-module(sup2).

-export([start/2, start_link/2, init/1]).

-behaviour(supervisor).

start(N, M) ->
	io:format("sup start~n", []),
	{ok, SupPid} = start_link(N, M),
	io:format("sup start_link end, sup pid: ~p, self: ~p~n", [SupPid, self()]),
	{ok, Child} = supervisor:start_child(erlang:list_to_atom(lists:append(lists:append("supervisor_", erlang:integer_to_list(N)), erlang:integer_to_list(M))), []),
	io:format("sup start end, child: ~p, sup: ~p~n", [Child, SupPid]).
	%%loop(SupPid).

start_link(N, M) ->
	Name = lists:append(lists:append("supervisor_", erlang:integer_to_list(N)), erlang:integer_to_list(M)),
	supervisor:start_link({local, erlang:list_to_atom(Name)}, ?MODULE, [N, M, erlang:list_to_atom(Name)]).
	
init([N, M, SupName]) ->
	io:format("sup init~n", []),
	process_flag(trap_exit, true),
    RestartStrategy = {simple_one_for_one, 10, 60},
    ChildSpec = {qes2, {qes2, start, [N, M, erlang:whereis(SupName)]},
        permanent, 5000, worker, [qes2]},
    Children = [ChildSpec],
	io:format("sup init end~n", []),
    {ok, {RestartStrategy, Children}}.
