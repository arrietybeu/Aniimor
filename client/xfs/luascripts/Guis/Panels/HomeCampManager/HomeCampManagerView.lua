-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampManager\\HomeCampManagerView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampManagerView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCampManagerView = Class.LightClass("HomeCampManagerView", UIView)

function HomeCampManagerView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.petListTransform = objectReference:GetRefValue("petListTransform")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.delegateUComponent = objectReference:GetRefValue("delegateUComponent")
	self.backUSDFText = objectReference:GetRefValue("backUSDFText")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.txtRewardUSDFText = objectReference:GetRefValue("txtRewardUSDFText")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
end

function HomeCampManagerView:registerObjects()
	return
end

function HomeCampManagerView:initView()
	return
end

return HomeCampManagerView
