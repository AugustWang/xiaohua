#!/bin/sh
erl   -sname tmp2234 -setcookie loginserver -s stop_loginserver stop 'loginserver@localhost'
