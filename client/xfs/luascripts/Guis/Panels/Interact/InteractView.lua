-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Interact\\InteractView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LuaUIUtils = require("Utils.LuaUIUtils")
local InteractView = Class.LightClass("InteractView", UIView)
local ClientTextUtils = require("Utils.ClientTextUtils")

function InteractView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.multiSelectHintUWidget = self.objectReference:GetRefValue("multiSelectHintUWidget")
	self.petSwitchCtrlInteractBtn = self.objectReference:GetRefValue("petSwitchCtrlInteractBtn")
	self.petSwitchCtrlInteractBtnKB = self.objectReference:GetRefValue("petSwitchCtrlInteractBtnKB")
	self.petSwitchCtrlIcon = self.objectReference:GetRefValue("petSwitchCtrlIcon")
	self.catchUButton = self.objectReference:GetRefValue("catchUButton")
	self.panelCaptureUWidget = self.objectReference:GetRefValue("panelCaptureUWidget")
	self.interactionNewUWidget = self.objectReference:GetRefValue("interactionNewUWidget")
	self.dialogueUWidget = self.objectReference:GetRefValue("dialogueUWidget")
	self.textInfoUSDFText = self.objectReference:GetRefValue("textInfoUSDFText")
	self.equipmentWidget = self.objectReference:GetRefValue("equipmentWidget")
	self.equipmentName = self.objectReference:GetRefValue("equipmentName")
	self.multiSelectHintUContainer = self.objectReference:GetRefValue("multiSelectHintUContainer")
end

function InteractView:registerObjects()
	self.dialogueUWidget:SetActive(false)

	self.pwtSwitchCtrlTxt = self.petSwitchCtrlInteractBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUSDFText")
end

function InteractView:initView()
	self:setUpSingleInteractBtn(self.petSwitchCtrlInteractBtn)
	LuaUIUtils.setUIViewVisible(self.multiSelectHintUWidget, false)
	self.panelCaptureUWidget:SetActive(true)

	local objRef = self.catchUButton.transform:GetComponent("ObjectReference")

	self.quickItemIcon = objRef:GetRefValue("itemIcon")
	self.quickTxtName = objRef:GetRefValue("txtName")
	self.quickEmptyTxtName = objRef:GetRefValue("emptyTxtName")
	self.quickTxtRate = objRef:GetRefValue("txtRate")
	self.catchUButton:GetComponent("KeyBindingPro").actionPath = "Hud/Interact"
	self.quickProgress = objRef:GetRefValue("progress")
end

function InteractView:setUpSingleInteractBtn(button)
	local isMobile = pg.global.ui.uiMgr:CheckIsMobileInteract()

	if not isMobile then
		button.isSelected = true
	end
end

function InteractView:showSwitchCtrl(styleInfo)
	self.petSwitchCtrlInteractBtnKB.actionPath = styleInfo.hotkeyType
	self.petSwitchCtrlIcon.url = styleInfo.iconId

	local actionText = pg.getLocalizationText(styleInfo.actionName)
	local platformHooks = InteractView._platformHooks

	actionText = platformHooks and platformHooks.showSwitchCtrlText and platformHooks.showSwitchCtrlText(self, styleInfo, actionText) or actionText

	ClientTextUtils.setText(self.pwtSwitchCtrlTxt, actionText)
end

return InteractView
