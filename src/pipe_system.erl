-module(pipe_system).
% -export([init/0]).

% init() ->
%     %%% Building the pipe network %%%

%     survivor:start(),
%     %% Create resource type: pipeType
%     {ok, PipeType_PID} = pipeTyp:create(),
%     %% Create resource instances
%     {ok, PipeInstance_0_PID} = pipeInst:create(self(), PipeType_PID),
%     {ok, PipeInstance_1_PID} = pipeInst:create(self(), PipeType_PID),
%     {ok, PipeInstance_2_PID} = pipeInst:create(self(), PipeType_PID),
%     {ok, PipeInstance_3_PID} = pipeInst:create(self(), PipeType_PID),
%     %% Create resource instance connectors
%     {ok, [Connector_PipeInstance_0_PID_In, Connector_0_PipeInstance_PID_Out]} = resource_instance:list_connectors(PipeInstance_0_PID),
%     {ok, [Connector_PipeInstance_1_PID_In, Connector_1_PipeInstance_PID_Out]} = resource_instance:list_connectors(PipeInstance_1_PID),
%     {ok, [Connector_PipeInstance_2_PID_In, Connector_2_PipeInstance_PID_Out]} = resource_instance:list_connectors(PipeInstance_2_PID),
%     {ok, [Connector_PipeInstance_3_PID_In, Connector_3_PipeInstance_PID_Out]} = resource_instance:list_connectors(PipeInstance_3_PID),
%     %% Connect the connectors
%     connector:connect(Connector_0_PipeInstance_PID_Out, Connector_PipeInstance_1_PID_In),
%     connector:connect(Connector_1_PipeInstance_PID_Out, Connector_PipeInstance_2_PID_In),
%     connector:connect(Connector_2_PipeInstance_PID_Out, Connector_PipeInstance_3_PID_In),
%     connector:connect(Connector_3_PipeInstance_PID_Out, Connector_PipeInstance_0_PID_In),
%     %% Fluidum
%     {ok, FLuidumType_PID} = fluidumTyp:create(), 
%     {ok, FluidumInstance_PID} = fluidumInst:create(Connector_PipeInstance_0_PID_In, FLuidumType_PID), 
    
%     %% Resource names
%     Resource_Type_Names =  #{pid_or_atom_to_string(PipeType_PID) => <<"SIMPLE PIPE">>},

%     %% Discover circuit
%     {ok, {Root_Pid, Circuit}} = fluidumTyp:discover_circuit(Connector_PipeInstance_0_PID_In),
%     io:fwrite("CIRCUIT = ~p~n", [Circuit]),

%     %% To JSON
%     JSON = jiffy:encode(iterate_circuit(Circuit, Resource_Type_Names)),

%     %% Map containing JSON and names
%     #{"pipe_system_json" => JSON, "resource_type_names" => Resource_Type_Names}.

% pid_or_atom_to_string(Value) ->
%     if 
%         is_atom(Value) -> atom_to_binary(Value, latin1);
%         is_pid(Value) -> list_to_binary(pid_to_list(Value));
%         true -> <<"null">>
%     end.

% iterate_circuit(Circuit, Resource_Type_Names) ->
%     iterate_circuit(maps:iterator(Circuit), Resource_Type_Names,[]).
% iterate_circuit(none, _Resource_Type_Names, JSON) -> % If none => iterator is done
%     sets:to_list(sets:from_list(JSON)); % List to set to list in order to remove duplicates (because of 2 connectors per resource)
% iterate_circuit({Key, _Value, Iter}, Resource_Type_Names, JSON) ->
%     JSON_New = add_resource(Key, JSON, Resource_Type_Names),
%     iterate_circuit(maps:next(Iter), Resource_Type_Names, JSON_New);
% iterate_circuit(Iter, Resource_Type_Names, JSON) -> % Handler first unusable iter result: [0|#{...}]
%     iterate_circuit(maps:next(Iter), Resource_Type_Names, JSON).

% add_resource(Connector, JSON, Resource_Type_Names) ->    
%     {ok, Resource_instance_PID} = connector:get_ResInst(Connector),
%     {ok, Resource_type_PID} = resource_instance:get_type(Resource_instance_PID),
%     {ok, [Connector_PipeInstance_PID_In, Connector_PipeInstance_PID_Out]} = resource_instance:list_connectors(Resource_instance_PID),    
%     {ok, Connector_NextInstance_PID} = connector:get_connected(Connector_PipeInstance_PID_Out),
%     {ok, [Resource_location_PID]} = resource_instance:list_locations(Resource_instance_PID),
%     {ok, {PipeInstance_location_type}} = location:get_Type(Resource_location_PID),    
%     {ok, PipeInstance_location_visitor_PID} = location:get_Visitor(Resource_location_PID),

%     JSON_resource = 
%     {[      
%         {<<"resource_type_PID">>,     pid_or_atom_to_string(Resource_type_PID)},
%         {<<"type">>,                  maps:get(pid_or_atom_to_string(Resource_type_PID),Resource_Type_Names)}, 
%         {<<"PID">>,                   pid_or_atom_to_string(Resource_instance_PID)},
%         {<<"connections">>,           [pid_or_atom_to_string(Connector_PipeInstance_PID_In), pid_or_atom_to_string(Connector_PipeInstance_PID_Out)]}, 
%         {<<"location_PID">>,          pid_or_atom_to_string(Resource_location_PID)}, 
%         {<<"location_type">>,         pid_or_atom_to_string(PipeInstance_location_type)}, 
%         {<<"location_visitor_PID">>,  pid_or_atom_to_string(PipeInstance_location_visitor_PID)}
%     ]},
%     JSON_connector = 
%     {[      
%         {<<"type">>,            <<"CONNECTOR">>},        
%         {<<"connections">>,     [pid_or_atom_to_string(Connector_PipeInstance_PID_Out), pid_or_atom_to_string(Connector_NextInstance_PID)]} 
%     ]},

%     JSON_New = [JSON_connector|[JSON_resource|JSON]],
%     JSON_New.


















%% Get the locations
    % {ok, [PipeInstance_0_location_PID]} = resource_instance:list_locations(PipeInstance_0_PID),
    % {ok, [PipeInstance_1_location_PID]} = resource_instance:list_locations(PipeInstance_1_PID),
    % {ok, [PipeInstance_2_location_PID]} = resource_instance:list_locations(PipeInstance_2_PID),
    % {ok, [PipeInstance_3_location_PID]} = resource_instance:list_locations(PipeInstance_3_PID),

    % {ok, {PipeInstance_0_location_type}} = location:get_Type(PipeInstance_0_location_PID),
    % {ok, {PipeInstance_1_location_type}} = location:get_Type(PipeInstance_1_location_PID),
    % {ok, {PipeInstance_2_location_type}} = location:get_Type(PipeInstance_2_location_PID),
    % {ok, {PipeInstance_3_location_type}} = location:get_Type(PipeInstance_3_location_PID),

    % {ok, PipeInstance_0_location_visitor_PID} = location:get_Visitor(PipeInstance_0_location_PID),
    % {ok, PipeInstance_1_location_visitor_PID} = location:get_Visitor(PipeInstance_1_location_PID),
    % {ok, PipeInstance_2_location_visitor_PID} = location:get_Visitor(PipeInstance_2_location_PID),
    % {ok, PipeInstance_3_location_visitor_PID} = location:get_Visitor(PipeInstance_3_location_PID),


    % List =    
    % [
    %     {[   
    %         {<<"ID">>,                    <<"0">>},        
    %         {<<"resource_type_PID">>,     pid_to_string(PipeType_PID)}, 
    %         {<<"type">>,                  <<"SIMPLE PIPE">>}, 
    %         {<<"PID">>,                   pid_to_string(PipeInstance_0_PID)},
    %         {<<"connections">>,           [pid_to_string(Connector_PipeInstance_0_PID_In), pid_to_string(Connector_0_PipeInstance_PID_Out)]}, 
    %         {<<"location_PID">>,          pid_to_string(PipeInstance_0_location_PID)}, 
    %         {<<"location_type">>,         atom_to_string(PipeInstance_0_location_type)}, 
    %         {<<"location_visitor_PID">>,  pid_or_atom_to_string(PipeInstance_0_location_visitor_PID)}
    %     ]}
    % ,
    %     {[ 
    %         {<<"ID">>,              <<"1">>}, 
    %         {<<"type">>,            <<"CONNECTOR">>},        
    %         {<<"connections">>,     [pid_to_string(Connector_0_PipeInstance_PID_Out), pid_to_string(Connector_PipeInstance_1_PID_In)]} 
    %     ]}
    % ,
    %     {[   
    %         {<<"ID">>,                    <<"2">>},        
    %         {<<"resource_type_PID">>,     pid_to_string(PipeType_PID)}, 
    %         {<<"type">>,                  <<"SIMPLE PIPE">>}, 
    %         {<<"PID">>,                   pid_to_string(PipeInstance_1_PID)},
    %         {<<"connections">>,           [pid_to_string(Connector_PipeInstance_1_PID_In), pid_to_string(Connector_1_PipeInstance_PID_Out)]}, 
    %         {<<"location_PID">>,          pid_to_string(PipeInstance_1_location_PID)}, 
    %         {<<"location_type">>,         atom_to_string(PipeInstance_1_location_type)}, 
    %         {<<"location_visitor_PID">>,  pid_or_atom_to_string(PipeInstance_1_location_visitor_PID)}
    %     ]}
    % ,
    %     {[ 
    %         {<<"ID">>,              <<"3">>}, 
    %         {<<"type">>,            <<"CONNECTOR">>},        
    %         {<<"connections">>,     [pid_to_string(Connector_1_PipeInstance_PID_Out), pid_to_string(Connector_PipeInstance_2_PID_In)]} 
    %     ]}
    % ,
    %     {[   
    %         {<<"ID">>,                    <<"4">>},        
    %         {<<"resource_type_PID">>,     pid_to_string(PipeType_PID)}, 
    %         {<<"type">>,                  <<"SIMPLE PIPE">>}, 
    %         {<<"PID">>,                   pid_to_string(PipeInstance_2_PID)},
    %         {<<"connections">>,           [pid_to_string(Connector_PipeInstance_2_PID_In), pid_to_string(Connector_2_PipeInstance_PID_Out)]}, 
    %         {<<"location_PID">>,          pid_to_string(PipeInstance_2_location_PID)}, 
    %         {<<"location_type">>,         atom_to_string(PipeInstance_2_location_type)}, 
    %         {<<"location_visitor_PID">>,  pid_or_atom_to_string(PipeInstance_2_location_visitor_PID)}
    %     ]}
    % ,
    %     {[ 
    %         {<<"ID">>,              <<"5">>}, 
    %         {<<"type">>,            <<"CONNECTOR">>},        
    %         {<<"connections">>,     [pid_to_string(Connector_2_PipeInstance_PID_Out), pid_to_string(Connector_PipeInstance_3_PID_In)]} 
    %     ]}
    % ,
    %     {[   
    %         {<<"ID">>,                    <<"6">>},        
    %         {<<"resource_type_PID">>,     pid_to_string(PipeType_PID)}, 
    %         {<<"type">>,                  <<"SIMPLE PIPE">>}, 
    %         {<<"PID">>,                   pid_to_string(PipeInstance_3_PID)},
    %         {<<"connections">>,           [pid_to_string(Connector_PipeInstance_3_PID_In), pid_to_string(Connector_3_PipeInstance_PID_Out)]}, 
    %         {<<"location_PID">>,          pid_to_string(PipeInstance_3_location_PID)}, 
    %         {<<"location_type">>,         atom_to_string(PipeInstance_3_location_type)}, 
    %         {<<"location_visitor_PID">>,  pid_or_atom_to_string(PipeInstance_3_location_visitor_PID)}
    %     ]}
    % ,
    %     {[ 
    %         {<<"ID">>,              <<"7">>}, 
    %         {<<"type">>,            <<"CONNECTOR">>},        
    %         {<<"connections">>,     [pid_to_string(Connector_3_PipeInstance_PID_Out), pid_to_string(Connector_PipeInstance_0_PID_In)]} 
    %     ]}
    % ],

    % io:format("~p~n", [List]), 
    % Json = jiffy:encode(List),
    % io:format("Jiffy~p~n~n", [Json]),


























































% % Jiffy vb. Json = jiffy:encode([  {[{foo,bar},{bar,foo}]}, {[{sven,baerten},{dorp,valmeer}]}   ])    ------> ---> JSON = <<"[{\"foo\":\"bar\",\"bar\":\"foo\"},{\"sven\":\"baerten\",\"dorp\":\"valmeer\"}]">>

% returnSystem(StartPid) -> 
%     io:format("StartPid = ~p~n", [StartPid]),
%     {NextPid, List} = addResourceToList(StartPid, []),
%     returnSystem(StartPid, NextPid, List).
    
% returnSystem(StartPid, NextPid, List) -> 
%     if 
%         StartPid =/= NextPid ->
%             {NextPid_t, List_t} = addResourceToList(NextPid, List),
%             returnSystem(StartPid, NextPid_t, List_t);
%         true ->
%             io:format("startPid=~p  nextPid=~p ~n", [StartPid, NextPid]),
%             List
%     end.

% addResourceToList(Pid, List) ->
%     % ResourceType e.g. pipeType
%     {ok, ResourceTypePid} = resource_instance:get_type(Pid),
    
%     % In and out connectors
%     {ok, [Connector_In, Connector_Out]} = resource_instance:list_connectors(Pid),
%     % ConnectorType e.g. simplepipe
%     {ok, ConnectorType} = connector:get_type(Connector_Out),
    
%     % Get in connector of next resource instance e.g. next pipe
%     {ok, Connector_In_NextResource} = connector:get_connected(Connector_Out),
    
%     % Pid of next resource instance e.g. next pipe
%     {ok, NextPid} = connector:get_ResInst(Connector_In_NextResource),

%     % Convert Pid's to string or else JSON conversion fails
%     Pid_s = list_to_binary(pid_to_list(Pid)),
%     ResourceTypePid_s = list_to_binary(pid_to_list(ResourceTypePid)),
%     Connector_In_s = list_to_binary(pid_to_list(Connector_In)),
%     Connector_Out_s = list_to_binary(pid_to_list(Connector_Out)),
%     Connector_In_NextResource_s = list_to_binary(pid_to_list(Connector_In_NextResource)),

%     % Add the resource instance and connector to the list
%     NewList = lists:append(List, [  {[ {<<"type">>,<<"resource">>}, {<<"resourceType">>,ResourceTypePid_s}, {<<"pid">>,Pid_s}, {<<"connectors">>,[Connector_In_s,Connector_Out_s]} ]},
%         {[ {<<"type">>,<<"connector">>}, {<<"connectorType">>,ConnectorType}, {<<"connectors">>,[Connector_Out_s,Connector_In_NextResource_s]} ]}
%     ]),

%     io:format("NextPid = ~p~n", [NextPid]),
%     %io:format("~p~n", [List]),

%     % Return: Pid of next resource and updated List
%     {NextPid, NewList}.



% [  {"type", "pipe"}, {"PID", "PID"}, {"connectors", ["conn_in", "conn_out"]} ]


% Oude werkwijze !
% {ok, [In1, Out1]} = resource_instance:list_connectors(PipeInstPID1),

    % {ok, In2} = connector:get_connected(Out1),
    % {ok, PipeInstPID2} = connector:get_ResInst(In2),
    % {ok, [_, Out2]} = resource_instance:list_connectors(PipeInstPID2),

    % {ok, In3} = connector:get_connected(Out2),
    % {ok, PipeInstPID3} = connector:get_ResInst(In3),
    % {ok, [_, Out3]} = resource_instance:list_connectors(PipeInstPID3),

    % {ok, In1_copy} = connector:get_connected(Out3),

    % {"conn1, inst, conn2 :  ", In1, PipeInstPID1, Out1, " -> ", In2, PipeInstPID2, Out2, " -> ", In3, PipeInstPID3, Out3, " -> ", In1_copy}.