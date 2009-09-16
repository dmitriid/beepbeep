-module(uri_params_middleware).
%% @doc A middlware for extracting URI parameters and populating beepbeep.data.
%%      Middleware must preceed beepbeep, but otherwise has no position requirements.
%%
%%      Acquired get_param/2 and get_param/3 from beepbeep_args, as beepbeep.data was
%%      no longer being populated and thus the functions are unusable if this middleware
%%      is not in effect.
%%
%% @author Will Larson <lethain@gmail.com> [lethain.com]

-export([run/2, get_param/2, get_param/3]).

get_param(Key, Env) ->
    get_param(Key, Env, undefined).

get_param(Key, Env, Default) ->
    Params = ewgi_api:find_data("beepbeep.data", Env),
    case is_list(Params) of
	true ->
	    proplists:get_value(Key, Params, Default);
	false ->
	    Default
    end.

%run(Ctx, App) ->
%    App(Ctx).

run(Ctx, App) ->
    QueryString = ewgi_api:query_string(Ctx),
    Data = case is_list(QueryString) of
	       true ->
		   mochiweb_util:parse_qs(QueryString);
	       false ->
		   []
    end,
    Ctx1 = ewgi_api:store_data("beepbeep.data", Data, Ctx),
    App(Ctx1).
