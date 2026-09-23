-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\LevelItemMultiInteractor.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local InteractionConst = require("Common.Const.InteractionConst")
local ConflictTypes = require("Common.ConflictTypes")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local ClientConst = require("Const.ClientConst")
local LevelItemMultiInteractor = Class.LightClass("LevelItemMultiInteractor", LevelItem)

function LevelItemMultiInteractor:ctor(sandbox, spawnInfo, syncInfo)
	LevelItemMultiInteractor.super.ctor(self, sandbox, spawnInfo, syncInfo)

	local configData = self:getConfigData()

	self.multiPlayerNum = configData.multiPlayerNum or 1
	self.initData = self:getConfigData().initData or {}
	self.resetDelay = self.initData.resetDelay or 2
	self.otherPlayerId = nil
end

function LevelItemMultiInteractor:onSandboxReady()
	LevelItemMultiInteractor.super.onSandboxReady(self)

	self.multiInteractorSB = self.shell.gameObject:GetComponent("MultiInteractorSB")

	self:refreshOtherPlayerInfo()
	self:addTimer(0, function()
		self:refreshInteractPlayerState()
	end)
end

function LevelItemMultiInteractor:destroy()
	if self.otherPlayerId then
		pg.game.cutscene:setOtherPlayer(ClientConst.CutsceneOtherPlayerKey.Player1, nil)

		self.otherPlayerId = nil
	end

	LevelItemMultiInteractor.super.destroy(self)
end

function LevelItemMultiInteractor:onLevelItemValueChange(key, oldValue, value)
	LevelItemMultiInteractor.super.onLevelItemValueChange(self, key, oldValue, value)

	if key == "interactInfo" then
		self:refreshInteractPlayerState()
		self:refreshOtherPlayerInfo()
	end
end

function LevelItemMultiInteractor:checkCanInteract(interactUnit)
	if self.syncInfo.state == SandboxConst.LEVEL_MULTI_INTERACT_STATE.TRIGGER then
		return false
	end

	local interactIndex = interactUnit.info.interactPartId or 0

	if interactIndex <= 0 or interactIndex > self.multiPlayerNum then
		return false
	end

	if self:isPartInteractByPlayer(interactIndex) then
		return false
	end

	if pg.me:isInLevelItemInteractState() then
		return false
	end

	return true
end

function LevelItemMultiInteractor:isPartInteractByPlayer(interactIndex)
	local interactInfo = self.syncInfo.interactInfo or {}

	if interactInfo[interactIndex] and interactInfo[interactIndex].playerId then
		return true
	end

	return false
end

function LevelItemMultiInteractor:onInteract(interactUnit)
	if self.syncInfo.state == SandboxConst.LEVEL_MULTI_INTERACT_STATE.TRIGGER then
		return
	end

	local interactIndex = interactUnit.info.interactPartId or 0

	if interactIndex <= 0 or interactIndex > self.multiPlayerNum then
		return false
	end

	if pg.me:checkStatus(ConflictTypes.CT_MULTI_INTERACT, true) then
		self:playerFaceToInteractUnit(interactIndex, true)
		self:serverMsg("RPC_CS_PartInteract", true, interactUnit.actionPrototypeId, interactIndex)
	end
end

function LevelItemMultiInteractor:RPC_SC_PartInteractSuccess(args)
	local isInteract, interactIndex = self:isMainPlayerInteracting()

	if isInteract then
		self:playerFaceToInteractUnit(interactIndex, true)
	end
end

function LevelItemMultiInteractor:cancelInteract()
	self:serverMsg("RPC_CS_PartInteract", false, 0, 0)
end

function LevelItemMultiInteractor:isMainPlayerInteracting()
	local interactInfo = self.syncInfo.interactInfo or {}

	for interactIndex, playerInteractInfo in pairs(interactInfo) do
		if playerInteractInfo.playerId == pg.me.id then
			return true, interactIndex
		end
	end

	return false, nil
end

function LevelItemMultiInteractor:refreshInteractPlayerState()
	local interactInfo = self.syncInfo.interactInfo or {}

	for interactIndex = 1, self.multiPlayerNum do
		local playerInteractInfo = interactInfo[interactIndex]

		if playerInteractInfo then
			self.multiInteractorSB:SetInInteractInfo(interactIndex, true, playerInteractInfo.playerId)
		else
			self.multiInteractorSB:SetInInteractInfo(interactIndex, false, nil)
		end
	end
end

function LevelItemMultiInteractor:refreshOtherPlayerInfo()
	local otherPlayerId
	local interactInfo = self.syncInfo.interactInfo or {}

	for interactIndex, playerInteractInfo in pairs(interactInfo) do
		if playerInteractInfo.playerId and playerInteractInfo.playerId ~= pg.me.id then
			otherPlayerId = playerInteractInfo.playerId

			break
		end
	end

	if otherPlayerId ~= self.otherPlayerId then
		self.otherPlayerId = otherPlayerId

		pg.game.cutscene:setOtherPlayer(ClientConst.CutsceneOtherPlayerKey.Player1, self.otherPlayerId)
	end
end

function LevelItemMultiInteractor:RPC_SC_OnInteractTrigger()
	pg.me:tempDisableCancelLevelInteract(self.resetDelay + 1)
end

return LevelItemMultiInteractor
