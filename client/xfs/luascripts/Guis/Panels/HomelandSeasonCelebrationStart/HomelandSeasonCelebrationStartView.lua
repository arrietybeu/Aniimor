-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonCelebrationStart\\HomelandSeasonCelebrationStartView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandSeasonCelebrationStartView = Class.LightClass("HomelandSeasonCelebrationStartView", UIView)

function HomelandSeasonCelebrationStartView:findObjects()
	self.txtDetails = self.transform:Find("Panel/TxtDetails"):GetComponent("USDFText")
end

function HomelandSeasonCelebrationStartView:registerObjects()
	return
end

function HomelandSeasonCelebrationStartView:initView()
	return
end

return HomelandSeasonCelebrationStartView
