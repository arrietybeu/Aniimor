-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\KnowledgeEntrance\\KnowledgeEntranceView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local KnowledgeEntranceView = Class.LightClass("KnowledgeEntranceView", UIView)

function KnowledgeEntranceView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.tabList = objectReference:GetRefValue("tabList")
	self.closeBtn = objectReference:GetRefValue("closeBtn")
	self.rightBtn = objectReference:GetRefValue("rightBtn")
	self.title = objectReference:GetRefValue("title")
end

function KnowledgeEntranceView:registerObjects()
	return
end

function KnowledgeEntranceView:initView()
	return
end

return KnowledgeEntranceView
