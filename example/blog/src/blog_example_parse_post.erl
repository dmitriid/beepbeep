-module(blog_example_parse_post).

-export([run/2]).

%% adapted from
%% http://github.com/skarab/ewgi_examples/blob/f8a5451992d2b72d73749bf2432bd05afea4688f/src/ewgi_post.erl
%% see discussion here:
%% http://groups.google.com/group/ewgi/tree/browse_frm/thread/c28995f6ef58bb94/b02e1fd66364629c?rnum=1&_done=%2Fgroup%2Fewgi%2Fbrowse_frm%2Fthread%2Fc28995f6ef58bb94%3F#doc_432d55727a0aec8d

run(Ctx, App) ->
    Parser = post_parse_middleware(App),
    case ewgi_api:request_method(Ctx) of
        'GET' ->
            App(Ctx);
        'POST' ->
            Parser(Ctx)
    end.

post_parse_middleware(App) ->
    fun(Ctx) ->
            case ewgi_api:request_method(Ctx) of
                Method when Method =:= 'POST';
                            Method =:= 'PUT' ->
                    case ewgi_api:remote_user_data(Ctx) of
                        undefined ->
                            %% Check content-type first
                            Ct = ewgi_api:content_type(Ctx),
                            parse_post(Ctx, App, parse_ct(Ct));
                        _ ->
                            App(Ctx)
                    end;
                _ ->
                    App(Ctx)
            end
    end.

%% Parse content-type (ignoring additional vars for now)
%% Should look like "major/minor; var=val"
parse_ct(L) when is_list(L) ->
    case string:tokens(L, ";") of
        [H|_] ->
            H;
        _ ->
            undefined
    end.

parse_post(Ctx, App, "application/x-www-form-urlencoded") ->
    case ewgi_api:content_length(Ctx) of
        L when is_integer(L), L > 0 ->
            Input = read_input_string(Ctx, L),
            Vals = ewgi_api:parse_post(Input),
            Ctx1 = ewgi_api:remote_user_data(Vals, Ctx),
            App(Ctx1);
        _ ->
            App(Ctx)
    end;
parse_post(Ctx, App, _) ->
    %% Silently ignore other content-types
    App(Ctx).

read_input_string(Ctx, L) when is_integer(L), L > 0 ->
    R = ewgi_api:read_input(Ctx),
    iolist_to_binary(R(read_input_string_cb([]), L)).

read_input_string_cb(Acc) ->
    fun(eof) ->
            lists:reverse(Acc);
       ({data, B}) ->
            read_input_string_cb([B|Acc])
    end.