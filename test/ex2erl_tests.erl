-module(ex2erl_tests).
-include_lib("eunit/include/eunit.hrl").

ex2erl_test() ->
    [{foo, _Code}] = rebar_ex2erl:ex2erl(<<"defmodule :foo, do: def sum(a, b), do: a + b">>, "foo.erl"),
    ?assertEqual(3, foo:sum(1, 2)),
    ok.
