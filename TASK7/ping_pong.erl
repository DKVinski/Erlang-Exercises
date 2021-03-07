-module(ping_pong).
-export([start/0, ping/2, pong/0]).

ping(M, Pong) when M > 0 ->
	Pong ! {self(), ping},
	receive
		{FromPid, pong} -> io:format("ping~n", [])
	end,
	ping(M - 1, Pong);
ping(0, Pong) ->
	Pong ! done.
	
pong() ->
	receive
		done -> io:format("pong~n", []), exit(normal);
		{FromPid, ping} -> io:format("pong~n", []), FromPid ! {self(), pong}
	end,
	pong().

start() ->
	Pong = spawn(ping_pong, pong, []),
	spawn(ping_pong, ping, [4, Pong]).