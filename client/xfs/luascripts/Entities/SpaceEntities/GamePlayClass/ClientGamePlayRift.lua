-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\GamePlayClass\\ClientGamePlayRift.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientGamePlayEntity = require("Entities.SpaceEntities.GamePlayClass.ClientGamePlayEntity")
local SandboxConst = require("Common.Const.SandboxConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local EventConst = require("Const.EventConst")
local MessageName = require("Const.MessageName")
local Time = require("Core.Common.Time")
local RiftLevelData = require("Data.rift_level_data")
local Utils = require("Common.Utils.Utils")
local ClientGamePlayRift = class.Class("ClientGamePlayRift", ClientGamePlayEntity)
local Vector3 = Vector3

function ClientGamePlayRift:ctor(entityId)
	ClientGamePlayRift.super.ctor(self, entityId)
	self:addRepeatTimer(0.5, CallbackHandler(self, "tick"))

	self.failRadius = 0
	self.center = nil
end

function ClientGamePlayRift:init(dict)
	ClientGamePlayRift.super.init(self, dict)

	self.targetStaticId = dict.targetStaticId
	self.failRadius = dict.failRadius or 0
	self.center = dict.center

	self:checkReConnect()

	return true
end

function ClientGamePlayRift:on_endTime_changed(oldVal, newVal)
	if not self:checkInGamePlay() then
		return
	end

	self:showUITips()
end

function ClientGamePlayRift:showUITips()
	local duration = self.endTime - Time.secondCache
	local extra
	local riftCfgData = RiftLevelData[self.riftLevelId]

	self.riftCfgData = riftCfgData

	if not riftCfgData and LoggerManager.checkLogger(LoggerConst.WARN) then
		self.logger:warn("RiftLevelData %s is null", self.riftLevelId)
	end

	if riftCfgData.sandboxtype == Const.RIFT_SANDBOX_TYPE.DEFEAT then
		extra = {
			infoText = riftCfgData.desc
		}
	elseif riftCfgData.sandboxtype == Const.RIFT_SANDBOX_TYPE.GUARD then
		extra = {
			infoText = riftCfgData.desc
		}

		self:checkShowNpc(duration, extra)
	end

	pg.global.ui.tips:showCountDown(duration, "Rift", extra)
end

function ClientGamePlayRift:on_actived_changed(old, newVal)
	if not self:checkInGamePlay() then
		return
	end

	self:setMainPlayerRiftLevel(newVal)

	if newVal then
		pg.global.ui.tips:showA1Tips({
			id = "TowerResultStart",
			showText = pg.getGameString("ROGUE_BATTLE_START")
		})
		facade:sendMsgToUI(MessageName.ON_PLAYER_START_RIFT)
	else
		pg.global.ui.tips:hideCountDown("Rift")
		pg.global.ui.tips:clearTargetEntityInfo()
		facade:sendMsgToUI(MessageName.ON_PLAYER_END_RIFT)
	end
end

function ClientGamePlayRift:on_status_changed(old, newVal)
	if not self:checkInGamePlay() then
		return
	end

	if newVal == SandboxConst.COMMON_RESULT.SUCCESS then
		pg.global.ui.tips:showA1Tips({
			id = "TowerResultWin",
			showText = pg.getGameString("ROGUE_BATTLE_SUCCESS")
		})
	end
end

function ClientGamePlayRift:tick()
	self:checkFinishGameplay()
end

function ClientGamePlayRift:on_riftLevel_changed(oldLevelId, newLevelId)
	return
end

function ClientGamePlayRift:getProtectNpc()
	local npc = pg.me.space:getEntityByStaticId(self.targetStaticId)

	return npc
end

function ClientGamePlayRift:checkShowNpc(duration, extra)
	if self.riftCfgData and self.riftCfgData.sandboxtype == Const.RIFT_SANDBOX_TYPE.GUARD then
		local npc = self:getProtectNpc()

		if not npc then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("riftLevelId [%s] npc is not find", self.riftLevelId)
			end

			return
		end

		extra.pet = npc

		pg.global.ui.tips:showTargetEntityInfo(duration, "RiftNpc", extra)
	end
end

function ClientGamePlayRift:isOtherPlayer()
	local isSpaceOwner = Utils.checkIsSpaceOwner(pg.me)

	return not isSpaceOwner
end

function ClientGamePlayRift:checkRadius()
	if self.failRadius == 0 or self.center == nil then
		return true
	end

	local player = pg.me or pg.pawn
	local dist = Vector3.Distance(player:getPosition(), self.center)

	if dist > self.failRadius then
		return false
	end

	return true
end

function ClientGamePlayRift:checkInGamePlay()
	if self:isOtherPlayer() then
		return self:checkRadius()
	end

	return true
end

function ClientGamePlayRift:checkFinishGameplay()
	if not self:checkInGamePlay() then
		local player = pg.me

		if not player then
			return
		end

		player:setRiftLevelId(nil)
		facade:sendMsgToUI(MessageName.ON_PLAYER_END_RIFT)
		pg.global.ui.tips:hideCountDown("Rift")
		pg.global.ui.tips:clearTargetEntityInfo()
	end
end

function ClientGamePlayRift:checkReConnect()
	if not self:checkInGamePlay() then
		return
	end

	if not pg.me:isInRiftMode() and self.riftLevelId ~= 0 then
		self:setMainPlayerRiftLevel()
		self:showUITips()
		facade:sendMsgToUI(MessageName.ON_PLAYER_START_RIFT)
	end
end

function ClientGamePlayRift:setMainPlayerRiftLevel()
	local player = pg.me

	if not player then
		return
	end

	if self.actived and self.riftLevelId then
		player:setRiftLevelId(self.riftLevelId)
	else
		player:setRiftLevelId(nil)
	end
end

function ClientGamePlayRift:destroy()
	ClientGamePlayRift.super.destroy(self)
end

return ClientGamePlayRift
