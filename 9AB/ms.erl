-module(ms).
-export([start_link/0]).
-export([init/1]).
-export([start/1, start_tail/2, to_slave/2, find_slave/1, find_slave_tail/2]).

-behaviour(supervisor).

start(N) ->
	start_link(), %%proces registriran kao ms
	start_tail(N, []),
	io:format("true~n", []).
	
start_tail(N, List) when N > 0 ->
	%%supervisor:start_child(Sup, ChildSpec)
	{ok, ChildPid} = supervisor:start_child(ms, []),
	%%io:format("{Pid: ~p}~n", [ChildPid]),
	start_tail(N-1, [ChildPid | List]);
start_tail(0, List) ->
	List.

start_link() ->
    {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
    {ok, Pid}.

init(_Args) ->
	process_flag(trap_exit, true),
    RestartStrategy = {simple_one_for_one, 10, 60},
    ChildSpec = {ch, {ch, start_link, []},
        permanent, brutal_kill, supervisor, [ch]},
    Children = [ChildSpec],
    {ok, {RestartStrategy, Children}}.
	
to_slave(Message, N) ->
	io:format("{~p, ~p}", [Message, N]),
	Pid = find_slave(N),
	Pid ! {Message, N, self()},
	receive
		{die, N} -> supervisor:restart_child(ms, Pid),ok
	after 500 -> ok
	end.
	
find_slave(N) ->
	Slaves = supervisor:which_children(ms),
	{_Id, Child, _Type, _Modules} = find_slave_tail(N, Slaves),
	Child.
	
find_slave_tail(N, [_Head|Tail]) when N > 1 ->
	%%io:format("{List: ~p}", [[Head|Tail]]),
	find_slave_tail(N - 1, Tail);
find_slave_tail(1, [Head|_Tail]) ->
	Head.