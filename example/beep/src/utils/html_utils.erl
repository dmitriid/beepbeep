-module(html_utils).

-export([htmlize/1, strip/1]).

htmlize(String) when is_list(String) ->
	htmlize(list_to_binary(String));
htmlize(String) ->
	htmlize(String, []).

htmlize(<<>>, Acc) ->
	lists:reverse(Acc);
htmlize(<<$\\, $n, Rest/binary>>, Acc) ->
	htmlize(Rest, ["<br />"] ++ Acc);
htmlize(<<$\\, $t, Rest/binary>>, Acc) ->
	htmlize(Rest, ["    "] ++ Acc);
htmlize(<<$\\, $:, Rest/binary>>, Acc) ->
	htmlize(Rest, [":"] ++ Acc);
htmlize(<<$<, Rest/binary>>, Acc) ->
	htmlize(Rest, ["&lt;"] ++ Acc);
htmlize(<<$>, Rest/binary>>, Acc) ->
	htmlize(Rest, ["&gt;"] ++ Acc);
htmlize(<<Char:1/binary, Rest/binary>>, Acc) ->
	htmlize(Rest, [Char] ++ Acc).


strip(Value) ->
    lists:reverse(strip1(lists:reverse(strip1(Value)))).

%% @spec strip1(Value::string()) -> string()
strip1([]) ->
    [];
strip1([32 | _T] = Value) ->
    strip1(string:strip(Value));
strip1([$\t | _T] = Value) ->
    strip1(string:strip(Value, both, $\t));
strip1([$\f | _T] = Value) ->
    strip1(string:strip(Value, both, $\f));
strip1(Value) ->
    Value.