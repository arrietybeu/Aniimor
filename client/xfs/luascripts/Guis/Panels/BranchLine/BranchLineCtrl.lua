-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BranchLine\\BranchLineCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BranchLineCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local BranchLineCtrl = Class.LightClass("BranchLineCtrl", UICtrl)
local SceneUtils = require("Common.Utils.SceneUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")

BranchLineCtrl.messages = {
	[MessageName.REQUEST_BRANCH_LINE_INFO] = {
		"onRequestLineInfo",
		true
	}
}

function BranchLineCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function BranchLineCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnCancelUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onBtnConfirmSelect()
	end

	function self.view.branchList.luaRenderItem(button, idx, data)
		self:renderItem(button, idx, data)
	end

	function self.view.branchList.luaSelectedChanged(uList)
		self.selectItem = uList.selectedItem
	end
end

function BranchLineCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function BranchLineCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	pg.me:pullExclusiveLine()
end

function BranchLineCtrl:onRequestLineInfo(data)
	local dataList = self.model:parseLineInfo(data.info)

	self.view.branchList:SetList(dataList)
end

function BranchLineCtrl:renderItem(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local channelUBaseText = objectReference:GetRefValue("channelUBaseText")
	local numberUBaseText = objectReference:GetRefValue("numberUBaseText")

	ClientTextUtils.setText(channelUBaseText, data.name)
	ClientTextUtils.setText(numberUBaseText, data.ps)
	button:TryChangePage("State", data.mode)
end

function BranchLineCtrl:onBtnConfirmSelect()
	if self.selectItem == nil then
		return
	end

	local lineId = self.selectItem.lineId

	pg.me:switchExclusiveLine(lineId)
	self:dismiss()
end

function BranchLineCtrl:onHide()
	return
end

return BranchLineCtrl
