-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GameplayProgress\\GameplayProgressView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GameplayProgressView = Class.LightClass("GameplayProgressView", UIView)

function GameplayProgressView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.mainText = self.objectReference:GetRefValue("mainText")
	self.mainUProgress = self.objectReference:GetRefValue("mainUProgress")
	self.lineContainerUSeparatorContainer = self.objectReference:GetRefValue("lineContainerUSeparatorContainer")
	self.allWidgetUWidget = self.objectReference:GetRefValue("allWidgetUWidget")
end

function GameplayProgressView:registerObjects()
	return
end

function GameplayProgressView:initView()
	return
end

function GameplayProgressView:initProgress(count, total, text, vehicle)
	self.total = total
	self.mainText.text = text
	self.count = count
	self.vehicle = vehicle

	if self.vehicle and vehicle.isSwing then
		vehicle:setProgressUI(self.mainUProgress)
	end

	self.mainUProgress.value = count / self.total

	self.lineContainerUSeparatorContainer:SetSeparatorCount(self.total - 1)
end

function GameplayProgressView:setCount(count)
	self.count = count

	self.allWidgetUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)

	if count ~= self.total then
		self.allWidgetUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User3)
	end

	if self.vehicle and self.vehicle.isSwing then
		if count == self.total then
			self.allWidgetUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User2)
		end
	else
		self.mainUProgress:ProgressToValue(count / self.total, function()
			if count == self.total then
				self.allWidgetUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User2)
			end
		end, 0.5)
	end
end

function GameplayProgressView:shake()
	self.allWidgetUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	self.mainUProgress:Shake(self.count / self.total, 0.33 / self.total, 1.6)
end

return GameplayProgressView
