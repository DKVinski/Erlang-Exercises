-module(my_sup).
-export([start/1, loop/0]).
%%-export([start_link/0, init/1])

%%-behaviour(supervisor).

start(SupervisedPid) ->
	link(SupervisedPid),
	process_flag(trap_exit, true),
	loop().
	
loop() ->
	receive
		{'EXIT',{Reason,_Stk}} -> io:format("ERROR ~p~n", [Reason]), exit(normal);
		{'EXIT',Reason} -> io:format("EXIT ~p~n", [Reason]), exit(normal);
		Term -> io:format("THROW ~p~n", [Term]), exit(normal)
	end,
	loop().

%%start_link() ->
%%    supervisor:start_link(my_sup, []).
%%
%%init(_Args) ->
%%    SupFlags = #{strategy => simple_one_for_one,
%%                 intensity => 0,
%%                 period => 1},
%%    ChildSpecs = [#{id => call,
%%                    start => {call, start_link, []},
%%                    shutdown => brutal_kill}],
%%    {ok, {SupFlags, ChildSpecs}}.
