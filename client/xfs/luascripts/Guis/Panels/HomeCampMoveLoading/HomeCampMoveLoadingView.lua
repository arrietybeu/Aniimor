-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampMoveLoading\\HomeCampMoveLoadingView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampVisitView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCampMoveLoadingView = Class.LightClass("HomeCampMoveLoadingView", UIView)

function HomeCampMoveLoadingView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.background = self.objectReference:GetRefValue("background")
	self.progressLoad = self.objectReference:GetRefValue("progressLoad")
	self.txtTipsUSDFText = self.objectReference:GetRefValue("txtTipsUSDFText")
end

return HomeCampMoveLoadingView
