-module(lists2).
-export([append/2, reverse/1, flatten/1]).

append([Head1|Tail1], [Head2|Tail2]) ->
	[Head1|append(Tail1, [Head2|Tail2])];
append([], [Head2|Tail2]) ->
	[Head2|Tail2];
append(X, []) ->
	[X];
append([], []) ->
	[].
	
reverse([Head|Tail]) ->
	append(reverse(Tail), [Head]);
reverse([]) ->
	[].
	
flatten(X) -> 
	reverse(flatten(X,[])).
flatten([],Acc) -> 
	Acc;
flatten([Head|Tail],Acc) when is_list(Head) -> 
	flatten(Tail, flatten(Head,Acc));
flatten([Head|Tail],Acc) -> 
	flatten(Tail,[Head|Acc]).