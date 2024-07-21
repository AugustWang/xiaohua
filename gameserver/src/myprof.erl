-module(myprof).

-compile(export_all).

%% all | existing | new | pid()
-define(FPROF_TRACE_FILE, "prof.log").
fprof(Pid,Time) ->
    spawn(fun() -> fprof_start(Pid), timer:sleep(Time*1000), fprof_stop() end).
fprof_start(Procs) ->
    fprof:trace([start, {file, ?FPROF_TRACE_FILE}, {procs, Procs}]).


%% @doc fprof complete
fprof_stop() ->
    ok = fprof:trace(stop),
    ok = fprof:profile({file, ?FPROF_TRACE_FILE}),
    DateStr = date_str(),
    Analyse1 = lists:concat(["fprof-", DateStr,".own"]),
    ok = fprof:analyse([{dest, Analyse1}, {details, true}, {totals, true}, {sort, own}]),
    io:format("fprof own ,result:~s~n", [Analyse1]),
    Analyse2 = lists:concat(["fprof-", DateStr,".acc"]),
    ok = fprof:analyse([{dest, Analyse2}, {details, true}, {totals, true}, {sort, acc}]),
    io:format("fprof acc ,result:~s~n", [Analyse2]),
    Analyse3 = lists:concat(["fprof-", DateStr,".normal"]),
    ok = fprof:analyse({dest, Analyse3}),
    io:format("fprof normal ,result:~s~n", [Analyse3]),
    io:format("fprof complete ~n"),

    ok.

%% 获取时间戳
date_str() ->
    date_str(erlang:localtime()).
date_str({{Year, Month, Day}, {Hour, Minute, _Second}}) ->
    lists:flatten(
        io_lib:format("~4..0B~2..0B~2..0B-~2..0B~2..0B",
                    [Year, Month, Day, Hour, Minute])).
