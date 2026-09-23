-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookSeason\\HomeBookSeasonView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeBookSeasonView = Class.LightClass("HomeBookSeasonView", UIView)

function HomeBookSeasonView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listItemUList = objectReference:GetRefValue("listItemUList")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
end

function HomeBookSeasonView:registerObjects()
	return
end

function HomeBookSeasonView:initView()
	return
end

return HomeBookSeasonView
