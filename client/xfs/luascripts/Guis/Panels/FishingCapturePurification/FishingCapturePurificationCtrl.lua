-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCapturePurification\\FishingCapturePurificationCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HotkeyConst = require("Const.HotkeyConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local FishingCapturePurificationCtrl = Class.LightClass("FishingCapturePurificationCtrl", UICtrl)

function FishingCapturePurificationCtrl:addListener()
	function self.view.btnComfirmUButton.luaClick()
		self:onConfirmClick()
	end
end

function FishingCapturePurificationCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	pg.game.input:enableControlInput(false, HotkeyConst.INPUT_BLOCK_FLAG.CatchBoss)

	if pg.pawn and pg.pawn.playEffect then
		self.blackFogEffectId = pg.pawn:playEffect(FishingCaptureConst.BLACK_FOG_SCREEN_EFFECT_KEY)
	end

	self.requestPending = false

	local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture)
	local phase = activityData and activityData:getCurPhase()
	local activityConfig = phase and FishingCaptureActivityData[phase]

	if activityConfig and activityConfig.trainSupply then
		ClientTextUtils.setText(self.view.textUBaseText, pg.getLocalizationText(activityConfig.trainSupply))
	end

	if self.view.btnComfirmTxt then
		ClientTextUtils.setText(self.view.btnComfirmTxt, pg.getGameString("FC_CONTRACT_BUTTON"))
	end
end

function FishingCapturePurificationCtrl:onDestroy()
	if pg.pawn and pg.pawn.stopEffectById then
		pg.pawn:stopEffectById(self.blackFogEffectId)

		self.blackFogEffectId = nil
	end

	pg.game.input:enableControlInput(true, HotkeyConst.INPUT_BLOCK_FLAG.CatchBoss)
end

function FishingCapturePurificationCtrl:onConfirmClick()
	if self.requestPending then
		return
	end

	if not pg.me or not pg.me:canConfirmFishingCaptureContract() then
		return
	end

	self.requestPending = true

	if not pg.me:requestConfirmFishingCaptureContract(function(success)
		self.requestPending = false

		if success then
			self:dismiss()
		end
	end) then
		self.requestPending = false

		return
	end
end

return FishingCapturePurificationCtrl
