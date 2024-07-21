#!/bin/sh
erl   -sname tmp1234 -setcookie gameserver -s stop_gameserver stop 'gameserver@localhost'
