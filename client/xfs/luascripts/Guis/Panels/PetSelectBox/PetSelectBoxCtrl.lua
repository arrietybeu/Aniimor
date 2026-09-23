-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSelectBox\\PetSelectBoxCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetSelectBoxCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetSelectBoxCtrl = Class.LightClass("PetSelectBoxCtrl", UICtrl)
local PetManagementUtils = require("Utils.PetManagementUtils")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

PetSelectBoxCtrl.messages = {}

function PetSelectBoxCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetSelectBoxCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.btnClose.luaClick()
		self:dismiss()
	end

	function self.view.btnDetails.luaClick()
		local _, page = self.view.rootComponent:TryGetCurrentPage("Switch")
		local newPage = page == 0 and 1 or 0

		self.view.rootComponent:TryChangePage("Switch", newPage)
	end

	function self.view.btnSelect.luaClick()
		self:onSelectConfirm()
	end
end

function PetSelectBoxCtrl:afterInit()
	PetManagementUtils.initMsg(self)
end

function PetSelectBoxCtrl:onDestroy()
	PetManagementUtils.destroyTemplate()
	UICtrl.onDestroy(self)
end

function PetSelectBoxCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.confirmCallback = info and info.confirmCallback
	self.selectPetId = info and info.selectPetId

	PetManagementUtils.setListButtonDelegateTable({
		selectedChanged = function(data)
			self.selectPetId = data.id
		end,
		openPropertyPanelCb = function()
			self:onSelectConfirm()
		end
	})
	PetManagementUtils.initTemplate(self.view.petInfo, self.view.petList, {
		hideUIScene = true,
		selectPetId = self.selectPetId,
		uiScene = self.uiScene
	})
end

function PetSelectBoxCtrl:onSelectConfirm()
	if self.confirmCallback and self.selectPetId then
		self.confirmCallback(self.selectPetId)
	end

	self:dismiss()
end

function PetSelectBoxCtrl:onHide()
	return
end

return PetSelectBoxCtrl
