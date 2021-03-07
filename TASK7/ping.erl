-module(ping).
-export([start/ 0, ping/1]).

start() ->
	Ping = spawn(ping, ping, [self()]).
	
ping(Ping) ->
	self() ! {Ping, ping},
	receive
		{FromPid, ping} -> FromPid ! {Ping, pong};
		stop -> exit(normal);
		{FromPid, Message} -> io:format("~p~n", [Message]), FromPid ! stop
	end.
	