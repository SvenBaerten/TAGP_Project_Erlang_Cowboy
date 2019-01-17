{application, 'tagp_project_cowboy', [
	{description, ""},
	{vsn, "rolling"},
	{modules, ['connector','disablePump_H','enablePump_H','flowMeterInst','flowMeterTyp','fluidumInst','fluidumTyp','heatExchangeLink','heatExchangerInst','heatExchangerTyp','json_H','location','msg','pipeInst','pipeTyp','pipe_system','project','pumpInst','pumpTyp','resource_instance','resource_type','setInTemp_H','survivor','survivor2','tagp_project_cowboy_app','tagp_project_cowboy_sup','terminalCommand_H','test']},
	{registered, [tagp_project_cowboy_sup]},
	{applications, [kernel,stdlib,cowboy,jiffy]},
	{mod, {tagp_project_cowboy_app, []}},
	{env, []}
]}.