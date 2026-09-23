-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetIvUpDialog\\PetIvUpDialogCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local PetIvUpDialogCtrl = Class.LightClass("PetIvUpDialogCtrl", UICtrl)

PetIvUpDialogCtrl.messages = {}

local IV_KEYS = {
	"hp",
	"atk",
	"def",
	"spd",
	"spAtk",
	"spDef"
}

function PetIvUpDialogCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self._pendingData = info
end

function PetIvUpDialogCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:closePanel()
	end
end

function PetIvUpDialogCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info ~= nil then
		self._pendingData = info
	end

	self:_render()
end

function PetIvUpDialogCtrl:onShow()
	self:_render()
end

function PetIvUpDialogCtrl:_render()
	if self.view == nil then
		return
	end

	local data = self._pendingData

	if data == nil then
		return
	end

	local oldIv = data.oldIv or {}
	local newIv = data.newIv or {}
	local petName = data.petName

	if petName ~= nil then
		self.view.txtPetName:SetText(tostring(petName))
	end

	for _, key in ipairs(IV_KEYS) do
		local oldVal = oldIv[key] or 0
		local newVal = newIv[key] or 0
		local delta = newVal - oldVal

		self:_renderStat(key, oldVal, newVal, delta)
	end
end

function PetIvUpDialogCtrl:_renderStat(key, oldVal, newVal, delta)
	local compName = "stat" .. key:sub(1, 1):upper() .. key:sub(2)

	self.view[compName]:setIvData(oldVal, newVal, delta)
end

return PetIvUpDialogCtrl
