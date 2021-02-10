-module(task5).
-export([create_index/1, present/1]).

-record(person, {name, birth, index = 0}).

create_index(FileName) ->
	People = file:consult(FileName),
	people_sort(People),
	lists:keysort(3, People).

people_sort([Head|Tail]) ->
	people_sort_tail(Tail, Head, 1).

people_sort_tail([Head|Tail], Previous, Index) ->
	{Name, Birth} = Head,
	{PreviousName, PreviousBirth} = Previous,
	{Year, Month, Day} = Birth,
	{PreviousYear, PreviousMonth, PreviousDay} = PreviousBirth,
	if
		Month > PreviousMonth or (Month == PreviousMonth and Day > PreviousDay) or (Month == PreviousMonth and Day == PreviousDay and Name > PreviousName) -> [#person{Name, Birth, Index}|people_sort_tail(Tail, Head, Index + 1)];
		false -> [#person{Name, Birth, Index}|people_sort_tail(Tail, Previous, Index + 1)] 
	end;
people_sort_tail([], _, _) ->
	[].		
	
%% print format has to be corrected	
present(FileName) ->
	People = create_index(FileName),
	lists:foreach(fun(Elem) -> io:format("~p~n", Elem) end, People).