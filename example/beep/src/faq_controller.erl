%%
%% Sample default controller
%%
-module(faq_controller,[Env]).

-include("rberl.hrl").

-export([handle_request/2]).

handle_request("index",[]) ->
    {render,"faq/index.html",[
		 ?TXT("faq_title")
		,?TXT("faq_to_be_filled")
		,?TXT("faq_toc")
		,{title, ?TXT2("faq")}
							 ]}.
