-module(task7).
-compile(export_all).

-define(Extention, ".beam").

for_each_module(Fun, Dir) ->
	{ok, Files} = file:list_dir(Dir),
	Modules = [Fun(list_to_atom(Mod)) || Mod <- Files, filename:extension(_) =:= Extension].
	
get_module_info(Dir, Tag) ->
	[{Mod1,App,Info1}, {Mod2,App,Info2}, …].
	