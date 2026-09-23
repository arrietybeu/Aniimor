-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonSkip\\CommonSkipCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CommonSkipCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local DialogueGraphSkipData = require("Data.dialogue_graph_skip_data")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local UICtrl = require("Guis.UICtrl")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CommonSkipCtrl = Class.LightClass("CommonSkipCtrl", UICtrl)

CommonSkipCtrl.SpeedMax = 3
CommonSkipCtrl.messages = {
	[MessageName.DIALOGUE_GRAPH_PLAYBACK_STATE_CHANGE] = {
		"onPlaybackStateChange",
		true
	},
	[MessageName.DIALOGUE_GRAPH_PLAYBACK_PERMISSION_CHANGE] = {
		"onPlaybackPremissionChange",
		true
	}
}

function CommonSkipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CommonSkipCtrl:onPlaybackStateChange(state)
	if state == DialogueGraphConst.PLAYBACK_STATE.NORMAL then
		self.view.mainCom:TryChangePage("skipState", 0)
		self.view.mainCom:TryChangePage("playState", 0)
	elseif state == DialogueGraphConst.PLAYBACK_STATE.AUTO_PLAYING then
		self.view.mainCom:TryChangePage("skipState", 0)
		self.view.mainCom:TryChangePage("playState", 1)
		self:setPlaySpeed(self.currentSpeed, true)
	elseif state == DialogueGraphConst.PLAYBACK_STATE.SKIPPING then
		self.view.mainCom:TryChangePage("skipState", 1)
	end
end

function CommonSkipCtrl:onPlaybackPremissionChange(permissonType)
	if permissonType == DialogueGraphConst.PLAYBACK_PERMISSION.SKIP then
		self.view.mainCom:TryChangePage("enableSkip", self.cmd:canSkip() and 0 or 1)
	end
end

function CommonSkipCtrl:addListener()
	LuaUIUtils.setUIViewVisible(self.view.btnSpeedUButton, false)

	function self.view.btnAutoUButton.luaClick()
		self.cmd:startAutoPlay()
	end

	LuaUIUtils.setUIViewVisible(self.view.btnGearUButton, false)

	function self.view.btnPlayingUButton.luaClick()
		self.cmd:stopAutoPlay()
	end

	function self.view.btnSkipUButton.luaClick()
		if not self.cmd:canSkip() then
			return
		end

		DialogueGraphUtils.pauseGame()

		local cmd = self.cmd

		local function okCb()
			DialogueGraphUtils.resumeGame()
			cmd:startSkip()
		end

		local title, msg, extraInfo
		local key = self.cmd.id

		if DialogueGraphSkipData[key] then
			title = pg.getLocalizationText(DialogueGraphSkipData[key].title)
			msg = pg.getLocalizationText(DialogueGraphSkipData[key].msg)

			pg.global.ui.dialogueSkip:openConfirm(title, msg, function()
				okCb()
			end, nil, function()
				DialogueGraphUtils.resumeGame()
			end, nil, nil, extraInfo)
		else
			title = pg.getGameString("SKIPDIALOGUE")
			msg = ""
			extraInfo = {
				hint = not pg.me.noSkipScenePromptToday,
				hintCb = function(isSelected)
					pg.me:SetSkipScenePromptToday(isSelected)
				end,
				hintDesc = pg.getGameString("SKIPDIALOGUE_TODAY")
			}

			if pg.me.noSkipScenePromptToday then
				okCb()
			else
				pg.global.showConfirmMsgRaw(title, msg, function()
					DialogueGraphUtils.resumeGame()
					okCb()
				end, nil, function()
					DialogueGraphUtils.resumeGame()
				end, nil, nil, extraInfo)
			end
		end
	end

	function self.view.btnLogUButton.luaClick()
		self:hide()
		self.cmd:pause()
		pg.game.communication:openDialogReview(function()
			self:show()
			self.cmd:resume()
		end)
	end

	local keyBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "confirm")

	keyBinding.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Confirm
	keyBinding.isVirtual = true

	function keyBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			facade:sendMsgToUI(MessageName.DIALOGUE_GRAPH_PLAYBACK_CLICK_NEXT)
		end

		return true
	end

	local logHotKeyContent = self.view.btnLogUButton.transform:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")
	local autoHotKeyContent = self.view.btnAutoUButton.transform:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")
	local playingHotKeyContent = self.view.btnPlayingUButton.transform:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")
	local skipHotKeyContent = self.view.btnSkipUButton.transform:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")

	logHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadSelect)
	autoHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest)
	playingHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest)
	skipHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadStart)
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadSelect, self.view.btnLogUButton.luaClick, self.view.btnLogUButton.gameObject)
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, self.view.btnAutoUButton.luaClick, self.view.btnAutoUButton.gameObject)
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, self.view.btnPlayingUButton.luaClick, self.view.btnPlayingUButton.gameObject)
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadStart, self.view.btnSkipUButton.luaClick, self.view.btnSkipUButton.gameObject)
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.ClosePanelCommon, function()
		self.view.btnSkipUButton.luaClick()

		return false
	end, self.view.gameObject)
end

function CommonSkipCtrl:onShow()
	UICtrl.onShow(self)
	self:onInit()
end

function CommonSkipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info.cmd then
		self.cmd = info.cmd
	end
end

function CommonSkipCtrl:onInit()
	self:setPlaySpeed(self.cmd:getPlaySpeed(), true)

	local playState = self.cmd:getPlaybackState()

	self:onPlaybackStateChange(playState)
	self:onPlaybackPremissionChange(DialogueGraphConst.PLAYBACK_PERMISSION.SKIP)
end

function CommonSkipCtrl:changeSpeed()
	if self.currentSpeed >= CommonSkipCtrl.SpeedMax then
		self.currentSpeed = 1
	else
		self.currentSpeed = math.floor(self.currentSpeed + 1)
	end

	self:setPlaySpeed(self.currentSpeed)
end

function CommonSkipCtrl:setPlaySpeed(speed, force)
	self.currentSpeed = speed

	self.cmd:setPlaySpeed(speed, force)
end

function CommonSkipCtrl:refreshSpeedBtnState(btn, active)
	btn:TryChangePage("state", active and 0 or 1)
end

function CommonSkipCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.cmd = nil
end

return CommonSkipCtrl
