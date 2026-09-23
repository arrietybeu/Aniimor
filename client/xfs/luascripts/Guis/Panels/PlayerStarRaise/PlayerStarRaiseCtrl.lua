-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerStarRaise\\PlayerStarRaiseCtrl.lua

local MessageName = require("Const.MessageName")
local PlayerLevelData = require("Data.player_level_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PlayerStarRaiseCtrl = Class.LightClass("PlayerStarRaiseCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")

PlayerStarRaiseCtrl.messages = {}

local PLAYER_MAX_STAR_LEVEL = 5

function PlayerStarRaiseCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PlayerStarRaiseCtrl:addListener()
	function self.view.playerStarListUList.luaRenderItem(button, idx, data)
		self:renderPlayerStarList(button, idx, data)
	end

	function self.view.petResearchStarListUList.luaRenderItem(button, idx, data)
		self:renderResearchStarList(button, idx, data)
	end

	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnCloseUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	self.view.keyHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.Confirm)

	local confirmBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.keyHotKeyContent.gameObject, "closeConfirmBind")

	confirmBind.isVirtual = true
	confirmBind.priority = -1
	confirmBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Confirm

	function confirmBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end
end

function PlayerStarRaiseCtrl:onDestroy()
	self:clearPlayerStarTimer()
	self:clearRaiseStarTimer()
	UICtrl.onDestroy(self)
end

function PlayerStarRaiseCtrl:renderPlayerStarList(button, idx, data)
	button:TryChangePage("State", data.isLight and 1 or 0)
end

function PlayerStarRaiseCtrl:renderResearchStarList(button, idx, data)
	button:TryChangePage("Progress", 0)

	local objectReference = button:GetComponent("ObjectReference")
	local progressUProgress = objectReference:GetRefValue("progressUProgress")
	local numUText = objectReference:GetRefValue("numUText")
	local garyEmptyUWidget = objectReference:GetRefValue("garyEmptyUWidget")
	local garyEmpty2UWidget = objectReference:GetRefValue("garyEmpty2UWidget")
	local goldenStarUImage = objectReference:GetRefValue("goldenStarUImage")
	local colourfulStarUImage = objectReference:GetRefValue("colourfulStarUImage")

	LuaUIUtils.setUIViewVisible(garyEmptyUWidget, data.isGolden)
	LuaUIUtils.setUIViewVisible(garyEmpty2UWidget, not data.isGolden)
	LuaUIUtils.setUIViewVisible(goldenStarUImage, false)
	LuaUIUtils.setUIViewVisible(colourfulStarUImage, false)

	if data.isLight or data.isRaiseStar then
		LuaUIUtils.setUIViewVisible(goldenStarUImage, data.isGolden)
		LuaUIUtils.setUIViewVisible(colourfulStarUImage, not data.isGolden)
	end

	if data.isRaiseStar then
		if data.isGolden then
			button:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		else
			button:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
		end
	end
end

function PlayerStarRaiseCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.curLevel = info.curLevel
	self.preLevel = info.preLevel

	if self.curLevel > PLAYER_MAX_STAR_LEVEL then
		self.view.rootComponent:TryChangePage("StarType", 0)
		self.view.vFXWidgetUComponent:TryChangePage("ParticleVisible", 0)
	else
		self.view.rootComponent:TryChangePage("StarType", 1)
		self.view.vFXWidgetUComponent:TryChangePage("ParticleVisible", self.curLevel)

		local playerStarData = self:getPlayerStarData()

		self.view.playerStarListUList:SetList(playerStarData)
	end

	LuaUIUtils.setUIViewVisible(self.view.vFXWidgetUComponent, false)

	self.countryStarData = info.countryStarData
	self.maxStarLevel = info.maxLevel

	local researchStarData = self:getResearchStarData()

	self.view.petResearchStarListUList:SetList(researchStarData)
	ClientTextUtils.setText(self.view.textUText, pg.getLocalizationText(PlayerLevelData[self.curLevel].levelName))
	ClientTextUtils.setText(self.view.textUpUText, pg.getLocalizationText(PlayerLevelData[math.min(self.curLevel + 1, PLAYER_MAX_STAR_LEVEL + 1)].levelName))
	self:startPlayerStarTimer()
end

function PlayerStarRaiseCtrl:clearRaiseStarTimer()
	if self.raiseStarTimerId then
		self:killTimer(self.raiseStarTimerId)
	end

	self.raiseStarTimerId = nil
end

function PlayerStarRaiseCtrl:clearPlayerStarTimer()
	if self.playerStarTimer then
		self:killTimer(self.playerStarTimer)
	end

	self.playerStarTimer = nil
end

function PlayerStarRaiseCtrl:startPlayerStarTimer()
	self:clearPlayerStarTimer()

	self.playerStarTimer = self:startTimer(function()
		if self.curLevel > PLAYER_MAX_STAR_LEVEL then
			self:playerStarRaiseVx()
		else
			self:playStarRaiseParticle()
		end
	end, 1)
end

function PlayerStarRaiseCtrl:startRaiseStar()
	self:clearRaiseStarTimer()

	self.raiseStarTimerId = self:startTimer(function()
		self:playerStarRaiseVx()
	end, 1)
end

function PlayerStarRaiseCtrl:getResearchStarData()
	local ret = {}

	for starLevel = 1, self.maxStarLevel do
		local item = {}

		if starLevel < self.curLevel then
			item.isLight = true
		elseif starLevel == self.curLevel then
			item.isRaiseStar = true
		else
			item.isGrey = true
		end

		item.isGolden = self.countryStarData[starLevel].isGolden
		ret[#ret + 1] = item
	end

	return ret
end

function PlayerStarRaiseCtrl:playStarRaiseParticle()
	LuaUIUtils.setUIViewVisible(self.view.vFXWidgetUComponent, true)
	self:startRaiseStar()
end

function PlayerStarRaiseCtrl:playerStarRaiseVx()
	local ret, button = self.view.playerStarListUList:TryGetChildAt(self.curLevel - 1)

	if ret then
		button:TryChangePage("State", 1)
		button:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function PlayerStarRaiseCtrl:getPlayerStarData()
	local ret = {}

	for starLevel = 1, PLAYER_MAX_STAR_LEVEL do
		local item = {}

		if starLevel < self.curLevel then
			item.isLight = true
		elseif starLevel == self.curLevel then
			item.isRaiseStar = true
		else
			item.isGrey = true
		end

		ret[#ret + 1] = item
	end

	return ret
end

function PlayerStarRaiseCtrl:onShow()
	return
end

function PlayerStarRaiseCtrl:onHide()
	return
end

return PlayerStarRaiseCtrl
