-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCollection\\GrabEggsCollectionView.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggsCollectionView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GrabEggsCollectionView = Class.LightClass("GrabEggsCollectionView", UIView)

function GrabEggsCollectionView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.panel = objectReference:GetRefValue("panel")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.btnBackUButtonTxt = objectReference:GetRefValue("btnBackUButtonTxt")
	self.switchPanel = objectReference:GetRefValue("switchPanel")
	self.preBtn = objectReference:GetRefValue("preBtn")
	self.nextBtn = objectReference:GetRefValue("nextBtn")
	self.switchTitle = objectReference:GetRefValue("switchTitle")
	self.switchLineList = objectReference:GetRefValue("switchLineList")
	self.seasonList = objectReference:GetRefValue("seasonList")
	self.panelRedDot = objectReference:GetRefValue("panelRedDot")
	self.panelRedDot = objectReference:GetRefValue("panelRedDot")
	self.popUp = objectReference:GetRefValue("popUp")
	self.panelSelArrow = objectReference:GetRefValue("panelSelArrow")
end

function GrabEggsCollectionView:registerObjects()
	return
end

function GrabEggsCollectionView:initView()
	if self.switchPanel then
		self.switchPanel.gameObject:SetActiveEx(false)
	end

	if self.popUp then
		local popUpGameObject = self.popUp.gameObject or self.popUp

		if popUpGameObject.SetActiveEx then
			popUpGameObject:SetActiveEx(false)
		elseif popUpGameObject.SetActive then
			popUpGameObject:SetActive(false)
		end
	end
end

return GrabEggsCollectionView
