-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerSkillFilter\\PlayerSkillFilterCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PlayerSkillFilterCtrl = Class.LightClass("PlayerSkillFilterCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

PlayerSkillFilterCtrl.messages = {}

function PlayerSkillFilterCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PlayerSkillFilterCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:onBtnClosePanel()
	end

	function self.view.filterList.luaRenderItem(button, _, data)
		self:onRenderOptionTypeItem(button, data)
	end

	function self.view.btnCancel.luaClick()
		self:onBtnCancel()
	end

	function self.view.btnConfirm.luaClick()
		self:onBtnConfirm()
	end
end

function PlayerSkillFilterCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PlayerSkillFilterCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.filterData = info
end

function PlayerSkillFilterCtrl:onShow()
	self.view.filterList:SetList(self.filterData.filter)
end

function PlayerSkillFilterCtrl:onRenderOptionTypeItem(button, data)
	local oc = button:GetComponent("ObjectReference")
	local txtTitle = oc:GetRefValue("txtTitle")
	local optionList = oc:GetRefValue("optionList")

	ClientTextUtils.setText(txtTitle, data.name)

	function optionList.luaRenderItem(subBtn, idx, subData)
		self:onRenderOptionItem(optionList, subBtn, idx, subData)
	end

	optionList:SetList(data)
end

function PlayerSkillFilterCtrl:onRenderOptionItem(optionList, button, index, data)
	local oc = button:GetComponent("ObjectReference")
	local txtName = oc:GetRefValue("txtName")

	ClientTextUtils.setText(txtName, data.optionName)
	button:TryChangePage("select", data.select and 1 or 0)

	function button.luaClick()
		data.select = not data.select

		optionList:RefreshElement(index)
	end
end

function PlayerSkillFilterCtrl:onBtnClosePanel()
	self:dismiss()
end

function PlayerSkillFilterCtrl:onBtnCancel()
	self:dismiss()

	if self.filterData.cancelCallback == nil then
		return
	end

	self.filterData.cancelCallback()
end

function PlayerSkillFilterCtrl:onBtnConfirm()
	self:dismiss()

	if self.filterData.confirmCallback == nil then
		return
	end

	self.filterData.confirmCallback()
end

function PlayerSkillFilterCtrl:onHide()
	return
end

return PlayerSkillFilterCtrl
