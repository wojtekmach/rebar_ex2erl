-module(spdx_tests).
-include_lib("eunit/include/eunit.hrl").

spdx_test() ->
    true = lists:any(fun(X) -> X == <<"Apache-2.0">> end, spdx:license_ids()),
    ok.
