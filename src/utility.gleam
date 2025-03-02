//// Utility
//// This is the utility module for Sorbet.
//// It contains error handling types and functions for the Sorbet parser.

import gleam/io

/// Represents different types of errors that can occur during Sorbet parsing.
///
/// ## Variants
/// - `Syntax`: Represents basic syntax errors in the input format
/// - `SyntaxException`: Represents more severe syntax exceptions, such as
///   continuation lines without a preceding key-value pair
///
pub type SorbetError {
  Syntax
  SyntaxException
}

/// Prints a formatted error message to the console.
///
/// Takes an error type and a message, formats them together with appropriate
/// prefixes, and outputs the result to standard output.
///
/// ## Parameters
/// - `error`: The type of error that occurred
/// - `message`: A descriptive message explaining the error
///
/// ## Returns
/// - `Nil`: This function performs a side effect and doesn't return a value
///
/// ## Example
///
/// ```
/// print_error(Syntax, "Invalid key-value format")
/// // Prints: "Syntax Error: Invalid key-value format"
/// ```
///
pub fn print_error(error: SorbetError, message: String) -> Nil {
  let error_type = case error {
    Syntax -> "Syntax Error"
    SyntaxException -> "Syntax Exception"
  }

  io.println(error_type <> ": " <> message)
}
