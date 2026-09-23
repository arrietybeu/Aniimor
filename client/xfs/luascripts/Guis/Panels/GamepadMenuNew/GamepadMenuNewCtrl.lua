-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GamepadMenuNew\\GamepadMenuNewCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local HotkeyConst = require("Const.HotkeyConst")
local Const = require("Common.Const.Const")
local AudioConst = require("Const.AudioConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local MenuWheelComponent = require("Guis.Panels.GamepadMenuNew.Component.MenuWheelComponent")
local PetWheelComponent = require("Guis.Panels.GamepadMenuNew.Component.PetWheelComponent")
local SkillWheelComponent = require("Guis.Panels.GamepadMenuNew.Component.SkillWheelComponent")
local UIConst = require("Const.UIConst")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local GamepadMenuNewCtrl = Class.LightClass("GamepadMenuNewCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ZoomingState = Const.ZoomingState
local FUNCTION_WHEEL_TITLE = {
	"TEAM_WHEEL",
	"FUNCTION_WHEEL",
	"SKILL_WHEEL"
}
local CLOSE_REASON_GAMEPAD_MENU_RELEASE = "GamepadMenuRelease"
local POST_RELEASE_SELECT_DELAY = 0.15
local DEFAULT_WHEEL_THRESHOLD = 0.15

GamepadMenuNewCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.MODIFY_PET_FORMATION] = {
		"onPetFormationUpdate",
		true
	},
	[MessageName.ON_GROUP_NAME_CHANGE] = {
		"onPetFormationUpdate",
		true
	}
}

function GamepadMenuNewCtrl:ctor()
	UICtrl.ctor(self)

	self.isOpen = false
	self.listData = {}
	self.wheelList = {}
	self.curWheelListIndex = 1
	self.curLeftStickValue = Vector2(0, 0)
	self.finishInitWheelList = false
	self.isShowPetAndSkillWheel = true
	self.postReleaseSelectTimer = nil
	self.postReleaseSelectData = nil
end

function GamepadMenuNewCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.menuWheelComponent = MenuWheelComponent.new(self)
	self.petWheelComponent = PetWheelComponent.new(self)
	self.skillWheelComponent = SkillWheelComponent.new(self)
	self.finishInitWheelList = false
end

function GamepadMenuNewCtrl:addListener()
	local zoomInBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.zoomInButton.gameObject, "zoomIn")

	zoomInBind.actionPath = "Hud/GamepadZoomIn"

	function zoomInBind.luaTrigger(inputInfo)
		self:handleGamepadZoomIn(inputInfo)
	end

	local zoomOutBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.zoomOutButton.gameObject, "zoomOut")

	zoomOutBind.actionPath = "Hud/GamepadZoomOut"

	function zoomOutBind.luaTrigger(inputInfo)
		self:handleGamepadZoomOut(inputInfo)
	end

	local switchLeftBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.switchLeftWheelButton.gameObject, "switchLeft")

	switchLeftBind.actionPath = "Hud/GamepadSwitchLeftWheel"

	function switchLeftBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Canceled" then
			self:handleSwitchWheel(true)
		end
	end

	local switchRightBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.switchRightWheelButton.gameObject, "switchRight")

	switchRightBind.actionPath = "Hud/GamepadSwitchRightWheel"

	function switchRightBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Canceled" then
			self:handleSwitchWheel(false)
		end
	end

	self.menuNavBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.releaseButton.gameObject, "release")
	self.menuNavBind.actionPath = "Hud/GamepadMenuLeftStick"
	self.menuNavBind.isVirtual = true

	function self.menuNavBind.luaTrigger(inputInfo)
		return self:handleMenuNavBind(inputInfo)
	end

	function self.view.wheelLoopList.luaRenderItem(button, index, data)
		if data.idx == 0 then
			self.petWheelComponent:initPetWheel(button)
			button:SetActive(self.isShowPetAndSkillWheel)
		elseif data.idx == 1 then
			self.menuWheelComponent:initMenuWheel(button)
		else
			self.skillWheelComponent:initSkillWheel(button)
			button:SetActive(self.isShowPetAndSkillWheel)
		end
	end
end

function GamepadMenuNewCtrl:refreshAll()
	self.petWheelComponent:refreshPet()
	self.menuWheelComponent:refreshMenuByScene()
	self.skillWheelComponent:refreshSkill()
end

function GamepadMenuNewCtrl:onPetFormationUpdate()
	if not self.petWheelComponent then
		return
	end

	self.petWheelComponent:refreshPetPrepareBattleTeamList()

	if not self.isOpen then
		return
	end

	self.petWheelComponent:refreshPet()

	if self.curWheelListIndex == 0 then
		self.petWheelComponent:refreshSelectedPetTeam()
	end
end

function GamepadMenuNewCtrl:clearPostReleaseSelect(skipRemoveTimer)
	if self.postReleaseSelectTimer and not skipRemoveTimer then
		TimerManager.removeTimer(self.postReleaseSelectTimer)
	end

	self.postReleaseSelectTimer = nil
	self.postReleaseSelectData = nil
end

function GamepadMenuNewCtrl:getActiveWheelEntry()
	if self.curWheelListIndex == 0 then
		return self.petWheelComponent.petWheels and self.petWheelComponent.petWheels[1]
	elseif self.curWheelListIndex == 1 then
		return self.menuWheelComponent.menuWheels and self.menuWheelComponent.menuWheels[1]
	elseif self.curWheelListIndex == 2 then
		return self.skillWheelComponent.skillWheels and self.skillWheelComponent.skillWheels[1]
	end
end

function GamepadMenuNewCtrl:getActiveSelectedWheelIndex()
	if (self.curWheelListIndex == 0 or self.curWheelListIndex == 2) and not self.isShowPetAndSkillWheel then
		return nil
	end

	local entry = self:getActiveWheelEntry()
	local wheel = entry and entry.wheel
	local rawIndex = wheel and wheel.wheelIndex or -1

	if not rawIndex or rawIndex < 0 then
		return nil
	end

	local selectedIndex = rawIndex

	if self.curWheelListIndex == 0 and self.petWheelComponent.selectedWheelIndex ~= nil then
		selectedIndex = self.petWheelComponent.selectedWheelIndex
	elseif self.curWheelListIndex == 1 and self.menuWheelComponent.selectedWheelIndex ~= nil then
		selectedIndex = self.menuWheelComponent.selectedWheelIndex
	elseif self.curWheelListIndex == 2 and self.skillWheelComponent.selectedWheelIndex ~= nil then
		selectedIndex = self.skillWheelComponent.selectedWheelIndex
	end

	if selectedIndex < 0 then
		return nil
	end

	return selectedIndex, wheel
end

function GamepadMenuNewCtrl:startPostReleaseSelect()
	self:clearPostReleaseSelect()

	local selectedIndex, wheel = self:getActiveSelectedWheelIndex()

	if selectedIndex == nil then
		return
	end

	self.postReleaseSelectData = {
		wheelListIndex = self.curWheelListIndex,
		selectedWheelIndex = selectedIndex,
		threshold = DEFAULT_WHEEL_THRESHOLD
	}
	self.postReleaseSelectTimer = TimerManager.addTimer(POST_RELEASE_SELECT_DELAY, function()
		self:clearPostReleaseSelect(true)
	end)
end

function GamepadMenuNewCtrl:executePostReleaseSelect()
	local data = self.postReleaseSelectData

	if not data then
		return false
	end

	self:clearPostReleaseSelect()

	local selectIndex = data.selectedWheelIndex

	if data.wheelListIndex == 0 then
		if selectIndex < self.petWheelComponent.petPrepareBattleTeamCount then
			self.petWheelComponent:refreshPetTeam(selectIndex, true)
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("WHEEL_EMPTY"))
		end

		self.petWheelComponent:_broadcastWheelIndex(-1)
	elseif data.wheelListIndex == 1 then
		self.menuWheelComponent:selectItemByScene(selectIndex + 1, true)
	elseif data.wheelListIndex == 2 then
		if selectIndex >= self.skillWheelComponent.skillGroupCount then
			pg.global.ui.tips:showTextTip(pg.getGameString("WHEEL_EMPTY"))
		end

		if not pg.me:isInCombat() then
			pg.me:switchToAbilityGroup(selectIndex + 1)
		end

		self.skillWheelComponent:_broadcastWheelIndex(-1)
	end

	return true
end

function GamepadMenuNewCtrl:handlePostReleaseStick(inputInfo)
	local data = self.postReleaseSelectData

	if not data then
		return false
	end

	local isStickRelease = false

	if inputInfo.valueVec2 then
		local threshold = data.threshold or DEFAULT_WHEEL_THRESHOLD
		local stickX = inputInfo.valueVec2.x
		local stickY = inputInfo.valueVec2.y

		isStickRelease = stickX * stickX + stickY * stickY < threshold * threshold
	else
		isStickRelease = inputInfo.phase == "Canceled"
	end

	if not isStickRelease then
		return false
	end

	self:executePostReleaseSelect()

	return true
end

function GamepadMenuNewCtrl:handleSwitchWheel(switchLeft)
	if switchLeft then
		self.curWheelListIndex = self.curWheelListIndex - 1 < 0 and 2 or self.curWheelListIndex - 1
	else
		self.curWheelListIndex = self.curWheelListIndex + 1 > 2 and 0 or self.curWheelListIndex + 1
	end

	ClientTextUtils.setText(self.view.functionWheelTitle, pg.getGameString(FUNCTION_WHEEL_TITLE[self.curWheelListIndex + 1]))
	self.view.wheelLoopList:GoNext(switchLeft and -1 or 1)
	self:setWheelOffset(self.curLeftStickValue)
	self:refreshAll()
end

function GamepadMenuNewCtrl:handleMenuNavBind(inputInfo)
	if self:handlePostReleaseStick(inputInfo) then
		return true
	end

	if self._visible then
		if inputInfo.phase == "Performed" then
			self:setWheelOffset(inputInfo.valueVec2)

			self.curLeftStickValue = inputInfo.valueVec2

			self:refreshAll()
		else
			self:setWheelOffset(Vector2(0, 0))

			self.curLeftStickValue = Vector2(0, 0)

			self:refreshAll()
		end
	end

	return false
end

function GamepadMenuNewCtrl:setWheelOffset(offset)
	if self.curWheelListIndex == 0 then
		self.petWheelComponent:setWheelOffset(offset)
	elseif self.curWheelListIndex == 1 then
		self.menuWheelComponent:setWheelOffset(offset)
	else
		self.skillWheelComponent:setWheelOffset(offset)
	end
end

function GamepadMenuNewCtrl:onOpen(info)
	self:checkShowPetAndSkillWheel()
	self:setMenuOpen(self.isOpen)
end

function GamepadMenuNewCtrl:checkShowPetAndSkillWheel()
	local showWheel = true
	local photoOpen = pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO)

	if pg.space and pg.space:isRogueEnv() then
		showWheel = false
	end

	if photoOpen then
		showWheel = false
	end

	self.view.switchLeftWheelButton:SetActive(showWheel)
	self.view.switchRightWheelButton:SetActive(showWheel)
	self.view.zoomInButton:SetActive(not photoOpen)
	self.view.zoomOutButton:SetActive(not photoOpen)

	self.isShowPetAndSkillWheel = showWheel
end

function GamepadMenuNewCtrl:onHide()
	pg.game.camera:cancelZooming()

	self.zoomingState = ZoomingState.None
end

function GamepadMenuNewCtrl:handleGamepadZoomIn(inputInfo)
	if inputInfo.phase == "Performed" then
		pg.game.camera:startZoomingIn()

		self.zoomingState = ZoomingState.ZoomingIn
	elseif inputInfo.phase == "Canceled" and self.zoomingState == ZoomingState.ZoomingIn then
		pg.game.camera:cancelZooming()

		self.zoomingState = ZoomingState.None
	end
end

function GamepadMenuNewCtrl:handleGamepadZoomOut(inputInfo)
	if inputInfo.phase == "Performed" then
		pg.game.camera:startZoomingOut()

		self.zoomingState = ZoomingState.ZoomingOut
	elseif inputInfo.phase == "Canceled" and self.zoomingState == ZoomingState.ZoomingOut then
		pg.game.camera:cancelZooming()

		self.zoomingState = ZoomingState.None
	end
end

function GamepadMenuNewCtrl:getExcludeResetInputActions()
	return {
		"Hud/GamepadMenu"
	}
end

function GamepadMenuNewCtrl:setMenuOpen(isOpen, closeReason)
	self.isOpen = isOpen

	if not self.view then
		return
	end

	if isOpen then
		self:clearPostReleaseSelect()

		self.finishInitWheelList = true

		self:show()
		self.view.widget:TryChangePage("state", 1)
		pg.game.audio:triggerEvent(AudioConst.EVENT_GAMEPAD_MENU_OPEN)
		self.petWheelComponent:clearWheels()
		self.menuWheelComponent:clearWheels()
		self.skillWheelComponent:clearWheels()
		self:checkShowPetAndSkillWheel()
		self:initMenuItems()

		if pg.global.ui.hudV2.view then
			pg.global.ui.hudV2.view.rootComponent:TryChangePage("ExplorePop", 1)
		end

		if pg.global.ui.hudV2 and pg.global.ui.hudV2.view then
			pg.global.ui.hudV2:setUIHide("GamepadMenu", true)
		end

		pg.global.ui.interact:hide()
		pg.global.ui.tips:hideAllAreasWithFlag(TipAreaConst.UITipAreaFlag.AreaFlag_FullScreen)
		self:refreshAll()

		self.curWheelListIndex = 1

		ClientTextUtils.setText(self.view.functionWheelTitle, pg.getGameString(FUNCTION_WHEEL_TITLE[self.curWheelListIndex + 1]))
		self.view.wheelLoopList:GoToIndex(self.curWheelListIndex)
	else
		if closeReason == CLOSE_REASON_GAMEPAD_MENU_RELEASE then
			self:startPostReleaseSelect()
		else
			self:clearPostReleaseSelect()
		end

		self.view.widget:TryChangePage("state", 0)
		self:hide()

		if pg.global.ui.hudV2.view then
			pg.global.ui.hudV2.view.rootComponent:TryChangePage("ExplorePop", 0)
		end

		pg.global.ui.interact:show()
		pg.global.ui.tips:showAllAreasWithFlag(TipAreaConst.UITipAreaFlag.AreaFlag_FullScreen)

		if pg.global.ui.hudV2 and pg.global.ui.hudV2.view then
			pg.global.ui.hudV2:setUIHide("GamepadMenu", false)
		end

		self.curWheelListIndex = -1
		self.curLeftStickValue = Vector2(0, 0)

		if self.finishInitWheelList then
			self.petWheelComponent:resetWheel()
			self.menuWheelComponent:resetWheel()
			self.skillWheelComponent:resetWheel()
		end
	end
end

function GamepadMenuNewCtrl:initMenuItems()
	self.wheelList = {
		{
			tIndex = 0,
			idx = 0
		},
		{
			tIndex = 1,
			idx = 1
		},
		{
			tIndex = 0,
			idx = 2
		}
	}

	self.view.wheelLoopList:SetList(self.wheelList)

	self.wheelList = self.view.wheelLoopList:GetAllChildrenButtons()
end

function GamepadMenuNewCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function GamepadMenuNewCtrl:onInputDeviceChanged(deviceType)
	self:clearPostReleaseSelect()

	if not self.isOpen then
		return
	end

	self:setMenuOpen(false)
end

function GamepadMenuNewCtrl:closePanel()
	self:setMenuOpen(false)
end

function GamepadMenuNewCtrl:onDestroy()
	self:clearPostReleaseSelect()
	UICtrl.onDestroy(self)
end

return GamepadMenuNewCtrl
