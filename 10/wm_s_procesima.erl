-module(wm_s_procesima).

-export([start_link/0, init/1, callback_mode/0, terminate/3, start/0, stop/0]).
-export([idle/3, pre_wash/3, main_wash/3, rinse/3, dry/3]).
-export([temperature/1, quick_program/1, prewash/1, dry/1]).
-export([skip/0, cancel/0, status/0]).

-behaviour(gen_statem).

-define(NAME, wm_s_procesima).

start() ->
	start_link().

start_link() ->
    gen_statem:start_link({local,?NAME}, ?MODULE, [], []).
	
init(_Args) ->
    io:format("init\n", []),
    Data = #{temp => 40, quick => off, pre => on, dry => on},
	Actions = [{next_event, internal, dry}],
	idle:start(Data),
	%%{ok, Pid} = idle:start(Data),
	%%io:format("~p~n",[erlang:process_info(Pid)]),
    {ok, idle, Data, Actions}.
	
callback_mode() ->
    state_functions.
	
terminate(_Reason, _State, _Data) ->
    ok.
	
stop() ->
    %%gen_statem:stop(name()).
	exit(self(), kill).
	
%% interface functions

temperature(Temp) ->
%%	gen_statem:cast(?NAME, {Data}).
%%	poslat poruku koja će se receivat u procesu, izmjenit state u procesu i vratit state kao datu state-u u statem-u
	whereis(idle) ! {ok, Temp, self()},
	receive
		{ok, Data} -> gen_statem:cast(?NAME, {Data}) %% cast ili call
	after 1000 -> not_ok
	end.
	
quick_program(OnOff_Q) ->
%%	gen_statem:cast(?NAME, {Data}).
%%	poslat poruku koja će se receivat u procesu, izmjenit state u procesu i vratit state kao datu state-u u statem-u
	whereis(idle) ! {quick, OnOff_Q, self()},
	receive
		{ok, Data} -> gen_statem:cast(?NAME, {Data}) %% cast ili call
	after 1000 -> not_ok
	end.
	
prewash(OnOff_P) ->
%%	gen_statem:cast(?NAME, {Data}).
%%	poslat poruku koja će se receivat u procesu, izmjenit state u procesu i vratit state kao datu state-u u statem-u
	whereis(idle) ! {pre, OnOff_P, self()},
	receive
		{ok, Data} -> gen_statem:cast(?NAME, {Data}) %% cast ili call
	after 1000 -> not_ok
	end.
	
dry(OnOff_D) ->
%%	gen_statem:cast(?NAME, {Data}).
%%	poslat poruku koja će se receivat u procesu, izmjenit state u procesu i vratit state kao datu state-u u statem-u
	whereis(idle) ! {dry, OnOff_D, self()},
	receive
		{ok, Data} -> gen_statem:cast(?NAME, {Data}) %% cast ili call
	after 1000 -> not_ok
	end.
	
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
idle(cast, {#{temp := Temp, quick := Quick, pre := Pre, dry := Dry} = Data}, #{temp := _Temp0, quick := _Quick0, pre := _Pre0, dry := _Dry0} = Data0) ->
	io:format("Nove postavke\n", []),
	{keep_state, idle, Data#{temp => Temp, quick => Quick, pre => Pre, dry => Dry}, [{state_timeout, 10000, idle}]};
idle(keep_state, idle, Data) ->
	io:format("mala vesmasina je idle...\n", []),
	case Pre of
		on -> {next_state, pre_wash, Data, [{state_timeout, 10000, idle}]};
		off -> {next_state, main_wash, Data, [{state_timeout, 10000, idle}]}
	end.
%%idle(cast, {temperature, NewTemp}, #{temp := _Temp, quick := Quick, pre := Pre, dry := Dry} = Data) ->
%%	io:format("mala vesmasina ce prat na novoj temperaturi\n", []),
%%	case Pre of
%%		on -> {next_state, pre_wash, Data#{temp => NewTemp, quick => Quick, pre => Pre, dry => Dry}, [{state_timeout, 10000, idle}]};
%%		off -> {next_state, main_wash, Data#{temp => NewTemp, quick => Quick, pre => Pre, dry => Dry}, [{state_timeout, 10000, idle}]}
%%	end;
%%idle(cast, {quick, OnOff}, #{temp := Temp, quick := _Quick, pre := Pre, dry := Dry} = Data) ->
%%	case OnOff of
%%		on -> io:format("mala vesmasina ce prat po kratkom programu jeeeejjjjjjjj\n", []),
%%				{next_state, rinse, Data#{temp => Temp, quick => on, pre => off, dry => off}, [{state_timeout, 10000, idle}]};
%%		off -> io:format("mala vesmasina NEce prat po kratkom programu jeeeejjjjjjjj\n", []),
%%				case Pre of
%%					on -> {next_state, pre_wash, Data#{temp => Temp, quick => off, pre => Pre, dry => Dry}, [{state_timeout, 10000, idle}]};
%%					off -> {next_state, main_wash, Data#{temp => Temp, quick => off, pre => Pre, dry => Dry}, [{state_timeout, 10000, idle}]}
%%				end
%%	end;
%%idle(cast, {pre, OnOff}, #{temp := Temp, quick := _Quick, pre := _Pre, dry := Dry} = Data) ->
%%	io:format("mala vesmasina ce ic na pretpranje kvak kvak\n", []),
%%	case OnOff of
%%		on -> {next_state, pre_wash, Data#{temp => Temp, quick => off, pre => on, dry => Dry}, [{state_timeout, 10000, idle}]};
%%		off -> {next_state, main_wash, Data#{temp => Temp, quick => off, pre => off, dry => Dry}, [{state_timeout, 10000, idle}]}
%%	end;
%%idle(cast, {dry, OnOff}, #{temp := Temp, quick := _Quick, pre := Pre, dry := _Dry} = Data) ->
%%	case OnOff of
%%		on -> io:format("mala vesmasina ce susit jupiiiiii\n", []), 
%%					{next_state, pre_wash, Data#{temp => Temp, quick => off, pre => Pre, dry => on}, [{state_timeout, 10000, idle}]};
%%		off -> io:format("mala vesmasina NEce susit \n", []),
%%				case Pre of
%%					on -> {next_state, pre_wash, Data#{temp => Temp, quick => off, pre => Pre, dry => off}, [{state_timeout, 10000, idle}]};
%%					off -> {next_state, main_wash, Data#{temp => Temp, quick => off, pre => Pre, dry => off}, [{state_timeout, 10000, idle}]}
%%				end
%%	end.
	
pre_wash(state_timeout, idle, Data) ->
	io:format("mala vesmasina je na pretpranjuuuuuu\n", []),
	pre_wash:start(Data),
	%%exit(whereis(pre_wash), kill),
	{next_state, main_wash, Data, [{state_timeout, 5000, pre_wash}]}.
	
main_wash(state_timeout, pre_wash, Data) ->
	io:format("mala vesmasina veselo pere pere pere\n", []),
	main_wash:start(Data),
	%%exit(whereis(main_wash), kill),
	{next_state, rinse, Data, [{state_timeout, 10000, main_wash}]};
main_wash(state_timeout, idle, Data) ->
	io:format("mala vesmasina veselo pere pere pere\n", []),
	main_wash:start(Data),
	%%exit(whereis(main_wash), kill),
	{next_state, rinse, Data, [{state_timeout, 10000, main_wash}]}.
	
rinse(state_timeout, main_wash, #{temp := _Temp, quick := _Quick, pre := _Pre, dry := Dry} = Data) ->
	io:format("mala vesmasina ispire robu\n", []),
	rinse:start(Data),
	%%exit(whereis(rinse), kill),
	case Dry of
		on -> {next_state, dry, Data, [{state_timeout, 5000, rinse}]};
		off -> {next_state, idle, Data, [{state_timeout, 5000, rinse}]}
	end;
rinse(state_timeout, idle, Data) ->
	io:format("mala vesmasina ispire robu\n", []),
	rinse:start(Data),
	%%exit(whereis(rinse), kill),
	{next_state, idle, Data, [{state_timeout, 5000, rinse}]}.
	
dry(state_timeout, rinse, Data) ->
	io:format("mala vesmasina i susiiiiiiii\n", []),
	dry:start(Data),
	%%exit(whereis(dry), kill),
	{next_state, idle, Data, [{state_timeout, 15000, dry}]}.
	%%stat tu?
	
%%omg funkcije

skip() ->
%% ubit trenutni proces
%% ispisat poruku
%% poslat datu s next_state next_state
	ok.

cancel() ->
%% ubit trenutni proces
%% ispisat poruku
%% poslat datu s next_state idle
	ok.

status() ->
%% doc do trenutnog procesa, u njemu receivat poruku i ispisat status
	ok.
	
