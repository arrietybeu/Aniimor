-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HatredArrowTip\\Component\\HornInviteComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("HornInviteComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local HornInviteComponent = Class.LightClass("HornInviteComponent", UIComponent)
local SysConfigData = require("Data.sys_config_data")
local AddressDataConst = require("Const.AddressDataConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UI_NODE_RUN_ACROSS = AddressDataConst.UI_NODE_RUN_ACROSS

function HornInviteComponent:findObjects()
	return
end

function HornInviteComponent:initView()
	self.canvasRect = pg.global.uiMgr.uiRootCanvasRect
	self.relatedScreenWidth = 3840
	self.relatedScreenHeight = 2160

	local widthRatio = self.ctrl.width / self.relatedScreenWidth
	local heightRatio = self.ctrl.height / self.relatedScreenHeight

	self.ratioX = widthRatio * 0.5
	self.ratioY = heightRatio * 0.5
	self.sqrX = math.pow(self.ratioX, 2)
	self.sqrY = math.pow(self.ratioY, 2)
end

function HornInviteComponent:onDestroy()
	UIComponent.onDestroy(self)
	self:clearUpdateTimer()
end

function HornInviteComponent:instantiateRes()
	if self.load then
		return
	end

	self.load = true

	self.view:addPrefabWithPathAsync(self.view.runAcrossRectTransform, UI_NODE_RUN_ACROSS, function(obj)
		local trans = obj.transform

		self._trackNode = trans:GetComponent("UWidget")
		self._trackRectTrans = trans:GetComponent("RectTransform")

		self._trackNode:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

		if self._trackNode and self._trackPos then
			self:tryTrackTargetPos(self._trackPos)
		end
	end)
end

function HornInviteComponent:tryTrackTargetPos(targetPos)
	if not self._trackNode then
		self:instantiateRes()

		return
	end

	self._trackNode:SetActiveFastest(true)

	local targetViewportPosX, targetViewportPosY, targetViewportPosZ = pg.global.cameraMgr:GetTargetViewportPosXYZ(targetPos[1], targetPos[2], targetPos[3])
	local dirX, dirY

	dirX = targetViewportPosX - 0.5
	dirY = targetViewportPosY - 0.5

	if targetViewportPosZ < 0 then
		local pitch, _, _ = pg.global.cameraMgr:GetCameraRotationEuler()

		if pitch > 0 then
			dirX = -dirX
			dirY = -dirY
		end
	end

	local targetAngle
	local configAngle = SysConfigData.HORN_ROT_ANGLE

	if dirX >= 0 and dirY >= 0 then
		targetAngle = configAngle[1]
	elseif dirX >= 0 and dirY < 0 then
		targetAngle = configAngle[4]
	elseif dirX < 0 and dirY >= 0 then
		targetAngle = configAngle[2]
	elseif dirX < 0 and dirY < 0 then
		targetAngle = configAngle[3]
	end

	local imgRotateAngle = targetAngle
	local arrowRot = Quaternion(0, 0, 0, 1)

	arrowRot:SetEuler(0, 0, imgRotateAngle)

	self._trackRectTrans.rotation = arrowRot
end

function HornInviteComponent:onShow()
	if self._trackNode then
		self._trackNode:SetActiveFastest(true)
		self._trackNode:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function HornInviteComponent:onHide()
	if self._trackNode then
		self._trackNode:SetActiveFastest(false)
	end
end

function HornInviteComponent:trackTarget(info)
	if not info or not info.pos then
		return
	end

	self._trackId = info.id
	self._trackPos = info.pos

	if not pg.game.setting:getHideAllHudArrowType() then
		self:tryTrackTargetPos(self._trackPos)
		self:show()
	else
		self._trackId = nil
		self._trackPos = nil

		self:hide()
	end
end

function HornInviteComponent:cancelTrack(id)
	if self._trackNode and (not self._trackId or self._trackId == id) then
		self._trackNode:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom2, function()
			self:hide()
		end)
	end
end

function HornInviteComponent:clearUpdateTimer()
	if self.updateTimer then
		pg.game.camera:removeLateUpdateTimer(self.updateTimer)

		self.updateTimer = nil
	end
end

function HornInviteComponent:refreshAllArrowHideState()
	if pg.game.setting:getHideAllHudArrowType() then
		if self._trackNode then
			self._trackNode:SetActiveFastest(false)
		end
	elseif self._trackPos then
		self:tryTrackTargetPos(self._trackPos)
	end
end

function HornInviteComponent:updateTrackEnt()
	local targetPos = self._trackPos

	if targetPos then
		self:tryTrackTargetPos(targetPos)
	else
		self:cancelTrack(self._trackId)
	end
end

return HornInviteComponent
