-module(vesmasina).

-export([start_link/0, button/0, init/1, callback_mode/0, idle/3, pre_wash/3, main_wash/3, rinse/3, dry/3, terminate/3, stop/0]).

-behaviour(gen_statem).

-define(NAME, vesmasina).

start_link() ->
    gen_statem:start_link({local,?NAME}, ?MODULE, [], []).
	
button() ->
    gen_statem:cast(?NAME, {button,[]}).
	
init(_Args) ->
    io:format("init\n", []),
    Data = #{stat => idle, temp => 0, quick => off, pre => off, dry => off},
	Actions = [{next_event, internal, dry}],
    {ok, idle, Data, Actions}.
	
callback_mode() ->
    state_functions.
	
terminate(_Reason, _State, _Data) ->
    %%State =/= locked andalso do_lock(),
    ok.
	
stop() ->
    %%gen_statem:stop(name()).
	exit(self(), kill).
	
idle(internal, dry, #{stat := idle, temp := 0, quick := off, pre := off, dry := off} = Data) ->
	io:format("mala vesmasina je idle...\n", []),
	{next_state, pre_wash, Data#{stat := pre_wash, temp := 0, quick := off, pre := off, dry := off}, [{state_timeout, 10000, idle}]};
idle(state_timeout, dry, #{stat := idle, temp := 0, quick := off, pre := off, dry := off} = Data) ->
	io:format("mala vesmasina je idle...\n", []),
	{next_state, pre_wash, Data#{stat := pre_wash, temp := 0, quick := off, pre := off, dry := off}, [{state_timeout, 10000, idle}]}.
	
pre_wash(state_timeout, idle, #{stat := pre_wash, temp := 0, quick := off, pre := off, dry := off} = Data) ->
	io:format("mala vesmasina je na pretpranjuuuuuu\n", []),
	{next_state, main_wash, Data#{stat := main_wash, temp := 0, quick := off, pre := off, dry := off}, [{state_timeout, 5000, pre_wash}]}.
	
main_wash(state_timeout, pre_wash, #{stat := main_wash, temp := 0, quick := off, pre := off, dry := off} = Data) ->
	io:format("mala vesmasina veselo pere pere pere\n", []),
	{next_state, rinse, Data#{stat := rinse, temp := 0, quick := off, pre := off, dry := off}, [{state_timeout, 10000, main_wash}]}.
	
rinse(state_timeout, main_wash, #{stat := rinse, temp := 0, quick := off, pre := off, dry := off} = Data) ->
	io:format("mala vesmasina ispire robu\n", []),
	{next_state, dry, Data#{stat := dry, temp := 0, quick := off, pre := off, dry := off}, [{state_timeout, 5000, rinse}]}.
	
dry(state_timeout, rinse, #{stat := dry, temp := 0, quick := off, pre := off, dry := off} = Data) ->
	io:format("mala vesmasina i susiiiiiiii\n", []),
	{next_state, idle, Data#{stat := idle, temp := 0, quick := off, pre := off, dry := off}, [{state_timeout, 15000, dry}]}.