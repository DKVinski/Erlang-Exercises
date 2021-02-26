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
	
search4func(FuncName) ->
	%%io:format("~p~n", [get_apps_data(functions)]),
	Kvak = [{Mod, App} || {Mod, App, FuncName} <- search4func_tail(lists:flatten(ets:lookup(module_info_ets, FuncName)), [])],
	io:format("~p,~n",[Kvak]).
	
search4func_tail([Head|Tail], Acc1) ->
	Acc4 = lists:append(Acc1, Head),
	search4func_tail(Tail, Acc4);
search4func_tail([],Acc1) ->
	Acc1.

save_apps_data() ->
	ets:new(module_info_ets, [bag, public]),
	[for_each_module(fun(_Elem) -> 
			ets:insert(module_info_ets, {Func, {Mod, App}}) end , code:get_path()) || {Mod, App, Func} <- get_apps_data(functions)],
	ok.