-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestVlog\\QuestVlogView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local QuestVlogView = Class.LightClass("QuestVlogView", UIView)

function QuestVlogView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.mainCom = self.objectReference:GetRefValue("mainCom")
	self.countTime = self.objectReference:GetRefValue("countTime")
	self.btnSkipUButton = self.objectReference:GetRefValue("btnSkipUButton")
end

function QuestVlogView:registerObjects()
	return
end

function QuestVlogView:initView()
	return
end

return QuestVlogView
