-module(lists1).
-export([nth/2, sublist/2, seq/2, insert/2, insertion_sort/1]).

nth(N, [_|Tail]) when N > 1 ->
	nth(N-1, Tail);
nth(1, [Head|_]) ->
	Head;
nth(_, []) ->
	exit("element not found").
	
sublist(N, [Head|Tail]) when N > 1 ->
	[Head|sublist(N-1, Tail)];
sublist(1, [Head|_]) ->
	[Head];
sublist(_, []) ->
	exit("not enough elements in the list").
	
seq(Low, High) when Low < High ->
	[Low|seq(Low+1, High)];
seq(Low, High) when Low == High ->
	[High].

%% list has to be sorted
insert(X, [Head|Tail]) when X > Head ->
	[Head|insert(X, Tail)];
insert(X, [Head|Tail]) when X < Head ->
	[X|[Head|Tail]];
insert(X, []) ->
	[X].
	
	
insertion_sort([Head|[]]) ->
	[Head];
insertion_sort([Head|Tail]) ->
	insert(Head, insertion_sort(Tail)).