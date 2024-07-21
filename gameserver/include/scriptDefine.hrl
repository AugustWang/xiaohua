
%%脚本事件回调函数
-record( scriptEvent, {event, call_module, call_func, parama} ).

%%脚本对象
-record( scriptObject, {id, type, data_id, event_array } ).



