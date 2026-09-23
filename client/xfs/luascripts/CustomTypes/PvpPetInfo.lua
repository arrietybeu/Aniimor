-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PvpPetInfo.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("PvpPetInfo")
local ObjHelper = require("Common.ObjHelper")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local PetData = require("Data.pet_data")
local TmpPetTemplateData = require("Data.tmp_pet_template_data")
local PvpPetInfo = class.LiteClass("PvpPetInfo", CustomDict)

function PvpPetInfo:getCharacterInfoDict()
	local characterInfo = {
		curCharacter = self.curCharacter,
		characterList = {
			self.curCharacter
		}
	}

	return characterInfo
end

function PvpPetInfo:getBasePropertyListDict(individualLevelInfo)
	local pptd = TmpPetTemplateData[self.templateId]
	local pdd = pptd and PetData[pptd.templateBaseId]

	if pdd == nil or pptd == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("invalid tmp pet config, templateId=%s, templateBaseId=%s", tostring(self.templateId), tostring(pptd and pptd.templateBaseId))
		end

		return {}
	end

	local basePropertyList = {}

	if individualLevelInfo == nil then
		individualLevelInfo = {}
	end

	for idx = 1, Const.BASE_PROPERTY_CNT do
		basePropertyList[idx] = Utils.getPropertyInitDict(ObjHelper.TYPE_PET_INFO, pdd, idx, 0, nil, individualLevelInfo)
		basePropertyList[idx].total, basePropertyList[idx].totalByUp = Utils.PropertyRefreshTotal(idx, basePropertyList[idx], {
			needExtraUp = true,
			objLevel = pptd.DefaultLevel or 1
		})
	end

	return basePropertyList
end

function PvpPetInfo:getCpValue()
	local basePropertyList = self:getBasePropertyListDict()
	local ret = 0

	for propIndex, baseProp in pairs(basePropertyList) do
		local addVal = baseProp.total

		if propIndex == Const.BASE_PROPERTY_HP_IDX then
			addVal = math.floor(baseProp.total / Const.CP_VALUE_HP_DIVISOR)
		end

		ret = ret + addVal
	end

	return ret
end

return PvpPetInfo
