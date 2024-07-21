%% Author: yueliangyou
%% Created: 2013-4-18
%% Description: TODO: utf8解析
-module(utf8).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export[get_utf8_char/1].

get_utf8_char ([]) ->
    {0, []};
get_utf8_char ([Char1 | String]) ->
    get_utf8_char(Char1, String).
 
get_utf8_char (Char1, String) when Char1 < 16#80 ->
    {Char1, String};
get_utf8_char (Char1, String) when Char1 < 16#E0 ->
    [Char2 | String2] = String,
    {{Char1, Char2}, String2};
get_utf8_char (Char1, String) when Char1 < 16#F0 ->
    [Char2, Char3 | String2] = String,
    {{Char1, Char2, Char3}, String2};
get_utf8_char (Char1, String) when Char1 < 16#F8 ->
    [Char2, Char3, Char4 | String2] = String,
    {{Char1, Char2, Char3, Char4}, String2};
get_utf8_char (Char1, String) when Char1 < 16#FC->
    [Char2, Char3, Char4, Char5 | String2] = String,
    {{Char1, Char2, Char3, Char4, Char5}, String2};
get_utf8_char (Char1, String) when Char1 < 16#FE->
    [Char2, Char3, Char4, Char5, Char6 | String2] = String,
    {{Char1, Char2, Char3, Char4, Char5, Char6}, String2}.

