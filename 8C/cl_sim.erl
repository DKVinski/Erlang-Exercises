%% ------------------------------------------------------------
%% The Graphic for the Code Lock
%% ------------------------------------------------------------

-module(cl_sim).
-export([start/1]).
-include_lib("wx/include/wx.hrl").

start(LogicPid) ->
    spawn_link(fun() -> init(LogicPid) end).

init(LogicPid) ->
    Win = wxFrame:new(wx:new(), ?wxID_ANY, "Code Lock"),
    Panel = wxPanel:new(Win),
    TopSz = wxBoxSizer:new(?wxVERTICAL),

    Lbl = create_info_panel(Panel, TopSz),
    _ = create_numeric_panel(Panel, TopSz),

    %% Setup the sizer and size the window appropriately
    wxWindow:setSizer(Panel, TopSz),
    wxSizer:fit(TopSz, Win),
    %% Connect to events
    wxFrame:connect(Win, command_button_clicked),
    wxFrame:connect(Win, close_window, [{skip, true}]),
    wxFrame:show(Win),
    event_loop(#{pid=>LogicPid, label=>Lbl}).

create_info_panel(Parent, TopSz) ->
    %% Make text window with background color and centered text
    TextPanel = wxPanel:new(Parent),
    wxWindow:setBackgroundColour(TextPanel, {255,110,114}),
    TextSz = wxBoxSizer:new(?wxVERTICAL),
    Lbl = wxStaticText:new(TextPanel, ?wxID_ANY, "Locked"),
    wxSizer:addStretchSpacer(TextSz),  %% vertical align
    wxSizer:add(TextSz, Lbl, [{flag, ?wxALIGN_CENTER}]),
    wxSizer:addStretchSpacer(TextSz),  %% vertical align
    wxSizer:setMinSize(TextSz, -1, 40),
    wxWindow:setSizer(TextPanel, TextSz),
    %% Add it in the topwindow
    Flags0 = [{border, 5}, {flag, ?wxALL bor ?wxALIGN_CENTER bor ?wxEXPAND}],
    wxSizer:add(TopSz, TextPanel, [{proportion, 1}|Flags0]),
    Lbl.

create_numeric_panel(Parent, TopSz) ->
    %% Make buttons and setup layout
    [Zero|One2Nine] = [wxButton:new(Parent, Id, [{label, integer_to_list(Id)}])
               || Id <- lists:seq(0, 9)],
    GSz = wxGridSizer:new(3),
    _ = [wxSizer:add(GSz, Button) || Button <- One2Nine],
    wxSizer:addStretchSpacer(GSz),  %% Empty left of zero
    wxSizer:add(GSz, Zero),
    wxSizer:addStretchSpacer(GSz),  %% Empty right of zero
    %% Place it in the topwindow
    Flags1 = [{border, 5}, {flag, ?wxALL bor ?wxALIGN_CENTER}],
    wxSizer:add(TopSz, GSz, [{proportion, 0}|Flags1]),
    ok.

event_loop(State = #{pid:=LogicPid, label:=Lbl}) ->
    receive
    #wx{id=Id, event=#wxCommand{}} ->
        LogicPid ! {button, Id},
        event_loop(State);
    #wx{event=#wxClose{}} ->
        exit(LogicPid, close_window);
    {display, String} ->
        wxStaticText:setLabel(Lbl, String),
        event_loop(State);
    Other ->
        io:format("event_loop got other:~w~n", [Other]),
        event_loop(State)
    end.
 
