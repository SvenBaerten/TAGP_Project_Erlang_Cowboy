-module(json_H).
-behavior(cowboy_handler).
-export([init/2, pipe_system_json/2]).

% Erlang module that handles the /requestPipeSystem request and sends the pipe system in a json format back to the website

% REST principle
-export([allowed_methods/2]).
-export([content_types_provided/2]).

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
	{[<<"GET">>], Req, State}.

content_types_provided(Req, State) ->
    {[
        {<<"application/json">>, pipe_system_json}
    ], Req, State}.

pipe_system_json(Req, State) ->
    JSON = project:get_pipeSystem_json(),
    {JSON, Req, State}.
