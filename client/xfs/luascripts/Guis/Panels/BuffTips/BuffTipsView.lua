-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BuffTips\\BuffTipsView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BuffTipsView = Class.LightClass("BuffTipsView", UIView)
local LuaUIUtils = require("Utils.LuaUIUtils")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackManager = require("Core.Net.CallbackManager")
local UIUtils = CS.FunPlus.WorldX.Utils.UIUtils
local ClientTextUtils = require("Utils.ClientTextUtils")

function BuffTipsView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.playerTip = self.objectReference:GetRefValue("playerTip")
	self.petTip = self.objectReference:GetRefValue("petTip")
	self.animation = self.objectReference:GetRefValue("animation")

	LuaUIUtils.setUIViewVisible(self.playerTip, false)
	LuaUIUtils.setUIViewVisible(self.petTip, false)

	self.appearDuration = self.animation:GetClip("VX_Node_Buff_Tips").length
	self.playerTimer = nil
	self.petTimer = nil
	self.playerEntId = nil
	self.petEntId = nil
end

function BuffTipsView:registerObjects()
	return
end

function BuffTipsView:initView()
	self.tickPosTimer = TimerManager.addRepeatNextFrameCb(function()
		self:tickPos()
	end)
end

function BuffTipsView:tickPos()
	if self.petEntId then
		local petEnt = pg.getEntity(self.petEntId)

		if petEnt then
			local uiPos = UIUtils.WorldToUIPosition(petEnt:getPosition() + Vector3(0, petEnt.eModel.height + 0.6, 0))

			self.petTip.position = uiPos
		end
	end

	if self.playerEntId then
		local playerEnt = pg.getEntity(self.playerEntId)

		if playerEnt then
			local uiPos = UIUtils.WorldToUIPosition(playerEnt:getPosition() + Vector3(0, playerEnt.eModel.height + 0.6, 0))

			self.playerTip.position = uiPos
		end
	end
end

function BuffTipsView:showTips(isPet, entId, tips, isDebuff)
	if isPet then
		if self.petTimer then
			TimerManager.removeTimer(self.petTimer)
		end

		self.petEntId = entId
		self.petTimer = TimerManager.addTimer(self.appearDuration, function()
			self.petEntId = nil
			self.petTimer = nil
		end)
	else
		if self.playerTimer then
			TimerManager.removeTimer(self.playerTimer)
		end

		self.playerEntId = entId
		self.playerTimer = TimerManager.addTimer(self.appearDuration, function()
			self.playerEntId = nil
			self.playerTimer = nil
		end)
	end

	local item = isPet and self.petTip or self.playerTip
	local controller = item:GetComponent("UComponent")
	local ent = pg.getEntity(entId)
	local uiPos = UIUtils.WorldToUIPosition(ent:getPosition() + Vector3(0, ent.eModel.height + 0.2, 0))

	item.position = uiPos

	LuaUIUtils.setUIViewVisible(item, true)

	local text = item:Find("Box/Content/Txt"):GetComponent("UBaseText")

	if isDebuff then
		controller:TryChangePage("state", "down")
	else
		controller:TryChangePage("state", "up")
	end

	controller:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	ClientTextUtils.setText(text, pg.getLocalizationText(tips))
end

function BuffTipsView:onDestroy()
	CallbackManager.delFrameCb(self.tickPosTimer)
	UIView.onDestroy(self)
end

return BuffTipsView
