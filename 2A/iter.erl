-module(iter).
-export([ford/1, foru/1, sum/1]).

ford(1) ->
	[1];
ford(N) ->
	[N|ford(N-1)].

foru(N) ->
	lists:reverse(ford(N)).


sum(1) ->
	1;
sum(N) ->
	sum(N-1) + N.