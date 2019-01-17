-module(heatExchangerInst).
-export([create/5, init/5, get_temp_influence/1, measure_temp_influence/1]).%, get_HE_link_spec/1, update_HE_link_spec/2]).

% HeatExchanger is a pipe and more; this pipe instance is passed to the create function.
% HeatExchangers have a HE_link to, typically, another HeatExchanger. The link provides 
% a function that models the mutual effect on the temperature of the flows on either side. 

create(Host, HeatExchangerTyp_Pid, PipeInst_Pid, HE_link_spec, RealWorldCmdFn) -> {ok, spawn(?MODULE, init, [Host, HeatExchangerTyp_Pid, PipeInst_Pid, HE_link_spec, RealWorldCmdFn])}.

init(Host, HeatExchangerTyp_Pid, PipeInst_Pid, HE_link_spec, RealWorldCmdFn) -> 
	{ok, State} = apply(resource_type, get_initial_state, [HeatExchangerTyp_Pid, self(), [PipeInst_Pid, RealWorldCmdFn]]),
									%  get_initial_state  (ResTyp_Pid,  ResInst_Pid, TypeOptions) 
	survivor:entry({ pumpInst_created, State }),
	loop(Host, State, HeatExchangerTyp_Pid, PipeInst_Pid, HE_link_spec).

get_temp_influence(HeatExchangerInst_Pid) -> 
	msg:get(HeatExchangerInst_Pid, get_temp_influence).

measure_temp_influence(HeatExchangerInst_Pid) -> 
	msg:get(HeatExchangerInst_Pid, measure_temp_influence).

loop(Host, State, HeatExchangerTyp_Pid, PipeInst_Pid, HE_link_spec) -> 
	receive
		{get_type, ReplyFn} -> 
			ReplyFn(HeatExchangerTyp_Pid),
			loop(Host, State, HeatExchangerTyp_Pid, PipeInst_Pid, HE_link_spec);
		{get_temp_influence, ReplyFn} ->
			ReplyFn(heatExchangeLink:get_temp_influence(HE_link_spec)),
			loop(Host, State, HeatExchangerTyp_Pid, PipeInst_Pid, HE_link_spec);
		{measure_temp_influence, ReplyFn} -> 
			#{rw_cmd := ExecFn} = State,
			ReplyFn(ExecFn()),
			loop(Host, State, HeatExchangerTyp_Pid, PipeInst_Pid, HE_link_spec);
		OtherMessage -> 
			PipeInst_Pid ! OtherMessage,
			loop(Host, State, HeatExchangerTyp_Pid, PipeInst_Pid, HE_link_spec)
	end.
