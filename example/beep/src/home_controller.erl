%%
%% Sample default controller
%%
-module(home_controller, [Env]).

-export([handle_request/2,before_filter/0]).

-include("rberl.hrl").

handle_request("index",[]) ->
    {render,"home/index.html",[
		 ?TXT("buzzwords_to_get_started")
		,?TXT("fast")
		,?TXT("dtl")
		,?TXT("buzzword_middleware")
		,?TXT("q_a_microframework")
		,?TXT("description_microframework")
		,?TXT("q_how_it_works")
		,?TXT("description_how_it_works")
		,?TXT("q_anyone_using")
		,?TXT("description_anyone_using")
		,?TXT("header_get_it")
		,?TXT("link_on_github")
		,?TXT("header_learn_more")
		,?TXT("link_documentation")
		,?TXT("link_roadmap")
		,?TXT("link_faq")
		,?TXT("framework_slogan")
		,?TXT("download_instructions")
		,?TXT("q_tutorials")
		,?TXT("tutorials_description")
		,{title, ?TXT2("welcome")}

							  ]}.

%% If necessary, add these hooks:
%% *DON'T FORGET TO EXPORT THEM AS NECESSARY*

%% before_filter/0
%%
%% Should return one of:
%% ok
%% {render, View, Data}
%% {render, View, Data, Options}
%% {static, File}
%% {text, Data}
%% {redirect, Url}
%% {controller, ControllerName}
%% {controller, ControllerName, ActionName}
%% {controller, ControllerName, ActionName, Args}
%%
before_filter() ->
	ok.

%Env = "",
%    FilterOnly = ["show"],
%    case lists:member(beepbeep_args:get_action(Env),FilterOnly) of
%		true ->
%			ok;
%		false ->
%			ok
%    end.

%% before_render/1
%%
%% This hook accepts one of these tuples:
%% {render, View, Data}
%% {render, View, Data, Options}
%% {static, File}
%% {text, Data}
%%
%% Should return one of:
%% {render, View, Data}
%% {render, View, Data, Options}
%% {static, File}
%% {text, Data}
%% {redirect, Url}
%%
%% before_render({render, View, Data, Options}) ->
%%	{render, View, Data, Options}.