-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\RpcDataVerifyCodec.lua

local CompactPropertySchema = require("Core.PropertySync.CompactPropertySchema")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("RpcDataVerifyCodec")
local isVisible = CompactPropertySchema.isVisible
local RpcDataVerifyCodec = {}
local VERIFY_MARK = "__compact_verify__"
local VERIFY_KIND = "__kind__"
local VERIFY_KIND_ENTITY = "entity"
local VERIFY_KIND_LAZY = "lazy"
local VERIFY_COMPACT = "__compact__"
local VERIFY_RAW = "__raw__"
local VERIFY_META = "__meta__"
local LEGACY_CUSTOM_TYPE = "__tp__"
local META_ID = "__id__"
local META_CLASS = "__class__"
local ROOT_PROPERTIES = "__Properties__"
local FIXED_FIELDS = "_f_"
local UNFIXED_FIELDS = "_u_"
local META_CUSTOM_TYPE = "__ct__"
local META_CUSTOM_VALUE = "__v__"
local SKIP_KEYS = {
	__scope__ = true,
	__cid__ = true,
	__class__ = true
}

local function isCustomObject(value)
	if type(value) ~= "table" then
		return false
	end

	local classType = rawget(value, "__ClassType")

	return type(classType) == "table" and classType.typeName ~= nil
end

local function toVerifyRawValue(value, seen, fromCustomProps)
	if isCustomObject(value) then
		local classType = rawget(value, "__ClassType")
		local typeName = classType and classType.typeName
		local rawValue

		if type(rawget(value, "_properties")) == "table" then
			rawValue = rawget(value, "_properties")
		elseif type(value.getRawTable) == "function" then
			rawValue = value:getRawTable()
		else
			rawValue = rawget(value, "_properties") or {}
		end

		rawValue = toVerifyRawValue(rawValue, seen, rawValue == rawget(value, "_properties"))

		if type(rawValue) == "table" then
			if rawValue[LEGACY_CUSTOM_TYPE] == nil then
				rawValue[LEGACY_CUSTOM_TYPE] = typeName
			end

			if rawValue[META_ID] == nil then
				rawValue[META_ID] = rawget(value, "_id")
			end
		end

		return rawValue
	end

	if type(value) ~= "table" then
		return value
	end

	seen = seen or {}

	if seen[value] ~= nil then
		return seen[value]
	end

	local out = {}

	seen[value] = out

	for k, v in pairs(value) do
		if k ~= "__ClassType" and k ~= "_properties" and (not fromCustomProps or k ~= "_") then
			out[k] = toVerifyRawValue(v, seen, false)
		end
	end

	return out
end

local function toStatRawValue(value, seen)
	if isCustomObject(value) then
		local rawValue

		if type(value.getRawTable) == "function" then
			rawValue = value:getRawTable()
		else
			rawValue = rawget(value, "_properties") or {}
		end

		return toStatRawValue(rawValue, seen)
	end

	if type(value) ~= "table" then
		return value
	end

	seen = seen or {}

	if seen[value] ~= nil then
		return seen[value]
	end

	local out = {}

	seen[value] = out

	for k, v in pairs(value) do
		if k ~= "__ClassType" and k ~= "_properties" then
			out[k] = toStatRawValue(v, seen)
		end
	end

	return out
end

local function collectMapKeys(map)
	if type(map) ~= "table" then
		return ""
	end

	local keys = {}

	for k, _ in pairs(map) do
		keys[#keys + 1] = tostring(k)
	end

	table.sort(keys)

	return table.concat(keys, ",")
end

local function countMapEntries(map)
	if type(map) ~= "table" then
		return 0
	end

	local count = 0

	for _, _ in pairs(map) do
		count = count + 1
	end

	return count
end

local function getValueSummary(value)
	local valueType = type(value)

	if valueType ~= "table" then
		return valueType, 0, 0, 0, nil
	end

	if value[META_CUSTOM_TYPE] ~= nil then
		local body = value[META_CUSTOM_VALUE] or {}

		return "custom", countMapEntries(body[FIXED_FIELDS]), countMapEntries(body[UNFIXED_FIELDS]), 0, value[META_CUSTOM_TYPE]
	end

	return "table", 0, 0, countMapEntries(value), nil
end

local function safeEncodedSize(protoCodec, value)
	if protoCodec == nil then
		return nil
	end

	local ok, bytes = pcall(function()
		return protoCodec:encode(value)
	end)

	if ok and type(bytes) == "string" then
		return #bytes
	end

	return nil
end

local function formatSizePart(label, rawSize, compactSize, value)
	if rawSize == nil or compactSize == nil then
		return string.format("%s:%s:size_error", tostring(label), type(value))
	end

	local savedSize = rawSize - compactSize
	local savedRatio = rawSize > 0 and savedSize * 100 / rawSize or 0

	return string.format("%s:%s:%d>%d:%+d:%.1f%%", tostring(label), type(value), rawSize, compactSize, savedSize, savedRatio)
end

local function sortKeys(keys)
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
end

local function makeFieldSizePart(rawKey, rawValue, compactKey, compactValue, label, protoCodec)
	local rawSize = safeEncodedSize(protoCodec, {
		[rawKey] = rawValue
	})
	local compactSize = safeEncodedSize(protoCodec, {
		[compactKey] = compactValue
	})

	return formatSizePart(label or rawKey, rawSize, compactSize, rawValue)
end

local function makeTopSizeDetail(rawDict, compactDict, protoCodec)
	if type(rawDict) ~= "table" or type(compactDict) ~= "table" then
		return ""
	end

	local keySet = {}

	for k, _ in pairs(rawDict) do
		if not SKIP_KEYS[k] then
			keySet[k] = true
		end
	end

	for k, _ in pairs(compactDict) do
		if not SKIP_KEYS[k] then
			keySet[k] = true
		end
	end

	local keys = {}

	for k, _ in pairs(keySet) do
		keys[#keys + 1] = k
	end

	sortKeys(keys)

	local parts = {}

	for _, k in ipairs(keys) do
		parts[#parts + 1] = makeFieldSizePart(k, rawDict[k], k, compactDict[k], k, protoCodec)
	end

	return table.concat(parts, "|")
end

local function addSectionSizeParts(parts, rawSection, compactSection, schema, protoCodec, fixed)
	if type(compactSection) ~= "table" then
		return
	end

	local keys = {}

	for k, _ in pairs(compactSection) do
		keys[#keys + 1] = k
	end

	sortKeys(keys)

	for _, k in ipairs(keys) do
		local rawKey = k
		local label = tostring(k)

		if fixed and schema ~= nil then
			rawKey = schema.indexToName[k] or k
			label = string.format("%s#%s", tostring(rawKey), tostring(k))
		end

		local rawValue = type(rawSection) == "table" and rawSection[rawKey] or nil
		local compactValue = compactSection[k]

		parts[#parts + 1] = makeFieldSizePart(rawKey, rawValue, k, compactValue, label, protoCodec)
	end
end

local function makePropertySizeDetail(rawProps, compactProps, schema, protoCodec)
	if type(compactProps) ~= "table" then
		return ""
	end

	local parts = {}

	addSectionSizeParts(parts, rawProps, compactProps[FIXED_FIELDS], schema, protoCodec, true)
	addSectionSizeParts(parts, rawProps, compactProps[UNFIXED_FIELDS], schema, protoCodec, false)

	return table.concat(parts, "|")
end

local function makeCustomSizeDetail(topKey, rawValue, compactValue, protoCodec)
	if type(compactValue) ~= "table" or compactValue[META_CUSTOM_TYPE] == nil then
		return nil
	end

	local typeName = compactValue[META_CUSTOM_TYPE]
	local schema = CompactPropertySchema.getCustomSchema(typeName)
	local body = compactValue[META_CUSTOM_VALUE] or {}
	local rawTable = type(rawValue) == "table" and rawValue or nil
	local parts = {}

	addSectionSizeParts(parts, rawTable, body[FIXED_FIELDS], schema, protoCodec, true)
	addSectionSizeParts(parts, rawTable, body[UNFIXED_FIELDS], schema, protoCodec, false)

	if #parts == 0 then
		return string.format("%s:%s:empty", tostring(topKey), tostring(typeName))
	end

	return string.format("%s:%s{%s}", tostring(topKey), tostring(typeName), table.concat(parts, "|"))
end

local function makeTopCustomSizeDetail(rawDict, compactDict, protoCodec)
	if type(rawDict) ~= "table" or type(compactDict) ~= "table" then
		return ""
	end

	local keys = {}

	for k, v in pairs(compactDict) do
		if not SKIP_KEYS[k] and type(v) == "table" and v[META_CUSTOM_TYPE] ~= nil then
			keys[#keys + 1] = k
		end
	end

	sortKeys(keys)

	local parts = {}

	for _, k in ipairs(keys) do
		local detail = makeCustomSizeDetail(k, rawDict[k], compactDict[k], protoCodec)

		if detail ~= nil then
			parts[#parts + 1] = detail
		end
	end

	return table.concat(parts, "||")
end

local function makeSectionDetail(section)
	if type(section) ~= "table" then
		return ""
	end

	local keys = {}

	for k, _ in pairs(section) do
		keys[#keys + 1] = k
	end

	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)

	local parts = {}

	for _, k in ipairs(keys) do
		local valueType, fixedCount, unfixedCount, tableCount, customType = getValueSummary(section[k])

		if customType ~= nil then
			parts[#parts + 1] = string.format("%s:%s:%s:f%d:u%d", tostring(k), valueType, tostring(customType), fixedCount, unfixedCount)
		elseif valueType == "table" then
			parts[#parts + 1] = string.format("%s:%s:n%d", tostring(k), valueType, tableCount)
		else
			parts[#parts + 1] = string.format("%s:%s", tostring(k), valueType)
		end
	end

	return table.concat(parts, "|")
end

local function fillSectionStats(prefix, section, stat)
	if type(section) ~= "table" then
		stat[prefix .. "FixedCount"] = 0
		stat[prefix .. "UnfixedCount"] = 0
		stat[prefix .. "FixedKeys"] = ""
		stat[prefix .. "UnfixedKeys"] = ""
		stat[prefix .. "FixedDetail"] = ""
		stat[prefix .. "UnfixedDetail"] = ""

		return
	end

	local fixedFields = section[FIXED_FIELDS]
	local unfixedFields = section[UNFIXED_FIELDS]

	stat[prefix .. "FixedCount"] = countMapEntries(fixedFields)
	stat[prefix .. "UnfixedCount"] = countMapEntries(unfixedFields)
	stat[prefix .. "FixedKeys"] = collectMapKeys(fixedFields)
	stat[prefix .. "UnfixedKeys"] = collectMapKeys(unfixedFields)
	stat[prefix .. "FixedDetail"] = makeSectionDetail(fixedFields)
	stat[prefix .. "UnfixedDetail"] = makeSectionDetail(unfixedFields)
end

local function fillCompactStats(compactDict, stat)
	if type(compactDict) ~= "table" then
		return
	end

	fillSectionStats("prop", compactDict[ROOT_PROPERTIES], stat)

	local topKeys = {}

	for k, _ in pairs(compactDict) do
		if not SKIP_KEYS[k] and k ~= ROOT_PROPERTIES then
			topKeys[#topKeys + 1] = tostring(k)
		end
	end

	table.sort(topKeys)

	stat.topKeyCount = #topKeys
	stat.topKeys = table.concat(topKeys, ",")
end

local function fillCompactSizeStats(rawDict, compactDict, protoCodec, stat)
	if type(rawDict) ~= "table" or type(compactDict) ~= "table" then
		return
	end

	local schema = CompactPropertySchema.getEntitySchema(compactDict[META_CLASS])

	stat.topSizeDetail = makeTopSizeDetail(rawDict, compactDict, protoCodec)
	stat.propSizeDetail = makePropertySizeDetail(rawDict[ROOT_PROPERTIES], compactDict[ROOT_PROPERTIES], schema, protoCodec)
	stat.topCustomSizeDetail = makeTopCustomSizeDetail(rawDict, compactDict, protoCodec)
end

function RpcDataVerifyCodec.logCompactInitDataStat(log, path, entityType, entityId, stat)
	if stat == nil then
		return
	end

	if stat.rawError ~= nil then
		log:warn("[CompactClientInitData] path=%s class=%s entityType=%s entityId=%s scope=%s compact=%d rawEncodeError=%s", path, tostring(stat.className), tostring(entityType), tostring(entityId), tostring(stat.scope), stat.compactSize or 0, tostring(stat.rawError))

		return
	end

	log:info("[CompactClientInitData] path=%s class=%s entityType=%s entityId=%s scope=%s raw=%d compact=%d saved=%d ratio=%.2f%%", path, tostring(stat.className), tostring(entityType), tostring(entityId), tostring(stat.scope), stat.rawSize, stat.compactSize, stat.savedSize, stat.savedRatio)
	log:info("[CompactClientInitDataDetail] path=%s class=%s entityType=%s entityId=%s topKeyCount=%d topKeys=[%s] propFixedCount=%d propUnfixedCount=%d propFixedKeys=[%s] propUnfixedKeys=[%s] propFixedDetail=[%s] propUnfixedDetail=[%s]", path, tostring(stat.className), tostring(entityType), tostring(entityId), stat.topKeyCount or 0, tostring(stat.topKeys or ""), stat.propFixedCount or 0, stat.propUnfixedCount or 0, tostring(stat.propFixedKeys or ""), tostring(stat.propUnfixedKeys or ""), tostring(stat.propFixedDetail or ""), tostring(stat.propUnfixedDetail or ""))
	log:info("[CompactClientInitDataSize] path=%s class=%s entityType=%s entityId=%s topSize=[%s] propSize=[%s] topCustomSize=[%s]", path, tostring(stat.className), tostring(entityType), tostring(entityId), tostring(stat.topSizeDetail or ""), tostring(stat.propSizeDetail or ""), tostring(stat.topCustomSizeDetail or ""))
end

local function hasTableKey(tbl, key)
	if type(tbl) ~= "table" then
		return false
	end

	for k, _ in pairs(tbl) do
		if k == key then
			return true
		end
	end

	return false
end

local function formatVerifyValue(value)
	local valueType = type(value)

	if valueType == "string" then
		if #value > 80 then
			return string.format("%q...", string.sub(value, 1, 80))
		end

		return string.format("%q", value)
	end

	if valueType ~= "table" then
		return tostring(value)
	end

	return string.format("table:%s", tostring(value))
end

local function deepCompareForVerify(left, right, path, options)
	local leftType = type(left)
	local rightType = type(right)

	if leftType ~= rightType then
		return false, path, formatVerifyValue(left), formatVerifyValue(right), string.format("type %s ~= %s", leftType, rightType)
	end

	if leftType == "userdata" and options and options.ignoreUserdataIdentity then
		return true
	end

	if leftType ~= "table" then
		if left ~= right then
			return false, path, formatVerifyValue(left), formatVerifyValue(right), "value mismatch"
		end

		return true
	end

	for k, lv in pairs(left) do
		if not hasTableKey(right, k) then
			return false, string.format("%s.%s(%s)", path, tostring(k), type(k)), formatVerifyValue(lv), "nil", "right missing key"
		end

		local ok, diffPath, lValue, rValue, reason = deepCompareForVerify(lv, right[k], string.format("%s.%s(%s)", path, tostring(k), type(k)), options)

		if not ok then
			return ok, diffPath, lValue, rValue, reason
		end
	end

	for k, rv in pairs(right) do
		if not hasTableKey(left, k) then
			return false, string.format("%s.%s(%s)", path, tostring(k), type(k)), "nil", formatVerifyValue(rv), "left missing key"
		end
	end

	return true
end

local function verifyDecodedEqual(kind, context, rawDecoded, compactDecoded)
	local options = {
		ignoreUserdataIdentity = type(kind) == "string" and string.sub(kind, 1, 5) == "lazy."
	}
	local ok, diffPath, rawValue, compactValue, reason = deepCompareForVerify(rawDecoded, compactDecoded, "$", options)

	if ok then
		return true
	end

	context = context or {}

	logger:error("[CompactClientInitDataVerify] kind=%s entityType=%s class=%s entityId=%s scope=%s path=%s reason=%s raw=%s compact=%s", tostring(kind), tostring(context.entityType), tostring(context.className), tostring(context.entityId), tostring(context.scope), tostring(diffPath), tostring(reason), tostring(rawValue), tostring(compactValue))
	error(string.format("CompactClientInitDataVerify failed at %s: %s", tostring(diffPath), tostring(reason)))
end

local function normalizeLazyTargetScope(scope)
	if scope == "own" or scope == "OwnClient" or scope == 2 then
		return "own"
	end

	if scope == "all" or scope == "AllClients" or scope == 3 then
		return "all"
	end

	return scope
end

local function fillLazyRawPrimitiveDefaultsForVerify(className, ptable, ctable)
	local schema = CompactPropertySchema.getEntitySchema(className)

	if schema == nil or type(ptable) ~= "table" then
		return
	end

	local targetScope = normalizeLazyTargetScope(type(ctable) == "table" and ctable.__aoiscope__ or nil)

	for _, name in ipairs(schema.orderedNames) do
		local declare = schema.declares[name]

		if ptable[name] == nil and declare ~= nil and not declare.isCustom and isVisible(declare.scope, targetScope) then
			ptable[name] = declare.default
		end
	end
end

function RpcDataVerifyCodec.encodeEntityInitVerifyForProto(compactDict, initDict, scope, protoCodec)
	return protoCodec:encode({
		[VERIFY_MARK] = true,
		[VERIFY_KIND] = VERIFY_KIND_ENTITY,
		[VERIFY_COMPACT] = compactDict,
		[VERIFY_RAW] = toVerifyRawValue(initDict),
		[VERIFY_META] = {
			className = type(compactDict) == "table" and compactDict.__class__ or nil,
			scope = scope or "all"
		}
	})
end

function RpcDataVerifyCodec.encodeEntityInitForProto(codec, entity, initDict, scope, protoCodec, collectStat, verify)
	local compactDict = codec.encodeEntityInit(entity, initDict, scope)
	local compactBytes = protoCodec:encode(compactDict)

	if not collectStat and not verify then
		return compactBytes
	end

	local rawDict = toStatRawValue(initDict)
	local rawOk, rawBytesOrErr = pcall(function()
		return protoCodec:encode(rawDict)
	end)

	if not rawOk then
		return compactBytes, {
			className = type(compactDict) == "table" and compactDict.__class__ or nil,
			scope = scope or "all",
			compactSize = #compactBytes,
			rawError = tostring(rawBytesOrErr)
		}
	end

	local stat

	if collectStat then
		local rawSize = #rawBytesOrErr
		local compactSize = #compactBytes
		local savedSize = rawSize - compactSize
		local savedRatio = rawSize > 0 and savedSize * 100 / rawSize or 0

		stat = {
			className = type(compactDict) == "table" and compactDict.__class__ or nil,
			scope = scope or "all",
			rawSize = rawSize,
			compactSize = compactSize,
			savedSize = savedSize,
			savedRatio = savedRatio
		}

		fillCompactStats(compactDict, stat)
		fillCompactSizeStats(rawDict, compactDict, protoCodec, stat)
	end

	if verify then
		return RpcDataVerifyCodec.encodeEntityInitVerifyForProto(compactDict, initDict, scope, protoCodec), stat
	end

	return compactBytes, stat
end

function RpcDataVerifyCodec.encodeLazyVerifyForProto(rawData, compactData, protoCodec, meta)
	return protoCodec:encode({
		[VERIFY_MARK] = true,
		[VERIFY_KIND] = VERIFY_KIND_LAZY,
		[VERIFY_RAW] = rawData,
		[VERIFY_COMPACT] = compactData,
		[VERIFY_META] = meta or {}
	})
end

function RpcDataVerifyCodec.decodeEntityInitVerify(codec, entityType, initDict)
	if type(initDict) ~= "table" or initDict[VERIFY_MARK] ~= true or initDict[VERIFY_KIND] ~= VERIFY_KIND_ENTITY then
		return nil, false
	end

	local compactPayload = initDict[VERIFY_COMPACT]
	local rawPayload = initDict[VERIFY_RAW]
	local meta = initDict[VERIFY_META] or {}
	local compactDecoded = codec.decodeEntityInit(entityType, compactPayload)
	local className = meta.className or type(compactPayload) == "table" and compactPayload.__class__ or codec.normalizeClientEntityType(entityType)
	local scope = meta.scope or type(compactPayload) == "table" and compactPayload.__scope__ or "all"
	local rawNormalized = codec.decodeEntityInit(entityType, codec.encodeEntityInit(className, rawPayload, scope))

	verifyDecodedEqual(VERIFY_KIND_ENTITY, {
		entityType = entityType,
		className = className,
		scope = scope
	}, rawNormalized, compactDecoded)

	return compactDecoded, true
end

function RpcDataVerifyCodec.decodeEntityInitOrNormal(codec, entityType, initDict)
	local decoded, handled = RpcDataVerifyCodec.decodeEntityInitVerify(codec, entityType, initDict)

	if handled then
		return decoded
	end

	return codec.decodeEntityInit(entityType, initDict)
end

function RpcDataVerifyCodec.tryDecodeLazyVerify(codec, binData, protoCodec, decodeFunc, releaseFunc, context)
	local ok, wrapper = pcall(function()
		return protoCodec:decode(binData)
	end)

	if not ok or type(wrapper) ~= "table" or wrapper[VERIFY_MARK] ~= true or wrapper[VERIFY_KIND] ~= VERIFY_KIND_LAZY then
		return nil
	end

	local compactData = wrapper[VERIFY_COMPACT]
	local rawData = wrapper[VERIFY_RAW]
	local meta = wrapper[VERIFY_META] or {}

	context = context or {}
	context.className = meta.className or context.className
	context.scope = context.scope or meta.scope

	local compactOk, compactCtable, compactPtable, compactIdx = pcall(decodeFunc, compactData, context)

	if not compactOk then
		error(compactCtable)
	end

	local rawOk, rawCtable, rawPtable, rawIdx = pcall(decodeFunc, rawData, context)

	if rawIdx ~= nil and releaseFunc ~= nil then
		releaseFunc(rawIdx)
	end

	if not rawOk then
		if compactIdx ~= nil and releaseFunc ~= nil then
			releaseFunc(compactIdx)
		end

		error(rawCtable)
	end

	if context.scope == nil and type(rawCtable) == "table" then
		context.scope = normalizeLazyTargetScope(rawCtable.__aoiscope__)
	end

	fillLazyRawPrimitiveDefaultsForVerify(context.className, rawPtable, rawCtable)
	verifyDecodedEqual(VERIFY_KIND_LAZY .. ".ctable", context, rawCtable, compactCtable)
	verifyDecodedEqual(VERIFY_KIND_LAZY .. ".ptable", context, rawPtable, compactPtable)

	return compactCtable, compactPtable, compactIdx
end

return RpcDataVerifyCodec
