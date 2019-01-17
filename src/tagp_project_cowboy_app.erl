%%%% Taak TAGP 2018-2019: Digital Twin %%%%

% Sven Baerten (1540637) - sven.baerten@student.uhasselt.be
% Faculteit Industriële Ingenieurswetenschappen - Master Elektronica-ICT aan de UHasselt en KU Leuven
% Vak: Toepassingen en algoritmes van geavanceerde programmeertalen [TAGP]
% Docenten: Paul Valckenaers en Kris Aerts

% Gepersonaliseerde opdracht: Digital Twin met Cowboy webserver (Cowboy: https://ninenines.eu/ en https://github.com/ninenines/cowboy)

-module(tagp_project_cowboy_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->   
    project:start(),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/site/[...]", cowboy_static, {priv_dir, tagp_project_cowboy, "/site"}},
            {"/measurement_logging/[...]", cowboy_static, {priv_dir, tagp_project_cowboy, "/measurement_logging"}},
            {"/requestPipeSystem", json_H, []},
            {"/enablePump", enablePump_H, []},
            {"/disablePump", disablePump_H, []},
            {"/setInTemperature/[...]", setInTemp_H, []},
            {"/terminalCommand", terminalCommand_H, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 8080}], 
        #{env => #{dispatch => Dispatch}}
    ),
    tagp_project_cowboy_sup:start_link().

stop(_State) ->
	ok.