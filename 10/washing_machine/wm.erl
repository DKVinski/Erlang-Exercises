-module(wm).

-export([start/1, start_link/1, init/1, terminate/2, stop/0]).
-export([handle_cast/2, handle_call/3, handle_info/2, code_change/3]).
-export([idle/1, idle_tail/1]).
-export([status/0, temperature/1, quick/1, pre/1, dry/1]).

-behaviour(gen_server).

-record(state, {phase, temp, quick, pre, dry, list, name}).

start(N) ->
	start_link(N).
	
start_link(N) ->
	NameName = lists:append("washing_machine_", erlang:integer_to_list(N)),
	{ok, Pid} = gen_server:start_link({local, erlang:list_to_atom(NameName)}, ?MODULE, NameName, []),
	self() ! {pid, Pid},
	{ok, Pid}.
	%%io:format("~p~n", [erlang:whereis(washing_machine)]).
	
init(NameName) ->
	process_flag(trap_exit, true),
	State = #state{phase = idle, temp = 40, quick = off, pre = on, dry = on, list = [], name = erlang:list_to_atom(NameName)},
	gen_server:cast(self(), idle),
	{ok, State}.

terminate(_Reason, _State) ->
	ok.

stop() ->
	receive
		{pid, ProcessPid} -> gen_server:stop(ProcessPid)
	after 1000 -> exit(normal)
	end.
	
	
%% prelasci iz stanja u stanje idu preko handle_cast
%% a dodavanje novih postavki u listu preko handle_info	
%% apply_after(Time, Module, Function, Arguments)
	
handle_cast(idle, State) ->
	NewState0 = State#state{phase = idle},
	NewState = idle(NewState0),
	io:format("~p: idle~n",[NewState#state.name]),
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
	io:format("~p: pre_wash~n", [State#state.name]),
	%%io:format("pre_wash, state: ~p~n", [NewState]),
	timer:apply_after(5000, gen_server, cast, [self(), main_wash]),
	{noreply, NewState};
handle_cast(main_wash, State) ->
	NewState = State#state{phase = main_wash},
	io:format("~p: main_wash~n", [State#state.name]),
	%%io:format("main_wash, state: ~p~n", [NewState]),
	timer:apply_after(10000, gen_server, cast, [self(), rinse]),
	{noreply, NewState};
handle_cast(rinse, State) ->
	NewState = State#state{phase = rinse},
	io:format("~p: rinse~n", [State#state.name]),
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
	io:format("~p: dry~n", [State#state.name]),
	%%io:format("dry, state: ~p~n", [NewState]),
	timer:apply_after(10000, gen_server, cast, [self(), idle]),
	{noreply, NewState}.

handle_info({status_report}, State) ->
	%%io:format("Status info start~n", []),
	%%io:format("složeno: ~p, self: ~p~n", [erlang:whereis(erlang:list_to_atom(lists:append("washing_machine_", erlang:integer_to_list(N)))), self()]),
	%%gen_server:call(erlang:whereis(erlang:list_to_atom(lists:append("washing_machine_", erlang:integer_to_list(N)))), {status_report}),
	%%io:format("Status info finish~n", []),
	io:format("~p status: ~p~n", [State#state.name, State]),
	{noreply, State};
handle_info({temp, Temp}, State) ->
	List = State#state.list,
	NewState = State#state{list = lists:append(List , [{temp, Temp}])},
	io:format("~p, new state: ~p~n", [State#state.name, NewState]),
	%%gen_server:call(erlang:whereis(erlang:list_to_atom(lists:append("washing_machine_", erlang:integer_to_list(N)))), {temp, Temp}),
	{noreply, NewState};
handle_info({quick, OnOff}, State) ->
	List = State#state.list,
	NewState = State#state{list = lists:append(List, [{quick, OnOff}])},
	io:format("~p, new state: ~p~n", [State#state.name, NewState]),
	%%gen_server:call(erlang:whereis(erlang:list_to_atom(lists:append("washing_machine_", erlang:integer_to_list(N)))), {quick, OnOff}),
	{noreply, NewState};
handle_info({pre, OnOff}, State) ->
	List = State#state.list,
	NewState = State#state{list = lists:append(List, [{pre, OnOff}])},
	io:format("~p, new state: ~p~n", [State#state.name, NewState]),
	%%gen_server:call(erlang:whereis(erlang:list_to_atom(lists:append("washing_machine_", erlang:integer_to_list(N)))), {pre, OnOff}),
	{noreply, NewState};
handle_info({dry, OnOff}, State) ->
	List = State#state.list,
	NewState = State#state{list = lists:append(List, [{dry, OnOff}])},
	io:format("~p, new state: ~p~n", [State#state.name, NewState]),
	%%gen_server:call(erlang:whereis(erlang:list_to_atom(lists:append("washing_machine_", erlang:integer_to_list(N)))), {dry, OnOff}),
	{noreply, NewState}.
%%hvatat odgovore od calla i prosljedit stabje
	
handle_call({status_report}, _From, State) ->
	io:format("~p status: ~p~n", [State#state.name, State]),
	{reply, ok, State};
handle_call({temp, Temp}, _From, State) ->
	List = State#state.list,
	NewState = State#state{list = lists:append(List , [{temp, Temp}])},
	io:format("~p, new state: ~p~n", [State#state.name, NewState]),
	{reply, ok, NewState};
handle_call({quick, OnOff}, _From, State) ->
	List = State#state.list,
	NewState = State#state{list = lists:append(List, [{quick, OnOff}])},
	io:format("~p, new state: ~p~n", [State#state.name, NewState]),
	{reply, ok, NewState};
handle_call({pre, OnOff}, _From, State) ->
	List = State#state.list,
	NewState = State#state{list = lists:append(List, [{pre, OnOff}])},
	io:format("~p, new state: ~p~n", [State#state.name, NewState]),
	{reply, ok, NewState};
handle_call({dry, OnOff}, _From, State) ->
	List = State#state.list,
	NewState = State#state{list = lists:append(List, [{dry, OnOff}])},
	io:format("~p, new state: ~p~n", [State#state.name, NewState]),
	{reply, ok, NewState}.
	
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
	
%% internal 'state' function

idle(State) ->
	io:format("~p:~n", [State#state.name]),
	idle_tail(State).

idle_tail(#state{phase = _Phase, temp = _Temp, quick = _Quick, pre = _Pre, dry = _Dry, list = [Head|Tail]} = Current) ->
	case Head of
		{temp, Temp} -> io:format("new settings: new temperature ~p~n", [ Temp]), 
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
	receive
		{pid, ProcessPid} -> self() ! {pid, ProcessPid}, gen_server:call(ProcessPid, {status_report})
	after 1000 -> exit(normal)
	end.
	
temperature(Temp) ->
	receive
		{pid, ProcessPid} -> self() ! {pid, ProcessPid}, gen_server:call(ProcessPid, {temp, Temp})
	after 1000 -> exit(normal)
	end.	
	
quick(OnOff) ->
	receive
		{pid, ProcessPid} -> self() ! {pid, ProcessPid}, gen_server:call(ProcessPid, {quick, OnOff})
	after 1000 -> exit(normal)
	end.	
	
pre(OnOff) ->
	receive
		{pid, ProcessPid} -> self() ! {pid, ProcessPid}, gen_server:call(ProcessPid, {pre, OnOff})
	after 1000 -> exit(normal)
	end.
	
dry(OnOff) ->
	receive
		{pid, ProcessPid} -> self() ! {pid, ProcessPid}, gen_server:call(ProcessPid, {dry, OnOff})
	after 1000 -> exit(normal)
	end.
