-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CreateRoleTimeline\\CreateRoleTimelineCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local TimerManager = require("Core.Timer.TimerManager")
local CreateRoleTimelineCtrl = Class.LightClass("CreateRoleTimelineCtrl", UICtrl)

function CreateRoleTimelineCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.forcePresetKey = info and info.forcePresetKey
	self.isFeedTrial = info and info.isFeedTrial == true
	self.avatarCreateRoleScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_CREATE_ROLE_SCENE)

	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("CHOOSE_YOUR_APPEARANCE"))
	ClientTextUtils.setText(self.view.leftDownTitleUSDFText, pg.getGameString("SCN_1"))

	if self.view.countDownUCountDown then
		self.view.countDownUCountDown:Play(120)
	end
end

function CreateRoleTimelineCtrl:addListener()
	function self.view.btn1UButton.luaClick()
		self:gotoAvatarMain(1)
	end

	function self.view.btn2UButton.luaClick()
		self:gotoAvatarMain(2)
	end
end

function CreateRoleTimelineCtrl:onHide()
	self:clearPreparedTimelineTransition()
	self.view.root:TryChangePage("State", 0)
end

function CreateRoleTimelineCtrl:onVisibleChange(visible)
	if visible and self.timelineScenePrepared then
		self.timelineScenePrepared = false

		if self.uiScene then
			self.uiScene:onCtrlVisibleChange(self.module, true)
		end

		return
	end

	UICtrl.onVisibleChangeUIScene(self, visible)
end

function CreateRoleTimelineCtrl:setForcePresetKey(forcePresetKey)
	self.forcePresetKey = forcePresetKey

	if not self.avatarCreateRoleScene then
		self.avatarCreateRoleScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_CREATE_ROLE_SCENE)
	end

	if self.avatarCreateRoleScene then
		self.avatarCreateRoleScene:playTimeline()
	end
end

function CreateRoleTimelineCtrl:showPreparedTimeline(forcePresetKey, isFeedTrial)
	self.forcePresetKey = forcePresetKey
	self.isFeedTrial = isFeedTrial == true

	if not self.avatarCreateRoleScene then
		self.avatarCreateRoleScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_CREATE_ROLE_SCENE)
	end

	local targetScene = self.avatarCreateRoleScene

	if not targetScene then
		self:show()

		return
	end

	local activatePreparedTimeline = targetScene:prepareTimelineFirstFrame(function()
		if self:checkUIClosing() then
			return
		end

		self.adapter:beginUISceneBlack()

		self.preparedTimelineBlackGuard = true

		self.adapter:blackFadeIn(0, false)

		self.preparedTimelineCutFrameId = TimerManager.addSpecificFrameCb(1, false, function()
			self.preparedTimelineCutFrameId = nil

			if self:checkUIClosing() then
				if self.preparedTimelineBlackGuard then
					self.preparedTimelineBlackGuard = false

					self.adapter:endUISceneBlack(0.1)
				end

				return
			end

			self.timelineScenePrepared = true

			self:show()
			targetScene:playPreparedTimeline()

			self.preparedTimelineReleaseBlackFrameId = TimerManager.addSpecificFrameCb(2, false, function()
				self.preparedTimelineReleaseBlackFrameId = nil

				if self.preparedTimelineBlackGuard then
					self.preparedTimelineBlackGuard = false

					self.adapter:endUISceneBlack(0.1)
				end
			end)
		end)
	end)

	if not activatePreparedTimeline then
		self:show()
		targetScene:playTimeline()

		return
	end

	targetScene:onCtrlVisibleChange(self.module, true)
	pg.game.uiScene:switchToScene(self._uiSceneName, nil, nil, nil, self.module)
	activatePreparedTimeline()
end

function CreateRoleTimelineCtrl:gotoAvatarMain(index)
	pg.global.ui:open(UIConst.UI_ID_AVATAR_MAIN, {
		forcePresetKey = self.forcePresetKey,
		fromCreateVideo = index,
		isFeedTrial = self.isFeedTrial
	})
end

function CreateRoleTimelineCtrl:clearPreparedTimelineTransition()
	self.timelineScenePrepared = false

	if self.preparedTimelineCutFrameId then
		TimerManager.delFrameCb(self.preparedTimelineCutFrameId)

		self.preparedTimelineCutFrameId = nil
	end

	if self.preparedTimelineReleaseBlackFrameId then
		TimerManager.delFrameCb(self.preparedTimelineReleaseBlackFrameId)

		self.preparedTimelineReleaseBlackFrameId = nil
	end

	if self.preparedTimelineBlackGuard then
		self.preparedTimelineBlackGuard = false

		self.adapter:endUISceneBlack(0)
	end
end

function CreateRoleTimelineCtrl:onDestroy()
	self:clearPreparedTimelineTransition()
	UICtrl.onDestroy(self)
end

function CreateRoleTimelineCtrl:onTimelineFinished()
	self.view.root:TryChangePage("State", 1)

	local scene = self.avatarCreateRoleScene

	if scene and not scene.expire then
		for _, entity in pairs(scene:getAllEntities()) do
			local modelView = entity.eModel.modelModelView

			if NotNil(modelView) and NotNil(entity.eModel.modelRoot) then
				modelView:CloseBoneSpring(entity.eModel.modelRoot)
			end
		end
	end
end

return CreateRoleTimelineCtrl
