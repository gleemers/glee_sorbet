//// Sorbet
//// This is the main module for Sorbet.
//// It contains the types and functions for the Sorbet language.
////
//// Sorbet is a simple key-value configuration format with support for
//// multi-line values using continuation lines.
////
//// Example:
//// ```
//// key1 => value1
//// key2 => first line
//// > second line
//// > third line
//// ```

import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import utility

/// Parse a string in Sorbet format into a dictionary.
///
/// The format follows these rules:
/// - Each key-value pair is on a separate line with the format "key => value"
/// - Multi-line values use continuation lines starting with ">"
/// - Empty lines are ignored
/// - Whitespace around keys and values is trimmed
///
/// ## Examples
///
/// ```
/// sorbet.parse("key => value")
/// // Returns a dictionary with {"key": "value"}
///
/// sorbet.parse("key => first line\n> second line")
/// // Returns a dictionary with {"key": "first line\nsecond line"}
/// ```
///
pub fn parse(contents: String) -> dict.Dict(String, String) {
  let lines = string.split(contents, "\n")

  let initial_state = #(dict.new(), None, "")

  let #(map, current_key, current_value) =
    list.fold(lines, initial_state, fn(state, line) {
      let #(map, current_key, current_value) = state

      case string.contains(line, "=>") {
        True -> {
          let map = case current_key {
            Some(key) -> dict.insert(map, key, string.trim(current_value))
            None -> map
          }

          // Process the new key-value pair
          let parts = string.split(line, "=>")
          case parts {
            [key, value] -> {
              let key = string.trim(key)
              let value = string.trim(value)
              #(map, Some(key), value)
            }
            _ -> {
              utility.print_error(
                utility.Syntax,
                "Syntax error! Expected [key] => [value] at: " <> line,
              )
              #(map, None, "")
            }
          }
        }
        False -> {
          let trimmed = string.trim(line)
          case string.starts_with(trimmed, ">") {
            True -> {
              case current_key {
                Some(_) -> {
                  let continuation =
                    string.trim(string.slice(trimmed, 1, string.length(trimmed)))
                  let new_value = case string.length(current_value) {
                    0 -> continuation
                    _ -> current_value <> "\n" <> continuation
                  }
                  #(map, current_key, new_value)
                }
                None -> {
                  utility.print_error(
                    utility.SyntaxException,
                    "Continuation line without a key at: " <> line,
                  )
                  state
                }
              }
            }
            False -> state
          }
        }
      }
    })

  let map = case current_key {
    Some(key) -> dict.insert(map, key, string.trim(current_value))
    None -> map
  }

  map
}

/// Format a key and value into the sorbet format.
/// If the value contains newlines, they will be formatted as continuation lines.
///
/// ## Examples
///
/// ```
/// sorbet.format_key_value("key", "value")
/// // Returns "key => value"
///
/// sorbet.format_key_value("key", "line1\nline2")
/// // Returns "key => line1\n> line2"
/// ```
///
pub fn format_key_value(key: String, value: String) -> String {
  case string.contains(value, "\n") {
    False -> key <> " => " <> value
    True -> {
      let lines = string.split(value, "\n")
      case lines {
        [] -> key <> " => "
        [first, ..rest] -> {
          let first_line = key <> " => " <> first
          let continuation_lines = list.map(rest, fn(line) { "> " <> line })

          string.join([first_line, ..continuation_lines], "\n")
        }
      }
    }
  }
}

/// Format a dictionary into the sorbet format.
///
/// Takes a dictionary of string keys and string values and converts it
/// to a string in Sorbet format. Multi-line values are properly formatted
/// with continuation lines.
///
/// ## Example
///
/// ```
/// sorbet.format_dict(dict.from_list([
///   #("key1", "value1"),
///   #("key2", "line1\nline2")
/// ]))
/// // Returns "key1 => value1\nkey2 => line1\n> line2"
/// ```
///
pub fn format_dict(map: dict.Dict(String, String)) -> String {
  let formatted_entries =
    dict.to_list(map)
    |> list.map(fn(entry) {
      let #(key, value) = entry
      format_key_value(key, value)
    })

  string.join(formatted_entries, "\n")
}
