%%%% Taak TAGP 2018-2019: Digital Twin %%%%

% Sven Baerten (1540637) - sven.baerten@student.uhasselt.be
% Faculteit Industriële Ingenieurswetenschappen - Master Elektronica-ICT aan de UHasselt en KU Leuven
% Vak: Toepassingen en algoritmes van geavanceerde programmeertalen [TAGP]
% Docenten: Paul Valckenaers en Kris Aerts

% Gepersonaliseerde opdracht: Digital Twin met Cowboy webserver (Cowboy: https://ninenines.eu/ en https://github.com/ninenines/cowboy)

-module(project).
-export([start/0, init/0, get_pipeSystem_json/0, enable_pump/0, disable_pump/0, set_inTemp/1, parse_terminal_command/1, string_to_number/1]).

start() ->
    PID = spawn(project, init, []),
    register(pipeSystem, PID).

init() ->
    %%% Start survivor for logging in ETS table %%%
    survivor2:start(),

    %%% REAL SYSTEM (RS) %%%
    {ok, RS_PipeTyp_PID} = resource_type:create(pipeTyp, []), 
    {ok, RS_Pipe_0_PID}  = resource_instance:create(pipeInst, [self(), RS_PipeTyp_PID]), 
    {ok, RS_Pipe_1_PID}  = resource_instance:create(pipeInst, [self(), RS_PipeTyp_PID]),
    {ok, RS_Pipe_2_PID}  = resource_instance:create(pipeInst, [self(), RS_PipeTyp_PID]),
    {ok, RS_Pipe_3_PID}  = resource_instance:create(pipeInst, [self(), RS_PipeTyp_PID]),
    {ok, RS_Pipe_4_PID}  = resource_instance:create(pipeInst, [self(), RS_PipeTyp_PID]),

    {ok, [RS_Connector_Pipe_0_In, RS_Connector_Pipe_0_Out]} = resource_instance:list_connectors(RS_Pipe_0_PID),
    {ok, [RS_Connector_Pipe_1_In, RS_Connector_Pipe_1_Out]} = resource_instance:list_connectors(RS_Pipe_1_PID),
    {ok, [RS_Connector_Pipe_2_In, RS_Connector_Pipe_2_Out]} = resource_instance:list_connectors(RS_Pipe_2_PID),
    {ok, [RS_Connector_Pipe_3_In, RS_Connector_Pipe_3_Out]} = resource_instance:list_connectors(RS_Pipe_3_PID),
    {ok, [RS_Connector_Pipe_4_In, RS_Connector_Pipe_4_Out]} = resource_instance:list_connectors(RS_Pipe_4_PID),

    connector:connect(RS_Connector_Pipe_0_Out, RS_Connector_Pipe_1_In),
    connector:connect(RS_Connector_Pipe_1_Out, RS_Connector_Pipe_2_In),
    connector:connect(RS_Connector_Pipe_2_Out, RS_Connector_Pipe_3_In),
    connector:connect(RS_Connector_Pipe_3_Out, RS_Connector_Pipe_4_In),
    connector:connect(RS_Connector_Pipe_4_Out, RS_Connector_Pipe_0_In),

    {ok, RS_PumpTyp_PID} = resource_type:create(pumpTyp, []),
    {ok, RS_Pump_PID}    = resource_instance:create(pumpInst, [self(), RS_PumpTyp_PID, RS_Pipe_0_PID, fun(_Command) -> none end]),

    {ok, RS_FluidumTyp_PID} = resource_type:create(fluidumTyp, []),
    {ok, RS_Fluidum_PID}    = resource_instance:create(fluidumInst, [RS_Connector_Pipe_0_In, RS_FluidumTyp_PID]),

    {ok, RS_FlowMeterTyp_PID}    = resource_type:create(flowMeterTyp, []),
    {ok, [RS_Location_Pipe_1|_]} = resource_instance:list_locations(RS_Pipe_1_PID),
    location:arrival(RS_Location_Pipe_1, RS_Fluidum_PID),
    {ok, RS_FlowMeter_PID} = resource_instance:create(flowMeterInst, [self(), RS_FlowMeterTyp_PID, RS_Pipe_1_PID, fun() -> none end]),

    {ok, RS_HeatExchangerTyp_PID} = resource_type:create(heatExchangerTyp, []),
    RS_Difference = 15,
    RS_HE_link_spec = #{delta => RS_Difference},
    {ok, RS_HeatExchanger_PID} = resource_instance:create(heatExchangerInst, [self(), RS_HeatExchangerTyp_PID, RS_Pipe_2_PID, RS_HE_link_spec, fun() -> none end]),
    
    RS = #{
        <<"PipeTyp_PID">>           => RS_PipeTyp_PID,
        <<"Pipe_0_PID">>            => RS_Pipe_0_PID,
        <<"Pipe_1_PID">>            => RS_Pipe_1_PID,
        <<"Pipe_2_PID">>            => RS_Pipe_2_PID,
        <<"Pipe_3_PID">>            => RS_Pipe_3_PID,
        <<"Pipe_4_PID">>            => RS_Pipe_4_PID,
        <<"PumpTyp_PID">>           => RS_PumpTyp_PID,
        <<"Pump_PID">>              => RS_Pump_PID,
        <<"FluidumTyp_PID">>        => RS_FluidumTyp_PID,
        <<"Fluidum_PID">>           => RS_Fluidum_PID,
        <<"FlowMeterTyp_PID">>      => RS_FlowMeterTyp_PID,
        <<"FlowMeter_PID">>         => RS_FlowMeter_PID,
        <<"HeatExchangerTyp_PID">>  => RS_HeatExchangerTyp_PID,
        <<"HeatExchanger_PID">>     => RS_HeatExchanger_PID
    },

    %%% DIGITAL TWIN (DT) %%%
    {ok, DT_PipeTyp_PID} = resource_type:create(pipeTyp, []),
    {ok, DT_Pipe_0_PID}  = resource_instance:create(pipeInst, [self(), DT_PipeTyp_PID]),
    {ok, DT_Pipe_1_PID}  = resource_instance:create(pipeInst, [self(), DT_PipeTyp_PID]),
    {ok, DT_Pipe_2_PID}  = resource_instance:create(pipeInst, [self(), DT_PipeTyp_PID]),
    {ok, DT_Pipe_3_PID}  = resource_instance:create(pipeInst, [self(), DT_PipeTyp_PID]),
    {ok, DT_Pipe_4_PID}  = resource_instance:create(pipeInst, [self(), DT_PipeTyp_PID]),

    {ok, [DT_Connector_Pipe_0_In, DT_Connector_Pipe_0_Out]} = resource_instance:list_connectors(DT_Pipe_0_PID),
    {ok, [DT_Connector_Pipe_1_In, DT_Connector_Pipe_1_Out]} = resource_instance:list_connectors(DT_Pipe_1_PID),
    {ok, [DT_Connector_Pipe_2_In, DT_Connector_Pipe_2_Out]} = resource_instance:list_connectors(DT_Pipe_2_PID),
    {ok, [DT_Connector_Pipe_3_In, DT_Connector_Pipe_3_Out]} = resource_instance:list_connectors(DT_Pipe_3_PID),
    {ok, [DT_Connector_Pipe_4_In, DT_Connector_Pipe_4_Out]} = resource_instance:list_connectors(DT_Pipe_4_PID),

    connector:connect(DT_Connector_Pipe_0_Out, DT_Connector_Pipe_1_In),
    connector:connect(DT_Connector_Pipe_1_Out, DT_Connector_Pipe_2_In),
    connector:connect(DT_Connector_Pipe_2_Out, DT_Connector_Pipe_3_In),
    connector:connect(DT_Connector_Pipe_3_Out, DT_Connector_Pipe_4_In),
    connector:connect(DT_Connector_Pipe_4_Out, DT_Connector_Pipe_0_In),

    {ok, DT_PumpTyp_PID} = resource_type:create(pumpTyp, []),
    {ok, DT_Pump_PID}    = resource_instance:create(pumpInst, [self(), DT_PumpTyp_PID, DT_Pipe_0_PID, fun(Command) -> pump_RealWorldCmdFn(RS_Pump_PID, Command) end]),

    {ok, DT_FluidumTyp_PID} = resource_type:create(fluidumTyp, []),
    {ok, DT_Fluidum_PID}    = resource_instance:create(fluidumInst, [DT_Connector_Pipe_0_In, DT_FluidumTyp_PID]),

    {ok, DT_FlowMeterTyp_PID}    = resource_type:create(flowMeterTyp, []),
    {ok, [DT_Location_Pipe_1|_]} = resource_instance:list_locations(DT_Pipe_1_PID),
    location:arrival(DT_Location_Pipe_1, DT_Fluidum_PID),
    {ok, DT_FlowMeter_PID} = resource_instance:create(flowMeterInst, [self(), DT_FlowMeterTyp_PID, DT_Pipe_1_PID, fun() -> flowMeter_RealWorldCmdFn(RS_FlowMeter_PID) end]),

    {ok, DT_HeatExchangerTyp_PID} = resource_type:create(heatExchangerTyp, []),
    DT_Difference = 15,
    DT_HE_link_spec = #{delta => DT_Difference},
    {ok, DT_HeatExchanger_PID} = resource_instance:create(heatExchangerInst, [self(), DT_HeatExchangerTyp_PID, DT_Pipe_2_PID, DT_HE_link_spec, fun() -> heatExchanger_RealWorldCmdFn(RS_HeatExchanger_PID) end]),
    
    DT = #{
        <<"PipeTyp_PID">>           => DT_PipeTyp_PID,
        <<"Pipe_0_PID">>            => DT_Pipe_0_PID,
        <<"Pipe_1_PID">>            => DT_Pipe_1_PID,
        <<"Pipe_2_PID">>            => DT_Pipe_2_PID,
        <<"Pipe_3_PID">>            => DT_Pipe_3_PID,
        <<"Pipe_4_PID">>            => DT_Pipe_4_PID,
        <<"PumpTyp_PID">>           => DT_PumpTyp_PID,
        <<"Pump_PID">>              => DT_Pump_PID,
        <<"FluidumTyp_PID">>        => DT_FluidumTyp_PID,
        <<"Fluidum_PID">>           => DT_Fluidum_PID,
        <<"FlowMeterTyp_PID">>      => DT_FlowMeterTyp_PID,
        <<"FlowMeter_PID">>         => DT_FlowMeter_PID,
        <<"HeatExchangerTyp_PID">>  => DT_HeatExchangerTyp_PID,
        <<"HeatExchanger_PID">>     => DT_HeatExchanger_PID
    },

    loop(RS, DT, #{inTemp => 25.0, flowMeter_flowMargin => 2, heatExchanger_tempMargin => 2}, #{pump=>false, flowMeter=>false, heatExchanger=>false}, #{}).

%%% Pipe system state %%%

loop(Real_System, Digital_Twin, Parameters, Mismatch, Test) -> 
    % Real System: map with real devices
    % Digital Twin: map with digital twins of real devices
    % Parameters: map with device parameters e.g. inTemperature of heat exchanger, margin for maximum difference between real and digital flow meter flow ...
    % Mismatch: map indicating potential mismatches between digital twin and real system devices
    % Test: map with parameters to simulate the real devices e.g. permanently disable real pump, water leak causing less flow ... and other general parameters e.g. flow measurement logging
    receive
        {get_real_system, PID} -> PID ! Real_System, loop(Real_System, Digital_Twin, Parameters, Mismatch, Test);
        {get_digital_twin, PID} -> PID ! Digital_Twin, loop(Real_System, Digital_Twin, Parameters, Mismatch, Test);
        {get_parameters, PID} -> PID ! Parameters, loop(Real_System, Digital_Twin, Parameters, Mismatch, Test);
        {update_parameters, Updated_Parameters} -> loop(Real_System, Digital_Twin, Updated_Parameters, Mismatch, Test);
        {get_mismatch, PID} -> PID ! Mismatch, loop(Real_System, Digital_Twin, Parameters, Mismatch, Test);
        {update_mismatch, Updated_Mismatch} -> loop(Real_System, Digital_Twin, Parameters, Updated_Mismatch, Test);
        {get_test, PID} -> PID ! Test, loop(Real_System, Digital_Twin, Parameters, Mismatch, Test);
        {update_test, Updated_Test} -> loop(Real_System, Digital_Twin, Parameters, Mismatch, Updated_Test);
        _any -> ok, loop(Real_System, Digital_Twin, Parameters, Mismatch, Test)
    end.

get_digital_twin() ->
    pipeSystem ! {get_digital_twin, self()},
    receive 
        Digital_Twin -> Digital_Twin
    end, Digital_Twin.

get_real_system() ->
    pipeSystem ! {get_real_system, self()},
    receive 
        Real_System -> Real_System
    end, Real_System.

get_parameters() ->
    pipeSystem ! {get_parameters, self()},
    receive 
        Parameters -> Parameters
    end, Parameters.

update_parameters(Updated_Parameters) -> pipeSystem ! {update_parameters, Updated_Parameters}.

get_mismatch() ->
    pipeSystem ! {get_mismatch, self()},
    receive 
        Mismatch -> Mismatch
    end, Mismatch.

update_mismatch(Updated_Mismatch) -> pipeSystem ! {update_mismatch, Updated_Mismatch}.

get_test() ->
    pipeSystem ! {get_test, self()},
    receive 
        Test -> Test
    end, Test.

update_test(Updated_Test) -> pipeSystem ! {update_test, Updated_Test}.


%%% Real world command functions %%%

pump_RealWorldCmdFn(Real_Pump_PID, Command) ->
    IsPumpFailure = maps:is_key(pumpFailure, get_test()),
    if
        IsPumpFailure == true ->
            pumpInst:switch_off(Real_Pump_PID);
        true ->
            if 
                Command == on ->
                    pumpInst:switch_on(Real_Pump_PID);
                Command == off ->
                    pumpInst:switch_off(Real_Pump_PID)
            end
    end.

flowMeter_RealWorldCmdFn(Real_FlowMeter_PID) ->
    {ok, Flow} = flowMeterInst:estimate_flow(Real_FlowMeter_PID),
    IsWaterLeak = maps:is_key(flowMeterWaterLeak, get_test()),
    if 
        IsWaterLeak == true ->
            Flow - (rand:uniform(15)/100)*Flow;
        true ->
            Flow
    end.

heatExchanger_RealWorldCmdFn(Real_HeatExchanger_PID) ->
    {ok, {ok, Fn}} = heatExchangerInst:get_temp_influence(Real_HeatExchanger_PID),
    IsFouling = maps:is_key(heatExchangerFouling, get_test()),
    if
        IsFouling =:= true ->
            fun(Flow,InTemp) -> {ok, Temp} = Fn(Flow,InTemp), {ok, Temp * 0.7} end;
        true ->
            Fn
    end.


%%% Functions to convert the real system and the digital twin to JSON %%%

pid_to_binary(PID) -> 
     list_to_binary(pid_to_list(PID)). % PID to binary string

get_pipeSystem_json() ->
    {RS, DT} = list_system(), jiffy:encode({[{<<"Real System">>, RS}, {<<"Digital Twin">>, DT}, {<<"Mismatch">>, get_mismatch()}]}). % Jiffy is a JSON library for Erlang, see https://github.com/davisp/jiffy

list_system() ->
    Digital_Twin = get_digital_twin(),
    #{<<"PipeTyp_PID">> := DT_PipeTyp_PID} = Digital_Twin,
    #{<<"Pipe_0_PID">> := _DT_Pipe_0_PID} = Digital_Twin,
    #{<<"Pipe_1_PID">> := _DT_Pipe_1_PID} = Digital_Twin,
    #{<<"Pipe_2_PID">> := _DT_Pipe_2_PID} = Digital_Twin,
    #{<<"Pipe_3_PID">> := DT_Pipe_3_PID} = Digital_Twin,
    #{<<"Pipe_4_PID">> := DT_Pipe_4_PID} = Digital_Twin,
    #{<<"PumpTyp_PID">> := DT_PumpTyp_PID} = Digital_Twin,
    #{<<"Pump_PID">> := DT_Pump_PID} = Digital_Twin,
    #{<<"FluidumTyp_PID">> := _DT_FluidumTyp_PID} = Digital_Twin,
    #{<<"Fluidum_PID">> := _DT_Fluidum_PID} = Digital_Twin,
    #{<<"FlowMeterTyp_PID">> := DT_FlowMeterTyp_PID} = Digital_Twin,
    #{<<"FlowMeter_PID">> := DT_FlowMeter_PID} = Digital_Twin,
    #{<<"HeatExchangerTyp_PID">> := DT_HeatExchangerTyp_PID} = Digital_Twin,
    #{<<"HeatExchanger_PID">> := DT_HeatExchanger_PID} = Digital_Twin,
    
    DT_Pump_Status = get_digitalPump_status(),
    DT_Flow = get_digitalFlowMeter_flow(),
    DT_InTemp = get_inTemp(),
    DT_OutTemp = get_digitalHeatExchanger_temp_influence(),

    DT =
    [{[   
        {<<"ID">>,                  0},   
        {<<"resource_type">>,       <<"PUMP">>},      
        {<<"resource_type_PID">>,   pid_to_binary(DT_PumpTyp_PID)}, 
        {<<"resource_PID">>,        pid_to_binary(DT_Pump_PID)},
        {<<"status">>,              DT_Pump_Status}
    ]},
    {[ 
        {<<"ID">>,                  1}, 
        {<<"resource_type">>,       <<"FLOW METER">>},      
        {<<"resource_type_PID">>,   pid_to_binary(DT_FlowMeterTyp_PID)}, 
        {<<"resource_PID">>,        pid_to_binary(DT_FlowMeter_PID)},
        {<<"flow">>,                DT_Flow}
    ]},
    {[ 
        {<<"ID">>,                  2}, 
        {<<"resource_type">>,       <<"HEAT EXCHANGER">>},      
        {<<"resource_type_PID">>,   pid_to_binary(DT_HeatExchangerTyp_PID)}, 
        {<<"resource_PID">>,        pid_to_binary(DT_HeatExchanger_PID)},
        {<<"ingoing_temperature">>, DT_InTemp},
        {<<"outgoing_temperature">>, DT_OutTemp}
    ]},
    {[ 
        {<<"ID">>,                  3}, 
        {<<"resource_type">>,       <<"PIPE">>},      
        {<<"resource_type_PID">>,   pid_to_binary(DT_PipeTyp_PID)}, 
        {<<"resource_PID">>,        pid_to_binary(DT_Pipe_3_PID)}
    ]},
    {[ 
        {<<"ID">>,                  4}, 
        {<<"resource_type">>,       <<"PIPE">>},      
        {<<"resource_type_PID">>,   pid_to_binary(DT_PipeTyp_PID)}, 
        {<<"resource_PID">>,        pid_to_binary(DT_Pipe_4_PID)}
    ]}],

    Real_System = get_real_system(),
    #{<<"PipeTyp_PID">> := RS_PipeTyp_PID} = Real_System,
    #{<<"Pipe_0_PID">> := _RS_Pipe_0_PID} = Real_System,
    #{<<"Pipe_1_PID">> := _RS_Pipe_1_PID} = Real_System,
    #{<<"Pipe_2_PID">> := _RS_Pipe_2_PID} = Real_System,
    #{<<"Pipe_3_PID">> := RS_Pipe_3_PID} = Real_System,
    #{<<"Pipe_4_PID">> := RS_Pipe_4_PID} = Real_System,
    #{<<"PumpTyp_PID">> := RS_PumpTyp_PID} = Real_System,
    #{<<"Pump_PID">> := RS_Pump_PID} = Real_System,
    #{<<"FluidumTyp_PID">> := _RS_FluidumTyp_PID} = Real_System,
    #{<<"Fluidum_PID">> := _RS_Fluidum_PID} = Real_System,
    #{<<"FlowMeterTyp_PID">> := RS_FlowMeterTyp_PID} = Real_System,
    #{<<"FlowMeter_PID">> := RS_FlowMeter_PID} = Real_System,
    #{<<"HeatExchangerTyp_PID">> := RS_HeatExchangerTyp_PID} = Real_System,
    #{<<"HeatExchanger_PID">> := RS_HeatExchanger_PID} = Real_System,
    
    RS_Pump_Status = get_realPump_status(),
    RS_Flow = measure_flow(),
    RS_InTemp = get_inTemp(),
    RS_OutTemp = measure_temp_influence(),

    RS = 
    [{[   
        {<<"ID">>,                  0},   
        {<<"resource_type">>,       <<"PUMP">>},      
        {<<"resource_type_PID">>,   pid_to_binary(RS_PumpTyp_PID)}, 
        {<<"resource_PID">>,        pid_to_binary(RS_Pump_PID)},
        {<<"status">>,              RS_Pump_Status}
    ]},
    {[ 
        {<<"ID">>,                  1}, 
        {<<"resource_type">>,       <<"FLOW METER">>},      
        {<<"resource_type_PID">>,   pid_to_binary(RS_FlowMeterTyp_PID)}, 
        {<<"resource_PID">>,        pid_to_binary(RS_FlowMeter_PID)},
        {<<"flow">>,                RS_Flow}
    ]},
    {[ 
        {<<"ID">>,                  2}, 
        {<<"resource_type">>,       <<"HEAT EXCHANGER">>},      
        {<<"resource_type_PID">>,   pid_to_binary(RS_HeatExchangerTyp_PID)}, 
        {<<"resource_PID">>,        pid_to_binary(RS_HeatExchanger_PID)},
        {<<"ingoing_temperature">>, RS_InTemp},
        {<<"outgoing_temperature">>, RS_OutTemp}
    ]},
    {[ 
        {<<"ID">>,                  3}, 
        {<<"resource_type">>,       <<"PIPE">>},      
        {<<"resource_type_PID">>,   pid_to_binary(RS_PipeTyp_PID)}, 
        {<<"resource_PID">>,        pid_to_binary(RS_Pipe_3_PID)}
    ]},
    {[ 
        {<<"ID">>,                  4}, 
        {<<"resource_type">>,       <<"PIPE">>},      
        {<<"resource_type_PID">>,   pid_to_binary(RS_PipeTyp_PID)}, 
        {<<"resource_PID">>,        pid_to_binary(RS_Pipe_4_PID)}
    ]}],
    
    % check and update mismatches between the digital twin and real devices
    Pump_Mismatch = is_pump_mismatch(RS_Pump_Status, DT_Pump_Status),
    FlowMeter_Mismatch = is_flowMeter_mismatch(RS_Flow, DT_Flow),
    HeatExchanger_Mismatch = is_heatExchanger_mismatch(RS_OutTemp, DT_OutTemp),
    check_mismatch(Pump_Mismatch, FlowMeter_Mismatch, HeatExchanger_Mismatch),
    
    % store flow measurements
    flow_measurement_csv(RS_Flow, DT_Flow),

    {RS, DT}.


%%% API functions to control the application %%%

% Pump
enable_pump() -> pumpInst:switch_on(get_digitalPump()).
disable_pump() -> pumpInst:switch_off(get_digitalPump()).
get_realPump() -> #{<<"Pump_PID">> := Pump_PID} = get_real_system(), Pump_PID.
get_digitalPump() -> #{<<"Pump_PID">> := Pump_PID} = get_digital_twin(), Pump_PID.
get_realPump_status() -> {ok, RealPump_status} = pumpInst:is_on(get_realPump()), RealPump_status.
get_digitalPump_status() -> {ok, DigitalPump_status} = pumpInst:is_on(get_digitalPump()), DigitalPump_status.
is_pump_mismatch(RealPump_status, DigitalPump_status) -> RealPump_status /= DigitalPump_status.
    
% Flow meter
measure_flow() -> {ok, Flow} = flowMeterInst:measure_flow(get_digitalFlowMeter()), Flow.
get_realFlowMeter() -> #{<<"FlowMeter_PID">> := FlowMeter_PID} = get_real_system(), FlowMeter_PID.
get_digitalFlowMeter() -> #{<<"FlowMeter_PID">> := FlowMeter_PID} = get_digital_twin(), FlowMeter_PID.
get_digitalFlowMeter_flow() -> {ok, Digital_Flow} = flowMeterInst:estimate_flow(get_digitalFlowMeter()), Digital_Flow.
is_flowMeter_mismatch(RealFlowMeter_flow, DigitalFlowMeter_flow) ->
    #{flowMeter_flowMargin := Margin} = get_parameters(), 
    if 
        RealFlowMeter_flow < 0 andalso DigitalFlowMeter_flow < 0 -> false;
        true -> abs(RealFlowMeter_flow - DigitalFlowMeter_flow) > Margin
    end.

% Heat exchanger
measure_temp_influence() ->
    {ok, Fn} = heatExchangerInst:measure_temp_influence(get_digitalHeatExchanger()),
    {ok, OutTemp} = Fn(measure_flow(), get_inTemp()), OutTemp.
get_realHeatExchanger() -> #{<<"HeatExchanger_PID">> := HeatExchanger_PID} = get_real_system(), HeatExchanger_PID.
get_digitalHeatExchanger() -> #{<<"HeatExchanger_PID">> := HeatExchanger_PID} = get_digital_twin(), HeatExchanger_PID.
get_digitalHeatExchanger_temp_influence() ->
    {ok, {ok,Fn}} = heatExchangerInst:get_temp_influence(get_digitalHeatExchanger()),
    {ok, OutTemp} = Fn(get_digitalFlowMeter_flow(),get_inTemp()), OutTemp.
is_heatExchanger_mismatch(RealHeatExchanger_temp_influence, DigitalHeatExchanger_temp_influence) -> 
    #{heatExchanger_tempMargin := Margin} = get_parameters(),
    if 
        RealHeatExchanger_temp_influence < 0 andalso DigitalHeatExchanger_temp_influence < 0 -> false;
        true -> abs(RealHeatExchanger_temp_influence - DigitalHeatExchanger_temp_influence) > Margin
    end.
get_inTemp() -> #{inTemp := InTemp} = get_parameters(), InTemp.
set_inTemp(InTemp) -> update_parameters(maps:put(inTemp, InTemp, get_parameters())).

% Mismatch between real and digital twin devices
check_mismatch(Pump_Mismatch, FlowMeter_Mismatch, HeatExchanger_Mismatch) -> 
    Updated_Mismatch = maps:put(pump, Pump_Mismatch, maps:put(flowMeter, FlowMeter_Mismatch, maps:put(heatExchanger, HeatExchanger_Mismatch, #{}))),
    update_mismatch(Updated_Mismatch).

% Parse the commands from the terminal on the website
parse_terminal_command(Command) ->
    Command_List = <<"commands\nprint ets table\npump on\npump off\npump status\nsetInTemp <temp>\npump failure on\npump failure off\nwater leak on\nwater leak off\nauto temperature on\nauto temperature off\nflow measurement logging on\nflow measurement logging off\nfouling on\nfouling off">>,
    Command_Split = string:lexemes(Command, " "),
    Command_Opcode = lists:nth(1, Command_Split),
    if
        Command == <<"commands">> -> Response = Command_List;
        Command == <<"print ets table">> -> Ets = ets:match_object(logboek, {'$0', '$1'}), Response = lists:foldl(fun(X, String) -> String ++ "\n" ++ lists:flatten(io_lib:format("~p", [X])) ++ "\n" end, "", Ets);  
        Command == <<"pump on">> -> enable_pump(), Response = Command;
        Command == <<"pump off">> -> disable_pump(), Response = Command;
        Command == <<"pump status">> -> Response = erlang:iolist_to_binary([<<"Real pump: ">>, erlang:atom_to_binary(get_realPump_status(), latin1), <<"  Digital pump: ">>, erlang:atom_to_binary(get_digitalPump_status(), latin1)]);
        Command_Opcode == <<"setInTemp">> -> 
            Temp = string_to_number(lists:nth(2,Command_Split)),
            if
                Temp == error -> Response = <<"error">>;
                true -> set_inTemp(Temp), Response = Command
            end;
        Command == <<"pump failure on">> ->  update_test(maps:put(pumpFailure, 0, get_test())), Response = Command;
        Command == <<"pump failure off">> ->  update_test(maps:remove(pumpFailure, get_test())), Response = Command;  
        Command == <<"water leak on">> -> update_test(maps:put(flowMeterWaterLeak, 0, get_test())), Response = Command;
        Command == <<"water leak off">> ->  update_test(maps:remove(flowMeterWaterLeak, get_test())), Response = Command; 
        Command == <<"auto temperature on">> -> Response = Command;
        Command == <<"auto temperature off">> -> Response = Command;
        Command == <<"flow measurement logging on">> ->  update_test(maps:put(flowLogging, 0, get_test())), Response = Command;
        Command == <<"flow measurement logging off">> ->  update_test(maps:remove(flowLogging, get_test())), Response = Command;
        Command == <<"fouling on">> -> update_test(maps:put(heatExchangerFouling, 0, get_test())), Response = Command; 
        Command == <<"fouling off">> ->  update_test(maps:remove(heatExchangerFouling, get_test())), Response = Command;
        true -> Response = <<"Undefined command">>
    end, Response.

% Convert a string to float/integer
string_to_number(String) -> 
    {Float, Info_Float} = string:to_float(String),
    {Integer, Info_Integer} = string:to_integer(String),
    if
        Info_Float =/= no_float andalso Info_Float =:= <<>> -> Float;
        Info_Integer =/= no_integer andalso Info_Integer =:= <<>> -> Integer;
        true -> error
    end.        

% Store real and digital flow meter measurements in a text file (csv format)
flow_measurement_csv(Digital_Flow, Real_Flow) -> % Store the digital and real flow of the flow meter in a .txt file using a csv format
    IsLogging = maps:is_key(flowLogging, get_test()),
    if
        IsLogging == true ->
            {ok, CurrentDir} = file:get_cwd(),
            ParentDir = lists:nth(1, string:split(string:split(CurrentDir, "/", trailing), "/", trailing)),
            Filename = ParentDir ++ "/priv/measurement_logging/Flow_Measurements.txt",
            {Status, _Info} = file:read_file_info(Filename),
            if 
                Status == error -> % File does not exist => write header
                    file:write_file(Filename, "\"" ++ "Time" ++ "\"" ++ "," ++ "\"" ++ "Digital_FlowMeter" ++ "\"" ++ "," ++ "\"" ++ "Real_FlowMeter" ++ "\"" ++ "\r\n", [append]);
                true ->
                    ok
            end,
            {{Year, Month, Day}, {Hour, Minute, Second}} = erlang:localtime(),
            Date = integer_to_list(Year) ++ "-" ++ io_lib:format("~2..0B", [Month]) ++ "-" ++ io_lib:format("~2..0B", [Day]) ++ " " ++ io_lib:format("~2..0B", [Hour]) ++ ":" ++ io_lib:format("~2..0B", [Minute]) ++ ":" ++ io_lib:format("~2..0B", [Second]),
            file:write_file(Filename, "\"" ++ Date ++ "\"" ++ "," ++ "\"" ++ io_lib:format("~.4f",[Digital_Flow]) ++ "\"" ++ "," ++ "\"" ++ io_lib:format("~.4f",[Real_Flow]) ++ "\"" ++ "\r\n", [append]);
        true ->
            ok
    end.