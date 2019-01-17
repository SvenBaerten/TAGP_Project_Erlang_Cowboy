-module(setInTemp_H).
-behavior(cowboy_handler).

-export([init/2]).

init(Req0, Opts) ->
	QsVals = cowboy_req:parse_qs(Req0),
	{_, InTemp_string} = lists:keyfind(<<"temp">>, 1, QsVals),
	InTemp = project:string_to_number(InTemp_string),
	project:set_inTemp(InTemp),
	Req1 = cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>},<<"">>, Req0), 
	{ok,Req1, Opts}.