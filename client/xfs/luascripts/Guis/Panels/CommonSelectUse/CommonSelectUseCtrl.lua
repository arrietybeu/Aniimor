-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonSelectUse\\CommonSelectUseCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LevelBreakthroughComponent = require("Guis.Panels.CommonSelectUse.Component.LevelBreakthroughComponent")
local LevelUpComponent = require("Guis.Panels.CommonSelectUse.Component.LevelUpComponent")
local HotkeyConst = require("Const.HotkeyConst")
local EventConst = require("Const.EventConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local CommonSelectUseCtrl = Class.LightClass("CommonSelectUseCtrl", UICtrl)
local Utils = require("Common.Utils.Utils")

function CommonSelectUseCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	function self.onPetLevelUpPanelClose(data)
		self:onPetLevelUpPanelCloseFunc(data)
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_PET_LEVEL_UP_CLOSE_PANEL, self.onPetLevelUpPanelClose)

	if info.directToLevelBreak then
		self:switchMode(self.model.MODE.LEVEL_BREAKTHROUGH)
	else
		self:switchMode(self.model.MODE.LEVEL_UP)
	end
end

function CommonSelectUseCtrl:switchMode(mode)
	if self.levelUpComponent then
		self.levelUpComponent:destroy()

		self.levelUpComponent = nil
	end

	if self.levelBreakthroughComponent then
		self.levelBreakthroughComponent:destroy()

		self.levelBreakthroughComponent = nil
	end

	if mode == self.model.MODE.LEVEL_UP then
		self.levelUpComponent = LevelUpComponent.new(self)

		self.levelUpComponent:overrideAddListener()
		self.view.root:GetComponent("UComponent"):TryChangePage("Type", 0)
		self.levelUpComponent:overrideOnShow()
	elseif mode == self.model.MODE.LEVEL_BREAKTHROUGH then
		self.levelBreakthroughComponent = LevelBreakthroughComponent.new(self)

		self.levelBreakthroughComponent:overrideAddListener()
		self.view.root:GetComponent("UComponent"):TryChangePage("Type", 1)
		self.levelBreakthroughComponent:overrideOnShow()
	end

	self.lastMode = mode
end

function CommonSelectUseCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.root.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closePanel()
		end
	end
end

function CommonSelectUseCtrl:checkCanOpen(_, data)
	if data == nil then
		return false
	end

	self.iData = data

	return true
end

function CommonSelectUseCtrl:checkSwitchMode()
	local canBreak = Utils.canLevelBreakthrough(self.iData.petId)
	local mode = self.model.MODE.LEVEL_UP

	if canBreak then
		mode = self.model.MODE.LEVEL_BREAKTHROUGH
	end

	if self.lastMode and self.lastMode == mode then
		-- block empty
	else
		if mode == self.model.MODE.LEVEL_BREAKTHROUGH then
			self.view.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		elseif mode == self.model.MODE.LEVEL_UP then
			self.view.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
		end

		self:switchMode(mode)
	end
end

function CommonSelectUseCtrl:closePanel()
	self:dismiss()
	pg.global.eventEmitter:removeEventListener(EventConst.ON_PET_LEVEL_UP_CLOSE_PANEL, self.onPetLevelUpPanelClose)
end

function CommonSelectUseCtrl:onPetLevelUpPanelCloseFunc(data)
	self:checkSwitchMode()
end

return CommonSelectUseCtrl
