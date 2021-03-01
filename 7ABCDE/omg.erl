-module(omg).
-export([for_each_module/2, get_module_info/2, get_apps_data/1, search4func/1, save_apps_data/0]).

-define(extension, ".beam").

for_each_module(Fun, Dir) ->
	{ok, Files} = file:list_dir(Dir),
	[Fun(list_to_atom(Mod)) || {Mod} <- Files, filename:extension(Mod) == ?extension].
	
get_module_info(Dir, Tag) ->
	for_each_module(fun(Elem) -> {Elem, filelib:find_source(Elem, Dir), 
									(list_to_atom(filename:basename(Elem, ?extension))):module_info(Tag)} end, Dir).
	
get_apps_data(Tag) ->
	Paths = code:get_path(),
	List = lists:map(fun(Elem) -> lists:flatten([Elem]) end, get_apps_data_tail(Paths, [], Tag)),
	lists:flatten(List).
		
get_apps_data_tail([Head|Tail], Acc, Tag) ->
	Data = get_module_info(Head, Tag),
	get_apps_data_tail(Tail, [Data, Acc], Tag),
	[Acc | Data];
get_apps_data_tail([], _, _) -> 
	[].
	
	
%% run-time error
%% 8> omg:search4func(ping).
%% exception error: bad argument
%%   in function  ets:lookup/2
%%      called as ets:lookup(module_info_ets,ping)
%%   in call from omg:search4func/1 (omg.erl, line 29)

search4func(FuncName) ->
	%%io:format("~p~n", [get_apps_data(functions)]),
	TableId = save_apps_data(),
	Kvak = [{Mod, App} ||  {_Func, {Mod, App}} <- ets:lookup(TableId, FuncName)],
	io:format("~p,~n",[Kvak]).

save_apps_data() ->
	TableId = ets:new(module_info_ets, [bag, public]),
	[for_each_module(fun(_Elem) -> 
			ets:insert(TableId, {Func, {Mod, App}}) end , code:get_path()) || {Mod, App, Func} <- get_apps_data(functions)],
	TableId.