-module(lock).
-export([]).

-behaviour(gen_fsm).

init() ->
	zero().

zero() ->
	receive
		{button, Button} -> SimPid ! {display, "Locked"}, one();
		{button, _} -> SimPid ! {display, "Locked"}
	end.
	
one() ->
	receive
		{button, Button} -> SimPid ! {display, "Locked"} two();
		{button, _} -> SimPid ! {display, "Locked"}
	end.
	
two() ->
	receive
		{button, Button} -> SimPid ! {display, "Locked"} three();
		{button, _} -> SimPid ! {display, "Locked"}
	end.
	
three() ->
	receive
		{button, Button} -> SimPid ! {display, "Open"} correct();
		{button, _} -> SimPid ! {display, "Locked"}
	end.
	
correct() ->
	time:sleep(10000),
	zero( , , ).
	
handle_sync_event() ->
	.

sync_send_event() ->
	.
	
code_change() ->
	.
	
terminate() ->
	.