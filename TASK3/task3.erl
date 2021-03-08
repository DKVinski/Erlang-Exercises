-module(task3).
-export([person/3, print_oldest/2]).

person(Name, Age, Adress) when is_number(Age) ->
	Person = #{Name => {Age, Adress}}.
	%% maps:put(key, value, map)
	
print_oldest(Person1, Person2) when is_map(Person1), is_map(Person2) ->
	[Name1|_] = maps:keys(Person1),
	[Name2|_] = maps:keys(Person2),
	{Age1, Adress1} = maps:get(Name1, Person1),
	{Age2, Adress2} = maps:get(Name2, Person2),
	if 
		Age1 > Age2 -> io:format("~p, ~p~n", [Name1, Adress1]);
		false -> io:format("~p, ~p~n", [Name2, Adress2])
	end,
	ok.
	
