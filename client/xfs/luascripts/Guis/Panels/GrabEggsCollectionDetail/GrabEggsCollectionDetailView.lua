-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCollectionDetail\\GrabEggsCollectionDetailView.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggsCollectionDetailView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GrabEggsCollectionDetailView = Class.LightClass("GrabEggsCollectionDetailView", UIView)

function GrabEggsCollectionDetailView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBack = objectReference:GetRefValue("btnBack")
	self.title = objectReference:GetRefValue("title")
	self.collectionName = objectReference:GetRefValue("collectionName")
	self.collectionDesc = objectReference:GetRefValue("collectionDesc")
	self.collectionDesc.supportRichText = true
	self.mobileTipTxt = objectReference:GetRefValue("mobileTipTxt")
	self.rotateKey = objectReference:GetRefValue("rotateKey")
	self.zoomKey = objectReference:GetRefValue("zoomKey")
	self.rotateKeyTxt = objectReference:GetRefValue("rotateKeyTxt")
	self.zoomKeyTxt = objectReference:GetRefValue("zoomKeyTxt")
end

function GrabEggsCollectionDetailView:registerObjects()
	return
end

function GrabEggsCollectionDetailView:initView()
	return
end

return GrabEggsCollectionDetailView
