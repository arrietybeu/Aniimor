-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FuncMenu\\FuncMenuView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FuncMenuView = Class.LightClass("FuncMenuView", UIView)

function FuncMenuView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnExitUButton = self.objectReference:GetRefValue("btnExitUButton")
	self.playerNameUText = self.objectReference:GetRefValue("playerNameUText")
	self.playerUIDUText = self.objectReference:GetRefValue("playerUIDUText")
	self.listBtnUList = self.objectReference:GetRefValue("listBtnUList")
	self.bottomBtnUList = self.objectReference:GetRefValue("bottomBtnUList")
	self.timeUText = self.objectReference:GetRefValue("timeUText")
	self.bgCloseUButton = self.objectReference:GetRefValue("bgCloseUButton")
	self.uIPbFunMenuAnimation = self.objectReference:GetRefValue("uIPbFunMenuAnimation")
	self.consoleKeyUList = self.objectReference:GetRefValue("consoleKeyUList")
	self.exitKeyUList = self.objectReference:GetRefValue("exitKeyUList")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.btnCopyUIDUButton = self.objectReference:GetRefValue("btnCopyUIDUButton")
	self.unlockConditionUBaseText = self.objectReference:GetRefValue("unlockConditionUBaseText")
	self.root = self.objectReference:GetRefValue("root")
	self.editAvatarUButton = self.objectReference:GetRefValue("editAvatarUButton")
	self.btnEditUButton = self.objectReference:GetRefValue("btnEditUButton")

	if self.uIPbFunMenuAnimation and self.uIPbFunMenuAnimation.gameObject and self.uIPbFunMenuAnimation.gameObject.transform then
		self.funMenuUCurvedPanel = self.uIPbFunMenuAnimation.gameObject.transform:GetComponent("UCurvedPanel")
	end

	self.editHotKeyContent = self.objectReference:GetRefValue("editHotKeyContent")
	self.exitGameHotKeyContent = self.objectReference:GetRefValue("exitGameHotKeyContent")
	self.keyListConsoleUList = self.objectReference:GetRefValue("keyListConsoleUList")
	self.copyBtnHotkeyContent = self.objectReference:GetRefValue("copyBtnHotkeyContent")
end

function FuncMenuView:setViewVisible(visible)
	FuncMenuView.super.setViewVisible(self, visible)

	if self.funMenuUCurvedPanel and NotNil(self.funMenuUCurvedPanel) and self.funMenuUCurvedPanel.RebuildColliderAfterScaleChange then
		self.funMenuUCurvedPanel:RebuildColliderAfterScaleChange()
	end
end

function FuncMenuView:registerObjects()
	return
end

function FuncMenuView:initView()
	local isPS = pg.global.platform:isPS()

	if ClientConfigCloudEnable == "true" then
		self.btnExitUButton.gameObject:SetActiveEx(false)
	end

	if isPS then
		self.btnCloseUButton.gameObject:SetActiveEx(false)
	end
end

return FuncMenuView
