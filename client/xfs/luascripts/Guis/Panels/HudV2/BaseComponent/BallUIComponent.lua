-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\BallUIComponent.lua

local ClientUtils = require("Utils.ClientUtils")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Lume = require("Core.Common.lume")
local GmToolUtils = require("Utils.GmToolUtils")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local Class = require("Core.Framework.Class")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local MessageName = require("Const.MessageName")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local Utils = require("Common.Utils.Utils")
local SceneData = require("Data.scene_data")
local Const = require("Core.Common.Const")
local BallUIComponent = Class.LightClass("BallUIComponent", HudBaseComponent)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local NORMAL_CATCH_KEY = "Catch/SwitchCatchMode"
local PERFORMED_CATCH_KEY = "Catch/SwitchCatchBall"

BallUIComponent.messages = {
	[MessageName.CATCH_MODE_CHANGE_UI] = {
		"onCatchModeChange",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"refreshInfo",
		true
	},
	[MessageName.ON_NOTIFY_ITEM] = {
		"refreshInfo",
		true
	},
	[MessageName.ON_BACKPACK_QUICK_BALL_CHANGE] = {
		"onQuickBallChange",
		true
	},
	[MessageName.MODULE_ENABLE_CHANGED] = {
		"onModuleEnableChanged",
		true
	},
	[MessageName.INTERACT_GESTURE_STATE_CHANGE] = {
		"onInteractGestureStateChanged",
		true
	},
	[MessageName.CHARACTER_STATE_CHANGED] = {
		"onCharacterStateChanged",
		true
	},
	[MessageName.ON_PLAYER_START_RIFT] = {
		"refreshBallVisible",
		true
	},
	[MessageName.ON_PLAYER_END_RIFT] = {
		"refreshBallVisible",
		true
	},
	[MessageName.APP_FOCUS_CHANGED] = {
		"onAppFocusChanged",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function BallUIComponent:onCtor(info)
	self.curSelectCastItem = nil
	self.isOpen = false
	self.openMap = {}
end

function BallUIComponent:_isInCaptureMode()
	return pg.me and pg.me.isInCatchMode and pg.me:isInCatchMode()
end

function BallUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.loopList = objectReference:GetRefValue("loopList")
	self.btnProp = objectReference:GetRefValue("btnPropUButton")
	self.iconCur = objectReference:GetRefValue("iconUImage")
	self.curBallUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.txtNumCur = objectReference:GetRefValue("textUSDFText")
	self.arrowLeft = objectReference:GetRefValue("arrowRightUImage")
	self.arrowRight = objectReference:GetRefValue("arrowLeftUImage")
	self.keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
end

function BallUIComponent:initView()
	self:refreshInfo()

	function self.loopList.luaRenderItem(button, index, data)
		self:setListItemNodeData(button, index, data)
	end

	self.keyHotKeyContent:SetHotKeyPaths(NORMAL_CATCH_KEY)

	self.keyBindOpen = KeyBindingPro.GetOrAddKeyBindingByName(self.transform.gameObject, "BallSwitch")
	self.keyBindOpen.isVirtual = true
	self.keyBindOpen.actionPath = "Hud/BallSwitch"

	function self.keyBindOpen.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if not self.isOpen or pg.me:isInBossCatch() then
				return true
			end

			local deltaZoom = inputInfo.valueVec2.y

			pg.game.audio:triggerEvent("SFX_UI_HUD_ItemMenu_Choose")

			local itemList = self:getItemList()

			if not itemList or #itemList == 1 then
				self.btnProp:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			elseif deltaZoom > 0 then
				self:switchPreItem()
			else
				self:switchNextItem()
			end
		end
	end

	self.ballMenuKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(self.transform.gameObject, "ItemMenu")
	self.ballMenuKeyBind.isVirtual = true
	self.ballMenuKeyBind.actionPath = "Hud/BallMenu"

	function self.ballMenuKeyBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local itemList = self:getItemList()

			if not itemList or #itemList == 0 then
				self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.User2)

				return
			end

			self:switchOpen(true, "ctrShortCut")
		else
			self:switchOpen(false, "ctrShortCut")
		end
	end

	self:refreshNormalPlatformInfo()
end

function BallUIComponent:handleSwitchCatchModeAction(enable)
	if pg.me == nil or pg.me.space == nil then
		return
	end

	local controller = pg.game.controller

	if controller == nil then
		return
	end

	if pg.me.space:isRogueEnv() then
		return
	end

	if enable == nil then
		return controller:onHandleSwitchCatchMode()
	end

	self:onCatchModeChangeGamePad(enable)

	return controller:onHandleSwitchCatchMode(enable)
end

function BallUIComponent:onCatchModeChange(enable)
	if not pg.game.controller:isInControlMainPlayer() or GmToolUtils and GmToolUtils.captureProbabilityHide then
		return
	end

	if enable then
		pg.game.audio:triggerEvent("ui_sfx_button")

		if not pg.me:isThrowItem() then
			pg.global.ui.captureBall:openOrShow()
		end
	else
		self:switchOpen(false, "ctrShortCut")
		self:switchOpen(false, "captureMode")
	end

	self:onCatchModeChangeGamePad(enable)
	pg.global.ui.interact:onCatchModeChange()
end

function BallUIComponent:onCatchModeChangeGamePad(enable)
	if pg.me and pg.me.isInFishingCapture and pg.me:isInFishingCapture() then
		return
	end

	if pg.game.input:isUsingGamepad() and pg.me:checkEnterCatchMode(false) then
		if not ClientCaptureUtils.hasBall(false) then
			return
		end

		if Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
			local itemId = pg.global.ui.hudV2:getCurSelectPropId()

			if not itemId or not pg.me.catchRogueInfo:canFireBall(pg.me, itemId) then
				return
			end
		end

		self:switchOpen(enable, "captureMode")
	end
end

function BallUIComponent:refreshItemList()
	local propList = self.model:getCapturePropInfos()

	self.curItemList = {}

	table.mergeList(self.curItemList, propList)

	if #propList == 0 then
		self.curSelectCastItem = nil
	end

	self.loopList:SetList(self.curItemList)

	if not self:checkCurItemValid() then
		local itemIdx = self:_getDefaultIndex()

		self:selectItem(itemIdx)
	else
		self:refreshSelectItemData()
	end

	self:refreshLocalSelectData()
end

function BallUIComponent:_getDefaultIndex()
	return 1
end

function BallUIComponent:getItemList()
	return self.curItemList
end

function BallUIComponent:getSelectItem()
	return self.curSelectCastItem
end

function BallUIComponent:checkItemIndexValid(itemIndex)
	return itemIndex > 0 and itemIndex <= #self.curItemList
end

function BallUIComponent:selectItem(itemIndex)
	if self:_isInCaptureMode() then
		return 0
	end

	self:resetItemAndArrowPos(itemIndex)

	itemIndex = math.clamp(itemIndex, 1, #self.curItemList)

	if self:realSelectItem(itemIndex) then
		return itemIndex
	end

	return 0
end

function BallUIComponent:getCurIndex()
	for itemIndex = 1, #self.curItemList do
		local ballItem = self.curItemList[itemIndex]

		if self.curSelectCastItem and self.curSelectCastItem.itemId == ballItem.itemId then
			return itemIndex
		end
	end

	return 0
end

function BallUIComponent:realSelectItem(itemIndex)
	itemIndex = math.clamp(itemIndex, 1, #self.curItemList)

	local newCastItem = self.curItemList[itemIndex]

	if newCastItem and self.curSelectCastItem and newCastItem.itemId == self.curSelectCastItem.itemId then
		return false
	end

	if newCastItem == nil and self.curSelectCastItem == nil then
		return false
	end

	self.curSelectCastItem = newCastItem

	self:refreshSelectItemData()
	pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.CatchSelectItemId, newCastItem.itemId)

	if self.curSelectCastItem == nil or self.curSelectCastItem.itemId == nil then
		return false
	end

	if pg.game.controller.onHandleSwitchProp then
		pg.game.controller:onHandleSwitchProp()
	end

	return true
end

function BallUIComponent:refreshNormalPlatformInfo()
	self:refreshLocalSelectData()
	self:refreshSelectItemData()

	if not self:checkCurItemValid() then
		self:selectItem(1)
	else
		self:refreshSelectItemData()
	end
end

function BallUIComponent:refreshLocalSelectData()
	local selectItemId = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.CatchSelectItemId, nil)
	local propList = self.model:getCapturePropInfos()

	for index, data in ipairs(propList) do
		if data.itemId == selectItemId then
			self.curSelectCastItem = data

			break
		end
	end
end

function BallUIComponent:refreshSelectItemData(itemInfo)
	if itemInfo then
		self.curSelectCastItem = itemInfo
	end

	self:setItemNodeData(self.curSelectCastItem)
end

function BallUIComponent:syncSelectedItem(itemInfo)
	self.curSelectCastItem = itemInfo

	self:setItemNodeData(self.curSelectCastItem)
end

function BallUIComponent:getUIVisible()
	if ClientUtils.isInDouYinOfflineScene() then
		return true
	end

	if not pg.space or not pg.me then
		return false
	end

	if pg.me.isInFishingCapture and pg.me:isInFishingCapture() then
		return false
	end

	if pg.space:isHomeCamp() or pg.space:isRogueEnv() or pg.space:isNpcDuel() or pg.space:isBossRushEnv() then
		return false
	end

	local sceneData = SceneData[pg.me.space.sceneId]

	if sceneData and sceneData.forbiddenCatch == 1 then
		return false
	end

	if pg.me:checkArkSceneState() then
		return false
	end

	if pg.me.forceControl then
		return false
	end

	if CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.SWIMMING) then
		return false
	end

	if not pg.me:isInCombat() and CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.FLYING) then
		return false
	end

	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.BallAndItem) then
		return false
	end

	if pg.global.ui.hudV2 and pg.global.ui.hudV2.RD and pg.global.ui.hudV2.RD.interactGesture and pg.global.ui.hudV2.RD.interactGesture.transform then
		return false
	end

	if pg.game.social.interactGestureComponent:checkInteractGesturePlaying() then
		return false
	end

	return true
end

function BallUIComponent:checkCurItemValid()
	if self.curSelectCastItem and self.curSelectCastItem.itemId then
		local itemId = self.curSelectCastItem.itemId
		local count = ClientUtils.getItemCountById(itemId)

		if count <= 0 then
			return false
		end

		local itemList = self.model:getCapturePropInfos()

		for _, itemInfo in ipairs(itemList) do
			if itemInfo.itemId == itemId then
				return true
			end
		end
	end

	return false
end

function BallUIComponent:getCurSelectPropId()
	if self:_isInCaptureMode() then
		local captureBallCtrl = pg.global.ui.captureBall

		if captureBallCtrl and captureBallCtrl.getCurSelectPropId then
			return captureBallCtrl:getCurSelectPropId()
		end
	end

	if self.curSelectCastItem then
		return self.curSelectCastItem.itemId
	end

	return nil
end

function BallUIComponent:refreshThrowItemInfo(itemId)
	if self.throwItemComponent == nil then
		return
	end

	self.throwItemComponent:refreshItemView(itemId)
end

function BallUIComponent:refreshInfo()
	if self:_isInCaptureMode() then
		return
	end

	self:refreshItemList()
	self:refreshOpenState()
	self:refreshSelectItemData()
	self:refreshUIVisible()
end

function BallUIComponent:onModuleEnableChanged(changeInfo)
	local moduleKey = changeInfo.moduleKey or ""

	if moduleKey == ClientConst.ModuleKey.BallAndItem then
		self:refreshUIVisible()
	end
end

function BallUIComponent:refreshUIVisible()
	if not self.uWidget then
		return
	end

	local uiVisible = self:getUIVisible()

	if not uiVisible and self.isOpen then
		self:switchOpen(false, "ctrShortCut")
		self:switchOpen(false, "captureMode")
	end

	LuaUIUtils.setUIVisible(self.uWidget, uiVisible)

	local ballVisible = self:isBallVisible()

	self.ctrl.uWidget:TryChangePage("LocState", uiVisible and ballVisible and 0 or 1)

	local curIndex = self:getCurIndex()
	local itemList = self:getItemList()

	if #itemList == 1 then
		LuaUIUtils.setUIVisible(self.arrowLeft, false)
		LuaUIUtils.setUIVisible(self.arrowRight, false)

		return
	end

	if curIndex == 1 then
		LuaUIUtils.setUIVisible(self.arrowLeft, true)
		LuaUIUtils.setUIVisible(self.arrowRight, false)
	elseif curIndex == #itemList then
		LuaUIUtils.setUIVisible(self.arrowLeft, false)
		LuaUIUtils.setUIVisible(self.arrowRight, true)
	else
		LuaUIUtils.setUIVisible(self.arrowLeft, true)
		LuaUIUtils.setUIVisible(self.arrowRight, true)
	end
end

function BallUIComponent:switchOpen(isOpen, mode)
	self.openMap[mode] = isOpen

	local open = false

	for _, v in pairs(self.openMap) do
		open = open or v
	end

	if self.isOpen ~= open then
		self.isOpen = open

		self:refreshOpenState()
	end

	pg.game:setModuleEnable("CATCH_BALL", ClientConst.ModuleKey.Chat, not open)
	self.keyHotKeyContent:SetHotKeyPaths(open and PERFORMED_CATCH_KEY or NORMAL_CATCH_KEY)

	if open then
		pg.game.audio:triggerEvent("SFX_UI_HUD_ItemMenu_Open")
	end
end

function BallUIComponent:refreshOpenState()
	self.ctrl.uWidget:TryChangePage("OpenBall", self.isOpen and 1 or 0)
	self:refreshListSelectState(true)
end

function BallUIComponent:refreshListSelectState(showSelect)
	local curIndex = self:getCurIndex()

	self:resetItemAndArrowPos(curIndex)
end

function BallUIComponent:resetItemAndArrowPos(index)
	if index <= 0 then
		return
	end

	local realIndex = index - 1

	self.loopList:GoToIndexMinCost(realIndex)
end

function BallUIComponent:_findNextEnabledIndex(fromIndex, dir)
	local n = #self.curItemList
	local i = fromIndex + dir

	while i >= 1 and i <= n do
		local item = self.curItemList[i]

		if item and item.itemId and ClientUtils.getItemCountById(item.itemId) > 0 then
			return i
		end

		i = i + dir
	end

	return 0
end

function BallUIComponent:switchPreItem()
	if self.isOpen then
		local curIndex = self:getCurIndex()
		local target = self:_findNextEnabledIndex(curIndex, -1)

		if target <= 0 then
			self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)

			return
		end

		self:selectItem(target)
	end
end

function BallUIComponent:switchNextItem()
	if self.isOpen then
		local curIndex = self:getCurIndex()
		local target = self:_findNextEnabledIndex(curIndex, 1)

		if target <= 0 then
			self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)

			return
		end

		self:selectItem(target)
	end
end

function BallUIComponent:setListItemNodeData(itemNode, index, itemInfo)
	local orc = itemNode:GetComponent("ObjectReference")
	local itemIcon = orc:GetRefValue("itemIcon")
	local iNumb = orc:GetRefValue("num")
	local exclusiveUWidget = orc:GetRefValue("exclusiveUWidget")

	if itemInfo.empty then
		itemNode:TryChangePage("PC_NULL", 1)

		return
	end

	itemNode:TryChangePage("PC_NULL", 0)

	if itemInfo and itemInfo.itemId then
		itemIcon.url = LuaUIUtils.getIconByItemId(itemInfo.itemId)

		local count = ClientUtils.getItemCountById(itemInfo.itemId)

		ClientTextUtils.setText(iNumb, count)

		if Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
			local curGameId = pg.me:getCatchRogueCurGameId()
			local gameBallItemIds = curGameId and CatchRoguePhaseData[curGameId].gameBallType

			if gameBallItemIds and table.contains(gameBallItemIds, itemInfo.itemId) then
				exclusiveUWidget:SetActive(true)
			else
				exclusiveUWidget:SetActive(false)
			end
		else
			exclusiveUWidget:SetActive(false)
		end

		function itemNode.luaClick()
			if self.isOpen then
				local curIndex = index + 1

				self:selectItem(curIndex)
			end
		end
	else
		itemNode.luaClick = nil
	end
end

function BallUIComponent:setItemNodeData(itemInfo)
	if not itemInfo then
		self.btnProp:TryChangePage("NullBall", 1)
		ClientTextUtils.setText(self.curBallUSDFText, 0)
		ClientTextUtils.setText(self.txtNumCur, "")

		return
	end

	self.btnProp:TryChangePage("NullBall", 0)

	self.iconCur.url = LuaUIUtils.getIconByItemId(itemInfo.itemId)

	ClientTextUtils.setText(self.curBallUSDFText, ClientUtils.getItemCountById(itemInfo.itemId))
	ClientTextUtils.setText(self.txtNumCur, pg.getLocalizationText(itemInfo.name))
end

function BallUIComponent:onQuickBallChange()
	if self:_isInCaptureMode() then
		return
	end

	self:refreshInfo()

	if not self:checkCurItemValid() then
		self:selectItem(1)
	end
end

function BallUIComponent:onInteractGestureStateChanged()
	self:refreshUIVisible()
end

function BallUIComponent:onCharacterStateChanged()
	self:refreshUIVisible()
end

function BallUIComponent:refreshBallVisible()
	if IsNil(self.uWidget) then
		return
	end

	local visible = self:isBallVisible()

	self.ctrl.uWidget:TryChangePage("LocState", visible and 0 or 1)
end

function BallUIComponent:isBallVisible()
	local visible = true

	if pg.me and pg.me.isInRiftMode and pg.me:isInRiftMode() then
		visible = false
	end

	return visible
end

function BallUIComponent:onInputDeviceChanged(deviceType)
	self:switchOpen(false, "ctrShortCut")
end

function BallUIComponent:onAppFocusChanged(focus)
	if not focus then
		self:switchOpen(false, "ctrShortCut")
	end
end

return BallUIComponent
