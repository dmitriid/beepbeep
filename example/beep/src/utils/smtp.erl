%%
%% adopted from
%% http://21ccw.blogspot.com/2009/05/how-to-send-email-via-gmail-using.html
%%

-module(smtp).
-export([send/1]).

send(Data) ->
	spawn(fun() ->
	case ssl:connect("smtp.gmail.com", 465, [{active, false}], 1000) of
		{ok, Socket} ->
			send1(Socket, Data);
		{error, Reason} ->
			err(Reason, Data)
	end end).

send1(Socket, Data) ->
    recv(Socket, Data),
    send(Socket, "HELO localhost", Data),
    send(Socket, "AUTH LOGIN", Data),
    send(Socket, binary_to_list(base64:encode("___@gmail.com")), Data),
    send(Socket, binary_to_list(base64:encode("password")), Data),
    send(Socket, "MAIL FROM: <___@gmail.com>", Data),
    send(Socket, "RCPT TO:<___@gmail.com>", Data),
    send(Socket, "DATA", Data),
    send_no_receive(Socket, "From: <___@gmail.com>"),
    send_no_receive(Socket, "To: <___@gmail.com>"),
    send_no_receive(Socket, "Date: Tue, 15 Jan 2008 16:02:43 +0000"),
    send_no_receive(Socket, "Subject: BeepBeep - Demo site"),
    send_no_receive(Socket, ""),
    send_no_receive(Socket, Data),
    send_no_receive(Socket, ""),
    send(Socket, ".", Data),
    send(Socket, "QUIT", Data),
    ssl:close(Socket).

send_no_receive(Socket, Data) ->
    ssl:send(Socket, Data ++ "\r\n").


send(Socket, Data, ActualData) ->
    ssl:send(Socket, Data ++ "\r\n"),
    recv(Socket, ActualData).

recv(Socket, Data) ->
	case ssl:recv(Socket, 0, 1000) of
		{ok, Return} ->
			io:format("~p~n", [Return]);
		{error, Reason} ->
			case Reason of
			   closed -> ssl:close(Socket), err(closed, Data), exit(closed);
			   _ -> io:format("ERROR: ~p~n", [Reason])
			end
	end.

err(Reason, Data) ->
	io:format("Error: ~p~n", [Reason]),
	spawn(
		fun() ->
				receive
					after 10000 -> ?MODULE:send(Data)
				end
		end
	).
