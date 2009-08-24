-module(contact_controller,[Env]).

-include("rberl.hrl").

-export([handle_request/2]).


handle_request("index",[]) ->
    {render,"contact/index.html", [
		{additional_css, "form.css"}
		,?TXT("contact")
		,?TXT("name")
		,?TXT("site")
		,?TXT("email")
		,?TXT("text")
		,?TXT("submit")
										]};

handle_request("send",[]) ->
	 Name  = html_utils:strip(beepbeep_args:get_param("name",Env))
    ,Email = html_utils:strip(beepbeep_args:get_param("email",Env))
    ,Site  = html_utils:strip(beepbeep_args:get_param("site",Env))
    ,Text  = html_utils:strip(beepbeep_args:get_param("text",Env)),
	
	if length(Name) =:= 0 andalso length(Email) =:= 0
	   andalso length(Site) =:= 0 andalso length(Text) =:= 0 ->
		   {redirect, "/contact/"};
	   true ->
		   spawn(fun() ->
			         smtp:send(lists:flatten([
			             "Name: ", Name, $\n,
			             "Email: ", Email, $\n,
			             "Site: ", Site, $\n,
			             "Text: ", $\n, Text
			         ]))
				 end),
		   {redirect, "/contact/sent"}
	end;

handle_request("sent",[]) ->
    {render,"contact/sent.html", [
		 ?TXT("email_sent")
										]}.