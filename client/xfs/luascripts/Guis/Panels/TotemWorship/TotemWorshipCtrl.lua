-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TotemWorship\\TotemWorshipCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TotemWorshipCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local RoguelikeData = require("Data.roguelike_data")
local UIConst = require("Const.UIConst")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TotemUpgradeData = require("Data.totem_upgrade_data")
local HotkeyConst = require("Const.HotkeyConst")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AddressDataConst = require("Const.AddressDataConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local ClientConst = require("Const.ClientConst")
local TotemWorshipCtrl = Class.LightClass("TotemWorshipCtrl", UICtrl)
local TotemRewardType = {
	Ability = 1,
	Item = 0
}

TotemWorshipCtrl.messages = {
	[MessageName.ADD_TOTEM_EXP] = {
		"onAddTotemExp",
		true
	}
}

function TotemWorshipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.view = self.view
	self.openTime = 0
end

function TotemWorshipCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:resetTotemCamera()
		self:close()
	end

	function self.view.submitBtn1.luaClick()
		self:levelUpSubmit()
	end

	local submitBindKeyBind1 = self.view.submitBtn1:GetComponent("KeyBindingPro")

	submitBindKeyBind1.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth

	function self.view.submitBtn2.luaClick()
		self:submitAll()
	end

	local submitBindKeyBind2 = self.view.submitBtn2:GetComponent("KeyBindingPro")

	submitBindKeyBind2.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth

	function self.view.rewardList.luaRenderItem(button, index, data)
		self:setRewardItemData(button, index, data)
	end

	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
		self:resetTotemCamera()
		self:close()
	end)
end

function TotemWorshipCtrl:onDestroy()
	self:destroyAllCutscenes()
	self:resetTotemCamera()
	UICtrl.onDestroy(self)
end

function TotemWorshipCtrl:checkCanOpen(showNotice, info)
	local totemId = info[1]

	if not totemId then
		return false
	end

	local totemUpgradeData = TotemUpgradeData[totemId]

	if not totemUpgradeData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("TotemWorshipCtrl showTotemWorship totemIdInvalid", totemId)
		end

		return
	end

	return true
end

function TotemWorshipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.openTime = Time.realSecondCache
	self.totemId = info[1] or 0
	self.uiContext = info.uiContext or {}

	self:refreshInfo()
	self:setTotemCamera()
end

function TotemWorshipCtrl:onShow()
	pg.game:setModuleEnable("TotemWorship", ClientConst.ModuleKey.OperationHint, false)
	pg.game:setModuleEnable("TotemWorship", ClientConst.ModuleKey.Quest, false)
end

function TotemWorshipCtrl:onHide()
	pg.game:setModuleEnable("TotemWorship", ClientConst.ModuleKey.OperationHint, true)
	pg.game:setModuleEnable("TotemWorship", ClientConst.ModuleKey.Quest, true)
end

function TotemWorshipCtrl:levelUpSubmit()
	if self.openTime > Time.realSecondCache - 1 then
		return
	end

	local playerTotemInfo = self:getPlayerTotemInfo()

	if playerTotemInfo.isMaxLevel then
		return
	end

	local totemUpgradeInfo = self:getNextLevelUpgradeInfo(playerTotemInfo.level)

	if not totemUpgradeInfo.count then
		return
	end

	local remainCount = totemUpgradeInfo.count - playerTotemInfo.exp

	pg.me:serverMsg("RPC_CS_AddTotemRunes", self.totemId, remainCount)
end

function TotemWorshipCtrl:submitAll()
	if self.openTime > Time.realSecondCache - 1 then
		return
	end

	local playerTotemInfo = self:getPlayerTotemInfo()

	if playerTotemInfo.isMaxLevel then
		return
	end

	local totemUpgradeInfo = self:getNextLevelUpgradeInfo(playerTotemInfo.level)
	local requireItemId = totemUpgradeInfo.itemId
	local itemCount = ClientUtils.getItemCountById(requireItemId)

	if itemCount > 0 then
		pg.me:serverMsg("RPC_CS_AddTotemRunes", self.totemId, itemCount)
	end
end

function TotemWorshipCtrl:refreshInfo()
	local totemUpgradeData = TotemUpgradeData[self.totemId]

	if not totemUpgradeData then
		return
	end

	local playerTotemInfo = self:getPlayerTotemInfo()

	if playerTotemInfo.isMaxLevel then
		self.view.widget:TryChangePage("State", 1)
		self:refreshFullLevelInfo(playerTotemInfo.level)
	else
		self.view.widget:TryChangePage("State", 0)
		self:refreshSubmitItemInfo(playerTotemInfo.level, playerTotemInfo.exp)
		self:refreshRewardList(playerTotemInfo.level, playerTotemInfo.exp)
		self:refreshLevelInfo(playerTotemInfo.level, playerTotemInfo.exp)
	end
end

function TotemWorshipCtrl:getPlayerTotemInfo()
	local playerTotemInfo = pg.me.totemMap[self.totemId]

	playerTotemInfo = playerTotemInfo or {
		exp = 0,
		level = 0
	}

	return playerTotemInfo
end

function TotemWorshipCtrl:refreshSubmitItemInfo(level, exp)
	local totemUpgradeInfo = self:getNextLevelUpgradeInfo(level)
	local requireItemId = totemUpgradeInfo.itemId
	local itemCount = ClientUtils.getItemCountById(requireItemId)
	local remainCount = totemUpgradeInfo.count - exp
	local consumeText = self.view.itemConsume:Find("Num"):GetComponent("USDFText")
	local consumeTitle = self.view.itemConsume:Find("Text"):GetComponent("USDFText")
	local objectReference = self.view.submitBtn2:GetComponent("ObjectReference")
	local submitTitle = objectReference:GetRefValue("txtNameUText")

	if itemCount <= 0 then
		ClientTextUtils.setText(consumeText, "")
		ClientTextUtils.setText(consumeTitle, ClientTextUtils.getGameString("REQUIRE_LABEL"))
		ClientTextUtils.setText(submitTitle, ClientTextUtils.getGameString("TOTEM_FIND_MORE"))

		self.view.submitBtn2.interactable = false
	else
		ClientTextUtils.setText(consumeTitle, ClientTextUtils.getGameString("CONSUME_LABEL"))
		ClientTextUtils.setText(submitTitle, ClientTextUtils.getGameString("TOTEM_SUBMIT"))
		ClientTextUtils.setText(consumeText, itemCount, "/", math.min(itemCount, remainCount))

		self.view.submitBtn2.interactable = true
	end

	local itemIcon = self.view.itemConsume:Find("Button/Bg"):GetComponent("UImage")
	local itemButton = self.view.itemConsume:Find("Button"):GetComponent("UButton")

	function itemButton.luaPress()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

			return
		end

		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			num = 1,
			id = requireItemId,
			targetRect = itemButton
		})
	end

	itemIcon.url = LuaUIUtils.getIconByItemId(requireItemId)

	if remainCount <= itemCount then
		self.view.submitBtn1:SetActive(true)
		self.view.submitBtn2:SetActive(false)
	else
		self.view.submitBtn1:SetActive(false)
		self.view.submitBtn2:SetActive(true)
	end
end

function TotemWorshipCtrl:setRewardItemData(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local itemNameUText = objectReference:GetRefValue("itemNameUText")

	itemNameUText:SetActive(true)

	if data.rewardType == TotemRewardType.Item then
		LuaUIUtils.renderRewardItem(button, data)
	elseif data.rewardType == TotemRewardType.Ability then
		LuaUIUtils.renderRewardAbility(button, data)
	end
end

function TotemWorshipCtrl:refreshRewardList(level, exp)
	local totemUpgradeInfo = self:getNextLevelUpgradeInfo(level)
	local listData = {}

	if totemUpgradeInfo.abilityIcon then
		local abilityInfo = {}

		abilityInfo.rewardType = TotemRewardType.Ability
		abilityInfo.name = totemUpgradeInfo.abilityDesc1
		abilityInfo.num = totemUpgradeInfo.abilityDesc1
		abilityInfo.abilityVirtualItemId = totemUpgradeInfo.abilityVirtualItemId
		abilityInfo.desc = totemUpgradeInfo.abilityDesc2
		abilityInfo.icon = totemUpgradeInfo.abilityIcon
		abilityInfo.tIndex = 1
		listData[#listData + 1] = abilityInfo
	end

	local rewardId = totemUpgradeInfo.reward
	local rewardItems = LuaUIUtils.getRewardItemByDropId(rewardId)

	for _, rewardItemInfo in ipairs(rewardItems) do
		rewardItemInfo.rewardType = TotemRewardType.Item
		rewardItemInfo.tIndex = 0
		listData[#listData + 1] = rewardItemInfo
	end

	self.view.rewardList:SetList(listData)
end

function TotemWorshipCtrl:getNextLevelUpgradeInfo(curLevel)
	local totemUpgradeData = TotemUpgradeData[self.totemId]

	return totemUpgradeData[curLevel + 1] or {}
end

function TotemWorshipCtrl:refreshLevelInfo(level, exp)
	local totemUpgradeInfo = self:getNextLevelUpgradeInfo(level)

	ClientTextUtils.setText(self.view.levelNum, level)

	local valueText = self.view.progressGroup:Find("ValueText"):GetComponent("USDFText")

	ClientTextUtils.setText(valueText, exp, "/", totemUpgradeInfo.count)

	local progress = self.view.progressGroup:Find("Progress1"):GetComponent("UProgress")

	progress.maxValue = 1
	progress.value = exp / totemUpgradeInfo.count
end

function TotemWorshipCtrl:refreshFullLevelInfo(level)
	ClientTextUtils.setText(self.view.levelNum, level)
	ClientTextUtils.setText(self.view.fullLevelNum, level)
	ClientTextUtils.setText(self.view.fullLevelNum2, level)
end

function TotemWorshipCtrl:onAddTotemExp(data)
	if not self.view then
		return
	end

	local totemId, levelBefore, expBefore, isMaxLevelBefore, level, exp, isMaxLevel = unpack(data)

	if totemId ~= self.totemId then
		return
	end

	if self.openTime > Time.realSecondCache - 1 then
		self:refreshInfo()

		return
	end

	if not isMaxLevel then
		self:refreshSubmitItemInfo(level, exp)
		self:refreshRewardList(levelBefore, expBefore)
		self:refreshLevelInfo(levelBefore, expBefore)
	else
		self:refreshFullLevelInfo(level)
	end

	local progress = self.view.progressGroup:Find("Progress1"):GetComponent("UProgress")

	self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.User1)

	if levelBefore ~= level or isMaxLevelBefore ~= isMaxLevel or isMaxLevel then
		self:playTotemCutscene(true)
	else
		self:playTotemCutscene(false)

		local totemUpgradeInfo = self:getNextLevelUpgradeInfo(level)
		local targetProgress = exp / totemUpgradeInfo.count

		progress:ProgressToValue(targetProgress, function()
			self:refreshInfo()
		end, 0.5, 0, CS.DG.Tweening.Ease.OutCubic)
	end
end

function TotemWorshipCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_TIPS] = true

	return whiteList
end

function TotemWorshipCtrl:getRefNpc()
	if self.uiContext then
		local npcGlobalId = self.uiContext and self.uiContext.npcGlobalId

		if npcGlobalId then
			return pg.getEntityByGlobalId(npcGlobalId)
		end
	end

	return nil
end

function TotemWorshipCtrl:setTotemCamera()
	local refNpc = self:getRefNpc()

	if refNpc then
		local cameraPos = refNpc:getPosition() + refNpc:getRotation() * Vector3(4.45, 4.73, 12.23)
		local cameraRot = refNpc:getRotation() * Quaternion.Euler(1, -147, 0)

		pg.game.camera:cameraBlendToFixed(cameraPos, cameraRot, CameraConst.DefaultFOV, 0.5)
	end
end

function TotemWorshipCtrl:resetTotemCamera()
	pg.game.camera:cancelBlendToFixed(0.5)
end

function TotemWorshipCtrl:destroyAllCutscenes()
	if self.cutsceneItem then
		self.cutsceneItem:destroy()

		self.cutsceneItem = nil
	end
end

function TotemWorshipCtrl:playTotemCutscene(isUpgrade)
	if self.cutsceneItem then
		return
	end

	local refNpc = self:getRefNpc()

	if not isUpgrade then
		if refNpc then
			refNpc:playEffect("Eff_LVIOT_Build_FlowerVillage_TotemPoles_001_Activated")
		end

		pg.game.audio:playEvent("SFX_UI_Experience")
	elseif refNpc then
		local whiteList = {}

		whiteList[UIConst.UI_ID_TOTEM_WORSHIP] = true

		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.TOTEM_WORSHIP, whiteList, 10)

		local cutsceneItem = pg.game.cutscene:createCutscene("toteWorshipUpgrade", AddressDataConst.TOTEM_WORSHIP_TIMELINE, refNpc:getPosition(), refNpc:getRotation(), {
			applySoundListener = false
		})

		cutsceneItem:preload()
		self.view.widget:TryChangePage("State", 2)

		self.view.widgetRoot.visibility = CS.XGUI.EVisibility.HitTestInvisible

		if refNpc.TotemWorshipFeature then
			refNpc.TotemWorshipFeature.isInCutscene = true
		end

		cutsceneItem:play(function()
			self.cutsceneItem = nil

			cutsceneItem:destroy()
			pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.TOTEM_WORSHIP)

			if refNpc.TotemWorshipFeature then
				refNpc.TotemWorshipFeature.isInCutscene = false

				refNpc.TotemWorshipFeature:refreshTotemEffect()
			end

			self:startTimer(function()
				self.view.widgetRoot.visibility = CS.XGUI.EVisibility.Visible

				self:refreshInfo()

				local playerTotemInfo = self:getPlayerTotemInfo()

				if playerTotemInfo.isMaxLevel then
					pg.game.audio:playEvent("SFX_UI_FullLevel")
				end
			end, 1)
		end)

		self.cutsceneItem = cutsceneItem
	else
		self:refreshInfo()
	end
end

return TotemWorshipCtrl
