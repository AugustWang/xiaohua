cd ../data
erl  -pa ../ebin -env ERL_MAX_ETS_TABLES 32768 -boot start_sasl -config elog -sname gameserver -setcookie gameserver -s server start