#!/bin/sh
cd ../data
erl -detached -smp +K true -pa ../ebin -env ERL_MAX_ETS_TABLES 32768  -boot start_sasl -config elog  -sname gameserver -setcookie gameserver -s server start
#erl -noshell -boot start_clean -sname gameserver -pa ../ebin  -s main start
