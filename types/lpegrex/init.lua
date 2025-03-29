---@meta lpegrex
--- SPDX-License-Identifier: 0BSD

local lpegrex = {}

---@param subject string
---@param position integer
---@return integer
function lpegrex.calcline(subject, position) end

---@param subject string
---@param pattern lpeglabel.Pattern | string
---@param init unknown | nil
---@return any
function lpegrex.find(subject, pattern, init) end

---@param subject string
---@param pattern lpeglabel.Pattern | string
---@param init unknown | nil
---@return any
function lpegrex.match(subject, pattern, init) end

function lpegrex.updatelocale() end

---@param subject string
---@param pattern lpeglabel.Pattern | string
---@param replacement string | function
---@return string
function lpegrex.gsub(subject, pattern, replacement) end

---@generic T : string
---@alias lpegrex.Node<T>
---| { tag: T, pos: integer, endpos: integer }

---@generic T : string
---@alias lpegrex.TagHandler<T>
---| string
---| false
---| fun(tag: T, node: lpegrex.Node<T>): lpegrex.Node<T>

---@class lpegrex.CompileOptionsTable
---@field tag? lpegrex.TagHandler<"tag">
---@field pos? lpegrex.TagHandler<"pos">
---@field endpos? lpegrex.TagHandler<"endpos">

---@class lpegrex.CompileExtraRulesTable
---@field __options? lpegrex.CompileOptionsTable
---@field [string]? (fun(...: unknown): (...: unknown | nil) | unknown)

---@param pattern string
---@param extra_rules? lpegrex.CompileExtraRulesTable
---@return lpeglabel.Pattern
function lpegrex.compile(pattern, extra_rules) end

return lpegrex
