-module(beep_app).

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for beep.
start(_Type, _StartArgs) ->
    beep_deps:ensure(),
    beep_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for beep.
stop(_State) ->
    ok.
