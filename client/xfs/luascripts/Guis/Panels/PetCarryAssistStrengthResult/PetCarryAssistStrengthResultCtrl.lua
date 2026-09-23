-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryAssistStrengthResult\\PetCarryAssistStrengthResultCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetCarryAssistStrengthResultCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetCarryAssistStrengthResultCtrl = Class.LightClass("PetCarryAssistStrengthResultCtrl", UICtrl)

PetCarryAssistStrengthResultCtrl.messages = {}

function PetCarryAssistStrengthResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.closeCallback = info and info.closeCallback
	self.carryAssistData = info.data
end

function PetCarryAssistStrengthResultCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:onClosePanel()
	end
end

function PetCarryAssistStrengthResultCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetCarryAssistStrengthResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local sData = self.carryAssistData

	self.view.jewelUImage.url = sData.icon

	self.view.jewelUComponent:TryChangePage("Quality", sData.quality)
	ClientTextUtils.setText(self.view.txtCpUBaseText, "CP ", sData.cpValue)
	ClientTextUtils.setText(self.view.txtNumUBaseText, sData.energy)
	LuaUIUtils.refreshCarryAssistAttrList(self.view.listBaseUList, sData.mainProperties)

	self.needChecks = {}
	self.timerIds = {}

	function self.view.listRandomUList.luaRenderItem(sBtn, _, sData)
		local objectReference = sBtn:GetComponent("ObjectReference")
		local attributeItemRef = objectReference:GetRefValue("attributeItemRef")

		LuaUIUtils.renderCarryAssistAttrItem(attributeItemRef, sData)

		local needCheck = sData.isRare

		if needCheck then
			sBtn:TryChangePage("state", 1)
		end

		local index = #self.needChecks + 1

		sBtn:TryChangePage("display", 0)

		if not needCheck then
			self.timerIds[index] = self:startTimer(function()
				sBtn:TryChangePage("display", 1)
			end, 0.8)
		end

		sBtn:TryChangePage("Quality", sData.isRare and 6 or 0)

		function sBtn.luaClick()
			if needCheck then
				sBtn:TryChangePage("display", 1)

				self.needChecks[index].needCheck = false
			end
		end

		self.needChecks[index] = {
			item = sBtn,
			needCheck = needCheck
		}
	end

	self.view.listRandomUList:SetList(sData.randomProperties)
end

function PetCarryAssistStrengthResultCtrl:onClosePanel()
	local showUnlock = false

	for i, v in ipairs(self.needChecks) do
		if v.needCheck then
			v.needCheck = false

			v.item:TryChangePage("display", 1)

			showUnlock = true
		end
	end

	for _, v in pairs(self.timerIds) do
		self:killTimer(v)

		v = nil
	end

	self.timerIds = nil

	if showUnlock then
		return
	end

	if self.closeCallback then
		self.closeCallback()
	end

	self:dismiss()
end

return PetCarryAssistStrengthResultCtrl
