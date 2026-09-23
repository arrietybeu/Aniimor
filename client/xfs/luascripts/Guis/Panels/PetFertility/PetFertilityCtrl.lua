-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertility\\PetFertilityCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local PetHatchComponent = require("Guis.Panels.PetFertility.Component.PetHatchComponent")
local PetBallEntityComponent = require("Guis.Panels.PetFertility.Component.PetBallEntityComponent")
local BreedSceneComponent = require("Guis.Panels.PetFertility.Component.BreedSceneComponent")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local PetFertilityCtrl = Class.LightClass("PetFertilityCtrl", UICtrl)

PetFertilityCtrl.messages = {
	[MessageName.PET_BALL_MAP_HATCH_SLOT_STATUS_CHANGED] = {
		"onHatchMapSlotStatusChanged",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PetFertilityCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info

	self:Init(info)
end

function PetFertilityCtrl:onShow()
	return
end

function PetFertilityCtrl:onHide()
	pg.global.ui.tips:hideDropHint()
end

function PetFertilityCtrl:onVisibleChange(visible)
	if visible and pg.game and pg.game.petBall then
		pg.game.petBall:setPreviewCameraEnabled(true)
	end
end

function PetFertilityCtrl:onDestroy()
	self:_resetSoulEggEvolutionIfNeeded()
	self:destroy()
	UICtrl.onDestroy(self)
end

function PetFertilityCtrl:Init(info)
	if info.openHatch then
		self.petHatchComponent = PetHatchComponent.new(self, self.view.panelHatchUComponent)
	else
		self:initGesture()

		self.breedSceneComponent = BreedSceneComponent.new(self)
		self.petBallEntityComponent = PetBallEntityComponent.new(self)
		self.petHatchComponent = PetHatchComponent.new(self, self.view.panelHatchUComponent)
	end

	local isPetHatchOpen = ClientActivityUtils.isPetHatchActivityOpen()

	if isPetHatchOpen then
		pg.global.ui.tips:showDropHint("PET_HATCH_ACTIVITY_1", self.view.root.position)
	end
end

function PetFertilityCtrl:additionOperation()
	if self.info and self.info.openHatch then
		self:openHatchPanel()
	end
end

function PetFertilityCtrl:destroy()
	self:destroyGesture()
end

function PetFertilityCtrl:_resetSoulEggEvolutionIfNeeded()
	local evolutionSystem = pg.game and pg.game.soulEggEvolution

	if evolutionSystem and evolutionSystem:isInEvolution() then
		evolutionSystem:resetSoulEggSystem()
	end
end

function PetFertilityCtrl:initGesture()
	fingerGestures.Active()
	fingerGestures.EnableTwist(false)
	fingerGestures.EnablePinch(true)
end

function PetFertilityCtrl:destroyGesture()
	fingerGestures.luaOnSwipe = nil
	fingerGestures.luaOnSwipeEnd = nil

	fingerGestures.DeActive()
end

function PetFertilityCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.root.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:backBtnEvent()
		end
	end

	function self.view.btnBackUButton.luaClick()
		self:backBtnEvent()
	end

	self:initTabStateEvent()
end

function PetFertilityCtrl:initTabStateEvent()
	function self.view.panelHatchUComponent.luaTryChangePage(name, pageIdx)
		if IsNil(self.view) then
			return
		end

		local _, page = self.view.panelHatchUComponent:TryGetCurrentPage("EggSelect")
		local _, page1 = self.view.panelHatchUComponent:TryGetCurrentPage("HiveSelect")

		if page == 0 and page1 == 0 then
			self.view.root:TryChangePage("TabBox", 1)
		else
			self.view.root:TryChangePage("TabBox", 0)
		end
	end
end

function PetFertilityCtrl:onHatchNaviBarClick()
	self.petHatchComponent:openHatchPanel()
end

function PetFertilityCtrl:backBtnEvent()
	if self.info and self.info.openHatch then
		self:closePanel()
	end
end

function PetFertilityCtrl:openHatchPanel()
	self.petHatchComponent:openHatchPanel()
end

function PetFertilityCtrl:closePanel()
	if self.petHatchComponent and self.petHatchComponent:tryCollapseEggBarForGamepad() then
		return
	end

	pg.global.ui.tips:hideDropHint()
	self:_resetSoulEggEvolutionIfNeeded()
	pg.global.ui:close(UIConst.UI_ID_PET_FERTILITY)

	if not self.info.openHatch then
		pg.game.uiScene:switchOutScene(UISceneConst.PET_BALL_PREVIEW_SCENE)
	end
end

function PetFertilityCtrl:onHatchMapSlotStatusChanged(info)
	if self.petHatchComponent then
		self.petHatchComponent:onHatchMapSlotStatusChanged(info)
	end
end

function PetFertilityCtrl:getCurPreviewingPetEnt()
	return
end

function PetFertilityCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_TOPLOGO] = true

	return whiteList
end

return PetFertilityCtrl
