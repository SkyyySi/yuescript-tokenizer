---@meta yuescript-tokenizer

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
_M.Token = setmetatable({
	---@param self   yuescript-tokenizer.Token
	---@param name   string
	---@param pos    integer
	---@param endpos integer
	---@param value  string
	__init = function(self, name, pos, endpos, value) end,
	__base = Token_base,
	__name = "Token",
}, {
	__index = Token_base,
	---@param cls yuescript-tokenizer.Token.__class
	---@param ... unknown
	__call  = function(cls, ...) end,
})

---@generic T
---@param func_name string
---@param arguments [integer, string, `T` | type, T | any][]
function _M.check_arguments(func_name, arguments) end

---@param source_code string
---@param file_name?  string
---@return Token[] | nil    tokens
---@return nil     | string error_message
---@return nil     | string traceback
---@nodiscard
function _M.try_tokenize() end

---@param source_code string
---@param file_name?  string
---@return Token[] tokens
---@nodiscard
function _M.tokenize() end

---@param tokens Token[]
function _M.visualize(tokens) end

---@param argv? string[]
function _M.main(argv) end

return _M
