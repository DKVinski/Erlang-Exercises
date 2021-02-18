-module(predicate).
-export([func/1]).

-include_lib("xmerl/include/xmerl.hrl").

func(Elem) ->
	fun() -> 
		if
			Elem -> true
		end
	end.