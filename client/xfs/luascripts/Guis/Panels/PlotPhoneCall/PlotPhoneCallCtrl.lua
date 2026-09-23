-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlotPhoneCall\\PlotPhoneCallCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AddressDataConst = require("Const.AddressDataConst")
local PlayableConst = require("Common.Const.PlayableConst")
local PlotPhoneCallCtrl = Class.LightClass("PlotPhoneCallCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local ToBool = ToBool
local Vector3 = Vector3

PlotPhoneCallCtrl.WaitCameraAnimTime = 1
PlotPhoneCallCtrl.HeadShowDelayTime = 0.25
PlotPhoneCallCtrl.DEFAULT_UI_POS = Vector3(-774.5, 123, 100)
PlotPhoneCallCtrl.DEFAULT_UI_ROT = Quaternion.Euler(0, -40.5, 2)
PlotPhoneCallCtrl.DEFAULT_UI_REVERSE_CAM_POS = Vector3(-206, 100, 100)
PlotPhoneCallCtrl.DEFAULT_UI_REVERSE_CAM_ROT = Quaternion.Euler(3, 226, 2)

function PlotPhoneCallCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PlotPhoneCallCtrl:addListener()
	function self.view.playBtn.luaClick()
		self:startPlayVideo()
	end
end

function PlotPhoneCallCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.view.panelUComponent:TryChangePage("State", 0)

	self.view.panelRectTransform.anchoredPosition = self.DEFAULT_UI_POS
	self.view.panelRectTransform.rotation = self.DEFAULT_UI_ROT

	self:playInitialShowAnim()
	self:tryShowNpcCallHeadIcon(info.resId)
	self:tryShowNpcCallName(info.name)

	local nearHeight, farHeight = pg.pawn:getCameraHeightInfo()
	local pivotOffset = Vector3(0, nearHeight, 0)

	pg.game.camera.lowPriorityAnimCameraMode:playCameraAnimByActorId(pg.me.actorId, AddressDataConst.CAMERA_ANI_PHONE_CALL_LEFT_START, 0, 1, false, nil, pivotOffset, nil, true, 1, true, 0.2, nil, true)

	local callback = info.callback

	self:startTimer(function()
		if not self.view then
			return
		end

		if callback then
			callback()
		end
	end, self.HeadShowDelayTime + self.WaitCameraAnimTime, false)

	if info.disableAni ~= true then
		pg.me:playAnimation(PlayableConst.Dialogue)
	end
end

function PlotPhoneCallCtrl:onDestroy()
	pg.game.camera.lowPriorityAnimCameraMode:stopCameraAnim()
	pg.game.camera.playerCameraMode:resetCamera()
	pg.me:stopAnimation(PlayableConst.Dialogue)
	UICtrl.onDestroy(self)
end

function PlotPhoneCallCtrl:onShow()
	UICtrl.onShow(self)
end

function PlotPhoneCallCtrl:playInitialShowAnim()
	self.view.connectUText:SetActiveQuickly(false)
	self.view.nameUText:SetActiveQuickly(false)
	self:startTimer(function()
		if not self.view then
			return
		end
	end, self.WaitCameraAnimTime, false)
end

function PlotPhoneCallCtrl:tryShowNpcCallName(name)
	name = name or pg.getGameString("AI_COMMUNICATE_STRANGER")

	ClientTextUtils.setText(self.view.nameUText, name)
end

function PlotPhoneCallCtrl:tryShowNpcCallHeadIcon(iconUrl)
	local enable = ToBool(iconUrl)

	LuaUIUtils.setUIViewVisible(self.view.panelAvatarUComponent, enable)

	if not enable then
		return
	end

	self.view.imgRoleUImage.url = iconUrl
end

function PlotPhoneCallCtrl:switchCameraAnim(isNpc)
	local nearHeight, farHeight = pg.pawn:getCameraHeightInfo()
	local pivotOffset = Vector3(0, nearHeight, 0)
	local cameraAnim = isNpc and AddressDataConst.CAMERA_ANI_PHONE_CALL_LEFT or AddressDataConst.CAMERA_ANI_PHONE_CALL_LEFT_REVERSE

	pg.game.camera.lowPriorityAnimCameraMode:playCameraAnimByActorId(pg.me.actorId, cameraAnim, 0, 1, false, nil, pivotOffset, nil, true, 1, true, 0.2, nil, true)

	if not self.view then
		return
	end

	local panelPos = isNpc and self.DEFAULT_UI_POS or self.DEFAULT_UI_REVERSE_CAM_POS
	local panelRot = isNpc and self.DEFAULT_UI_ROT or self.DEFAULT_UI_REVERSE_CAM_ROT

	self.view.panelRectTransform.anchoredPosition = panelPos
	self.view.panelRectTransform.rotation = panelRot
end

function PlotPhoneCallCtrl:switchToShowVideoOrPhoto(resID)
	if string.match(resID, "%.mp4$") or string.match(resID, "%.mp4$") then
		self.view.videoPlayer.resID = resID

		self.view.videoPlayer:PrepareVideo()

		self.view.picUImage.url = nil

		self.view.playBtn:SetActiveFastest(true)
	else
		self.view.picUImage.url = resID
		self.view.videoPlayer.resID = nil

		self.view.playBtn:SetActiveFastest(false)
	end

	self.view.panelUComponent:TryChangePage("State", 1)
end

function PlotPhoneCallCtrl:startPlayVideo()
	self.view.videoPlayer:PlayVideo()
	self.view.playBtn:SetActiveFastest(false)
end

return PlotPhoneCallCtrl
