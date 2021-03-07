-module(predicate).
-export([func/0]).

-include_lib("xmerl/include/xmerl.hrl").

func() -> 
	fun(Elem) -> 
		case Elem#xmlElement.name of
			title -> true;
			description -> true;
			_ -> false
		end
	end.