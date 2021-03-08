-module(omg).
-export([for_each_module/2, get_module_info/2, get_apps_data/1, search4func/1, save_apps_data/0, get_data_tail/2, get_func_tail/4]).

-define(extension, ".beam").

for_each_module(Fun, Dir) ->
	%%io:format("dir: ~p~n", [Dir]),
	%%io:format("grrrrrrrrrrrrrrr~n~p~n",[file:list_dir(Dir)]).
	case filelib:is_dir(Dir) of
		true -> {ok, Files} = file:list_dir(Dir), [Fun(list_to_atom(Mod)) || Mod <- Files, filename:extension(Mod) == ?extension];
		false -> []
	end.
	
get_module_info(Dir, Tag) ->
	for_each_module(fun(Elem) -> {Elem, filename:dirname(Elem), 
									(list_to_atom(filename:basename(Elem, ?extension))):module_info(Tag)} end, Dir).
									
get_apps_data(Tag) ->
	Paths = code:get_path(),
	%%{ok, CurrentDirectory} = file:get_cwd(),
	%%Paths = [CurrentDirectory],
	List = lists:map(fun(Elem) -> %%io:format("get_apps_data_tail: ~p~n", [Elem]), 
									lists:flatten([Elem]) end, get_apps_data_tail(Paths, [], Tag)),
	lists:flatten(List).
	
get_apps_data_tail([Head|Tail], Acc, Tag) ->
	Data = get_module_info(Head, Tag),
	DataList = get_data_tail(Data, []),
	get_apps_data_tail(Tail, lists:append([DataList], [Acc]), Tag);
get_apps_data_tail([], Acc, _) -> 
	Acc.
	
get_data_tail([Head|Tail], Acc) ->
	{Mod, App, Func} = Head,
	FuncList = get_func_tail(Func, Mod, App, []),
	get_data_tail(Tail, lists:append(FuncList, Acc));
get_data_tail([], Acc) ->
	Acc.

get_func_tail([Head|Tail], Mod, App, Acc) ->
	get_func_tail(Tail, Mod, App, lists:append([{Mod, App, Head}] , Acc));
get_func_tail([], _Mod, _App, Acc) ->
	Acc.

search4func(FuncName) ->
	%%io:format("~p~n", [get_apps_data(functions)]),
	TableId = save_apps_data(),
	[{Mod, App} ||  {_Func, {Mod, App}} <- ets:lookup(TableId, FuncName)].

save_apps_data() ->
	TableId = ets:new(module_info_ets, [duplicate_bag]),
	[ets:insert(TableId,{Func, {Mod, App}}) || {Mod, App, {Func, _Arrity}} <- get_apps_data(functions)],
	%%io:format("table: ~p~n", [ets:tab2list(TableId)]),
	TableId.
