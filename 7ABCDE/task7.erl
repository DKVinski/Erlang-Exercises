-module(task7).
-compile(export_all).

-define(Extention, ".beam").

%% needs to be run/debugged

for_each_module(Fun, Dir) ->
	{ok, Files} = file:list_dir(Dir),
	[Fun(list_to_atom(Mod)) || Mod <- Files, filename:extension(_) =:= Extension].
	
get_module_info(Dir, Tag) ->
	for_each_module([fun(Elem) -> {Elem, find_source(Elem, Dir), Elem:module_info(Tag)} end], Dir).
	
get_apps_data(Tag) ->
	Data = get_module_info("code", Tag),
	lists:map(fun(Elem) -> {Mod, App, Info} = Elem, lists:flatten(Info) end,Data).
	
search4func(FuncName) ->
	[{Mod, App} || {Mod, App, {Name, Arity}} <- get_apps_data(functons), Name =:= FuncName].

%%todo
save_apps_data() ->
	ETS = ets:new(module_info_ets, [set, public]),
	for_each_module([fun(Elem) -> ETS:insert(module_info_ets, {})] ,Dir),
	ok.