-define(TXT, 
	fun(_K) ->
		_Language = ewgi_api:find_data("beep_web.language", Env, "en-US"),
		{list_to_atom(_K), rberl_server:get(_K, _Language)}
	end).

-define(TXT2, 
	fun(_K) ->
		_Language = ewgi_api:find_data("beep_web.language", Env, "en-US"),
		rberl_server:get(_K, _Language)
	end).

-define(LANGUAGES, ["en-US", "ru-RU", "tr-TR", "ro-RO"]).