import gleam/dict
import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import sorbet

/// Main entry point for running the test suite
pub fn main() {
  gleeunit.main()
}

/// Tests parsing a simple key-value pair
/// Verifies that a basic "key => value" string is correctly parsed
pub fn parse_simple_key_value_test() {
  let input = "key => value"
  let result = sorbet.parse(input)

  dict.size(result)
  |> should.equal(1)

  dict.get(result, "key")
  |> should.equal(Ok("value"))
}

/// Tests parsing multiple key-value pairs
/// Verifies that multiple key-value pairs separated by newlines are correctly parsed
pub fn parse_multiple_key_value_pairs_test() {
  let input = "key1 => value1\nkey2 => value2\nkey3 => value3"
  let result = sorbet.parse(input)

  dict.size(result)
  |> should.equal(3)

  dict.get(result, "key1")
  |> should.equal(Ok("value1"))

  dict.get(result, "key2")
  |> should.equal(Ok("value2"))

  dict.get(result, "key3")
  |> should.equal(Ok("value3"))
}

/// Tests parsing with continuation lines
/// Verifies that continuation lines (starting with >) are correctly
/// appended to their respective values
pub fn parse_with_continuation_lines_test() {
  let input =
    "key1 => value1\n> continuation1\nkey2 => value2\n> continuation2\n> more continuation"
  let result = sorbet.parse(input)

  dict.size(result)
  |> should.equal(2)

  dict.get(result, "key1")
  |> should.equal(Ok("value1\ncontinuation1"))

  dict.get(result, "key2")
  |> should.equal(Ok("value2\ncontinuation2\nmore continuation"))
}

/// Tests parsing with empty lines
/// Verifies that empty lines between key-value pairs are ignored
pub fn parse_with_empty_lines_test() {
  let input = "key1 => value1\n\nkey2 => value2\n\n\nkey3 => value3"
  let result = sorbet.parse(input)

  dict.size(result)
  |> should.equal(3)

  dict.get(result, "key1")
  |> should.equal(Ok("value1"))

  dict.get(result, "key2")
  |> should.equal(Ok("value2"))

  dict.get(result, "key3")
  |> should.equal(Ok("value3"))
}

/// Tests parsing with whitespace
/// Verifies that whitespace around keys and values is properly trimmed
pub fn parse_with_whitespace_test() {
  let input = "  key1  =>  value1  \n  key2  =>  value2  "
  let result = sorbet.parse(input)

  dict.size(result)
  |> should.equal(2)

  dict.get(result, "key1")
  |> should.equal(Ok("value1"))

  dict.get(result, "key2")
  |> should.equal(Ok("value2"))
}

/// Tests formatting key-value pairs
/// Verifies that keys and values are correctly formatted into the Sorbet format,
/// including proper handling of multi-line values
pub fn format_key_value_test() {
  sorbet.format_key_value("key", "value")
  |> should.equal("key => value")

  sorbet.format_key_value("key", "value\nwith\nmultiple\nlines")
  |> should.equal("key => value\n> with\n> multiple\n> lines")
}

/// Tests formatting a dictionary into Sorbet format
/// Verifies that a dictionary is correctly converted to a string in Sorbet format,
/// and that the formatted string can be parsed back into an equivalent dictionary
pub fn format_dict_test() {
  let input =
    dict.from_list([
      #("key1", "value1"),
      #("key2", "value2\nwith\nmultiple\nlines"),
      #("key3", "value3"),
    ])

  let result = sorbet.format_dict(input)
  let lines = string.split(result, "\n")

  // We should have 6 lines (3 for key1, key3, and the first line of key2's value,
  // plus 3 more for the continuation lines of key2's value)
  list.length(lines)
  |> should.equal(6)

  // The result should contain all keys and values
  string.contains(result, "key1 => value1")
  |> should.be_true()

  string.contains(result, "key2 => value2")
  |> should.be_true()

  string.contains(result, "> with")
  |> should.be_true()

  string.contains(result, "> multiple")
  |> should.be_true()

  string.contains(result, "> lines")
  |> should.be_true()

  string.contains(result, "key3 => value3")
  |> should.be_true()

  // Parse the formatted output back to ensure it's valid
  let parsed = sorbet.parse(result)
  dict.size(parsed)
  |> should.equal(3)

  dict.get(parsed, "key2")
  |> should.equal(Ok("value2\nwith\nmultiple\nlines"))
}
