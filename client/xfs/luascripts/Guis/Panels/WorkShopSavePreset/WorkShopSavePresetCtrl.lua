-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopSavePreset\\WorkShopSavePresetCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local PlayableConst = require("Common.Const.PlayableConst")
local AddressDataConst = require("Const.AddressDataConst")
local UICtrl = require("Guis.UICtrl")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local WorkShopSavePresetCtrl = Class.LightClass("WorkShopSavePresetCtrl", UICtrl)
local SysConfigData = require("Data.sys_config_data")
local AppearanceVariableData = require("Data.appearance_variable_data")
local ClientTextUtils = require("Utils.ClientTextUtils")

WorkShopSavePresetCtrl.messages = {}

function WorkShopSavePresetCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
end

function WorkShopSavePresetCtrl:addListener()
	function self.view.btnCancel.luaClick()
		self:onBtnCancel()
	end

	function self.view.btnConfirm.luaClick()
		self:onBtnConfirm()
	end

	function self.view.inputField.luaValueChanged(newName)
		newName = ClientTextUtils.getValidName(newName, SysConfigData.playerNameMaxLen)

		self.view.inputField:SetTextWithoutNotify(newName)
	end
end

function WorkShopSavePresetCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function WorkShopSavePresetCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.argData = info

	self:poseAvatar()
end

function WorkShopSavePresetCtrl:onShow()
	local data = self.argData

	if not string.isNilOrEmpty(data.title) then
		ClientTextUtils.setText(self.view.txtTitle, pg.getLocalizationText(data.title))
	end

	if not string.isNilOrEmpty(data.partName) then
		ClientTextUtils.setText(self.view.txtPartName, pg.getLocalizationText(data.partName))
	end

	ClientTextUtils.setText(self.view.txtPresetNum, string.format("%d/%d", data.usedNum, data.allNum))

	if data.usedNum == data.unlockNum then
		self.view.rootComponent:TryChangePage("isFull", "Yes")
	else
		self.view.rootComponent:TryChangePage("isFull", "No")
	end
end

function WorkShopSavePresetCtrl:onBtnCancel()
	self:idleAvatar()

	if self.argData.cancelCallback then
		self.argData.cancelCallback()
	end

	self:dismiss()
end

function WorkShopSavePresetCtrl:onBtnConfirm()
	if self.argData.confirmCallback == nil then
		return
	end

	local newPresetName = self.view.inputField.text

	if string.isNilOrEmpty(newPresetName) then
		pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_TITLE_PROMPT"))

		return
	end

	pg.me:sensitiveWordsCheck(newPresetName, function(text)
		self:idleAvatar()
		self.argData.confirmCallback(text)
		self:dismiss()
	end, function(state)
		if self.argData.cancelCallback then
			self.argData.cancelCallback()
		end
	end)
end

function WorkShopSavePresetCtrl:onHide()
	self:idleAvatar()
end

function WorkShopSavePresetCtrl:poseAvatar()
	local entity = self.avatarScene:getCurEntity()

	self.avatarScene:showNameBG(AddressDataConst.AVATAR_TIP_BG, Vector3.New(0, -0.06, 0), function()
		self.avatarScene:setTipCameraMode()
	end)
	self.avatarScene:setCurEntityRot(-15)

	local anim = AppearanceVariableData.AVATAR_ANIM_PRESET or "Show_Pose03_Loop"

	entity:playAnimation(PlayableConst[anim])
end

function WorkShopSavePresetCtrl:idleAvatar()
	local entity = self.avatarScene:getCurEntity()
	local anim = AppearanceVariableData.AVATAR_ANIM_PRESET or "Show_Pose03_End"

	entity:playAnimation(PlayableConst[anim])
	self.avatarScene:playIdleAnimation(entity)
	self.avatarScene:setAvatarCameraMode()
	self.avatarScene:hideNameBG()
end

return WorkShopSavePresetCtrl
