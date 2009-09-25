%% @author Dave Bryson [http://weblog.miceda.org]
%% @copyright Dave Bryson 2008-2009
%% 
%% Creates a MochiWeb Server with the BeepBeep hook
%%
-module(blog_example_web).
-author('Dave Bryson <http://weblog.miceda.org>').

-export([start/1, stop/0, loop/1]).

start(Options) ->
    Loop = fun (Req) ->
                   ?MODULE:loop(Req)
           end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options]).

stop() ->
    mochiweb_http:stop(?MODULE).

loop(Req) ->
	Mod = ewgi_mochiweb:new(beepbeep:loop([beepbeep_session, post_data_middleware, beepbeep])),
    Mod:run(Req).
