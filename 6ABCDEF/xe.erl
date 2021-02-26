-module(xe).
-export([print_rates/1, new_record/1, convert/3]).

-include_lib("xmerl/include/xmerl.hrl").
-record(xe_info, {currency, pubDate, rate}).

%% Currency has to be string ""
print_rates(Currency) ->
	File2Rec = "xml_files/" ++ string:to_upper(Currency) ++ ".xml",
	%%io:format("~p~n", [File2Rec]),
	ListOfRecords =  rss_xe:get_xe_info(xmlget:file2rec(File2Rec),predicate:func()),
	lists:foreach(fun([TitleRecord, DescrRecord]) -> 
					[{xmlText, [{_nn1, _nn2},{_nn3, _nn4},{_nn5, _nn6},{_nn7, _nn8}], _SomeNumberT, [], ImportantPartOfTitle, text}] = TitleRecord#xmlElement.content,
					[{xmlText, [{_nn9, _nn10},{_nn11, _nn12},{_nn13, _nn14},{_nn15, _nn16}], _SomeNumberD, [], ImportantPartOfDescr, text}] = DescrRecord#xmlElement.content,
					io:format("~p exchange rate: ~p ~n", [list_to_atom(ImportantPartOfTitle), list_to_atom(ImportantPartOfDescr)]) 
				  end, 
				  ListOfRecords).
				  
new_record(Currency) ->
	File2Rec = "xml_files/" ++ string:to_upper(Currency) ++ ".xml",
	ListOfRecords =  rss_xe:get_xe_info(xmlget:file2rec(File2Rec),
											fun(Elem) -> 
												case Elem#xmlElement.name of 
													title -> true;
													pubDate -> true;
													description -> true;
													_ -> false 
												end
											end),
	lists:map(fun(Elem) -> 
				[TitleRecord, PubDateRecord, DescrRecord] = Elem,
				[{xmlText, [{_nn1, _nn2},{item, _nn3},{channel, _nn4},{rss, _nn5}], _SomeNumberT, [], ImportantPartOfTitle, text}] = TitleRecord#xmlElement.content,
				[{xmlText, [{_nn6, _nn7},{item, _nn8},{channel, _nn9},{rss, _nn10}], _SomeNumberP, [], ImportantPartOfPubDate, text}] = PubDateRecord#xmlElement.content,
				[{xmlText, [{_nn11, _nn12},{item, _nn13},{channel, _nn14},{rss, _nn15}], _SomeNumberD, [], ImportantPartOfDescr, text}] = DescrRecord#xmlElement.content,
				NewRecord = #xe_info{currency = ImportantPartOfTitle, pubDate = ImportantPartOfPubDate, rate = rss_xe:rate_string_to_num(ImportantPartOfDescr)},
				%%io:format("~p~n", [NewRecord]),
				NewRecord
			   end, 
			   ListOfRecords).
   
convert(FromCurr, ToCurr, Amount) ->
	Key = string:to_upper(ToCurr) ++ "/" ++ string:to_upper(FromCurr),
	List = new_record(FromCurr),
	{value,{xe_info, Key,_PubDate,Rate}} = lists:keysearch(Key, 2, List),
	%%io:format("rate: ~p~n key: ~p~n", [Rate, Key]),
	io:format("~p ~p = ~p ~p~n", [Amount, FromCurr, Amount*Rate, ToCurr]).