-module(test).

-export([start/0]).

compile() ->
    compile:file(resource_instance),
    compile:file(connector),
    compile:file(flowMeterInst),
    compile:file(flowMeterTyp),
    compile:file(fluidumInst),
    compile:file(fluidumTyp),
    compile:file(heatExchangeLink),
    compile:file(heatExchangerInst),
    compile:file(heatExchangerTyp),
    compile:file(location),
    compile:file(msg),
    compile:file(pipeInst),
    compile:file(pipeTyp),
    compile:file(pumpInst),
    compile:file(pumpTyp),
    compile:file(resource_type),
    compile:file(survivor),
    compile:file(survivor2),
    compile:file(project).

start() ->
    compile(),
    spawn(project, init, []).
