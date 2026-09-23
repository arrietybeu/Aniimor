-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\ObjHelper.lua

local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local PetData = require("Data.pet_data")
local ObjHelper = {
	TYPE_HOMELANE = 16,
	TYPE_PET_INFO = 8,
	TYPE_PUPPET = 4,
	TYPE_PET = 2,
	TYPE_PLAYER = 1,
	TYPE_NONE = 0
}

function ObjHelper.getRealObjType(obj)
	if obj == nil then
		return ObjHelper.TYPE_NONE
	elseif Utils.isHomeland(obj and obj.spaceType) then
		return ObjHelper.TYPE_HOMELANE
	elseif Utils.isPetInfoType(obj) then
		return ObjHelper.TYPE_PET_INFO
	elseif Utils.isPlayer(obj) or Utils.isBotPlayer(obj) then
		return ObjHelper.TYPE_PLAYER
	elseif Utils.isPet(obj) then
		return ObjHelper.TYPE_PET
	elseif Utils.isPuppet(obj) then
		return ObjHelper.TYPE_PUPPET
	end

	return ObjHelper.TYPE_NONE
end

function ObjHelper.validateObj(obj, objType)
	if objType and ObjHelper.getRealObjType(obj) ~= objType then
		return nil
	end

	return obj
end

function ObjHelper.match(obj, type)
	return type == ObjHelper.getRealObjType(obj)
end

function ObjHelper.matchOneOf(obj, typeList)
	local realObjType = ObjHelper.getRealObjType(obj)

	return lume.find(typeList, realObjType)
end

function ObjHelper.callObjFunc(obj, funcName, ...)
	if obj == nil then
		return false, nil
	end

	if type(obj[funcName]) ~= "function" then
		return false, nil
	end

	return true, obj[funcName](obj, ...)
end

function ObjHelper.getObjRepr(obj)
	if obj == nil then
		return string.format("(nil obj)")
	end

	local ok, repr = ObjHelper.callObjFunc(obj, "repr")

	if ok == true then
		return repr
	else
		local className = obj.className or obj.__ClassType and obj.__ClassType.typeName or "NOTCLASS"

		return string.format("%s(id=%s)", className, tostring(obj.id))
	end
end

function ObjHelper.getObjConfigData(obj)
	if obj == nil then
		return nil
	end

	local configData

	if ObjHelper.match(obj, ObjHelper.TYPE_PET_INFO) then
		configData = PetData[obj.templateId]
	else
		configData = Utils.getEntityConfigData(obj)
	end

	return configData
end

function ObjHelper.getObjLevel(obj)
	return obj and obj.level or 0
end

function ObjHelper.getObjStage(obj)
	local stage = obj and obj.stage

	if stage ~= nil then
		return stage
	else
		local configData = ObjHelper.getObjConfigData(obj)

		return configData and configData.stage or 0
	end
end

return ObjHelper
