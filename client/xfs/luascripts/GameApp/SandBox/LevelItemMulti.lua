-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\LevelItemMulti.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local InteractionConst = require("Common.Const.InteractionConst")
local ConflictTypes = require("Common.ConflictTypes")
local LevelItemMulti = Class.LightClass("LevelItemMulti", LevelItem)

function LevelItemMulti:ctor(sandbox, spawnInfo, syncInfo)
	LevelItemMulti.super.ctor(self, sandbox, spawnInfo, syncInfo)

	local configData = self:getConfigData()

	self.multiPlayerNum = configData.multiPlayerNum or 1
end

function LevelItemMulti:checkCanInteract(interactUnit)
	if self.syncInfo.state == SandboxConst.LEVEL_ITEM_MILTI_STATE.TRIGGER then
		return false
	end

	if interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_MULTI_INTERACT then
		if pg.me:isInLevelItemInteractState() then
			return false
		end
	elseif interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_MULTI_INTERACT_CANCEL and not pg.me:isInLevelItemInteractState() then
		return false
	end

	return true
end

function LevelItemMulti:onInteract(interactUnit)
	if self.syncInfo.state == SandboxConst.LEVEL_ITEM_MILTI_STATE.TRIGGER then
		return
	end

	if interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_MULTI_INTERACT then
		if pg.me:checkStatus(ConflictTypes.CT_MULTI_INTERACT, true) then
			self:serverMsg("RPC_CS_DoInteract", true, interactUnit.actionPrototypeId)
		end
	else
		self:cancelInteract()
	end
end

function LevelItemMulti:cancelInteract()
	self:serverMsg("RPC_CS_DoInteract", false, 0)
end

return LevelItemMulti
