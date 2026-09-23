-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DebugVitality\\DebugVitalityCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("DebugVitalityCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local DebugVitalityCtrl = Class.LightClass("DebugVitalityCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Time = require("Core.Common.Time")

DebugVitalityCtrl.messages = {}

function DebugVitalityCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function DebugVitalityCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnClose.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			-- block empty
		end
	end

	function self.view.btnClose.luaClick()
		return
	end

	function self.view.itemList.luaRenderItem(button, index, data)
		self:onRenderVitalityItem(button, data)
	end
end

function DebugVitalityCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if self.tickTimer then
		self:killTimer(self.tickTimer)
	end

	self.tickTimer = nil
end

function DebugVitalityCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function DebugVitalityCtrl:onShow()
	local dataList, min_interval = self.model:getItemInfo()

	self.min_interval = min_interval or 5

	self.view.itemList:SetList(dataList)

	self.tickTimer = self:startTimer(function()
		self:tickRefresh()
	end, 1, true)
	self.lastUpdateTime = Time.realSecondCache
end

function DebugVitalityCtrl:tickRefresh()
	if Time.realSecondCache - self.lastUpdateTime < self.min_interval then
		return
	end

	self.lastUpdateTime = Time.realSecondCache

	self.model:refreshDataList(self.view.itemList.itemData)
	self.view.itemList:RefreshList()
end

function DebugVitalityCtrl:onRenderVitalityItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
	local numUBaseText = objectReference:GetRefValue("numUBaseText")
	local changeNumUBaseText = objectReference:GetRefValue("changeNumUBaseText")

	iconUImage.url = data.icon

	ClientTextUtils.setText(nameUBaseText, data.name)
	ClientTextUtils.setText(numUBaseText, data.ownNumStr)
	ClientTextUtils.setText(changeNumUBaseText, data.desc)
end

function DebugVitalityCtrl:onHide()
	return
end

return DebugVitalityCtrl
