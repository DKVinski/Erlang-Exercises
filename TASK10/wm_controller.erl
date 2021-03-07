-module(wm_controller).

-export([start/1, start_tail/2, start_link/2, init/1, terminate/2, stop/0]).
-export([handle_cast/2, handle_call/3, handle_info/2, code_change/3]).
-export([add/0, remove/0, status/1, temperature/2, quick/2, pre/2, dry/2]).

-behaviour(gen_server).

-define(NAME, wm_controller).

-record(state, {list, n}).

start(N) ->
	List = start_tail(N, []),
	start_link(List, N+1).

start_link(List, N) ->
	gen_server:start_link({local, ?NAME}, ?MODULE, [List, N], []).

start_tail(N, List) when N > 0 ->
	{ok, Pid} = wm:start(N),
	start_tail(N-1, lists:append(List, [Pid]));
start_tail(0, List) ->
	List.
	
add() -> gen_server:cast(erlang:whereis(wm_controller), add).
	
remove() -> gen_server:cast(erlang:whereis(wm_controller), remove).
	
status(N) -> gen_server:cast(erlang:whereis(wm_controller), {stat, N}).
	
temperature(N, Temp) -> gen_server:cast(erlang:whereis(wm_controller), {temp, N, Temp}).
	
quick(N, OnOff) -> gen_server:cast(erlang:whereis(wm_controller), {quick, N, OnOff}).
	
pre(N, OnOff) -> gen_server:cast(erlang:whereis(wm_controller), {pre, N, OnOff}).
	
dry(N, OnOff) -> gen_server:cast(erlang:whereis(wm_controller), {dry, N, OnOff}).
	
	
init([List, N]) ->
	process_flag(trap_exit, true),
	io:format("List of washing machines: ~p~n",[List]),
	State = #state{list = List, n = N},
	{ok, State}.
	
terminate(_Reason, _State) ->
	ok.
	
stop() -> gen_server:stop(erlang:whereis(wm_controller), normal, 10).
	
handle_cast(add, State) ->
	{ok, Pid} = wm:start(),
	StateList = State#state.list,
	NewStateN = State#state.n + 1,
	NewStateList = lists:append(StateList, [Pid]),
	NewState = State#state{list = NewStateList, n = NewStateN},
	io:format("List of washing machines: ~p~n",[NewState]),
	{noreply, NewState};
handle_cast(remove, State) ->
	[_Head|Tail] = State#state.list,
	NewState = State#state{list = Tail},
	io:format("List of washing machines: ~p~n",[NewState]),
	{noreply, NewState};
handle_cast({stat, N}, State) ->
	io:format("Status controller start~n", []),
	erlang:whereis(erlang:list_to_atom(lists:append("washing_machine_", erlang:integer_to_list(N)))) ! {status_report},
	io:format("Status controller finish~n", []),
	{noreply, State};
handle_cast({temp, N, Temp}, State) ->
	erlang:whereis(erlang:list_to_atom(lists:append("washing_machine_", erlang:integer_to_list(N)))) ! {temp, Temp},
	{noreply, State};
handle_cast({quick, N, OnOff}, State) ->
	erlang:whereis(erlang:list_to_atom(lists:append("washing_machine_", erlang:integer_to_list(N)))) ! {quick, OnOff},
	{noreply, State};
handle_cast({pre, N, OnOff}, State) ->
	erlang:whereis(erlang:list_to_atom(lists:append("washing_machine_", erlang:integer_to_list(N)))) ! {pre, OnOff},
	{noreply, State};
handle_cast({dry, N, OnOff}, State) ->
	erlang:whereis(erlang:list_to_atom(lists:append("washing_machine_", erlang:integer_to_list(N)))) ! {dry, OnOff},
	{noreply, State}.

	
handle_call(_Request, _From, State) ->
	{reply, ok, State}.
	
handle_info(_Info, State) ->
	{noreply, State}.
	
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
	
	
