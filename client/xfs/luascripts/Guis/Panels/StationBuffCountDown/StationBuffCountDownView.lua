-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\StationBuffCountDown\\StationBuffCountDownView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local StationBuffCountDownView = Class.LightClass("StationBuffCountDownView", UIView)

function StationBuffCountDownView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.titleText = self.objectReference:GetRefValue("txtTitle")
	self.progress = self.objectReference:GetRefValue("progress")
	self.vxUpAdd1 = self.objectReference:GetRefValue("VXUPAdd1")
	self.vxUpAdd = self.objectReference:GetRefValue("VXUpAdd")
	self.vxUpFlow = self.objectReference:GetRefValue("VXUpFlow")
end

function StationBuffCountDownView:registerObjects()
	return
end

function StationBuffCountDownView:initView()
	return
end

function StationBuffCountDownView:initProgress(count, total)
	self.total = total and total > 0 and total or 1
	self.count = math.clamp(count or 0, 0, self.total)

	self:setFinishVxVisible(false)
	ClientTextUtils.setText(self.titleText, pg.getGameString("HOMECAMP_CAMP_BUFF"))

	self.progress.value = self.count / self.total
end

function StationBuffCountDownView:playProgressToEnd(cb)
	local remain = math.max(self.total - (self.count or 0), 0)

	self.progress:ProgressToValue(1, cb, remain, 0, CS.DG.Tweening.Ease.Linear)
end

function StationBuffCountDownView:setFinishVxVisible(visible)
	self.vxUpAdd1.gameObject:SetActiveEx(visible)
	self.vxUpAdd.gameObject:SetActiveEx(visible)
	self.vxUpFlow.gameObject:SetActiveEx(visible)
end

return StationBuffCountDownView
