-module(washing_machine).
-define(NAME, washing_machine).

-export([start_link/0]).

-behaviour(gen_statem).

start_link() ->
	gen_statem:start_link({local, ?NAME}, ?MODULE, [], []).
	
%%init
%%callback_mode (state funcs, handle events funcs)