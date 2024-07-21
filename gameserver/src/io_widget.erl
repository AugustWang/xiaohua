-module(io_widget).

-export([start/1, test/0, set_title/2, insert/2]).


start(Pid) ->
    gs:start(),
    spawn_link(fun() -> widget(Pid) end).

set_title(Pid, Str) -> 
    Pid ! {title, Str}.

insert(Pid, Str) ->
    Pid ! {insert, Str}.

widget(Parent) ->
    Size = [{width,500},{height,200}],
    Win = gs:window(gs:start(),
		    [{map,true},{configure,true},{title,"window"}|Size]),
    gs:frame(packer, Win,[{packer_x, [{stretch,1,500}]},
			  {packer_y, [{stretch,10,120,100},
				      {stretch,1,15,15}]}]),
    gs:create(editor,editor,packer, [{pack_x,1},{pack_y,1},{vscroll,right}]),
    gs:create(entry, entry, packer, [{pack_x,1},{pack_y,2},{keypress,true}]),
    gs:config(packer, Size),
    gs:config(entry, {insert,{0," > "}}),
    loop(Win, Parent). 

loop(Win, Parent) ->   
    receive
	{title, Str} ->
	    gs:config(Win, [{title, Str}]),
	    loop(Win, Parent);
	{insert, Str} ->
	    gs:config(editor, {insert,{'end',Str}}),
	    loop(Win, Parent);
	{gs,_,destroy,_,_} ->
	    Parent ! {self(), destroyed};
	{gs, entry,keypress,_,['Return'|_]} ->
	    Text = gs:read(entry, text),
	    io:format("Read:~p~n",[Text]),
	    gs:config(entry, {delete,{0,last}}),
	    gs:config(entry, {insert,{0," > "}}),
	    Parent ! {self(), {data, Text}},
	    loop(Win, Parent);
	{gs,_,configure,[],[W,H,_,_]} ->
	    gs:config(packer, [{width,W},{height,H}]),
	    loop(Win, Parent);
	{gs, entry,keypress,_,_} ->
	    loop(Win, Parent);
	Any ->
	    io:format("Discarded:~p~n",[Any]),
	    loop(Win, Parent)
    end.

test() ->
    spawn(fun() -> test1() end).

test1() ->
    W = io_widget:start(self()),
    io_widget:set_title(W, "Test window"),
    loop(W).

loop(W) ->
    receive
	{W, {data, Str}} ->
	    Str1 = Str ++ "\n",
	    io_widget:insert(W, Str1),
	    loop(W)
    end.