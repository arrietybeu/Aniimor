-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\InteractGestureUIComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local InteractGestureUIComponent = Class.LightClass("InteractGestureUIComponent", HudBaseComponent)
local SysConfigData = require("Data.sys_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local MessageName = require("Const.MessageName")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local NoticeDef = require("Common.NoticeDef")
local ItemData = require("Data.item_data")
local ItemSourceData = require("Data.item_source_data")
local HomeObjectData = require("Data.home_object_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AddressDataConst = require("Const.AddressDataConst")
local HandheldAppearanceUtils = require("Utils.HandheldAppearanceUtils")

InteractGestureUIComponent.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.GESTURE_TARGET_CHANGE] = {
		"onGestureTargetChanged",
		true
	},
	[MessageName.INTERACT_GESTURE_UNLOCK_CHANGED] = {
		"onInteractGestureUnlockChanged",
		true
	},
	[MessageName.APPEARANCE_CUR_SUIT_ID_CHANGED] = {
		"onInteractGestureUnlockChanged",
		true
	}
}
InteractGestureUIComponent.petIcon = "$UI_HUD_Entry_Manage.png"
InteractGestureUIComponent.GestureMaxNumber = 7
InteractGestureUIComponent.AppearanceGestureMaxNumber = 6
InteractGestureUIComponent.BlockedActions = {
	"Skill/LockTarget",
	"Catch/SwitchCatchMode"
}

function InteractGestureUIComponent:getGestureMaxNumber()
	return self.curInteractAction == Const.APPEARANCE_ACTION_TYPE.Appearance and InteractGestureUIComponent.AppearanceGestureMaxNumber or InteractGestureUIComponent.GestureMaxNumber
end

function InteractGestureUIComponent:onRootNodeLoaded(trans)
	if self.closeAfterLoad or not pg.me or pg.me:isInCatchMode() then
		self.closeAfterLoad = nil
		self._resLoading = false
		self.pendingOpenEmoticonInfo = nil

		self.view:destroyInstance(trans.gameObject)

		return
	end

	HudBaseComponent.onRootNodeLoaded(self, trans)
end

function InteractGestureUIComponent:closeForCatchMode()
	if self._resLoading then
		self.closeAfterLoad = true
	end

	self.pendingOpenEmoticonInfo = nil

	if self.transform or self.inputActionsBlocked or self.restoreOtherHudBaseFrameId then
		self:closeEmoticonPanel(nil, true)
	end
end

function InteractGestureUIComponent:prepareOpenEmoticonPanel(info)
	if self.closeAfterLoad then
		self.closeAfterLoad = nil
		self._resLoading = true
	end

	self.pendingOpenEmoticonInfo = info
end

function InteractGestureUIComponent:setBlockedActionsEnabled(enabled)
	local inputMgr = pg.global and pg.global.inputMgr

	if not inputMgr then
		return
	end

	for _, action in ipairs(InteractGestureUIComponent.BlockedActions) do
		inputMgr:SetInputActionEnabled(action, enabled, HotkeyConst.INPUT_BLOCK_FLAG.InteractGesture)
	end

	self.inputActionsBlocked = not enabled
end

function InteractGestureUIComponent:setOtherHudBaseVisible(visible)
	local hud = pg.global.ui.hudV2

	if not hud then
		return
	end

	local reason = self.compName or HudSplicingCfg.componentName.interactGesture
	local fnName = visible and "showBaseComponent" or "hideBaseComponent"

	if not hud[fnName] then
		return
	end

	hud[fnName](hud, HudSplicingCfg.LayoutName.RM, nil, reason)
	hud[fnName](hud, HudSplicingCfg.LayoutName.MD, nil, reason)
	self:setBlockedActionsEnabled(visible)
	pg.global.ui.tips:refreshShortCutKey()

	if hud.LD then
		if pg.global.ui:runPlatformByMobile() then
			if hud.LD.btnPetModeUContainer then
				hud.LD.btnPetModeUContainer.gameObject:SetActiveEx(visible)
			end
		elseif hud.LD.ball then
			hud.LD.ball:refreshUIVisible()
		end
	end
end

function InteractGestureUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.scrollHotKeyContent = objectReference:GetRefValue("scrollHotKeyContent")
	self.scrollTextUSDFText = objectReference:GetRefValue("scrollTextUSDFText")
	self.tipNameUSDFText = objectReference:GetRefValue("tipNameUSDFText")
	self.tipDescTextPlus = objectReference:GetRefValue("tipDescTextPlus")
	self.tipGoUButton = objectReference:GetRefValue("tipGoUButton")
	self.tipGoUSDFText = objectReference:GetRefValue("tipGoUSDFText")
	self.tipGoHotKeyContent = objectReference:GetRefValue("tipGoHotKeyContent")
	self.tipUComponent = objectReference:GetRefValue("tipUComponent")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.keyLeftHotKeyContent = objectReference:GetRefValue("keyLeftHotKeyContent")
	self.keyRightHotKeyContent = objectReference:GetRefValue("keyRightHotKeyContent")
	self.btnRefreshUButton = objectReference:GetRefValue("btnRefreshUButton")
	self.imageSuitUImage = objectReference:GetRefValue("imageSuitUImage")
	self.textSuitUSDFText = objectReference:GetRefValue("textSuitUSDFText")
	self.btnSuitSpecialUButton = objectReference:GetRefValue("btnSuitSpecialUButton")
	self.textSuitEmptyUSDFText = objectReference:GetRefValue("textSuitEmptyUSDFText")
	self.listPoseUList = objectReference:GetRefValue("listPoseUList")
	self.vXWidgetUWidget = objectReference:GetRefValue("vXWidgetUWidget")
end

function InteractGestureUIComponent:initView()
	self:bindHotKeyPerform("Hud/OpenEmotion", function()
		self:closeEmoticonPanel()
	end, self.gameObject, "Hud/OpenEmotion")
	self:bindHotKeyPerform("Common/ClosePanelCommon", function()
		self:closeEmoticonPanel()
	end, self.gameObject, "Common/ClosePanelCommon")

	local scrollBind = self:bindHotKeyPerform("Hud/InteractScroll", function(_, inputInfo)
		local delta = inputInfo.valueVec2.y > 0 and -1 or 1

		self:handleSwitchGesturePage(delta)
	end, self.gameObject, "Hud/InteractScroll")

	scrollBind.priority = 60000

	function self.btnCloseUButton.luaClick()
		self:closeEmoticonPanel()
	end

	self.scrollHotKeyContent.useRawBindingPath = true

	self.scrollHotKeyContent:SetHotKeyPaths("Hud/InteractScroll")

	function self.listUList.luaRenderItem(button, index, data)
		self:renderInteractGestureButton(button, index, data)
	end

	function self.listPoseUList.luaRenderItem(button, index, data)
		self:renderInteractGestureButton(button, index, data)
	end

	function self.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
		local imageIconUImage = objectReference:GetRefValue("imageIconUImage")

		ClientTextUtils.setText(txtNameUBaseText, data.label)
		button:TryChangePage("Icon", data.interactAction - 1)

		if data.interactAction == Const.APPEARANCE_ACTION_TYPE.Appearance then
			local quality = pg.game.social.interactGestureComponent:getAppearanceSuitActionQuality()

			if not AddressDataConst.AVATAR_APPEARANCE_SUIT_QUALITY_ICON[quality] then
				quality = 4
			end

			imageIconUImage.url = AddressDataConst.AVATAR_APPEARANCE_SUIT_QUALITY_ICON[quality]
		end

		pg.global.setPreViewRedDot(string.format(RedDotConst.RedDotPath.INTERACT_GESTURE_TAB_ITEM, data.interactAction), button, function()
			return pg.game.social.interactGestureComponent:hasNewInteractGesture(data.interactAction)
		end)
	end

	function self.listTabUList.luaSelectedChanged(ulist, isSelected)
		if not isSelected then
			return
		end

		self.curInteractAction = ulist.selectedItem.interactAction
		self.gestureDataOffset = 0

		self:refreshGestureDataList(self.gestureDataOffset)

		if ulist.selectedItem.interactAction == Const.APPEARANCE_ACTION_TYPE.Double then
			pg.game.social.interactGestureComponent:startSelectPlayer(self.curSelectedPlayerId)
		else
			self.friendshipLevel = 0
			self.curSelectedPlayerId = nil

			pg.game.social.interactGestureComponent:stopSelectPlayer()
		end

		self.vXWidgetUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end

	local consoleDetailBind = KeyBindingPro.GetOrAddKeyBindingByName(self.gameObject, "consoleDetailBind")

	consoleDetailBind.isVirtual = true
	consoleDetailBind.priority = 100000
	consoleDetailBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth

	function consoleDetailBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.tipUComponent.gameObject:SetActiveEx(true)
		end
	end

	function self.btnRefreshUButton.luaClick()
		return
	end

	ClientTextUtils.setText(self.textSuitEmptyUSDFText, pg.getGameString("CUR_SUIT_EMPTY"))
	self:openEmoticonPanel(self.pendingOpenEmoticonInfo)
end

function InteractGestureUIComponent:renderInteractGestureButton(button, index, data)
	if data.itemId and ItemData[data.itemId] then
		button:TryChangePage("Quality", ItemData[data.itemId].quality or 0)
	else
		button:TryChangePage("Quality", 0)
	end

	if data.isEmpty then
		button:TryChangePage("Empty", 1)
		button:TryChangePage("Icon", 0)

		button.interactable = false

		return
	else
		button:TryChangePage("Empty", 0)

		button.interactable = true
	end

	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
	local propsUImage = objectReference:GetRefValue("propsUImage")
	local costItemUImage = objectReference:GetRefValue("costItemUImage")
	local packUpUWidget = objectReference:GetRefValue("packUpUWidget")

	iconUImage.url = data.icon

	ClientTextUtils.setText(txtNameUSDFText, data.name)

	local gestureComponent = pg.game.social.interactGestureComponent
	local actionType = data.interactAction
	local isDoubleAction = actionType == Const.APPEARANCE_ACTION_TYPE.Double
	local isFurnitureAction = actionType == Const.APPEARANCE_ACTION_TYPE.Furniture
	local isVehicleAction = actionType == Const.APPEARANCE_ACTION_TYPE.Vehicle
	local isHomeObjectAction = isFurnitureAction or isVehicleAction
	local targetPlayerId = self.curSelectedPlayerId
	local costItemId = data.costItemId and data.costItemId[1]
	local costItemData = costItemId and ItemData[costItemId]
	local itemUrl = costItemData and costItemData.icon or data.pet and InteractGestureUIComponent.petIcon or ""

	propsUImage.gameObject:SetActiveEx(not string.isNilOrEmpty(itemUrl))

	costItemUImage.url = itemUrl

	if not gestureComponent:isActionUnlocked(data) then
		button:TryChangePage("Icon", 1)

		function button.luaClick()
			if isHomeObjectAction then
				pg.global.showBubbleMessageById(NoticeDef.HOME_ORNAMENT_UNLOCKED)
			elseif HandheldAppearanceUtils.isHandheldAction(data.index) then
				pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_ACTION_HANDHELD"))
			else
				pg.global.showBubbleMessageById(NoticeDef.INTERACT_ACTION_LOCKED)
			end
		end
	elseif not gestureComponent:isActionCostEnough(data) then
		button:TryChangePage("Icon", 2)

		function button.luaClick()
			pg.global.showBubbleMessageById(NoticeDef.ITEM_COUNT_LACK)
		end
	elseif isDoubleAction and not targetPlayerId then
		button:TryChangePage("Icon", 0)

		function button.luaClick()
			pg.global.showBubbleMessageRaw(pg.getGameString("ACTION_NO_TARGET_TOAST"))
		end
	elseif data.friendshipLevel and self.friendshipLevel < data.friendshipLevel then
		button:TryChangePage("Icon", 2)

		function button.luaClick()
			pg.global.showBubbleMessageById(NoticeDef.FRIEND_INTIMACY_NOT_ENOUGH)
		end
	elseif not gestureComponent:isFriendActionPermissionUnlocked(data, targetPlayerId) then
		button:TryChangePage("Icon", 2)

		function button.luaClick()
			pg.global.showBubbleMessageById(NoticeDef.INTERACT_ACTION_LOCKED)
		end
	else
		button:TryChangePage("Icon", 0)

		function button.luaClick()
			pg.pawn:dismountSelf()
			gestureComponent:handleActionPlayed(data)

			if not isHomeObjectAction then
				self:closeEmoticonPanel(true)
			end
		end
	end

	if data.homeTemplateId then
		local shouldRecycle = false

		if pg.me.placedHomeTemplateId and pg.me.placedHomeTemplateId == data.homeTemplateId then
			shouldRecycle = true
		end

		packUpUWidget.gameObject:SetActiveEx(shouldRecycle)
	else
		packUpUWidget.gameObject:SetActiveEx(false)
	end

	local actionPath = "Raw/KeyNum" .. index + 1
	local actionBind = self:bindHotKeyPerform(actionPath, function()
		button.luaClick()

		return false
	end, button.gameObject, actionPath)

	actionBind.priority = 60000

	keyHotKeyContent:SetHotKeyPaths(actionPath)

	function button.luaHover()
		data.itemId = data.itemId or data.homeTemplateId

		if not data.itemId or not ItemData[data.itemId] then
			return
		end

		ClientTextUtils.setText(self.tipNameUSDFText, pg.getLocalizationText(ItemData[data.itemId].itemName))
		ClientTextUtils.setText(self.tipDescTextPlus, pg.getLocalizationText(ItemData[data.itemId].itemDes))

		local sourceId = ItemData[data.itemId].source and ItemData[data.itemId].source[1]

		if sourceId then
			local sourceData = ItemSourceData[sourceId]

			ClientTextUtils.setText(self.tipGoUSDFText, pg.getLocalizationText(sourceData.buttonTxt))
			self.tipGoUButton.gameObject:SetActiveEx(true)
			self.tipGoUButton:TryChangePage("Gain", 0)
			self.tipGoHotKeyContent:SetHotKeyPaths("Hud/InteractGestureGo")

			function self.tipGoUButton.luaClick()
				LuaUIUtils.clueSeek(sourceData)
			end

			self:bindHotKeyPerform("Hud/InteractGestureGo", self.tipGoUButton.luaClick, self.tipGoUButton.gameObject, "Hud/InteractGestureGo")
		else
			self.tipGoUButton.gameObject:SetActiveEx(false)
		end

		self.tipUComponent.gameObject:SetActiveEx(not pg.game.input:isUsingGamepad())
	end

	function button.luaUnhover()
		self.tipUComponent.gameObject:SetActiveEx(false)
	end

	local isNew = pg.game.social.interactGestureComponent:isNewInteractGesture(data.index)

	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.INTERACT_GESTURE_ACTION_ITEM, data.index), button, isNew, RedDotConst.RedDotStyle.NEW)
end

function InteractGestureUIComponent:onInteractGestureUnlockChanged()
	if not self.gestureDatas then
		return
	end

	if self.listTabUList then
		self.listTabUList:RefreshList()
	end

	if self.listUList then
		self.listUList:RefreshList()
	end
end

function InteractGestureUIComponent:handleSwitchGesturePage(delta)
	self:refreshGestureDataList(self.gestureDataOffset + delta)
end

function InteractGestureUIComponent:refreshGestureDataList(offset)
	self:handleTabChanged()

	local ret = {}
	local hasGestureData = false
	local gestureDataGroup = self.gestureDatas[self.curInteractAction] and self.gestureDatas[self.curInteractAction].actions or {}
	local gestureMaxNumber = self:getGestureMaxNumber()

	if pg.global.ui:runPlatformByMobile() then
		self.listUList:SetList(gestureDataGroup)
	else
		for i = offset * gestureMaxNumber + 1, offset * gestureMaxNumber + gestureMaxNumber do
			if gestureDataGroup[i] then
				hasGestureData = true
				ret[#ret + 1] = gestureDataGroup[i]
			else
				ret[#ret + 1] = {
					isEmpty = true
				}
			end
		end

		if hasGestureData then
			self.listUList:SetList(ret)

			self.gestureDataOffset = offset

			ClientTextUtils.setText(self.scrollTextUSDFText, offset + 1)
		end
	end
end

function InteractGestureUIComponent:handleTabChanged()
	if self.curInteractAction ~= Const.APPEARANCE_ACTION_TYPE.Appearance then
		self.uWidget:TryChangePage("Module", 2)
		self.uWidget:TryChangePage("State", 0)
	else
		self.uWidget:TryChangePage("Module", 0)

		local suitId = self.suitId or 0
		local suitItem = ItemData[suitId] or {}
		local inSuit = suitId > 0 and AppearanceSuitData[suitId] and AppearanceSuitData[suitId].action and #AppearanceSuitData[suitId].action > 0

		self.imageSuitUImage.url = suitItem.icon or ""

		self.textSuitUSDFText.gameObject:SetActiveEx(suitItem.itemName ~= nil)

		if suitItem.itemName then
			ClientTextUtils.setText(self.textSuitUSDFText, pg.getLocalizationText(suitItem.itemName))
		end

		self.uWidget:TryChangePage("State", inSuit and 0 or 1)
	end
end

function InteractGestureUIComponent:openEmoticonPanel(info)
	info = info or self.pendingOpenEmoticonInfo
	self.pendingOpenEmoticonInfo = nil

	if self.restoreOtherHudBaseFrameId then
		self:killFrameTimer(self.restoreOtherHudBaseFrameId)

		self.restoreOtherHudBaseFrameId = nil
	end

	self:setOtherHudBaseVisible(false)

	self.gestureDatas = pg.game.social.interactGestureComponent:getGestureDatas()

	local targetPlayerId = info and info.playerId or nil

	self.curSelectedPlayerId = targetPlayerId
	self.friendshipLevel = targetPlayerId and pg.game.chat:getFriendship(targetPlayerId) or 0

	local tabDatas = {}
	local selectedIndex = 0
	local curSuitId = pg.me.curShow.suitId or 0

	if curSuitId > 0 and AppearanceSuitData[curSuitId] and AppearanceSuitData[curSuitId].action and #AppearanceSuitData[curSuitId].action > 0 then
		self.suitId = pg.me.curShow.suitId

		if self.suitId then
			info = info or {}
			info.interactAction = info.interactAction or Const.APPEARANCE_ACTION_TYPE.Appearance
		end
	end

	for idx, data in pairs(self.gestureDatas) do
		tabDatas[#tabDatas + 1] = {
			tIndex = 2,
			label = data.label,
			interactAction = idx
		}

		if info and info.interactAction == idx then
			selectedIndex = #tabDatas - 1
		end
	end

	if tabDatas and #tabDatas > 0 then
		tabDatas[1].tIndex = 0
		tabDatas[#tabDatas].tIndex = 1

		self.listTabUList:SetList(tabDatas)

		self.curSelectedPlayerId = targetPlayerId
		self.friendshipLevel = targetPlayerId and pg.game.chat:getFriendship(targetPlayerId) or 0

		self.listTabUList:SelectItem(selectedIndex)
		self:focusGestureAction(info and info.actionId, info and info.interactAction)
	end
end

function InteractGestureUIComponent:focusGestureAction(actionId, interactAction)
	if not actionId or not interactAction then
		return
	end

	local gestureDataGroup = self.gestureDatas[interactAction].actions

	for index, data in ipairs(gestureDataGroup) do
		if data.index == actionId then
			local listIndex = index - 1

			if not pg.global.ui:runPlatformByMobile() then
				local offset = math.floor(listIndex / self:getGestureMaxNumber())

				self:refreshGestureDataList(offset)

				listIndex = listIndex % self:getGestureMaxNumber()
			end

			self.listUList:SelectItem(listIndex, false)
			self.listUList:GoToIndex(listIndex, true)

			return
		end
	end
end

function InteractGestureUIComponent:closeEmoticonPanel(delayShowOtherHudBase, forceClose)
	if not forceClose and pg.game.input:isUsingGamepad() and self.transform and NotNil(self.tipUComponent.gameObject) and self.tipUComponent.gameObject.activeSelf then
		self.tipUComponent.gameObject:SetActiveEx(false)

		return
	end

	self:tryCloseComponent()

	if self.restoreOtherHudBaseFrameId then
		self:killFrameTimer(self.restoreOtherHudBaseFrameId)

		self.restoreOtherHudBaseFrameId = nil
	end

	if delayShowOtherHudBase then
		self.restoreOtherHudBaseFrameId = self:startFrameTimer(function()
			self.restoreOtherHudBaseFrameId = nil

			self:setOtherHudBaseVisible(true)
		end, 1)
	else
		self:setOtherHudBaseVisible(true)
	end

	self.curSelectedPlayerId = nil
	self.friendshipLevel = 0
	self.gestureDataOffset = nil
	self.gestureDatas = nil
	self.suitId = 0

	local interactGestureCacheKey = pg.me.uid .. pg.game.social.interactGestureComponent.InteractGestureCacheKey
	local curActions = {}

	for actionId, unlock in pairs(pg.me.actionShowIds or EMPTY_TABLE) do
		if unlock then
			curActions[#curActions + 1] = tostring(actionId)
		end
	end

	pg.global.prefsCacheUtils:setString(interactGestureCacheKey, table.concat(curActions, "|"))
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HUD_INTERACT_GESTURE)
	pg.game.social.interactGestureComponent:stopSelectPlayer()
end

function InteractGestureUIComponent:onGestureTargetChanged(info)
	local curSelectedPlayerId = info and info.playerId and info.playerId or nil

	self.curSelectedPlayerId = curSelectedPlayerId
	self.friendshipLevel = curSelectedPlayerId and pg.game.chat:getFriendship(curSelectedPlayerId) or 0

	self.listUList:RefreshList()
end

function InteractGestureUIComponent:onInputDeviceChanged()
	self.tipUComponent.gameObject:SetActiveEx(false)
end

function InteractGestureUIComponent:onDestroy()
	if self.restoreOtherHudBaseFrameId then
		self:killFrameTimer(self.restoreOtherHudBaseFrameId)

		self.restoreOtherHudBaseFrameId = nil
	end

	if self.inputActionsBlocked then
		self:setBlockedActionsEnabled(true)
	end

	HudBaseComponent.onDestroy(self)
end

return InteractGestureUIComponent
