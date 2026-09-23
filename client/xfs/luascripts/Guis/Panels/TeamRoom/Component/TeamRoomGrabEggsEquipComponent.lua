-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoom\\Component\\TeamRoomGrabEggsEquipComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local HotkeyConst = require("Const.HotkeyConst")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local TeamRoomGrabEggsEquipComponent = Class.LightClass("TeamRoomGrabEggsEquipComponent", UIComponent)
local NOVICE_PROTECTION_TEAM_TEXT_KEY = "GRAB_EGG_NOVICEPROTECTION_TEAM"
local GRAB_EGGS_NOTICE_TEXT_KEY = "GRAB_EGG_PVP_TXT_5"

TeamRoomGrabEggsEquipComponent.messages = {
	[MessageName.SYNC_TEAM_INFO] = {
		"refreshVisible",
		true
	},
	[MessageName.TEAM_MATCHED_STATUS_CHANGE] = {
		"refreshVisible",
		true
	},
	[MessageName.TEAM_MATCH_START_TIME_CHANGE] = {
		"refreshVisible"
	},
	[MessageName.TEAM_ENTER_MEMBER_AGREE_CHANGE] = {
		"refreshVisible",
		true
	},
	[MessageName.TEAM_PUSH_GO_READY_ROOM] = {
		"refreshVisible",
		true
	},
	[MessageName.TEAM_MATCH_ENTRY_INTERACTABLE_CHANGE] = {
		"refreshVisible",
		true
	},
	[MessageName.GRAB_EGG_NOVICE_PROTECTION_CHANGED] = {
		"refreshGrabEggsNotices",
		true
	}
}

function TeamRoomGrabEggsEquipComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnStore = objectReference:GetRefValue("btnStoreUButton")
	self.btnEquip = objectReference:GetRefValue("btnEquipUButton")
	self.noticeToastItem1UButton = objectReference:GetRefValue("noticeToastItem1UButton")
	self.noticeToastItem2UButton = objectReference:GetRefValue("noticeToastItem2UButton")

	local noticeObjectReference1 = self.noticeToastItem1UButton.transform:GetComponent("ObjectReference")

	self.noticeToastItem1TextUSDFText = noticeObjectReference1:GetRefValue("textUSDFText")
	self.noticeToastItem1Text2USDFText = noticeObjectReference1:GetRefValue("text2USDFText")
	self.noticeToastItem1TextUSDFText.supportRichText = true
	self.noticeToastItem1Text2USDFText.supportRichText = true

	local noticeObjectReference2 = self.noticeToastItem2UButton.transform:GetComponent("ObjectReference")

	self.noticeToastItem2TextUSDFText = noticeObjectReference2:GetRefValue("textUSDFText")
	self.noticeToastItem2Text2USDFText = noticeObjectReference2:GetRefValue("text2USDFText")
	self.noticeToastItem2TextUSDFText.supportRichText = true
	self.noticeToastItem2Text2USDFText.supportRichText = true
end

function TeamRoomGrabEggsEquipComponent:registerObjects()
	function self.btnEquip.luaClick()
		self:onBtnEquip()
	end

	function self.btnStore.luaClick()
		self:onBtnStore()
	end
end

function TeamRoomGrabEggsEquipComponent:initView()
	self:setButtonName(self.btnStore, "GRAB_EGG_BTN_STORE")
	self:setButtonName(self.btnEquip, "GRAB_EGG_BTN_EQUIP")
	self:setButtonHotkey(self.btnStore, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadStart)
	self:setButtonHotkey(self.btnEquip, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth)
	self:refreshVisible()
end

function TeamRoomGrabEggsEquipComponent:setButtonName(button, key)
	local objectReference = button.transform:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

	ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(key))
end

function TeamRoomGrabEggsEquipComponent:setButtonHotkey(button, path)
	local objectReference = button.transform:GetComponent("ObjectReference")
	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

	keyHotKeyContent:SetHotKeyPaths(path)
end

function TeamRoomGrabEggsEquipComponent:onBtnEquip()
	pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_BAG, {
		bagType = UIConst.GRAB_EGG_BAG_TYPE.INVENTORY
	})
end

function TeamRoomGrabEggsEquipComponent:onBtnStore()
	if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
		shopTags = {
			35
		}
	})
end

function TeamRoomGrabEggsEquipComponent:setNoticeText(button, textComponent, textComponent2, text)
	local visible = text ~= nil

	button:SetActive(visible)

	if not visible then
		return
	end

	button:TryChangePage("State", 0)
	ClientTextUtils.setText(textComponent, text)
	ClientTextUtils.setText(textComponent2, text)
end

function TeamRoomGrabEggsEquipComponent:refreshGrabEggsNotices()
	local dungeonId = self.ctrl and self.ctrl.getTeamRoomFrameDungeonId and self.ctrl:getTeamRoomFrameDungeonId()

	if dungeonId ~= Const.ROB_EGG_SCENE_CLIP_ID then
		self.noticeToastItem1UButton:SetActive(false)
		self.noticeToastItem2UButton:SetActive(false)

		return
	end

	local hardLv = self.ctrl and self.ctrl.getTeamRoomFrameHardLv and self.ctrl:getTeamRoomFrameHardLv()
	local player = pg.me
	local info = dungeonId and hardLv and player and player.grabEgg_getNoviceProtectionInfo and player:grabEgg_getNoviceProtectionInfo(dungeonId, hardLv)
	local noviceProtectionText

	if info ~= nil and info.isNextRoundProtected then
		noviceProtectionText = pg.getFormatText(pg.getGameString(NOVICE_PROTECTION_TEAM_TEXT_KEY), info.remainingTimes, info.totalTimes)
	end

	local grabEggsNoticeText = pg.getGameString(GRAB_EGGS_NOTICE_TEXT_KEY)

	self:setNoticeText(self.noticeToastItem1UButton, self.noticeToastItem1TextUSDFText, self.noticeToastItem1Text2USDFText, grabEggsNoticeText)
	self:setNoticeText(self.noticeToastItem2UButton, self.noticeToastItem2TextUSDFText, self.noticeToastItem2Text2USDFText, noviceProtectionText)
end

function TeamRoomGrabEggsEquipComponent:refreshVisible()
	local visible = true

	if pg.global.ui.tips and pg.global.ui.tips.teamMatchTip and pg.global.ui.tips.teamMatchTip.isCountDownPlaying then
		visible = false
	elseif pg.me.matchState ~= Const.PLAYER_MATCH_STATUS.IDLE then
		visible = false
	elseif pg.me:isInTeamDungeonScene() then
		visible = false
	end

	self.gameObject:SetActiveEx(visible)
	self:refreshGrabEggsNotices()
end

return TeamRoomGrabEggsEquipComponent
