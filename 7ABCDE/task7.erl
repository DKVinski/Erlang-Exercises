-module(task7).
-compile(export_all).

-define(extention, ".beam").

%% needs to be run/debugged

for_each_module(Fun, Dir) ->
	{ok, Files} = file:list_dir(Dir),
	[Fun(list_to_atom(Mod)) || Mod <- Files, filename:extension(Mod) == extension].
	
get_module_info(Dir, Tag) ->
	for_each_module([fun(Elem) -> {Elem, file:find_source(Elem, Dir), Elem:module_info(Tag)} end], Dir).
	
get_apps_data(Tag) ->
	Data = get_module_info("code", Tag),
	lists:map(fun(Elem) -> {Mod, App, Info} = Elem, lists:flatten(Info) end,Data).
	
search4func(FuncName) ->
	[{Mod, App} || {Mod, App, {Name, Arity}} <- get_apps_data(functons), Name =:= FuncName].

%%todo
save_apps_data(FunctionName) ->
	ets:new(module_info_ets, [set, public]),
	for_each_module(fun(Elem) -> ets:insert(module_info_ets, get_apps_data(FunctionName))end , code:get_path(FunctionName)),
	ok.