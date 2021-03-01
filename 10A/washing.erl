-module(washing).

-export([start_link/0, button/0, init/1, callback_mode/0, idle/3, wash/3, terminate/3]).

-behaviour(gen_statem).

-define(NAME, washing).

start_link() ->
    gen_statem:start_link({local,?NAME}, ?MODULE, [], []).
	
button() ->
    gen_statem:cast(?NAME, {button,[]}).
	
init(_Args) ->
    io:format("init\n", []),
    Data = #{prog => 0},
	Actions = [{next_event, internal, wash}],
    {ok, idle, Data, Actions}.
	
callback_mode() ->
    state_functions.
	
%% omggggggggggggggggg
idle(internal, wash, #{prog := 0} = Data) ->
	io:format("mala vesmasina nestrpljiva ceka da ju se uposli\n", []),
	{next_state, wash, Data#{prog := 0},
	[{state_timeout,10000,idle}]}.
	
wash(state_timeout, idle,  Data) ->
    io:format("jedna mala vesmasina pere pere pere\n", []),
    {next_state, idle, Data,
	[{state_timeout,10000,wash}]}.
	
terminate(_Reason, _State, _Data) ->
    %%State =/= locked andalso do_lock(),
    ok.