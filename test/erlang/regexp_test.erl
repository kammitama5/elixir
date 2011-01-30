-module(regexp_test).
-include("elixir.hrl").
-include_lib("eunit/include/eunit.hrl").

% Evaluate the Expr returning Regexp internal information.
eval_regexp(Expr) ->
  { Regexp, Binding } = elixir:eval(Expr),
  { test_helper:unpack_regexp(Regexp), Binding }.

base_regexp_test() ->
  {{"foo", [], []}, []} = eval_regexp("~r{foo}"),
  {{"foo", "iu", []}, []} = eval_regexp("~r{foo}iu"),
  {{"foo", "iu", []}, []} = eval_regexp("~R{foo}iu"),
  {{"foo", "iu", []}, []} = eval_regexp("~R{f#{'o}o}iu").
