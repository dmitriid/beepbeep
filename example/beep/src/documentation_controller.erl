-module(documentation_controller,[Env]).

-include("rberl.hrl").

-export([handle_request/2, before_render/1]).


handle_request("index",[]) ->
    {render,"documentation/index.html", [
		 ?TXT("overview")
		,?TXT("overview_description")
		,?TXT("features")
		,?TXT("feature_script")
		,?TXT("feature_session")
		,?TXT("feature_filters")
		,?TXT("feature_dtl")
		,{title, ?TXT2("overview")}
										]};

handle_request("get-started",[]) ->
    {render,"documentation/getting_started.html",[
		 ?TXT("how_it_works")
		,?TXT("download_code")
		,?TXT("cd_to_directory")
		,?TXT("run_make")
		,?TXT("generate_app")
		,?TXT("your_app_name")
		,?TXT("destination_dir")
		,?TXT("this_generates_app")
		,?TXT("to_run_the_sample")
		,?TXT("cd_to_app_dir")
		,?TXT("compile_app")
		,?TXT("start_server")
		,?TXT("visit_sample_site")
		,?TXT("primer_write_controller")
		,?TXT("where")
		,?TXT("primer_what_is_action")
		,?TXT("primer_what_is_params")
		,?TXT("primer_mapping")
		,?TXT("primer_example")
		,?TXT("maps_to")
		,?TXT("callback_filter_hook")
		,?TXT("primer_return_view")
		,?TXT("primer_use_view")
		,?TXT("primer_view_example")
		,?TXT("primer_view_example_result")
		,?TXT("primer_view_explanation")
		,?TXT("primer_separation")
		,?TXT("primer_hooks")
		,{title, ?TXT2("get_started")}
												 ]};


handle_request("innards",[]) ->
	{render,"documentation/innards.html",[
		 ?TXT("workflow_intro")
		,?TXT("things_are_not_scary")
		,?TXT("request_into_app")
		,?TXT("app_web_loop")
		,?TXT("beepbeep_loop")
		,?TXT("env_is_passed_on")
		,?TXT("call_to_dispatch")
		,?TXT("app_web_preprocess")
		,?TXT("get_controller")
		,?TXT("app_web_before_filter")
		,?TXT("controller_before_filter")
		,?TXT("controller_action")
		,?TXT("controller_before_render")
		,?TXT("app_web_before_render")
		,?TXT("the_end")
		,{title, ?TXT2("how_stuff_works")}
										 ]};

handle_request("hooks",[]) ->
	{render,"documentation/hooks.html",[
		 ?TXT("hooks_overview_title")
		,?TXT("hooks_overview")
		,?TXT("hooks_overview_2")
		,?TXT("hooks_detailed")
		,?TXT("where_app_web")
		,?TXT("params")
		,?TXT("environment_variable")
		,?TXT("hook_app_web_preprocess")
		,?TXT("returns")
		,?TXT("render_state")
		,?TXT("render_state_description")
		,?TXT("new_controller")
		,?TXT("new_controller_description")
		,?TXT("hook_app_web_before_filter")
		,?TXT("hook_controller_before_filter")
		,?TXT("hook_controller_before_render")
		,?TXT("hook_app_web_before_render")
		,{title, ?TXT2("hooks")}
										]};

handle_request("erlydtl",[]) ->
	{render,"documentation/erlydtl.html",[
		 ?TXT("for_now_refer_to_erlydtl_docs")
		,{title, "ErlyDTL"}
										]};

handle_request("roadmap",[]) ->
	{render,"documentation/roadmap.html",[
		 ?TXT("this_is_a_tentative_roadmap")
		,?TXT("options_to_beepbeep")
		,?TXT("erlydtl_changes")
		,?TXT("webmachine_integration")
		,?TXT("yaws_integration")
		,?TXT("pluggable_template_engines")
		,?TXT("better_error_handling_customization")
		,?TXT("django_middleware")
		,?TXT("ewgi")
		,{title, ?TXT2("roadmap")}
										]};

handle_request("middleware",[]) ->
    {render,"documentation/middleware.html", [
		  ?TXT("intro_to_middleware")
		 ,?TXT("intro_to_middleware_2")
		 ,?TXT("intro_to_middleware_3")
		 ,?TXT("intro_to_middleware_4")
		 ,{title, "Middleware"}
										]}.

before_render({render, View, Data, Options}) ->
	{render, View, Data ++ [
		 ?TXT("overview")
		,?TXT("get_started")
		,?TXT("working_with_beepbeep")
		,?TXT("hooks")
		,?TXT("technical_info")
		,?TXT("how_stuff_works")
		,?TXT("roadmap")
		,?TXT("faq")
						   ], Options}.