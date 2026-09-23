-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ItemObtain\\ItemObtainCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ItemObtainCtrl = Class.LightClass("ItemObtainCtrl", UICtrl)
local EventConst = require("Const.EventConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local logger = require("Core.Log.LoggerManager").getLogger("PaymentShopsComponent")
local UIConst = require("Const.UIConst")
local ItemData = require("Data.item_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ItemConstSourceData = require("Data.item_const_source_data")
local ItemBatchNotifyFullData = require("Data.item_batch_notify_full_data")
local ClientConst = require("Const.ClientConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")

ItemObtainCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

local TIME_SHOW_CLOSE_BTN = 1

function ItemObtainCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isClosing = false

	function self.view.itemList.luaRenderItem(item, index, data)
		self:instantiateItem(item, index, data)
	end

	function self.view.closeBtn.luaClick()
		self:closePanel()
	end

	self.view.closeBtn:SetGamepadAction("Raw/GamepadButtonSouth", nil, function()
		self:closePanel()
	end)
end

function ItemObtainCtrl:addListener()
	return
end

function ItemObtainCtrl:onOpen()
	self.view.closeBtn:SetActive(false)
	self:startTimer(function()
		self.view.closeBtn:SetActive(true)
	end, TIME_SHOW_CLOSE_BTN)
end

function ItemObtainCtrl:checkCanOpen(showNotice, params)
	if self._isOpen or self.view and self.view.widget.isClosing then
		self._pendingQueue = self._pendingQueue or {}

		table.insert(self._pendingQueue, params)

		return false
	end

	self.itemListData = params.itemList
	self.source = params.source
	self.rechargeDes = params.rechargeDes

	return true
end

function ItemObtainCtrl:onShow()
	if not self.itemListData then
		return
	end

	self.model:parseItemList(self.itemListData, self.source)
	self.view.itemList:SetList(self.itemListData)
	self:refreshDungeonQuitText()

	local sourceCfg = ItemBatchNotifyFullData[self.source]
	local strTxt

	if sourceCfg and sourceCfg.txt then
		strTxt = pg.getLocalizationText(sourceCfg.txt)
	end

	strTxt = strTxt or self.rechargeDes

	if strTxt then
		self.view.txtTipsUBaseText:SetActive(true)
		ClientTextUtils.setText(self.view.txtTipsUBaseText, strTxt)
	end

	if sourceCfg and sourceCfg.name then
		local name = pg.getLocalizationText(sourceCfg.name)

		ClientTextUtils.setText(self.view.txtName1UBaseText, name)
		ClientTextUtils.setText(self.view.txtNameUBaseText, name)
	else
		ClientTextUtils.setText(self.view.txtName1UBaseText, pg.getGameString("SHOP_GET"))
		ClientTextUtils.setText(self.view.txtNameUBaseText, pg.getGameString("SHOP_GET"))
	end

	self:refreshRogueRewardUp()
	self:CheckBadgeCollection()
	pg.game.audio:triggerEvent("SFX_UI_CommonRewardPanel")
	pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonHigh")
end

function ItemObtainCtrl:refreshDungeonQuitText()
	local textKey = "FC_DUNGEON_QUIT_TEXT_OLD"

	if self.source == ItemConstSourceData.ITEM_SOURCE_FC_WEEK_DUNGEON then
		textKey = "FC_DUNGEON_QUIT_TEXT"
	end

	ClientTextUtils.setText(self.view.txtDownUBaseText, pg.getGameString(textKey))
end

function ItemObtainCtrl:onDestroy()
	if self.source == ItemConstSourceData.ITEM_SOURCE_FC_WEEK_DUNGEON then
		self._waitExitFishingCaptureWeeklyDungeon = true
	end

	pg.global.eventEmitter:emit(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, {})
	UICtrl.onDestroy(self)

	if self._pendingQueue and #self._pendingQueue > 0 then
		local nextParams = table.remove(self._pendingQueue, 1)

		TimerManager.addNextFrameCb(function()
			pg.global.ui.itemObtain:open(nextParams)
		end)

		return
	end

	self:_tryExitFishingCaptureWeeklyDungeon()
end

function ItemObtainCtrl:_tryExitFishingCaptureWeeklyDungeon()
	if not self._waitExitFishingCaptureWeeklyDungeon then
		return
	end

	self._waitExitFishingCaptureWeeklyDungeon = nil

	local space = pg.me and pg.me.space

	if not space or not Utils.isWeeklyDungeonSceneId(space.sceneId) then
		return
	end

	ClientUtils.exitDungeon()
end

function ItemObtainCtrl:instantiateItem(item, index, data)
	function item.luaClick()
		self:onClickItem(item, data)
	end

	item.draggable = false

	local itemNum = data.itemCount
	local objectReference = item:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local buttonUpUButton = objectReference:GetRefValue("buttonUpUButton")
	local itemLableUContainer = objectReference:GetRefValue("itemLableUContainer")

	if ClientActivityUtils.isRogueRewardUp() and data.isUpReward then
		buttonUpUButton:SetActive(true)
	else
		buttonUpUButton:SetActive(false)
	end

	item:TryChangePage("Quality", data.quality)
	ClientTextUtils.setText(txtNameUText, tostring(itemNum))

	iconUImage.url = LuaUIUtils.getIconByIconId(data.icon)

	if data.isRechargeAdd or data.isRechargeFirst then
		itemLableUContainer:SetActive(true)
		itemLableUContainer:LoadDefaultUrlManually()

		local objectReference1 = itemLableUContainer.content:GetComponent("ObjectReference")
		local txtName = objectReference1:GetRefValue("txtName")
		local strLaber = data.isRechargeAdd and pg.getGameString("SHOP_ADD_GIFT") or pg.getGameString("SHOP_CHARGE_FRIST")

		ClientTextUtils.setText(txtName, strLaber)
	else
		itemLableUContainer:SetActive(false)
	end

	local anim = item:GetComponent("Animation")

	anim:Play("UI_Prefab_Prop_Card_In_FlashLight")
end

function ItemObtainCtrl:onClickItem(button, data)
	if data.isPet then
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_PET_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_PET_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_PET_TIP, {
				autoVer = true,
				checkTouchBegin = false,
				addSibling = 1,
				templateId = data.content.templateId,
				targetRect = button,
				rayCastParent = self.view.widget
			})
		end
	elseif pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	else
		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			autoHor = true,
			checkTouchBegin = false,
			addSibling = 1,
			id = data.itemId,
			num = data.itemCount,
			invId = data.invId,
			genID = data.genID,
			targetRect = button,
			rayCastParent = self.view.widget,
			closeOnJumpToSource = function()
				self:closePanel()
			end
		})
	end
end

function ItemObtainCtrl:closePanel()
	if self.isClosing then
		return
	end

	self.isClosing = true

	pg.global.ui:close(UIConst.UI_ID_COMMON_OBTAIN)
	pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

	if self.source == ItemConstSourceData.ITEM_SOURCE_ROGUE_START_STYLE or self.source == ItemConstSourceData.ITEM_SOURCE_SANDBOX_ROGUELIKE then
		pg.me.space:nextCacheInfo()
	end
end

function ItemObtainCtrl:onInputDeviceChanged(deviceType)
	return
end

function ItemObtainCtrl:CheckBadgeCollection()
	if self.source == ItemConstSourceData.ITEM_SOURCE_ACTIVITY_COLLECT_BADGE then
		for _, rawData in ipairs(self.itemListData) do
			local content = rawData.content

			if content and content.rewardQuality == 6 then
				self.view.lightContentUWidget:SetActive(true)

				return
			end
		end
	end

	self.view.lightContentUWidget:SetActive(false)
end

function ItemObtainCtrl:refreshRogueRewardUp()
	local isRewardUp = false

	for _, rawData in ipairs(self.itemListData) do
		if rawData.isUpReward and ClientActivityUtils.isRogueRewardUp() then
			isRewardUp = true

			break
		end
	end

	self.view.doubleRewardUWidget:SetActive(isRewardUp)

	if isRewardUp then
		local objectReference = self.view.doubleRewardUWidget:GetComponent("ObjectReference")
		local timesUBaseText = objectReference:GetRefValue("timesUBaseText")
		local curCostTxt = objectReference:GetRefValue("curCostTxt")
		local remainCnt, totalCnt, curCostCnt = ClientActivityUtils.getRogueRewardUpConfig()

		if timesUBaseText then
			timesUBaseText:SetActive(true)
			ClientTextUtils.setText(timesUBaseText, string.format("%s/%s", remainCnt, totalCnt))
		end

		if curCostTxt then
			ClientTextUtils.setText(curCostTxt, pg.getFormatText(pg.getGameString("MOCKBATTLE_UP_CONSUME"), curCostCnt))
		end
	end
end

return ItemObtainCtrl
