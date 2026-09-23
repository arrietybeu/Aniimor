-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityResult\\PetFertilityResultCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local ItemData = require("Data.item_data")
local PetFertilityResultCtrl = Class.LightClass("PetFertilityResultCtrl", UICtrl)

PetFertilityResultCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PetFertilityResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:Init()
end

function PetFertilityResultCtrl:onShow()
	return
end

function PetFertilityResultCtrl:onHide()
	return
end

function PetFertilityResultCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

function PetFertilityResultCtrl:Init()
	return
end

function PetFertilityResultCtrl:destroy()
	return
end

function PetFertilityResultCtrl:addListener()
	function self.view.continueButtonUButton.luaClick()
		self:sweepEggBushes()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onEggObtainClick()
	end
end

function PetFertilityResultCtrl:sweepEggBushes()
	self.eggInfo = pg.game.petBall.eggInfo

	if not self.eggInfo then
		return
	end

	self.view.fuyuEggUImage.url = ItemData[self.eggInfo.itemId].icon

	self.view.root:TryChangePage("State", 1)

	if self.timer then
		TimerManager.removeTimer(self.timer)
	end

	self.timer = TimerManager.addTimer(0.8, function()
		self.view.root:TryChangePage("State", 2)
	end)

	self.view.panelResultUComponent:TryChangePage("shiny", self.eggInfo.isShiny and 1 or 0)
end

function PetFertilityResultCtrl:onEggObtainClick()
	self:closePanel()
	pg.global.ui:open(UIConst.UI_ID_PET_FERTILITY_RESULT_POP)
end

function PetFertilityResultCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_PET_FERTILITY_RESULT)
end

return PetFertilityResultCtrl
