-module(mathStuff).
-export([perimeter/1]).

perimeter({square, Side}) ->
	Side*4;
perimeter({circle, Radius}) ->
	Radius*2*math:pi();
perimeter({triangle, A, B, C}) ->
	A+B+C;
perimeter(_) ->
	throw(badarg).