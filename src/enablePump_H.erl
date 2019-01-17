-module(enablePump_H).
-behavior(cowboy_handler).
-export([init/2]).

% Erlang module that handles the /enablePump request

init(Req0, Opts) ->
    project:enable_pump(),
	Req1 = cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>},<<"">>, Req0), 
	{ok,Req1, Opts}.