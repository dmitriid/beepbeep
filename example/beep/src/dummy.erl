-module(dummy).

-export([run/2, run/3]).

run(Ctx, App) ->
	io:format("Dummy!!!!!~n"),
	App(Ctx).

run(Ctx, App, O) ->
	io:format("Dummy ~p~n", [O]),
	App(Ctx).
