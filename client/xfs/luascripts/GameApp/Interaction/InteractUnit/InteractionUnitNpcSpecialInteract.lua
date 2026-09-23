-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitNpcSpecialInteract.lua

local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local InteractData = require("Data.interact_data")
local InteractionConst = require("Common.Const.InteractionConst")
local UIConst = require("Const.UIConst")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local Vector3 = Vector3
local InteractionUnitNpcSpecialInteract = Class.LightClass("InteractionUnitNpcSpecialInteract", InteractionUnitBase)

function InteractionUnitNpcSpecialInteract:ctor(info, interactId)
	local actionPrototypeId = info.actionPrototypeId % 100000

	self.info = info
	self.globalId = info.globalId
	self.dist = info.dist
	self.needItem = info.needItem
	self.targetName = info.name or ""
	self.eventType = info.eventType
	self.actionPrototypeId = info.actionPrototypeId
	self.interactData = InteractData[actionPrototypeId] and lume.clone(InteractData[actionPrototypeId]) or {}
	self.interactData.styleId = actionPrototypeId
	self.interactData.index = 1
	self.interactionType = info.interactionType or self.interactData.type
	self.interactId = interactId
	self.targetPos = info.targetPos
	self.handlePetEthnicGroup = info.handlePetEthnicGroup or ToBool(self.interactData.handlePetEthnicGroup)
	self.useTurnAnim = false
	self.stateCheckExclude = {}

	if self.interactData.stateCheckExclude then
		for _, state in ipairs(self.interactData.stateCheckExclude) do
			self.stateCheckExclude[state] = true
		end
	end

	self.interactFunc = info.interactFunc
	self.canInteractiveFunc = info.canInteractiveFunc
	self.needCheckDis = info.needCheckDis
	self.checkEntity = info.checkEntity
	self.questId = info.questId
end

function InteractionUnitNpcSpecialInteract:getText()
	local interactData = self.interactData
	local actionName = interactData.actionName

	if self.questId and self.questId ~= 0 then
		local desc, _ = QuestUtils.getQuestInteractDescAndIcon(self.questId)

		actionName = not string.isNilOrEmpty(desc) and desc or actionName
	end

	if actionName then
		local text = pg.getLocalizationText(actionName)
		local ent = self:getEntity()

		if ent then
			local name

			if ent.getName then
				name = ent:getName()
			else
				local configData = ent:getConfigData()

				name = configData.name
			end

			text = string.gsub(text, UIConst.INTERACT_TEXT_REPLACE_PATTERN, pg.getLocalizationText(name))
		end

		return text
	elseif self.targetName then
		return pg.getLocalizationText(self.targetName)
	end

	return ""
end

function InteractionUnitNpcSpecialInteract:canInteractive()
	if not self:checkInteractBlock() then
		return false
	end

	if self.needCheckDis and self.targetPos then
		local configDis = self:getConfigDis()
		local curDis = Vector3.Distance(pg.pawn:getPosition(), self.targetPos)

		if configDis ~= 0 and configDis < curDis then
			return false
		end
	end

	if pg.me:isInCatchMode() then
		return false
	end

	if self.canInteractiveFunc then
		return self.canInteractiveFunc(self)
	end

	if self.checkEntity then
		return InteractionUnitNpcSpecialInteract.super.canInteractive(self)
	end

	return true
end

function InteractionUnitNpcSpecialInteract:interactive()
	if self.interactFunc then
		self.interactFunc(self)
	end
end

function InteractionUnitNpcSpecialInteract:getIcon()
	if self.questId and self.questId ~= 0 then
		local _, icon = QuestUtils.getQuestInteractDescAndIcon(self.questId)

		if not string.isNilOrEmpty(icon) then
			return icon
		end
	end

	return InteractionUnitNpcSpecialInteract.super.getIcon(self)
end

return InteractionUnitNpcSpecialInteract
