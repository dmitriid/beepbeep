-ifndef(_BEEPBEEP_HRL).
-define(_BEEPBEEP_HRL, 1).

%% Session Id key
-define(BEEPBEEP_SID, "_beepbeep_session_id_").

%% Environment data
-define(BEEPBEEP_ENV_DATA, [{server_sw, "SERVER_SOFTWARE"},
			    {server_name, "SERVER_NAME"},
			    {server_protocol, "SERVER_PROTOCOL"},
			    {server_port, "SERVER_PORT"},
			    {method, "REQUEST_METHOD"},
			    {content_type, "CONTENT_TYPE"},
			    {content_length,"CONTENT_LENGTH"},
			    {path_info, "PATH_INFO"},
			    {remote_addr, "REMOTE_ADDR"},
			    {beepbeep_params, "beepbeep.data"}]).




%% Include EWGI only once
%-include("ewgi.hrl").

%% @type property() = atom() | tuple()
-type(property() :: atom() | tuple()).

%% @type proplist() = [property()]
-type(proplist() :: [property()]).

%% @type iodata() = binary() | iolist()
-type(iodata() :: binary() | iolist()).

%%% Note: Dialyzer currently doesn't support recursive types. When it does, this should change:
%%%-type stream() :: fun(() -> {} | {any(), stream()}).
%% @type stream() = function()
-type stream() :: fun(() -> {} | {any(), function()}).

%% @type ewgi_response() = iodata() | stream()
-type(ewgi_response() :: iodata() | stream()).


%% @type ewgi_env() = proplist()
-type(ewgi_env() :: proplist()).

%% @type ewgi_response_headers() = [{string(), string()}]
-type(ewgi_response_headers() :: [{string(), string()}]).

%% @type ewgi_write() = function()
-type(ewgi_write() :: fun((iodata()) -> ok)).

%% @type ewgi_request() = proplist()
-type(ewgi_request() :: proplist()).

%% @type ewgi_context() = {ewgi_context, ewgi_request(), ewgi_response()}
-type(ewgi_context() :: {ewgi_context, ewgi_request(), ewgi_response()}).


-record(ewgi_response, {ewgi_status, ewgi_header_list, ewgi_message_body, any}).

-endif.
