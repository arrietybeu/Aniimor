-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\ShieldDataList.lua

local CustomList = require("Core.PropertySync.CustomList")
local Class = require("Core.Framework.Class")
local ShieldData = require("CustomTypes.ShieldData")
local Utils = require("Common.Utils.Utils")
local ShieldDataList = Class.LiteClass("ShieldDataList", CustomList)

function ShieldDataList:getCurPoint(ent, buffInsId)
	local curPoint = 0

	for _, shieldData in ipairs(self) do
		if not buffInsId or shieldData.buffInsId == buffInsId then
			curPoint = curPoint + shieldData.curPoint
		end
	end

	if ent and Utils.isPet(ent) then
		local masterEntity = ent:getMasterEntity()

		if masterEntity then
			curPoint = curPoint + masterEntity.shieldDataList:getCurPoint(nil, buffInsId)
		end
	end

	return curPoint
end

function ShieldDataList:getShieldData(buffInsId)
	for idx, shieldData in ipairs(self) do
		if shieldData.buffInsId == buffInsId then
			return shieldData
		end
	end

	return nil
end

function ShieldDataList:getShieldPointByTemplateId(buffTemplateId)
	local curPoint = 0

	for _, shieldData in ipairs(self) do
		if shieldData.templateId == buffTemplateId then
			curPoint = curPoint + shieldData.curPoint
		end
	end

	return curPoint
end

function ShieldDataList:removeShield(buffInsId)
	for idx, shieldData in ipairs(self) do
		if shieldData.buffInsId == buffInsId then
			self:remove(idx)

			return
		end
	end
end

function ShieldDataList:getGeneralShieldData()
	for idx, shieldData in ipairs(self) do
		if shieldData.isGeneral then
			return shieldData
		end
	end
end

function ShieldDataList:createShieldData(initDic)
	return ShieldData(initDic)
end

return ShieldDataList
