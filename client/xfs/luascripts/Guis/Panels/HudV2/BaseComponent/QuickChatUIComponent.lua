-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\QuickChatUIComponent.lua

local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local QuickChatIUIComponent = Class.LightClass("QuickChatIUIComponent", HudBaseComponent)
local SysConfigData = require("Data.sys_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local MessageName = require("Const.MessageName")
local ClientSwitch = require("Common.ClientSwitch")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local AsrHttpClient = require("Core.Net.Http.AsrHttpClient")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("QuickChatIUIComponent")

QuickChatIUIComponent.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function QuickChatIUIComponent:findObjects()
	local rootObjectReference = self.transform:GetComponent("ObjectReference")

	self.btnChatBubbleUComponent = rootObjectReference:GetRefValue("btnChatBubbleUComponent")

	local objectReference = self.btnChatBubbleUComponent:GetComponent("ObjectReference")

	self.btnChatExpand = objectReference:GetRefValue("btnChatExpand")
	self.btnChatBubbleAnim = self.btnChatExpand:GetComponent("Animation")
	self.btnChatExpandClose = objectReference:GetRefValue("btnChatExpandClose")
	self.chatInputField = objectReference:GetRefValue("chatInputField")
	self.btnChatSend = objectReference:GetRefValue("btnChatSend")
	self.placeHolderUSDFText = objectReference:GetRefValue("placeHolderUSDFText")
	self.chatExpandHotKey = objectReference:GetRefValue("chatExpandHotKey")
	self.chatExpandCloseHotKey = objectReference:GetRefValue("chatExpandCloseHotKey")
	self.btnVioceUButton = objectReference:GetRefValue("btnVioceUButton")
	self.btnChat = self.ctrl.btnChat

	self.gameObject:SetActiveEx(false)
end

function QuickChatIUIComponent:initView()
	function self.btnChatExpand.luaClick()
		self:leaveSimpleChatMode()

		local hasDungeonTeamInfo = pg.me:hasDungeonTeamInfo()

		if hasDungeonTeamInfo then
			local openParam = {
				initTab = pg.game.chat.tabType.Notice,
				initChannelType = pg.game.chat.channelType.Team
			}
			local options = {
				ignoreDisableMainCamera = true
			}

			pg.global.ui:open(UIConst.UI_ID_CHAT, openParam, nil, nil, options)
		else
			pg.global.ui:open(UIConst.UI_ID_CHAT, nil, nil, nil, {
				ignoreDisableMainCamera = true
			})
		end

		self:refreshBtnChatAnim(false)
	end

	function self.chatInputField.luaValueChanged(text)
		self.chatInputField:SetTextWithoutNotify(ClientTextUtils.getValidName(text, SysConfigData.SIMPLE_CHAT_LIMIT_MAX or 25))
	end

	function self.chatInputField.luaOnSpecialEvent(actionPath)
		if actionPath == "Common/TabSwitch" then
			self.btnChatExpand.luaClick()
		elseif actionPath == "Hud/QuitQuickChat" then
			self.btnChatExpandClose.luaClick()
		end
	end

	function self.chatInputField.luaOnSelect(text)
		self.typingChannel = pg.game.chat:getCurSimpleChatChannelInfo()

		pg.game.chat:showEntityMessageTypingByUid(pg.me.uid, ClientConst.PlayerTyping.Typing)
		pg.me:notifyPlayerTyping(self:getTypingTargetIds(self.typingChannel), ClientConst.PlayerTyping.Typing)
	end

	function self.chatInputField.luaOnDeSelect(text)
		pg.game.chat:showEntityMessageTypingByUid(pg.me.uid, ClientConst.PlayerTyping.None)
		pg.me:notifyPlayerTyping(self:getTypingTargetIds(self.typingChannel, true), ClientConst.PlayerTyping.None)

		self.typingChannel = nil
	end

	function self.chatInputField.luaEndEdit(text)
		if self:sendMessageQuick(text) == true then
			self:refreshChatInputAfterSend()
		end
	end

	function self.btnChatExpandClose.luaClick()
		self:leaveSimpleChatMode()
	end

	function self.btnChatSend.luaClick()
		if self:sendMessageQuick(self.chatInputField.text) == true then
			self:refreshChatInputAfterSend()
		end
	end

	self.chatExpandHotKey:SetHotKeyPaths("Common/TabSwitch")
	self.chatExpandCloseHotKey:SetHotKeyPaths("Hud/QuitQuickChat")
	self:bindHotKeyPerform("Common/TabSwitch", self.btnChatExpand.luaClick, self.btnChatExpand.gameObject)
	self:bindHotKeyPerform("Hud/QuitQuickChat", self.btnChatExpandClose.luaClick, self.btnChatExpandClose.gameObject)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HUD_CHAT, self.btnChatExpand, function()
		return pg.game.chat:redDot_GetHudChatButtonState()
	end, function()
		return pg.game.chat:redDot_HudChatGetAllUnreadMessage()
	end)

	function self.btnVioceUButton.luaPress()
		self:onNvidiaTestByGMEPress()
	end

	function self.btnVioceUButton.luaRelease()
		self:onNvidiaTestByGMERelease()
	end

	self:initBtnVoice()
end

function QuickChatIUIComponent:refreshChatInputAfterSend()
	self.chatInputField.text = ""

	if pg.global.ui:runPlatformByMobile() or pg.game.input:isUsingGamepad() then
		return
	end

	self.chatInputField:Select()
end

function QuickChatIUIComponent:initBtnVoice()
	if not ClientSwitch.NvidiaVoiceTest then
		return
	end

	local hotKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(self.btnVioceUButton.gameObject, "btnVoice")
	local hotKeyContent = self.btnVioceUButton:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")

	if hotKeyContent then
		hotKeyBind.keyBoardContent = hotKeyContent
	end

	hotKeyBind.actionPath = "Hud/SkillR"
end

function QuickChatIUIComponent:leaveSimpleChatMode()
	self.chatInputField:DeSelect()
	self:switchQuickChatState(false)
end

function QuickChatIUIComponent:openChat()
	self:initBtnVoice()
	self.btnVioceUButton:SetActiveFastestAndMarkIgnoreLayout(ClientSwitch.NvidiaVoiceTest or false)

	if pg.game:checkModuleEnable(ClientConst.ModuleKey.Chat) ~= true then
		return
	end

	if pg.me == nil then
		return
	end

	local channel = pg.game.chat:getCurSimpleChatChannelInfo()

	if channel ~= nil then
		self:switchQuickChatState(true)

		local inputStr = ""

		if pg.global.ui:runPlatformByMobile() then
			inputStr = pg.getGameString("SIMPLE_CHAT_CHANNEL_TIP_MOBILE")
		elseif pg.game.input:isUsingGamepad() then
			inputStr = pg.getGameString("SIMPLE_CHAT_CHANNEL_TIP_CONSOLE")
		else
			inputStr = pg.getGameString("SIMPLE_CHAT_CHANNEL_TIP_PC")
		end

		ClientTextUtils.setText(self.placeHolderUSDFText, pg.getFormatText(inputStr, channel.channelName))
		self:refreshBtnChatAnim()

		if pg.global.ui:runPlatformByMobile() or ClientSwitch.NvidiaVoiceTest then
			-- block empty
		else
			self.chatInputField:Select()
		end

		if pg.game.input:isUsingGamepad() then
			pg.global.showBubbleMessageRaw(pg.getGameString("SIMPLE_CHAT_CONSOLE_TIP"))
		end
	else
		pg.global.ui:open(UIConst.UI_ID_CHAT, nil, nil, nil, {
			ignoreDisableMainCamera = true
		})
		self:refreshBtnChatAnim(false)
	end
end

function QuickChatIUIComponent:getTypingTargetIds(channel, allowInactiveVehicle)
	if channel == nil then
		channel = pg.game.chat:getCurSimpleChatChannelInfo()
	end

	if channel ~= nil and channel.channelType == pg.game.chat.channelType.Vehicle then
		return pg.game.chat:getVehicleChatTargetIds(channel.channelId, allowInactiveVehicle)
	end

	local targetIds = {}

	if pg.me == nil then
		return targetIds
	end

	local actorIds = pg.me:entitiesInRange(Const.CHAT.NEARBY_RADIUS, Const.SEARCH_USR_TYPE_PLAYER + Const.SEARCH_USR_TYPE_PLAYER_GHOST)

	for _, actorId in ipairs(actorIds) do
		local ent = pg.getEntityByActorId(actorId)

		if ent ~= nil and ent.uid ~= nil then
			table.insert(targetIds, ent.uid)
		end
	end

	return targetIds
end

function QuickChatIUIComponent:syncVehicleTypingToUid(uid, vehicleActorId)
	local typingType = ClientConst.PlayerTyping.None

	if self.typingChannel ~= nil and self.typingChannel.channelType == pg.game.chat.channelType.Vehicle and tonumber(self.typingChannel.channelId) == tonumber(vehicleActorId) then
		typingType = ClientConst.PlayerTyping.Typing
	end

	pg.me:notifyPlayerTyping({
		uid
	}, typingType)
end

function QuickChatIUIComponent:switchQuickChatState(isQuickChat)
	self.gameObject:SetActiveEx(isQuickChat)

	if isQuickChat then
		self.ctrl:hide()
	else
		self.ctrl:show()
	end

	if self.ctrl.aim then
		self.ctrl.aim:refreshAimBtnState()
	end

	self:refreshBtnChatAnim()

	if pg.global.ui.hudV2 and pg.global.ui.hudV2.RD.interactGesture then
		pg.global.ui.hudV2.RD.interactGesture:closeEmoticonPanel()
	end
end

function QuickChatIUIComponent:refreshBtnChatAnim(isPlaying)
	if isPlaying ~= nil then
		self.isAnimPlaying = isPlaying
	end

	if not IsNil(self.btnChat) and not IsNil(self.btnChat.gameObject) and not IsNil(self.btnChatBubbleUComponent.gameObject) then
		if self.isAnimPlaying then
			self.btnChatBubbleUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		else
			self.btnChat:InvokeCallback(CS.XGUI.EInvokeTime.User2)
			self.btnChatBubbleUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
		end
	end
end

function QuickChatIUIComponent:onInputDeviceChanged()
	local channel = pg.game.chat:getCurSimpleChatChannelInfo()

	if channel ~= nil then
		local inputStr = pg.getGameString("SIMPLE_CHAT_CHANNEL_TIP_PC")

		if pg.game.input:isUsingGamepad() == true then
			inputStr = pg.getGameString("SIMPLE_CHAT_CHANNEL_TIP_CONSOLE")
		end

		ClientTextUtils.setText(self.placeHolderUSDFText, pg.getFormatText(inputStr, channel.channelName))
	end
end

function QuickChatIUIComponent:sendMessageQuick(text)
	if string.isNilOrEmpty(text) == true then
		return false
	end

	local channel = pg.game.chat:getCurSimpleChatChannelInfo()

	if channel == nil then
		return false
	end

	local sent = pg.game.chat:sendMessage(text, pg.game.chat.subMessageType.Text, channel.channelType, channel.channelId)

	return sent
end

local function getLocalASRAddress()
	local ip = pg.global.prefsCacheUtils:getString("nvidiaASRIP", "127.0.0.1")
	local port = tonumber(pg.global.prefsCacheUtils:getString("nvidiaASRPort", "8000")) or 8000

	if string.isNilOrEmpty(ip) then
		ip = "127.0.0.1"
	end

	return ip, port
end

function QuickChatIUIComponent:onNvidiaTestByGMEPress()
	if not ClientSwitch.NvidiaVoiceTest then
		return
	end

	pg.global.gmeManager:StartRecord_Test()
end

function QuickChatIUIComponent:onNvidiaTestByGMERelease()
	if not ClientSwitch.NvidiaVoiceTest then
		return
	end

	pg.global.gmeManager:StopRecord_Test(function(fileId, filePath, fileSize, duration, gmeText, auditResult, code, tooShort)
		pg.game.speech:onRecordStopped(fileId, filePath, fileSize, duration, gmeText, auditResult, code, tooShort)

		if string.isNilOrEmpty(filePath) then
			logger:info("GME record file path is empty")

			return
		end

		local file, openErr = io.open(filePath, "rb")

		if file == nil then
			logger:info("Failed to open GME OGG: path=%s err=%s", filePath, tostring(openErr))

			return
		end

		local oggBytes = file:read("*a")

		file:close()

		local filename = filePath:match("([^/\\]+)$") or "record.ogg"
		local ip, port = getLocalASRAddress()

		AsrHttpClient:recognize(ip, port, oggBytes, filename, false, 60000, function(ok, result, err)
			if not ok then
				logger:info("Local ASR recognize failed: %s , will use gme text ", tostring(err))
				self:sendMessageQuick(gmeText)
			else
				self:sendMessageQuick(result and result.text or "")
			end
		end)
	end)
end

return QuickChatIUIComponent
