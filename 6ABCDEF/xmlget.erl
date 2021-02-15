%%%-------------------------------------------------------------------
%%% File    : xmlget.erl
%%% Author  : Peter Andersson
%%%
%%% Description : Help module for exercise 6.
%%%-------------------------------------------------------------------
-module(xmlget).

-export([url2file/2, url2rec/1, file2rec/1, get_page/1]).

-include_lib("kernel/include/file.hrl").
-include_lib("xmerl/include/xmerl.hrl").

-define(PROXY, "www-proxy.ericsson.se").
-define(PROXYPORT, 8080).

%%%-----------------------------------------------------------------
%%% url2file(URL, File) -> ok | {error,Reason}
%%%
%%% URL = string(), e.g. "planet.trapexit.org/general/rss20.xml".
%%% File = string(), e.g. "/tmp/xmldata".
%%%
%%% Description: Copies the web page at URL to local file.
%%%-----------------------------------------------------------------
url2file(URL, File) ->
    case get_page(URL) of
	{ok,Result} ->
	    log("Writing XML data to file: ~s~n", [File]),
	    case write_to_file(File, extract_xml(URL, Result)) of
		ok ->
		    ok;
		Error = {error,Why} ->
		    log("Saving to ~s failed: ~p~n", [File,Why]),
		    Error
	    end;
	Error ->
	    Error
    end.

%%%-----------------------------------------------------------------
%%% url2rec(URL) -> XmlElement | {error,Reason}
%%%
%%% URL = string(), e.g. "planet.trapexit.org/general/rss20.xml".
%%% XmlElement = record(xmlElement), see the xmerl manual.
%%%
%%% Description: Gets XML data from URL and returns the data on
%%%              record form (as specified by xmerl).
%%%-----------------------------------------------------------------
url2rec(URL) ->
    case get_page(URL) of
	{ok,Result} ->
	    %% log("Successful fetch, scanning XML data...~n~n", []),
	    {XmlElem,_} = xmerl_scan:string(extract_xml(URL, Result)),
	    XmlElem;
	Error ->
	    Error
    end.

%%%-----------------------------------------------------------------
%%% file2rec(File) -> XmlElement
%%%
%%% File = string(), e.g. "/tmp/xmldata".
%%% XmlElement = record(xmlElement), see the xmerl manual.
%%%
%%% Description: Reads XML data from file and returns the data on
%%%              record form (as specified by xmerl).
%%%-----------------------------------------------------------------
file2rec(File) ->
    %% log("Scanning XML data in ~s...~n~n", [File]),
    {XmlElem,_} = xmerl_scan:file(File),
    XmlElem.

%%%-----------------------------------------------------------------
%%% get_page(URL) -> {ok,Result} | {error,Reason}
%%%
%%% URL = string(), e.g. "planet.trapexit.org/general/rss20.xml".
%%% Result = string(), the web page at URL.
%%%
%%% Description: Fetches the web page at URL and returns it as a
%%%              string.
%%%-----------------------------------------------------------------
get_page(URL0) ->
    {URL,_Host} =
	case URL0 of
	    [$h,$t,$t,$p,$:,$/,$/|HostPath] ->
		[H|_] = string:tokens(HostPath, "/"),
		{URL0,H};
	    HostPath ->
		[H|_] = string:tokens(HostPath, "/"),
		{"http://"++URL0,H}
	end,
    inets:start(),
    case httpc:set_options([{proxy, {{?PROXY,?PROXYPORT},["localhost"]}},
			    {https_proxy, {{?PROXY,?PROXYPORT},["localhost"]}}]) of
	SOError = {error,SOEReason} ->
	    log("Failed to set http options. Reason: ~p~n", [SOEReason]),
	    SOError;
	ok ->
	    case httpc:request(URL) of
		{ok,{{_Version,_,_ReasonPhrase},_Headers,Body}} ->
		    {ok,Body};
		{error,ReqEReason1} ->
		    log("Http request to ~s failed. Reason: ~p~n", 
			[URL,ReqEReason1]),
		    httpc:set_options([{proxy, {undefined,[]}},
				       {https_proxy, {undefined,[]}}]),
		    case httpc:request(URL) of
			{ok,{{_Version,_,_ReasonPhrase},_Headers,Body}} ->
			    {ok,Body};
			ReqError = {error,ReqEReason2} ->
			    log("Http request to ~s failed. Reason: ~p~n", 
				[URL,ReqEReason2]),
			    ReqError
		    end
	    end
    end.

%%%-----------------------------------------------------------------
%%% HELP FUNCTIONS
	
extract_xml(_URL, XML) ->
    case string:str(XML, "<?xml") of
	0 ->
%	    exit({error,invalid_xml});
%	    log("Warning! No xml tag found in feed: ~s~n", [URL]),
	    XML;
	Start ->
	    string:substr(XML, Start)
    end.
    
write_to_file(File, Data) ->
    OldName = File ++ ".1",
    ReadResult =
	case file:read_file_info(File) of
	    {error,enoent} ->
		ok;
	    {ok,_} ->
		file:delete(OldName),
		file:rename(File, OldName),		% ok | {error,_}
		file:delete(File),
		ok;
	    Error ->
		Error
	end,
    RetVal = if ReadResult /= ok ->
		     ReadResult;
		true ->
		     {ok,Dev} = file:open(File, [write]),
		     WriteResult = file:write(Dev, Data),
		     file:close(Dev),
		     WriteResult
	     end,
    if RetVal /= ok ->
	    log("XML data could not be written to ~s: ~p~n", [File,RetVal]),
	    RetVal;
       true ->
	    RetVal
    end.

log(Str, Args) ->
    Str1 = "-- XML GET -- ~s --~n" ++ Str,
    Args1 = [date_time() | Args],
    io:format(Str1, Args1).

date_time() ->
    {{Y,Mo,D}, {H,M,_S}} = erlang:localtime(),
    Hs = integer_to_list(H),
    Ms = itos(M),
    Ys = integer_to_list(Y),
    Mos = itos(Mo),
    Ds = itos(D),
    Ys ++ "-" ++ Mos ++ "-" ++ Ds ++ " " ++ Hs ++ ":" ++ Ms.
    
itos(I) ->
    Is = integer_to_list(I),
    if I < 10 -> "0" ++ Is;
       true -> Is
    end.
