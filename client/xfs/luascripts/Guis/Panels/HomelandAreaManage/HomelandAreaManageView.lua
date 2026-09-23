-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandAreaManage\\HomelandAreaManageView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandAreaManageView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandAreaManageView = Class.LightClass("HomelandAreaManageView", UIView)

function HomelandAreaManageView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.titleText = objectReference:GetRefValue("titleText")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.btnProductUButton = objectReference:GetRefValue("btnProductUButton")
	self.btnPublicUButton = objectReference:GetRefValue("btnPublicUButton")
	self.btnOreUButton = objectReference:GetRefValue("btnOreUButton")
	self.btnSeasonUButton = objectReference:GetRefValue("btnSeasonUButton")
	self.btnBuildUButton = objectReference:GetRefValue("btnBuildUButton")
	self.btnLakeUButton = objectReference:GetRefValue("btnLakeUButton")
	self.popInfoUWidget = objectReference:GetRefValue("popInfoUWidget")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
end

function HomelandAreaManageView:registerObjects()
	self.areaInfoObjectReference = self.popInfoUWidget:GetComponent("ObjectReference")
end

function HomelandAreaManageView:initView()
	return
end

return HomelandAreaManageView
