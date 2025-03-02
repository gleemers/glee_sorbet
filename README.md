# sorbet

[![Package Version](https://img.shields.io/hexpm/v/sorbet)](https://hex.pm/packages/sorbet)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/sorbet/)

A simple key-value configuration format parser and formatter for Gleam with support for multi-line values.

## Installation

```sh
gleam add sorbet@1
```

## Usage

### Parsing Sorbet Format

```gleam
import sorbet
import gleam/io

pub fn main() {
  // Simple key-value pairs
  let config = "name => Sorbet\nversion => 1.0.0"
  let parsed = sorbet.parse(config)
  
  // Access values
  io.debug(parsed) // Dict{"name": "Sorbet", "version": "1.0.0"}
  
  // Multi-line values
  let multi_line = "description => A configuration format\n> with support for\n> multi-line values"
  let parsed_multi = sorbet.parse(multi_line)
  
  // The multi-line value is joined with newlines
  io.debug(parsed_multi) // Dict{"description": "A configuration format\nwith support for\nmulti-line values"}
}
```

### Formatting to Sorbet Format

```gleam
import sorbet
import gleam/dict
import gleam/io

pub fn main() {
  // Format a single key-value pair
  let formatted = sorbet.format_key_value("name", "Sorbet")
  io.println(formatted) // Prints: name => Sorbet
  
  // Format a multi-line value
  let multi_line = sorbet.format_key_value(
    "description", 
    "A configuration format\nwith support for\nmulti-line values"
  )
  io.println(multi_line)
  // Prints:
  // description => A configuration format
  // > with support for
  // > multi-line values
  
  // Format a dictionary to Sorbet format
  let config = dict.from_list([
    #("name", "Sorbet"),
    #("version", "1.0.0"),
    #("description", "A simple config format")
  ])
  
  let formatted_dict = sorbet.format_dict(config)
  io.println(formatted_dict)
  // Prints something like:
  // name => Sorbet
  // version => 1.0.0
  // description => A simple config format
}
```

## Sorbet Format

Sorbet is a simple key-value configuration format with the following rules:
- Each key-value pair is on a separate line with the format `key => value`
- Multi-line values use continuation lines starting with `>`
- Empty lines are ignored
- Whitespace around keys and values is trimmed

Example:
```
# This is a Sorbet configuration file
name => My Project
description => This is a multi-line
> description for my project
> that spans multiple lines
version => 1.0.0
```

Further documentation can be found at <https://hexdocs.pm/sorbet>.

## Development

```sh
gleam test  # Run the tests
```
