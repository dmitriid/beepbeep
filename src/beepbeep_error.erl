-module(beepbeep_error).

-export([render_error/1, dump/1]).

render_error(Err) ->
	{ok, [
		"<html><body><pre>",
		dump(Err),
		"</pre></body></html>"
	]}.

dump({Path, Err}) ->
	Error = guess_error(Err),
	lists:flatten(io_lib:format("~p", [{Path, Error}]));
dump(Err) ->
	io_lib:format("~p", [Err]).

guess_error({_, erlydtl_parser, [Reason, [[_OpenBracket, List, _EndBracket]]]}) ->
	Err = parser_error(List, []),
	{erlydtl_parser, lists:flatten([Reason, Err])};
guess_error({_, erlydtl_parser, L}) ->
	{erlydtl_parser, lists:flatten(L)};
guess_error(L) when is_list(L) ->
	lists:flatten(L);
guess_error(Err) ->
	Err.

parser_error([], Acc) ->
	lists:reverse(Acc);
parser_error([H|T], Acc) when is_list(H) ->
	parser_error(T, [list_to_integer(H)] ++ Acc);
parser_error([H|T], Acc) ->
	parser_error(T, [H] ++ Acc).
