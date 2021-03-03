-module(wm_controller).

-export([start/1, start_tail/2, start_link/1, init/1, terminate/2, stop/0, stop_tail/1]).
-export([handle_cast/2, handle_call/3, handle_info/2, code_change/3]).
-export([add/0, remove/0, get_status/1, temperature/2, quick/2, pre/2, dry/2]).

-behaviour(gen_server).

-define(NAME, wm_controller).

start(N) ->
	State = start_tail(N, []),
	start_link(State).

start_link(State) ->
	gen_server:start_link({local, ?NAME}, ?MODULE, [State], []).

start_tail(N, List) when N > 0->
	{ok, Pid} = washing_machine:start(),
	start_tail(N-1, lists:append(List, [Pid]));
start_tail(0, List) ->
	List.
	
add() ->
	gen_server:cast(self(), add).
	
remove() ->
	gen_server:cast(self(), remove).
	
get_status(WmNumber) ->
	gen_server:cast(self(), {stat, WmNumber}).
	
temperature(N, Temp) ->
	gen_server:cast(self(), {temp, N, Temp}).
	
quick(N, OnOff) ->
	gen_server:cast(self(), {quick, N, OnOff}).
	
pre(N, OnOff) ->
	gen_server:cast(self(), {pre, N, OnOff}).
	
dry(N, OnOff) ->
	gen_server:cast(self(), {dry, N, OnOff}).
	
	
init(State) ->
	process_flag(trap_exit, true),
	io:format("List of washing machines: ~p~n",[State]),
	{ok, State}.
	
terminate(_Reason, State) ->
	stop_tail(State),
	ok.
	
stop() ->
	gen_server:stop(erlang:whereis(wm_controller)).
	
stop_tail([Head|Tail]) ->
	exit(Head, normal),
	stop_tail(Tail);
stop_tail([]) ->
	ok.
	
handle_cast(add, State) ->
	{ok, Pid} = washing_machine:start(),
	NewState = lists:append(State, [Pid]),
	io:format("List of washing machines: ~p~n",[NewState]),
	{noreply, NewState};
handle_cast(remove, State) ->
	[_Head|Tail] = State,
	io:format("List of washing machines: ~p~n",[Tail]),
	{noreply, Tail};
handle_cast({stat, N}, State) ->
	WmPid = lists:nth(N, State),
	WmPid ! {status_report};
handle_cast({temp, N, Temp}, State) ->
	WmPid = lists:nth(N, State),
	WmPid ! {temp, Temp};
handle_cast({quick, N, OnOff}, State) ->
	WmPid = lists:nth(N, State),
	WmPid ! {quick, OnOff};
handle_cast({pre, N, OnOff}, State) ->
	WmPid = lists:nth(N, State),
	WmPid ! {pre, OnOff};
handle_cast({dry, N, OnOff}, State) ->
	WmPid = lists:nth(N, State),
	WmPid ! {dry, OnOff}.

	
handle_call(_Request, _From, State) ->
	{reply, ok, State}.
	
handle_info(_Info, State) ->
	{noreply, State}.
	
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
	
	
