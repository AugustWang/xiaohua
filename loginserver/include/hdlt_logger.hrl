%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2010. All Rights Reserved.
%%
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%%
%% %CopyrightEnd%
%%
%%

-ifndef(hdlt_logger_hrl).
-define(hdlt_logger_hrl, true).

%% Various log macros
%-define(SET_LEVEL(N), hdlt_logger:set_level(N)).
%-define(GET_LEVEL(),  hdlt_logger:get_level()).
%-define(SET_NAME(N),  hdlt_logger:set_name(N)).

-define(ERROR_OUT(F, A),   hdlt_logger:error_out(F, A)).
-define(ERROR_OUT(F),   hdlt_logger:error_out(F, [])).
-define(LOG_OUT(F, A),    hdlt_logger:log(F, A)).
-define(LOG_OUT(F),    hdlt_logger:log(F, [])).
-define(DEBUG_OUT(F, A),  hdlt_logger:debug(F, A)).
-define(DEBUG_OUT(F),  hdlt_logger:debug(F, [])).

-endif. % -ifdef(hdlt_logger_hrl).

%%note:
%%1.log init
%%hdlt_logger:start("LogFileName"),"LogFileName" param is main name of log file,
%%auto create "Log" folder at cur dir,and create auto time log file at "Log" folder, 
%%like this:LogFileName-2012-08-07_15_17_29.log

%%2.use example:
%%(1).?DEBUG( "debug test ~s", ["P1"] ),
%%(2).?DEBUG( "debug test2" ),
%%(3).?LOG_OUT( "log test" ),
%%(4).?ERROR_OUT( "error test ~s", ["P1"] ),

