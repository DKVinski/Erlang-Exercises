%%%-------------------------------------------------------------------
%%% File    : rss_xe.erl
%%% Author  : Peter Andersson
%%%
%%% Description : Help- and example module for exercise 6.
%%%-------------------------------------------------------------------
-module(rss_xe).

-export([get_xe_info/2, rate_string_to_num/1]).

-include_lib("xmerl/include/xmerl.hrl").


%%%-----------------------------------------------------------------
%%% get_xe_info(TopXmlElement, FilterPred) -> Filtered 
%%%
%%% TopXmlElement = record(xmlElement), result from scanning an
%%%                 exchange rate XML specification (see xmerl).
%%% FilterPred = fun(), called for each XmlElement record in each list
%%%              on the deepest level of the nested TopXmlElement 
%%%              structure. The fun must return true for those 
%%%              elements that should be extracted, false otherwise.
%%% Filtered = [ListOfElems | ...], the result of extracting elements
%%%            from the exchange rate item lists (one list per item).
%%% ListOfElems = [Elem | ...].
%%% Elem = record(xmlElement), an element for which FilterPred has 
%%%        returned true.
%%%
%%% Description: The function traverses the content lists of the
%%%              nested xmlElement records and finds one element
%%%              named item for each exchange rate. The content
%%%              list of an item contains info about that particular
%%%              exchange rate. The FilterPred fun is applied to
%%%              the info elements in the content list of each item.
%%%              Hence the return value of this function is a list
%%%              of lists: 
%%%
%%%              [[Match1forItem1,Match2forItem1,...] | 
%%%               [Match1forItem2,Match2forItem2,...] | ...]
%%%
%%%              The elements in the lists are those that FilterPred
%%%              has returned true for. 
%%%-----------------------------------------------------------------
get_xe_info(TopXmlElem, FilterPred) ->
    TopContent = TopXmlElem#xmlElement.content,

    %% find the element named channel
    {value,Channel} = lists:keysearch(channel, #xmlElement.name, TopContent),

    %% extract all elements named item
    IsItem = fun(Elem) when is_record(Elem, xmlElement) ->
		     Elem#xmlElement.name == item;
		(_) ->
		     false
	     end,
    Items = lists:filter(IsItem, Channel#xmlElement.content),

    %% apply the filter predicate fun on each element in the 
    %% content list of each item
    XEInfo = fun(Item) ->
		     lists:filter(FilterPred, Item#xmlElement.content)	    
	     end,
    lists:map(XEInfo, Items).


%%%-----------------------------------------------------------------
%%% rate_string_to_num(Description) -> Num
%%%
%%% Description = string(), e.g. "1 Swedish Krona = 0.08432 Pounds"
%%% Num = number()
%%%
%%% Description: Extracts the exchange rate from a description
%%%              string and converts the rate to a number.
%%%-----------------------------------------------------------------
rate_string_to_num(Str) ->
    Ts = string:tokens(Str, [$ ]),
    [_,RateStr|_] = lists:dropwhile(fun("=") ->
					    false;
				       (_) ->
					    true
				    end, Ts),
    RateStr1 = [N || N <- RateStr, N /= $,],	% remove comma
    case catch list_to_float(RateStr1) of
	{'EXIT',_} ->
	    list_to_integer(RateStr1);
	Num ->
	    Num
    end.
