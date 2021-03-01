-module(main_wash).
-export([start/0, start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-behaviour(gen_server).

start() ->
	start_link().

start_link() ->
	gen_server:start_link({local, ?NAME}, ?MODULE, [], []).

init(Args) ->
	io:format("State: ~p~n", [Args]),
	{ok, Args}.
	
handle_call(_Request, _From, State) ->
    {reply, ok, State}.
	
handle_cast(_Msg, State) ->
    {noreply, State}.
	
handle_info(_Info, State) ->
	%%todo
    {noreply, State}.
	
terminate(_Reason, _State) ->
    ok.
	
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
	
