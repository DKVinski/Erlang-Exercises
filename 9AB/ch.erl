-module(ch).

-behaviour(gen_server).

-export([init/1]).
-export([handle_cast/2, handle_call/3]).

-export([start_link/0]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init(_Args) ->
    %%io:format("child has started (~w)~n", [self()]),
    {ok, chState}.

handle_cast(calc, State) ->
    {noreply, State};
handle_cast(calcbad, State) ->
    {noreply, State}.
	
handle_call(_Request, From, _State) ->
	receive
		{die, N} -> io:format("master restarting dead slave ~p.~n", [N]), From ! {die, N};
		{Message, N} -> io:format("Slave ~p got message ~p. ~n", [N, Message]), From ! {Message, N}
	end,
	ok.