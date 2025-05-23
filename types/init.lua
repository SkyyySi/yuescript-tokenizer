---@meta yuescript-tokenizer
--- SPDX-License-Identifier: 0BSD

---@class yuescript-tokenizer
---@field grammar   string
---@field tokenizer lpeglabel.Pattern
local _M = {}

---@alias yuescript-tokenizer.Token.name
---| "Comment"
---| "String"
---| "Symbol"
---| "Keyword"
---| "Number"
---| "Identifier"
---| "Whitespace"
---| "Unknown"

---@class yuescript-tokenizer.Token : yuescript-tokenizer.Token.__base
---@field name   yuescript-tokenizer.Token.name
---@field pos    integer
---@field endpos integer
---@field value  string
---@operator concat(any): string

---@class yuescript-tokenizer.Token.__base
---@field __class    yuescript-tokenizer.Token.__class
---@field __index    yuescript-tokenizer.Token.__base
---@field __tostring fun(self: yuescript-tokenizer.Token): string
---@field __repr     fun(self: yuescript-tokenizer.Token): string
---@field __pretty   fun(self: yuescript-tokenizer.Token): string
---@field __concat   fun(self: yuescript-tokenizer.Token, other: any): string
local Token_base = {}

---@class yuescript-tokenizer.Token.__class : yuescript-tokenizer.Token.__base
---@field __name "Token"
---@field __base yuescript-tokenizer.Token.__base
---@field __init fun(self: yuescript-tokenizer.Token, name: string, pos: integer, endpos: integer, value: string)
---@overload fun(name: string, pos: integer, endpos: integer, value: string): self: yuescript-tokenizer.Token
_M.Token = {}

---@generic T
---@param func_name string
---@param arguments [integer, string, `T` | type, T | any][]
function _M.check_arguments(func_name, arguments) end

---@param source_code string
---@param file_name?  string
---@return yuescript-tokenizer.Token[] tokens
---@nodiscard
function _M.tokenize(source_code, file_name) end

---@param tokens yuescript-tokenizer.Token[]
function _M.visualize(tokens) end

---@param argv? string[]
function _M.main(argv) end

return _M
