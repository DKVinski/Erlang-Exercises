-module(wm).

-export([start_link/0, init/1, callback_mode/0, terminate/3, start/0, stop/0]).
-export([idle/3, pre_wash/3, main_wash/3, rinse/3, dry/3]).
-export([temperatureE/1, quick_program/1, prewash/1, dryY/1]).
-export([skip/0, cancel/0, status/0]).

-behaviour(gen_statem).

-define(NAME, wm).

start() ->
	start_link().

start_link() ->
    gen_statem:start_link({local,?NAME}, ?MODULE, [], []).
	
init(_Args) ->
    io:format("init\n", []),
    Data = #{temp => 40, quick => off, pre => on, dry => on},
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
	
%% interface functions

temperatureE(Temp) ->
	gen_statem:cast(?NAME, {temperature, Temp}).
	
quick_program(OnOff) ->
	gen_statem:cast(?NAME, {quick, OnOff}).
	
prewash(OnOff) ->
	gen_statem:cast(?NAME, {pre, OnOff}).
	
dryY(OnOff) ->
	gen_statem:cast(?NAME, {dry, OnOff}).
	
%% state functions
	
idle(internal, dry, #{temp := 40, quick := off, pre := on, dry := on} = Data) ->
	io:format("mala vesmasina je idle...\n", []),
	{next_state, pre_wash, Data, [{state_timeout, 10000, idle}]};
idle(state_timeout, dry, #{temp := _Temp, quick := _Quick, pre := Pre, dry := _Dry} = Data) ->
	io:format("mala vesmasina je idle...\n", []),
	case Pre of
		on -> {next_state, pre_wash, Data, [{state_timeout, 10000, idle}]};
		off -> {next_state, main_wash, Data, [{state_timeout, 10000, idle}]}
	end;
idle(state_timeout, rinse, #{temp := _Temp, quick := _Quick, pre := Pre, dry := _Dry} = Data) ->
	io:format("mala vesmasina je idle...\n", []),
	case Pre of
		on -> {next_state, pre_wash, Data, [{state_timeout, 10000, idle}]};
		off -> {next_state, main_wash, Data, [{state_timeout, 10000, idle}]}
	end;
idle(cast, {temperature, NewTemp}, #{temp := _Temp, quick := Quick, pre := Pre, dry := Dry} = Data) ->
	io:format("mala vesmasina ce prat na novoj temperaturi\n", []),
	case Pre of
		on -> {next_state, pre_wash, Data#{temp => NewTemp, quick => Quick, pre => Pre, dry => Dry}, [{state_timeout, 10000, idle}]};
		off -> {next_state, main_wash, Data#{temp => NewTemp, quick => Quick, pre => Pre, dry => Dry}, [{state_timeout, 10000, idle}]}
	end;
idle(cast, {quick, OnOff}, #{temp := Temp, quick := _Quick, pre := Pre, dry := Dry} = Data) ->
	case OnOff of
		on -> io:format("mala vesmasina ce prat po kratkom programu jeeeejjjjjjjj\n", []),
				{next_state, rinse, Data#{temp => Temp, quick => on, pre => off, dry => off}, [{state_timeout, 10000, idle}]};
		off -> io:format("mala vesmasina NEce prat po kratkom programu jeeeejjjjjjjj\n", []),
				case Pre of
					on -> {next_state, pre_wash, Data#{temp => Temp, quick => off, pre => Pre, dry => Dry}, [{state_timeout, 10000, idle}]};
					off -> {next_state, main_wash, Data#{temp => Temp, quick => off, pre => Pre, dry => Dry}, [{state_timeout, 10000, idle}]}
				end
	end;
idle(cast, {pre, OnOff}, #{temp := Temp, quick := _Quick, pre := _Pre, dry := Dry} = Data) ->
	io:format("mala vesmasina ce ic na pretpranje kvak kvak\n", []),
	case OnOff of
		on -> {next_state, pre_wash, Data#{temp => Temp, quick => off, pre => on, dry => Dry}, [{state_timeout, 10000, idle}]};
		off -> {next_state, main_wash, Data#{temp => Temp, quick => off, pre => off, dry => Dry}, [{state_timeout, 10000, idle}]}
	end;
idle(cast, {dry, OnOff}, #{temp := Temp, quick := _Quick, pre := Pre, dry := _Dry} = Data) ->
	case OnOff of
		on -> io:format("mala vesmasina ce susit jupiiiiii\n", []), 
					{next_state, pre_wash, Data#{temp => Temp, quick => off, pre => Pre, dry => on}, [{state_timeout, 10000, idle}]};
		off -> io:format("mala vesmasina NEce susit \n", []),
				case Pre of
					on -> {next_state, pre_wash, Data#{temp => Temp, quick => off, pre => Pre, dry => off}, [{state_timeout, 10000, idle}]};
					off -> {next_state, main_wash, Data#{temp => Temp, quick => off, pre => Pre, dry => off}, [{state_timeout, 10000, idle}]}
				end
	end.
	
pre_wash(state_timeout, idle, Data) ->
	io:format("mala vesmasina je na pretpranjuuuuuu\n", []),
	{next_state, main_wash, Data, [{state_timeout, 5000, pre_wash}]}.
	
main_wash(state_timeout, pre_wash, Data) ->
	io:format("mala vesmasina veselo pere pere pere\n", []),
	{next_state, rinse, Data, [{state_timeout, 10000, main_wash}]};
main_wash(state_timeout, idle, Data) ->
	io:format("mala vesmasina veselo pere pere pere\n", []),
	{next_state, rinse, Data, [{state_timeout, 10000, main_wash}]}.
	
rinse(state_timeout, main_wash, #{temp := _Temp, quick := _Quick, pre := _Pre, dry := Dry} = Data) ->
	case Dry of
		on -> io:format("mala vesmasina ispire robu\n", []), {next_state, dry, Data, [{state_timeout, 5000, rinse}]};
		off -> io:format("mala vesmasina ispire robu\n", []), {next_state, idle, Data, [{state_timeout, 5000, rinse}]}
	end;
rinse(state_timeout, idle, Data) ->
	io:format("mala vesmasina ispire robu\n", []),
	{next_state, idle, Data, [{state_timeout, 5000, rinse}]}.
	
dry(state_timeout, rinse, Data) ->
	io:format("mala vesmasina i susiiiiiiii\n", []),
	{next_state, idle, Data, [{state_timeout, 15000, dry}]}.
	%%stat tu?
	
%%omg

skip() ->
	ok.
	
cancel() ->
	ok.

status() ->
	ok.