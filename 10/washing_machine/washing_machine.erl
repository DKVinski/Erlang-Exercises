-module(washing_machine).

-export([start/0, start_link/0, init/1, terminate/2, stop/0]).
-export([handle_cast/2, handle_call/3, handle_info/2, code_change/3]).
-export([idle/1, idle_tail/1]).
-export([status/0, temperature/1, quick/1, pre/1, dry/1]).

-behaviour(gen_server).

-define(NAME, washing_machine).

-record(state, {phase, temp, quick, pre, dry, list}).

start() ->
	start_link().
	
start_link() ->
	gen_server:start_link({local, ?NAME}, ?MODULE, [], []).
	%%io:format("~p~n", [erlang:whereis(washing_machine)]).
	
init([]) ->
	process_flag(trap_exit, true),
	State = #state{phase = idle, temp = 40, quick = off, pre = on, dry = on, list = []},
	gen_server:cast(self(), idle),
	{ok, State}.
	
terminate(_Reason, _State) ->
	ok.

stop() ->
	gen_server:stop(erlang:whereis(washing_machine)).
	
%% prelasci iz stanja u stanje idu preko handle_cast
%% a dodavanje novih postavki u listu preko handle_info	
%% apply_after(Time, Module, Function, Arguments)
	
handle_cast(idle, State) ->
	NewState0 = State#state{phase = idle},
	NewState = idle(NewState0),
	io:format("idle~n",[]),
	%%io:format("idle, state: ~p~n",[NewState]),
	case NewState#state.quick of
		on -> timer:apply_after(10000, gen_server, cast, [self(), rinse]);
		off ->	case NewState#state.pre of
					on -> timer:apply_after(10000, gen_server, cast, [self(), pre_wash]);
					off -> timer:apply_after(10000, gen_server, cast, [self(), main_wash])
					end
	end,
	{noreply, NewState};
handle_cast(pre_wash, State) ->
	NewState = State#state{phase = pre_wash},
	io:format("pre_wash~n", []),
	%%io:format("pre_wash, state: ~p~n", [NewState]),
	timer:apply_after(5000, gen_server, cast, [self(), main_wash]),
	{noreply, NewState};
handle_cast(main_wash, State) ->
	NewState = State#state{phase = main_wash},
	io:format("main_wash~n", []),
	%%io:format("main_wash, state: ~p~n", [NewState]),
	timer:apply_after(10000, gen_server, cast, [self(), rinse]),
	{noreply, NewState};
handle_cast(rinse, State) ->
	NewState = State#state{phase = rinse},
	io:format("rinse~n", []),
	%%io:format("rinse, state: ~p~n", [NewState]),
	case NewState#state.quick of
		on -> timer:apply_after(5000, gen_server, cast, [self(), idle]);
		off -> case NewState#state.dry of
					on -> timer:apply_after(5000, gen_server, cast, [self(), dry]);
					off -> timer:apply_after(5000, gen_server, cast, [self(), idle])
				end
	end,
	{noreply, NewState};
handle_cast(dry, State) ->
	NewState = State#state{phase = dry},
	io:format("dry~n", []),
	%%io:format("dry, state: ~p~n", [NewState]),
	timer:apply_after(10000, gen_server, cast, [self(), idle]),
	{noreply, NewState}.

handle_info({status_report}, State) ->
	io:format("Status: ~p~n", [State]),
	{noreply, State};
handle_info({temp, Temp}, State) ->
	List = State#state.list,
	NewState = State#state{list = lists:append(List , [{temp, Temp}])},
	io:format("handle info, new state: ~p~n", [NewState]),
	{noreply, NewState};
handle_info({quick, OnOff}, State) ->
	List = State#state.list,
	NewState = State#state{list = lists:append(List, [{quick, OnOff}])},
	io:format("handle info, new state: ~p~n", [NewState]),
	{noreply, NewState};
handle_info({pre, OnOff}, State) ->
	List = State#state.list,
	NewState = State#state{list = lists:append(List, [{pre, OnOff}])},
	io:format("handle info, new state: ~p~n", [NewState]),
	{noreply, NewState};
handle_info({dry, OnOff}, State) ->
	List = State#state.list,
	NewState = State#state{list = lists:append(List, [{dry, OnOff}])},
	io:format("handle info, new state: ~p~n", [NewState]),
	{noreply, NewState}.
	
handle_call(_Request, _From, State) ->
	{reply, ok, State}.
	
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
	
%% internal 'state' function

idle(State) ->
	idle_tail(State).

idle_tail(#state{phase = _Phase, temp = _Temp, quick = _Quick, pre = _Pre, dry = _Dry, list = [Head|Tail]} = Current) ->
	case Head of
		{temp, Temp} -> io:format("new settings: new temperature ~p~n", [Temp]), 
							New = Current#state{phase = idle, temp = Temp, list = Tail}, idle_tail(New);
		{quick, OnOff} -> io:format("new settings: quick program ~p~n", [OnOff]),
							case OnOff of
								on -> New = Current#state{phase = idle, quick = OnOff, pre = off, dry = off, list = Tail}, idle_tail(New);
								off -> New = Current#state{phase = idle, quick = OnOff, list = Tail}, idle_tail(New)
							end;
		{pre, OnOff} -> io:format("new settings: prewash ~p~n", [OnOff]),
							New = Current#state{phase = idle, quick = off, pre = OnOff, list = Tail}, idle_tail(New);
		{dry, OnOff} -> io:format("new settings: drying ~p~n", [OnOff]),
							New = Current#state{phase = idle, quick = off, dry = OnOff, list = Tail}, idle_tail(New)
	end;
idle_tail(#state{phase = _Phase, temp = _Temp, quick = _Quick, pre = _Pre, dry = _Dry, list = []} = Current) ->
	Current.

%% input functions
%% komunicirat će s programom preko handle info, slat će serveru poruke koje ce handle_info obrađivat

status() ->
	erlang:whereis(washing_machine) ! {status_report}.
	
temperature(Temp) ->
	erlang:whereis(washing_machine) ! {temp, Temp}.
	
quick(OnOff) ->
	erlang:whereis(washing_machine) ! {quick, OnOff}.
	
pre(OnOff) ->
	erlang:whereis(washing_machine) ! {pre, OnOff}.
	
dry(OnOff) ->
	erlang:whereis(washing_machine) ! {dry, OnOff}.



%% cancel, end, skip ???