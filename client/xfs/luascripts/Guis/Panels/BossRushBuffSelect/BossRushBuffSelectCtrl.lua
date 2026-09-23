-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushBuffSelect\\BossRushBuffSelectCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushBuffSelectCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local BossRushBuffSelectCtrl = Class.LightClass("BossRushBuffSelectCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local BossRushCycleData = require("Data.bossrush_cycle_data")
local BossRushUtils = require("Utils.BossRushUtils")
local BossRushBuffData = require("Data.bossrush_buff_data")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")

BossRushBuffSelectCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function BossRushBuffSelectCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.tab = info.tab or 0
	self.isShow = info.isShow
	self.buffIndex = info.buffIndex or 0

	self.view.rootUComponent:TryChangePage("Tab", info.tab)
	self.view.rootUComponent:TryChangePage("Type", self.buffIndex)
	self.view.rootUComponent:TryChangePage("State", self.isShow and 1 or 0)

	self.buffSelected = pg.me.space.selectBatBuffs or {}

	local key = RedDotConst.RedDotPath.BOSS_RUSH_MAIN_BUFF .. pg.me.curBossRushCycleId

	pg.me:setRedDotRecord(Const.CLIENT_KEY.BOSS_RUSH, key, false)
	self:initUI(info)
	self.view.consoleBarConsoleBar:SetState("canSelect", not self.isShow, true)

	if pg.game.input:isUsingGamepad() then
		self.view.btnInfoUButton.renderOpacity = 0.001
	else
		self.view.btnInfoUButton.renderOpacity = 1
	end
end

function BossRushBuffSelectCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:close()
	end

	function self.view.buffSpecialTabUButton.luaClick()
		self.view.rootUComponent:TryChangePage("Type", 0)
		UIUtils.PlayAnimation(self.view.windowAnimation, true)
		self:refreshBuffList("specialBuffRef")
	end

	function self.view.buffNormalTabUButton.luaClick()
		self.view.rootUComponent:TryChangePage("Type", 1)
		UIUtils.PlayAnimation(self.view.windowAnimation, true)
		self:refreshBuffList("generalBuffRef")
	end

	self:bindHotKeyPerform("Raw/GamepadStart", function()
		self.view.btnInfoUButton:OnClickSimulate()
	end)
end

function BossRushBuffSelectCtrl:initUI(params)
	LuaUIUtils.bindCommonTipInfo(self.view.btnInfoUButton, pg.getGameString("BOSS_RUSH_BUFF_SELECT_TIP"))

	self.isOpen = BossRushUtils.checkIsOpen()
	self.cycleId = self.isOpen and pg.me.curBossRushCycleId or pg.me.nextBossRushCycleId
	self.cycleData = BossRushCycleData[self.cycleId]

	if not self.cycleData then
		logger:error("BossRushBuffSelectCtrl:initUI no cycle data for id:", self.cycleId)

		return
	end

	self.view.btnConfirmUButton:SetActive(params and params.showConfirmBtn)

	function self.view.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local name1 = objectReference:GetRefValue("name1")
		local name2 = objectReference:GetRefValue("name2")

		ClientTextUtils.setText(name1, data.name)
		ClientTextUtils.setText(name2, data.name)
	end

	function self.view.listTabUList.luaClick(button, data)
		self.view.rootUComponent:TryChangePage("Tab", data.tab)

		if data.tab == 0 then
			UIUtils.PlayAnimation(self.view.windowAnimation, true)
		end
	end

	local tabData = {
		{
			selected = true,
			tIndex = 0,
			tab = 0,
			name = pg.getGameString("BOSS_RUSH_BATTLE_BUFF")
		},
		{
			tIndex = 2,
			tab = 1,
			name = pg.getGameString("BOSS_RUSH_HELP_BUFF")
		}
	}

	self.view.listTabUList:SetList(tabData)
	self.view.listTabUList:SelectItem(self.tab)

	local tabCheckData = {
		{
			selected = true,
			key = "specialBuffRef",
			tIndex = 0,
			label = pg.getGameString("BOSS_RUSH_SPECIAL_BUFF")
		},
		{
			tIndex = 2,
			key = "generalBuffRef",
			label = pg.getGameString("BOSS_RUSH_NORMAL_BUFF")
		}
	}

	function self.view.listTabCheckUList.luaClick(button, data)
		self:refreshBuffList(data.key)
	end

	self.view.listTabCheckUList:SetList(tabCheckData)
	self.view.listTabCheckUList:SelectItem(self.buffIndex)

	function self.view.listBuffUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
		local contentUScrollRect = objectReference:GetRefValue("contentUScrollRect")
		local textLockTipsUSDFText = objectReference:GetRefValue("textLockTipsUSDFText")
		local textStarNumUSDFText = objectReference:GetRefValue("textStarNumUSDFText")
		local starNumULayoutBox = objectReference:GetRefValue("starNumULayoutBox")
		local textLvUSDFText = objectReference:GetRefValue("textLvUSDFText")
		local textLockUSDFText = objectReference:GetRefValue("textLockUSDFText")

		ClientTextUtils.setText(textLockUSDFText, pg.getGameString("BOSS_RUSH_CHALLENGE_TIP3"))

		if self.isShow then
			button.navForceInteractable = true

			button:SetInteractableNoNavRefresh(false)
		end

		local buffInfo = BossRushBuffData[data.buffId]

		if buffInfo then
			ClientTextUtils.setText(nameUBaseText, pg.getLocalizationText(buffInfo.buffName or ""))
			ClientTextUtils.setText(textLockTipsUSDFText, ClientTextUtils.getGameString("BOSS_RUSH_CHALLENGE_TIP2"))
			ClientTextUtils.setText(contentUScrollRect.content:GetComponent("UBaseText"), pg.getLocalizationText(buffInfo.desc or ""))

			if buffInfo.Bufflevel ~= nil then
				ClientTextUtils.setText(textLvUSDFText, pg.getGameString("LEVEL_LITE") .. tostring(buffInfo.Bufflevel))
			else
				ClientTextUtils.setText(textLvUSDFText, "")
			end

			iconUImage.url = buffInfo.buffIcon or ""

			if data.isUnlock ~= nil then
				local isLock = data.isUnlock == false
				local unlockNeedNum = data.needStar or 0

				if unlockNeedNum > 0 then
					ClientTextUtils.setText(textStarNumUSDFText, unlockNeedNum)
				end

				starNumULayoutBox:SetActive(unlockNeedNum > 0)
				button:TryChangePage("Lock", isLock and 0 or 1)
			else
				starNumULayoutBox:SetActive(false)
				button:TryChangePage("Lock", 1)
			end
		end
	end

	function self.view.listBuffUList.luaClick(button, data)
		if self.isShow then
			pg.global.showBubbleMessageRaw(pg.getGameString("BOSS_RUSH_BUFF_CANT_SELECT_BUFF"))

			return
		end

		if data.isUnlock == false then
			return
		end

		button:InvokeCallback(CS.XGUI.EInvokeTime.User1)

		self.buffSelected[self.curBuffIndex] = data.buffId

		self:refreshBuffSelected()
	end

	self:refreshBuffList(self.buffIndex == 0 and "specialBuffRef" or "generalBuffRef")
	self:refreshBuffSelected()
	self:renderHelpBuff(self.view.supportBuff1ObjectReference, 1)
	self:renderHelpBuff(self.view.supportBuff2ObjectReference, 2)
end

function BossRushBuffSelectCtrl:refreshBuffList(key)
	self.curBuffIndex = key == "specialBuffRef" and 1 or 2

	local buffList = {}

	if key == "specialBuffRef" then
		buffList = BossRushUtils.getSpecialBuffList(self.isOpen)
	else
		buffList = BossRushUtils.getNormalBuffList()
	end

	self.view.listBuffUList:SetList(buffList)
end

function BossRushBuffSelectCtrl:refreshBuffSelected()
	local selectBuffs = self.buffSelected
	local isEmpty1 = true

	if selectBuffs[1] then
		local buffInfo = BossRushBuffData[selectBuffs[1]]

		if buffInfo then
			isEmpty1 = false

			ClientTextUtils.setText(self.view.specialBuffUBaseText, pg.getLocalizationText(buffInfo.buffName or ""))

			self.view.specialBuffUImage.url = buffInfo.buffIcon or ""
		end
	end

	self.view.buffSpecialTabUButton:TryChangePage("Empty", isEmpty1 and 1 or 0)
	self.view.buffSpecialTabUButton:TryChangePage("isShow", self.isShow and 1 or 0)

	local isEmpty2 = true

	if selectBuffs[2] then
		local buffInfo = BossRushBuffData[selectBuffs[2]]

		if buffInfo then
			isEmpty2 = false

			ClientTextUtils.setText(self.view.normalBuffUBaseText, pg.getLocalizationText(buffInfo.buffName or ""))

			self.view.normalBuffUImage.url = buffInfo.buffIcon or ""
		end
	end

	self.view.buffNormalTabUButton:TryChangePage("Empty", isEmpty2 and 1 or 0)
	self.view.buffNormalTabUButton:TryChangePage("isShow", self.isShow and 1 or 0)

	self.view.btnConfirmUButton.interactable = not isEmpty1 and not isEmpty2 and not self.isShow
end

function BossRushBuffSelectCtrl:renderHelpBuff(objRef, index)
	local buffId = self.cycleData.miniGameBuffRef and self.cycleData.miniGameBuffRef[index]

	if not buffId then
		return
	end

	local titleUBaseText = objRef:GetRefValue("titleUBaseText")
	local petNameUBaseText = objRef:GetRefValue("petNameUBaseText")
	local contentUScrollRect = objRef:GetRefValue("contentUScrollRect")
	local iconUImage = objRef:GetRefValue("iconUImage")
	local rootUComponent = objRef:GetRefValue("rootUComponent")
	local objectReference = contentUScrollRect.content:GetComponent("ObjectReference")
	local textLockDetailUBaseText = objectReference:GetRefValue("textLockDetailUBaseText")
	local textDetailUBaseText = objectReference:GetRefValue("textDetailUBaseText")
	local buffInfo = BossRushBuffData[buffId]

	if buffInfo then
		ClientTextUtils.setText(titleUBaseText, pg.getLocalizationText(buffInfo.buffName or ""))
		ClientTextUtils.setText(petNameUBaseText, pg.getLocalizationText(buffInfo.petName or ""))
		ClientTextUtils.setText(textLockDetailUBaseText, pg.getGameString("BOSS_RUSH_HELP_BUFF_LOCK_DESC_" .. index))
		ClientTextUtils.setText(textDetailUBaseText, pg.getLocalizationText(buffInfo.desc or ""))

		iconUImage.url = buffInfo.buffIcon or ""
	end
end

function BossRushBuffSelectCtrl:onDestroy()
	if not self.isShow then
		pg.me:bossRushSelectBattleBuffs(self.buffSelected)
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_BOSS_RUSH_CHALLENGE) then
		pg.global.ui.bossRushChallenge:refreshBuffInfo()
	end

	UICtrl.onDestroy(self)
end

function BossRushBuffSelectCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function BossRushBuffSelectCtrl:onShow()
	return
end

function BossRushBuffSelectCtrl:onHide()
	return
end

function BossRushBuffSelectCtrl:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self.view.btnInfoUButton.renderOpacity = 0.001
	else
		self.view.btnInfoUButton.renderOpacity = 1
	end
end

return BossRushBuffSelectCtrl
