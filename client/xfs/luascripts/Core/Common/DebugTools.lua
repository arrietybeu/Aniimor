-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\DebugTools.lua

local module = {}

function module._tableRepr(tb, tbType, ctx)
	local strOut = {}

	if tbType ~= nil then
		table.insert(strOut, tbType)
	else
		table.insert(strOut, "Table")
	end

	if ctx[tb] ~= nil then
		table.insert(strOut, "{...}")

		return table.concat(strOut, "")
	end

	ctx[tb] = true

	table.insert(strOut, "{")

	local mt = getmetatable(tb)

	if mt ~= nil then
		table.insert(strOut, "MetaTable=")
		table.insert(strOut, module.objectRepr(mt, ctx))
	end

	for k, v in pairs(tb) do
		table.insert(strOut, "[")
		table.insert(strOut, module.objectRepr(k, ctx))
		table.insert(strOut, "]=")
		table.insert(strOut, module.objectRepr(v, ctx))
		table.insert(strOut, ",")
	end

	ctx[tb] = nil

	table.insert(strOut, "}")

	return table.concat(strOut, "")
end

function module._instanceRepr(inst, ctx)
	local instName = "Instance(" .. inst:getClassType() .. ")"

	return module._tableRepr(inst, instName, ctx)
end

function module._classRepr(cls, ctx)
	local clsName = "Class(" .. cls.typeName .. ")"

	return module._tableRepr(cls, "clsName", ctx)
end

function module._functionRepr(func, ctx)
	local info = debug.getinfo(func)
	local what = rawget(info, "what")

	if what ~= nil then
		what = what .. "Func"
	else
		what = "UnknownFunc"
	end

	local funcStr = tostring(func)

	return (funcStr:gsub("function", what))
end

function module.objectRepr(obj, ctx)
	local strOut = {}

	if ctx == nil then
		ctx = {}
	end

	if type(obj) == "table" then
		if rawget(obj, "_inheritsCount") ~= nil then
			table.insert(strOut, module._classRepr(obj, ctx))
		elseif rawget(obj, "getClass") ~= nil then
			table.insert(strOut, module._instanceRepr(obj, ctx))
		else
			table.insert(strOut, module._tableRepr(obj, nil, ctx))
		end
	elseif type(obj) == "string" then
		table.insert(strOut, string.format("%q", obj))
	elseif type(obj) == "number" then
		if obj == math.floor(obj) then
			table.insert(strOut, string.format("%d", obj))
		else
			table.insert(strOut, string.format("%f", obj))
		end
	elseif type(obj) == "function" then
		table.insert(strOut, module._functionRepr(obj, ctx))
	else
		table.insert(strOut, tostring(obj))
	end

	return table.concat(strOut, "")
end

return module
