-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Parser\\loader.lua

local Utils = require("Common.Utils.Utils")
local _M = {
	FILE_TYPE_LUA = 3,
	FILE_TYPE_JSON = 2,
	FILE_TYPE_BSON_BYTES = 1,
	FILE_TYPE_UNKNOWN = 0,
	GlobalBtPathList = {}
}

local function _load_lua(path)
	local relativeTreePath = Utils.getScriptRelativeTreePath(path):gsub(".lua", "")
	local luaName = relativeTreePath:gsub("/", ".")
	local success, data = pcall(require, luaName)

	if success then
		table.insert(_M.GlobalBtPathList, luaName)

		return data
	end
end

local constFileType = {
	{
		".lua",
		_M.FILE_TYPE_LUA,
		_load_lua
	}
}

function _M.testFileType(path)
	if not path then
		return false, _M.FILE_TYPE_UNKNOWN
	end

	local extensionName, fileType, loadFunc, pathBase

	for _, v in ipairs(constFileType) do
		extensionName = v[1]
		fileType = v[2]
		loadFunc = v[3]

		local posStart, _ = string.find(path, extensionName .. "$")

		if posStart then
			pathBase = string.sub(path, 1, posStart - 1)

			return extensionName, fileType, loadFunc, pathBase
		end
	end

	return false, _M.FILE_TYPE_UNKNOWN
end

function _M.load(pathBase)
	local data = require(pathBase)

	if data then
		return data, _M.FILE_TYPE_LUA
	end

	return false, _M.FILE_TYPE_UNKNOWN
end

return _M
