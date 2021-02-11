-module(task5).
-export([create_index/1, present/1]).

-record(person, {name, birth, index = 0}).

%% row 20: syntax error before '>'
create_index(FileName) ->
	People = file:consult(FileName),
	people_sort(People),
	lists:keysort(3, People).

people_sort([Head|Tail]) ->
	people_sort_tail(Tail, Head, 1).

people_sort_tail([{Name, {Year, Month, Day}}|Tail], {PreviousName, {PreviousYear, PreviousMonth, PreviousDay}}, Index) ->
	if
		(list_to_integer(Month) > list_to_integer(PreviousMonth)) or 
		(list_to_integer(Month) == list_to_integer(PreviousMonth) and list_to_integer(Day) > list_to_integer(PreviousDay)) or 
		(list_to_integer(Month) == list_to_integer(PreviousMonth) and list_to_integer(Day) == list_to_integer(PreviousDay) and list_to_atom(Name) > list_to_atom(PreviousName))
			-> #person{name = Name, birth = {Year, Month, Day}, index = Index},[{Name, {Year, Month, Day}, Index}|people_sort_tail(Tail, {Year, Month, Day}, Index}, Index + 1)];
		false -> #person{name = Name, birth = {Year, Month, Day}, Index}, index = Index},[{Name, {Year, Month, Day}, Index}}|people_sort_tail(Tail, {PreviousYear, PreviousMonth, PreviousDay}, Index + 1)] 
	end;
people_sort_tail([], _, _) ->
	[].		
	
%% print format has to be corrected	
present(FileName) ->
	People = create_index(FileName),
	lists:foreach(fun(Elem) -> io:format("~p~n", Elem) end, People).