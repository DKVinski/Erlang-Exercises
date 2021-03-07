-module(demo).
-export([factorial/1, double/1]).

factorial(0) ->
	1;
factorial(N) ->
	N * factorial(N - 1).
	
times(X, N) ->
	X * N.
double(X) ->
	times(X, 2).