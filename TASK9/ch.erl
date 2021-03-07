-module(ch).

-behaviour(gen_server).

-export([init/1]).
-export([handle_cast/2, handle_call/3, handle_info/2]).

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
	
handle_call(_Request, _From, _State) ->
	ok.
	
%% handle_info(_Req, #server{type_integration = Type_integration} = State) ->
	%% case Type_integration of 
		%% zt ->
			%% start_scaning();
		%% lmt ->
			%% wait_for_user_input();
	%% end
    %% {noreply, State#server{type_integration = ""}}.
	
%%handle_info(Info, State) ->
%%	receive
%%		{die, N} -> io:format("master restarting dead slave ~p.~n", [N]);
%%		{Message, N} -> io:format("Slave ~p got message ~p. ~n", [N, Message]);
%%		{'EXIT', From, normal} -> not_ok
%%	after 1000 -> exit(omg)
%%	end.

handle_info({die, N, From}, _State) ->
	io:format("Master restarting dead slave ~p.~n", [N]),
	From ! {die, N},
	{noreply, ok};
handle_info({Message, N, _From}, _State) ->
	io:format("Slave ~p got message ~p. ~n", [N, Message]),
	{noreply, ok}.