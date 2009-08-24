-module(beepbeep_mw).

-export([stack/2]).

-include("beepbeep.hrl").

%% @spec stack(Ctx::ewgi_context(), Stack::proplist()) -> ewgi_context()
%% @doc Run multiple ewgi middleware apps in a chain

-spec stack(ewgi_context(), proplist()) -> ewgi_context().

stack(Ctx, []) ->
	Ctx;
stack(Ctx, [Middleware|T]) ->
	F = fun(C) ->
			stack(C, T)
		end,
	run(Middleware, Ctx, F).

run(Module, Ctx, F) when is_atom(Module) ->
	Module:run(Ctx, F);

run({Module}, Ctx, F) ->
	Module:run(Ctx, F);

run({Module, Options}, Ctx, F) ->
	Module:run(Ctx, F, Options).
