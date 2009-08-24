%%  Controls login
-module(login_controller,[Env]).

-export([handle_request/2,before_filter/0]).

%% Return the login form
handle_request("new",[]) ->
    {render,"login/new.html",[]};

%% Get the post params from the form and verify
handle_request("create",[]) ->
	PostData = ewgi_api:remote_user_data(Env),
    Un = proplists:get_value("un",PostData),
    Pw = proplists:get_value("pw",PostData),

    %% Check if the user entered the proper Username and Password. 
    %% In this case it's hard code - foo:foobar
    if Un =:= "foo" andalso Pw =:= "foobar" ->
	    %% If the user entered the correct Un/Pw
	    %% Set the user_id in the session and redirect
	    beepbeep_args:set_session_data(Env,"user_id","dave"),
	    
	    {redirect,"/home/new"};
	true ->
	    %% Bad username and password - redirect back to the login page
	    {redirect,"/login/new"}
    end.

%% No filter used
before_filter() ->
    ok.
