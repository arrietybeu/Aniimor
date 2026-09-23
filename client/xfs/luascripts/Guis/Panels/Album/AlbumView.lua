-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Album\\AlbumView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AlbumView = Class.LightClass("AlbumView", UIView)

function AlbumView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.emptyTextUText = self.objectReference:GetRefValue("emptyTextUText")
	self.btnTopUButton = self.objectReference:GetRefValue("btnTopUButton")
	self.btnBottomUButton = self.objectReference:GetRefValue("btnBottomUButton")
	self.txtTipsUBaseText = self.objectReference:GetRefValue("txtTipsUBaseText")
	self.btnUpdateUButton = self.objectReference:GetRefValue("btnUpdateUButton")

	local btnUpdateObjRef = self.btnUpdateUButton:GetComponent("ObjectReference")

	self.btnUpdateTxtNameUText = btnUpdateObjRef:GetRefValue("txtNameUText")
	self.btnOpenUButton = self.objectReference:GetRefValue("btnOpenUButton")
	self.btnSettingUButton = self.objectReference:GetRefValue("btnSettingUButton")
	self.textCapacityUBaseText = self.objectReference:GetRefValue("textCapacityUBaseText")
	self.btnBatchUButton = self.objectReference:GetRefValue("btnBatchUButton")
	self.btnDeleteUButton = self.objectReference:GetRefValue("btnDeleteUButton")
	self.btnExitSelectUButton = self.objectReference:GetRefValue("btnExitSelectUButton")
end

function AlbumView:registerObjects()
	self.rootViewComponent = self.transform:GetComponent("UComponent")
end

function AlbumView:initView()
	if UNITY_PS5 then
		self.btnOpenUButton.gameObject:SetActiveEx(false)
	end
end

return AlbumView
