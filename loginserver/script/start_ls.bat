echo on
cd ../data
erl  -pa ../ebin -env ERL_MAX_ETS_TABLES 32768  -boot start_sasl -config elog  -sname loginserver -setcookie loginserver -s server start
