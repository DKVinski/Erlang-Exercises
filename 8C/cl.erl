-module(cl).
-export([start/1, init/2, zero/3, one/3, two/3, three/3, four/3, open/2]).

start(Code) ->
	LogicPid = spawn( fun() -> true end),
	SimPid = cl_sim:start(LogicPid),
	init(SimPid, Code).
	
init(SimPid, Code) ->
	SimPid ! {display, "locked"},
	zero(SimPid, Code, Code).
	
zero(SimPid, [Head|Tail], Code) ->
	receive
		{button, Head} -> one(SimPid, Tail, Code);
		{button, _} -> zero(SimPid, Code, Code)
	after 3000 -> exit(normal)
	end.
	
one(SimPid, [Head|Tail], Code) ->
	receive
		{button, Head} -> two(SimPid, Tail, Code);
		{button, _} -> zero(SimPid, Code, Code)
	after 3000 -> exit(normal)
	end.
	
two(SimPid, [Head|Tail], Code) ->
	receive
		{button, Head} -> three(SimPid, Tail, Code);
		{button, _} -> zero(SimPid, Code, Code)
	after 3000 -> exit(normal)
	end.

three(SimPid, [Head|Tail], Code) ->
	receive
		{button, Head} -> four(SimPid, Tail, Code);
		{button, _} -> zero(SimPid, Code, Code)
	after 3000 -> exit(normal)
	end.
	
four(SimPid, [Head|[]], Code) ->
	receive
		{button, Head} -> open(SimPid, Code);
		{button, _} -> zero(SimPid, Code, Code)
	after 3000 -> exit(normal)
	end.
	
open(SimPid, Code) ->
	SimPid ! {display, "open"},
	timer:sleep(5000),
	SimPid ! {display, "locked"},
	zero(SimPid, Code, Code).