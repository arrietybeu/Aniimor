-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestCourse\\Component\\QuestGuideCourseGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local GamePadNavigation = require("Utils.GamePadNavigation")
local QuestGuideCourseGamePadComponent = Class.LightClass("QuestGuideCourseGamePadComponent", UIComponent)

function QuestGuideCourseGamePadComponent:findObjects()
	self.root = self.view.root
	self.navigation = GamePadNavigation.new(self)
end

function QuestGuideCourseGamePadComponent:onInputDeviceChanged(deviceType)
	self:initPanelFocus()
end

function QuestGuideCourseGamePadComponent:initPanelFocus()
	self:unfocusCourseGradeItem()

	if pg.game.input:isUsingGamepad() then
		if not self.ctrl.guideCourseComponent.showDetailPanel then
			self.navigation:focusReset(self.navigation.AREAS.GUIDE_COURSE_GRADE)

			self.curGrade = 1
		else
			self.navigation:focusReset(self.navigation.AREAS.GUIDE_COURSE_LIST_COURSE)
		end
	else
		self:unfocusRewardItem()
		self:unfocusCourseGradeItem()
		self:unfocusCourseItem()
	end
end

function QuestGuideCourseGamePadComponent:init()
	self.navigation.longPressDelay = 0.55
	self.onRightStickMoveCallback = nil
	self.rightStickMoveY = 0
	self.rightStickMoveX = 0
	self.courseGradeRewardArea = {}

	self:initAreas()
	self.navigation:addConsoleEvent(self.navigation:initCommonLeftStickMoveData(self.root.gameObject))
	self.navigation:addConsoleEvent(self:initRightStickMoveData())
	self.navigation:initDPadMoveData(self.root.gameObject)
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("LS", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("RS", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("Y", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("B", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("A", self.root.gameObject))
	self.view.leftHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDLeft)
	self.view.rightHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDRight)

	if self.rightTickTimer ~= nil then
		self:killTimer(self.rightTickTimer)
	end

	self.rightTickTimer = self:startTimer(function()
		self:startTick()
	end, 0, true)
end

function QuestGuideCourseGamePadComponent:initView()
	return
end

function QuestGuideCourseGamePadComponent:initAreas()
	self.navigation.AREAS = {
		GUIDE_COURSE_LIST_COURSE = 4,
		GUIDE_COURSE_GRADE = 1,
		GUIDE_COURSE_LIST_COURSE_REWARD = 5,
		GUIDE_COURSE_LIST_REWARD = 3,
		GUIDE_COURSE_GRADE_REWARD = 2
	}
	self.navigation.GUIDE_COURSE_GRADE = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.GUIDE_COURSE_GRADE,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.GUIDE_COURSE_GRADE
	}
	self.navigation.GUIDE_COURSE_GRADE_REWARD = {}
	self.navigation.GUIDE_COURSE_LIST_REWARD = {
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.GUIDE_COURSE_LIST_COURSE
	}
	self.navigation.GUIDE_COURSE_LIST_COURSE = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.GUIDE_COURSE_LIST_REWARD,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.GUIDE_COURSE_LIST_COURSE,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.GUIDE_COURSE_LIST_COURSE
	}
	self.navigation.GUIDE_COURSE_LIST_COURSE_REWARD = {}
	self.navigation.AREA_TABLES = {
		self.navigation.GUIDE_COURSE_GRADE,
		self.navigation.GUIDE_COURSE_GRADE_REWARD,
		self.navigation.GUIDE_COURSE_LIST_REWARD,
		self.navigation.GUIDE_COURSE_LIST_COURSE,
		self.navigation.GUIDE_COURSE_LIST_COURSE_REWARD
	}
end

function QuestGuideCourseGamePadComponent:startTick()
	if self.rightStickMoveY ~= 0 then
		self.view.courseDetailList.content.transform.anchoredPosition = Vector2(0, self.view.courseDetailList.content.transform.anchoredPosition.y - self.rightStickMoveY * 100)
	end

	if self.rightStickMoveX ~= 0 and not self.ctrl.guideCourseComponent.showDetailPanel and self.curList ~= nil then
		self.curList.content.transform.anchoredPosition = Vector2(self.curList.content.transform.anchoredPosition.x - self.rightStickMoveX * 100, 0)
	end
end

function QuestGuideCourseGamePadComponent:initRightStickMoveData()
	return {
		actionPath = "Hud/RightStickMove",
		isVirtual = true,
		id = "rightStickMove",
		parent = self.root.gameObject,
		event = function(inputInfo)
			TimerManager.removeTimer(self.navigation.longPressTimer)

			if self.navigation.longPressMayPerformed == true then
				return
			end

			if inputInfo.phase == "Performed" then
				self.rightStickMoveY = inputInfo.valueVec2.y
				self.rightStickMoveX = inputInfo.valueVec2.x
			else
				self.rightStickMoveY = 0
				self.rightStickMoveX = 0
			end
		end
	}
end

function QuestGuideCourseGamePadComponent:refocusArea()
	if pg.game.input:isUsingGamepad() then
		self.navigation:reFocus()
	end
end

function QuestGuideCourseGamePadComponent:initCourseGradeArea(dataList, ulist)
	local t = {}

	for i = 1, #dataList do
		local x = 1
		local y = i

		if t[x] == nil then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			local curGrade = i
			local ret, btn = ulist:TryGetChildAt(i - 1)
			local courseConfig = self.model:getCourseGradeConfig(curGrade)

			if self.model:isCourseGradeUnlock(courseConfig[1]) then
				t[x][y].Fun4IsImportant = true
				t[x][y].Fun4Name = pg.getGameString("QUEST_DELEGATION_GO")
				t[x][y].Fun4 = function(x1, y1)
					if self.curGradeItem ~= nil then
						self.curGradeItem.luaClick()
					end
				end
				t[x][y].Fun5IsImportant = true
				t[x][y].Fun5Name = pg.getGameString("QUEST_DELEGATION_LOCK")
				t[x][y].Fun5 = function(x1, y1)
					self:lockCourseGradeItemArea(btn, curGrade)
				end
			else
				t[x][y].Fun4Name = nil
				t[x][y].Fun4 = nil
				t[x][y].Fun5Name = nil
				t[x][y].Fun5 = nil
				t[x][y].Fun6Name = nil
				t[x][y].Fun6 = nil
			end

			self:unfocusCourseGradeItem()
			self:focusCourseGradeItem(btn)
			self.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList)
		end
		t[x][y].Fun3Name = pg.getGameString("QUEST_DELEGATION_CLOSE")
		t[x][y].Fun3 = function(x1, y1)
			self.ctrl:dismiss()
		end
	end

	self.navigation:initAreaTableSlots(self.navigation.GUIDE_COURSE_GRADE, t)
end

function QuestGuideCourseGamePadComponent:initCourseGradeRewardAreaTable(grade, dataList, ulist)
	local t = {}

	for i = 1, #dataList do
		local data = dataList[i]
		local x = 1
		local y = i

		if t[x] == nil then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			ulist:GoToIndex(i - 1, false)

			local ret, btn = ulist:TryGetChildAt(i - 1)

			if btn == nil then
				if self.delayToScrollTimer ~= nil then
					self.ctrl:killTimer(self.delayToScrollTimer)
				end

				self.delayToScrollTimer = self.ctrl:startTimer(function()
					self.navigation:reFocus()
				end, 0.1)

				return
			end

			local courseConfig = self.model:getCourseGradeConfig(grade)

			if self.model:isCourseGradeUnlock(courseConfig[1]) then
				t[x][y].Fun4IsImportant = true
				t[x][y].Fun4Name = pg.getGameString("QUEST_DELEGATION_GO")
				t[x][y].Fun4 = function(x1, y1)
					if self.curGradeItem ~= nil then
						self.curGradeItem.luaClick()
					end
				end
				t[x][y].Fun5 = function(x1, y1)
					self:unlockCourseGradeItemArea(self.markItem)
				end

				if self.model:canGetCourseGradeLevelReward(grade, i) then
					t[x][y].Fun2IsImportant = true
					t[x][y].Fun2Name = pg.getGameString("QUEST_DELEGATION_CLAIM")
					t[x][y].Fun2 = function(x1, y1)
						if self.curRewardItem ~= nil then
							self.curRewardItem.luaClick()
						end
					end
				else
					t[x][y].Fun2Name = nil
					t[x][y].Fun2 = nil
				end
			else
				t[x][y].Fun2Name = nil
				t[x][y].Fun2 = nil
				t[x][y].Fun4Name = nil
				t[x][y].Fun4 = nil
				t[x][y].Fun5Name = nil
				t[x][y].Fun5 = nil
			end

			self:unfocusRewardItem()
			self:focusRewardItem(btn)
			self.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList)
		end
		t[x][y].Fun3Name = pg.getGameString("QUEST_DELEGATION_CLOSE")
		t[x][y].Fun3 = function(x1, y1)
			self:unlockCourseGradeItemArea(self.markItem)
		end
		t[x][y].Fun6IsImportant = true
		t[x][y].Fun6Name = pg.getGameString("QUEST_DELEGATION_DETAIL")
		t[x][y].Fun6 = function(x1, y1)
			if self.curRewardItem ~= nil then
				pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
					id = data.id,
					num = data.num,
					targetRect = self.curRewardItem
				})
			end
		end
	end

	if self.courseGradeRewardArea[grade] == nil then
		self.courseGradeRewardArea[grade] = {}
		self.courseGradeRewardArea[grade].area = t
		self.courseGradeRewardArea[grade].list = ulist
	end
end

function QuestGuideCourseGamePadComponent:initCourseListGradeRewardAreaTable(curGrade, dataList, ulist)
	local t = {}

	for i = 1, #dataList do
		local data = dataList[i]
		local x = 1
		local y = i

		if t[x] == nil then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			local ret, btn = ulist:TryGetChildAt(i - 1)

			if self.model:canGetCourseGradeLevelReward(curGrade, i) then
				t[x][y].Fun2IsImportant = true
				t[x][y].Fun2Name = pg.getGameString("QUEST_DELEGATION_CLAIM")
				t[x][y].Fun2 = function(x1, y1)
					local itemComs = self.view:getCourseDetailRewardItemComs(btn)

					if itemComs.rewardBtn then
						itemComs.rewardBtn.luaClick()
					end
				end
			else
				t[x][y].Fun2Name = nil
				t[x][y].Fun2 = nil
			end

			self:unfocusCourseItem()
			self:unfocusRewardItem()
			self:focusRewardItem(btn)
			self.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList)
		end
		t[x][y].Fun3Name = pg.getGameString("QUEST_DELEGATION_CLOSE")
		t[x][y].Fun3 = function(x1, y1)
			self.view.courseDetailCloseBtn.luaClick()
			self:initPanelFocus()
		end
		t[x][y].Fun6IsImportant = true
		t[x][y].Fun6Name = pg.getGameString("QUEST_DELEGATION_DETAIL")
		t[x][y].Fun6 = function(x1, y1)
			if self.curRewardItem ~= nil then
				local rewardItems = self.model:getRewardItems(data.reward)

				if rewardItems ~= nil then
					local itemComs = self.view:getCourseDetailRewardItemComs(self.curRewardItem)

					pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
						id = rewardItems[1][1],
						num = rewardItems[1][2],
						targetRect = itemComs.rewardBtn
					})
				end
			end
		end
	end

	self.navigation:initAreaTableSlots(self.navigation.GUIDE_COURSE_LIST_REWARD, t)
end

function QuestGuideCourseGamePadComponent:initCourseListAreaTable(dataList, ulist)
	local colCount = 3
	local t = {}

	for i = 1, #dataList do
		local data = dataList[i]
		local x = math.ceil(i / colCount)
		local y = (i - 1) % colCount + 1

		if t[x] == nil then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			local ret, btn = ulist:TryGetChildAt(i - 1)
			local hasGet = self.model:isCourseReward(data.id)
			local canGet = self.model:isCourseComplete(data.id)

			if canGet and not hasGet then
				t[x][y].Fun2IsImportant = true
				t[x][y].Fun2Name = pg.getGameString("QUEST_DELEGATION_CLAIM")
				t[x][y].Fun2 = function(x1, y1)
					local itemComs = self.view:getCourseItemComs(btn)

					itemComs.startBtn.luaClick()
				end
			else
				t[x][y].Fun2Name = nil
				t[x][y].Fun2 = nil
			end

			self:unfocusRewardItem()
			self:unfocusCourseItem()
			self:focusCourseItem(x - 1, btn)
			self.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList)
		end
		t[x][y].Fun4IsImportant = true
		t[x][y].Fun4Name = pg.getGameString("QUEST_DELEGATION_GO")
		t[x][y].Fun4 = function(x1, y1)
			local ret, btn = self.view.courseDetailList:TryGetChildAt(i - 1)

			if btn then
				local itemComs = self.view:getCourseItemComs(btn)

				itemComs.startBtn.luaClick()
			end
		end
		t[x][y].Fun3Name = pg.getGameString("QUEST_DELEGATION_CLOSE")
		t[x][y].Fun3 = function(x1, y1)
			self.view.courseDetailCloseBtn.luaClick()
			self:initPanelFocus()
		end
		t[x][y].Fun5IsImportant = true
		t[x][y].Fun5Name = pg.getGameString("QUEST_DELEGATION_LOCK")
		t[x][y].Fun5 = function(x1, y1)
			local ret, btn = ulist:TryGetChildAt(i - 1)
			local itemComs = self.view:getCourseItemComs(btn)

			self:lockCourseItemArea(itemComs)
		end
	end

	self.navigation:initAreaTableSlots(self.navigation.GUIDE_COURSE_LIST_COURSE, t)
end

function QuestGuideCourseGamePadComponent:initCourseListCourseRewardAreaTable(dataList, ulist, courseData)
	local t = {}

	for i = 1, #dataList do
		local data = dataList[i]
		local x = 1
		local y = i

		if t[x] == nil then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			self:unfocusRewardItem()

			local ret, btn = ulist:TryGetChildAt(i - 1)

			self:focusRewardItem(btn)

			local hasGet = self.model:isCourseReward(courseData.id)
			local canGet = self.model:isCourseComplete(courseData.id)

			if canGet and not hasGet then
				t[x][y].Fun2IsImportant = true
				t[x][y].Fun2Name = pg.getGameString("QUEST_DELEGATION_CLAIM")
				t[x][y].Fun2 = function(x1, y1)
					local itemComs = self.view:getCourseItemComs(self.curCourseItem)

					itemComs.startBtn.luaClick()
				end
			else
				t[x][y].Fun2Name = nil
				t[x][y].Fun2 = nil
			end

			self.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList)
		end
		t[x][y].Fun4IsImportant = true
		t[x][y].Fun4Name = pg.getGameString("QUEST_DELEGATION_GO")
		t[x][y].Fun4 = function(x1, y1)
			local colCount = 3
			local index = (self.markCcursorIndex.x - 1) * colCount + self.markCcursorIndex.y
			local ret, btn = self.view.courseDetailList:TryGetChildAt(index - 1)

			if btn then
				local itemComs = self.view:getCourseItemComs(btn)

				itemComs.startBtn.luaClick()
			end
		end
		t[x][y].Fun6IsImportant = true
		t[x][y].Fun6Name = pg.getGameString("QUEST_DELEGATION_DETAIL")
		t[x][y].Fun6 = function(x1, y1)
			if self.curRewardItem ~= nil then
				pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
					id = data[1],
					num = data[2],
					targetRect = self.curRewardItem
				})
			end
		end
		t[x][y].Fun5 = function(x1, y1)
			self:unlockCourseItemArea()
		end
		t[x][y].Fun3Name = pg.getGameString("QUEST_DELEGATION_CLOSE")
		t[x][y].Fun3 = function(x1, y1)
			self:unlockCourseItemArea()
		end
	end

	self.navigation:initAreaTableSlots(self.navigation.GUIDE_COURSE_LIST_COURSE_REWARD, t)
end

function QuestGuideCourseGamePadComponent:focusCourseGradeItem(itemBtn)
	itemBtn:TryChangePage("GamePadFocus", 1)

	self.curGradeItem = itemBtn
end

function QuestGuideCourseGamePadComponent:unfocusCourseGradeItem()
	if self.curGradeItem ~= nil then
		self.curGradeItem:TryChangePage("GamePadFocus", 0)

		self.curGradeItem = nil
	end
end

function QuestGuideCourseGamePadComponent:lockCourseGradeItemArea(itemBtn, grade)
	if self.markItem ~= nil then
		self:unlockCourseGradeItemArea(self.markItem)
	end

	self.markItem = itemBtn
	self.markAreaId = self.navigation.cursorArea
	self.markCcursorIndex = self.navigation.cursorIndex

	itemBtn:TryChangePage("GamePadFocus", 2)

	if self.courseGradeRewardArea[grade] ~= nil then
		self.navigation:initAreaTableSlots(self.navigation.GUIDE_COURSE_GRADE_REWARD, self.courseGradeRewardArea[grade].area)
		self.navigation:focusReset(self.navigation.AREAS.GUIDE_COURSE_GRADE_REWARD)

		self.curList = self.courseGradeRewardArea[grade].list
	end
end

function QuestGuideCourseGamePadComponent:unlockCourseGradeItemArea(itemBtn)
	if self.markAreaId == nil then
		return
	end

	self.navigation:specificSet(self.markAreaId, self.markCcursorIndex.x, self.markCcursorIndex.y)

	self.markAreaId = nil
	self.markCcursorIndex = nil
	self.markItem = nil

	self.navigation:reFocus()
	self:unfocusRewardItem()
	itemBtn:TryChangePage("GamePadFocus", 1)
end

function QuestGuideCourseGamePadComponent:focusRewardItem(itemBtn)
	if itemBtn == nil then
		return
	end

	local objectReference = itemBtn.transform:GetComponent("ObjectReference")
	local consoleSelected = objectReference:GetRefValue("consoleSelected")

	consoleSelected:TryChangePage("GamePadFocus", 1)

	self.curRewardItem = itemBtn
end

function QuestGuideCourseGamePadComponent:unfocusRewardItem()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	end

	if self.curRewardItem ~= nil then
		local objectReference = self.curRewardItem.transform:GetComponent("ObjectReference")
		local consoleSelected = objectReference:GetRefValue("consoleSelected")

		consoleSelected:TryChangePage("GamePadFocus", 0)

		self.curRewardItem = nil
	end
end

function QuestGuideCourseGamePadComponent:lockCourseItemArea(itemComs)
	if self.markItemComs ~= nil then
		self:unlockCourseItemArea()
	end

	self.markItemComs = itemComs
	self.markAreaId = self.navigation.cursorArea
	self.markCcursorIndex = self.navigation.cursorIndex

	self.navigation:focusReset(self.navigation.AREAS.GUIDE_COURSE_LIST_COURSE_REWARD)
	itemComs.btn:TryChangePage("GamePadFocus", 2)
	self:initCourseListCourseRewardAreaTable(itemComs.data.rewardItems, itemComs.rewardUList, itemComs.data)
	self.navigation:focusReset(self.navigation.AREAS.GUIDE_COURSE_LIST_COURSE_REWARD)
end

function QuestGuideCourseGamePadComponent:unlockCourseItemArea()
	if self.markAreaId == nil then
		return
	end

	self.navigation:specificSet(self.markAreaId, self.markCcursorIndex.x, self.markCcursorIndex.y)
	self.navigation:reFocus()

	if self.markItemComs ~= nil then
		self.markItemComs.btn:TryChangePage("GamePadFocus", 1)
	end

	self.markAreaId = nil
	self.markCcursorIndex = nil
	self.markItemComs = nil

	self:unfocusRewardItem()
end

function QuestGuideCourseGamePadComponent:focusCourseItem(index, itemBtn)
	if itemBtn == nil then
		return
	end

	local objectReference = itemBtn.transform:GetComponent("ObjectReference")
	local consoleSelected = objectReference:GetRefValue("consoleSelected")

	consoleSelected:TryChangePage("GamePadFocus", 1)

	self.curCourseItem = itemBtn

	if self.delayToScrollTimer ~= nil then
		self.ctrl:killTimer(self.delayToScrollTimer)
	end

	self.delayToScrollTimer = self.ctrl:startTimer(function()
		local toY = 0

		toY = index == 0 and 0 or math.abs(itemBtn.localPosition.y + 45)

		self.view.courseDetailList:GoToPos(Vector2(0, toY), false)
	end, 0.1, false)
end

function QuestGuideCourseGamePadComponent:unfocusCourseItem()
	if self.curCourseItem ~= nil then
		local objectReference = self.curCourseItem.transform:GetComponent("ObjectReference")
		local consoleSelected = objectReference:GetRefValue("consoleSelected")

		consoleSelected:TryChangePage("GamePadFocus", 0)

		self.curCourseItem = nil
	end
end

function QuestGuideCourseGamePadComponent:onExit()
	return
end

function QuestGuideCourseGamePadComponent:onDestroy()
	self.root = nil
	self.navigation = nil
	self.rightStickMoveY = 0

	UIComponent.onDestroy(self)
end

return QuestGuideCourseGamePadComponent
