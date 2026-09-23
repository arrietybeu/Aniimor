-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GameCutToBlack\\GameCutToBlackView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GameCutToBlackView = Class.LightClass("GameCutToBlackView", UIView)

function GameCutToBlackView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.maskImgAnimation = self.objectReference:GetRefValue("maskImgAnimation")
end

function GameCutToBlackView:registerObjects()
	return
end

function GameCutToBlackView:initView()
	return
end

return GameCutToBlackView
