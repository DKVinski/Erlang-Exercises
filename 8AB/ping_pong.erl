-module(ping_pong).
-export([start/0, ping/2, pong/0]).

ping(M, Pong) when is_integer(M) ->
	Pong ! {Ping, ping}
	receive
		{FromPid, pong} -> FromPid ! {Ping, ping}, io:format("ping")
	end
	ping(M - 1, Pong);
ping(0, Pong) ->
	receive
		{FromPid, pong} -> exit(normal)
	end.
	
pong() ->
	receive
		{FromPid, ping} -> FromPid ! {Pong, pong}, io:format("pong")
	end.

start_ping_pong() ->
	Ping = spawn(ping_pong, ping, [M, Pong]).
	Pong = spawn(ping_pong, pong, []).