-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerBuffDetail\\TowerBuffDetailView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerBuffDetailView = Class.LightClass("TowerBuffDetailView", UIView)

function TowerBuffDetailView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.listBuffUList = objectReference:GetRefValue("listBuffUList")
	self.buffPanelUComponent = objectReference:GetRefValue("buffPanelUComponent")
	self.skillPanelUComponent = objectReference:GetRefValue("skillPanelUComponent")
	self.skilUltimateUButton = objectReference:GetRefValue("skilUltimateUButton")
	self.skil1UButton = objectReference:GetRefValue("skil1UButton")
	self.skil2UButton = objectReference:GetRefValue("skil2UButton")
	self.petDemensionUWidget = objectReference:GetRefValue("petDemensionUWidget")
	self.skillProgressUBaseText = objectReference:GetRefValue("skillProgressUBaseText")
	self.skillProgressUList = objectReference:GetRefValue("skillProgressUList")
	self.buffDetailEmptyUWidget = objectReference:GetRefValue("buffDetailEmptyUWidget")
	self.titleTabUList = objectReference:GetRefValue("titleTabUList")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.imgBossUImage = objectReference:GetRefValue("imgBossUImage")
end

function TowerBuffDetailView:registerObjects()
	if self.skillPanelUComponent then
		self.skillEmpty = self.skillPanelUComponent:Find("Empty")
	end
end

function TowerBuffDetailView:initView()
	return
end

return TowerBuffDetailView
