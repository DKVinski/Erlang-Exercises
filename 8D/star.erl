-module(star).
-export([start/2, star_center/2, spawn_sides/2, star_side/0, kill_sides/1, star_messaging_M/2, star_messaging_Pid/2]).

start(N,M) ->
	Centar = spawn(star, star_center, [N,M]),
	io:format("center ~p~n", [Centar]).
	
star_center(N,M) ->
	SidesList = spawn_sides(N, []),
	io:format("sides ~p~n", [SidesList]),
	star_messaging_M(M, SidesList),
	star_side(),
	kill_sides(SidesList),
	io:format("end~n"),
	exit(normal).
	
spawn_sides(N, ListOfSides) when N > 0 ->
	spawn_sides(N-1, [spawn(star, star_side, [])|ListOfSides]); %% list of sides' pids
spawn_sides(0, ListOfSides) ->
	ListOfSides.
	
star_side() ->
	receive
		{message, CenterPid, Number} -> io:format("message ~p from center to ~p~n", [Number, self()]), 
											CenterPid ! {message, self(), Number}, star_side()
	end.
	
kill_sides([Head|Tail]) ->
	exit(Head, kill),
	kill_sides(Tail);
kill_sides([]) ->
	ok.
	
star_messaging_M(M, SidesList) when M > 0 -> 				%% for every number in M
	io:format(".~n"),
	star_messaging_Pid(M, SidesList),						%% goes around the sides
	star_messaging_M(M-1, SidesList);
star_messaging_M(0, _SidesLIst) ->
	ok.
	
star_messaging_Pid(M, [Head|Tail]) when M > 0 ->
	Head ! {message, self(), M},
	receive
		{message, SidePid, M} -> io:format("message from ~p to center~n", [SidePid]), star_messaging_Pid(M, Tail);
		{message, _SidePid, _} -> error("invalid message~n"), exit(kill)
	end;
star_messaging_Pid(_, []) ->
	ok.