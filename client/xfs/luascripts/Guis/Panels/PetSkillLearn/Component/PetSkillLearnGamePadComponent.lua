-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSkillLearn\\Component\\PetSkillLearnGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetSkillLearnGamePadComponent = Class.LightClass("PetSkillLearnGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function PetSkillLearnGamePadComponent:findObjects()
	self.root = self.view.root
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
	self:initEmptyArea()
end

function PetSkillLearnGamePadComponent:initView()
	self.navigation:addConsoleEvent(self.navigation:initCommonLeftStickMoveData(self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("A", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("B", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("X", self.root.gameObject))
end

function PetSkillLearnGamePadComponent:initAreas()
	self.navigation.AREAS = {
		EMPTY_AREA = 2,
		LIST_AREA = 1
	}
	self.navigation.LIST_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.LIST_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.LIST_AREA,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.LIST_AREA,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.LIST_AREA
	}
	self.navigation.EMPTY_AREA = {}
	self.navigation.AREA_TABLES = {
		self.navigation.LIST_AREA,
		self.navigation.EMPTY_AREA
	}
end

function PetSkillLearnGamePadComponent:deSelectLists()
	local btns = self.view.listUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i]:TryChangePage("select", 0)
		btns[i]:ClosePopup()
	end
end

function PetSkillLearnGamePadComponent:deSelectOthers()
	return
end

function PetSkillLearnGamePadComponent:deSelectAll()
	self:deSelectLists()
	self:deSelectOthers()
end

function PetSkillLearnGamePadComponent:initEmptyArea()
	local t = {}

	t[1] = {}
	t[1][1] = {}
	t[1][1].Focus = function(x1, y1)
		self.navigation:baseFocus(t, x1, y1, self.view.keyListUList)
		self:deSelectAll()
	end
	t[1][1].Fun3 = function(x1, y1)
		self.view.btnCloseUButton.luaClick()
	end
	t[1][1].Fun3Name = pg.getGameString("BACK_TO_PRE")

	self.navigation:initAreaTableSlots(self.navigation.EMPTY_AREA, t)
end

function PetSkillLearnGamePadComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		local areaId

		if self.ctrl.isEmpty then
			areaId = self.navigation.AREAS.EMPTY_AREA
		else
			areaId = self.navigation.AREAS.LIST_AREA
		end

		self.navigation:specificSet(areaId, 1, 1)
		self.navigation:reFocus()
	else
		self:deSelectAll()
	end
end

function PetSkillLearnGamePadComponent:onDestroy()
	self.root = nil
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return PetSkillLearnGamePadComponent
