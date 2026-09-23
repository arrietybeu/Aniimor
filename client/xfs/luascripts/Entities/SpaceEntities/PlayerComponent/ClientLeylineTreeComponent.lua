-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientLeylineTreeComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local SysConfigData = require("Data.sys_config_data")
local TimerManager = require("Core.Timer.TimerManager")
local ClientLeylineTreeComponent = class.Component("ClientLeylineTreeComponent")

function ClientLeylineTreeComponent:RPC_SC_OnLeylineTreeActivated(leylineTreeId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_OnLeylineTreeActivated LeylineTreeId %f", leylineTreeId)
	end
end

function ClientLeylineTreeComponent:RPC_SC_OnLeylineTreeUpdated(leylineTreeId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_OnLeylineTreeUpdated LeylineTreeId %f", leylineTreeId)
	end
end

function ClientLeylineTreeComponent:RPC_SC_UnlockFreelance(leylineTreeId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_UnlockFreelance LeylineTreeId %f", leylineTreeId)
	end

	if not self.staminaTickData then
		return
	end

	local curTreeId = pg.game.leylineTree and pg.game.leylineTree:getCurLeylineTreeId()

	self.staminaTickData.freelanceMode = Utils.isUnlockFreelanceMode(self, curTreeId)
end

function ClientLeylineTreeComponent:RPC_SC_OnLeylineTreeRewardUpdated(leylineTreeId, imprintIndex)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_OnLeylineTreeRewardUpdated LeylineTreeId %f, imprintIndex %f", leylineTreeId, imprintIndex)
	end
end

function ClientLeylineTreeComponent:onLeylineTreeInfoMapCreatePlentyCount_changed(ov, nv, leylineTreeId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onLeylineTreeInfoMapCreatePlentyCount_changed", ov, nv, leylineTreeId)
	end

	facade:SendMessageCommand(MessageName.NOURISH_COUNT_CHANGED, {
		oldValue = ov,
		newValue = nv,
		leylineTreeId = leylineTreeId
	})

	local treeEntId = pg.space.leylineTreeMap[leylineTreeId]

	if not treeEntId then
		return
	end

	local ent = pg.getEntity(treeEntId)

	if not ent then
		return
	end

	if nv ~= -1 then
		ent:playStageAnimation(3, SysConfigData.QUICK_P_LIFE_TIME, SysConfigData.SHRINK_P_DELAY_TIME, SysConfigData.SHRINK_P_LIFE_TIME, SysConfigData.LIGHT_BALL_SHOW_DELAY, function()
			ent:playStageAnimation(1)
		end)
	else
		ent:playStageAnimation(2)
	end
end

function ClientLeylineTreeComponent:onChangeMeteorologyCount_changed(ov, nv, leylineTreeId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onChangeMeteorologyCount_changed", ov, nv, leylineTreeId)
	end

	facade:SendMessageCommand(MessageName.LEYLINETREE_METEOROLOGY_COUNT_CHANGED, {
		leylineTreeId = leylineTreeId,
		oldValue = ov,
		newValue = nv
	})
end

function ClientLeylineTreeComponent:onChangeMeteorologyCD_changed(ov, nv, leylineTreeId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onChangeMeteorologyCD_changed", ov, nv, leylineTreeId)
	end

	facade:SendMessageCommand(MessageName.LEYLINETREE_METEOROLOGY_CD_CHANGED, {
		leylineTreeId = leylineTreeId,
		oldValue = ov,
		newValue = nv
	})
end

function ClientLeylineTreeComponent:RPC_SC_LeylineMarkCreate(sceneId, markIdsDurtimesPairs)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_LeylineMarkCreate sceneId %f markIdsDurtimesPairs %s", sceneId, inspect(markIdsDurtimesPairs))
	end

	local t = {}

	for markId, info in pairs(markIdsDurtimesPairs) do
		t[markId] = info.durtime
	end

	facade:SendMessageCommand(MessageName.NOURISH_ON_NOURISHED, {
		sceneId = sceneId,
		markIdsDurtimesPairs = t
	})
end

function ClientLeylineTreeComponent:RPC_SC_LeylineMarkClear(sceneId, markId, createId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_LeylineMarkClear sceneId %f markId %f", sceneId, markId)
	end

	local plentyInfo = pg.game.map:getLeylineTreePlentyInfo(sceneId, markId, createId)

	facade:SendMessageCommand(MessageName.NOURISH_ON_NOURISH_FINISHED, {
		sceneId = sceneId,
		markId = markId,
		plentyInfo = plentyInfo
	})

	if not plentyInfo then
		return
	end

	pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("PLENTY_DISAPPEARED"), plentyInfo.familyName, plentyInfo.areaName), 2)
end

function ClientLeylineTreeComponent:isUsingSpaceOwnerLeylinePlentyInfos()
	if not self.space or not Utils.isSpaceSingleWorld(self.space.spaceType) then
		return false
	end

	if not self:isInTeam() or not self.inLeaderWorld then
		return false
	end

	return true
end

function ClientLeylineTreeComponent:getSpaceOwnerSceneLeylineMarkIdTimes()
	if not self:isUsingSpaceOwnerMap() then
		return nil
	end

	local leaderPlayer = self:getTeamLeaderPlayer()

	if leaderPlayer == nil then
		return nil
	end

	local res = require("CustomTypes.SceneLeylineMarkIdTimes")(leaderPlayer.sceneLeylineMarkIdTimes:getRawTable())

	return res
end

function ClientLeylineTreeComponent:onPendingMapMeteorologyChanged(oldValue, newValue)
	facade:SendMessageCommand(MessageName.LEYLINE_MAP_RAINBOW_CHANGED)
end

return ClientLeylineTreeComponent
