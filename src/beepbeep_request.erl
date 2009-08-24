%% Author: Senthilkumar Peelikkampatti
%% Created: Aug 16, 2009
%%
%%
%%====================================================================
%% http_method_handler -- A hack for mochiweb_multipart API.
%%====================================================================


-module(beepbeep_request).

-export([default_file_handler/2, default_file_handler_1/3, parse_post/2, parse_data/1]).


%%====================================================================
%% It is file handler function for file upload but it is an exact copy
%% of Mochiweb's function. May need specialized handler for big files.
%%====================================================================
default_file_handler(Filename, ContentType) ->
%% 	io:format(" default_file_handler Filename is ~p  and ContentType is ~p~n", [Filename, ContentType]),
	default_file_handler_1(Filename, ContentType, []).


%%====================================================================
%% It is file handler function for file upload but it is an exact copy
%% of Mochiweb's function. May need specialized handler for big files.
%%====================================================================
default_file_handler_1(Filename, ContentType, Acc) ->
    fun(eof) ->
            Value = iolist_to_binary(lists:reverse(Acc)),
            {Filename, ContentType, Value};
        (Next) ->
            default_file_handler_1(Filename, ContentType, [Next | Acc])
    end.


%%====================================================================
%% It is helper method for controllers,
%% This can be reused whenever there is a req for handling POST and
%%  which expects
%%   1. multipart/form-data
%% 	 2. application/x-www-form-urlencoded
%%====================================================================
parse_post(Ctx, "multipart/form-data") ->
	Content_length= ewgi_api:content_length(Ctx),
	Req = beepbeep_file_curry:new(Ctx),
	RequestContent = beepbeep_multipart:parse_form(Req, fun default_file_handler/2);


%%====================================================================
%% See above
%%====================================================================
parse_post(Ctx, "application/x-www-form-urlencoded") ->
	Content_length= ewgi_api:content_length(Ctx),
	Vals = ewgi_api:read_input_string(Content_length, Ctx),
	ewgi_api:parse_post(Vals).


%%====================================================================
%% This is the method indented to handle different type of http method
%% This method returns the FUN which later takes key to return value.
%%====================================================================

parse_data(Ctx) ->
    Data = case ewgi_api:request_method(Ctx) of
               'GET' ->
                    ewgi_api:parse_qs(ewgi_api:query_string(Ctx));
               _     ->
                    case ewgi_api:remote_user_data(Ctx) of
                        undefined ->
                            Ct = ewgi_api:content_type(Ctx),
                            Vals= parse_post(Ctx, parse_ct(Ct)),
                            Vals;
                        _->
                            ok
                    end
           end,
    fun (Key) when Data =/= ok ->
            proplists:get_value(Key, Data) end.


%% Parse content-type (ignoring additional vars for now)
%% Should look like "major/minor; var=val"
parse_ct(L) when is_list(L) ->
    case string:tokens(L, ";") of
        [H|_] ->
            H;
        _ ->
            undefined
    end.
