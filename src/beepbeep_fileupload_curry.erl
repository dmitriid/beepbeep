-module(beepbeep_fileupload_curry, [Ctx]).

-author('Senthilkumar Peelikkampatti <http://pmsenthilkumar.blogspot.com/>').

-export([recv/1, get_header_value/1]).

%%====================================================================
%% It is adapter methor for mochiweb_multipart
%%====================================================================

recv(Length) ->
	Bin = iolist_to_binary(ewgi_api:read_input_string(Length, Ctx)),
    Bin.


%%====================================================================
%% It is adapter methor for mochiweb_multipart
%%====================================================================
get_header_value ("content-length") ->
    integer_to_list(ewgi_api:content_length(Ctx));


%%====================================================================
%% It is adapter methor for mochiweb_multipart
%%====================================================================
get_header_value ("content-type") ->
    ewgi_api:content_type(Ctx).