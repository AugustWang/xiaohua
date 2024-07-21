%% Author: yueliangyou
%% Created: 2013-3-6
%% Description: TODO: Md5加密
-module(md5).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export[encrypt/1].

%%对指定字符串用MD5加密
encrypt(String)->
	Md5_16=erlang:md5(String),	
	Md5_list=binary_to_list(Md5_16), 
	lists:flatten(list_to_hex(Md5_list)). 
 
list_to_hex(L)-> 
	lists:map(fun(X)->int_to_hex(X) end, L). 
 
int_to_hex(N) when N < 256-> 
	[hex(N div 16), hex(N rem 16)]. 
 
hex(N) when N < 10-> 
	$0+N; 
hex(N) when N >= 10,N < 16-> 
	$a+(N-10).
