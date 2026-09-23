-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CreatePlayer\\CreatePlayerCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CreatePlayerCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Const = require("Common.Const.Const")
local CreatePlayerCtrl = Class.LightClass("CreatePlayerCtrl", UICtrl)
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local CreatePlayerTimelineComponent = require("Guis.Panels.CreatePlayer.Component.CreatePlayerTimelineComponent")

CreatePlayerCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.GUIDE_SELECT_FINISH] = {
		"callBackResetSubmitState",
		true
	}
}

function CreatePlayerCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.timelineCmp = CreatePlayerTimelineComponent.new(self)
end

function CreatePlayerCtrl:addListener()
	function self.view.inputField.luaValueChanged(name)
		self:onNameChanged(name)
	end

	function self.view.btnConfirm.luaClick()
		self:submitRename()
	end
end

function CreatePlayerCtrl:onDestroy()
	local DefaultSceneConst = require("Common.Const.DefaultSceneConst")

	pg.global.scene:unloadAdditiveScene(DefaultSceneConst.CREATE_PLAYER_ADDITIVE_SCENE_ID)
	UICtrl.onDestroy(self)
end

function CreatePlayerCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.canSubmit = true

	self:hide()
end

function CreatePlayerCtrl:onShow()
	return
end

function CreatePlayerCtrl:refreshNamePage()
	local tags = self.model:getSelectedTagsInNamePage()

	self.view.selectTags:SetList(tags)
	ClientTextUtils.setText(self.view.nameTitle, pg.getGameString("TID_NAME_TITLE"))
	ClientTextUtils.setText(self.view.nameDetails, pg.getGameString("TID_NAME_TEXT"))
	ClientTextUtils.setText(self.view.nameTip, pg.getGameString("TAG_NARRATION"))
	self:focusNamePage()
end

function CreatePlayerCtrl:focusNamePage()
	local UISceneConst = require("GameApp.UIScene.UISceneConst")
	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	if avatarScene == nil then
		return
	end

	local entity = avatarScene:getCurEntity()

	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.CREATE_USER_SNAPSHOT)

	local uImage = self.view.imgRole
	local rate = Screen.width / 1920
	local sizeDelta = uImage.sizeDelta * 0.9 * rate
	local _ex, _ey, _ez = entity.eModel:GetPositionAgentPosEx()
	local screenPos = avatarScene.camera:WorldToScreenPoint(Vector3.New(_ex, _ey, _ez))
	local position = Vector2.New(screenPos.x - sizeDelta.x / 2 + 80 * rate, screenPos.y - sizeDelta.y * 0.5)

	Utils.captureAndCheckPhoto(Const.PhotoCheckScene.Share, function(sprite, imgUrl, success)
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.CREATE_USER_SNAPSHOT)

		if not success then
			return
		end

		self.view.imgRole.sprite = sprite
	end, position, sizeDelta, 1, false, true)
end

function CreatePlayerCtrl:submitRename()
	return
end

function CreatePlayerCtrl:randomName()
	ClientTextUtils.setText(self.view.inputField, self.model:getRandomName())
end

function CreatePlayerCtrl:onNameChanged(name)
	name = self.model:getValidName(name)

	self.view.inputField:SetTextWithoutNotify(name)
	self.view.rootComponent:TryChangePage("nameTip", string.isNilOrEmpty(name) and 0 or 1)
end

function CreatePlayerCtrl:callBackResetSubmitState()
	if self.view == nil or self.view.rootComponent == nil then
		return
	end

	self.view.rootComponent:TryChangePage("Pass", 1)
	self.view.rootComponent:TryChangePage("Tips", 0)
	self.timelineCmp:continuePlay()
	self.timelineCmp:setPlayerName(self.view.inputField.text)
end

function CreatePlayerCtrl:resetSubmitState(result, errorCode)
	if result == true then
		self:callBackResetSubmitState()
	else
		self.canSubmit = true

		self.view.rootComponent:TryChangePage("Tips", 1)

		local SysNoticeData = require("Data.sys_notice_data")
		local cData = SysNoticeData[errorCode or 0]

		if cData then
			local desc = pg.getLocalizationText(cData.text)

			ClientTextUtils.setText(self.view.txtTips, desc)
		end
	end
end

function CreatePlayerCtrl:fallBack()
	if self.page == 1 then
		return
	end

	local UISceneConst = require("GameApp.UIScene.UISceneConst")
	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	local entity = avatarScene:getCurEntity()

	avatarScene:playIdleAnimation(entity)
	avatarScene:hideNameBG()
	avatarScene:setAvatarCameraMode()
	self:close()
end

function CreatePlayerCtrl:onInputDeviceChanged(deviceType)
	return
end

function CreatePlayerCtrl:onHide()
	return
end

return CreatePlayerCtrl
