-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CTipArea\\FriendOnLineItem.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local FriendOnLineItem = Class.LightClass("FriendOnLineItem", BaseQueueItem)
local DISPLAY_DURATION = 5
local EXIT_ANIMATION = CS.XGUI.EInvokeTime.Custom1
local CLOSE_ACTION_PATH = "Hud/ItemClose"
local PC_CHAT_ACTION_PATH = "Hud/OpenChat"

function FriendOnLineItem:onInit()
	self.uContainer = self.uWidget
	self.isContainerLoading = false
	self.isDestroyed = false
end

function FriendOnLineItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function FriendOnLineItem:tryPopupItem()
	if self:isQueueEmpty() then
		return
	end

	if self.scrollList == nil then
		self:loadContainerContent()

		return
	end

	while not self:isQueueEmpty() and not self:isReachTheLimit() do
		local data = self:dequeue()

		data.removed = nil

		self:addRunItem(data)
		self.scrollList:PushRenderItem(data)
	end
end

function FriendOnLineItem:loadContainerContent()
	if self.isContainerLoading then
		return
	end

	if self.uContainer:CheckURLLoaded() then
		self:registerScrollList(self.uContainer.content)

		return
	end

	self.isContainerLoading = true

	local function onLoaded(content)
		self.isContainerLoading = false

		if IsNil(content) then
			return
		end

		if self.isDestroyed then
			self.uContainer:DestroyContent()

			return
		end

		self:registerScrollList(content)
	end

	self.uContainer:LoadDefaultUrlManually(onLoaded)
end

function FriendOnLineItem:registerScrollList(content)
	if self.scrollList ~= nil then
		return
	end

	self.scrollList = content:GetComponent("UScrollList")

	self:setMaxLimit(self.scrollList.MaxCount)

	function self.scrollList.luaRenderItem(button, data)
		self:renderFriendItem(button, data)
	end

	self:bindCloseHotKeys(content)
end

function FriendOnLineItem:bindCloseHotKeys(content)
	local function closeFirstFriendItem()
		local data = self:firstRunItem()

		if data ~= nil then
			self:recycleToast(data)
		end
	end

	self.pcCloseHotKey = LuaUIUtils.bindHotKey(content.gameObject, CLOSE_ACTION_PATH, closeFirstFriendItem, nil)
	self.gamepadCloseHotKey = LuaUIUtils.bindHotKey(content.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadSelect, closeFirstFriendItem, nil)

	self:refreshCloseHotKeys()
end

function FriendOnLineItem:refreshCloseHotKeys()
	local isUsingGamepad = pg.game.input:isUsingGamepad()

	self.pcCloseHotKey.enabled = not isUsingGamepad
	self.gamepadCloseHotKey.enabled = isUsingGamepad
end

function FriendOnLineItem:resolveFriendOnlineDisplayName(uid, playerInfo, rawName)
	local platformHooks = FriendOnLineItem._platformHooks

	if platformHooks and platformHooks.resolveFriendOnlineDisplayName then
		return platformHooks.resolveFriendOnlineDisplayName(self, uid, playerInfo, rawName) or rawName
	end

	return rawName
end

function FriendOnLineItem:renderFriendItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local playerHeadUWidget = objectReference:GetRefValue("playerHeadUWidget")
	local btnChatUButton = objectReference:GetRefValue("btnChatUButton")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local listKeyUList = objectReference:GetRefValue("listKeyUList")
	local playerInfo = pg.game.chat:getPlayerInfo(data.uid)

	LuaUIUtils.renderPlayerAvatarImages(playerHeadUWidget, {
		avatarIconId = playerInfo.headIcon,
		avatarFrameIconId = playerInfo.headFrame
	})

	local displayName = LuaUIUtils.getPlayerDisplayName(data.uid, playerInfo.playerName, true)

	displayName = self:resolveFriendOnlineDisplayName(data.uid, playerInfo, displayName)

	local displayText = pg.getFormatText(pg.getGameString("FRIEND_ONLINE"), displayName)

	ClientTextUtils.setText(txtNameUSDFText, displayText)
	self:refreshKeyList(listKeyUList)

	function btnChatUButton.luaClick()
		self:recycleToast(data)
		pg.global.ui.chat:createNewChat(nil, data.uid)
		pg.game.audio:triggerEvent("ui_sfx_button")
	end

	self:bindChatHotKeys(btnChatUButton, data)

	if data.endTime == nil then
		data.endTime = Time.realSecondCache + DISPLAY_DURATION
	end
end

function FriendOnLineItem:bindChatHotKeys(btnChatUButton, data)
	local inputMapActionKey = HotkeyConst.INPUT_MAP_ACTION_KEY

	btnChatUButton:SetPCAction(PC_CHAT_ACTION_PATH)
	btnChatUButton:SetGamepadAction(inputMapActionKey.GamepadStart)

	local shouldHideHotKey = data ~= self:firstRunItem()

	btnChatUButton:SetHotkeyForceHidden(shouldHideHotKey)
end

function FriendOnLineItem:refreshKeyList(listKeyUList)
	local isMobile = pg.global.ui:runPlatformByMobile()

	if isMobile then
		return
	end

	local isUsingGamepad = pg.game.input:isUsingGamepad()
	local inputMapActionKey = HotkeyConst.INPUT_MAP_ACTION_KEY
	local closeKeyPath = isUsingGamepad and inputMapActionKey.GamepadSelect or CLOSE_ACTION_PATH
	local chatKeyPath = isUsingGamepad and inputMapActionKey.GamepadStart or PC_CHAT_ACTION_PATH

	LuaUIUtils.setKeyList(listKeyUList, {
		{
			path = closeKeyPath,
			label = pg.getGameString("CLOSE")
		},
		{
			path = chatKeyPath,
			label = pg.getGameString("FRIEND_ONLINE_GOTO_CHAT")
		}
	})
end

function FriendOnLineItem:onInputDeviceChanged()
	if self.scrollList == nil then
		return
	end

	self:refreshCloseHotKeys()

	for _, data in ipairs(self.runList) do
		self:refreshRunningItemKeyList(data)
	end
end

function FriendOnLineItem:refreshRunningItemKeyList(data)
	local hasItem, button = self.scrollList:TryGetItem(data)

	if hasItem ~= true then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local listKeyUList = objectReference:GetRefValue("listKeyUList")

	self:refreshKeyList(listKeyUList)
end

function FriendOnLineItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local currentTime = Time.realSecondCache

	for i = #self.runList, 1, -1 do
		local data = self.runList[i]

		if data.endTime ~= nil and currentTime >= data.endTime then
			self:recycleToast(data)
		end
	end
end

function FriendOnLineItem:onClearRunningList(force)
	for i = #self.runList, 1, -1 do
		self:recycleToast(self.runList[i], force)
	end
end

function FriendOnLineItem:recycleToast(data, force)
	self:requestRecycle(data, force, EXIT_ANIMATION)
end

function FriendOnLineItem:destroyItem(data, force)
	self:completeRecycle(data, force)
end

function FriendOnLineItem:refreshFriendHotKeyStates()
	for _, data in ipairs(self.runList) do
		self:refreshRunningItemHotKeyState(data)
	end
end

function FriendOnLineItem:refreshRunningItemHotKeyState(data)
	local hasItem, button = self.scrollList:TryGetItem(data)

	if hasItem ~= true then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local btnChatUButton = objectReference:GetRefValue("btnChatUButton")
	local shouldHideHotKey = data ~= self:firstRunItem()

	btnChatUButton:SetHotkeyForceHidden(shouldHideHotKey)
end

function FriendOnLineItem:onDestroy()
	self.isDestroyed = true

	BaseQueueItem.onDestroy(self)

	if self.scrollList ~= nil then
		self.scrollList.luaRenderItem = nil
	end

	self.uContainer:DestroyContent()

	self.scrollList = nil
	self.pcCloseHotKey = nil
	self.gamepadCloseHotKey = nil
end

function FriendOnLineItem:GMPushData(data)
	data.uid = pg.me.uid
	data.tIndex = 0
end

function FriendOnLineItem:getRecycleTarget(data)
	return self:getListRecycleTarget(data)
end

function FriendOnLineItem:onRecycleCleanup(data, target, reason)
	self:cleanupRecycleList(data, target, reason)
end

function FriendOnLineItem:onRecycleFinished(data, reason)
	data.removed = true

	self:refreshFriendHotKeyStates()
end

return FriendOnLineItem
