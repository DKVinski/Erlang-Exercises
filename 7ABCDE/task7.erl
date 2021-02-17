-module(task7).
-export([for_each_module/2, get_module_info/2, get_apps_data/1, search4func/1]).

-define(extension, ".beam").

for_each_module(Fun, Dir) ->
	{ok, Files} = file:list_dir(Dir),
	[Fun(list_to_atom(Mod)) || Mod <- Files, filename:extension(Mod) == ?extension].
	
get_module_info(Dir, Tag) ->
	for_each_module(fun(Elem) -> {Elem, filelib:find_source(Elem, Dir), (list_to_atom(filename:basename(Elem, ?extension))):module_info(Tag)} end, Dir).
	
get_apps_data(Tag) ->
	Paths = code:get_path(),
	get_apps_data_tail(Paths, [], Tag).
	
get_apps_data_tail([Head|Tail], Acc, Tag) ->
	Data = get_module_info(Head, Tag),
	get_apps_data_tail(Tail, [Data, Acc], Tag),
	[Acc | Data];
get_apps_data_tail([], _, _) -> 
	[].
	
search4func(FuncName) ->
	io:format("~p~n", [get_apps_data(functions)]),
	Kvak = [{Mod, App} || {Mod, App, Name} <- search4func_tail(get_apps_data(functions), []), Name == FuncName],
	io:format("~p,~n",[Kvak]).
	
search4func_tail([Head|Tail], Acc1) ->
	Acc4 = lists:append(Acc1, search4func_tail_tail(Head, [])),
	search4func_tail(Tail, Acc1),
	Acc4;
search4func_tail([],_Acc1) ->
	[].
	
search4func_tail_tail({Mod,{_ok, App},[{Name, _}|NameTail]}, Acc2) ->
	search4func_tail_tail({Mod,{_ok, App},NameTail}, Acc2),
	Acc3 = lists:append(Acc2,{Mod, App, Name});
search4func_tail_tail([], _Acc2) ->
	[];
search4func_tail_tail({_Mod,{_ok, _App},[]}, []) ->
	[].

%%save_apps_data() ->
%%	ets:new(module_info_ets, [set, public]),
%%	for_each_module(fun(Elem) -> ets:insert(module_info_ets, get_apps_data(FunctionName))end , code:get_path(FunctionName)),
%%	ok.