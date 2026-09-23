-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarTip\\AvatarTipCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local PlayableConst = require("Common.Const.PlayableConst")
local AddressDataConst = require("Const.AddressDataConst")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientUtils = require("Utils.ClientUtils")
local UICtrl = require("Guis.UICtrl")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AvatarTipCtrl = Class.LightClass("AvatarTipCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local AppearanceVariableData = require("Data.appearance_variable_data")

AvatarTipCtrl.messages = {}

function AvatarTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.openData = info
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.autoSaveData = info.autoSaveData
	self.avatarScene.pauseAutoSave = true

	self.avatarScene:showNameBG(AddressDataConst.AVATAR_TIP_BG, nil, function()
		self.avatarScene:setTipCameraMode()
		self.avatarScene:showAvatarTemplate(self.autoSaveData.presetKey, function()
			local entity = self.avatarScene:getCurEntity()

			AvatarUtils.parseCustomDataFromDisk(entity, self.autoSaveData)
		end, true)

		local entity = self.avatarScene:getCurEntity()

		self.avatarScene:setCurEntityRot(-15)

		local anim = AppearanceVariableData.AVATAR_ANIM_PRESET or "Show_Pose03_Loop"

		entity:playAnimation(PlayableConst[anim])
	end)
end

function AvatarTipCtrl:addListener()
	function self.view.cancelBtn.luaClick()
		self.avatarScene:removeEntity(self.autoSaveData.presetKey)

		self.autoSaveData = nil

		self.avatarScene:setAvatarCameraMode()
		self.avatarScene:setAvatarCameraModeFar()
		self.avatarScene:hideNameBG()

		if self.openData.cancelCb then
			self.openData.cancelCb()
		end

		self:dismiss()
	end

	function self.view.confirmBtn.luaClick()
		ClientUtils.afterOpenUIAvatarMain()

		local entity = self.avatarScene:getCurEntity()
		local anim = AppearanceVariableData.AVATAR_ANIM_PRESET or "Show_Pose03_End"

		entity:playAnimation(PlayableConst[anim])
		self.avatarScene:setCurEntityRot(0)
		self.avatarScene:playIdleAnimation(entity)
		self.avatarScene:setAvatarCameraMode()
		self.avatarScene:hideNameBG()

		if self.openData.confirmCb then
			self.openData.confirmCb()
		end

		local entity = self.avatarScene:getCurEntity()

		if entity then
			AvatarUtils.parseCustomDataFromDisk(entity, self.autoSaveData)
		end

		self.avatarScene.pauseAutoSave = false

		pg.global.ui:open(UIConst.UI_ID_AVATAR, {
			presetKey = self.autoSaveData.presetKey,
			isFeedTrial = self.openData.isFeedTrial
		})
		self:dismiss()
	end
end

function AvatarTipCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function AvatarTipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	ClientTextUtils.setText(self.view.contextText, pg.getLocalizationText(info.desc))
end

function AvatarTipCtrl:onShow()
	self.avatarScene:setTipCameraMode()
end

function AvatarTipCtrl:onHide()
	return
end

return AvatarTipCtrl
