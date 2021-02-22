-module(qes).

-export([start/0, make_window/0, loop/0]).
-export([start_link/0]).
-export([init/1]).
-include_lib("wx/include/wx.hrl").

-behaviour(supervisor).

%%start() ->
%%	make_window(),
%%	receive
%%		#wx{userData=quitBtn} -> exit(kvak)
%%	after 10000 ->exit(normal)
%%	end.

start() ->
	{ok, _Pid} = start_link(),
	make_window(),
	loop().

start_link() ->
    {ok, Pid} = supervisor:start_link({local, ?MODULE}, 
        ?MODULE, []),
    {ok, Pid}.

init(_Args) ->
    RestartStrategy = {simple_one_for_one, 10, 60},
    ChildSpec = {child, {child, start_link, []},
        permanent, brutal_kill, worker, [child]},
    Children = [ChildSpec],
    {ok, {RestartStrategy, Children}}.

loop() ->
	receive
		#wx{userData=quitBtn} -> {ok, Pid} = supervisor:restart_child(child, []), Pid ! {restart};
		#wx{userData=spawnBtn} -> {ok, Pid} = supervisor:start_child(child, []), Pid ! {new};
		#wx{userData=errorBtn} -> supervisor:terminate_child(child, []), {ok, Pid} = supervisor:start_child(child, []), Pid ! {error}
	after 10000 -> exit(omg)
	end,
	receive
		{restart} -> make_window();
		{new} -> make_window();
		{error} -> make_window()
	after 10000 -> exit(normal)
	end,
	loop().

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

