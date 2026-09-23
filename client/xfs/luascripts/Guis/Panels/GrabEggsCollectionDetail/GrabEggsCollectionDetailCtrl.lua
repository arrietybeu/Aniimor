-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCollectionDetail\\GrabEggsCollectionDetailCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggsCollectionDetailCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GrabEggsCollectionDetailCtrl = Class.LightClass("GrabEggsCollectionDetailCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local HotkeyConst = require("Const.HotkeyConst")
local ItemData = require("Data.item_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

GrabEggsCollectionDetailCtrl.messages = {}

function GrabEggsCollectionDetailCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initView()
	self:bindGamepadInput()
end

function GrabEggsCollectionDetailCtrl:initView()
	ClientTextUtils.setText(self.view.title, pg.getGameString("GRAB_EGG_Collection_Title_Review"))
	ClientTextUtils.setText(self.view.mobileTipTxt, pg.getGameString("GRAB_EGG_Collection_Review_Tip_Mobile"))
	ClientTextUtils.setText(self.view.rotateKeyTxt, pg.getGameString("GRAB_EGG_Collection_Review_Tip_Rotate"))
	ClientTextUtils.setText(self.view.zoomKeyTxt, pg.getGameString("GRAB_EGG_Collection_Review_Tip_Zoom"))

	if self.view.rotateKey then
		self.view.rotateKey:SetHotKeyPaths("Common/MouseLeftButton")
	end

	if self.view.zoomKey then
		self.view.zoomKey:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.Camera_Zoom)
	end
end

function GrabEggsCollectionDetailCtrl:getBindGameObject()
	local transform = self.view and self.view.transform

	if not transform or UIUtils.IsNull(transform) then
		return nil
	end

	return transform.gameObject
end

function GrabEggsCollectionDetailCtrl:bindGamepadInput()
	local bindObject = self:getBindGameObject()

	if not bindObject then
		return
	end

	self.rightStickBind = KeyBindingPro.GetOrAddKeyBindingByName(bindObject, "grabEggsCollectionDetailRightStick")
	self.rightStickBind.isVirtual = true
	self.rightStickBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightStickMove

	function self.rightStickBind.luaTrigger(inputInfo)
		self:onGamepadRightStickInput(inputInfo)

		return true
	end

	self.leftTriggerBind = KeyBindingPro.GetOrAddKeyBindingByName(bindObject, "grabEggsCollectionDetailLT")
	self.leftTriggerBind.isVirtual = true
	self.leftTriggerBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftTrigger

	function self.leftTriggerBind.luaTrigger(inputInfo)
		self.leftTriggerHeld = inputInfo and inputInfo.phase == "Performed" and inputInfo.isPressed == true

		self:updateGamepadZoomInput()

		return true
	end

	self.rightTriggerBind = KeyBindingPro.GetOrAddKeyBindingByName(bindObject, "grabEggsCollectionDetailRT")
	self.rightTriggerBind.isVirtual = true
	self.rightTriggerBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightTrigger

	function self.rightTriggerBind.luaTrigger(inputInfo)
		self.rightTriggerHeld = inputInfo and inputInfo.phase == "Performed" and inputInfo.isPressed == true

		self:updateGamepadZoomInput()

		return true
	end
end

function GrabEggsCollectionDetailCtrl:onGamepadRightStickInput(inputInfo)
	if not self.uiScene or not self.uiScene.setGamepadRotateInput then
		return
	end

	if inputInfo and inputInfo.phase == "Performed" then
		self.uiScene:setGamepadRotateInput(inputInfo.valueVec2)

		return
	end

	self.uiScene:setGamepadRotateInput(nil)
end

function GrabEggsCollectionDetailCtrl:updateGamepadZoomInput()
	if not self.uiScene or not self.uiScene.setGamepadZoomInput then
		return
	end

	local zoomInput = (self.rightTriggerHeld and 1 or 0) - (self.leftTriggerHeld and 1 or 0)

	self.uiScene:setGamepadZoomInput(zoomInput)
end

function GrabEggsCollectionDetailCtrl:clearGamepadInput()
	self.leftTriggerHeld = false
	self.rightTriggerHeld = false

	if self.uiScene and self.uiScene.resetGamepadInput then
		self.uiScene:resetGamepadInput()
	end
end

function GrabEggsCollectionDetailCtrl:unbindGamepadInput()
	self:clearGamepadInput()

	if self.rightStickBind then
		self.rightStickBind.luaTrigger = nil
		self.rightStickBind.actionPath = nil
		self.rightStickBind = nil
	end

	if self.leftTriggerBind then
		self.leftTriggerBind.luaTrigger = nil
		self.leftTriggerBind.actionPath = nil
		self.leftTriggerBind = nil
	end

	if self.rightTriggerBind then
		self.rightTriggerBind.luaTrigger = nil
		self.rightTriggerBind.actionPath = nil
		self.rightTriggerBind = nil
	end
end

function GrabEggsCollectionDetailCtrl:addListener()
	function self.view.btnBack.luaClick()
		self:close()
	end

	self:bindCloseButton()
end

function GrabEggsCollectionDetailCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local item = info and info.item
	local itemId = item and item.id

	self:refreshCollectionInfo(itemId)

	if itemId and self.uiScene and self.uiScene.showItemModel then
		self.uiScene:showItemModel(itemId, item, info.slotId, info.initialRotation, info.modelScale)
	end
end

function GrabEggsCollectionDetailCtrl:refreshCollectionInfo(itemId)
	local itemConfig = itemId and ItemData[itemId]
	local itemName = itemConfig and itemConfig.itemName and pg.getLocalizationText(itemConfig.itemName) or ""
	local itemDesc = itemConfig and itemConfig.funcRep and pg.getLocalizationText(itemConfig.funcRep) or ""

	ClientTextUtils.setText(self.view.collectionName, itemName)
	ClientTextUtils.setText(self.view.collectionDesc, itemDesc)
end

function GrabEggsCollectionDetailCtrl:onDestroy()
	self:unbindGamepadInput()
	UICtrl.onDestroy(self)
end

function GrabEggsCollectionDetailCtrl:onShow()
	return
end

function GrabEggsCollectionDetailCtrl:onHide()
	self:clearGamepadInput()
end

return GrabEggsCollectionDetailCtrl
