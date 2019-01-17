-module(terminalCommand_H).
-behavior(cowboy_handler).
-export([init/2]).

% Erlang module that handles the /terminalCommand request

init(Req0, Opts) ->
	{ok, Command, Req1} = cowboy_req:read_body(Req0),
	Response = project:parse_terminal_command(Command),
	Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>},Response, Req1), 
	{ok, Req2, Opts}.