-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RankFilter\\RankFilterView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local RankFilterView = Class.LightClass("RankFilterView", UIView)

function RankFilterView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.listFilterUList = objectReference:GetRefValue("listFilterUList")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
end

function RankFilterView:registerObjects()
	local objectReference = self.btnConfirmUButton:GetComponent("ObjectReference")

	self.txtConfirmUText = objectReference:GetRefValue("txtNameUText")
end

return RankFilterView
