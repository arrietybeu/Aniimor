-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitPlayerFunc.lua

local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local UIConst = require("Const.UIConst")
local Vector3 = Vector3
local InteractionUnitPlayerFunc = Class.LightClass("InteractionUnitPlayerFunc", InteractionUnitBase)

function InteractionUnitPlayerFunc:ctor(info, interactId)
	InteractionUnitPlayerFunc.super.ctor(self, info, interactId)

	self.interactFunc = info.interactFunc
	self.canInteractiveFunc = info.canInteractiveFunc
	self.needCheckDis = info.needCheckDis
	self.targetName = info.name or ""
	self.handlePetEthnicGroup = info.handlePetEthnicGroup
	self.checkEntity = info.checkEntity
end

function InteractionUnitPlayerFunc:canInteractive()
	if not self:checkInteractBlock() then
		return false
	end

	local ent = self:getEntity()
	local configDis = self.dist or self:getConfigDis()

	if ent and configDis ~= 0 and configDis < Vector3.Distance(pg.pawn:getPosition(), ent:getPosition()) then
		return false
	end

	if self.needCheckDis and self.targetPos then
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
		return InteractionUnitPlayerFunc.super.canInteractive(self)
	end

	return true
end

function InteractionUnitPlayerFunc:interactive()
	if self.interactFunc then
		self.interactFunc(self)
	end
end

function InteractionUnitPlayerFunc:getActionName()
	local interactData = self.interactData

	if interactData.actionName then
		local text = pg.getLocalizationText(interactData.actionName)
		local ent = self:getEntity()

		if ent then
			local name

			if ent.playerName then
				name = ent.playerName

				local _h = InteractionUnitPlayerFunc._platformHooks

				if _h and _h.getPlayerDisplayName then
					name = _h.getPlayerDisplayName(self, ent, ent.playerName) or ent.playerName
				end

				text = pg.getFormatText(text, name)
			else
				local configData = ent:getConfigData()

				name = configData.name
				text = pg.getFormatText(text, pg.getLocalizationText(name))
			end
		end

		return text
	end

	return ""
end

function InteractionUnitPlayerFunc:getText()
	local interactData = self.interactData

	if interactData.actionName then
		local text = pg.getLocalizationText(interactData.actionName)
		local ent = self:getEntity()

		if ent then
			local name

			if ent.playerName then
				name = ent.playerName

				local _h = InteractionUnitPlayerFunc._platformHooks

				if _h and _h.getPlayerDisplayName then
					name = _h.getPlayerDisplayName(self, ent, ent.playerName) or ent.playerName
				end
			else
				local configData = ent:getConfigData()

				name = configData.name
			end

			text = pg.getFormatText(text, pg.getLocalizationText(name))
		end

		return text
	elseif self.targetName then
		return pg.getLocalizationText(self.targetName)
	end

	return ""
end

return InteractionUnitPlayerFunc
