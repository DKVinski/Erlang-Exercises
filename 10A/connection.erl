-module(connection).
-behaviour(gen_statem).

-export([start_link/1, request/2]).
-export([callback_mode/0, init/1]).
-export([disconnected/3, connected/3]).

%% Public API.

start_link(Opts) ->
    {host, Host} = proplists:lookup(host, Opts),
    {port, Port} = proplists:lookup(port, Opts),
    gen_statem:start_link(?MODULE, {Host, Port}, []).

request(Pid, Request) ->
    gen_statem:call(Pid, {request, Request}).

%% gen_statem callbacks

callback_mode() -> [state_functions, state_enter].

init({Host, Port}) ->
    Data = #{host => Host, port => Port, requests => #{}},
    Actions = [{next_event, internal, connect}],
    {ok, disconnected, Data, Actions}.

%% Disconnected state

disconnected(enter, disconnected, _Data) -> keep_state_and_data;

disconnected(enter, connected, #{requests := Requests} = Data) ->
    io:format("Connection closed~n"),

    lists:foreach(fun({_, From}) -> gen_statem:reply(From, {error, disconnected}) end,
                  Requests),

    Data1 = maps:put(socket, undefined, Data),
    Data2 = maps:put(requests, #{}, Data1),
    
    Actions = [{{timeout, reconnect}, 500, undefined}],
    {keep_state, Data2, Actions};

disconnected(internal, connect, #{host := Host, port := Port} = Data) ->
    case gen_tcp:connect(Host, Port, [binary, {active, true}]) of
        {ok, Socket} ->
            Data1 = maps:put(socket, Socket, Data),
            {next_state, connected, Data1};
        {error, Error} ->
            io:puts("Connection failed: ~ts~n", [inet:format_error(Error)]),
            keep_state_and_data
    end;

disconnected({timeout, reconnect}, _, Data) ->
    Actions = [{next_event, internal, connect}],
    {keep_state, Data, Actions};

disconnected({call, From}, {request, _}, _Data) ->
    Actions = [{reply, From, {error, disconnected}}],
    {keep_state_and_data, Actions}.

%% Connected state

connected(enter, _OldState, _Data) -> keep_state_and_data;

connected(info, {tcp_closed, Socket}, #{socket := Socket} = Data) ->
    {next_state, disconnected, Data};

connected({call, From}, {request, Request}, #{socket := Socket} = Data) ->
    #{id := RequestId} = Request,

    case gen_tcp:send(Socket, encode_request(Request)) of
        ok ->
            #{requests := Requests} = Data,
            Requests1 = maps:put(RequestId, From, Requests),
            Data1 = maps:put(requests, Data, Requests1),
            {keep_state, Data1};
        {error, _} ->
            ok = gen_tcp:close(Socket),
            {next_state, disconnected, Data}
    end;

connected(info, {tcp, Socket, Packet}, #{socket := Socket} = Data) ->
    #{requests := Requests} = Data,
    #{id := Id} = Response = decode_response(Packet),
    From = maps:get(Id, Requests),
    Requests1 = maps:remove(Id, Requests),
    Data1 = maps:put(requests, Requests1, Data),
    
    gen_statem:reply(From, {ok, Response}),
    {keep_state, Data1}.