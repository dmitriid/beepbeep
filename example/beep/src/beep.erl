-module(beep).
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.
        
%% @spec start() -> ok
%% @doc Start the beep server.
start() ->
    beep_deps:ensure(),
    ensure_started(crypto),
    application:start(beep).

%% @spec stop() -> ok
%% @doc Stop the beep server.
stop() ->
    Res = application:stop(beep),
    application:stop(crypto),
    Res.
