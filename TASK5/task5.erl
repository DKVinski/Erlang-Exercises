-module(task5).
-export([create_index/1, present/1]).

-record(person, {name, birth, index = 0}).

create_index(FileName) ->
	People = file:consult(FileName),
	
	%% #person{name = Name, birth = {Year, Month, Day}, index = {Month, Day, Name}},
	{ok, PeopleList} = People,
	ListOfPeople = create_list_of_records(PeopleList, []),
	lists:keysort(4, ListOfPeople).
	
create_list_of_records([{Name, {Year, Month, Day}}|Tail], ListTilNow) ->
	List = [#person{name = Name, birth = {Year, Month, Day}, index = {Month, Day, Name}}|ListTilNow],
	create_list_of_records(Tail, List);
create_list_of_records([], List) ->
	List.

present(FileName) ->
	People = create_index(FileName),
	lists:foreach(fun(Elem) -> {Year,Month,Day}=Elem#person.birth, io:format("~p, ~p.~p.~n", [Elem#person.name, Day, Month]) end, People).