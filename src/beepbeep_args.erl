%%
%% Main BeepBeep API to use in Controllers
%%
-module(beepbeep_args).
-compile(export_all).
-author('Dave Bryson <http://weblog.miceda.org>').

%% @spec path(Env) -> Path
%% @doc return the path
path(Env) ->
    proplists:get_value("PATH_INFO", Env).

%% @spec path_components(Env) -> []
%% @doc return the path as an array parsed on the "/"
path_components(Env) ->
    string:tokens(path(Env), "/").

%% @spec server_software(Env) -> ServerSoftware
%% @doc return the name of the server
server_software(Env) ->
    proplists:get_value("SERVER_SOFTWARE", Env).

%% @spec server_name(Env) -> ServerName
%% @doc return the hostname of the server
server_name(Env) ->
    proplists:get_value("SERVER_NAME", Env).

%% @spec server_protocol(Env) -> ServerProtocol
%% @doc return the protocol i.e. http
server_protocol(Env) ->
    proplists:get_value("SERVER_PROTOCOL", Env).

server_port(Env) ->
    proplists:get_value("SERVER_PORT", Env).

method(Env) ->
    proplists:get_value("REQUEST_METHOD", Env).

content_type(Env) ->
    proplists:get_value("CONTENT_TYPE", Env).

content_length(Env) ->
    proplists:get_value("CONTENT_LENGTH", Env).

remote_addr(Env) ->
    proplists:get_value("REMOTE_ADDR", Env).

get_all_headers(Env) ->
    lists:foldl(fun({"HTTP_" ++ _, _}=Pair, Hdrs) ->
                        [Pair|Hdrs];
                   (_, Hdrs) ->
                        Hdrs
                end, [], Env).

get_param(Key, Env) ->
	get_param(Key, Env, "").
get_param(Key, Env, Default) ->
    Params = proplists:get_value("beepbeep.data", Env),
    proplists:get_value(Key, Params, Default).

get_session_id(Env) ->
    ewgi_api:find_data("beep.session_id", Env).

set_session_id(Value, Env) ->
    case lists:keysearch("beepbeep_sid", 1, Env) of
	{value, _} ->
	    set_value("beepbeep_sid", Value, Env);
	false ->
	    [proplists:property({"beepbeep_sid", Value})|Env]
    end.

%% Helpers for accessing Session Data
set_session_data(Env, Key, Value) ->
    Sid = get_session_id(Env),
    beepbeep_session_server:set_session_data(Sid, Key, Value).

get_session_data(Env) ->
    Sid = get_session_id(Env),
    beepbeep_session_server:get_session_data(Sid).

get_session_data(Key, Env) ->
    proplists:get_value(Key, get_session_data(Env)).

get_action(Env) ->
    ewgi_api:find_data("beep.action", Env).

set_action(Env, Value) ->
    case lists:keysearch("action_name", 1, Env) of
	{value, _} ->
	    set_value("action_name", Value, Env);
	false ->
	    [proplists:property({"action_name", Value})|Env]
    end.

get_controller(Env) ->
    PathComponents = path_components(Env),
    %% Map the request to our app
    {ControllerName, _ActionName, _Args}  = case PathComponents of
					    [] ->
						{"home", "index", []};
					    [C] ->
						{C, "index", []};
					    [C, A | Params]  ->
						{C, A, Params}
					end,
	ControllerName.

set_controller(Env, Value) ->
    case lists:keysearch("controller_name", 1, Env) of
	{value, _} ->
	    set_value("controller_name", Value, Env);
	false ->
	    [proplists:property({"controller_name", Value})|Env]
    end.

get_value(Key, Env) ->
    proplists:get_value(Key, Env).

get_value(Key, Env, Default) ->
    proplists:get_value(Key, Env, Default).

get_all_values(Key, Env) ->
    proplists:get_all_values(Key, Env).

set_value(Key, Val, Env) ->
    lists:keyreplace(Key, 1, Env, {Key, Val}).

%%
%% @doc Set a 'flash' message for use in your template. All flash message are wr
%%
flash(Term, Env) ->
	Flash = case get_session_data("beepbeep_flash", Env) of
		undefined ->
			[Term];
		ExistingFlash ->
			[Term|ExistingFlash]
	end,
	set_session_data(Env, "beepbeep_flash", Flash).

%% Get and clear the flash
get_flash(Env) ->
	Sid = get_session_id(Env),
	case get_session_data("beepbeep_flash", Env) of
		undefined ->
			%% No flash data
			none;
		Data ->
			beepbeep_session_server:remove_session_data(Sid, "beepbeep_flash"),
			Data
	end.
