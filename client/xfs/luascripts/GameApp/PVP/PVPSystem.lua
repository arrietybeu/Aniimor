-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\PVP\\PVPSystem.lua

local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local LoggerManager = require("Core.Log.LoggerManager")
local TimerManager = require("Core.Timer.TimerManager")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PVPSystem = Class.LightClass("PVPSystem", SystemBase)
local AudioConst = require("Const.AudioConst")
local Const = require("Common.Const.Const")
local MatchConst = require("Common.Const.MatchConst")

function PVPSystem:onCtor()
	self.reMatchFunc = nil
	self.pvpMode = Const.PVPMode.Fair
	self.souDaCheMode = Const.SpaceBattleMode.OnePlusThree
	self.inCovenant = false
	self.isLoading = false
	self.rivalUid = 0
end

function PVPSystem:onSpaceCreated(space)
	self:reloadMatchType()
end

function PVPSystem:reloadMatchType()
	local me = pg.me

	if me.matchType == MatchConst.MatchTypeNone or me.matchType == MatchConst.MatchTypePVP1V1_Fair or me.matchType == MatchConst.MatchTypeFairPVP1V1Debug or me.matchType == MatchConst.MatchTypeInvitePVP1V1_Fair then
		self.pvpMode = Const.PVPMode.Fair
	else
		self.pvpMode = Const.PVPMode.UnFair
	end
end

function PVPSystem:isFairMode()
	return self.pvpMode == Const.PVPMode.Fair
end

function PVPSystem:isOne2Three()
	return self.souDaCheMode == Const.SpaceBattleMode.OnePlusThree
end

function PVPSystem:checkPvpState()
	if not pg.me:isMatchStatusInDungeon() then
		return
	end

	self.checkTimer = TimerManager.addRepeatTimer(0.1, function()
		if pg.me == nil or pg.me.space == nil then
			return
		end

		if not pg.me.space:isPvpEnv() then
			return
		end

		if not pg.global.scene:isSceneValid() then
			return
		end

		pg.game.loading:onProgressFinished()
		TimerManager.removeTimer(self.checkTimer)

		self.checkTimer = nil
	end)
end

function PVPSystem:setCovenantState(inCovenant)
	self.inCovenant = inCovenant
end

function PVPSystem:setRivalUID(rivalUid)
	self.rivalUid = rivalUid
end

function PVPSystem:getRivalUID()
	return self.rivalUid
end

function PVPSystem:enterRoom(enemyTeamInfo)
	pg.game.audio:triggerEvent("SFX_UI_PVP_MatchSuccess")
	pg.global.ui:closeAllUIPanel({
		[UIConst.UI_ID_TIPS] = true,
		[UIConst.UI_ID_TOPLOGO] = true,
		[UIConst.UI_ID_DAMAGE_NUMBER] = true,
		[UIConst.UI_ID_CHAIN_ATTACK] = true
	}, true)
	LuaUIUtils.openPvpBpScene(enemyTeamInfo)
end

function PVPSystem:playPvpBGM(bgmName, abmName)
	pg.game.audio:playBgm(bgmName, AudioConst.BgmPriority.DefaultUI, not string.isNilOrEmpty(bgmName))
	pg.game.audio:playAmb(abmName, AudioConst.BgmPriority.DefaultUI, not string.isNilOrEmpty(abmName))

	if not string.isNilOrEmpty(bgmName) or not string.isNilOrEmpty(abmName) then
		self:setNormalVolume()
	end
end

function PVPSystem:setNormalVolume()
	pg.game.audio:trySetState(AudioConst.STATE_GROUP_BGM_VOLUME, AudioConst.BGM_VOLUME_STATE_ID_NORMAL)
	pg.game.audio:setAttenGroupState(AudioConst.AttenGroupStateReason.PVP, false)
end

function PVPSystem:pvpResGetReady()
	pg.me:serverMsg("RPC_CS_PVPClientReady")
	pg.global.ui:close(UIConst.UI_ID_PVP_CHOSE)

	for id, entity in pairs(pg.getEntities()) do
		if entity.trySetEnemyState then
			entity:trySetEnemyState()
		end
	end
end

function PVPSystem:bindReMatchFunc()
	function self.reMatchFunc()
		LuaUIUtils.openPVPMenu(1)
	end
end

function PVPSystem:onSceneLoaded(sceneId, sceneName)
	if self.reMatchFunc then
		self.reMatchFunc()
	end

	self.reMatchFunc = nil
end

function PVPSystem:closeUnexpectedly()
	if self.timer then
		TimerManager.removeTimer(self.timer)
	end

	self.timer = nil

	pg.global.ui:close(UIConst.UI_ID_PVP_CHOSE)
	pg.global.ui:close(UIConst.UI_ID_PVP_BATTLE)
	pg.global.ui:open(UIConst.UI_ID_HUD_V2)
end

return PVPSystem
