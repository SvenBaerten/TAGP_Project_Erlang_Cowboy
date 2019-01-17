-module(heatExchangerTyp).
-export([create/0, init/0]).


create() -> {ok, spawn(?MODULE, init, [])}.

init() -> 
	survivor:entry(heatExchangerTyp_created),
	loop().

loop() -> 
	receive
		{initial_state, [ResInst_Pid, [PipeInst_Pid, RealWorldCmdFn]], ReplyFn} ->
			ReplyFn(#{resInst => ResInst_Pid, pipeInst => PipeInst_Pid, rw_cmd => RealWorldCmdFn}), 
			loop()
	end. 

 