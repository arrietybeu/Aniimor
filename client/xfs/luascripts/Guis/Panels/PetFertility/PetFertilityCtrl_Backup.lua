-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertility\\PetFertilityCtrl_Backup.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local PetBallComponent = require("Guis.Panels.PetFertility.Component.PetBallComponent")
local PetBreedComponent = require("Guis.Panels.PetFertility.Component.PetBreedComponent")
local PetHatchComponent = require("Guis.Panels.PetFertility.Component.PetHatchComponent")
local PetBreedConfirmComponent = require("Guis.Panels.PetFertility.Component.PetBreedConfirmComponent")
local PetBallEntityComponent = require("Guis.Panels.PetFertility.Component.PetBallEntityComponent")
local PetFeedComponent = require("Guis.Panels.PetFertility.Component.PetFeedComponent")
local BreedSceneComponent = require("Guis.Panels.PetFertility.Component.BreedSceneComponent")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local PetFertilityCtrl = Class.LightClass("PetFertilityCtrl", UICtrl)

PetFertilityCtrl.messages = {
	[MessageName.PET_FAVORITE_CHANGE] = {
		"onPetFavoriteChanged",
		true
	},
	[MessageName.PET_FAVORITE_TYPE_CHANGE] = {
		"onPetFavoriteTypeChanged",
		true
	},
	[MessageName.PET_BALL_MAP_MAIN_PET_CHANGED] = {
		"onPetBallPetChange",
		true
	},
	[MessageName.PET_CUSTOM_NAME_CHANGED] = {
		"onPetCustomNameChanged",
		true
	},
	[MessageName.PET_BREED_COUNT_CHANGED] = {
		"onPetBreedCountChanged",
		true
	},
	[MessageName.PET_BALL_MAP_HATCH_SLOT_STATUS_CHANGED] = {
		"onHatchMapSlotStatusChanged",
		true
	},
	[MessageName.PET_BALL_MAP_EXP_ACTION_STATUS] = {
		"onPetBallExpActionStatusChanged",
		true
	},
	[MessageName.PET_LEVEL_CHANGED] = {
		"onPetLevelChanged",
		true
	},
	[MessageName.PET_ADD_EXP] = {
		"onPetAddExp",
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
	return
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
		self.petBallComponent = PetBallComponent.new(self, self.view.ballComponent)
		self.petBreedComponent = PetBreedComponent.new(self, self.view.breedComponent)
		self.petHatchComponent = PetHatchComponent.new(self, self.view.panelHatchUComponent)
		self.petBreedConfirmComponent = PetBreedConfirmComponent.new(self, self.view.breedConfirmComponent)
		self.petFeedComponent = PetFeedComponent.new(self, self.view.petlFeedUComponent)
	end

	local isPetHatchOpen = ClientActivityUtils.isPetHatchActivityOpen()

	if isPetHatchOpen then
		pg.global.ui.tips:showDropHint("PET_HATCH_ACTIVITY_1", self.view.root.position)
	end
end

function PetFertilityCtrl:additionOperation()
	if self.info and self.info.openHatch then
		self:openHatchPanel()

		self.view.tabBoxUWidget.renderOpacity = 0
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

function PetFertilityCtrl:beginAni()
	self.petBallComponent.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.Begin, nil, nil, nil, nil)
end

function PetFertilityCtrl:initGesture()
	fingerGestures.Active()
	fingerGestures.EnableTwist(false)
	fingerGestures.EnablePinch(true)

	function fingerGestures.luaOnSwipe(gesture)
		self:gestureEventSwipe(gesture)
	end

	function fingerGestures.luaOnSwipeEnd(gesture)
		self:gestureEventSwipeEnd(gesture)
	end

	function fingerGestures.luaOnPinchIn(gesture)
		self:gestureEventPinch(-1)
	end

	function fingerGestures.luaOnPinchOut(gesture)
		self:gestureEventPinch(1)
	end
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

	function self.view.btnPetBallUButton.luaClick()
		self:onPetBallNaviBarClick()
	end

	function self.view.btnBreedUButton.luaClick()
		self:onBreedNaviBarClick()
	end

	function self.view.btnHatchUButton.luaClick()
		self:onHatchNaviBarClick()
	end

	function self.view.btnSkipUButton.luaClick()
		self.breedSceneComponent:finish()
	end

	self:initTabStateEvent()
end

function PetFertilityCtrl:initTabStateEvent()
	function self.view.ballComponent.luaTryChangePage(name, pageIdx)
		if name == "BallState" and pageIdx == 1 then
			self.view.root:TryChangePage("TabBox", 1)
		else
			self.view.root:TryChangePage("TabBox", 0)
		end
	end

	function self.view.breedComponent.luaTryChangePage(name, pageIdx)
		if IsNil(self.view) then
			return
		end

		if name == "FertilityState" and pageIdx == 0 then
			self.view.root:TryChangePage("TabBox", 1)
		else
			self.view.root:TryChangePage("TabBox", 0)
		end
	end

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

	function self.view.root.luaTryChangePage(name, pageIdx)
		if IsNil(self.view) then
			return
		end

		local _, page = self.view.ballComponent:TryGetCurrentPage("BallState")
		local _, page1 = self.view.breedComponent:TryGetCurrentPage("FertilityState")
		local _, page2 = self.view.panelHatchUComponent:TryGetCurrentPage("EggSelect")
		local _, page3 = self.view.panelHatchUComponent:TryGetCurrentPage("HiveSelect")

		if name == "TabState" and pageIdx == 1 and page1 == 0 then
			self.view.root:TryChangePage("TabBox", 1)
		elseif name == "TabState" and pageIdx == 2 and page2 == 0 and page3 == 0 then
			self.view.root:TryChangePage("TabBox", 1)
		elseif name == "TabState" and pageIdx == 0 and page == 1 then
			self.view.root:TryChangePage("TabBox", 1)
		elseif name == "TabState" then
			self.view.root:TryChangePage("TabBox", 0)
		end
	end
end

function PetFertilityCtrl:onPetBallNaviBarClick()
	local _, page = self.view.root:TryGetCurrentPage("TabState")

	if page == 0 then
		return
	elseif page == 1 then
		self.petBallComponent.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusFYReverse, self.model.TIMELINE_INDEX.FocusGJ, nil, nil, nil)
	else
		self.petBallComponent.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusFHReverse, self.model.TIMELINE_INDEX.FocusGJ, nil, nil, nil)
	end

	self.petBallComponent.root:TryChangePage("BallState", 1)
end

function PetFertilityCtrl:onBreedNaviBarClick()
	local _, page = self.view.root:TryGetCurrentPage("TabState")

	if page == 0 then
		self.petBallComponent.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusGJReverse, self.model.TIMELINE_INDEX.FocusFY, nil, nil, nil)
	elseif page == 1 then
		return
	else
		self.petBallComponent.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusFHReverse, self.model.TIMELINE_INDEX.FocusFY, nil, nil, nil)
	end

	self.petBreedComponent:openBreedPanel()
end

function PetFertilityCtrl:onHatchNaviBarClick()
	local _, page = self.view.root:TryGetCurrentPage("TabState")

	if page == 0 then
		self.petBallComponent.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusGJReverse, self.model.TIMELINE_INDEX.FocusFH, nil, nil, nil)
	elseif page == 1 then
		self.petBallComponent.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusFYReverse, self.model.TIMELINE_INDEX.FocusFH, nil, nil, nil)
	else
		return
	end

	self.petHatchComponent:openHatchPanel()
end

function PetFertilityCtrl:backBtnEvent()
	if self.info and self.info.openHatch then
		self:closePanel()

		return
	end

	local _, page = self.view.root:TryGetCurrentPage("TabState")
	local _, breedPage = self.view.breedComponent:TryGetCurrentPage("FertilityState")
	local _, ballPage = self.view.ballComponent:TryGetCurrentPage("BallState")

	if page == 0 then
		if ballPage == 1 then
			self.petBallComponent:backToSelectPage("ball")
		elseif ballPage == 2 then
			self.petBallComponent:backToPage1()
		elseif ballPage == 3 then
			self.petBallComponent:managementBackToPreviewPage()
			self:leavePetSelection()
		elseif ballPage == 4 then
			self.petBallComponent:managementBackToPreviewPage()
			self.petFeedComponent:onHidePetFeed()
		else
			self:closePanel()
		end
	elseif page == 1 then
		if breedPage == 0 then
			self.petBallComponent:backToSelectPage("breed")
		elseif breedPage == 1 then
			self.view.breedComponent:TryChangePage("FertilityState", 0)
		else
			self.view.breedComponent:TryChangePage("FertilityState", 1)
		end
	else
		self.petBallComponent:backToSelectPage("hatch")
	end
end

function PetFertilityCtrl:openBreedPanel()
	self.view.root:TryChangePage("TabState", 1)
	self.petBreedComponent:openBreedPanel()
end

function PetFertilityCtrl:openHatchPanel()
	self.view.root:TryChangePage("TabState", 2)
	self.petHatchComponent:openHatchPanel()
end

function PetFertilityCtrl:gestureEventPinch(val)
	local _, page = self.view.root:TryGetCurrentPage("TabState")
	local _, ballPage = self.view.ballComponent:TryGetCurrentPage("BallState")

	if page == 0 and ballPage == 1 then
		self.petBallComponent:scalePetBallCamera(val, true)
	end
end

function PetFertilityCtrl:gestureEventSwipe(gesture)
	local _, page = self.view.root:TryGetCurrentPage("TabState")
	local _, breedPage = self.view.breedComponent:TryGetCurrentPage("FertilityState")
	local _, ballPage = self.view.ballComponent:TryGetCurrentPage("BallState")

	if page == 0 then
		if ballPage == 1 then
			self.petBallComponent:rotatePetBall(gesture)
		elseif ballPage == 2 then
			-- block empty
		end
	elseif page ~= 1 or breedPage == 0 then
		-- block empty
	elseif breedPage == 1 then
		-- block empty
	end
end

function PetFertilityCtrl:gestureEventSwipeEnd(gesture)
	local _, page = self.view.root:TryGetCurrentPage("TabState")
	local _, breedPage = self.view.breedComponent:TryGetCurrentPage("FertilityState")
	local _, ballPage = self.view.ballComponent:TryGetCurrentPage("BallState")

	if page == 0 then
		if ballPage == 1 then
			-- block empty
		elseif ballPage == 2 then
			self.petBallComponent:switchPetBalls(gesture.swipeVector[1] < 0)
		end
	elseif page ~= 1 or breedPage == 0 then
		-- block empty
	elseif breedPage == 1 then
		-- block empty
	end
end

function PetFertilityCtrl:closePanel()
	if self.petHatchComponent and self.petHatchComponent:tryCollapseEggBarForGamepad() then
		return
	end

	self:_resetSoulEggEvolutionIfNeeded()
	pg.global.ui:close(UIConst.UI_ID_PET_FERTILITY)

	if not self.info.openHatch then
		pg.game.uiScene:switchOutScene(UISceneConst.PET_BALL_PREVIEW_SCENE)
	end
end

function PetFertilityCtrl:openBreedConfirmPage(featureTable, breedTalentTable, malePetId, femalePetId)
	self.petBreedConfirmComponent:openConfirmPage(featureTable, breedTalentTable, malePetId, femalePetId)
end

function PetFertilityCtrl:onPetFavoriteChanged(info)
	local petInfo = self.model:getPetInfo(info[1])

	if self.petBreedComponent then
		self.petBreedComponent:onPetFavoriteChanged(petInfo)
	end

	if self.petBallComponent then
		self.petBallComponent:onPetFavoriteChanged(petInfo)
	end
end

function PetFertilityCtrl:onPetFavoriteTypeChanged(info)
	local petInfo = self.model:getPetInfo(info[1])

	if self.petBreedComponent then
		self.petBreedComponent:onPetFavoriteChanged(petInfo)
	end

	if self.petBallComponent then
		self.petBallComponent:onPetFavoriteChanged(petInfo)
	end
end

function PetFertilityCtrl:onPetBallPetChange(info)
	if self.petBallComponent then
		self.petBallComponent:onPetBallPetChanged(info)
	end
end

function PetFertilityCtrl:onPetCustomNameChanged(info)
	local petInfo = self.model:getPetInfo(info.petId)

	if self.petBallComponent then
		self.petBallComponent:onPetCustomNameChanged(petInfo)
	end
end

function PetFertilityCtrl:onPetBreedCountChanged(info)
	local petId = info.petId
	local breedCount = info.breedCount
	local petInfo = self.model:getPetInfo(petId)

	if self.petBreedComponent then
		self.petBreedComponent:onPetBreedRemainsChanged(petInfo)
	end
end

function PetFertilityCtrl:onHatchMapSlotStatusChanged(info)
	if self.petHatchComponent then
		self.petHatchComponent:onHatchMapSlotStatusChanged(info)
	end
end

function PetFertilityCtrl:onPetBallExpActionStatusChanged(info)
	if self.petBallComponent then
		self.petBallComponent:onPetBallExpActionStatusChanged(info)
	end

	if self.petFeedComponent then
		self.petFeedComponent:onPetBallExpActionStatusChanged(info)
	end
end

function PetFertilityCtrl:onPetLevelChanged(info)
	if self.petBallComponent then
		self.petBallComponent:onPetLevelChanged(info)
	end

	if self.petFeedComponent then
		self.petFeedComponent:onPetLevelChanged(info)
	end
end

function PetFertilityCtrl:onPetAddExp(info)
	if self.petBallComponent then
		self.petBallComponent:onPetAddExp(info)
	end

	if self.petFeedComponent then
		self.petFeedComponent:onPetAddExp(info)
	end
end

function PetFertilityCtrl:showAllUI(flag)
	self.view.root:TryChangePage("hideAll", not flag and 1 or 0)
end

function PetFertilityCtrl:resetBreedChoose()
	self.petBreedComponent.currentMalePetId = nil
	self.petBreedComponent.currentMaleEthnicGroup = nil

	self.petBreedComponent:onCurrentMalePetIdChanged()

	self.petBreedComponent.currentFemalePetId = nil
	self.petBreedComponent.currentFemaleEthnicGroup = nil

	self.petBreedComponent:onCurrentFemalePetIdChanged()
end

function PetFertilityCtrl:getCurPreviewingPetEnt()
	if self.petBallEntityComponent then
		return self.petBallEntityComponent.pets[self.petBallEntityComponent.curPreviewingPetEntId]
	end

	return nil
end

function PetFertilityCtrl:displayPetBallBreed(enable, parmonA, parmonB, cb)
	if enable then
		if self.breedSceneComponent.loaded then
			return
		end

		self.breedSceneComponent:load(parmonA, parmonB, cb)
	else
		if not self.breedSceneComponent.loaded then
			return
		end

		self.breedSceneComponent:reset()

		if cb then
			cb()
		end
	end
end

function PetFertilityCtrl:refreshSelectedPetEnt(petId)
	if self.petBallEntityComponent then
		return self.petBallEntityComponent:refreshSelectedPetEnt(petId)
	end
end

function PetFertilityCtrl:leavePetSelection()
	if self.petBallEntityComponent then
		return self.petBallEntityComponent:leavePetSelection()
	end
end

function PetFertilityCtrl:refreshBreedSceneSelectedPetEnt(petId, isMale, allClear)
	if self.petBallEntityComponent then
		return self.petBallEntityComponent:refreshBreedSceneSelectedPetEnt(petId, isMale, allClear)
	end
end

function PetFertilityCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_TOPLOGO] = true

	return whiteList
end

return PetFertilityCtrl
