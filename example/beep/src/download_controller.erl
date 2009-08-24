%%
%% Sample default controller
%%
-module(download_controller,[Env]).

-export([handle_request/2]).

-include("rberl.hrl").

handle_request("index",[]) ->
    {render,"download/index.html",[
		 {beepbeep_version, "0.1"}
		,?TXT("stable_versions")
		,?TXT("current_version")
		,?TXT("get_it_here")
		,?TXT("development_version")
		,?TXT("get_development_version")
		,?TXT("fork_dave_byrson")
		,?TXT("fork_dmitrii_dimandt")
		,?TXT("get_development_snapshot")
		,?TXT("then_get_started")
		,{title, ?TXT2("download_instructions")}
								  ]}.
