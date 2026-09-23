-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientFishingCaptureDungeon.lua

local Class = require("Core.Framework.Class")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local Time = require("Core.Common.Time")
local ClientPveDungeon = require("Entities.SpaceEntities.ClientPveDungeon")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local BossTitleTrapInvisibleOwner = require("Utils.BossTitleTrapInvisibleOwner")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local Phase = FishingCaptureConst.Phase
local ClientFishingCaptureDungeon = Class.Class("ClientFishingCaptureDungeon", ClientPveDungeon)

function ClientFishingCaptureDungeon:init(dict)
	ClientFishingCaptureDungeon.super.init(self, dict)
	BossTitleTrapInvisibleOwner.forceReleaseAll()

	local tips = pg.global and pg.global.ui and pg.global.ui.tips

	if tips and tips.setBossTitleItemInvisibleReason then
		tips:setBossTitleItemInvisibleReason("fishingCapture", true)
	end

	return true
end

function ClientFishingCaptureDungeon:start()
	ClientFishingCaptureDungeon.super.start(self)
	pg.global.ui.tips:hideCountDown("fishingCapture")
	pg.global.ui.tips:hideBossCatchWarning()
	pg.global.ui.tips:hideBossCatchTips()

	if self.gamePhase == Phase.BATTLE or self.gamePhase == Phase.TRANSITION then
		local remainTime = math.max(0, self.phaseEndTs - Time.secondCache)

		self:_showPhaseCountDown(remainTime)
	elseif self.gamePhase == Phase.CAPTURE then
		pg.global.ui.tips:showBossCatchTips(pg.getGameString("FC_CONTRACT_TIPS"))
	end
end

function ClientFishingCaptureDungeon:onStatusClosed(params)
	ClientFishingCaptureDungeon.super.onStatusClosed(self, params)
	pg.global.ui.tips:hideCountDown("fishingCapture")
	pg.global.ui.tips:hideBossCatchWarning()
	pg.global.ui.tips:hideBossCatchTips()
end

function ClientFishingCaptureDungeon:destroy()
	pg.global.ui.tips:hideCountDown("fishingCapture")
	pg.global.ui.tips:hideBossCatchWarning()
	pg.global.ui.tips:hideBossCatchTips()
	ClientFishingCaptureDungeon.super.destroy(self)
end

function ClientFishingCaptureDungeon:_showPhaseCountDown(remainTime)
	if not remainTime or remainTime <= 0 then
		return
	end

	if self.gamePhase == Phase.TRANSITION then
		pg.global.ui.tips:showBossCatchWarning(remainTime, pg.getGameString("FC_TRANS_TEXT"), pg.getGameString("FC_TRANS_SUBTEXT"))

		return
	end

	if self.gamePhase ~= Phase.BATTLE then
		return
	end

	local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture)
	local phase = activityData and activityData:getCurPhase()

	if not phase or phase <= 0 then
		return
	end

	local activityInfo = FishingCaptureActivityData and FishingCaptureActivityData[phase]
	local warnDuration = activityInfo and activityInfo.battleWarnDuration or 0

	pg.global.ui.tips:showCountDown(remainTime, "fishingCapture", {
		warnDuration = warnDuration
	})
end

function ClientFishingCaptureDungeon:on_gamePhase_changed(oldV, newV)
	pg.global.ui.tips:hideCountDown("fishingCapture")
	pg.global.ui.tips:hideBossCatchWarning()
	pg.global.ui.tips:hideBossCatchTips()

	if newV == Phase.BATTLE then
		self._enterBattleTime = Time.secondCache

		pg.global.ui.tips:showA1Tips({
			id = "TowerResultStart",
			showText = pg.getGameString("FC_BATTLE_START")
		})

		local remainTime = math.max(0, self.phaseEndTs - Time.secondCache)

		self:_showPhaseCountDown(remainTime)
	else
		pg.global.ui.tips:hideA1Tips("TowerResultStart")

		if newV == Phase.TRANSITION then
			local remainTime = math.max(0, self.phaseEndTs - Time.secondCache)

			self:_showPhaseCountDown(remainTime)
		elseif newV == Phase.CAPTURE then
			pg.global.ui.tips:showBossCatchTips(pg.getGameString("FC_CONTRACT_TIPS"))
		end
	end

	if pg.me and pg.me.onPhaseChange then
		pg.me:onPhaseChange({
			phase = newV
		})
	end
end

function ClientFishingCaptureDungeon:on_phaseEndTs_changed(oldV, newV)
	pg.global.ui.tips:hideCountDown("fishingCapture")
	pg.global.ui.tips:hideBossCatchWarning()

	if self.gamePhase == Phase.BATTLE or self.gamePhase == Phase.TRANSITION then
		self:_showPhaseCountDown(math.max(0, newV - Time.secondCache))
	end
end

function ClientFishingCaptureDungeon:on_bossDebuffLayer_changed(oldV, newV)
	return
end

function ClientFishingCaptureDungeon:on_isPausing_changed(oldV, newV)
	if newV then
		pg.global.ui.tips:hideCountDown("fishingCapture")
		pg.global.ui.tips:hideBossCatchWarning()
	elseif self.gamePhase == Phase.BATTLE or self.gamePhase == Phase.TRANSITION then
		self:_showPhaseCountDown(math.max(0, self.phaseEndTs - Time.secondCache))
	end
end

return ClientFishingCaptureDungeon
