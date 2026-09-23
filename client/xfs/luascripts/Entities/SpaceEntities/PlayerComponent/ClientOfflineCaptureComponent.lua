-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientOfflineCaptureComponent.lua

local class = require("Core.Framework.Class")
local NoBallContext = require("GameApp.Capture.Context.NoBallContext")
local CaptureFsm = require("GameApp.Capture.CaptureFsm")
local castItemData = require("Data.cast_item_data")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local VirtualCatchContext = require("GameApp.Capture.Context.VirtualCatchContext")
local TimerManager = require("Core.Timer.TimerManager")
local FeedLogin = require("GameApp.Feed.FeedLogin")
local UIConst = require("Const.UIConst")
local CaptureStates = CaptureFsm.states
local ClientOfflineCaptureComponent = class.Component("ClientOfflineCaptureComponent")
local OFFLINE_CAPTURE_BALLS = {
	{
		itemId = 110001,
		count = 99
	}
}
local FEED_LOGIN_DELAY = 30

function ClientOfflineCaptureComponent:getOfflineCaptureBalls()
	return OFFLINE_CAPTURE_BALLS
end

function ClientOfflineCaptureComponent.getOfflineBallCount(itemId)
	for _, info in ipairs(OFFLINE_CAPTURE_BALLS) do
		if info.itemId == itemId then
			return info.count or 0
		end
	end

	return 0
end

function ClientOfflineCaptureComponent:ctor()
	self.noBallContext = NoBallContext.new(self)
	self.currentContext = self.noBallContext
	self.preloadedBall = {}
	self.offlineCaptureRecord = {}
	self.offlineCaptureTotal = 0
	self.offlineCapturedCount = 0
	self.offlineAllCapturedNotified = false
	self.feedLoginCountdownStarted = false
end

function ClientOfflineCaptureComponent:registerOfflinePuppet(staticId)
	if staticId == nil then
		return
	end

	if self.offlineCaptureRecord[staticId] ~= nil then
		return
	end

	self.offlineCaptureRecord[staticId] = false
	self.offlineCaptureTotal = self.offlineCaptureTotal + 1
end

function ClientOfflineCaptureComponent:markOfflinePuppetCaptured(staticId)
	if staticId == nil then
		return
	end

	if self.offlineCaptureRecord[staticId] ~= false then
		return
	end

	self.offlineCaptureRecord[staticId] = true
	self.offlineCapturedCount = self.offlineCapturedCount + 1
	self.feedGameEntryUnread = true

	local feedGameEntryCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_FEED_GAME_ENTRY)

	if feedGameEntryCtrl and feedGameEntryCtrl:checkUIOpen() then
		feedGameEntryCtrl:refreshRedDot()
	end

	if self:isAllOfflineCaptured() then
		self:onAllOfflineCaptured()
	end
end

function ClientOfflineCaptureComponent:isAllOfflineCaptured()
	return self.offlineCaptureTotal > 0 and self.offlineCapturedCount >= self.offlineCaptureTotal
end

function ClientOfflineCaptureComponent:onAllOfflineCaptured()
	if self.offlineAllCapturedNotified then
		return
	end

	self.offlineAllCapturedNotified = true
end

function ClientOfflineCaptureComponent:switchContext(context)
	context = context or self.noBallContext

	local fromContext = self.currentContext

	fromContext:destroy()

	self.currentContext = context

	context:enter(fromContext)
end

function ClientOfflineCaptureComponent:forceExitCaptureMode()
	self:switchContext()
end

function ClientOfflineCaptureComponent:toggleCatchMode()
	return self.currentContext:exit()
end

function ClientOfflineCaptureComponent:isInCatchMode()
	return self.currentContext.className ~= "NoBallContext"
end

function ClientOfflineCaptureComponent:isCaptureThrowing()
	local ctx = self.currentContext

	return ctx and (ctx.state == CaptureStates.T or ctx.fsm and ctx.fsm.state == CaptureStates.T) or false
end

function ClientOfflineCaptureComponent:isInQuickCapture()
	return false
end

function ClientOfflineCaptureComponent:isInBossCatch()
	return false
end

function ClientOfflineCaptureComponent:isInBigBallCatch()
	return false
end

function ClientOfflineCaptureComponent:enterOfflineCapture(itemId)
	self:preloadBall(itemId)
	self:switchContext(VirtualCatchContext.new(self, itemId))
end

function ClientOfflineCaptureComponent:captureThrow()
	self.currentContext:throw()
	self:startFeedLoginCountdown()
end

function ClientOfflineCaptureComponent:startFeedLoginCountdown()
	if self.feedLoginCountdownStarted or not FREE_WALK or not pg.global.sdkManager:getIsFeedScene() then
		return
	end

	self.feedLoginCountdownStarted = true
	self.feedLoginTimer = TimerManager.addTimer(FEED_LOGIN_DELAY, function()
		self.feedLoginTimer = nil

		FeedLogin.showFinishConfirm(function()
			self:loginFromFeedScene()
		end, function()
			self.feedLoginCountdownStarted = false

			self:startFeedLoginCountdown()
		end)
	end)
end

function ClientOfflineCaptureComponent:loginFromFeedScene()
	if not FREE_WALK or not pg.global.sdkManager:getIsFeedScene() then
		return
	end

	FeedLogin.login()
end

function ClientOfflineCaptureComponent:onThrowBreak()
	self.currentContext:throwBreak()
end

function ClientOfflineCaptureComponent:onThrowEnd(breaked)
	self.currentContext:throwEnd(breaked)
end

function ClientOfflineCaptureComponent:switchProp()
	local itemId

	itemId = pg.global.ui.hudV2:getCurSelectPropId()

	self:preloadBall(itemId)
	self.currentContext:switch()
end

function ClientOfflineCaptureComponent:preloadBall(itemId)
	if not itemId then
		return
	end

	if self.preloadedBall[itemId] then
		return
	end

	self.preloadedBall[itemId] = true

	local ballData = castItemData[Utils.itemId2CastItemId(itemId)]

	if not ballData then
		return
	end

	pg.global.resMgr:PreLoadInstance(ballData.model, 1)
end

function ClientOfflineCaptureComponent:SyncCaptureHoldVirtualBall(ballUid, itemId)
	local curEnt = pg.getEntityByGlobalId(ballUid)

	if curEnt then
		return curEnt
	end

	local castItemId = Utils.itemId2CastItemId(itemId)
	local ballData = castItemData[castItemId]
	local holdBone = ballData.bone
	local valid, bonePos, boneRot = self.eModel.skeletonView:TryGetBonePosRot(holdBone)

	bonePos = valid and bonePos or self:getPosition()
	boneRot = valid and boneRot or self:getRotation()

	local envEntity = ClientUtils.createClientEntity("ClientCatchBallVirtual", ballUid, {
		itemId = itemId,
		ballUid = ballUid,
		authorityId = self.id,
		position = bonePos,
		rotation = boneRot
	})

	if envEntity and envEntity.eModel then
		envEntity.eModel:SetAgentPositionAndRotationEx(bonePos[1], bonePos[2], bonePos[3], boneRot[1], boneRot[2], boneRot[3], boneRot[4], true)
	end

	return envEntity
end

function ClientOfflineCaptureComponent:preDestroy()
	if self.feedLoginTimer then
		TimerManager.removeTimer(self.feedLoginTimer)

		self.feedLoginTimer = nil
	end

	if self.currentContext then
		self.currentContext:destroy()

		self.currentContext = nil
	end

	if self.noBallContext then
		self.noBallContext.player = nil
	end
end

function ClientOfflineCaptureComponent:destroy()
	self.currentContext = nil
	self.noBallContext = nil
end

return ClientOfflineCaptureComponent
