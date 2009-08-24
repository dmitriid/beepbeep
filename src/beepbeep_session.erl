-module(beepbeep_session).

-export([run/2]).
-include("beepbeep.hrl").

run(Ctx, App) ->
	Cookies = ewgi_api:get_header_value("cookie", Ctx),
	SessionKey = case Cookies of
		undefined -> beepbeep_session_server:new_session(undefined);
		_ ->
			Cookie = proplists:get_value(?BEEPBEEP_SID, beepbeep_cookies:parse_cookie(Cookies)),
			beepbeep_session_server:new_session(Cookie)
	end,

	Ctx1 = ewgi_api:store_data("beep.session_id", SessionKey, Ctx),
	Ctx2 = App(Ctx1),

	SetCookieHeader = beepbeep_cookies:cookie(?BEEPBEEP_SID, SessionKey, [{path, "/"}]),
	Ctx3 = ewgi_api:response_headers([SetCookieHeader | ewgi_api:response_headers(Ctx2)], Ctx2),
	Ctx3.
