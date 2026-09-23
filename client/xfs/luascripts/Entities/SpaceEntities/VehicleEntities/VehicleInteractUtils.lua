-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\VehicleEntities\\VehicleInteractUtils.lua

local VehicleInteractUtils = {}
local Utils = require("Common.Utils.Utils")

local function isBddData(value)
	if type(value) == "table" and rawget(value, "_BddData_") then
		return true
	end

	local metatable = getmetatable(value)

	return metatable ~= nil and metatable._BddData_ == true
end

function VehicleInteractUtils.toConfigList(value)
	if value == nil then
		return nil
	end

	local valueType = type(value)

	if valueType == "number" or valueType == "boolean" then
		return {
			value
		}
	end

	if valueType ~= "table" and valueType ~= "userdata" then
		return nil
	end

	local source = isBddData(value) and Utils.deepCopyTable(value) or value
	local sourceType = type(source)

	if sourceType == "number" or sourceType == "boolean" then
		return {
			source
		}
	end

	if sourceType ~= "table" and sourceType ~= "userdata" then
		return nil
	end

	local list = {}

	for _, item in ipairs(source) do
		list[#list + 1] = item
	end

	return list
end

function VehicleInteractUtils.toInteractIdList(value)
	local interactIds = {}
	local valueList = VehicleInteractUtils.toConfigList(value)

	if not valueList then
		return interactIds
	end

	for _, interactId in ipairs(valueList) do
		if type(interactId) == "number" and interactId > 0 then
			interactIds[#interactIds + 1] = interactId
		end
	end

	return interactIds
end

return VehicleInteractUtils
