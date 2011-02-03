-module(string_test).
-include("elixir.hrl").
-include_lib("eunit/include/eunit.hrl").

% Evaluate the Expr returning String internal information.
eval_string(Expr) ->
  { String, Binding } = elixir:eval(Expr),
  { test_helper:unpack_string(String), Binding }.

% Interpolations

extract_interpolations_without_interpolation_test() ->
  [{s, "foo"}] = elixir_string_methods:extract_interpolations("foo").

extract_interpolations_with_escaped_interpolation_test() ->
  [{s, "f#{o}o"}] = elixir_string_methods:extract_interpolations("f\\#{o}o").

extract_interpolations_with_interpolation_test() ->
  [{s, "f"}, {i, "o"}, {s, "o"}] = elixir_string_methods:extract_interpolations("f#{o}o").

extract_interpolations_with_two_interpolations_test() ->
  [{s, "f"}, {i, "o"}, {i, "o"}, {s, "o"}] = elixir_string_methods:extract_interpolations("f#{o}#{o}o").

extract_interpolations_with_only_two_interpolations_test() ->
  [{i, "o"}, {i, "o"}] = elixir_string_methods:extract_interpolations("#{o}#{o}").

extract_interpolations_with_tuple_inside_interpolation_test() ->
  [{s, "f"}, {i, "{1}"}, {s, "o"}] = elixir_string_methods:extract_interpolations("f#{{1}}o").

extract_interpolations_with_string_inside_interpolation_test() ->
  [{s, "f"}, {i, "\"foo\""}, {s, "o"}] = elixir_string_methods:extract_interpolations("f#{\"foo\"}o").

extract_interpolations_with_right_curly_inside_string_inside_interpolation_test() ->
  [{s, "f"}, {i, "\"f}o\""}, {s, "o"}] = elixir_string_methods:extract_interpolations("f#{\"f}o\"}o").

extract_interpolations_with_right_curly_inside_regexp_inside_interpolation_test() ->
  [{s, "f"}, {i, "#r\"f}o\""}, {s, "o"}] = elixir_string_methods:extract_interpolations("f#{#r\"f}o\"}o").

%% String

simple_string_test() ->
  {<<"foo">>, _} = eval_string("\"foo\"").

string_with_double_quotes_test() ->
  {<<"f\"o\"o">>, _} = eval_string("\"f\\\"o\\\"o\"").

string_with_newline_test() ->
  {<<"f\no">>, _} = eval_string("\"f\no\"").

string_with_slash_test() ->
  {<<"f\\o">>, _} = eval_string("\"f\\\\o\"").

string_with_interpolation_test() ->
  {<<"foo">>, _} = eval_string("\"f#{'o}o\"").

string_with_another_string_interpolation_test() ->
  {<<"foo">>, _} = eval_string("\"f#{\"o\"}o\"").

string_with_another_string_inside_string_interpolation_test() ->
  {<<"fbaro">>, _} = eval_string("\"f#{\"b#{'a}r\"}o\"").

string_with_another_string_with_curly_inside_interpolation_test() ->
  {<<"fb}ro">>, _} = eval_string("\"f#{\"b}r\"}o\"").

string_with_atom_with_separator_inside_interpolation_test() ->
  {<<"f}o">>, _} = eval_string("\"f#{'(})}o\""),
  {<<"f}o">>, _} = eval_string("\"f#{'[}]}o\""),
  {<<"f}o">>, _} = eval_string("\"f#{'{\\}}}o\""),
  {<<"f}o">>, _} = eval_string("\"f#{'\\\"}\\\"}o\"").

string_without_interpolation_and_escaped_test() ->
  {<<"f#o">>, _} = eval_string("\"f\\#o\"").

string_with_escaped_interpolation_test() ->
  {<<"f#{'o}o">>, _} = eval_string("\"f\\#{'o}o\"").

invalid_string_interpolation_test() ->
  ?assertError({badarg, "unexpected end of string, expected }"}, elixir:eval("\"f#{{}o\"")).

strings_are_utf8_chars_test() ->
  F = fun() ->
    test_helper:load_fixture("utf8.ex"),
    {10,[]} = elixir:eval("Foo.length")
  end,
  test_helper:run_and_remove(F, ['Foo']).

char_test() ->
  {99,[]} = elixir:eval("$1 + $2"),
  {92,[]} = elixir:eval("$\\\n"),
  {40,[]} = elixir:eval("$\\\(").
    
bad_char_test() ->
  ?assertError({badsyntax, _}, elixir:eval("$foo")).

implicit_string_concatenation_test() ->
  {<<"foobar">>, []} = eval_string("\"foo\" \"bar\""),
  {<<"foobar">>, []} = eval_string("\"foo\"\n\"bar\""),
  {<<"foobarbaz">>, []} = eval_string("\"foo\"\n\"b#{'a}r\"\n\"baz\"").

string_preprocessors_test() ->
  {<<"f#{o}obar">>, []} = eval_string("~q(f#{o}o) ~Q(b#{'a}r)").

%% Methods

string_initialized_with_bin_test() ->
  {<<"elixir">>, []} = eval_string("String.new(<<101,108,105,120,105,114>>)").

string_to_s_returns_self_test() ->
  {<<"elixir">>, []} = eval_string("\"elixir\".to_s").

string_inspect_test() ->
  {<<"\"elixir\"">>, []} = eval_string("\"elixir\".inspect").

string_to_list_test() ->
  {"elixir", []} = elixir:eval("\"elixir\".to_list").

string_length_test() ->
  {6, []} = elixir:eval("\"elixir\".length").

string_add_test() ->
  {<<"elixir">>, []} = eval_string("\"eli\" + \"xir\"").
