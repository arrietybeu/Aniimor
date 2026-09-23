-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\MarqueeUIComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local MarqueeUIComponent = Class.LightClass("MarqueeUIComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Lume = require("Core.Common.lume")

function MarqueeUIComponent:findObjects()
	self.container = self.transform:GetComponent("UContainer")
end

function MarqueeUIComponent:registerObjectsInternal()
	self.objectReference = self.container.content:GetComponent("ObjectReference")
	self.textUSDFText = self.objectReference:GetRefValue("textUSDFText")
	self.rootAnimation = self.objectReference:GetRefValue("rootAnimation")
	self.textMaskUWidget = self.objectReference:GetRefValue("textMaskUWidget")
	self.appearAnimDuration = 0.5
	self.hideAnimDuration = self.rootAnimation:GetClip("VX_Pb_Popup_Marquee_Out").length
end

function MarqueeUIComponent:initView()
	self:hide()

	self.isRunningMarquee = false
	self.textQueue = {}
	self.textIdQueue = {}
	self.textSpeedQueue = {}
	self.curRunningMarqueeId = nil
end

function MarqueeUIComponent:clearMarquee()
	self:hide()

	self.isRunningMarquee = false

	Lume.clear(self.textQueue)
	Lume.clear(self.textIdQueue)
	Lume.clear(self.textSpeedQueue)

	self.curRunningMarqueeId = nil
end

function MarqueeUIComponent:clearMarqueeById(id)
	local totalCnt = #self.textQueue

	for i = totalCnt, 1, -1 do
		if self.textIdQueue[i] == id then
			table.remove(self.textIdQueue, i)
			table.remove(self.textQueue, i)
			table.remove(self.textSpeedQueue, i)
		end
	end

	if self.curRunningMarqueeId == id then
		self:tryRunNextMarqueeText()
	end
end

function MarqueeUIComponent:applyMarqueeSpeed(speed)
	if speed ~= nil and self.textUSDFText then
		self.textUSDFText:SetMarqueeScrollSpeed(speed)
	end
end

function MarqueeUIComponent:addMarqueeText(text, id, speed)
	if self.isRunningMarquee then
		table.insert(self.textQueue, text)
		table.insert(self.textIdQueue, id)

		self.textSpeedQueue[#self.textQueue] = speed
	else
		self:startRunMarqueeText(text, id, speed)
	end
end

function MarqueeUIComponent:startRunMarqueeText(text, id, speed)
	if not self.container:CheckURLLoaded() then
		self.container:LoadDefaultUrlManually(function()
			self:registerObjectsInternal()
			self:runMarqueeTextInternal(text, speed)
		end)
	else
		self:runMarqueeTextInternal(text, speed)
	end

	self.isRunningMarquee = true
	self.curRunningMarqueeId = id
end

function MarqueeUIComponent:runMarqueeTextInternal(text, speed)
	self:show()
	self:killRealHideTimer()
	LuaUIUtils.setUIViewVisible(self.textMaskUWidget, false)
	self.rootAnimation:Play("VX_Pb_Popup_Marquee_In")
	self:startLoopAnimTimer(text, true, speed)
end

function MarqueeUIComponent:tryRunNextMarqueeText()
	if ToBool(self.textQueue) then
		local nextText = self.textQueue[1]

		table.remove(self.textQueue, 1)

		local nextTextId = self.textIdQueue[1]

		table.remove(self.textIdQueue, 1)

		local nextSpeed = self.textSpeedQueue[1]

		table.remove(self.textSpeedQueue, 1)

		self.curRunningMarqueeId = nextTextId

		self:applyMarqueeSpeed(nextSpeed)
		ClientTextUtils.setText(self.textUSDFText, pg.getLocalizationText(nextText))
	else
		self.isRunningMarquee = false
		self.curRunningMarqueeId = nil

		ClientTextUtils.setText(self.textUSDFText, "")
		self.rootAnimation:Play("VX_Pb_Popup_Marquee_Out")
		self:startRealHideTimer()
	end
end

function MarqueeUIComponent:showMarquee(text, duration, speed)
	if not self.container:CheckURLLoaded() then
		self.container:LoadDefaultUrlManually(function()
			self:registerObjectsInternal()
			self:showMarqueeInternal(text, duration, speed)
		end)
	else
		self:showMarqueeInternal(text, duration, speed)
	end
end

function MarqueeUIComponent:showMarqueeInternal(text, duration, speed)
	self:show()
	self:killRealHideTimer()
	LuaUIUtils.setUIViewVisible(self.textMaskUWidget, false)
	self.rootAnimation:Play("VX_Pb_Popup_Marquee_In")
	self:startLoopAnimTimer(text, false, speed)
	self:startHideTimer(duration)
end

function MarqueeUIComponent:startHideTimer(duration)
	if self.hideTimer ~= nil then
		self:killTimer(self.hideTimer)

		self.hideTimer = nil
	end

	self.hideTimer = self:startTimer(function()
		self.rootAnimation:Play("VX_Pb_Popup_Marquee_Out")
		self:startRealHideTimer()
	end, duration, false)
end

function MarqueeUIComponent:startLoopAnimTimer(text, enableCb, speed)
	if self.startLoopTimer ~= nil then
		self:killTimer(self.startLoopTimer)

		self.startLoopTimer = nil
	end

	self.startLoopTimer = self:startTimer(function()
		LuaUIUtils.setUIViewVisible(self.textMaskUWidget, true)
		self:applyMarqueeSpeed(speed)
		ClientTextUtils.setText(self.textUSDFText, pg.getLocalizationText(text))
		self.rootAnimation:Play("VX_Pb_Popup_Marquee_Loop")

		if enableCb then
			self.textUSDFText:SetMarqueeScrollEndCallback(function()
				self:tryRunNextMarqueeText()
			end)
		end
	end, self.appearAnimDuration, false)
end

function MarqueeUIComponent:startRealHideTimer()
	self:killRealHideTimer()

	self.realHideTimer = self:startTimer(function()
		self:hide()

		self.isRunningMarquee = false
		self.curRunningMarqueeId = nil
	end, self.hideAnimDuration, false)
end

function MarqueeUIComponent:killRealHideTimer()
	if self.realHideTimer ~= nil then
		self:killTimer(self.realHideTimer)

		self.realHideTimer = nil
	end
end

function MarqueeUIComponent:setMarqueeGMVisible(visible)
	LuaUIUtils.setUIViewVisible(self.container, visible)
end

return MarqueeUIComponent
