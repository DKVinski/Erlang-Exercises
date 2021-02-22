-module(ms_fail).
-export([start/1, to_slave/2, slave/0, start_slaves/2]).

start(N) ->
	register(master, self()),
	Slaves = start_slaves(N, []),
	%%process_flag(trap_exit, true),
	io:format("true~n"),
	io:format("slaves ~p~n", [Slaves]),
	self() ! {Slaves},
	ok.
	%%wait_for_message(Slaves).
	
start_slaves(N, List) when N > 0 ->
	start_slaves(N-1, [spawn_link(ms, slave, []) | List]);
start_slaves(0, List) ->
	List.
	
to_slave(Message, N) ->
	self() ! {Message, N},
	receive
		{die, N} -> receive
					{Slaves} -> lists:nth(N, Slaves) ! {die, N}, slave(), 
								io:format("master restarting dead slave ~p.~n", [N]), List = [spawn(ms, slave, []) | Slaves], self() ! {List}
					after 1000 -> io:format("majko mila opet nije dobio slavove"), exit(normal)
					end;
		{'EXIT',{_Reason,_Stk}} -> receive
									{Slaves} -> io:format("master restarting dead slave.~n", []), 
												List = [spawn(ms, slave, []) | Slaves], self() ! {List}
									after 1000 -> io:format("majko mila opet nije dobio slavove"), exit(normal)
									end;
		{'EXIT',_Reason} ->	receive
							{Slaves} -> io:format("master restarting dead slave.~n", []), 
										List = [spawn(ms, slave, []) | Slaves], self() ! {List}
							after 1000 -> io:format("majko mila opet nije dobio slavove"), exit(normal)
							end;
		{Message, N} -> receive
						{Slaves} -> io:format("{~p, ~p}	", [Message, N]), io:format("~p~n", [Slaves]), lists:nth(N, Slaves) ! {Message, N}, slave(), self() ! {Slaves}, io:format("jel dojde tu")
						after 1000 -> io:format("majko mila opet nije dobio slavove"), exit(normal)
						end
	after 30000 -> exit(normal)
	end.
	
slave() ->
	io:format("~p~n", [self()]),
	receive
		{die, _N} -> exit(self(),kill);
		{Message, N} -> io:format("Slave ~p got message ~p. ~p~n", [N, Message, self()]), exit(omg)
	after 100000 -> exit(normal)
	end,
	ok.