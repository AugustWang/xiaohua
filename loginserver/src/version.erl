-module(version).

-include("version.hrl").

%%
%% Exported Functions
%%
-compile(export_all).




getMinProtocolVersion()->
	?MIN_PROTOCOL_VERSION.

getDbVersion()->
	?DBVersion.

getServerVersion()->
	?ServerVersion.

