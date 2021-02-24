-module(sup).

-export([start/0]).
-export([start_link/0]).
-export([init/1]).

-behaviour(supervisor).

start() ->
	start_link(),
	{ok, _ChildPid} = supervisor:start_child(sup, [self()]),
	loop().
	
loop() ->
	receive
		{ok, quitBtn, ChildPid} -> supervisor:restart_child(sup, ChildPid);
		{ok, spawnBtn, _ChildPid} -> start();
		{ok, errorBtn, ChildPid} -> supervisor:terminate_child(sup, ChildPid);
		_ -> io:format("kvak~n")
	after 10000 -> exit(normal)
	end,
	loop().

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
	process_flag(trap_exit, true),
    RestartStrategy = {simple_one_for_one, 10, 60},
    ChildSpec = {qes, {qes, start_link, []},
        permanent, 5000, worker, [qes]},
    Children = [ChildSpec],
    {ok, {RestartStrategy, Children}}.
	
	