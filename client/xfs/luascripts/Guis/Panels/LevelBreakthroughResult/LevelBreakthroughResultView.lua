-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LevelBreakthroughResult\\LevelBreakthroughResultView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LevelBreakthroughResultView = Class.LightClass("LevelBreakthroughResultView", UIView)

function LevelBreakthroughResultView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.petName = self.objectReference:GetRefValue("petName")
	self.levelNum = self.objectReference:GetRefValue("levelNum")
	self.imgPetUImage = self.objectReference:GetRefValue("imgPetUImage")
	self.breakNum = self.objectReference:GetRefValue("breakNum")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
end

function LevelBreakthroughResultView:initView()
	return
end

return LevelBreakthroughResultView
