-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HatredArrowTip\\Component\\FluteInviteComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("FluteInviteComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local FluteInviteComponent = Class.LightClass("FluteInviteComponent", UIComponent)
local SysConfigData = require("Data.sys_config_data")
local AddressDataConst = require("Const.AddressDataConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UI_NODE_FLUTE_RUN_ACROSS = AddressDataConst.UI_NODE_FLUTE_RUN_ACROSS
local Const = require("Common.Const.Const")
local FLUTE_EFFECT_TYPE = {
	RECEIVE_FLUTE = 1,
	PLAY_FLUTE = 0,
	FLUTE_REPLY = 3,
	RECEIVE_REPLY = 2
}
local FLUTE_GENDER_TO_COLOR = {
	[Const.GENDER_TYPE_MALE] = 0,
	[Const.GENDER_TYPE_FEMALE] = 1,
	[Const.GENDER_TYPE_NONE] = 2
}

function FluteInviteComponent:findObjects()
	return
end

function FluteInviteComponent:initView()
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

function FluteInviteComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function FluteInviteComponent:instantiateRes(effectType, fluteGender)
	self.view:addPrefabWithPathAsync(self.view.runAcrossRectTransform, UI_NODE_FLUTE_RUN_ACROSS, function(obj)
		local trans = obj.transform

		self._trackNode = trans:GetComponent("UWidget")

		local objectReference = trans:GetComponent("ObjectReference")

		self._trackNodeFirst = objectReference:GetRefValue("widgetFirstUComponent")
		self._trackNodeSecond = objectReference:GetRefValue("widgetSecondUComponent")
		self._trackRectTrans = trans:GetComponent("RectTransform")

		if effectType == FLUTE_EFFECT_TYPE.PLAY_FLUTE or effectType == FLUTE_EFFECT_TYPE.RECEIVE_FLUTE then
			self._trackNodeFirst:TryChangePage("c1", FLUTE_GENDER_TO_COLOR[fluteGender])
			self._trackNode:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		elseif effectType == FLUTE_EFFECT_TYPE.FLUTE_REPLY or effectType == FLUTE_EFFECT_TYPE.RECEIVE_REPLY then
			self._trackNodeSecond:TryChangePage("color", FLUTE_GENDER_TO_COLOR[fluteGender])
			self._trackNode:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
		end
	end)
end

function FluteInviteComponent:tryTrackTargetPos(effectType, fluteGender)
	if not self._trackNode then
		self:instantiateRes(effectType, fluteGender)

		return
	elseif effectType == FLUTE_EFFECT_TYPE.PLAY_FLUTE or effectType == FLUTE_EFFECT_TYPE.RECEIVE_FLUTE then
		self._trackNodeFirst:TryChangePage("c1", FLUTE_GENDER_TO_COLOR[fluteGender])
		self._trackNode:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	elseif effectType == FLUTE_EFFECT_TYPE.FLUTE_REPLY or effectType == FLUTE_EFFECT_TYPE.RECEIVE_REPLY then
		self._trackNodeSecond:TryChangePage("color", FLUTE_GENDER_TO_COLOR[fluteGender])
		self._trackNode:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end

	self._trackNode:SetActiveFastest(true)

	self._trackRectTrans.rotation = Quaternion(0, 0, 0, 1)
end

function FluteInviteComponent:onShow()
	if self._trackNode then
		self._trackNode:SetActiveFastest(true)
	end
end

function FluteInviteComponent:onHide()
	if self._trackNode then
		self._trackNode:SetActiveFastest(false)
	end
end

function FluteInviteComponent:trackTarget(info)
	if not info then
		return
	end

	self._trackId = info.id

	if not pg.game.setting:getHideAllHudArrowType() then
		self:tryTrackTargetPos(info.effectType, info.fluteGender)
		self:show()
	else
		self._trackId = nil

		self:hide()
	end
end

function FluteInviteComponent:cancelTrack(id)
	if self._trackNode and (not self._trackId or self._trackId == id) then
		self._trackNode:TryDestroyWithAnim(function()
			self:hide()
		end)

		self._trackNode = nil
	end
end

return FluteInviteComponent
