-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ReplaceSkill\\Component\\ReplaceSkillGamePadComponent.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local UIComponent = require("Guis.Helper.UIComponent")
local ReplaceSkillGamePadComponent = Class.LightClass("ReplaceSkillGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")
local LuaUIUtils = require("Utils.LuaUIUtils")

function ReplaceSkillGamePadComponent:findObjects()
	self.root = self.view.root
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function ReplaceSkillGamePadComponent:initView()
	self.navigation:addConsoleEvent(self.navigation:initCommonLeftStickMoveData(self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("X", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("B", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("Y", self.root.gameObject))
	self.navigation:addConsoleEvent(self:initKeyAData(self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("LSD", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("RSD", self.root.gameObject))
end

function ReplaceSkillGamePadComponent:initAreas()
	self.navigation.AREAS = {
		EQUIP_SKILL_AREA = 1,
		UNLOCK_SKILL_AREA = 2
	}
	self.navigation.EQUIP_SKILL_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.UNLOCK_SKILL_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.UNLOCK_SKILL_AREA,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.EQUIP_SKILL_AREA,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.EQUIP_SKILL_AREA
	}
	self.navigation.UNLOCK_SKILL_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.EQUIP_SKILL_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.EQUIP_SKILL_AREA,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.UNLOCK_SKILL_AREA,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.UNLOCK_SKILL_AREA
	}
	self.navigation.AREA_TABLES = {
		self.navigation.EQUIP_SKILL_AREA,
		self.navigation.UNLOCK_SKILL_AREA
	}
end

function ReplaceSkillGamePadComponent:initKeyAData(rootGameObject)
	return {
		isVirtual = true,
		parent = rootGameObject,
		id = "fun" .. self.navigation.FUNCTION_INDEX.A,
		actionPath = "Hud/PetManagementButtonFun" .. self.navigation.FUNCTION_INDEX.A,
		event = function(inputInfo)
			if inputInfo.phase == "Performed" then
				self.navigation.longPressMayPerformed = true
				self.navigation.longPressTimer = TimerManager.addTimer(self.navigation.longPressDelay, function()
					self.navigation.longPressStart = true

					self:clonePrefab()
				end)
			elseif inputInfo.phase == "Canceled" then
				if self.navigation.longPressStart == true then
					self:destroyClonePrefab()

					self.navigation.longPressStart = nil
				else
					TimerManager.removeTimer(self.navigation.longPressTimer)

					local curSlot = self.navigation:getCurSlot()

					if curSlot ~= nil and curSlot.Fun4 ~= nil then
						curSlot.Fun4(self.navigation.cursorIndex.x, self.navigation.cursorIndex.y)
					end
				end

				self.navigation.longPressMayPerformed = false
			end
		end
	}
end

function ReplaceSkillGamePadComponent:clonePrefab()
	local curSlot = self.navigation:getCurSlot()

	if curSlot ~= nil and curSlot.ValidSlot == true then
		self.navigation.selectedObj = nil

		if self.navigation.cursorArea == self.navigation.AREAS.EQUIP_SKILL_AREA then
			self.navigation.selectedObj = self.ctrl:getEquipListItemByCursorIndex(self.navigation.cursorIndex.x, self.navigation.cursorIndex.y)
		elseif self.navigation.cursorArea == self.navigation.AREAS.UNLOCK_SKILL_AREA then
			self.navigation.selectedObj = self.ctrl:getUnlockListItemByCursorIndex(self.navigation.cursorIndex.x, self.navigation.cursorIndex.y)
		end

		if self.navigation.selectedObj == nil then
			return
		end

		local oriButton = self.navigation.selectedObj:GetComponent("UButton")

		self.navigation.prefabCloneLoader = ResLoader.new(pg.global.uiMgr.uiRootCanvasRt.gameObject.transform)

		self.navigation.prefabCloneLoader:instantiateAsync(self.navigation.selectedObj, function(gameObj, userData)
			gameObj.transform.anchorMin = Vector2(0.5, 0.5)
			gameObj.transform.anchorMax = Vector2(0.5, 0.5)
			gameObj.transform.pivot = Vector2(0.5, 0.5)
			gameObj.transform.position = self.navigation.selectedObj.transform.position

			local cloneButton = gameObj:GetComponent("UButton")

			if self.navigation.cursorArea == self.navigation.AREAS.EQUIP_SKILL_AREA then
				self.ctrl:equipSkillGamePadBeginDrag(oriButton, oriButton.dataFromUList, cloneButton)
				gameObj.transform:Find("EquipmentRayBox").gameObject:SetActiveEx(false)
			elseif self.navigation.cursorArea == self.navigation.AREAS.UNLOCK_SKILL_AREA then
				self.ctrl:unlockSkillGamePadBeginDrag(oriButton, oriButton.dataFromUList, cloneButton)
				gameObj.transform:Find("RayBox").gameObject:SetActiveEx(false)
			end
		end, self.navigation.selectedObj.transform.position, Quaternion.Euler(0, 0, 0))
	end
end

function ReplaceSkillGamePadComponent:destroyClonePrefab()
	if self.navigation.prefabCloneLoader then
		if self.navigation.selectedObj == nil then
			return
		end

		local oriButton = self.navigation.selectedObj:GetComponent("UButton")

		if oriButton.luaEndDrag ~= nil then
			oriButton.luaEndDrag(self.navigation.dropWidget, self.navigation.dropRayBox)
		end

		self.navigation.prefabCloneLoader:clearInstantiate()

		self.navigation.prefabCloneLoader = nil

		self.navigation:laterFramesFocus(nil, 1)
	end
end

function ReplaceSkillGamePadComponent:deSelectLists()
	return
end

function ReplaceSkillGamePadComponent:deSelectOthers()
	return
end

function ReplaceSkillGamePadComponent:deSelectAll()
	self:deSelectLists()
	self:deSelectOthers()
end

function ReplaceSkillGamePadComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self.navigation:specificSet(self.navigation.AREAS.EQUIP_SKILL_AREA, 1, 1)
		self.navigation:laterFramesFocus(nil, 1)
	else
		self.ctrl:deSelectAllGamePadFocus()
	end

	self.ctrl:resetDragState()
end

function ReplaceSkillGamePadComponent:onDestroy()
	self.root = nil
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return ReplaceSkillGamePadComponent
