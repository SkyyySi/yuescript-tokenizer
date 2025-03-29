# YueScript-Tokenizer

This library provides the ability to tokenize a piece of YueScript source
code, without the need for the input to be fully syntactically or semantically
valid.

All pieces of the given source code will be preserved, including comments. If
you want something to be ignored / discarded, you need to do so manually.

## Installation

Simply clone this repository and `require()` / `import` it.

## Usage

For details on the usage, please have a look at the `/types` directory, which
documents the public API in the form of LuaCATS type annotations.

## License

This project is licensed under the terms of the Zero-Clause BSD license, a copy
of wich may be found in `/LICENSE.md` or at
[opensource.org](https://opensource.org/license/0BSD).
