-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonPlayerSkillTip\\CommonPlayerSkillTipCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CommonPlayerSkillTipCtrl = Class.LightClass("CommonPlayerSkillTipCtrl", UICtrl)
local CustomTriggerData = require("Data.custom_trigger_data")
local SkillData = require("Data.player_skill_data")
local PlayerLevelTable = require("Data.player_level_data")
local HotkeyConst = require("Const.HotkeyConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ItemUtils = require("Common.Utils.ItemUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")

CommonPlayerSkillTipCtrl.messages = {}

function CommonPlayerSkillTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CommonPlayerSkillTipCtrl:addListener()
	self:bindTipsGamepadClose()

	function self.view.elementList.luaRenderItem(button, _, data)
		self:onRenderElementItem(button, data)
	end

	function self.view.upEffectList.luaRenderItem(button, index, data)
		self:onRenderUpEffectItem(button, data)
	end

	function self.view.consumeList.luaRenderItem(button, index, data)
		self:onRenderConsumeItem(button, data)
	end

	function self.view.btnLearn.luaClick()
		self:onUpGradeBtnClick()
	end

	function self.view.btnActiveUp.luaClick()
		self:onUpGradeBtnClick()
	end

	function self.view.btnPassUp.luaClick()
		self:onUpGradeBtnClick()
	end

	function self.view.btnEquip.luaClick()
		self:onBtnEquip()
	end

	function self.view.btnEquip2.luaClick()
		self:onBtnEquip()
	end
end

function CommonPlayerSkillTipCtrl:onDestroy()
	if self.iData.onCloseCallback then
		self.iData.onCloseCallback()
	end

	UICtrl.onDestroy(self)
end

function CommonPlayerSkillTipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.iData = info

	function self.view.rootCmp.luaCloseAction()
		self:close()
	end

	function self.view.rootCmp.luaSetScale()
		local scale = Vector3.one * (self.iData.scale or 1)

		self.view.transform.localScale = scale
	end

	self.view.rootCmp.draggable = true
end

function CommonPlayerSkillTipCtrl:onShow()
	if self.iData == nil then
		return
	end

	local autoVer = self.iData.autoVer or false
	local autoHor = self.iData.autoHor or false

	self.view.rootCmp:SetAutoVertical(autoVer, autoHor)

	if self.iData.checkTouchBegin ~= nil then
		self.view.rootCmp:SetCheckTouchState(self.iData.checkTouchBegin)
	end

	if self.iData.rayCastParent then
		self.view.rootCmp:AddRayOcclusionMask(self.iData.rayCastParent, self.iData.addSibling or 0)
	end

	self.view.rootCmp:SetSingleDisplay(self.iData.singleDisplay or false)
	self.view.rootCmp:OpenPopup(self.iData.targetRect)
	self:refreshView()
end

function CommonPlayerSkillTipCtrl:refreshView()
	ClientTextUtils.setText(self.view.btnEquipText, pg.getGameString("CHARACTER_SKILL_EQUIP"))
	ClientTextUtils.setText(self.view.btnEquipText2, pg.getGameString("CHARACTER_SKILL_EQUIP"))

	local data = self.iData.data

	ClientTextUtils.setText(self.view.txtLevel, data.level)

	self.view.icon.url = data.icon

	ClientTextUtils.setText(self.view.skillName, data.name)

	self.view.txtDetail.supportRichText = true

	ClientTextUtils.setText(self.view.txtDetail, data.desc)
	self.view.elementList:SetList(data.attrs)

	if data.video then
		self.view.rootCmp:TryChangePage("VideoPlayer", 1)
		self.view.rootCmp:TryChangePage("NeedDownload", 0)

		self.view.videoSkill.resID = data.video
	else
		self.view.rootCmp:TryChangePage("VideoPlayer", 0)
	end

	self.view.upEffectList:SetList(data.upDescList)
	self.view.consumeList:SetList(data.consume)

	if data.state == self.model.SKILL_STATE.CANT_UNLOCK_LEVEL_INSUFFICIENT then
		self.view.rootCmp:TryChangePage("BtnState", 0)
		ClientTextUtils.setText(self.view.textMaxLv, pg.getFormatText(pg.getGameString("CONDITION_LESS"), data.noMatchDesc))
	elseif data.state == self.model.SKILL_STATE.CANT_UPGRADE_LEVEL_INSUFFICIENT then
		self.view.rootCmp:TryChangePage("BtnState", 0)
		ClientTextUtils.setText(self.view.textMaxLv, pg.getFormatText(pg.getGameString("UP_CONDITION_LESS"), data.noMatchDesc))
	elseif data.state == self.model.SKILL_STATE.CAN_UNLOCK then
		self.view.rootCmp:TryChangePage("BtnState", 1)
	elseif data.state == self.model.SKILL_STATE.CANT_UNLOCK_CONDITION_NOT_MEET then
		self.view.rootCmp:TryChangePage("BtnState", 2)
	elseif data.state == self.model.SKILL_STATE.CANT_UPGRADE_CONDITION_NOT_MEET then
		if data.abilityType == AbilityConst.SKILL_TYPE.COMBATS then
			self.view.rootCmp:TryChangePage("BtnState", 3)
		else
			self.view.rootCmp:TryChangePage("BtnState", 4)
		end
	elseif data.state == self.model.SKILL_STATE.CAN_UPGRADE then
		if data.abilityType == AbilityConst.SKILL_TYPE.COMBATS then
			self.view.rootCmp:TryChangePage("BtnState", 5)
		else
			self.view.rootCmp:TryChangePage("BtnState", 6)
		end
	elseif data.state == self.model.SKILL_STATE.MAX_LEVEL then
		if data.abilityType == AbilityConst.SKILL_TYPE.COMBATS then
			self.view.rootCmp:TryChangePage("BtnState", 7)
		else
			self.view.rootCmp:TryChangePage("BtnState", 8)
			ClientTextUtils.setText(self.view.textMaxLv, string.format("- %s -", pg.getGameString("MaxLevel")))
		end
	end

	if data.hideSkillButton then
		self.view.rootCmp:TryChangePage("HideLevel", 1)
		self.view.rootCmp:TryChangePage("BtnState", 9)
	else
		self.view.rootCmp:TryChangePage("HideLevel", 0)
	end

	self.view.rootCmp:TryChangePage("IsRare", data.isRare and 1 or 0)
end

function CommonPlayerSkillTipCtrl:onRenderElementItem(button, data)
	local oc = button:GetComponent("ObjectReference")
	local iName = oc:GetRefValue("txtName")

	ClientTextUtils.setText(iName, data.name)
end

function CommonPlayerSkillTipCtrl:onRenderUpEffectItem(item, data)
	local oc = item:GetComponent("ObjectReference")
	local iName = oc:GetRefValue("txtName")

	ClientTextUtils.setText(iName, data.name)

	if data.tIndex == 1 then
		local iCurNum = oc:GetRefValue("before")
		local iAddNum = oc:GetRefValue("next")

		ClientTextUtils.setText(iCurNum, data.cur)
		ClientTextUtils.setText(iAddNum, data.next)
	elseif data.tIndex == 2 then
		local iNumber = oc:GetRefValue("num")

		ClientTextUtils.setText(iNumber, string.format("%d/%d", data.finishedCount, data.max))
		item:TryChangePage("Complete", data.finished and 1 or 0)
	end
end

function CommonPlayerSkillTipCtrl:onRenderConsumeItem(item, data)
	local oc = item:GetComponent("ObjectReference")
	local iIcon = oc:GetRefValue("iconUImage")
	local iConsume = oc:GetRefValue("numUText")

	iConsume.supportRichText = true
	data.ownNum = ItemUtils.getItemCountById(pg.me, data.id)
	iIcon.url = data.icon
	iConsume.supportRichText = true

	LuaUIUtils.renderConsumeText(iConsume, data.ownNum, data.num, UIConst.ITEM_STATE.FULL)
end

function CommonPlayerSkillTipCtrl:onUpGradeBtnClick()
	local data = self.iData.data

	if data.state == self.model.SKILL_STATE.CANT_UNLOCK_LEVEL_INSUFFICIENT then
		pg.global.showBubbleMessageRaw(pg.getGameString("LEVEL_LESS"))

		return
	elseif data.state == self.model.SKILL_STATE.MAX_LEVEL then
		pg.global.showBubbleMessageRaw(pg.getGameString("FULL_LEVELED"))

		return
	end

	local check, name = self:checkItemEnough(data.consume)

	if not check then
		pg.global.showBubbleMessageRaw(string.format("道具%s不足", name))

		return
	end

	local me = pg.me

	if data.state == self.model.SKILL_STATE.CAN_UNLOCK then
		me:serverMsg("RPC_CS_UnlockSkillNode", data.id, CallbackHandler(self, "skillLearnOrUpCallback", true))
	elseif data.state == self.model.SKILL_STATE.CAN_UPGRADE then
		me:serverMsg("RPC_CS_upgradeSkillNode", data.id, CallbackHandler(self, "skillLearnOrUpCallback", false))
	end
end

function CommonPlayerSkillTipCtrl:onBtnEquip()
	local callback = self.iData.onSwitchToLearn

	if callback then
		callback()
	end

	self:close()
end

function CommonPlayerSkillTipCtrl:checkItemEnough(consume)
	for _, v in ipairs(consume) do
		if v.ownNum < v.num then
			return false, v.name
		end
	end

	return true
end

function CommonPlayerSkillTipCtrl:skillLearnOrUpCallback(isLearn, result)
	if not result then
		return
	end

	self:refreshView()

	local callback = self.iData.onCallback

	if callback then
		callback(isLearn)
	end
end

function CommonPlayerSkillTipCtrl:onHide()
	return
end

return CommonPlayerSkillTipCtrl
