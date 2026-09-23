-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GuidePanel\\GuidePanelView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GuidePanelView = Class.LightClass("GuideNormalView", UIView)

function GuidePanelView:findObjects()
	return
end

function GuidePanelView:registerObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.virtualBtn = objectReference:GetRefValue("virtualBtn")
	self.uGuide = objectReference:GetRefValue("uGuide")
	self.mainCom = objectReference:GetRefValue("mainCom")
	self.topTipsOR = objectReference:GetRefValue("topTipsOR")
	self.aiCallOR = objectReference:GetRefValue("aiCallOR")
	self.guideDrag = objectReference:GetRefValue("guideDrag")
	self.alphaMaskBtn = objectReference:GetRefValue("alphaMaskBtn")
	self.blackMaskBtn = objectReference:GetRefValue("blackMaskBtn")
	self.guideVXRoot = objectReference:GetRefValue("guideVXRoot")
	self.skipNode = objectReference:GetRefValue("skipNode")
end

function GuidePanelView:initView()
	return
end

return GuidePanelView
