-module(sup).

-export([start/1, start_link/1, init/1]).

-behaviour(supervisor).

start(N) ->
	io:format("sup start~n", []),
	{ok, SupPid} = start_link(N),
	io:format("sup start_link end, sup pid: ~p, self: ~p~n", [SupPid, self()]),
	{ok, Child} = supervisor:start_child(erlang:list_to_atom(lists:append("supervisor_", erlang:integer_to_list(N))), []),
	io:format("sup start end, child: ~p, sup: ~p~n", [Child, SupPid]).
	%%loop(SupPid).

start_link(N) ->
	Name = lists:append("supervisor_", erlang:integer_to_list(N)),
	supervisor:start_link({local, erlang:list_to_atom(Name)}, ?MODULE, [N, erlang:list_to_atom(Name)]).
	
init([N, SupName]) ->
	io:format("sup init~n", []),
	process_flag(trap_exit, true),
    RestartStrategy = {simple_one_for_one, 10, 60},
    ChildSpec = {qes, {qes, start, [N, erlang:whereis(SupName)]},
        permanent, 5000, worker, [qes]},
    Children = [ChildSpec],
	io:format("sup init end~n", []),
    {ok, {RestartStrategy, Children}}.
	
%%loop(SupPid) ->
%%	io:format("sup loop~n", []),
%%	receive
%%		{quit,Pid} -> 
%%		{error,Pid} -> 
%%	after 5000 -> exit(normal)
%%	end,
%%	loop(SupPid).