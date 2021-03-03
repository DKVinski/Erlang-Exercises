-module(washing_machine).
-define(NAME, washing_machine).

-export([start_link/0, name/0, init/1, callback_mode/0, code_change/4, terminate/3]).
-export([idle/3, pre_wash/3, main_wash/3, rinse/3, dry/3]).
-export([start/0, stop/0, push/0]).
-export([handle_event/3]).

-behaviour(gen_statem).

name() -> washing_machine_statem.

start_link() ->
	gen_statem:start_link(?MODULE, [], []).
	
init(Args) ->
	io:format("init~n", []),
	%%process_flag(trap_exit, true),
	State = idle,
	Data = {0, off, off, off}, %% {Temp, Quick, Pre, Dry}
	{ok, State, Data}.
	
callback_mode() ->
	%% handle_event.	
	state_functions.
	
code_change(_Vsn, State, Data, _Extra) ->
    {ok,State,Data}.
	
terminate(_Reason, _State, _Data) ->
    ok.
	
%% interface functions

%%temperature(Temp) ->
	%%.
	
%%quick_programme(OnOff) ->
	%%.
	
%%prewash(OnOff) ->
	%%.
	
%%dry(OnOff) ->
	%%.
	
start() ->
	start_link().
	
%%skip() ->
%%	gen_statem:call(name(), skip).
	
%%cancel() ->
%%	gen_statem:call(name(), cancel).
	
%%status() ->
%%	gen_statem:call(name(), status).
	
stop() ->
    %%gen_statem:stop(name()).
	exit(self(), kill).
	
%% state functions

idle({call,From}, push, _Data0) -> %% traje dok se ne unesu parametri programa
	%% pozvat interfejs
	io:format("idle~n", []),
	%%receive
		%%{ok, skip} -> pre_wash;
		%%{ok, cancel} -> idle;
		%%{ok, status} -> io:format("~n", [])........
		%%{temperature, T} -> Temp = T;
		%%{quickP, Q} -> Quick = Q;
		%%{preW, P} -> Pre = P;
		%%{dryY, D} -> Dry = D
	%%after 20000 -> ok
	%%end
	Temp = 0, Quick = off, Pre = off, Dry = off,
	Data = #{temp => Temp, quick => Quick, pre => Pre, dry => Dry, remaining => {Temp, Quick, Pre, Dry}},
	Actions = [{next_event, internal, pre_wash}],
	{next_state,pre_wash,Data, [{reply,From,pre_wash}]};
idle(EventType, EventContent, Data) ->
    handle_event(EventType, EventContent, Data).
	
pre_wash(internal, idle, Data) -> %% traje 5 s
	io:format("prewash~n", []),
	%%receive
		%%{ok, skip} -> main_wash;
		%%{ok, cancel} -> idle;
		%%{ok, status} -> io:format("~n", [])........
	%%after 5000 -> ok
	%%end,
	{next_state,main_wash,Data,[{reply,main_wash}]}.
	
main_wash(enter, _OldState, Data) -> %% traje 10 s
	io:format("main wash~n", []),
	%%receive
		%%{ok, skip} -> rinse;
		%%{ok, cancel} -> idle;
		%%{ok, status} -> io:format("~n", [])........
	%%after 10000 -> ok
	%%end,
	{next_state,rinse,Data,[{reply,rinse}]}.
	
rinse(enter, _OldState, Data) -> %% traje 5 s
	io:format("rinse~n", []),
	%%receive
		%%{ok, skip} -> dry;
		%%{ok, cancel} -> idle;
		%%{ok, status} -> io:format("~n", [])........
	%%after 5000 -> ok
	%%end,
	{next_state,dry,Data,[{reply,dry}]}.

dry(enter, _OldState, Data) -> %% traje 15 s
	io:format("dry~n", []),
	%%receive
		%%{ok, skip} -> idle;
		%%{ok, cancel} -> idle;
		%%{ok, status} -> io:format("~n", [])........
	%%after 15000 -> ok
	%%end,
	{next_state,idle,Data,[{reply,idle}]}.

%%handle_event

handle_event({call,From}, idle, Data) ->
    %% Reply with the current count
    {next_state, pre_wash,Data,[{reply,From,Data}]};
handle_event(_, _, Data) ->
    %% Ignore all other events
    {keep_state,Data}.
	
%%todo
%% automatski prijelaz u iduće stanje
%% svako stanje je PROCES (gen_server)
%% omogućit funkcije interfejsa uvjek
%% gen_statem:start_timer

%% kad se ulazi u func za svaku fazu u njoj se spawna novi proces

push() ->
    gen_statem:call(name(), idle).