-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\knowledgeDetail\\KnowledgeDetailView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local KnowledgeDetailView = Class.LightClass("KnowledgeDetailView", UIView)

function KnowledgeDetailView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.root = objectReference:GetRefValue("root")
	self.exitBtn = objectReference:GetRefValue("exitBtn")
	self.titleTxt = objectReference:GetRefValue("titleTxt")
	self.listTab = objectReference:GetRefValue("listTab")
	self.collectPercentTxt = objectReference:GetRefValue("collectPercentTxt")
	self.paintingNode = objectReference:GetRefValue("paintingNode")
	self.collectionNode = objectReference:GetRefValue("collectionNode")
	self.heroNode = objectReference:GetRefValue("heroNode")
	self.audioNode = objectReference:GetRefValue("audioNode")
	self.imageNode = objectReference:GetRefValue("imageNode")
	self.bookNode = objectReference:GetRefValue("bookNode")
end

function KnowledgeDetailView:registerObjects()
	return
end

function KnowledgeDetailView:initView()
	return
end

return KnowledgeDetailView
