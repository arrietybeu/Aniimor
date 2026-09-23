-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerEnhance\\Component\\PlayerGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PlayerGamePadComponent = Class.LightClass("PlayerGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")
local UIConst = require("Const.UIConst")

function PlayerGamePadComponent:findObjects()
	self.root = self.view.objectReference
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function PlayerGamePadComponent:initView()
	self.navigation:addConsoleEvent(self.navigation:initCommonLeftStickMoveData(self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("A", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("B", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("X", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("Y", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("LS", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("RS", self.root.gameObject))
end

function PlayerGamePadComponent:initAreas()
	self.navigation.AREAS = {
		MODE_REWARD_DETAIL = 11,
		MODE_REWARD_PAGE = 10,
		MODE_SKILL_EQUIP_PAGE2 = 9,
		MODE_SKILL_EQUIP_PAGE1 = 8,
		MODE_SKILL_TREE_PAGE3 = 7,
		MODE_SKILL_TREE_PAGE2 = 6,
		MODE_SKILL_TREE_PAGE1 = 5,
		MODE_PLAYER_SKILL = 4,
		MODE_PLAYER_EQUIP = 3,
		MODE_PLAYER_REWARD = 2,
		MODE_PLAYER_EXE = 1
	}
	self.navigation.MODE_PLAYER_EXE = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_PLAYER_SKILL,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_PLAYER_REWARD,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.MODE_PLAYER_SKILL,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.MODE_PLAYER_REWARD
	}
	self.navigation.MODE_PLAYER_REWARD = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_PLAYER_EXE,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_PLAYER_EQUIP,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.MODE_PLAYER_EXE,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.MODE_PLAYER_EQUIP
	}
	self.navigation.MODE_PLAYER_EQUIP = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_PLAYER_REWARD,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_PLAYER_SKILL,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.MODE_PLAYER_REWARD,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.MODE_PLAYER_SKILL
	}
	self.navigation.MODE_PLAYER_SKILL = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_PLAYER_EQUIP,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_PLAYER_EXE,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.MODE_PLAYER_EQUIP,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.MODE_PLAYER_EXE
	}
	self.treePageCacheArea = nil
	self.treePageCacheIndex = nil
	self.navigation.MODE_SKILL_TREE_PAGE1 = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_SKILL_TREE_PAGE3,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_SKILL_TREE_PAGE2,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.MODE_SKILL_TREE_PAGE1,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.MODE_SKILL_TREE_PAGE1,
		matchType = self.navigation.MATCH_MODE.MATCH_DIRECTION,
		EnterAreaAction = function(slot)
			self.treePageCacheArea = self.navigation.AREAS.MODE_SKILL_TREE_PAGE1
		end,
		ExitAreaAction = function(slot)
			self.treePageCacheArea = nil
		end
	}
	self.navigation.MODE_SKILL_TREE_PAGE2 = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_SKILL_TREE_PAGE1,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_SKILL_TREE_PAGE3,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.MODE_SKILL_TREE_PAGE2,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.MODE_SKILL_TREE_PAGE2,
		matchType = self.navigation.MATCH_MODE.MATCH_DIRECTION,
		EnterAreaAction = function(slot)
			self.treePageCacheArea = self.navigation.AREAS.MODE_SKILL_TREE_PAGE2
		end,
		ExitAreaAction = function(slot)
			self.treePageCacheArea = nil
		end
	}
	self.navigation.MODE_SKILL_TREE_PAGE3 = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_SKILL_TREE_PAGE2,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_SKILL_TREE_PAGE1,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.MODE_SKILL_TREE_PAGE3,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.MODE_SKILL_TREE_PAGE3,
		matchType = self.navigation.MATCH_MODE.MATCH_DIRECTION,
		EnterAreaAction = function(slot)
			self.treePageCacheArea = self.navigation.AREAS.MODE_SKILL_TREE_PAGE3
		end,
		ExitAreaAction = function(slot)
			self.treePageCacheArea = nil
		end
	}
	self.navigation.MODE_SKILL_EQUIP_PAGE1 = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_SKILL_EQUIP_PAGE2,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_SKILL_EQUIP_PAGE2
	}
	self.navigation.MODE_SKILL_EQUIP_PAGE2 = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_SKILL_EQUIP_PAGE1,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_SKILL_EQUIP_PAGE1
	}
	self.navigation.MODE_REWARD_PAGE = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_REWARD_PAGE,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_REWARD_PAGE
	}
	self.navigation.MODE_REWARD_DETAIL = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_REWARD_DETAIL,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_REWARD_DETAIL
	}
	self.navigation.AREA_TABLES = {
		self.navigation.MODE_PLAYER_EXE,
		self.navigation.MODE_PLAYER_REWARD,
		self.navigation.MODE_PLAYER_EQUIP,
		self.navigation.MODE_PLAYER_SKILL,
		self.navigation.MODE_SKILL_TREE_PAGE1,
		self.navigation.MODE_SKILL_TREE_PAGE2,
		self.navigation.MODE_SKILL_TREE_PAGE3,
		self.navigation.MODE_SKILL_EQUIP_PAGE1,
		self.navigation.MODE_SKILL_EQUIP_PAGE2,
		self.navigation.MODE_REWARD_PAGE,
		self.navigation.MODE_REWARD_DETAIL
	}
end

function PlayerGamePadComponent:bindStaticAreaSupplement()
	local t = {}

	for i, v in ipairs(self.view.tipBtnList) do
		t[i] = {}
		t[i][1] = {
			Focus = function(x, y)
				v:TryChangePage("GamePadFocus", 1)
				self.navigation:baseFocus(t, x, y, self.view.keyList)
			end,
			DisFocus = function(x, y)
				v:TryChangePage("GamePadFocus", 0)
				v:ClosePopup()
			end,
			Fun3 = function(x, y)
				self.ctrl:dismiss()
			end,
			Fun3Name = pg.getGameString("CHARACTER_HOME_CANCEL"),
			Fun4 = function(x, y)
				if v.isTooltipOpen then
					v:ClosePopup()

					v.isSelected = true
				else
					v:OnClickSimulate()
				end
			end,
			Fun4Name = pg.getGameString("CHARACTER_HOME_DETAIL")
		}
	end

	self.navigation:initAreaTableSlots(self.navigation.MODE_PLAYER_EXE, t)

	local t1 = self:initSingleBtnAreaSupplement(self.view.btnAssembly)

	self.navigation:initAreaTableSlots(self.navigation.MODE_PLAYER_EQUIP, t1)

	local t2 = self:initSingleBtnAreaSupplement(self.view.btnSkills)

	self.navigation:initAreaTableSlots(self.navigation.MODE_PLAYER_SKILL, t2)
end

function PlayerGamePadComponent:initSingleBtnAreaSupplement(btn)
	local t = {
		{
			{}
		}
	}

	t[1][1].Focus = function(x, y)
		btn:TryChangePage("GamePadFocus", 1)
		self.navigation:baseFocus(t, x, y, self.view.keyList)
	end
	t[1][1].DisFocus = function(x, y)
		btn:TryChangePage("GamePadFocus", 0)
	end
	t[1][1].Fun3 = function(x, y)
		self.ctrl:dismiss()
	end
	t[1][1].Fun3Name = pg.getGameString("CHARACTER_SKILL_CANCEL")
	t[1][1].Fun4 = function(x, y)
		btn.luaClick()
	end
	t[1][1].Fun4Name = pg.getGameString("CHARACTER_SKILL_GO")

	return t
end

function PlayerGamePadComponent:bind_RewardArea(xBtnList)
	local btnList = xBtnList:GetAllButtons()

	if btnList.Length == 0 then
		return
	end

	local t = {
		{}
	}
	local keys = t[1]

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		i = i + 1
		keys[i] = {
			Focus = function(x, y)
				v:TryChangePage("GamePadFocus", 1)
				self.navigation:baseFocus(t, x, y, self.view.keyList)
			end,
			DisFocus = function(x, y)
				v:TryChangePage("GamePadFocus", 0)
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
			end
		}
		keys[i].Fun1 = function(x, y)
			self.ctrl:switchModelTrans(self.model.MODEL_STATE.REWARD_PAGE)
		end
		keys[i].Fun1IsImportant = true
		keys[i].Fun1Name = pg.getGameString("CHARACTER_REWARDS_DETAIL")
		keys[i].Fun4 = function(x, y)
			self.ctrl:receiveMainLvAward()
		end
		keys[i].Fun4IsImportant = true
		keys[i].Fun4Name = pg.getGameString("CHARACTER_REWARDS_GET")
		keys[i].Fun6 = function(x, y)
			v:OnClickSimulate()
		end
		keys[i].Fun6IsImportant = true
		keys[i].Fun6Name = pg.getGameString("CHARACTER_REWARDS_LOCK")
		keys[i].Fun3 = function(x, y)
			self.ctrl:dismiss()
		end
		keys[i].Fun3Name = pg.getGameString("CHARACTER_REWARDS_CANCEL")
	end

	self.navigation:initAreaTableSlots(self.navigation.MODE_PLAYER_REWARD, t)
end

function PlayerGamePadComponent:bind_SkillTreeArea(xBtnList, area, skillType)
	local btnList = xBtnList:GetAllButtons()

	if btnList.Length == 0 then
		return
	end

	local t = {}
	local col = self.model.SKILL_TREE_LENGTH[skillType] or 1

	for i = 1, 6 do
		t[i] = {}

		for j = 1, col do
			local index = (i - 1) * col + j
			local v = btnList[index - 1]

			t[i][j] = {
				Focus = function(x, y)
					v:TryChangePage("GamePadFocus", 1)
					self.navigation:baseFocus(t, x, y, self.view.keyList)
				end,
				DisFocus = function(x, y)
					v:TryChangePage("GamePadFocus", 0)
					v:ClosePopup()
				end,
				csBtn = v
			}
			t[i][j].Fun1 = function(x, y)
				if not v.isTooltipOpen then
					return
				end

				self.ctrl.skillTreePageCmp:onUpGradeBtnClick(v.dataFromUList)
			end
			t[i][j].Fun3 = function(x, y)
				self.ctrl.skillTreePageCmp:closeSkillTreePage()
			end
			t[i][j].Fun3Name = pg.getGameString("CHARACTER_REWARDS_CANCEL")
			t[i][j].Fun4 = function(x, y)
				if v.dataFromUList.isEmpty then
					return
				end

				if v.isTooltipOpen then
					v:ClosePopup()

					v.isSelected = true
				else
					v:OnClickSimulate()
				end
			end
			t[i][j].Fun4Name = pg.getGameString("CHARACTER_REWARDS_DETAIL")
			t[i][j].Fun5 = function(x, y)
				if v.isTooltipOpen then
					return
				end

				self.ctrl.skillTreePageCmp:onReset()
			end
			t[i][j].empty = v.dataFromUList.isEmpty
		end
	end

	self.navigation:initAreaTableSlots(area, t)
end

function PlayerGamePadComponent:focusXBoxPage(page)
	local x = 1
	local y = 1
	local area = self.navigation.AREAS.MODE_PLAYER_EQUIP

	if page == self.model.MODEL_STATE.SKILL_TREE then
		area = self.navigation.AREAS.MODE_SKILL_TREE_PAGE1

		if self.treePageCacheArea then
			area = self.treePageCacheArea

			local index = self.navigation.cacheAreaIndex[area]

			if index then
				x = index.x
				y = index.y
			end
		end
	elseif page == self.model.MODEL_STATE.SKILL_EQUIP then
		area = self.navigation.AREAS.MODE_SKILL_EQUIP_PAGE1
	elseif page == self.model.MODEL_STATE.REWARD_PAGE then
		area = self.navigation.AREAS.MODE_REWARD_PAGE
	end

	self.navigation:laterFramesFocus(function()
		self.navigation:specificSet(area, x, y)
	end, 1)
end

function PlayerGamePadComponent:bind_SkillEquipArea(xBtnList, area)
	local btnList = xBtnList:GetAllButtons()

	if btnList.Length == 0 then
		return
	end

	local t = {}

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		i = i + 1
		t[i] = {}
		t[i][1] = {
			Focus = function(x, y)
				v:TryChangePage("GamePadFocus", 1)
				self.navigation:baseFocus(t, x, y, self.view.keyList)
				xBtnList:GoToIndex(i - 1)
			end,
			DisFocus = function(x, y)
				v:TryChangePage("GamePadFocus", 0)
				v:ClosePopup()
			end
		}
		t[i][1].Fun1 = function(x, y)
			if not v.isTooltipOpen then
				return
			end

			self.ctrl.skillEquipPageCmp:onEquipCombatClick(v.dataFromUList)
		end
		t[i][1].Fun3 = function(x, y)
			if v.isTooltipOpen then
				v:ClosePopup()

				v.isSelected = true
			else
				self.ctrl:closeSkillEquipPage()
			end
		end
		t[i][1].Fun3Name = pg.getGameString("CHARACTER_REWARDS_CANCEL")
		t[i][1].Fun4 = function(x, y)
			if v.isTooltipOpen then
				v:ClosePopup()

				v.isSelected = true
			else
				v:OnClickSimulate()
			end
		end
		t[i][1].Fun4Name = pg.getGameString("CHARACTER_REWARDS_DETAIL")
	end

	self.navigation:initAreaTableSlots(area, t)
end

function PlayerGamePadComponent:onInputDeviceChanged(deviceType, page)
	if pg.game.input:isUsingGamepad() then
		self:focusXBoxPage(page)
	else
		self.navigation:clearNavigation(deviceType)
	end
end

function PlayerGamePadComponent:onDestroy()
	self.root = nil
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return PlayerGamePadComponent
