-module(cl).
-export([start/1, zero/2, one/3, two/3, three/3, open/2]).

start(Code) ->
	LogicPid = spawn(cl, zero, [Code, Code]),
	SimPid = cl_sim:start(LogicPid),
	LogicPid ! {ok, SimPid}.
	%%init(Code).	
	
zero([Head|Tail], Code) ->
	io:format("zero ~p ~p ~n", [self(), Head]),
	receive
		{ok, Pid} -> SimPid = Pid,
						receive
							{button, Head} -> one(SimPid, Tail, Code),
								io:format(".~n");
							{button, _} -> self() ! {ok, SimPid}, zero(Code, Code)
						end
	end.
	
one(SimPid, [Head|Tail], Code) ->
	io:format("one ~p ~p ~n", [self(), Head]),
	receive
		{button, Head} -> two(SimPid, Tail, Code);
		{button, _} -> self() ! {ok, SimPid}, zero(Code, Code)
	after 10000 -> self() ! {ok, SimPid}, zero(Code, Code)
	end.
	
two(SimPid, [Head|Tail], Code) ->
	io:format("two ~p ~p ~n", [self(), Head]),
	receive
		{button, Head} -> three(SimPid, Tail, Code);
		{button, _} -> self() ! {ok, SimPid}, zero(Code, Code)
	after 10000 -> self() ! {ok, SimPid}, zero(Code, Code)
	end.

three(SimPid, [Head|_Tail], Code) ->
	io:format("three ~p ~p ~n", [self(), Head]),
	receive
		{button, Head} -> open(SimPid, Code);
		{button, _} -> self() ! {ok, SimPid}, zero(Code, Code)
	after 10000 -> self() ! {ok, SimPid}, zero(Code, Code)
	end.
	
open(SimPid, Code) ->
	io:format("open ~p ~n", [self()]),
	SimPid ! {display, "open"},
	timer:sleep(10000),
	SimPid ! {display, "locked"},
	self() ! {ok, SimPid},
	zero(Code, Code).