-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Social\\Component\\PetPeekTag.lua

local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local InteractionConst = require("Common.Const.InteractionConst")
local Const = require("Common.Const.Const")
local TimerManager = require("Core.Timer.TimerManager")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local SocialConst = require("Common.Const.SocialConst")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local PetPeekTag = Class.LiteClass("PetPeekTag")

PetPeekTag.PEEK_ACTION_ID = InteractionConst.STYLE_CONST.ARK_PET_UP_INTERACT

function PetPeekTag:getPetEntity(petEntityId, globalId)
	local pet

	if petEntityId ~= nil then
		pet = pg.getEntity(petEntityId)
	end

	if pet == nil and globalId ~= nil then
		pet = pg.getEntityByGlobalId(globalId)
	end

	return pet
end

function PetPeekTag:getPetDisplayNameByInfo(petInfo)
	if petInfo == nil then
		return ""
	end

	if not string.isNilOrEmpty(petInfo.customName) then
		return petInfo.customName
	end

	local petData = PetData[petInfo.templateId]

	if petData ~= nil and petData.name ~= nil then
		return pg.getLocalizationText(petData.name)
	end

	return ""
end

function PetPeekTag:getPetIcon(pet, petInfo)
	petInfo = petInfo or {}

	local templateId = petInfo.templateId or pet ~= nil and pet.templateId
	local petData = templateId ~= nil and PetData[templateId] or nil
	local petConfigData = pet ~= nil and pet:getConfigData() or nil
	local iconName = petData ~= nil and petData.iconName or petConfigData ~= nil and petConfigData.iconName

	if iconName == nil then
		return nil
	end

	return LuaUIUtils.getPetIcon(iconName, LuaUIUtils.PET_ICON, petInfo.label or pet ~= nil and pet.label, petInfo.gender or pet ~= nil and pet.gender)
end

function PetPeekTag:isPetInRange(pet, distance)
	if pet == nil or pg.pawn == nil then
		return false
	end

	if pet.visible == false then
		return false
	end

	local petPos = pet:getPosition()
	local pawnPos = pg.pawn:getPosition()

	if petPos == nil or pawnPos == nil then
		return false
	end

	local dis = Vector3.Distance(petPos, pawnPos)

	return dis <= distance
end

function PetPeekTag:resetData()
	if self._tagWidgets ~= nil then
		local petEntityIds = {}

		for petEntityId, _ in pairs(self._tagWidgets) do
			petEntityIds[#petEntityIds + 1] = petEntityId
		end

		for _, petEntityId in ipairs(petEntityIds) do
			self:detach(petEntityId)
		end
	end

	self._tagWidgets = {}
end

function PetPeekTag:attach(petEntityId, petName, context)
	if petEntityId == nil then
		return
	end

	if self._tagWidgets == nil then
		self._tagWidgets = {}
	end

	local pet = self:getPetEntity(petEntityId)

	if pet == nil then
		return
	end

	local globalId = pet:getGlobalId()

	if globalId == nil then
		return
	end

	self:detach(petEntityId)

	local petInfo = pg.me ~= nil and pg.me:getPetInfo(petEntityId) or nil
	local displayName = petName

	if displayName == nil or displayName == "" then
		displayName = self:getPetDisplayNameByInfo(petInfo)
	end

	local tagInfo = {
		petEntityId = petEntityId,
		petName = displayName,
		globalId = globalId,
		beforePropLevels = context ~= nil and context.beforePropLevels or nil,
		ivUpNoticeText = context ~= nil and context.ivUpNoticeText or nil
	}
	local triggerInfo = {
		showLvUpIcon = true,
		globalId = globalId,
		actionPrototypeId = PetPeekTag.PEEK_ACTION_ID,
		interactionType = InteractionConst.INTERACTION_TYPE_ARK_PET_INTERACT,
		iconId = self:getPetIcon(pet, petInfo),
		formatTextArgs = {
			displayName
		},
		canInteractiveFunc = function()
			local curPet = self:getPetEntity(petEntityId, globalId)

			return self:isPetInRange(curPet, SocialConst.PET_PEEK_INTERACT_DISTANCE)
		end,
		interactFunc = function()
			self:openPendingIvUpDialog(petEntityId)
		end
	}

	tagInfo.triggerInfo = triggerInfo
	tagInfo.timerId = TimerManager.addTimer(SocialConst.PET_PEEK_TAG_TTL_SEC, function()
		self:detach(petEntityId)
	end)
	self._tagWidgets[petEntityId] = tagInfo

	facade:SendMessageCommand(MessageName.ENTER_TRIGGER, triggerInfo)
end

function PetPeekTag:detach(petEntityId)
	if petEntityId == nil or self._tagWidgets == nil then
		return
	end

	local tagInfo = self._tagWidgets[petEntityId]

	if tagInfo == nil then
		return
	end

	if tagInfo.timerId ~= nil then
		TimerManager.removeTimer(tagInfo.timerId)
	end

	if tagInfo.triggerInfo ~= nil then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, tagInfo.triggerInfo)
	end

	self._tagWidgets[petEntityId] = nil
end

function PetPeekTag:openPendingIvUpDialog(petEntityId)
	if petEntityId == nil or self._tagWidgets == nil then
		return
	end

	local tagInfo = self._tagWidgets[petEntityId]

	if tagInfo == nil then
		return
	end

	local beforePropLevels = tagInfo.beforePropLevels

	self:detach(petEntityId)

	local petInfo = pg.me ~= nil and pg.me:getPetInfo(petEntityId) or nil

	if petInfo == nil then
		return
	end

	self:_openIvUpLevelUpPanel(petInfo, beforePropLevels, tagInfo.ivUpNoticeText)
end

function PetPeekTag:_buildIvUpOldProp(petInfo, beforePropLevels)
	if petInfo == nil or beforePropLevels == nil then
		return nil, false
	end

	local attributeMap = PetAttributeCalcUtils.getAttributeMapByPetInfo(pg.me, petInfo)

	if attributeMap == nil then
		return nil, false
	end

	local oldProp = {}
	local hasChange = false

	for index = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local attrId = PetManagementDataHelper.CUR_PROP[index]
		local curValue

		if attrId ~= nil then
			curValue = attributeMap[attrId]
		end

		local beforeInfo = beforePropLevels[index]
		local beforeTotal

		if beforeInfo ~= nil then
			beforeTotal = beforeInfo.attributeTotal or beforeInfo.propDisplayVal
		end

		if beforeTotal == nil then
			beforeTotal = curValue
		end

		beforeTotal = tonumber(beforeTotal) or 0
		oldProp[index] = {
			total = beforeTotal
		}

		if curValue ~= nil and beforeTotal ~= curValue then
			hasChange = true
		end
	end

	return oldProp, hasChange
end

function PetPeekTag:_openIvUpLevelUpPanel(petInfo, beforePropLevels, ivUpNoticeText)
	local oldProp, hasChange = self:_buildIvUpOldProp(petInfo, beforePropLevels)

	if oldProp == nil then
		return false
	end

	local level = petInfo.level or 0

	pg.global.ui:open(UIConst.UI_ID_PET_LEVEL_UP, {
		isIvUp = true,
		petId = petInfo.id,
		oldProp = oldProp,
		oldLevel = level,
		newLevel = level,
		ivUpNoticeText = ivUpNoticeText
	})

	return true
end

function PetPeekTag:destroy()
	self:resetData()
end

return PetPeekTag
