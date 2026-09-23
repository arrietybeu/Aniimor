-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpChose\\Component\\PvpMatchResultComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PvpMatchResultComponent = Class.LightClass("PvpMatchResultComponent", UIComponent)
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")

function PvpMatchResultComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.name1 = self.objectReference:GetRefValue("name1")
	self.name2 = self.objectReference:GetRefValue("name2")
	self.rankIcon1 = self.objectReference:GetRefValue("rankIcon1")
	self.rankIcon2 = self.objectReference:GetRefValue("rankIcon2")
	self.rankName1 = self.objectReference:GetRefValue("rankName1")
	self.rankName2 = self.objectReference:GetRefValue("rankName2")
end

function PvpMatchResultComponent:initView()
	return
end

function PvpMatchResultComponent:refreshView(data)
	ClientTextUtils.setText(self.name1, data.selfName)
	ClientTextUtils.setText(self.name2, data.otherName)

	self.rankIcon1.url = data.selfScoreData.icon

	ClientTextUtils.setText(self.rankName1, string.format("%s%s", data.selfScoreData.preName, data.selfScoreData.postName))

	self.rankIcon2.url = data.otherScoreData.icon

	ClientTextUtils.setText(self.rankName2, string.format("%s%s", data.otherScoreData.preName, data.otherScoreData.postName))
end

return PvpMatchResultComponent
