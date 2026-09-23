-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Lib\\luaunit.lua

require("math")

local M = {}

M.private = {}
M.VERSION = "3.4"
M._VERSION = M.VERSION
M._LUAVERSION = jit and jit.version or _VERSION
M.ORDER_ACTUAL_EXPECTED = true
M.PRINT_TABLE_REF_IN_ERROR_MSG = false
M.LINE_LENGTH = 80
M.TABLE_DIFF_ANALYSIS_THRESHOLD = 10
M.LIST_DIFF_ANALYSIS_THRESHOLD = 10
M.STRIP_EXTRA_ENTRIES_IN_STACK_TRACE = 0
M.EPS = 2.220446049250313e-16

if math.abs(8.326672684688674e-17) > M.EPS then
	M.EPS = 1.1920928955078125e-07
end

local STRIP_LUAUNIT_FROM_STACKTRACE = true

M.VERBOSITY_DEFAULT = 10
M.VERBOSITY_LOW = 1
M.VERBOSITY_QUIET = 0
M.VERBOSITY_VERBOSE = 20
M.DEFAULT_DEEP_ANALYSIS = nil
M.FORCE_DEEP_ANALYSIS = true
M.DISABLE_DEEP_ANALYSIS = false

local cmdline_argv = rawget(_G, "arg")

M.FAILURE_PREFIX = "LuaUnit test FAILURE: "
M.SUCCESS_PREFIX = "LuaUnit test SUCCESS: "
M.SKIP_PREFIX = "LuaUnit test SKIP:    "
M.USAGE = "Usage: lua <your_test_suite.lua> [options] [testname1 [testname2] ... ]\nOptions:\n  -h, --help:             Print this help\n  --version:              Print version information\n  -v, --verbose:          Increase verbosity\n  -q, --quiet:            Set verbosity to minimum\n  -e, --error:            Stop on first error\n  -f, --failure:          Stop on first failure or error\n  -s, --shuffle:          Shuffle tests before running them\n  -o, --output OUTPUT:    Set output type to OUTPUT\n                          Possible values: text, tap, junit, nil\n  -n, --name NAME:        For junit only, mandatory name of xml file\n  -r, --repeat NUM:       Execute all tests NUM times, e.g. to trig the JIT\n  -p, --pattern PATTERN:  Execute all test names matching the Lua PATTERN\n                          May be repeated to include several patterns\n                          Make sure you escape magic chars like +? with %\n  -x, --exclude PATTERN:  Exclude all test names matching the Lua PATTERN\n                          May be repeated to exclude several patterns\n                          Make sure you escape magic chars like +? with %\n  testname1, testname2, ... : tests to run in the form of testFunction,\n                              TestClass or TestClass.testMethod\n\nYou may also control LuaUnit options with the following environment variables:\n* LUAUNIT_OUTPUT: same as --output\n* LUAUNIT_JUNIT_FNAME: same as --name "
M.oldOsExit = os.exit

function os.exit(...)
	if M.LuaUnit and #M.LuaUnit.instances ~= 0 then
		local msg = "You are trying to exit but there is still a running instance of LuaUnit.\nLuaUnit expects to run until the end before exiting with a complete status of successful/failed tests.\n\nTo force exit LuaUnit while running, please call before os.exit (assuming lu is the luaunit module loaded):\n\n    lu.unregisterCurrentSuite() \n\n"

		M.private.error_fmt(2, msg)
	end

	M.oldOsExit(...)
end

local function pcall_or_abort(func, ...)
	local unpack = rawget(_G, "unpack") or table.unpack
	local result = {
		pcall(func, ...)
	}

	if not result[1] then
		print(result[2])
		print()
		print(M.USAGE)
		os.exit(-1)
	end

	return unpack(result, 2)
end

local crossTypeOrdering = {
	string = 3,
	number = 1,
	table = 4,
	other = 5,
	boolean = 2
}
local crossTypeComparison = {
	number = function(a, b)
		return a < b
	end,
	string = function(a, b)
		return a < b
	end,
	other = function(a, b)
		return tostring(a) < tostring(b)
	end
}

local function crossTypeSort(a, b)
	local type_a, type_b = type(a), type(b)

	if type_a == type_b then
		local func = crossTypeComparison[type_a] or crossTypeComparison.other

		return func(a, b)
	end

	type_a = crossTypeOrdering[type_a] or crossTypeOrdering.other
	type_b = crossTypeOrdering[type_b] or crossTypeOrdering.other

	return type_a < type_b
end

local function __genSortedIndex(t)
	local sortedIndex = {}

	for key, _ in pairs(t) do
		table.insert(sortedIndex, key)
	end

	table.sort(sortedIndex, crossTypeSort)

	return sortedIndex
end

M.private.__genSortedIndex = __genSortedIndex

local function sortedNext(state, control)
	local key

	if control == nil then
		state.count = #state.sortedIdx
		state.lastIdx = 1
		key = state.sortedIdx[1]

		return key, state.t[key]
	end

	if control ~= state.sortedIdx[state.lastIdx] then
		local lower, upper = 1, state.count

		repeat
			state.lastIdx = math.modf((lower + upper) / 2)
			key = state.sortedIdx[state.lastIdx]

			if key == control then
				break
			end

			if crossTypeSort(key, control) then
				lower = state.lastIdx + 1
			else
				upper = state.lastIdx - 1
			end
		until upper < lower

		if upper < lower then
			state.lastIdx = state.count
		end
	end

	state.lastIdx = state.lastIdx + 1
	key = state.sortedIdx[state.lastIdx]

	if key then
		return key, state.t[key]
	end
end

local function sortedPairs(tbl)
	return sortedNext, {
		t = tbl,
		sortedIdx = __genSortedIndex(tbl)
	}, nil
end

M.private.sortedPairs = sortedPairs

math.randomseed(math.floor(os.clock() * 100000000000))

local function randomizeTable(t)
	for i = #t, 2, -1 do
		local j = math.random(i)

		if i ~= j then
			t[i], t[j] = t[j], t[i]
		end
	end
end

M.private.randomizeTable = randomizeTable

local function strsplit(delimiter, text)
	if delimiter == "" or delimiter == nil then
		error("delimiter is nil or empty string!")
	end

	if text == nil then
		return nil
	end

	local list, pos, first, last = {}, 1

	while true do
		first, last = text:find(delimiter, pos, true)

		if first then
			table.insert(list, text:sub(pos, first - 1))

			pos = last + 1
		else
			table.insert(list, text:sub(pos))

			break
		end
	end

	return list
end

M.private.strsplit = strsplit

local function hasNewLine(s)
	return string.find(s, "\n", 1, true) ~= nil
end

M.private.hasNewLine = hasNewLine

local function prefixString(prefix, s)
	return prefix .. string.gsub(s, "\n", "\n" .. prefix)
end

M.private.prefixString = prefixString

local function strMatch(s, pattern, start, final)
	start = start or 1
	final = final or string.len(s)

	local foundStart, foundEnd = string.find(s, pattern, start, false)

	return foundStart == start and foundEnd == final
end

M.private.strMatch = strMatch

local function patternFilter(patterns, expr)
	local default, result = true

	if patterns ~= nil then
		for _, pattern in ipairs(patterns) do
			local exclude = pattern:sub(1, 1) == "!"

			if exclude then
				pattern = pattern:sub(2)
			else
				default = false
			end

			if string.find(expr, pattern) then
				result = not exclude
			end
		end
	end

	if result ~= nil then
		return result
	end

	return default
end

M.private.patternFilter = patternFilter

local function xmlEscape(s)
	return string.gsub(s, ".", {
		[">"] = "&gt;",
		["&"] = "&amp;",
		["<"] = "&lt;",
		["'"] = "&apos;",
		["\""] = "&quot;"
	})
end

M.private.xmlEscape = xmlEscape

local function xmlCDataEscape(s)
	return string.gsub(s, "]]>", "]]&gt;")
end

M.private.xmlCDataEscape = xmlCDataEscape

local function lstrip(s)
	local idx = 0

	while idx < s:len() do
		idx = idx + 1

		local c = s:sub(idx, idx)

		if c ~= " " and c ~= "\t" then
			break
		end
	end

	return s:sub(idx)
end

M.private.lstrip = lstrip

local function extractFileLineInfo(s)
	local s2 = lstrip(s)
	local firstColon = s2:find(":", 1, true)

	if firstColon == nil then
		return s
	end

	local secondColon = s2:find(":", firstColon + 1, true)

	if secondColon == nil then
		return s
	end

	return s2:sub(1, secondColon - 1)
end

M.private.extractFileLineInfo = extractFileLineInfo

local function stripLuaunitTrace2(stackTrace, errMsg)
	local function isLuaunitInternalLine(s)
		return s:find("[/\\]luaunit%.lua:%d+: ") ~= nil
	end

	local t = strsplit("\n", stackTrace)
	local idx = 2
	local errMsgFileLine = extractFileLineInfo(errMsg)

	while t[idx] and extractFileLineInfo(t[idx]) ~= errMsgFileLine do
		table.remove(t, idx)
	end

	while t[idx] and not isLuaunitInternalLine(t[idx]) do
		idx = idx + 1
	end

	while t[idx] do
		table.remove(t, idx)
	end

	return table.concat(t, "\n")
end

M.private.stripLuaunitTrace2 = stripLuaunitTrace2

local function prettystr_sub(v, indentLevel, printTableRefs, cycleDetectTable)
	local type_v = type(v)

	if type_v == "string" then
		if v:find("\"", 1, true) and not v:find("'", 1, true) then
			return "'" .. v .. "'"
		end

		return "\"" .. v:gsub("\"", "\\\"") .. "\""
	elseif type_v == "table" then
		return M.private._table_tostring(v, indentLevel, printTableRefs, cycleDetectTable)
	elseif type_v == "number" then
		if v ~= v then
			return "#NaN"
		end

		if v == math.huge then
			return "#Inf"
		end

		if v == -math.huge then
			return "-#Inf"
		end

		if _VERSION == "Lua 5.3" then
			local i = math.tointeger(v)

			if i then
				return tostring(i)
			end
		end
	end

	return tostring(v)
end

local function prettystr(v)
	local cycleDetectTable = {}
	local s = prettystr_sub(v, 1, M.PRINT_TABLE_REF_IN_ERROR_MSG, cycleDetectTable)

	if cycleDetectTable.detected and not M.PRINT_TABLE_REF_IN_ERROR_MSG then
		cycleDetectTable = {}
		s = prettystr_sub(v, 1, true, cycleDetectTable)
	end

	return s
end

M.prettystr = prettystr

function M.adjust_err_msg_with_iter(err_msg, iter_msg)
	if iter_msg then
		iter_msg = iter_msg .. ", "
	else
		iter_msg = ""
	end

	local RE_FILE_LINE = ".*:%d+: "

	if type(err_msg) ~= "string" then
		err_msg = prettystr(err_msg)
	end

	if err_msg:find(M.SUCCESS_PREFIX) == 1 or err_msg:match("(" .. RE_FILE_LINE .. ")" .. M.SUCCESS_PREFIX .. ".*") then
		return nil, M.NodeStatus.SUCCESS
	end

	if err_msg:find(M.SKIP_PREFIX) == 1 or err_msg:match("(" .. RE_FILE_LINE .. ")" .. M.SKIP_PREFIX .. ".*") ~= nil then
		err_msg = err_msg:gsub(".*" .. M.SKIP_PREFIX, iter_msg, 1)

		return err_msg, M.NodeStatus.SKIP
	end

	if err_msg:find(M.FAILURE_PREFIX) == 1 or err_msg:match("(" .. RE_FILE_LINE .. ")" .. M.FAILURE_PREFIX .. ".*") ~= nil then
		err_msg = err_msg:gsub(M.FAILURE_PREFIX, iter_msg, 1)

		return err_msg, M.NodeStatus.FAIL
	end

	if iter_msg then
		local match

		match = err_msg:match("(.*:%d+: ).*")

		if match then
			err_msg = err_msg:gsub(match, match .. iter_msg)
		else
			err_msg = iter_msg .. err_msg
		end
	end

	return err_msg, M.NodeStatus.ERROR
end

local function tryMismatchFormatting(table_a, table_b, doDeepAnalysis, margin)
	if type(table_a) ~= "table" or type(table_b) ~= "table" then
		return false
	end

	if doDeepAnalysis == M.DISABLE_DEEP_ANALYSIS then
		return false
	end

	local len_a, len_b, isPureList = #table_a, #table_b, true

	for k1, v1 in pairs(table_a) do
		if type(k1) ~= "number" or len_a < k1 then
			isPureList = false

			break
		end
	end

	if isPureList then
		for k2, v2 in pairs(table_b) do
			if type(k2) ~= "number" or len_b < k2 then
				isPureList = false

				break
			end
		end
	end

	if isPureList and math.min(len_a, len_b) < M.LIST_DIFF_ANALYSIS_THRESHOLD and doDeepAnalysis ~= M.FORCE_DEEP_ANALYSIS then
		return false
	end

	if isPureList then
		return M.private.mismatchFormattingPureList(table_a, table_b, margin)
	else
		return false
	end
end

M.private.tryMismatchFormatting = tryMismatchFormatting

local function getTaTbDescr()
	if not M.ORDER_ACTUAL_EXPECTED then
		return "expected", "actual"
	end

	return "actual", "expected"
end

local function extendWithStrFmt(res, ...)
	table.insert(res, string.format(...))
end

local function mismatchFormattingMapping(table_a, table_b, doDeepAnalysis)
	return
end

M.private.mismatchFormattingMapping = mismatchFormattingMapping

local function mismatchFormattingPureList(table_a, table_b, margin)
	local result, descrTa, descrTb = {}, getTaTbDescr()
	local len_a, len_b, refa, refb = #table_a, #table_b, "", ""

	if M.PRINT_TABLE_REF_IN_ERROR_MSG then
		refa, refb = string.format("<%s> ", M.private.table_ref(table_a)), string.format("<%s> ", M.private.table_ref(table_b))
	end

	local longest, shortest = math.max(len_a, len_b), math.min(len_a, len_b)
	local deltalv = longest - shortest
	local commonUntil = shortest

	for i = 1, shortest do
		if not M.private.is_table_equals(table_a[i], table_b[i], margin) then
			commonUntil = i - 1

			break
		end
	end

	local commonBackTo = shortest - 1

	for i = 0, shortest - 1 do
		if not M.private.is_table_equals(table_a[len_a - i], table_b[len_b - i], margin) then
			commonBackTo = i - 1

			break
		end
	end

	table.insert(result, "List difference analysis:")

	if len_a == len_b then
		extendWithStrFmt(result, "* lists %sA (%s) and %sB (%s) have the same size", refa, descrTa, refb, descrTb)
	else
		extendWithStrFmt(result, "* list sizes differ: list %sA (%s) has %d items, list %sB (%s) has %d items", refa, descrTa, len_a, refb, descrTb, len_b)
	end

	extendWithStrFmt(result, "* lists A and B start differing at index %d", commonUntil + 1)

	if commonBackTo >= 0 then
		if deltalv > 0 then
			extendWithStrFmt(result, "* lists A and B are equal again from index %d for A, %d for B", len_a - commonBackTo, len_b - commonBackTo)
		else
			extendWithStrFmt(result, "* lists A and B are equal again from index %d", len_a - commonBackTo)
		end
	end

	local function insertABValue(ai, bi)
		bi = bi or ai

		if M.private.is_table_equals(table_a[ai], table_b[bi], margin) then
			return extendWithStrFmt(result, "  = A[%d], B[%d]: %s", ai, bi, prettystr(table_a[ai]))
		else
			extendWithStrFmt(result, "  - A[%d]: %s", ai, prettystr(table_a[ai]))
			extendWithStrFmt(result, "  + B[%d]: %s", bi, prettystr(table_b[bi]))
		end
	end

	if commonUntil > 0 then
		table.insert(result, "* Common parts:")

		for i = 1, commonUntil do
			insertABValue(i)
		end
	end

	if commonUntil < shortest - commonBackTo - 1 then
		table.insert(result, "* Differing parts:")

		for i = commonUntil + 1, shortest - commonBackTo - 1 do
			insertABValue(i)
		end
	end

	if shortest - commonBackTo <= longest - commonBackTo - 1 then
		table.insert(result, "* Present only in one list:")

		for i = shortest - commonBackTo, longest - commonBackTo - 1 do
			if len_b < len_a then
				extendWithStrFmt(result, "  - A[%d]: %s", i, prettystr(table_a[i]))
			else
				extendWithStrFmt(result, "  + B[%d]: %s", i, prettystr(table_b[i]))
			end
		end
	end

	if commonBackTo >= 0 then
		table.insert(result, "* Common parts at the end of the lists")

		for i = longest - commonBackTo, longest do
			if len_b < len_a then
				insertABValue(i, i - deltalv)
			else
				insertABValue(i - deltalv, i)
			end
		end
	end

	return true, table.concat(result, "\n")
end

M.private.mismatchFormattingPureList = mismatchFormattingPureList

local function prettystrPairs(value1, value2, suffix_a, suffix_b)
	local str1, str2 = prettystr(value1), prettystr(value2)

	if hasNewLine(str1) or hasNewLine(str2) then
		return "\n" .. str1 .. (suffix_a or ""), "\n" .. str2
	end

	return str1 .. (suffix_b or ""), str2
end

M.private.prettystrPairs = prettystrPairs

local UNKNOWN_REF = "table 00-unknown ref"
local ref_generator = {
	value = 1,
	[UNKNOWN_REF] = 0
}

local function table_ref(t)
	local ref = ""
	local mt = getmetatable(t)

	if mt == nil then
		ref = tostring(t)
	else
		local success, result

		success, result = pcall(setmetatable, t, nil)

		if not success then
			ref = tostring(t)

			if not ref:match("table: 0?x?[%x]+") then
				return UNKNOWN_REF
			end
		else
			ref = tostring(t)

			setmetatable(t, mt)
		end
	end

	ref = ref:sub(8)

	if ref ~= UNKNOWN_REF and ref_generator[ref] == nil then
		ref_generator[ref] = ref_generator.value
		ref_generator.value = ref_generator.value + 1
	end

	if M.PRINT_TABLE_REF_IN_ERROR_MSG then
		return string.format("table %02d-%s", ref_generator[ref], ref)
	else
		return string.format("table %02d", ref_generator[ref])
	end
end

M.private.table_ref = table_ref

local TABLE_TOSTRING_SEP = ", "
local TABLE_TOSTRING_SEP_LEN = string.len(TABLE_TOSTRING_SEP)

local function _table_tostring(tbl, indentLevel, printTableRefs, cycleDetectTable)
	printTableRefs = printTableRefs or M.PRINT_TABLE_REF_IN_ERROR_MSG
	cycleDetectTable = cycleDetectTable or {}
	cycleDetectTable[tbl] = true

	local result, dispOnMultLines = {}, false

	local function keytostring(k)
		if type(k) == "string" and k:match("^[_%a][_%w]*$") then
			return k
		end

		return prettystr_sub(k, indentLevel + 1, printTableRefs, cycleDetectTable)
	end

	local mt = getmetatable(tbl)

	if mt and mt.__tostring then
		result = tostring(tbl)

		if type(result) ~= "string" then
			return string.format("<invalid tostring() result: \"%s\" >", prettystr(result))
		end

		result = strsplit("\n", result)

		return M.private._table_tostring_format_multiline_string(result, indentLevel)
	else
		local entry, count, seq_index = nil, 0, 1

		for k, v in sortedPairs(tbl) do
			if k == seq_index then
				entry = ""
				seq_index = seq_index + 1
			elseif cycleDetectTable[k] then
				cycleDetectTable.detected = true
				entry = "<" .. table_ref(k) .. ">="
			else
				entry = keytostring(k) .. "="
			end

			if cycleDetectTable[v] then
				cycleDetectTable.detected = true
				entry = entry .. "<" .. table_ref(v) .. ">"
			else
				entry = entry .. prettystr_sub(v, indentLevel + 1, printTableRefs, cycleDetectTable)
			end

			count = count + 1
			result[count] = entry
		end

		return M.private._table_tostring_format_result(tbl, result, indentLevel, printTableRefs)
	end
end

M.private._table_tostring = _table_tostring

local function _table_tostring_format_multiline_string(tbl_str, indentLevel)
	local indentString = "\n" .. string.rep("    ", indentLevel - 1)

	return table.concat(tbl_str, indentString)
end

M.private._table_tostring_format_multiline_string = _table_tostring_format_multiline_string

local function _table_tostring_format_result(tbl, result, indentLevel, printTableRefs)
	local dispOnMultLines = false
	local totalLength = 0

	for k, v in ipairs(result) do
		totalLength = totalLength + string.len(v)

		if totalLength >= M.LINE_LENGTH then
			dispOnMultLines = true

			break
		end
	end

	if not dispOnMultLines then
		if #result > 0 then
			totalLength = totalLength + TABLE_TOSTRING_SEP_LEN * (#result - 1)
		end

		dispOnMultLines = totalLength + 2 >= M.LINE_LENGTH
	end

	if dispOnMultLines then
		local indentString = string.rep("    ", indentLevel - 1)

		result = {
			"{\n    ",
			indentString,
			table.concat(result, ",\n    " .. indentString),
			"\n",
			indentString,
			"}"
		}
	else
		result = {
			"{",
			table.concat(result, TABLE_TOSTRING_SEP),
			"}"
		}
	end

	if printTableRefs then
		table.insert(result, 1, "<" .. table_ref(tbl) .. "> ")
	end

	return table.concat(result)
end

M.private._table_tostring_format_result = _table_tostring_format_result

local function table_findkeyof(t, element)
	if type(t) == "table" then
		for k, v in pairs(t) do
			if M.private.is_table_equals(v, element) then
				return k
			end
		end
	end

	return nil
end

local function _is_table_items_equals(actual, expected)
	local type_a, type_e = type(actual), type(expected)

	if type_a ~= type_e then
		return false
	elseif type_a == "table" then
		for k, v in pairs(actual) do
			if table_findkeyof(expected, v) == nil then
				return false
			end
		end

		for k, v in pairs(expected) do
			if table_findkeyof(actual, v) == nil then
				return false
			end
		end

		return true
	elseif actual ~= expected then
		return false
	end

	return true
end

local _recursion_cache_MT = {
	__index = {
		cached = function(t, actual, expected)
			local subtable = t[actual] or {}

			return subtable[expected]
		end,
		store = function(t, actual, expected, value, asymmetric)
			local subtable = t[actual]

			if not subtable then
				subtable = {}
				t[actual] = subtable
			end

			subtable[expected] = value

			if not asymmetric then
				t:store(expected, actual, value, true)
			end

			return value
		end
	}
}

local function _is_table_equals(actual, expected, cycleDetectTable, marginForAlmostEqual)
	local type_a, type_e = type(actual), type(expected)

	if type_a ~= type_e then
		return false
	end

	if type_a == "number" then
		if marginForAlmostEqual ~= nil then
			return M.almostEquals(actual, expected, marginForAlmostEqual)
		else
			return actual == expected
		end
	elseif type_a ~= "table" then
		return actual == expected
	end

	cycleDetectTable = cycleDetectTable or {
		actual = {},
		expected = {}
	}

	if cycleDetectTable.actual[actual] then
		if cycleDetectTable.expected[expected] then
			return true
		end

		return false
	end

	if cycleDetectTable.expected[expected] then
		return false
	end

	cycleDetectTable.actual[actual] = true
	cycleDetectTable.expected[expected] = true

	local actualKeysMatched = {}

	for k, v in pairs(actual) do
		actualKeysMatched[k] = true

		if not _is_table_equals(v, expected[k], cycleDetectTable, marginForAlmostEqual) then
			cycleDetectTable.actual[actual] = nil
			cycleDetectTable.expected[expected] = nil

			return false
		end
	end

	for k, v in pairs(expected) do
		if not actualKeysMatched[k] then
			cycleDetectTable.actual[actual] = nil
			cycleDetectTable.expected[expected] = nil

			return false
		end
	end

	cycleDetectTable.actual[actual] = nil
	cycleDetectTable.expected[expected] = nil

	return true
end

M.private._is_table_equals = _is_table_equals

local function failure(main_msg, extra_msg_or_nil, level)
	local msg

	if type(extra_msg_or_nil) == "string" and extra_msg_or_nil:len() > 0 then
		msg = extra_msg_or_nil .. "\n" .. main_msg
	else
		msg = main_msg
	end

	error(M.FAILURE_PREFIX .. msg, (level or 1) + 1 + M.STRIP_EXTRA_ENTRIES_IN_STACK_TRACE)
end

local function is_table_equals(actual, expected, marginForAlmostEqual)
	return _is_table_equals(actual, expected, nil, marginForAlmostEqual)
end

M.private.is_table_equals = is_table_equals

local function fail_fmt(level, extra_msg_or_nil, ...)
	failure(string.format(...), extra_msg_or_nil, (level or 1) + 1)
end

M.private.fail_fmt = fail_fmt

local function error_fmt(level, ...)
	error(string.format(...), (level or 1) + 1 + M.STRIP_EXTRA_ENTRIES_IN_STACK_TRACE)
end

M.private.error_fmt = error_fmt

local function errorMsgEquality(actual, expected, doDeepAnalysis, margin)
	if not M.ORDER_ACTUAL_EXPECTED then
		expected, actual = actual, expected
	end

	if type(expected) == "string" or type(expected) == "table" then
		local strExpected, strActual = prettystrPairs(expected, actual)
		local result = string.format("expected: %s\nactual: %s", strExpected, strActual)

		if margin then
			result = result .. "\nwere not equal by the margin of: " .. prettystr(margin)
		end

		local success, mismatchResult

		success, mismatchResult = tryMismatchFormatting(actual, expected, doDeepAnalysis, margin)

		if success then
			result = table.concat({
				result,
				mismatchResult
			}, "\n")
		end

		return result
	end

	return string.format("expected: %s, actual: %s", prettystr(expected), prettystr(actual))
end

function M.assertError(f, ...)
	if pcall(f, ...) then
		failure("Expected an error when calling function but no error generated", nil, 2)
	end
end

function M.fail(msg)
	failure(msg, nil, 2)
end

function M.failIf(cond, msg)
	if cond then
		failure(msg, nil, 2)
	end
end

function M.skip(msg)
	error_fmt(2, M.SKIP_PREFIX .. msg)
end

function M.skipIf(cond, msg)
	if cond then
		error_fmt(2, M.SKIP_PREFIX .. msg)
	end
end

function M.runOnlyIf(cond, msg)
	if not cond then
		error_fmt(2, M.SKIP_PREFIX .. prettystr(msg))
	end
end

function M.success()
	error_fmt(2, M.SUCCESS_PREFIX)
end

function M.successIf(cond)
	if cond then
		error_fmt(2, M.SUCCESS_PREFIX)
	end
end

function M.assertEquals(actual, expected, extra_msg_or_nil, doDeepAnalysis)
	if type(actual) == "table" and type(expected) == "table" then
		if not is_table_equals(actual, expected) then
			failure(errorMsgEquality(actual, expected, doDeepAnalysis), extra_msg_or_nil, 2)
		end
	elseif type(actual) ~= type(expected) then
		failure(errorMsgEquality(actual, expected), extra_msg_or_nil, 2)
	elseif actual ~= expected then
		failure(errorMsgEquality(actual, expected), extra_msg_or_nil, 2)
	end
end

function M.almostEquals(actual, expected, margin)
	if type(actual) ~= "number" or type(expected) ~= "number" or type(margin) ~= "number" then
		error_fmt(3, "almostEquals: must supply only number arguments.\nArguments supplied: %s, %s, %s", prettystr(actual), prettystr(expected), prettystr(margin))
	end

	if margin < 0 then
		error_fmt(3, "almostEquals: margin must not be negative, current value is " .. margin)
	end

	return margin >= math.abs(expected - actual)
end

function M.assertAlmostEquals(actual, expected, margin, extra_msg_or_nil)
	margin = margin or M.EPS

	if type(margin) ~= "number" then
		error_fmt(2, "almostEquals: margin must be a number, not %s", prettystr(margin))
	end

	if type(actual) == "table" and type(expected) == "table" then
		if not is_table_equals(actual, expected, margin) then
			failure(errorMsgEquality(actual, expected, nil, margin), extra_msg_or_nil, 2)
		end
	elseif type(actual) == "number" and type(expected) == "number" and type(margin) == "number" then
		if not M.almostEquals(actual, expected, margin) then
			if not M.ORDER_ACTUAL_EXPECTED then
				expected, actual = actual, expected
			end

			local delta = math.abs(actual - expected)

			fail_fmt(2, extra_msg_or_nil, "Values are not almost equal\n" .. "Actual: %s, expected: %s, delta %s above margin of %s", actual, expected, delta, margin)
		end
	else
		error_fmt(3, "almostEquals: must supply only number or table arguments.\nArguments supplied: %s, %s, %s", prettystr(actual), prettystr(expected), prettystr(margin))
	end
end

function M.assertNotEquals(actual, expected, extra_msg_or_nil)
	if type(actual) ~= type(expected) then
		return
	end

	if type(actual) == "table" and type(expected) == "table" then
		if not is_table_equals(actual, expected) then
			return
		end
	elseif actual ~= expected then
		return
	end

	fail_fmt(2, extra_msg_or_nil, "Received the not expected value: %s", prettystr(actual))
end

function M.assertNotAlmostEquals(actual, expected, margin, extra_msg_or_nil)
	margin = margin or M.EPS

	if M.almostEquals(actual, expected, margin) then
		if not M.ORDER_ACTUAL_EXPECTED then
			expected, actual = actual, expected
		end

		local delta = math.abs(actual - expected)

		fail_fmt(2, extra_msg_or_nil, "Values are almost equal\nActual: %s, expected: %s" .. ", delta %s below margin of %s", actual, expected, delta, margin)
	end
end

function M.assertItemsEquals(actual, expected, extra_msg_or_nil)
	if not _is_table_items_equals(actual, expected) then
		expected, actual = prettystrPairs(expected, actual)

		fail_fmt(2, extra_msg_or_nil, "Content of the tables are not identical:\nExpected: %s\nActual: %s", expected, actual)
	end
end

function M.assertStrContains(str, sub, isPattern, extra_msg_or_nil)
	if not string.find(str, sub, 1, not isPattern) then
		sub, str = prettystrPairs(sub, str, "\n")

		fail_fmt(2, extra_msg_or_nil, "Could not find %s %s in string %s", isPattern and "pattern" or "substring", sub, str)
	end
end

function M.assertStrIContains(str, sub, extra_msg_or_nil)
	if not string.find(str:lower(), sub:lower(), 1, true) then
		sub, str = prettystrPairs(sub, str, "\n")

		fail_fmt(2, extra_msg_or_nil, "Could not find (case insensitively) substring %s in string %s", sub, str)
	end
end

function M.assertNotStrContains(str, sub, isPattern, extra_msg_or_nil)
	if string.find(str, sub, 1, not isPattern) then
		sub, str = prettystrPairs(sub, str, "\n")

		fail_fmt(2, extra_msg_or_nil, "Found the not expected %s %s in string %s", isPattern and "pattern" or "substring", sub, str)
	end
end

function M.assertNotStrIContains(str, sub, extra_msg_or_nil)
	if string.find(str:lower(), sub:lower(), 1, true) then
		sub, str = prettystrPairs(sub, str, "\n")

		fail_fmt(2, extra_msg_or_nil, "Found (case insensitively) the not expected substring %s in string %s", sub, str)
	end
end

function M.assertStrMatches(str, pattern, start, final, extra_msg_or_nil)
	if not strMatch(str, pattern, start, final) then
		pattern, str = prettystrPairs(pattern, str, "\n")

		fail_fmt(2, extra_msg_or_nil, "Could not match pattern %s with string %s", pattern, str)
	end
end

local function _assertErrorMsgEquals(stripFileAndLine, expectedMsg, func, ...)
	local no_error, error_msg = pcall(func, ...)

	if no_error then
		failure("No error generated when calling function but expected error: " .. M.prettystr(expectedMsg), nil, 3)
	end

	if type(expectedMsg) == "string" and type(error_msg) ~= "string" then
		error_msg = tostring(error_msg)
	end

	local differ = false

	if stripFileAndLine then
		if error_msg:gsub("^.+:%d+: ", "") ~= expectedMsg then
			differ = true
		end
	elseif error_msg ~= expectedMsg then
		local tr = type(error_msg)
		local te = type(expectedMsg)

		if te == "table" then
			if tr ~= "table" then
				differ = true
			else
				local ok = pcall(M.assertItemsEquals, error_msg, expectedMsg)

				if not ok then
					differ = true
				end
			end
		else
			differ = true
		end
	end

	if differ then
		error_msg, expectedMsg = prettystrPairs(error_msg, expectedMsg)

		fail_fmt(3, nil, "Error message expected: %s\nError message received: %s\n", expectedMsg, error_msg)
	end
end

function M.assertErrorMsgEquals(expectedMsg, func, ...)
	_assertErrorMsgEquals(false, expectedMsg, func, ...)
end

function M.assertErrorMsgContentEquals(expectedMsg, func, ...)
	_assertErrorMsgEquals(true, expectedMsg, func, ...)
end

function M.assertErrorMsgContains(partialMsg, func, ...)
	local no_error, error_msg = pcall(func, ...)

	if no_error then
		failure("No error generated when calling function but expected error containing: " .. prettystr(partialMsg), nil, 2)
	end

	if type(error_msg) ~= "string" then
		error_msg = tostring(error_msg)
	end

	if not string.find(error_msg, partialMsg, nil, true) then
		error_msg, partialMsg = prettystrPairs(error_msg, partialMsg)

		fail_fmt(2, nil, "Error message does not contain: %s\nError message received: %s\n", partialMsg, error_msg)
	end
end

function M.assertErrorMsgMatches(expectedMsg, func, ...)
	local no_error, error_msg = pcall(func, ...)

	if no_error then
		failure("No error generated when calling function but expected error matching: \"" .. expectedMsg .. "\"", nil, 2)
	end

	if type(error_msg) ~= "string" then
		error_msg = tostring(error_msg)
	end

	if not strMatch(error_msg, expectedMsg) then
		expectedMsg, error_msg = prettystrPairs(expectedMsg, error_msg)

		fail_fmt(2, nil, "Error message does not match pattern: %s\nError message received: %s\n", expectedMsg, error_msg)
	end
end

function M.assertEvalToTrue(value, extra_msg_or_nil)
	if not value then
		failure("expected: a value evaluating to true, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertEvalToFalse(value, extra_msg_or_nil)
	if value then
		failure("expected: false or nil, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertIsTrue(value, extra_msg_or_nil)
	if value ~= true then
		failure("expected: true, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertNotIsTrue(value, extra_msg_or_nil)
	if value == true then
		failure("expected: not true, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertIsFalse(value, extra_msg_or_nil)
	if value ~= false then
		failure("expected: false, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertNotIsFalse(value, extra_msg_or_nil)
	if value == false then
		failure("expected: not false, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertIsNil(value, extra_msg_or_nil)
	if value ~= nil then
		failure("expected: nil, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertNotIsNil(value, extra_msg_or_nil)
	if value == nil then
		failure("expected: not nil, actual: nil", extra_msg_or_nil, 2)
	end
end

for _, funcName in ipairs({
	"assertIsNumber",
	"assertIsString",
	"assertIsTable",
	"assertIsBoolean",
	"assertIsFunction",
	"assertIsUserdata",
	"assertIsThread"
}) do
	local typeExpected = funcName:match("^assertIs([A-Z]%a*)$")

	typeExpected = typeExpected and typeExpected:lower() or error("bad function name '" .. funcName .. "' for type assertion")
	M[funcName] = function(value, extra_msg_or_nil)
		if type(value) ~= typeExpected then
			if type(value) == "nil" then
				fail_fmt(2, extra_msg_or_nil, "expected: a %s value, actual: nil", typeExpected, type(value), prettystrPairs(value))
			else
				fail_fmt(2, extra_msg_or_nil, "expected: a %s value, actual: type %s, value %s", typeExpected, type(value), prettystrPairs(value))
			end
		end
	end
end

for _, typeExpected in ipairs({
	"Number",
	"String",
	"Table",
	"Boolean",
	"Function",
	"Userdata",
	"Thread",
	"Nil"
}) do
	local typeExpectedLower = typeExpected:lower()

	local function isType(value)
		return type(value) == typeExpectedLower
	end

	M["is" .. typeExpected] = isType
	M["is_" .. typeExpectedLower] = isType
end

for _, funcName in ipairs({
	"assertNotIsNumber",
	"assertNotIsString",
	"assertNotIsTable",
	"assertNotIsBoolean",
	"assertNotIsFunction",
	"assertNotIsUserdata",
	"assertNotIsThread"
}) do
	local typeUnexpected = funcName:match("^assertNotIs([A-Z]%a*)$")

	typeUnexpected = typeUnexpected and typeUnexpected:lower() or error("bad function name '" .. funcName .. "' for type assertion")
	M[funcName] = function(value, extra_msg_or_nil)
		if type(value) == typeUnexpected then
			fail_fmt(2, extra_msg_or_nil, "expected: not a %s type, actual: value %s", typeUnexpected, prettystrPairs(value))
		end
	end
end

function M.assertIs(actual, expected, extra_msg_or_nil)
	if actual ~= expected then
		if not M.ORDER_ACTUAL_EXPECTED then
			actual, expected = expected, actual
		end

		local old_print_table_ref_in_error_msg = M.PRINT_TABLE_REF_IN_ERROR_MSG

		M.PRINT_TABLE_REF_IN_ERROR_MSG = true
		expected, actual = prettystrPairs(expected, actual, "\n", "")
		M.PRINT_TABLE_REF_IN_ERROR_MSG = old_print_table_ref_in_error_msg

		fail_fmt(2, extra_msg_or_nil, "expected and actual object should not be different\nExpected: %s\nReceived: %s", expected, actual)
	end
end

function M.assertNotIs(actual, expected, extra_msg_or_nil)
	if actual == expected then
		local old_print_table_ref_in_error_msg = M.PRINT_TABLE_REF_IN_ERROR_MSG

		M.PRINT_TABLE_REF_IN_ERROR_MSG = true

		local s_expected

		if not M.ORDER_ACTUAL_EXPECTED then
			s_expected = prettystrPairs(actual)
		else
			s_expected = prettystrPairs(expected)
		end

		M.PRINT_TABLE_REF_IN_ERROR_MSG = old_print_table_ref_in_error_msg

		fail_fmt(2, extra_msg_or_nil, "expected and actual object should be different: %s", s_expected)
	end
end

function M.assertIsNaN(value, extra_msg_or_nil)
	if type(value) ~= "number" or value == value then
		failure("expected: NaN, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertNotIsNaN(value, extra_msg_or_nil)
	if type(value) == "number" and value ~= value then
		failure("expected: not NaN, actual: NaN", extra_msg_or_nil, 2)
	end
end

function M.assertIsInf(value, extra_msg_or_nil)
	if type(value) ~= "number" or math.abs(value) ~= math.huge then
		failure("expected: #Inf, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertIsPlusInf(value, extra_msg_or_nil)
	if type(value) ~= "number" or value ~= math.huge then
		failure("expected: #Inf, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertIsMinusInf(value, extra_msg_or_nil)
	if type(value) ~= "number" or value ~= -math.huge then
		failure("expected: -#Inf, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertNotIsPlusInf(value, extra_msg_or_nil)
	if type(value) == "number" and value == math.huge then
		failure("expected: not #Inf, actual: #Inf", extra_msg_or_nil, 2)
	end
end

function M.assertNotIsMinusInf(value, extra_msg_or_nil)
	if type(value) == "number" and value == -math.huge then
		failure("expected: not -#Inf, actual: -#Inf", extra_msg_or_nil, 2)
	end
end

function M.assertNotIsInf(value, extra_msg_or_nil)
	if type(value) == "number" and math.abs(value) == math.huge then
		failure("expected: not infinity, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertIsPlusZero(value, extra_msg_or_nil)
	if type(value) ~= "number" or value ~= 0 then
		failure("expected: +0.0, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	elseif 1 / value == -math.huge then
		failure("expected: +0.0, actual: -0.0", extra_msg_or_nil, 2)
	elseif 1 / value ~= math.huge then
		failure("expected: +0.0, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertIsMinusZero(value, extra_msg_or_nil)
	if type(value) ~= "number" or value ~= 0 then
		failure("expected: -0.0, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	elseif 1 / value == math.huge then
		failure("expected: -0.0, actual: +0.0", extra_msg_or_nil, 2)
	elseif 1 / value ~= -math.huge then
		failure("expected: -0.0, actual: " .. prettystr(value), extra_msg_or_nil, 2)
	end
end

function M.assertNotIsPlusZero(value, extra_msg_or_nil)
	if type(value) == "number" and 1 / value == math.huge then
		failure("expected: not +0.0, actual: +0.0", extra_msg_or_nil, 2)
	end
end

function M.assertNotIsMinusZero(value, extra_msg_or_nil)
	if type(value) == "number" and 1 / value == -math.huge then
		failure("expected: not -0.0, actual: -0.0", extra_msg_or_nil, 2)
	end
end

function M.assertTableContains(t, expected, extra_msg_or_nil)
	if table_findkeyof(t, expected) == nil then
		t, expected = prettystrPairs(t, expected)

		fail_fmt(2, extra_msg_or_nil, "Table %s does NOT contain the expected element %s", t, expected)
	end
end

function M.assertNotTableContains(t, expected, extra_msg_or_nil)
	local k = table_findkeyof(t, expected)

	if k ~= nil then
		t, expected = prettystrPairs(t, expected)

		fail_fmt(2, extra_msg_or_nil, "Table %s DOES contain the unwanted element %s (at key %s)", t, expected, prettystr(k))
	end
end

function M.wrapFunctions()
	io.stderr:write("Use of WrapFunctions() is no longer needed.\nJust prefix your test function names with \"test\" or \"Test\" and they\nwill be picked up and run by LuaUnit.\n")
end

local list_of_funcs = {
	{
		"assertEquals",
		"assert_equals"
	},
	{
		"assertItemsEquals",
		"assert_items_equals"
	},
	{
		"assertNotEquals",
		"assert_not_equals"
	},
	{
		"assertAlmostEquals",
		"assert_almost_equals"
	},
	{
		"assertNotAlmostEquals",
		"assert_not_almost_equals"
	},
	{
		"assertEvalToTrue",
		"assert_eval_to_true"
	},
	{
		"assertEvalToFalse",
		"assert_eval_to_false"
	},
	{
		"assertStrContains",
		"assert_str_contains"
	},
	{
		"assertStrIContains",
		"assert_str_icontains"
	},
	{
		"assertNotStrContains",
		"assert_not_str_contains"
	},
	{
		"assertNotStrIContains",
		"assert_not_str_icontains"
	},
	{
		"assertStrMatches",
		"assert_str_matches"
	},
	{
		"assertError",
		"assert_error"
	},
	{
		"assertErrorMsgEquals",
		"assert_error_msg_equals"
	},
	{
		"assertErrorMsgContains",
		"assert_error_msg_contains"
	},
	{
		"assertErrorMsgMatches",
		"assert_error_msg_matches"
	},
	{
		"assertErrorMsgContentEquals",
		"assert_error_msg_content_equals"
	},
	{
		"assertIs",
		"assert_is"
	},
	{
		"assertNotIs",
		"assert_not_is"
	},
	{
		"assertTableContains",
		"assert_table_contains"
	},
	{
		"assertNotTableContains",
		"assert_not_table_contains"
	},
	{
		"wrapFunctions",
		"WrapFunctions"
	},
	{
		"wrapFunctions",
		"wrap_functions"
	},
	{
		"assertIsNumber",
		"assert_is_number"
	},
	{
		"assertIsString",
		"assert_is_string"
	},
	{
		"assertIsTable",
		"assert_is_table"
	},
	{
		"assertIsBoolean",
		"assert_is_boolean"
	},
	{
		"assertIsNil",
		"assert_is_nil"
	},
	{
		"assertIsTrue",
		"assert_is_true"
	},
	{
		"assertIsFalse",
		"assert_is_false"
	},
	{
		"assertIsNaN",
		"assert_is_nan"
	},
	{
		"assertIsInf",
		"assert_is_inf"
	},
	{
		"assertIsPlusInf",
		"assert_is_plus_inf"
	},
	{
		"assertIsMinusInf",
		"assert_is_minus_inf"
	},
	{
		"assertIsPlusZero",
		"assert_is_plus_zero"
	},
	{
		"assertIsMinusZero",
		"assert_is_minus_zero"
	},
	{
		"assertIsFunction",
		"assert_is_function"
	},
	{
		"assertIsThread",
		"assert_is_thread"
	},
	{
		"assertIsUserdata",
		"assert_is_userdata"
	},
	{
		"assertIsNumber",
		"assertNumber"
	},
	{
		"assertIsString",
		"assertString"
	},
	{
		"assertIsTable",
		"assertTable"
	},
	{
		"assertIsBoolean",
		"assertBoolean"
	},
	{
		"assertIsNil",
		"assertNil"
	},
	{
		"assertIsTrue",
		"assertTrue"
	},
	{
		"assertIsFalse",
		"assertFalse"
	},
	{
		"assertIsNaN",
		"assertNaN"
	},
	{
		"assertIsInf",
		"assertInf"
	},
	{
		"assertIsPlusInf",
		"assertPlusInf"
	},
	{
		"assertIsMinusInf",
		"assertMinusInf"
	},
	{
		"assertIsPlusZero",
		"assertPlusZero"
	},
	{
		"assertIsMinusZero",
		"assertMinusZero"
	},
	{
		"assertIsFunction",
		"assertFunction"
	},
	{
		"assertIsThread",
		"assertThread"
	},
	{
		"assertIsUserdata",
		"assertUserdata"
	},
	{
		"assertIsNumber",
		"assert_number"
	},
	{
		"assertIsString",
		"assert_string"
	},
	{
		"assertIsTable",
		"assert_table"
	},
	{
		"assertIsBoolean",
		"assert_boolean"
	},
	{
		"assertIsNil",
		"assert_nil"
	},
	{
		"assertIsTrue",
		"assert_true"
	},
	{
		"assertIsFalse",
		"assert_false"
	},
	{
		"assertIsNaN",
		"assert_nan"
	},
	{
		"assertIsInf",
		"assert_inf"
	},
	{
		"assertIsPlusInf",
		"assert_plus_inf"
	},
	{
		"assertIsMinusInf",
		"assert_minus_inf"
	},
	{
		"assertIsPlusZero",
		"assert_plus_zero"
	},
	{
		"assertIsMinusZero",
		"assert_minus_zero"
	},
	{
		"assertIsFunction",
		"assert_function"
	},
	{
		"assertIsThread",
		"assert_thread"
	},
	{
		"assertIsUserdata",
		"assert_userdata"
	},
	{
		"assertNotIsNumber",
		"assert_not_is_number"
	},
	{
		"assertNotIsString",
		"assert_not_is_string"
	},
	{
		"assertNotIsTable",
		"assert_not_is_table"
	},
	{
		"assertNotIsBoolean",
		"assert_not_is_boolean"
	},
	{
		"assertNotIsNil",
		"assert_not_is_nil"
	},
	{
		"assertNotIsTrue",
		"assert_not_is_true"
	},
	{
		"assertNotIsFalse",
		"assert_not_is_false"
	},
	{
		"assertNotIsNaN",
		"assert_not_is_nan"
	},
	{
		"assertNotIsInf",
		"assert_not_is_inf"
	},
	{
		"assertNotIsPlusInf",
		"assert_not_plus_inf"
	},
	{
		"assertNotIsMinusInf",
		"assert_not_minus_inf"
	},
	{
		"assertNotIsPlusZero",
		"assert_not_plus_zero"
	},
	{
		"assertNotIsMinusZero",
		"assert_not_minus_zero"
	},
	{
		"assertNotIsFunction",
		"assert_not_is_function"
	},
	{
		"assertNotIsThread",
		"assert_not_is_thread"
	},
	{
		"assertNotIsUserdata",
		"assert_not_is_userdata"
	},
	{
		"assertNotIsNumber",
		"assertNotNumber"
	},
	{
		"assertNotIsString",
		"assertNotString"
	},
	{
		"assertNotIsTable",
		"assertNotTable"
	},
	{
		"assertNotIsBoolean",
		"assertNotBoolean"
	},
	{
		"assertNotIsNil",
		"assertNotNil"
	},
	{
		"assertNotIsTrue",
		"assertNotTrue"
	},
	{
		"assertNotIsFalse",
		"assertNotFalse"
	},
	{
		"assertNotIsNaN",
		"assertNotNaN"
	},
	{
		"assertNotIsInf",
		"assertNotInf"
	},
	{
		"assertNotIsPlusInf",
		"assertNotPlusInf"
	},
	{
		"assertNotIsMinusInf",
		"assertNotMinusInf"
	},
	{
		"assertNotIsPlusZero",
		"assertNotPlusZero"
	},
	{
		"assertNotIsMinusZero",
		"assertNotMinusZero"
	},
	{
		"assertNotIsFunction",
		"assertNotFunction"
	},
	{
		"assertNotIsThread",
		"assertNotThread"
	},
	{
		"assertNotIsUserdata",
		"assertNotUserdata"
	},
	{
		"assertNotIsNumber",
		"assert_not_number"
	},
	{
		"assertNotIsString",
		"assert_not_string"
	},
	{
		"assertNotIsTable",
		"assert_not_table"
	},
	{
		"assertNotIsBoolean",
		"assert_not_boolean"
	},
	{
		"assertNotIsNil",
		"assert_not_nil"
	},
	{
		"assertNotIsTrue",
		"assert_not_true"
	},
	{
		"assertNotIsFalse",
		"assert_not_false"
	},
	{
		"assertNotIsNaN",
		"assert_not_nan"
	},
	{
		"assertNotIsInf",
		"assert_not_inf"
	},
	{
		"assertNotIsPlusInf",
		"assert_not_plus_inf"
	},
	{
		"assertNotIsMinusInf",
		"assert_not_minus_inf"
	},
	{
		"assertNotIsPlusZero",
		"assert_not_plus_zero"
	},
	{
		"assertNotIsMinusZero",
		"assert_not_minus_zero"
	},
	{
		"assertNotIsFunction",
		"assert_not_function"
	},
	{
		"assertNotIsThread",
		"assert_not_thread"
	},
	{
		"assertNotIsUserdata",
		"assert_not_userdata"
	},
	{
		"assertIsThread",
		"assertIsCoroutine"
	},
	{
		"assertIsThread",
		"assertCoroutine"
	},
	{
		"assertIsThread",
		"assert_is_coroutine"
	},
	{
		"assertIsThread",
		"assert_coroutine"
	},
	{
		"assertNotIsThread",
		"assertNotIsCoroutine"
	},
	{
		"assertNotIsThread",
		"assertNotCoroutine"
	},
	{
		"assertNotIsThread",
		"assert_not_is_coroutine"
	},
	{
		"assertNotIsThread",
		"assert_not_coroutine"
	}
}

for _, v in ipairs(list_of_funcs) do
	local funcname, alias = v[1], v[2]

	M[alias] = M[funcname]

	if EXPORT_ASSERT_TO_GLOBALS then
		_G[funcname] = M[funcname]
		_G[alias] = M[funcname]
	end
end

local genericOutput = {
	__class__ = "genericOutput"
}
local genericOutput_MT = {
	__index = genericOutput
}

M.genericOutput = genericOutput

function genericOutput.new(runner, default_verbosity)
	local t = {
		runner = runner
	}

	if runner then
		t.result = runner.result
		t.verbosity = runner.verbosity or default_verbosity
		t.fname = runner.fname
	else
		t.verbosity = default_verbosity
	end

	return setmetatable(t, genericOutput_MT)
end

function genericOutput:startSuite()
	return
end

function genericOutput:startClass(className)
	return
end

function genericOutput:startTest(testName)
	return
end

function genericOutput:updateStatus(node)
	return
end

function genericOutput:endTest(node)
	return
end

function genericOutput:endClass()
	return
end

function genericOutput:endSuite()
	return
end

local TapOutput = genericOutput.new()
local TapOutput_MT = {
	__index = TapOutput
}

TapOutput.__class__ = "TapOutput"

function TapOutput.new(runner)
	local t = genericOutput.new(runner, M.VERBOSITY_LOW)

	return setmetatable(t, TapOutput_MT)
end

function TapOutput:startSuite()
	print("1.." .. self.result.selectedCount)
	print("# Started on " .. self.result.startDate)
end

function TapOutput:startClass(className)
	if className ~= "[TestFunctions]" then
		print("# Starting class: " .. className)
	end
end

function TapOutput:updateStatus(node)
	if node:isSkipped() then
		io.stdout:write("ok ", self.result.currentTestNumber, "\t# SKIP ", node.msg, "\n")

		return
	end

	io.stdout:write("not ok ", self.result.currentTestNumber, "\t", node.testName, "\n")

	if self.verbosity > M.VERBOSITY_LOW then
		print(prefixString("#   ", node.msg))
	end

	if (node:isFailure() or node:isError()) and self.verbosity > M.VERBOSITY_DEFAULT then
		print(prefixString("#   ", node.stackTrace))
	end
end

function TapOutput:endTest(node)
	if node:isSuccess() then
		io.stdout:write("ok     ", self.result.currentTestNumber, "\t", node.testName, "\n")
	end
end

function TapOutput:endSuite()
	print("# " .. M.LuaUnit.statusLine(self.result))

	return self.result.notSuccessCount
end

local JUnitOutput = genericOutput.new()
local JUnitOutput_MT = {
	__index = JUnitOutput
}

JUnitOutput.__class__ = "JUnitOutput"

function JUnitOutput.new(runner)
	local t = genericOutput.new(runner, M.VERBOSITY_LOW)

	t.testList = {}

	return setmetatable(t, JUnitOutput_MT)
end

function JUnitOutput:startSuite()
	if self.fname == nil then
		error("With Junit, an output filename must be supplied with --name!")
	end

	if string.sub(self.fname, -4) ~= ".xml" then
		self.fname = self.fname .. ".xml"
	end

	self.fd = io.open(self.fname, "w")

	if self.fd == nil then
		error("Could not open file for writing: " .. self.fname)
	end

	print("# XML output to " .. self.fname)
	print("# Started on " .. self.result.startDate)
end

function JUnitOutput:startClass(className)
	if className ~= "[TestFunctions]" then
		print("# Starting class: " .. className)
	end
end

function JUnitOutput:startTest(testName)
	print("# Starting test: " .. testName)
end

function JUnitOutput:updateStatus(node)
	if node:isFailure() then
		print("#   Failure: " .. prefixString("#   ", node.msg):sub(4, nil))
	elseif node:isError() then
		print("#   Error: " .. prefixString("#   ", node.msg):sub(4, nil))
	end
end

function JUnitOutput:endSuite()
	print("# " .. M.LuaUnit.statusLine(self.result))
	self.fd:write("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n")
	self.fd:write("<testsuites>\n")
	self.fd:write(string.format("    <testsuite name=\"LuaUnit\" id=\"00001\" package=\"\" hostname=\"localhost\" tests=\"%d\" timestamp=\"%s\" time=\"%0.3f\" errors=\"%d\" failures=\"%d\" skipped=\"%d\">\n", self.result.runCount, self.result.startIsodate, self.result.duration, self.result.errorCount, self.result.failureCount, self.result.skippedCount))
	self.fd:write("        <properties>\n")
	self.fd:write(string.format("            <property name=\"Lua Version\" value=\"%s\"/>\n", _VERSION))
	self.fd:write(string.format("            <property name=\"LuaUnit Version\" value=\"%s\"/>\n", M.VERSION))
	self.fd:write("        </properties>\n")

	for i, node in ipairs(self.result.allTests) do
		self.fd:write(string.format("        <testcase classname=\"%s\" name=\"%s\" time=\"%0.3f\">\n", node.className, node.testName, node.duration))

		if node:isNotSuccess() then
			self.fd:write(node:statusXML())
		end

		self.fd:write("        </testcase>\n")
	end

	self.fd:write("    <system-out/>\n")
	self.fd:write("    <system-err/>\n")
	self.fd:write("    </testsuite>\n")
	self.fd:write("</testsuites>\n")
	self.fd:close()

	return self.result.notSuccessCount
end

local TextOutput = genericOutput.new()
local TextOutput_MT = {
	__index = TextOutput
}

TextOutput.__class__ = "TextOutput"

function TextOutput.new(runner)
	local t = genericOutput.new(runner, M.VERBOSITY_DEFAULT)

	t.errorList = {}

	return setmetatable(t, TextOutput_MT)
end

function TextOutput:startSuite()
	if self.verbosity > M.VERBOSITY_DEFAULT then
		print("Started on " .. self.result.startDate)
	end
end

function TextOutput:startTest(testName)
	if self.verbosity > M.VERBOSITY_DEFAULT then
		io.stdout:write("    ", self.result.currentNode.testName, " ... ")
	end
end

function TextOutput:endTest(node)
	if node:isSuccess() then
		if self.verbosity > M.VERBOSITY_DEFAULT then
			io.stdout:write("Ok\n")
		else
			io.stdout:write(".")
			io.stdout:flush()
		end
	elseif self.verbosity > M.VERBOSITY_DEFAULT then
		print(node.status)
		print(node.msg)
	else
		io.stdout:write(string.sub(node.status, 1, 1))
		io.stdout:flush()
	end
end

function TextOutput:displayOneFailedTest(index, fail)
	print(index .. ") " .. fail.testName)
	print(fail.msg)
	print(fail.stackTrace)
	print()
end

function TextOutput:displayErroredTests()
	if #self.result.errorTests ~= 0 then
		print("Tests with errors:")
		print("------------------")

		for i, v in ipairs(self.result.errorTests) do
			self:displayOneFailedTest(i, v)
		end
	end
end

function TextOutput:displayFailedTests()
	if #self.result.failedTests ~= 0 then
		print("Failed tests:")
		print("-------------")

		for i, v in ipairs(self.result.failedTests) do
			self:displayOneFailedTest(i, v)
		end
	end
end

function TextOutput:endSuite()
	if self.verbosity > M.VERBOSITY_DEFAULT then
		print("=========================================================")
	else
		print()
	end

	self:displayErroredTests()
	self:displayFailedTests()
	print(M.LuaUnit.statusLine(self.result))

	if self.result.notSuccessCount == 0 then
		print("OK")
	end
end

local function nopCallable()
	return nopCallable
end

local NilOutput = {
	__class__ = "NilOuptut"
}
local NilOutput_MT = {
	__index = nopCallable
}

function NilOutput.new(runner)
	return setmetatable({
		__class__ = "NilOutput"
	}, NilOutput_MT)
end

M.LuaUnit = {
	__class__ = "LuaUnit",
	outputType = TextOutput,
	verbosity = M.VERBOSITY_DEFAULT,
	instances = {}
}

local LuaUnit_MT = {
	__index = M.LuaUnit
}

if EXPORT_ASSERT_TO_GLOBALS then
	LuaUnit = M.LuaUnit
end

function M.LuaUnit.new()
	local newInstance = setmetatable({}, LuaUnit_MT)

	return newInstance
end

function M.LuaUnit.asFunction(aObject)
	if type(aObject) == "function" then
		return aObject
	end
end

function M.LuaUnit.splitClassMethod(someName)
	local separator = string.find(someName, ".", 1, true)

	if separator then
		return someName:sub(1, separator - 1), someName:sub(separator + 1)
	end

	return nil, someName
end

function M.LuaUnit.isMethodTestName(s)
	return string.sub(s, 1, 4):lower() == "test"
end

function M.LuaUnit.isTestName(s)
	return string.sub(s, 1, 4):lower() == "test"
end

function M.LuaUnit.collectTests()
	local testNames = {}

	for k, _ in pairs(_G) do
		if type(k) == "string" and M.LuaUnit.isTestName(k) then
			table.insert(testNames, k)
		end
	end

	table.sort(testNames)

	return testNames
end

function M.LuaUnit.parseCmdLine(cmdLine)
	local result, state = {}
	local SET_OUTPUT = 1
	local SET_PATTERN = 2
	local SET_EXCLUDE = 3
	local SET_FNAME = 4
	local SET_REPEAT = 5

	if cmdLine == nil then
		return result
	end

	local function parseOption(option)
		if option == "--help" or option == "-h" then
			result.help = true

			return
		elseif option == "--version" then
			result.version = true

			return
		elseif option == "--verbose" or option == "-v" then
			result.verbosity = M.VERBOSITY_VERBOSE

			return
		elseif option == "--quiet" or option == "-q" then
			result.verbosity = M.VERBOSITY_QUIET

			return
		elseif option == "--error" or option == "-e" then
			result.quitOnError = true

			return
		elseif option == "--failure" or option == "-f" then
			result.quitOnFailure = true

			return
		elseif option == "--shuffle" or option == "-s" then
			result.shuffle = true

			return
		elseif option == "--output" or option == "-o" then
			state = SET_OUTPUT

			return state
		elseif option == "--name" or option == "-n" then
			state = SET_FNAME

			return state
		elseif option == "--repeat" or option == "-r" then
			state = SET_REPEAT

			return state
		elseif option == "--pattern" or option == "-p" then
			state = SET_PATTERN

			return state
		elseif option == "--exclude" or option == "-x" then
			state = SET_EXCLUDE

			return state
		end

		error("Unknown option: " .. option, 3)
	end

	local function setArg(cmdArg, state)
		if state == SET_OUTPUT then
			result.output = cmdArg

			return
		elseif state == SET_FNAME then
			result.fname = cmdArg

			return
		elseif state == SET_REPEAT then
			result.exeRepeat = tonumber(cmdArg) or error("Malformed -r argument: " .. cmdArg)

			return
		elseif state == SET_PATTERN then
			if result.pattern then
				table.insert(result.pattern, cmdArg)
			else
				result.pattern = {
					cmdArg
				}
			end

			return
		elseif state == SET_EXCLUDE then
			local notArg = "!" .. cmdArg

			if result.pattern then
				table.insert(result.pattern, notArg)
			else
				result.pattern = {
					notArg
				}
			end

			return
		end

		error("Unknown parse state: " .. state)
	end

	for i, cmdArg in ipairs(cmdLine) do
		if state ~= nil then
			setArg(cmdArg, state, result)

			state = nil
		elseif cmdArg:sub(1, 1) == "-" then
			state = parseOption(cmdArg)
		elseif result.testNames then
			table.insert(result.testNames, cmdArg)
		else
			result.testNames = {
				cmdArg
			}
		end
	end

	if result.help then
		M.LuaUnit.help()
	end

	if result.version then
		M.LuaUnit.version()
	end

	if state ~= nil then
		error("Missing argument after " .. cmdLine[#cmdLine], 2)
	end

	return result
end

function M.LuaUnit.help()
	print(M.USAGE)
	os.exit(0)
end

function M.LuaUnit.version()
	print("LuaUnit v" .. M.VERSION .. " by Philippe Fremy <phil@freehackers.org>")
	os.exit(0)
end

local NodeStatus = {
	__class__ = "NodeStatus"
}
local NodeStatus_MT = {
	__index = NodeStatus
}

M.NodeStatus = NodeStatus
NodeStatus.SUCCESS = "SUCCESS"
NodeStatus.SKIP = "SKIP"
NodeStatus.FAIL = "FAIL"
NodeStatus.ERROR = "ERROR"

function NodeStatus.new(number, testName, className, isCoroutine)
	local t = {
		number = number,
		testName = testName,
		className = className,
		isCoroutine = isCoroutine
	}

	setmetatable(t, NodeStatus_MT)
	t:success()

	return t
end

function NodeStatus:success()
	self.status = self.SUCCESS
	self.msg = nil
	self.stackTrace = nil
	self.isCoroutineDone = false
	self.nextCount = 0
end

function NodeStatus:skip(msg)
	self.status = self.SKIP
	self.msg = msg
	self.stackTrace = nil
end

function NodeStatus:fail(msg, stackTrace)
	self.status = self.FAIL
	self.msg = msg
	self.stackTrace = stackTrace
end

function NodeStatus:error(msg, stackTrace)
	self.status = self.ERROR
	self.msg = msg
	self.stackTrace = stackTrace
end

function NodeStatus:isSuccess()
	return self.status == NodeStatus.SUCCESS
end

function NodeStatus:isNotSuccess()
	return self.status == NodeStatus.FAIL or self.status == NodeStatus.ERROR or self.status == NodeStatus.SKIP
end

function NodeStatus:isSkipped()
	return self.status == NodeStatus.SKIP
end

function NodeStatus:isFailure()
	return self.status == NodeStatus.FAIL
end

function NodeStatus:isError()
	return self.status == NodeStatus.ERROR
end

function NodeStatus:statusXML()
	if self:isError() then
		return table.concat({
			"            <error type=\"",
			xmlEscape(self.msg),
			"\">\n",
			"                <![CDATA[",
			xmlCDataEscape(self.stackTrace),
			"]]></error>\n"
		})
	elseif self:isFailure() then
		return table.concat({
			"            <failure type=\"",
			xmlEscape(self.msg),
			"\">\n",
			"                <![CDATA[",
			xmlCDataEscape(self.stackTrace),
			"]]></failure>\n"
		})
	elseif self:isSkipped() then
		return table.concat({
			"            <skipped>",
			xmlEscape(self.msg),
			"</skipped>\n"
		})
	end

	return "            <passed/>\n"
end

local function conditional_plural(number, singular)
	local suffix = ""

	if number ~= 1 then
		suffix = singular:sub(-2) == "ss" and "es" or "s"
	end

	return string.format("%d %s%s", number, singular, suffix)
end

function M.LuaUnit.statusLine(result)
	local s = {
		string.format("Ran %d tests in %0.3f seconds", result.runCount, result.duration),
		conditional_plural(result.successCount, "success")
	}

	if result.notSuccessCount > 0 then
		if result.failureCount > 0 then
			table.insert(s, conditional_plural(result.failureCount, "failure"))
		end

		if result.errorCount > 0 then
			table.insert(s, conditional_plural(result.errorCount, "error"))
		end
	else
		table.insert(s, "0 failures")
	end

	if result.skippedCount > 0 then
		table.insert(s, string.format("%d skipped", result.skippedCount))
	end

	if result.nonSelectedCount > 0 then
		table.insert(s, string.format("%d non-selected", result.nonSelectedCount))
	end

	return table.concat(s, ", ")
end

function M.LuaUnit:startSuite(selectedCount, nonSelectedCount)
	self.result = {
		currentTestNumber = 0,
		failureCount = 0,
		errorCount = 0,
		runCount = 0,
		successCount = 0,
		skippedCount = 0,
		notSuccessCount = 0,
		suiteStarted = true,
		currentClassName = "",
		selectedCount = selectedCount,
		nonSelectedCount = nonSelectedCount,
		startTime = os.clock(),
		startDate = os.date(os.getenv("LUAUNIT_DATEFMT")),
		startIsodate = os.date("%Y-%m-%dT%H:%M:%S"),
		patternIncludeFilter = self.patternIncludeFilter,
		allTests = {},
		failedTests = {},
		errorTests = {},
		skippedTests = {}
	}
	self.outputType = self.outputType or TextOutput
	self.output = self.outputType.new(self)

	self.output:startSuite()
end

function M.LuaUnit:startClass(className, classInstance)
	self.result.currentClassName = className

	self.output:startClass(className)
	self:setupClass(className, classInstance)
end

function M.LuaUnit:startTest(testName, isCoroutine)
	self.result.currentTestNumber = self.result.currentTestNumber + 1
	self.result.runCount = self.result.runCount + 1
	self.result.currentNode = NodeStatus.new(self.result.currentTestNumber, testName, self.result.currentClassName, isCoroutine)
	self.result.currentNode.startTime = os.clock()

	table.insert(self.result.allTests, self.result.currentNode)
	self.output:startTest(testName)
end

function M.LuaUnit:updateStatus(err)
	if err.status == NodeStatus.SUCCESS then
		return
	end

	local node = self.result.currentNode

	if node.status ~= NodeStatus.SUCCESS then
		return
	end

	if err.status == NodeStatus.FAIL then
		node:fail(err.msg, err.trace)
		table.insert(self.result.failedTests, node)
	elseif err.status == NodeStatus.ERROR then
		node:error(err.msg, err.trace)
		table.insert(self.result.errorTests, node)
	elseif err.status == NodeStatus.SKIP then
		node:skip(err.msg)
		table.insert(self.result.skippedTests, node)
	else
		error("No such status: " .. prettystr(err.status))
	end

	self.output:updateStatus(node)
end

function M.LuaUnit:endTest()
	local node = self.result.currentNode

	node.duration = os.clock() - node.startTime
	node.startTime = nil

	self.output:endTest(node)

	if node:isSuccess() then
		self.result.successCount = self.result.successCount + 1
	elseif node:isError() then
		if self.quitOnError or self.quitOnFailure then
			print("\nERROR during LuaUnit test execution:\n" .. node.msg)

			self.result.aborted = true
		end
	elseif node:isFailure() then
		if self.quitOnFailure then
			print("\nFailure during LuaUnit test execution:\n" .. node.msg)

			self.result.aborted = true
		end
	elseif node:isSkipped() then
		self.result.runCount = self.result.runCount - 1
	else
		error("No such node status: " .. prettystr(node.status))
	end

	self.result.currentNode = nil
end

function M.LuaUnit:endClass()
	self:teardownClass(self.lastClassName, self.lastClassInstance)
	self.output:endClass()
end

function M.LuaUnit:endSuite()
	if self.result.suiteStarted == false then
		error("LuaUnit:endSuite() -- suite was already ended")
	end

	self.result.duration = os.clock() - self.result.startTime
	self.result.suiteStarted = false
	self.result.failureCount = #self.result.failedTests
	self.result.errorCount = #self.result.errorTests
	self.result.notSuccessCount = self.result.failureCount + self.result.errorCount
	self.result.skippedCount = #self.result.skippedTests

	self.output:endSuite()
end

function M.LuaUnit:setOutputType(outputType, fname)
	if outputType:upper() == "NIL" then
		self.outputType = NilOutput

		return
	end

	if outputType:upper() == "TAP" then
		self.outputType = TapOutput

		return
	end

	if outputType:upper() == "JUNIT" then
		self.outputType = JUnitOutput

		if fname then
			self.fname = fname
		end

		return
	end

	if outputType:upper() == "TEXT" then
		self.outputType = TextOutput

		return
	end

	error("No such format: " .. outputType, 2)
end

function M.LuaUnit:protectedCall(classInstance, methodInstance, prettyFuncName, isCoroutine)
	local function err_handler(e)
		return {
			status = NodeStatus.ERROR,
			msg = e,
			trace = string.sub(debug.traceback("", 1), 2)
		}
	end

	local ok, err

	if isCoroutine == true then
		local co = coroutine.create(methodInstance)
		local ret = true
		local nextCount = 0

		while true do
			if classInstance then
				ok, err = xpcall(function()
					ret, nextCount = coroutine.resume(co, classInstance)
				end, err_handler)
			else
				ok, err = xpcall(function()
					ret, nextCount = coroutine.resume(co)
				end, err_handler)
			end

			if not ok or not ret then
				ok = false
				err = {
					status = NodeStatus.ERROR,
					msg = nextCount,
					trace = string.sub(debug.traceback("", 1), 2)
				}

				break
			elseif nextCount == 0 then
				break
			end

			local Time = require("Core.Common.Time")

			nextCount = nextCount * 1000

			while nextCount > 0 do
				local start = Time.getMillisecond()

				self.loop()

				nextCount = nextCount - (Time.getMillisecond() - start)
			end
		end
	elseif classInstance then
		ok, err = xpcall(function()
			methodInstance(classInstance)
		end, err_handler)
	else
		ok, err = xpcall(function()
			methodInstance()
		end, err_handler)
	end

	if ok then
		return {
			status = NodeStatus.SUCCESS
		}
	end

	local iter_msg

	iter_msg = self.exeRepeat and "iteration " .. self.currentCount
	err.msg, err.status = M.adjust_err_msg_with_iter(err.msg, iter_msg)

	if err.status == NodeStatus.SUCCESS or err.status == NodeStatus.SKIP then
		err.trace = nil

		return err
	end

	if prettyFuncName then
		err.trace = err.trace:gsub("in (%a+) 'methodInstance'", "in %1 '" .. prettyFuncName .. "'")
	end

	if STRIP_LUAUNIT_FROM_STACKTRACE then
		err.trace = stripLuaunitTrace2(err.trace, err.msg)
	end

	return err
end

function M.LuaUnit:execOneFunction(className, methodName, classInstance, methodInstance, isCoroutine)
	if type(methodInstance) ~= "function" then
		self:unregisterSuite()
		error(tostring(methodName) .. " must be a function, not " .. type(methodInstance))
	end

	local prettyFuncName

	if className == nil then
		className = "[TestFunctions]"
		prettyFuncName = methodName
	else
		prettyFuncName = className .. "." .. methodName
	end

	if self.lastClassName ~= className then
		if self.lastClassName ~= nil then
			self:endClass()
		end

		self:startClass(className, classInstance)

		self.lastClassName = className
		self.lastClassInstance = classInstance
	end

	self:startTest(prettyFuncName, isCoroutine)

	local node = self.result.currentNode

	for iter_n = 1, self.exeRepeat or 1 do
		if node:isNotSuccess() then
			break
		end

		self.currentCount = iter_n

		if classInstance then
			local func = self.asFunction(classInstance.setUp) or self.asFunction(classInstance.Setup) or self.asFunction(classInstance.setup) or self.asFunction(classInstance.SetUp)

			if func then
				self:updateStatus(self:protectedCall(classInstance, func, className .. ".setUp"))
			end
		end

		if node:isSuccess() then
			self:updateStatus(self:protectedCall(classInstance, methodInstance, prettyFuncName, isCoroutine))
		end

		if classInstance then
			local func = self.asFunction(classInstance.tearDown) or self.asFunction(classInstance.TearDown) or self.asFunction(classInstance.teardown) or self.asFunction(classInstance.Teardown)

			if func then
				self:updateStatus(self:protectedCall(classInstance, func, className .. ".tearDown"))
			end
		end
	end

	self:endTest()
end

function M.LuaUnit.expandOneClass(result, className, classInstance)
	for methodName, methodInstance in sortedPairs(classInstance) do
		if M.LuaUnit.asFunction(methodInstance) and M.LuaUnit.isMethodTestName(methodName) then
			table.insert(result, {
				className .. "." .. methodName,
				classInstance
			})
		end
	end
end

function M.LuaUnit.expandClasses(listOfNameAndInst)
	local result = {}

	for i, v in ipairs(listOfNameAndInst) do
		local name, instance = v[1], v[2]

		if M.LuaUnit.asFunction(instance) then
			table.insert(result, {
				name,
				instance
			})
		else
			if type(instance) ~= "table" then
				error("Instance must be a table or a function, not a " .. type(instance) .. " with value " .. prettystr(instance))
			end

			local className, methodName = M.LuaUnit.splitClassMethod(name)

			if className then
				local methodInstance = instance[methodName]

				if methodInstance == nil then
					error("Could not find method in class " .. tostring(className) .. " for method " .. tostring(methodName))
				end

				table.insert(result, {
					name,
					instance
				})
			else
				M.LuaUnit.expandOneClass(result, name, instance)
			end
		end
	end

	return result
end

function M.LuaUnit.applyPatternFilter(patternIncFilter, listOfNameAndInst)
	local included, excluded = {}, {}

	for i, v in ipairs(listOfNameAndInst) do
		if patternFilter(patternIncFilter, v[1]) then
			table.insert(included, v)
		else
			table.insert(excluded, v)
		end
	end

	return included, excluded
end

local function getKeyInListWithGlobalFallback(key, listOfNameAndInst)
	local result

	for i, v in ipairs(listOfNameAndInst) do
		if listOfNameAndInst[i][1] == key then
			result = listOfNameAndInst[i][2]

			break
		end
	end

	if not M.LuaUnit.asFunction(result) then
		result = _G[key]
	end

	return result
end

function M.LuaUnit:setupSuite(listOfNameAndInst)
	local setupSuite = getKeyInListWithGlobalFallback("setupSuite", listOfNameAndInst)

	if self.asFunction(setupSuite) then
		self:updateStatus(self:protectedCall(nil, setupSuite, "setupSuite"))
	end
end

function M.LuaUnit:teardownSuite(listOfNameAndInst)
	local teardownSuite = getKeyInListWithGlobalFallback("teardownSuite", listOfNameAndInst)

	if self.asFunction(teardownSuite) then
		self:updateStatus(self:protectedCall(nil, teardownSuite, "teardownSuite"))
	end
end

function M.LuaUnit:setupClass(className, instance)
	if type(instance) == "table" and self.asFunction(instance.setupClass) then
		self:updateStatus(self:protectedCall(instance, instance.setupClass, className .. ".setupClass"))
	end
end

function M.LuaUnit:teardownClass(className, instance)
	if type(instance) == "table" and self.asFunction(instance.teardownClass) then
		self:updateStatus(self:protectedCall(instance, instance.teardownClass, className .. ".teardownClass"))
	end
end

function M.LuaUnit:internalRunSuiteByInstances(listOfNameAndInst, isCoroutine)
	local expandedList = self.expandClasses(listOfNameAndInst)

	if self.shuffle then
		randomizeTable(expandedList)
	end

	local filteredList, filteredOutList = self.applyPatternFilter(self.patternIncludeFilter, expandedList)

	self:startSuite(#filteredList, #filteredOutList)
	self:setupSuite(listOfNameAndInst)

	for i, v in ipairs(filteredList) do
		local name, instance = v[1], v[2]

		if M.LuaUnit.asFunction(instance) then
			self:execOneFunction(nil, name, nil, instance, isCoroutine)
		else
			assert(type(instance) == "table")

			local className, methodName = M.LuaUnit.splitClassMethod(name)

			assert(className ~= nil)

			local methodInstance = instance[methodName]

			assert(methodInstance ~= nil)
			self:execOneFunction(className, methodName, instance, methodInstance, isCoroutine)
		end

		if self.result.aborted then
			break
		end
	end

	if self.lastClassName ~= nil then
		self:endClass()
	end

	self:teardownSuite(listOfNameAndInst)
	self:endSuite()

	if self.result.aborted then
		print("LuaUnit ABORTED (as requested by --error or --failure option)")
		self:unregisterSuite()
		os.exit(-2)
	end
end

function M.LuaUnit:internalRunSuiteByNames(listOfName, isCoroutine)
	local instanceName, instance
	local listOfNameAndInst = {}

	for i, name in ipairs(listOfName) do
		local className, methodName = M.LuaUnit.splitClassMethod(name)

		if className then
			instanceName = className
			instance = _G[instanceName]

			if instance == nil then
				self:unregisterSuite()
				error("No such name in global space: " .. instanceName)
			end

			if type(instance) ~= "table" then
				self:unregisterSuite()
				error("Instance of " .. instanceName .. " must be a table, not " .. type(instance))
			end

			local methodInstance = instance[methodName]

			if methodInstance == nil then
				self:unregisterSuite()
				error("Could not find method in class " .. tostring(className) .. " for method " .. tostring(methodName))
			end
		else
			instanceName = name
			instance = _G[instanceName]
		end

		if instance == nil then
			self:unregisterSuite()
			error("No such name in global space: " .. instanceName)
		end

		if type(instance) ~= "table" and type(instance) ~= "function" then
			self:unregisterSuite()
			error("Name must match a function or a table: " .. instanceName)
		end

		table.insert(listOfNameAndInst, {
			name,
			instance
		})
	end

	self:internalRunSuiteByInstances(listOfNameAndInst, isCoroutine)
end

function M.LuaUnit.run(...)
	local runner = M.LuaUnit.new()

	return runner:runSuite(...)
end

function M.LuaUnit.runWithLoop(...)
	local runner = M.LuaUnit.new()
	local metas = {
		...
	}

	runner.loop = metas[1]

	table.remove(metas, 1)

	return runner:runSuiteWithLoop(unpack(metas))
end

function M.LuaUnit:registerSuite()
	M.LuaUnit.instances[#M.LuaUnit.instances + 1] = self
end

function M.unregisterCurrentSuite()
	table.remove(M.LuaUnit.instances, #M.LuaUnit.instances)
end

function M.LuaUnit:unregisterSuite()
	local instanceIdx

	for i, instance in ipairs(M.LuaUnit.instances) do
		if instance == self then
			instanceIdx = i

			break
		end
	end

	if instanceIdx ~= nil then
		table.remove(M.LuaUnit.instances, instanceIdx)
	end
end

function M.LuaUnit:initFromArguments(...)
	local args = {
		...
	}

	if type(args[1]) == "table" and args[1].__class__ == "LuaUnit" then
		table.remove(args, 1)
	end

	if #args == 0 then
		args = cmdline_argv
	end

	local options = pcall_or_abort(M.LuaUnit.parseCmdLine, args)

	self.verbosity = options.verbosity
	self.quitOnError = options.quitOnError
	self.quitOnFailure = options.quitOnFailure
	self.exeRepeat = options.exeRepeat
	self.patternIncludeFilter = options.pattern
	self.shuffle = options.shuffle
	options.output = options.output or os.getenv("LUAUNIT_OUTPUT")
	options.fname = options.fname or os.getenv("LUAUNIT_JUNIT_FNAME")

	if options.output then
		if options.output:lower() == "junit" and options.fname == nil then
			print("With junit output, a filename must be supplied with -n or --name")
			os.exit(-1)
		end

		pcall_or_abort(self.setOutputType, self, options.output, options.fname)
	end

	return options.testNames
end

function M.LuaUnit:runSuite(...)
	testNames = self:initFromArguments(...)

	self:registerSuite()
	self:internalRunSuiteByNames(testNames or M.LuaUnit.collectTests(), false)
	self:unregisterSuite()

	return self.result.notSuccessCount
end

function M.LuaUnit:runSuiteWithLoop(...)
	testNames = self:initFromArguments(...)

	self:registerSuite()
	self:internalRunSuiteByNames(testNames or M.LuaUnit.collectTests(), true)
	self:unregisterSuite()

	return self.result.notSuccessCount
end

function M.LuaUnit:runSuiteByInstances(listOfNameAndInst, commandLineArguments)
	testNames = self:initFromArguments(commandLineArguments)

	self:registerSuite()
	self:internalRunSuiteByInstances(listOfNameAndInst)
	self:unregisterSuite()

	return self.result.notSuccessCount
end

M.run = M.LuaUnit.run
M.Run = M.LuaUnit.run

function M:setVerbosity(verbosity)
	M.LuaUnit.verbosity = verbosity
end

M.set_verbosity = M.setVerbosity
M.SetVerbosity = M.setVerbosity

return M
