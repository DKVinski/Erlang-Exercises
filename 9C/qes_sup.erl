-module(qes).

-export([]).
-export([init/1]).
-export([handle_cast/2, handle_call/3, handle_info/2]).
-export([start_link/0]).

-include_lib("wx/include/wx.hrl").

-behaviour(supervisor).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
    io:format("ch has started (~w)~n", [self()]),
    {ok, chState}.

handle_cast(calc, State) ->
    {noreply, State};
handle_cast(calcbad, State) ->
    {noreply, State}.
	
handle_call(_Request, _From, _State) ->
	make_window(),
	ok.
	
handle_info(#wx{userData=Btn}, _State) ->
	case Btn of
		quitBtn -> make_window(), ok1;
		spawnBtn -> make_window(), ok2;
		errorBtn -> make_window(), ok3
	end,
	ok;
handle_info({window}, _state) ->
	make_window(),
	ok.
	
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

