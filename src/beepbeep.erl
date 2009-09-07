%% @author Dave Bryson [http://weblog.miceda.org]
%% @copyright Dave Bryson 2008-2009
%%
%% @doc BeepBeep Dispatcher
%%
%% This is called from the MochiWeb server to dispatch
%% requests. Requests are mapped to modules (controllers) and
%% functions (actions) based on path components in the Url. For
%% example, the request:
%%
%% '/feed/show'
%%
%% would get mapped to the module (controller) 'feed' and the function
%% (action) 'show'.
%% By default the root request:
%%
%% '/'
%%
%% is automatically mapped to the module 'home' and the function 'index'
%% Maps Urls to controllers and their views
%%
%% <strong>Note:</strong> the default behaviour can be easily overriden by
%% middleware components
%%
-module(beepbeep).
-author('Dave Bryson <http://weblog.miceda.org>').

-export([loop/1, run/2]).
-export([get_view_file/1]).

-include("beepbeep.hrl").

%% @spec loop(Modules::proplist()) -> function()
%% @doc Returns a function to be called from ewgi. Modules is a list of
%%      middleware components that will be called in succession. 
%%      <strong>Note:</strong> Beepbeep is always the last module in the chain
%%
%%      May be invoked like this: loop([module1, {module2, Options}, beepbeep]).

-spec loop(proplist()) -> function().
loop(Modules) when is_list(Modules) ->
	F = fun(Ctx) ->
			beepbeep_mw:stack(Ctx, Modules)
	    end,
	F.

%% @spec run(Ctx::ewgi_context(), App::function()) -> ewgi_context()
%% @doc Handles various return codes from within the framework and
%%      "translates" them into ewgi context.

-spec run(ewgi_context(), function()) -> ewgi_context().
run({ewgi_context, Request, _Response} = C, App) ->
    [{AppWebModule, _}] = lists:filter(
		fun({T, _}) ->
				T1 = atom_to_list(T),
				Tokens = string:tokens(T1, "_"),
				case
					lists:last(Tokens) of "web" -> true;
					_ -> false
				end
		end, code:all_loaded()),
	case dispatch(C, AppWebModule) of
		{ok, Status, ContentType, Headers, Content} ->
			Ctx = {ewgi_context, Request, {ewgi_response, {Status, "OK"}, [{"content-type", ContentType} | Headers], Content, undefined}},
			App(Ctx);
		{redirect, Url} ->
			{ewgi_context, Request, {ewgi_response, {302, "Temporary redirect"}, [{"Location", Url}, {"content-type", "text/html; charset=UTF-8"}], "", undefined}};
		{static, File} ->
			Tokens = string:tokens(atom_to_list(AppWebModule), "_"),
			AppNameTokens = lists:sublist(Tokens, length(Tokens) - 1),
			Deps = list_to_atom(lists:flatten( string:join(AppNameTokens, "_") ++ "_deps")),
			FilePath = Deps:local_path(["www"]) ++ File,
			Ctx = {ewgi_response, {200, "OK"}, [{"content-type", content_type(filename:extension(File))}], [], undefined},
			Ctx1 = serve_file(Ctx, FilePath),
			Ctx2 = {ewgi_context, Request, Ctx1},
			App(Ctx2);
		{error, Err} ->
			{ok, Data} = beepbeep_error:render_error(Err),
			{ewgi_context, Request, {ewgi_response, {501, "Internal server error"}, [{"content-type", "text/html"}], Data, undefined}}
	end.


%% @spec run(Context::ewgi_context(), AppWebModule::atom()) -> tuple()
%% @doc Performs actual Beepbeep jobs, calls controller etc.

-spec dispatch(ewgi_context(), atom()) -> tuple().
dispatch(Context, AppWebModule) ->
    PathComponents = string:tokens(ewgi_api:path_info(Context), "/"),
	%% Map the request to our app
    {ControllerName, ActionName, Args}  = case PathComponents of
					    [] ->
							{"home", "index", []};
					    [C] ->
							{C, "index", []};
					    [C, A | Params]  ->
							{C, A, Params}
					end,
    case beepbeep_router:get_controller(ControllerName) of
	{ok, Controller} ->
		Ctx1 = ewgi_api:store_data("beep.controller", atom_to_list(Controller), Context),
		Ctx = ewgi_api:store_data("beep.action", ActionName, Ctx1),
		case try_app_filter(AppWebModule, Ctx) of
			ok ->
				process_request(AppWebModule, Ctx, Controller, ActionName, Args);
			Response ->
				preprocess_request(Response, AppWebModule, Ctx, Controller, ActionName, Args)
		end;
	no_controller ->
	    F = ewgi_api:path_info(Context),
		preprocess_request({static,  F}, AppWebModule, Context, undefined, ActionName, Args)
    end.


process_request(AppWebModule, Context, ControllerName, ActionName, Args) ->
    Controller = ControllerName:new(Context),
    case try_filter(Controller) of
		ok ->
			try Controller:handle_request(ActionName, Args) of
				Response ->
					preprocess_request(Response, AppWebModule, Context, Controller, ActionName, Args)
			catch
				_:ErrorReason ->
					try try_app_error(AppWebModule, {error, ErrorReason}, Context) of
						Response ->
							preprocess_request(Response, AppWebModule, Context, Controller, ActionName, Args)
					catch
						_:Reason ->
							Reason
					end
			end;
		Any ->
			preprocess_request(Any, AppWebModule, Context, Controller, ActionName, Args)
    end.

%% handle renderers
preprocess_request({render, View} = _Request, AppWebModule, Env, Controller, ActionName, Args) ->
	preprocess_request({render, View, [], []}, AppWebModule, Env, Controller, ActionName, Args);
preprocess_request({render, View, Data} = _Request, AppWebModule, Env, Controller, ActionName, Args) ->
	preprocess_request({render, View, Data, []}, AppWebModule, Env, Controller, ActionName, Args);
preprocess_request({render, _View, _Data, _Options} = Request, AppWebModule, Env, Controller, _ActionName, _Args) ->
	Req = case beepbeep_args:get_flash(Env) of
        none -> Request;
        Flash ->
            {render, _View, [{flash, Flash}|_Data], _Options}
    end,
	NewRequest = pre_render(Req, AppWebModule, Env, Controller),
	handle_response(NewRequest);
preprocess_request({text, _Data} = Request, AppWebModule, Env, Controller, ActionName, _Args) ->
    %Env1 = beepbeep_args:set_action(Env, ActionName),
	NewRequest = pre_render(Request, AppWebModule, Env, Controller),
	handle_response(NewRequest);
preprocess_request({static, _File} = Request, AppWebModule, Env, Controller, _ActionName, _Args) ->
    %Env1 = beepbeep_args:set_action(Env, ActionName),
	NewRequest = pre_render(Request, AppWebModule, Env, Controller),
	handle_response(NewRequest);

%% handle internal redirects
preprocess_request({controller, ControllerName} = _Request, AppWebModule, Env, Controller, ActionName, Args) ->
	preprocess_request({controller, ControllerName, "index", []}, AppWebModule, Env, Controller, ActionName, Args);
preprocess_request({controller, ControllerName, MethodName} = _Request, AppWebModule, Env, Controller, ActionName, Args) ->
	preprocess_request({controller, ControllerName, MethodName, []}, AppWebModule, Env, Controller, ActionName, Args);
preprocess_request({controller, ControllerName, MethodName, NewArgs} = _Request, AppWebModule, Env, _Controller, _ActionName, _Args) ->
    case beepbeep_router:get_controller(ControllerName) of
	{ok, Controller} ->
		process_request(AppWebModule, Env, Controller, MethodName, NewArgs);
	no_controller ->
	    %% Try static
	    F = beepbeep_args:path(Env),
		preprocess_request({static,  F}, AppWebModule, Env, undefined, MethodName, NewArgs)
    end;

%% process all other requests as is
preprocess_request(Request, _AppWebModule, _Env, _Controller, _ActionName, _Args) ->
	handle_response(Request).

%% Handle all responses from controller
handle_response({render, View}) ->
	handle_response({render, View, []});

handle_response({render, View, Data}) ->
    {ok, Content} = render_template(View, Data),
    {ok, 200, "text/html", [], Content};

handle_response({render, View, Data, Options}) ->
    {ok, Content} = render_template(View, Data),
    {ok,
     proplists:get_value(status, Options, 200),
     proplists:get_value(content_type, Options, "text/html"),
     proplists:get_value(headers, Options, []),
     Content};

handle_response({text, Data}) ->
    {ok, 200, "text/plain", [], Data};

handle_response({text, Data, Mimetype}) ->
    {ok, 200, Mimetype, [], Data};

%% This seems stupid...better way??
handle_response({redirect, _Url} = Redirect) ->
    Redirect;

handle_response({static, _File} = File) ->
    File.

render_template(ViewFile, Data) ->
    FullPathToFile = get_view_file(ViewFile), 
    error_logger:info_msg("Trying file: ~s~n", [FullPathToFile]),
    Pieces = string:tokens(ViewFile, "/"),
    Name = string:join(Pieces, "_"),
    Name1 = filename:basename(Name, filename:extension(Name)),
    ModName = list_to_atom(Name1 ++ "_view"),

    Compile = erlydtl:compile(FullPathToFile, ModName),
	case Compile of
		{error, Error1} ->
			beepbeep_error:render_error({FullPathToFile, Error1});
		_ ->
		    try ModName:render(Data) of
				Any ->
					Any
			catch
				_:Error2 ->
					beepbeep_error:render_error({FullPathToFile, Error2})
			end
	end.

pre_render(Request, AppWebModule, Env, Controller) ->
	NewRequest = try_render(Controller, Request),
	try_app_render(AppWebModule, NewRequest, Env).


try_app_error(AppWebModule, Error, Env) ->
    try AppWebModule:error(Error, Env) of
		Any ->
			Any
	catch
		_:_ ->
			Error
    end.

try_app_filter(AppWebModule, Env) ->
    try AppWebModule:before_filter(Env) of
		Any ->
			Any
	catch
		_:_ ->
			ok
    end.

try_filter(ControllerName) ->
    try ControllerName:before_filter() of
		Any ->
			Any
	catch
		_:_ ->
			ok
    end.

try_render(ControllerName, Response) ->
    try ControllerName:before_render(Response) of
		Any ->
			Any
	catch
		_:_ ->
			Response
    end.

try_app_render(AppWebModule, Response, Env) ->
    try AppWebModule:before_render(Response, Env) of
		Any ->
			Any
	catch
		_:_ ->
			Response
	end.


%%%
%%% Utility functions
%%%

get_view_file(ViewFile) ->
    %%filename:join([get_base_dir()|["views", ViewFile]]),
    beepbeep_router:get_view(ViewFile).



%%
%% File-related functions
%%

%% @doc Serves file from within Beepbeep. <strong>Note:</strong> may result in
%%      a serious performance penalty. Use nginx or similar to serve static files
serve_file(Response, File) ->
    case file:open(File, [raw, binary]) of
        {ok, IoDevice} ->
            %% Set ChunkSize to an optimal value
            ChunkSize = 1024,
            Stream = iodevice_stream(IoDevice, ChunkSize),
            Response1 = setelement(4, Response, Stream),
            Response1;
        _ ->
            %% Respond with 404...
            setelement(2, Response, {404, "NOT FOUND"})
    end.

%% @doc Returns a CPS function that wraps a file.
%% @see http://groups.google.com/group/ewgi/browse_frm/thread/d1c91dbe220aa703
iodevice_stream(IoDevice, ChunkSize) ->
    fun() ->
            case file:read(IoDevice, ChunkSize) of
                eof ->
					 file:close(IoDevice),
                    {};
                {ok, Data} ->
                    {Data, iodevice_stream(IoDevice, ChunkSize)}
            end
    end.

%% @doc Return mime-type for several well-known file extensions.
content_type(".css") ->
	"text/css";
content_type(".png") ->
	"image/png";
content_type(".gif") ->
	"image/gif";
content_type(_) ->
	"text/plain".
