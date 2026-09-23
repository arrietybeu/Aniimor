-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GameCountTime\\GameCountTimeView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GameCountTimeView = Class.LightClass("GameCountTimeView", UIView)

function GameCountTimeView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.countTimeAnimation = self.objectReference:GetRefValue("countTimeAnimation")
end

function GameCountTimeView:registerObjects()
	return
end

function GameCountTimeView:initView()
	return
end

return GameCountTimeView
