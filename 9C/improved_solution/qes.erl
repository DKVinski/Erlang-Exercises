-module(qes).

-export([start/2, start_link/2, init/1, handle_call/3, handle_cast/2, handle_info/2]).
-include_lib("wx/include/wx.hrl").

-behaviour(gen_server).

-record(state, {supPid, nextN}).

start(N, SupPid) ->
	io:format("qes start~n", []),
	start_link(N, SupPid).

start_link(N, SupPid) ->
	Name = lists:append("qes_", erlang:integer_to_list(N)),
	io:format("qes start_link~n", []),
	gen_server:start_link({local, erlang:list_to_atom(Name)}, ?MODULE, [N, SupPid],[]).
	
init([N, SupPid]) ->
	io:format("qes init~n", []),
	process_flag(trap_exit, true),
	make_window(),
	State = #state{supPid = SupPid, nextN = N+1},
	io:format("qes init end~n", []),
    {ok, State}.

handle_call(_Request, _From, State) ->
	{reply, ok, State}.
	
handle_cast(_Request, State) ->
	{noreply, State}.
	
handle_info(#wx{userData=Btn}, State) ->
	case Btn of
		quitBtn ->  exit(self(), normal);
		spawnBtn -> sup:start(State#state.nextN); %%gen_server:start_link({global, erlang:list_to_atom(lists:append("supervisor_", erlang:integer_to_list(State#state.nextN)))}, sup, [State#state.nextN, erlang:list_to_atom(lists:append("supervisor_", erlang:integer_to_list(State#state.nextN)))], [{timeout, 100}]);
		errorBtn -> supervisor:restart_child(State#state.supPid, self())
	end,
	{noreply, State}.
 

%% ----------------------------------------------------------------------
%% Opens a window with three buttons for
%%  QUIT:   Closes window and all child windows
%%  SPAWN:  Spawns of a child window
%%  ERROR:  Dies because of an error, all children will also die.
%%          The window should be restarted by the parent window.
%% Title of the window will be the pid of the calling process.
%% The calling process will receive messages when a button is pressed.
%% Messages look like:
%% #wx{userData=ButtonName}
%%      where ButtonName is: quitBtn, spawnBtn or errorBtn
%% Returns: ok
%% ----------------------------------------------------------------------
make_window() ->
    W = wxFrame:new(wx:new(), ?wxID_ANY, pid_to_list(self())),
    P = wxPanel:new(W),
    Sz = wxBoxSizer:new(?wxHORIZONTAL),
    Q = wxButton:new(P, ?wxID_ANY, [{label, "Quit"}]),
    S = wxButton:new(P, ?wxID_ANY, [{label, "Spawn"}]),
    E = wxButton:new(P, ?wxID_ANY, [{label, "Error"}]),
    wxButton:setBackgroundColour(Q, {150, 250, 150}),
    wxButton:setBackgroundColour(S, {150, 150, 250}),
    wxButton:setBackgroundColour(E, {250, 150, 150}),
    wxSizer:add(Sz, Q),
    wxSizer:add(Sz, S),
    wxSizer:add(Sz, E),
    wxButton:connect(Q, command_button_clicked, [{userData, quitBtn}]),
    wxButton:connect(S, command_button_clicked, [{userData, spawnBtn}]),
    wxButton:connect(E, command_button_clicked, [{userData, errorBtn}]),
    wxPanel:setSizer(P, Sz),
    wxSizer:fit(Sz, W),
    wxFrame:show(W),
    ok.

