-module(beep_web_dispatch).

-export([run/2]).
-include("rberl.hrl").


run({ewgi_context, Request, _} = Ctx, App) ->
	PathInfo = string:tokens(ewgi_api:path_info(Ctx), "/"),
	Path = list_to_binary(PathInfo),

	Session = ewgi_api:find_data("beep.session_id", Ctx),
	SessionData = beepbeep_session_server:get_session_data(Session),

	Language = case proplists:get_value("language", SessionData) of
		undefined ->
			"en-US";
		Any ->
			Any
	end,

	beepbeep_session_server:set_session_data(Session, "language", Language),
	case Path of
		<<>> ->
			{ewgi_context, Request, {ewgi_response, {302, "Temporary redirect"}, [{"Location", "/" ++ Language ++ "/"}], "", undefined}};
		<<A,B,$-,C,D>> ->
			%% we have a language set it
			beepbeep_session_server:set_session_data(Session, "language", [A,B,$-,C,D]),
			Ctx1 = ewgi_api:path_info("/", Ctx),
			Ctx2 = ewgi_api:store_data("beep_web.language", [A,B,$-,C,D], Ctx1),
			App(Ctx2);
		<<A,B,$-,C,D,Rest/binary>> ->
			beepbeep_session_server:set_session_data(Session, "language", [A,B,$-,C,D]),
			Ctx1 = ewgi_api:path_info("/" ++ string:join(tl(PathInfo), "/"), Ctx),
			Ctx2 = ewgi_api:store_data("beep_web.language", [A,B,$-,C,D], Ctx1),
			App(Ctx2);
		_ ->
			{ewgi_context, Request, {ewgi_response, {302, "Temporary redirect"}, [{"Location", "/"++Language++"/" ++ string:join(PathInfo, "/")}], "", undefined}}
	end.