-module(funs).
-export([llen/1]).

llen(List) ->
	lists:map(fun(Elem) -> erlang:length(Elem) end, List).