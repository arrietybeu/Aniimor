-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Lib\\protoc.lua

local string = string
local tonumber = tonumber
local setmetatable = setmetatable
local error = error
local ipairs = ipairs
local io = io
local table = table
local math = math
local assert = assert
local tostring = tostring
local type = type
local insert_tab = table.insert

local function meta(name, t)
	t = t or {}
	t.__name = name
	t.__index = t

	return t
end

local function default(t, k, def)
	local v = t[k]

	if not v then
		v = def or {}
		t[k] = v
	end

	return v
end

local Lexer = meta("Lexer")

do
	local escape = {
		f = "\f",
		r = "\r",
		t = "\t",
		a = "\a",
		n = "\n",
		b = "\b",
		v = "\v"
	}

	local function tohex(x)
		return string.byte(tonumber(x, 16))
	end

	local function todec(x)
		return string.byte(tonumber(x, 10))
	end

	local function toesc(x)
		return escape[x] or x
	end

	function Lexer.new(name, src)
		local self = {
			pos = 1,
			name = name,
			src = src
		}

		return setmetatable(self, Lexer)
	end

	function Lexer:__call(patt, pos)
		return self.src:match(patt, pos or self.pos)
	end

	function Lexer:test(patt)
		self:whitespace()

		local pos = self("^" .. patt .. "%s*()")

		if not pos then
			return false
		end

		self.pos = pos

		return true
	end

	function Lexer:expected(patt, name)
		if not self:test(patt) then
			return self:error((name or "'" .. patt .. "'") .. " expected")
		end

		return self
	end

	function Lexer:pos2loc(pos)
		local linenr = 1

		pos = pos or self.pos

		for start, stop in self.src:gmatch("()[^\n]*()\n?") do
			if start <= pos and pos <= stop then
				return linenr, pos - start + 1
			end

			linenr = linenr + 1
		end
	end

	function Lexer:error(fmt, ...)
		local ln, co = self:pos2loc()

		return error(("%s:%d:%d: " .. fmt):format(self.name, ln, co, ...))
	end

	function Lexer:opterror(opt, msg)
		if not opt then
			return self:error(msg)
		end

		return nil
	end

	function Lexer:whitespace()
		local pos, c = self("^%s*()(%/?)")

		self.pos = pos

		if c == "" then
			return self
		end

		return self:comment()
	end

	function Lexer:comment()
		local pos = self("^%/%/[^\n]*\n?()")

		if not pos and self("^%/%*") then
			pos = self("^%/%*.-%*%/()")

			if not pos then
				self:error("unfinished comment")
			end
		end

		if not pos then
			return self
		end

		self.pos = pos

		return self:whitespace()
	end

	function Lexer:line_end(opt)
		self:whitespace()

		local pos = self("^[%s;]*%s*()")

		if not pos then
			return self:opterror(opt, "';' expected")
		end

		self.pos = pos

		return pos
	end

	function Lexer:eof()
		self:whitespace()

		return self.pos > #self.src
	end

	function Lexer:keyword(kw, opt)
		self:whitespace()

		local ident, pos = self("^([%a_][%w_]*)%s*()")

		if not ident or ident ~= kw then
			return self:opterror(opt, "''" .. kw .. "\" expected")
		end

		self.pos = pos

		return kw
	end

	function Lexer:ident(name, opt)
		self:whitespace()

		local b, ident, pos = self("^()([%a_][%w_]*)%s*()")

		if not ident then
			return self:opterror(opt, (name or "name") .. " expected")
		end

		self.pos = pos

		return ident, b
	end

	function Lexer:full_ident(name, opt)
		self:whitespace()

		local b, ident, pos = self("^()([%a_][%w_.]*)%s*()")

		if not ident or ident:match("%.%.+") then
			return self:opterror(opt, (name or "name") .. " expected")
		end

		self.pos = pos

		return ident, b
	end

	function Lexer:integer(opt)
		self:whitespace()

		local ns, oct, hex, s, pos = self("^([+-]?)(0?)([xX]?)([0-9a-fA-F]+)%s*()")
		local n

		if oct == "0" and hex == "" then
			n = tonumber(s, 8)
		elseif oct == "" and hex == "" then
			n = tonumber(s, 10)
		elseif oct == "0" and hex ~= "" then
			n = tonumber(s, 16)
		end

		if not n then
			return self:opterror(opt, "integer expected")
		end

		self.pos = pos

		return ns == "-" and -n or n
	end

	function Lexer:number(opt)
		self:whitespace()

		if self:test("nan%f[%A]") then
			return 0 / 0
		elseif self:test("inf%f[%A]") then
			return 1 / 0
		end

		local ns, d1, s, d2, s2, pos = self("^([+-]?)(%.?)([0-9]+)(%.?)([0-9]*)()")

		if not ns then
			return self:opterror(opt, "floating-point number expected")
		end

		local es, pos2 = self("(^[eE][+-]?[0-9]+)%s*()", pos)

		if d1 == "." and d2 == "." then
			return self:error("malformed floating-point number")
		end

		self.pos = pos2 or pos

		local n = tonumber(d1 .. s .. d2 .. s2 .. (es or ""))

		return ns == "-" and -n or n
	end

	function Lexer:quote(opt)
		self:whitespace()

		local q, start = self("^([\"'])()")

		if not start then
			return self:opterror(opt, "string expected")
		end

		self.pos = start

		local patt = "()(\\?" .. q .. ")%s*()"

		while true do
			local stop, s, pos = self(patt)

			if not stop then
				self.pos = start - 1

				return self:error("unfinished string")
			end

			self.pos = pos

			if s == q then
				return self.src:sub(start, stop - 1):gsub("\\x(%x+)", tohex):gsub("\\(%d+)", todec):gsub("\\(.)", toesc)
			end
		end
	end

	function Lexer:constant(opt)
		local c = self:full_ident("constant", "opt") or self:number("opt") or self:quote("opt")

		if not c and not opt then
			return self:error("constant expected")
		end

		return c
	end

	function Lexer:option_name()
		local ident

		if self:test("%(") then
			ident = self:full_ident("option name")

			self:expected("%)")
		else
			ident = self:ident("option name")
		end

		while self:test("%.") do
			ident = ident .. "." .. self:ident()
		end

		return ident
	end

	function Lexer:type_name()
		if self:test("%.") then
			local id, pos = self:full_ident("type name")

			return "." .. id, pos
		else
			return self:full_ident("type name")
		end
	end
end

local Parser = meta("Parser")

Parser.typemap = {}
Parser.loaded = {}
Parser.paths = {
	"",
	"."
}
Parser.ReadFileHookFunc = nil

function Parser.new()
	local self = {}

	self.typemap = {}
	self.loaded = {}
	self.paths = {
		"",
		"."
	}

	return setmetatable(self, Parser)
end

function Parser:error(msg)
	return self.lex:error(msg)
end

function Parser:addpath(path)
	insert_tab(self.paths, path)
end

function Parser:parsefile(name)
	local info = self.loaded[name]

	if info then
		return info
	end

	local errors = {}
	local err

	for _, path in ipairs(self.paths) do
		local fn = path ~= "" and path .. "/" .. name or name

		if self.ReadFileHookFunc ~= nil then
			local content = self.ReadFileHookFunc(fn)

			if content and string.len(content) > 0 then
				info = self:parse(content, name)

				return info
			end
		else
			local fh

			fh, err = io.open(fn)

			if fh then
				local content = fh:read("*a")

				if content then
					info = self:parse(content, name)

					fh:close()

					return info
				end
			end
		end

		insert_tab(errors, err or fn .. ": " .. "unknown error")
	end

	if self.import_fallback then
		info = self.import_fallback(name)
	end

	if not info then
		error("module load error: " .. name .. "\n\t" .. table.concat(errors, "\n\t"))
	end

	return info
end

do
	local labels = {
		optional = 1,
		repeated = 3,
		required = 2
	}
	local key_types = {
		string = 9,
		bool = 8,
		sfixed64 = 16,
		sfixed32 = 15,
		fixed64 = 6,
		fixed32 = 7,
		sint64 = 18,
		sint32 = 17,
		uint64 = 4,
		uint32 = 13,
		int64 = 3,
		int32 = 5
	}
	local com_types = {
		group = 10,
		enum = 14,
		message = 11
	}
	local types = {
		group = 10,
		bool = 8,
		sfixed64 = 16,
		sfixed32 = 15,
		fixed64 = 6,
		fixed32 = 7,
		sint64 = 18,
		sint32 = 17,
		uint64 = 4,
		uint32 = 13,
		int64 = 3,
		int32 = 5,
		string = 9,
		bytes = 12,
		float = 2,
		double = 1,
		enum = 14,
		message = 11
	}

	local function register_type(self, lex, tname, typ)
		if not tname:match("%.") then
			tname = self.prefix .. tname
		end

		if self.typemap[tname] then
			return
		end

		self.typemap[tname] = typ
	end

	local function type_info(lex, tname)
		local tenum = types[tname]

		if com_types[tname] then
			return lex:error("invalid type name: " .. tname)
		elseif tenum then
			tname = nil
		end

		return tenum, tname
	end

	local function map_info(lex)
		local keyt = lex:ident("key type")

		if not key_types[keyt] then
			return lex:error("invalid key type: " .. keyt)
		end

		local valt = lex:expected(","):type_name()
		local name = lex:expected(">"):ident()
		local ident = name:gsub("^%a", string.upper):gsub("_(%a)", string.upper) .. "Entry"
		local kt, ktn = type_info(lex, keyt)
		local vt, vtn = type_info(lex, valt)

		return name, types.message, ident, {
			name = ident,
			field = {
				{
					number = 1,
					name = "key",
					label = labels.optional,
					type = kt,
					type_name = ktn
				},
				{
					number = 2,
					name = "value",
					label = labels.optional,
					type = vt,
					type_name = vtn
				}
			},
			options = {
				map_entry = true
			}
		}
	end

	local function inline_option(lex, info)
		if lex:test("%[") then
			info = info or {}

			while true do
				local name = lex:option_name()
				local value = lex:expected("="):constant()

				info[name] = value

				if lex:test("%]") then
					return info
				end

				lex:expected(",")
			end
		end
	end

	local function field(self, lex, ident)
		local name, typ, type_name, map_entry

		if ident == "map" and lex:test("%<") then
			name, typ, type_name, map_entry = map_info(lex)
			self.locmap[map_entry.field[1]] = lex.pos
			self.locmap[map_entry.field[2]] = lex.pos

			register_type(self, lex, type_name, types.message)
		else
			typ, type_name = type_info(lex, ident)
			name = lex:ident()
		end

		local info = {
			name = name,
			number = lex:expected("="):integer(),
			label = ident == "map" and labels.repeated or labels.optional,
			type = typ,
			type_name = type_name
		}
		local options = inline_option(lex)

		if options then
			info.default_value, options.default = (tostring(options.default))
			info.json_name, options.json_name = options.json_name

			if options.packed and options.packed == "false" then
				options.packed = false
			end
		end

		info.options = options

		if info.number <= 0 then
			lex:error("invalid tag number: " .. info.number)
		end

		return info, map_entry
	end

	local function label_field(self, lex, ident)
		local label = labels[ident]
		local info, map_entry

		if not label then
			if self.syntax == "proto2" and ident ~= "map" then
				return lex:error("proto2 disallow missing label")
			end

			return field(self, lex, ident)
		end

		if label == labels.optional and self.syntax == "proto3" then
			return lex:error("proto3 disallow 'optional' label")
		end

		info, map_entry = field(self, lex, lex:type_name())
		info.label = label

		return info, map_entry
	end

	local toplevel = {}

	function toplevel:package(lex, info)
		local package = lex:full_ident("package name")

		lex:line_end()

		info.package = package
		self.prefix = "." .. package .. "."

		return self
	end

	function toplevel:import(lex, info)
		local mode = lex:ident("\"weak\" or \"public\"", "opt") or "public"

		if mode ~= "weak" and mode ~= "public" then
			return lex:error("\"weak or \"public\" expected")
		end

		local name = lex:quote()

		lex:line_end()

		local result = self:parsefile(name)

		if self.on_import then
			self.on_import(result)
		end

		local dep = default(info, "dependency")
		local index = #dep

		dep[index + 1] = name

		if mode == "public" then
			local it = default(info, "public_dependency")

			insert_tab(it, index)
		else
			local it = default(info, "weak_dependency")

			insert_tab(it, index)
		end
	end

	do
		local msg_body = {}

		function msg_body:message(lex, info)
			local nested_type = default(info, "nested_type")

			insert_tab(nested_type, toplevel.message(self, lex))

			return self
		end

		function msg_body:enum(lex, info)
			local nested_type = default(info, "enum_type")

			insert_tab(nested_type, toplevel.enum(self, lex))

			return self
		end

		function msg_body:extend(lex, info)
			local extension = default(info, "extension")
			local nested_type = default(info, "nested_type")
			local ft, mt = toplevel.extend(self, lex, {})

			for _, v in ipairs(ft) do
				insert_tab(extension, v)
			end

			for _, v in ipairs(mt) do
				insert_tab(nested_type, v)
			end

			return self
		end

		function msg_body:extensions(lex, info)
			local rt = default(info, "extension_range")

			repeat
				local start = lex:integer("field number range")
				local stop = math.floor(536870912)

				lex:keyword("to")

				if not lex:keyword("max", "opt") then
					stop = lex:integer("field number range end or 'max'")
				end

				insert_tab(rt, {
					start = start,
					["end"] = stop
				})
			until not lex:test(",")

			lex:line_end()

			return self
		end

		function msg_body:reserved(lex, info)
			if lex:test("%a") then
				local rt = default(info, "reserved_name")

				repeat
					insert_tab(rt, lex:ident("field name"))
				until not lex:test(",")
			else
				local rt = default(info, "reserved_range")
				local first = true

				repeat
					local start = lex:integer(first and "field name or number range" or "field number range")

					if lex:keyword("to", "opt") then
						local stop = lex:integer("field number range end")

						insert_tab(rt, {
							start = start,
							["end"] = stop
						})
					else
						insert_tab(rt, {
							start = start,
							["end"] = start
						})
					end

					first = false
				until not lex:test(",")
			end

			lex:line_end()

			return self
		end

		function msg_body:oneof(lex, info)
			local fs = default(info, "field")
			local ts = default(info, "nested_type")
			local ot = default(info, "oneof_decl")
			local index = #ot + 1
			local oneof = {
				name = lex:ident()
			}

			lex:expected("{")

			while not lex:test("}") do
				local ident = lex:type_name()

				if ident == "option" then
					toplevel.option(self, lex, oneof)
				else
					local f, t = field(self, lex, ident, "no_label")

					self.locmap[f] = lex.pos

					if t then
						insert_tab(ts, t)
					end

					f.oneof_index = index - 1

					insert_tab(fs, f)
				end

				lex:line_end("opt")
			end

			ot[index] = oneof
		end

		function toplevel:message(lex, info)
			local name = lex:ident("message name")
			local typ = {
				name = name
			}

			register_type(self, lex, name, types.message)

			local prefix = self.prefix

			self.prefix = prefix .. name .. "."

			lex:expected("{")

			while not lex:test("}") do
				local ident, pos = lex:type_name()
				local body_parser = msg_body[ident]

				if body_parser then
					body_parser(self, lex, typ)
				else
					local fs = default(typ, "field")
					local f, t = label_field(self, lex, ident)

					self.locmap[f] = pos

					insert_tab(fs, f)

					if t then
						local ts = default(typ, "nested_type")

						insert_tab(ts, t)
					end
				end

				lex:line_end("opt")
			end

			lex:line_end("opt")

			if info then
				info = default(info, "message_type")

				insert_tab(info, typ)
			end

			self.prefix = prefix

			return typ
		end

		function toplevel:enum(lex, info)
			local name = lex:ident("enum name")
			local enum = {
				name = name
			}

			register_type(self, lex, name, types.enum)
			lex:expected("{")

			while not lex:test("}") do
				local ident = lex:ident("enum constant name")

				if ident == "option" then
					toplevel.option(self, lex, default(enum, "options"))
				else
					local values = default(enum, "value")
					local number = lex:expected("="):integer()

					lex:line_end()
					insert_tab(values, {
						name = ident,
						number = number,
						options = inline_option(lex)
					})
				end

				lex:line_end("opt")
			end

			lex:line_end("opt")

			if info then
				info = default(info, "enum_type")

				insert_tab(info, enum)
			end

			return enum
		end

		function toplevel:option(lex, info)
			local ident = lex:option_name()

			lex:expected("=")

			local value = lex:constant()

			lex:line_end()

			local options = info and default(info, "options") or {}

			options[ident] = value

			return options, self
		end

		function toplevel:extend(lex, info)
			local name = lex:type_name()
			local ft = info and default(info, "extension") or {}
			local mt = info and default(info, "message_type") or {}

			lex:expected("{")

			while not lex:test("}") do
				local ident, pos = lex:type_name()
				local f, t = label_field(self, lex, ident)

				self.locmap[f] = pos
				f.extendee = name

				insert_tab(ft, f)
				insert_tab(mt, t)
				lex:line_end("opt")
			end

			return ft, mt
		end

		local svr_body = {}

		function svr_body:rpc(lex, info)
			local name, pos = lex:ident("rpc name")
			local rpc = {
				name = name
			}

			self.locmap[rpc] = pos

			local _, tn

			lex:expected("%(")

			rpc.client_streaming = lex:keyword("stream", "opt")
			_, tn = type_info(lex, lex:type_name())

			if not tn then
				return lex:error("rpc input type must by message")
			end

			rpc.input_type = tn

			lex:expected("%)"):expected("returns"):expected("%(")

			rpc.server_streaming = lex:keyword("stream", "opt")
			_, tn = type_info(lex, lex:type_name())

			if not tn then
				return lex:error("rpc output type must by message")
			end

			rpc.output_type = tn

			lex:expected("%)")

			if lex:test("{") then
				while not lex:test("}") do
					lex:line_end("opt")
					lex:keyword("option")
					toplevel.option(self, lex, default(rpc, "options"))
				end
			end

			lex:line_end("opt")

			local t = default(info, "method")

			insert_tab(t, rpc)
		end

		function svr_body.stream(_, lex)
			lex:error("stream not implement yet")
		end

		function toplevel:service(lex, info)
			local name = lex:ident("service name")
			local svr = {
				name = name
			}

			lex:expected("{")

			while not lex:test("}") do
				local ident = lex:type_name()
				local body_parser = svr_body[ident]

				if body_parser then
					body_parser(self, lex, svr)
				else
					return lex:error("expected 'rpc' or 'option' in service body")
				end

				lex:line_end("opt")
			end

			lex:line_end("opt")

			if info then
				info = default(info, "service")

				insert_tab(info, svr)
			end

			return svr
		end
	end

	local function make_context(self, lex)
		local ctx = {
			syntax = "proto2",
			prefix = ".",
			locmap = {},
			lex = lex,
			parser = self
		}

		ctx.loaded = self.loaded
		ctx.typemap = self.typemap
		ctx.paths = self.paths

		function ctx.import_fallback(import_name)
			if self.unknown_import == true then
				return true
			elseif type(self.unknown_import) == "string" then
				return import_name:match(self.unknown_import) and true or nil
			elseif self.unknown_import then
				return self:unknown_import(import_name)
			end
		end

		function ctx.type_fallback(type_name)
			if self.unknown_type == true then
				return true
			elseif type(self.unknown_type) == "string" then
				return type_name:match(self.unknown_type) and true
			elseif self.unknown_type then
				return self:unknown_type(type_name)
			end
		end

		function ctx.on_import(info)
			if self.on_import then
				return self.on_import(info)
			end
		end

		return setmetatable(ctx, Parser)
	end

	function Parser:parse(src, name)
		local loaded = self.loaded[name]

		if loaded then
			if loaded == true then
				error("loop loaded: " .. name)
			end

			return loaded
		end

		name = name or "<input>"
		self.loaded[name] = true

		local lex = Lexer.new(name, src)
		local info = {
			name = lex.name
		}
		local ctx = make_context(self, lex)
		local syntax = lex:keyword("syntax", "opt")

		if syntax then
			info.syntax = lex:expected("="):quote()
			ctx.syntax = info.syntax

			lex:line_end()
		end

		while not lex:eof() do
			local ident = lex:ident()
			local top_parser = toplevel[ident]

			if top_parser then
				top_parser(ctx, lex, info)
			else
				lex:error("unknown keyword '" .. ident .. "'")
			end

			lex:line_end("opt")
		end

		self.loaded[name] = name ~= "<input>" and info or nil

		return ctx:resolve(lex, info)
	end

	local function empty()
		return
	end

	local function iter(t, k)
		local v = t[k]

		if v then
			return ipairs(v)
		end

		return empty
	end

	local function check_dup(self, lex, typ, map, k, v)
		local old = map[v[k]]

		if old then
			local ln, co = lex:pos2loc(self.locmap[old])

			lex:error("%s '%s' exists, previous at %d:%d", typ, v[k], ln, co)
		end

		map[v[k]] = v
	end

	local function check_type(self, lex, tname)
		if tname:match("^%.") then
			local t = self.typemap[tname]

			if not t then
				return lex:error("unknown type '%s'", tname)
			end

			return t, tname
		end

		local prefix = self.prefix

		for i = #prefix + 1, 1, -1 do
			local op = prefix[i]

			prefix[i] = tname

			local tn = table.concat(prefix, ".", 1, i)

			prefix[i] = op

			local t = self.typemap[tn]

			if t then
				return t, tn
			end
		end

		local tn, t

		if self.type_fallback then
			tn, t = self.type_fallback(tname)
		end

		if tn then
			t = types[t or "message"]

			if tn == true then
				tn = "." .. tname
			end

			return t, tn
		end

		return lex:error("unknown type '%s'", tname)
	end

	local function check_field(self, lex, info)
		if info.extendee then
			local t, tn = check_type(self, lex, info.extendee)

			if t ~= types.message then
				lex:error("message type expected in extension")
			end

			info.extendee = tn
		end

		if info.type_name then
			local t, tn = check_type(self, lex, info.type_name)

			info.type = t
			info.type_name = tn
		end
	end

	local function check_enum(self, lex, info)
		local names, numbers = {}, {}

		for _, v in iter(info, "value") do
			lex.pos = self.locmap[v]

			check_dup(self, lex, "enum name", names, "name", v)

			if not info.options or not info.options.options or not info.options.options.allow_alias then
				check_dup(self, lex, "enum number", numbers, "number", v)
			end
		end
	end

	local function check_message(self, lex, info)
		insert_tab(self.prefix, info.name)

		local names, numbers = {}, {}

		for _, v in iter(info, "field") do
			lex.pos = assert(self.locmap[v])

			check_dup(self, lex, "field name", names, "name", v)
			check_dup(self, lex, "field number", numbers, "number", v)
			check_field(self, lex, v)
		end

		for _, v in iter(info, "nested_type") do
			check_message(self, lex, v)
		end

		for _, v in iter(info, "extension") do
			lex.pos = assert(self.locmap[v])

			check_field(self, lex, v)
		end

		self.prefix[#self.prefix] = nil
	end

	local function check_service(self, lex, info)
		local names = {}

		for _, v in iter(info, "method") do
			lex.pos = self.locmap[v]

			check_dup(self, lex, "rpc name", names, "name", v)

			local t, tn = check_type(self, lex, v.input_type)

			v.input_type = tn

			if t ~= types.message then
				lex:error("message type expected in parameter")
			end

			t, tn = check_type(self, lex, v.output_type)
			v.output_type = tn

			if t ~= types.message then
				lex:error("message type expected in return")
			end
		end
	end

	function Parser:resolve(lex, info)
		self.prefix = {
			"",
			info.package
		}

		for _, v in iter(info, "message_type") do
			check_message(self, lex, v)
		end

		for _, v in iter(info, "enum_type") do
			check_enum(self, lex, v)
		end

		for _, v in iter(info, "service") do
			check_service(self, lex, v)
		end

		for _, v in iter(info, "extension") do
			lex.pos = assert(self.locmap[v])

			check_field(self, lex, v)
		end

		self.prefix = nil

		return info
	end
end

local has_pb, pb = pcall(require, "pb")

if has_pb then
	local descriptor_pb = "\n\xF9#\n\x10descriptor.proto\x12\x0Fgoogle.protobuf\"G\n\x11FileDescript" .. "orSet\x122\n\x04file\x18\x01 \x03(\v2$.google.protobuf.FileDescriptorProto\"" .. "\xDB\x03\n\x13FileDescriptorProto\x12\f\n\x04name\x18\x01 \x01(\t\x12\x0F\n\apack" .. "age\x18\x02 \x01(\t\x12\x12\n\ndependency\x18\x03 \x03(\t\x12\x19\n\x11public_depend" .. "ency\x18\n \x03(\x05\x12\x17\n\x0Fweak_dependency\x18\v \x03(\x05\x126\n\fmessag" .. "e_type\x18\x04 \x03(\v2 .google.protobuf.DescriptorProto\x127\n\tenum_type" .. "\x18\x05 \x03(\v2$.google.protobuf.EnumDescriptorProto\x128\n\aservice\x18" .. "\x06 \x03(\v2'.google.protobuf.ServiceDescriptorProto\x128\n\textension" .. "\x18\a \x03(\v2%.google.protobuf.FieldDescriptorProto\x12-\n\aoptions\x18" .. "\b \x01(\v2\x1C.google.protobuf.FileOptions\x129\n\x10source_code_info\x18" .. "\t \x01(\v2\x1F.google.protobuf.SourceCodeInfo\x12\x0E\n\x06syntax\x18\f \x01(" .. "\t\"\xE4\x03\n\x0FDescriptorProto\x12\f\n\x04name\x18\x01 \x01(\t\x124\n\x05field" .. "\x18\x02 \x03(\v2%.google.protobuf.FieldDescriptorProto\x128\n\textension" .. "\x18\x06 \x03(\v2%.google.protobuf.FieldDescriptorProto\x125\n\vnested_ty" .. "pe\x18\x03 \x03(\v2 .google.protobuf.DescriptorProto\x127\n\tenum_type\x18" .. "\x04 \x03(\v2$.google.protobuf.EnumDescriptorProto\x12H\n\x0Fextension_rang" .. "e\x18\x05 \x03(\v2/.google.protobuf.DescriptorProto.ExtensionRange\x129\n" .. "\noneof_decl\x18\b \x03(\v2%.google.protobuf.OneofDescriptorProto\x120" .. "\n\aoptions\x18\a \x01(\v2\x1F.google.protobuf.MessageOptions\x1A,\n\x0EEx" .. "tensionRange\x12\r\n\x05start\x18\x01 \x01(\x05\x12\v\n\x03end\x18\x02 \x01(\x05\"\xA9\x05" .. "\n\x14FieldDescriptorProto\x12\f\n\x04name\x18\x01 \x01(\t\x12\x0E\n\x06number\x18" .. "\x03 \x01(\x05\x12:\n\x05label\x18\x04 \x01(\x0E2+.google.protobuf.FieldDescriptorPro" .. "to.Label\x128\n\x04type\x18\x05 \x01(\x0E2*.google.protobuf.FieldDescriptorPro" .. "to.Type\x12\x11\n\ttype_name\x18\x06 \x01(\t\x12\x10\n\bextendee\x18\x02 \x01(\t\x12" .. "\x15\n\rdefault_value\x18\a \x01(\t\x12\x13\n\voneof_index\x18\t \x01(\x05\x12." .. "\n\aoptions\x18\b \x01(\v2\x1D.google.protobuf.FieldOptions\"\xB6\x02\n\x04T" .. "ype\x12\x0F\n\vTYPE_DOUBLE\x10\x01\x12\x0E\n\nTYPE_FLOAT\x10\x02\x12\x0E\n\nTY" .. "PE_INT64\x10\x03\x12\x0F\n\vTYPE_UINT64\x10\x04\x12\x0E\n\nTYPE_INT32\x10\x05\x12" .. "\x10\n\fTYPE_FIXED64\x10\x06\x12\x10\n\fTYPE_FIXED32\x10\a\x12\r\n\tTYPE_B" .. "OOL\x10\b\x12\x0F\n\vTYPE_STRING\x10\t\x12\x0E\n\nTYPE_GROUP\x10\n\x12\x10" .. "\n\fTYPE_MESSAGE\x10\v\x12\x0E\n\nTYPE_BYTES\x10\f\x12\x0F\n\vTYPE_UIN" .. "T32\x10\r\x12\r\n\tTYPE_ENUM\x10\x0E\x12\x11\n\rTYPE_SFIXED32\x10\x0F\x12\x11" .. "\n\rTYPE_SFIXED64\x10\x10\x12\x0F\n\vTYPE_SINT32\x10\x11\x12\x0F\n\vTYPE_S" .. "INT64\x10\x12\"C\n\x05Label\x12\x12\n\x0ELABEL_OPTIONAL\x10\x01\x12\x12\n\x0ELABEL" .. "_REQUIRED\x10\x02\x12\x12\n\x0ELABEL_REPEATED\x10\x03\"$\n\x14OneofDescriptorPro" .. "to\x12\f\n\x04name\x18\x01 \x01(\t\"\x8C\x01\n\x13EnumDescriptorProto\x12\f\n\x04" .. "name\x18\x01 \x01(\t\x128\n\x05value\x18\x02 \x03(\v2).google.protobuf.EnumValueD" .. "escriptorProto\x12-\n\aoptions\x18\x03 \x01(\v2\x1C.google.protobuf.EnumOpti" .. "ons\"l\n\x18EnumValueDescriptorProto\x12\f\n\x04name\x18\x01 \x01(\t\x12\x0E\n" .. "\x06number\x18\x02 \x01(\x05\x122\n\aoptions\x18\x03 \x01(\v2!.google.protobuf.Enum" .. "ValueOptions\"\x90\x01\n\x16ServiceDescriptorProto\x12\f\n\x04name\x18\x01 \x01(" .. "\t\x126\n\x06method\x18\x02 \x03(\v2&.google.protobuf.MethodDescriptorProto" .. "\x120\n\aoptions\x18\x03 \x01(\v2\x1F.google.protobuf.ServiceOptions\"\xC1" .. "\x01\n\x15MethodDescriptorProto\x12\f\n\x04name\x18\x01 \x01(\t\x12\x12\n\ninput" .. "_type\x18\x02 \x01(\t\x12\x13\n\voutput_type\x18\x03 \x01(\t\x12/\n\aoptions\x18\x04 " .. "\x01(\v2\x1E.google.protobuf.MethodOptions\x12\x1F\n\x10client_streaming\x18" .. "\x05 \x01(\b:\x05false\x12\x1F\n\x10server_streaming\x18\x06 \x01(\b:\x05false\"\xE7\x04" .. "\n\vFileOptions\x12\x14\n\fjava_package\x18\x01 \x01(\t\x12\x1C\n\x14java_out" .. "er_classname\x18\b \x01(\t\x12\"\n\x13java_multiple_files\x18\n \x01(\b:\x05fals" .. "e\x12,\n\x1Djava_generate_equals_and_hash\x18\x14 \x01(\b:\x05false\x12%\n\x16ja" .. "va_string_check_utf8\x18\x1B \x01(\b:\x05false\x12F\n\foptimize_for\x18\t \x01(" .. "\x0E2).google.protobuf.FileOptions.OptimizeMode:\x05SPEED\x12\x12\n\ngo_pa" .. "ckage\x18\v \x01(\t\x12\"\n\x13cc_generic_services\x18\x10 \x01(\b:\x05false\x12$" .. "\n\x15java_generic_services\x18\x11 \x01(\b:\x05false\x12\"\n\x13py_generic_ser" .. "vices\x18\x12 \x01(\b:\x05false\x12\x19\n\ndeprecated\x18\x17 \x01(\b:\x05false\x12" .. "\x1F\n\x10cc_enable_arenas\x18\x1F \x01(\b:\x05false\x12\x19\n\x11objc_class_pref" .. "ix\x18$ \x01(\t\x12C\n\x14uninterpreted_option\x18\xE7\a \x03(\v2$.google.pro" .. "tobuf.UninterpretedOption\":\n\fOptimizeMode\x12\t\n\x05SPEED\x10\x01\x12\r" .. "\n\tCODE_SIZE\x10\x02\x12\x10\n\fLITE_RUNTIME\x10\x03*\t\b\xE8\a\x10\x80\x80" .. "\x80\x80\x02\"\xE6\x01\n\x0EMessageOptions\x12&\n\x17message_set_wire_format" .. "\x18\x01 \x01(\b:\x05false\x12.\n\x1Fno_standard_descriptor_accessor\x18\x02 \x01(\b:" .. "\x05false\x12\x19\n\ndeprecated\x18\x03 \x01(\b:\x05false\x12\x11\n\tmap_entry\x18" .. "\a \x01(\b\x12C\n\x14uninterpreted_option\x18\xE7\a \x03(\v2$.google.protobu" .. "f.UninterpretedOption*\t\b\xE8\a\x10\x80\x80\x80\x80\x02\"\xA0\x02\n\fField" .. "Options\x12:\n\x05ctype\x18\x01 \x01(\x0E2#.google.protobuf.FieldOptions.CType:" .. "\x06STRING\x12\x0E\n\x06packed\x18\x02 \x01(\b\x12\x13\n\x04lazy\x18\x05 \x01(\b:\x05false" .. "\x12\x19\n\ndeprecated\x18\x03 \x01(\b:\x05false\x12\x13\n\x04weak\x18\n \x01(\b:\x05f" .. "alse\x12C\n\x14uninterpreted_option\x18\xE7\a \x03(\v2$.google.protobuf.Un" .. "interpretedOption\"/\n\x05CType\x12\n\n\x06STRING\x10\x00\x12\b\n\x04CORD\x10\x01" .. "\x12\x10\n\fSTRING_PIECE\x10\x02*\t\b\xE8\a\x10\x80\x80\x80\x80\x02\"\x8D\x01\n" .. "\vEnumOptions\x12\x13\n\vallow_alias\x18\x02 \x01(\b\x12\x19\n\ndeprecated" .. "\x18\x03 \x01(\b:\x05false\x12C\n\x14uninterpreted_option\x18\xE7\a \x03(\v2$.goo" .. "gle.protobuf.UninterpretedOption*\t\b\xE8\a\x10\x80\x80\x80\x80\x02\"}\n" .. "\x10EnumValueOptions\x12\x19\n\ndeprecated\x18\x01 \x01(\b:\x05false\x12C\n\x14un" .. "interpreted_option\x18\xE7\a \x03(\v2$.google.protobuf.UninterpretedOptio" .. "n*\t\b\xE8\a\x10\x80\x80\x80\x80\x02\"{\n\x0EServiceOptions\x12\x19\n\ndepr" .. "ecated\x18! \x01(\b:\x05false\x12C\n\x14uninterpreted_option\x18\xE7\a \x03(\v2" .. "$.google.protobuf.UninterpretedOption*\t\b\xE8\a\x10\x80\x80\x80\x80\x02\"z" .. "\n\rMethodOptions\x12\x19\n\ndeprecated\x18! \x01(\b:\x05false\x12C\n\x14uni" .. "nterpreted_option\x18\xE7\a \x03(\v2$.google.protobuf.UninterpretedOption" .. "*\t\b\xE8\a\x10\x80\x80\x80\x80\x02\"\x9E\x02\n\x13UninterpretedOption\x12;\n" .. "\x04name\x18\x02 \x03(\v2-.google.protobuf.UninterpretedOption.NamePart\x12\x18" .. "\n\x10identifier_value\x18\x03 \x01(\t\x12\x1A\n\x12positive_int_value\x18\x04 \x01(" .. "\x04\x12\x1A\n\x12negative_int_value\x18\x05 \x01(\x03\x12\x14\n\fdouble_value\x18\x06" .. " \x01(\x01\x12\x14\n\fstring_value\x18\a \x01(\f\x12\x17\n\x0Faggregate_value" .. "\x18\b \x01(\t\x1A3\n\bNamePart\x12\x11\n\tname_part\x18\x01 \x02(\t\x12\x14\n\f" .. "is_extension\x18\x02 \x02(\b\"\xD5\x01\n\x0ESourceCodeInfo\x12:\n\blocation\x18" .. "\x01 \x03(\v2(.google.protobuf.SourceCodeInfo.Location\x1A\x86\x01\n\bLocati" .. "on\x12\x10\n\x04path\x18\x01 \x03(\x05B\x02\x10\x01\x12\x10\n\x04span\x18\x02 \x03(\x05B\x02\x10\x01" .. "\x12\x18\n\x10leading_comments\x18\x03 \x01(\t\x12\x19\n\x11trailing_comments\x18" .. "\x04 \x01(\t\x12!\n\x19leading_detached_comments\x18\x06 \x03(\tB)\n\x13com.google" .. ".protobufB\x10DescriptorProtosH\x01"

	function Parser.reload()
		assert(pb.load(descriptor_pb))
	end

	local function do_compile(self, f, ...)
		if self.include_imports then
			local old = self.on_import
			local infos = {}

			function self.on_import(info)
				insert_tab(infos, info)
			end

			local r = f(...)

			insert_tab(infos, r)

			self.on_import = old

			return {
				file = infos
			}
		end

		return {
			file = {
				f(...)
			}
		}
	end

	function Parser:compile(s, name)
		local set = do_compile(self, self.parse, self, s, name)

		return pb.encode(".google.protobuf.FileDescriptorSet", set)
	end

	function Parser:compilefile(fn)
		local set = do_compile(self, self.parsefile, self, fn)

		return pb.encode(".google.protobuf.FileDescriptorSet", set)
	end

	function Parser:load(s, name)
		local ret, pos = pb.load(self:compile(s, name))

		if ret then
			return ret, pos
		end

		error("load failed at offset " .. pos)
	end

	function Parser:loadfile(fn)
		local ret, pos = pb.load(self:compilefile(fn))

		if ret then
			return ret, pos
		end

		error("load failed at offset " .. pos)
	end

	Parser.reload()
end

return Parser
