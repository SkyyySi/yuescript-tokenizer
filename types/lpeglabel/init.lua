---@meta lpeglabel
--- SPDX-License-Identifier: 0BSD

---@class lpeglabel.Pattern : userdata, lpeglabel
---@operator add(lpeglabel.Pattern): lpeglabel.Pattern # Matches `self` or `other` (ordered choice)
---@operator sub(lpeglabel.Pattern): lpeglabel.Pattern # Matches `self` if `other` does *not* match
---@operator mul(lpeglabel.Pattern): lpeglabel.Pattern # 
---@operator div(lpeglabel.Pattern): lpeglabel.Pattern # 
---@operator pow(integer): lpeglabel.Pattern # Matches at least `n` repetitions of `self`
---@operator unm: lpeglabel.Pattern # Equivalent to `("" - self)`
---@operator len: lpeglabel.Pattern # Matches `self` but consumes no input
local Pattern = {}

---@param subject string
---@param init? unknown
---@return any ast
---@return nil error
---@return nil error_position
---@overload fun(self: self, subject: string, init?: unknown): nil, string, integer
function Pattern:match(subject, init) end

--- MARK: Introduction

--- LPeg is a pattern-matching library for Lua, based on
--- (Parsing Expression Grammars)[https://bford.info/packrat/]
--- (PEGs). This text is a reference manual for the library. For those
--- starting with LPeg,
--- (Mastering LPeg)[https://www.inf.puc-rio.br/~roberto/docs/lpeg-primer.pdf]
--- presents a good tutorial. For a more
--- formal treatment of LPeg, as well as some discussion about its
--- implementation, see
--- (A Text Pattern-Matching Tool based on Parsing Expression Grammars)[https://www.inf.puc-rio.br/~roberto/docs/peg.pdf]
--- . You may also be interested in my talk about LPeg given at the III
--- Lua Workshop.
---
--- Following the Snobol tradition, LPeg defines patterns as first-class
--- objects. That is, patterns are regular Lua values (represented by userdata).
--- The library offers several functions to create and compose patterns. With
--- the use of metamethods, several of these functions are provided as infix or
--- prefix operators. On the one hand, the result is usually much more verbose
--- than the typical encoding of patterns using the so called regular
--- expressions (which typically are not regular expressions in the formal
--- sense). On the other hand, first-class patterns allow much better
--- documentation (as it is easy to comment the code, to break complex
--- definitions in smaller parts, etc.) and are extensible, as we can define new
--- functions to create and compose patterns. 
---
--- For a quick glance of the library, the following table summarizes its basic
--- operations for creating patterns:
---
--- | Operator              | Description                                                  |
--- | --------------------- | ------------------------------------------------------------ |
--- | `lpeg.P(string)`      | Matches string literally                                     |
--- | `lpeg.P(n)`           | Matches exactly n characters                                 |
--- | `lpeg.S(string)`      | Matches any character in string (Set)                        |
--- | `lpeg.R("xy")`        | Matches any character between x and y (Range)                |
--- | `lpeg.utfR(cp1, cp2)` | Matches an UTF-8 code point between cp1 and cp2              |
--- | `patt^n`              | Matches at least n repetitions of patt                       |
--- | `patt^-n`             | Matches at most n repetitions of patt                        |
--- | `patt1 * patt2`       | Matches patt1 followed by patt2                              |
--- | `patt1 + patt2`       | Matches patt1 or patt2 (ordered choice)                      |
--- | `patt1 - patt2`       | Matches patt1 if patt2 does not match                        |
--- | `-patt`               | Equivalent to ("" - patt)                                    |
--- | `#patt`               | Matches patt but consumes no input                           |
--- | `lpeg.B(patt)`        | Matches patt behind the current position, consuming no input |
---
--- As a very simple example, `lpeg.R("09")^1` creates a pattern that matches a
--- non-empty sequence of digits. As a not so simple example, `-lpeg.P(1)`
--- (which can be written as `lpeg.P(-1)`, or simply `-1` for operations
--- expecting a pattern) matches an empty string only if it cannot match a
--- single character; so, it succeeds only at the end of the subject.
---
--- LPeg also offers the
--- [re module](https://www.inf.puc-rio.br/~roberto/lpeg/re.html)
--- , which implements patterns following a regular-expression style (e.g.,
--- `[09]+`). (This module is 270 lines of Lua code, and of course it uses LPeg
--- to parse regular expressions and translate them to regular LPeg patterns.)
---@class lpeglabel
---@field version string The current version of LPeg.
local lpeg = {}

--- MARK: Functions

--- The matching function. It attempts to match the given pattern against the
--- subject string. If the match succeeds, returns the index in the subject of
--- the first character after the match, or the
--- [captured values](https://www.inf.puc-rio.br/~roberto/lpeg/#captures)
--- (if the pattern captured any value).
--- 
--- An optional numeric argument `init` makes the match start at that position
--- in the subject string. As in the Lua standard libraries, a negative value
--- counts from the end.
--- 
--- Unlike typical pattern-matching functions, `match` works only in anchored
--- mode; that is, it tries to match the pattern with a prefix of the given
--- subject string (at position `init`), not with an arbitrary substring of the
--- subject. So, if we want to find a pattern anywhere in a string, we must
--- either write a loop in Lua or write a pattern that matches anywhere. This
--- second approach is easy and quite efficient; see
--- [examples](https://www.inf.puc-rio.br/~roberto/lpeg/#ex)
--- .
---@param pattern string
---@return lpeglabel.Pattern?
function lpeg.match(pattern, subject, init) end

--- If the given `value` is a pattern, returns the string `"pattern"`. Otherwise
--- returns `nil`.
---@param value lpeglabel.Pattern
---@return "pattern"
---@overload fun(value: any): nil
function lpeg.type(value) end

--- Sets a limit for the size of the backtrack stack used by LPeg to track calls
--- and choices. (The default limit is 400.) Most well-written patterns need
--- little backtrack levels and therefore you seldom need to change this limit;
--- before changing it you should try to rewrite your pattern to avoid the need
--- for extra space. Nevertheless, a few useful patterns may overflow. Also,
--- with recursive grammars, subjects with deep recursion may also need larger
--- limits.
---@param max integer Default: `400`
function lpeg.setmaxstack(max) end

--- MARK: Basic Constructions

--- The following operations build patterns. All operations that expect a
--- pattern as an argument may receive also strings, tables, numbers, booleans,
--- or functions, which are translated to patterns according to the rules of
--- function
--- [`lpeg.P`](https://www.inf.puc-rio.br/~roberto/lpeg/#op-p)
--- .

--- Converts the given `value` into a proper pattern, according to the following
--- rules:
---
--- - If the argument is a pattern, it is returned unmodified.
--- - If the argument is a string, it is translated to a pattern that matches
---   the string literally.
--- - If the argument is a non-negative number `n`, the result is a pattern that
---   matches exactly `n` characters.
--- - If the argument is a negative number `-n`, the result is a pattern that
---   succeeds only if the input string has less than `n` characters left:
---   `lpeg.P(-n)` is equivalent to `-lpeg.P(n)` (see the
---   [unary minus operation](https://www.inf.puc-rio.br/~roberto/lpeg/#op-unm)
---   ).
--- - If the argument is a boolean, the result is a pattern that always succeeds
---   or always fails (according to the boolean value), without consuming any
---   input.
--- - If the argument is a table, it is interpreted as a grammar (see
---   [Grammars](https://www.inf.puc-rio.br/~roberto/lpeg/#grammar)
---   ).
--- - If the argument is a function, returns a pattern equivalent to a
---   [match-time capture](https://www.inf.puc-rio.br/~roberto/lpeg/#matchtime)
---   over the empty string.
---@param pattern lpeglabel.Pattern
---@return lpeglabel.Pattern
---@overload fun(expression: string): lpeglabel.Pattern
---@overload fun(char_count: integer): lpeglabel.Pattern
---@overload fun(succeeds: boolean): lpeglabel.Pattern
---@overload fun(grammar: lpeglabel.Grammar): lpeglabel.Pattern
---@overload fun(func: function): lpeglabel.Pattern
function lpeg.P(pattern) end

--- Returns a pattern that matches only if the input string at the current
--- position is preceded by patt. Pattern patt must match only strings with some
--- fixed length, and it cannot contain captures.
---
--- Like the
--- [and predicate](https://www.inf.puc-rio.br/~roberto/lpeg/#op-len)
--- , this pattern never consumes any input,
--- independently of success or failure.
---@param pattern lpeglabel.Pattern
---@return lpeglabel.Pattern
function lpeg.B(pattern) end

--- Returns a pattern that matches any single character belonging to one of the
--- given *ranges*. Each range is a string *xy* of length 2, representing all
--- characters with code between the codes of *x* and *y* (both inclusive).
---
--- As an example, the pattern `lpeg.R("09")` matches any digit, and
--- `lpeg.R("az", "AZ")` matches any ASCII letter. 
---@param range string
---@param ... string
---@return lpeglabel.Pattern
function lpeg.R(range, ...) end

--- Returns a pattern that matches any single character that appears in the
--- given string. (The `S` stands for *Set*.)
---
--- As an example, the pattern `lpeg.S("+-*/")` matches any arithmetic operator.
---
--- Note that, if `set` is a character (that is, a string of length 1), then
--- `lpeg.P(s)` is equivalent to `lpeg.S(s)` which is equivalent to
--- `lpeg.R(s..s)`. Note also that both `lpeg.S("")` and `lpeg.R()` are patterns
--- that always fail.
---@param set string
---@return lpeglabel.Pattern
function lpeg.S(set) end

--- Returns a pattern that matches a valid UTF-8 byte sequence representing a
--- code point in the range `[cp1, cp2]`. The range is limited by the natural
--- Unicode limit of `0x10FFFF`, but may include surrogates.
---@param cp1 integer
---@param cp2 integer
---@return lpeglabel.Pattern
function lpeg.utfR(cp1, cp2) end

--- This operation creates a non-terminal (a *variable*) for a grammar. The
--- created non-terminal refers to the rule indexed by `name` in the enclosing
--- grammar. (See
--- [Grammars](https://www.inf.puc-rio.br/~roberto/lpeg/#grammar)
--- for details.)
---@param name string
---@return lpeglabel.Pattern
function lpeg.V(name) end

---@class lpeglabel.locale
---@field alnum lpeglabel.Pattern
---@field alpha lpeglabel.Pattern
---@field cntrl lpeglabel.Pattern
---@field digit lpeglabel.Pattern
---@field graph lpeglabel.Pattern
---@field lower lpeglabel.Pattern
---@field print lpeglabel.Pattern
---@field punct lpeglabel.Pattern
---@field space lpeglabel.Pattern
---@field upper lpeglabel.Pattern
---@field xdigit lpeglabel.Pattern

--- Returns a table with patterns for matching some character classes according
--- to the current locale. The table has fields named `alnum`, `alpha`, `cntrl`,
--- `digit`, `graph`, `lower`, `print`, `punct`, `space`, `upper`, and
--- `xdigit`, each one containing a correspondent pattern. Each pattern matches
--- any single character that belongs to its class.
---
--- If called with an argument `table`, then it creates those fields inside the
--- given table and returns that table.
---@return lpeglabel.locale
---@overload fun(table: table): table: lpeglabel.locale
function lpeg.locale() end

--- MARK: Grammars

--- With the use of Lua variables, it is possible to define patterns
--- incrementally, with each new pattern using previously defined ones. 
--- However, this technique does not allow the definition of recursive patterns.
--- For recursive patterns, we need real grammars.
---
--- LPeg represents grammars with tables, where each entry is a rule.
---
--- The call `lpeg.V(name)` creates a pattern that represents the nonterminal
--- (or variable) with index `name` in a grammar. Because the grammar still does
--- not exist when this function is evaluated, the result is an open reference
--- to the respective rule.
---
--- A table is *fixed* when it is converted to a pattern (either by calling
--- `lpeg.P` or by using it wherein a pattern is expected). Then every open
--- reference created by `lpeg.V(name)` is corrected to refer to the rule
--- indexed by `name` in the table.
---
--- When a table is fixed, the result is a pattern that matches its *initial
--- rule*. The entry with index `1` in the table defines its initial rule. If
--- that entry is a string, it is assumed to be the name of the initial rule.
--- Otherwise, LPeg assumes that the entry `1` itself is the initial rule.
---
--- As an example, the following grammar matches strings of a's and b's that
--- have the same number of a's and b's: 
---
--- ```lua
--- equalcount = lpeg.P {
--- 	"S",   -- initial rule name
--- 	S = "a" * lpeg.V"B" + "b" * lpeg.V"A" + "",
--- 	A = "a" * lpeg.V"S" + "b" * lpeg.V"A" * lpeg.V"A",
--- 	B = "b" * lpeg.V"S" + "a" * lpeg.V"B" * lpeg.V"B",
--- } * -1
--- ```
---
--- It is equivalent to the following grammar in standard PEG notation:
---
--- ```peg
--- 	S <- 'a' B / 'b' A / ''
--- 	A <- 'a' S / 'b' A A
--- 	B <- 'b' S / 'a' B B
--- ```
---@class lpeglabel.Grammar
---@field [1] string
---@field [string] lpeglabel.Pattern

--- MARK: Captures

--- A capture is a pattern that produces values (the so called *semantic
--- information*) according to what it matches. LPeg offers several kinds of
--- captures, which produces values based on matches and combine these values
--- to produce new values. Each capture may produce zero or more values.
---
--- The following table summarizes the basic captures:
--- 
--- | Operation                  | What it Produces                                                                                      |
--- | -------------------------- | ----------------------------------------------------------------------------------------------------- |
--- | `lpeg.C(patt)`             | the match for patt plus all captures made by patt                                                     |
--- | `lpeg.Carg(n)`             | the value of the nth extra argument to lpeg.match (matches the empty string)                          |
--- | `lpeg.Cb(key)`             | the values produced by the previous group capture named key (matches the empty  string)               |
--- | `lpeg.Cc(values)`          | the given values (matches the empty string)                                                           |
--- | `lpeg.Cf(patt, func)`      | folding capture (deprecated)                                                                          |
--- | `lpeg.Cg(patt [, key])`    | the values produced by patt, optionally tagged with key                                               |
--- | `lpeg.Cp()`                | the current position (matches the empty string)                                                       |
--- | `lpeg.Cs(patt)`            | the match for patt with the values from nested captures replacing their  matches                      |
--- | `lpeg.Ct(patt)`            | a table with all captures from patt                                                                   |
--- | `patt / string`            | string, with some marks replaced by captures of patt                                                  |
--- | `patt / number`            | the n-th value captured by patt, or no value when number is zero.                                     |
--- | `patt / table`             | table[c], where c is the (first) capture of patt                                                      |
--- | `patt / function`          | the returns of function applied to the captures of patt                                               |
--- | `patt % function`          | produces no value; it accummulates the captures from patt into the previous  capture through function |
--- | `lpeg.Cmt(patt, function)` | the returns of function applied to the captures of patt; the  application is done at match time       |
---
--- A capture pattern produces its values only when it succeeds. For instance,
--- the pattern `lpeg.C(lpeg.P"a"^-1)` produces the empty string when there is
--- no `"a"` (because the pattern `"a"?` succeeds), while the pattern
--- `lpeg.C("a")^-1` does not produce any value when there is no `"a"` (because
--- the pattern `"a"` fails). A pattern inside a loop or inside a recursive
--- structure produces values for each match.
---
--- Usually, LPeg does not specify when, if, or how many times it evaluates its
--- captures. Therefore, captures should avoid side effects. As an example,
--- LPeg may or may not call func in the pattern `lpeg.P"a" / func / 0`, given
--- that the
--- ["division" by 0](https://www.inf.puc-rio.br/~roberto/lpeg/#cap-num)
--- instructs LPeg to throw away the results from the pattern. Similarly, a
--- capture nested inside a
--- [named group](https://www.inf.puc-rio.br/~roberto/lpeg/#cap-g)
--- may be evaluated only when that group is referred in a
--- [back capture](https://www.inf.puc-rio.br/~roberto/lpeg/#cap-b)
--- ; if there are multiple back captures, the group may be evaluated multiple
--- times.
---
--- Moreover, captures cannot affect the way a pattern matches a subject. The
--- only exception to this rule is the so-called match-time capture. When a
--- match-time capture matches, it forces the immediate evaluation of all its
--- nested captures and then calls its corresponding function, which defines
--- whether the match succeeds and also what values are produced. 

---@alias lpeglabel.Capturable lpeglabel.Pattern | lpeglabel.Grammar | string | number | boolean | function

--- Creates a *simple capture*, which captures the substring of the subject
--- that matches `pattern`. The captured value is a string. If `pattern` has
--- other captures, their values are returned after this one.
---@param pattern lpeglabel.Capturable
---@return lpeglabel.Pattern
function lpeg.C(pattern) end

--- Creates an *argument capture*. This pattern matches the empty string and
--- produces the value given as the `number`'th extra argument given in the
--- call to `lpeg.match`.
---@param number integer
---@return lpeglabel.Pattern
function lpeg.Carg(number) end

--- Creates a *back capture*. This pattern matches the empty string and
--- produces the values produced by the *most recent*
--- [group capture](https://www.inf.puc-rio.br/~roberto/lpeg/#cap-g)
--- named `key` (where `key` can be any Lua value).
---
--- *Most recent* means the last *completed outermost* group capture with the
--- given key. A *complete* capture means that the entire pattern corresponding
--- to the capture has matched; in other words, the back capture is not nested
--- inside the group. An *outermost* capture means that the capture is not
--- inside another complete capture that does not contain the back capture
--- itself.
---
--- In the same way that LPeg does not specify when it evaluates captures, it
--- does not specify whether it reuses values previously produced by the group
--- or re-evaluates them.
---@param key string
---@return lpeglabel.Pattern
function lpeg.Cb(key) end

--- Creates a *constant capture*. This pattern matches the empty string and
--- produces all given values as its captured values.
---@param value any
---@param ... any
---@return lpeglabel.Pattern
function lpeg.Cc(value, ...) end

--- Creates a *fold capture*. ~~This construction is deprecated; use an accumulator pattern instead. In general, a fold like lpeg.Cf(p1 * p2^0, func) can be translated to (p1 * (p2 % func)^0).~~ This pattern is only deprecated in lpeg, but not in lpeglabel.
---@param pattern any
---@param func fun(...: any): ...: any
---@return lpeglabel.Pattern
function lpeg.Cf(pattern, func) end

--- Creates a *group capture*. It groups all values returned by `pattern` into
--- a single capture. The group may be anonymous (if no key is given) or named
--- with the given key (which can be any non-nil Lua value).
---
--- An anonymous group serves to join values from several captures into a
--- single capture. A named group has a different behavior. In most situations,
--- a named group returns no values at all. Its values are only relevant for a
--- following
--- [back capture](https://www.inf.puc-rio.br/~roberto/lpeg/#cap-b)
--- or when used inside a
--- [table capture](https://www.inf.puc-rio.br/~roberto/lpeg/#cap-t)
--- .
---@param pattern any
---@param key any
---@return lpeglabel.Pattern
function lpeg.Cg(pattern, key) end

--- Creates a *position capture*. It matches the empty string and captures the
--- position in the subject where the match occurs. The captured value is a
--- number.
---@return lpeglabel.Pattern
function lpeg.Cp() end

--- Creates a *substitution capture*, which captures the substring of the
--- subject that matches `pattern`, with *substitutions*. For any capture
--- inside `pattern` with a value, the substring that matched the capture is
--- replaced by the capture value (which should be a string). The final
--- captured value is the string resulting from all replacements.
---@param pattern lpeglabel.Capturable
---@return lpeglabel.Pattern
function lpeg.Cs(pattern) end

--- Creates a *table capture*. This capture returns a table with all values
--- from all anonymous captures made by `pattern` inside this table in
--- successive integer keys, starting at 1. Moreover, for each named capture
--- group created by `pattern`, the first value of the group is put into the
--- table with the group key as its key. The captured value is only the table.
---@param pattern lpeglabel.Capturable
---@return lpeglabel.Pattern
function lpeg.Ct(pattern) end

--- Creates a *match-time capture*. Unlike all other captures, this one is
--- evaluated immediately when a match occurs (even if it is part of a larger
--- pattern that fails later). It forces the immediate evaluation of all its
--- nested captures and then calls `func`.
---
--- The given function gets as arguments the entire subject, the current
--- position (after the match of patt), plus any capture values produced by
--- patt.
---
--- The first value returned by `func` defines how the match happens. If the
--- call returns a number, the match succeeds and the returned number becomes
--- the new current position. (The returned number must be in the range
--- `[current_position, len(subject) + current_position].`) If the call returns
--- `true`, the match succeeds without consuming any input. (So, to return
--- `true` is equivalent to return `current_position`.) If the call returns
--- `false`, `nil`, or no value, the match fails.
---
--- Any extra values returned by the function become the values produced by the capture.
---@param pattern lpeglabel.Capturable
---@param func fun(subject: string, current_position: integer, ...: any): captured_values: any
---@return lpeglabel.Pattern
function lpeg.Cmt(pattern, func) end

--- Returns a pattern that throws the label `label`, which can be an integer or
--- a string.
--- 
--- When a label is thrown, the current subject position is used to set
--- **errpos**, no matter whether it is the fartherst failure position or not.
--- 
--- In case the PEG grammar has a rule `label`, after a label is thrown this
--- rule will be used as a recovery rule, otherwise the whole matching fails.
--- 
--- The recovery rule will try to match the input from the subject position
--- where `label` was thrown. In case the matching of the recovery rule
--- succeeds, the regular matching is resumed. Otherwise, the result of the
--- recovery rule is the matching result.
--- 
--- When we have a predicate such as `-p` or `#p` and a label `label` is thrown
--- during the matching of `p`, this causes the failure of `p`, but does not
--- propagate `label`, or calls its associated recovery rule.
---@param label string
---@return lpeglabel.Pattern
function lpeg.T(label) end

--- This function is undocumented; its API, purpose and behaviour are unknown.
function lpeg.ptree() end

--- This function is undocumented; its API, purpose and behaviour are unknown.
function lpeg.pcode() end

---@class lpeglabel.re
---@field find fun(subject, pattern, max_matches)
---@field match fun(subject, pattern, max_matches)
---@field updatelocale fun()
---@field gsub fun(subject, pattern, replacement)
---@field compile fun(pattern, definitions)
---@field calcline fun(subject, index)
local re = {}
