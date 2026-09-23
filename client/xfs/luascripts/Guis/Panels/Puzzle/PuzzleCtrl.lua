-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Puzzle\\PuzzleCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PuzzleCtrl = Class.LightClass("PuzzleCtrl", UICtrl)
local PuzzleData = require("Data.puzzle_data")
local Time = require("Core.Common.Time")
local json = require("json")
local Vector2 = Vector2
local Vector3 = Vector3
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PUZZLE1_TWEEN_ID = "puzzle1"
local PUZZLE2_TWEEN_ID = "puzzle2"

PuzzleCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}
PuzzleCtrl.ModeType = {
	["3X3"] = 0,
	["4X4"] = 1
}
PuzzleCtrl.GameType = {
	Normal = 1
}
PuzzleCtrl.HistoryKey = "PuzzleHistory"

function PuzzleCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info

	local puzzleConfig = PuzzleData[self.info[1]]

	if not puzzleConfig then
		return
	end

	self.puzzleConfig = puzzleConfig
	self.mode = puzzleConfig.mode
	self.stopPosition = puzzleConfig.stopPosition
	self.oneRowCount = self.mode == self.ModeType["3X3"] and 3 or 4
	self.aniPosFix = self.mode == self.ModeType["3X3"] and "1" or "2"
	self.maxCount = self.oneRowCount * self.oneRowCount
	self.problem = puzzleConfig.problem or {
		0,
		2,
		2,
		0
	}
	self.finishImg = puzzleConfig.keyRes
	self.tipImg = puzzleConfig.tipsRes
	self.frameImg = puzzleConfig.frameRes
	self.puzzleImgs = puzzleConfig.puzzleRes or {}
	self.moveGuideDeltaTime = 1
	self.showFinishView = false
	self.lastPlayerMoveTime = Time.secondCache
	self.tipTimeThreshold = 10
	self.inAniName = "VX_Pb_Jigsaw_In"
	self.initSuccess = false

	self:initUI()
	pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.PUZZLE, false)

	local pet = pg.me:getCurPetEntity()

	if pet then
		pet:setVisible(ClientConst.MODEL_VISIBLE_KEY.PUZZLE, false)
	end
end

function PuzzleCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnFinishUButton.luaClick()
		if self.puzzleConfig.successNoteinWindow then
			pg.global.ui.tips:showTextTip(pg.getLocalizationText(self.puzzleConfig.successNoteinWindow))
		end

		self:close()
	end

	local rawKeyboardW = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "rawKeyboardW")

	rawKeyboardW.isVirtual = true
	rawKeyboardW.actionPath = "Raw/KeyboardW"

	function rawKeyboardW.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local changePos = self.curStopPos + self.oneRowCount

			self:tryMovePuzzle(changePos)
		end
	end

	local rawKeyboardS = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "rawKeyboardS")

	rawKeyboardS.isVirtual = true
	rawKeyboardS.actionPath = "Raw/KeyboardS"

	function rawKeyboardS.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local changePos = self.curStopPos - self.oneRowCount

			self:tryMovePuzzle(changePos)
		end
	end

	local rawKeyboardA = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "rawKeyboardA")

	rawKeyboardA.isVirtual = true
	rawKeyboardA.actionPath = "Raw/KeyboardA"

	function rawKeyboardA.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local changePos = self.curStopPos + 1

			self:tryMovePuzzle(changePos)
		end
	end

	local rawKeyboardD = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "rawKeyboardD")

	rawKeyboardD.isVirtual = true
	rawKeyboardD.actionPath = "Raw/KeyboardD"

	function rawKeyboardD.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local changePos = self.curStopPos - 1

			self:tryMovePuzzle(changePos)
		end
	end

	local rawGamepadUp = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "rawGamepadUp")

	rawGamepadUp.isVirtual = true
	rawGamepadUp.actionPath = "Raw/GamepadDPadUp"

	function rawGamepadUp.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local changePos = self.curStopPos + self.oneRowCount

			self:tryMovePuzzle(changePos)
		end
	end

	local rawGamepadDown = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "rawGamepadDown")

	rawGamepadDown.isVirtual = true
	rawGamepadDown.actionPath = "Raw/GamepadDPadDown"

	function rawGamepadDown.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local changePos = self.curStopPos - self.oneRowCount

			self:tryMovePuzzle(changePos)
		end
	end

	local rawGamepadLeft = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "rawGamepadLeft")

	rawGamepadLeft.isVirtual = true
	rawGamepadLeft.actionPath = "Raw/GamepadDPadLeft"

	function rawGamepadLeft.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local changePos = self.curStopPos + 1

			self:tryMovePuzzle(changePos)
		end
	end

	local rawGamepadRight = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "rawGamepadRight")

	rawGamepadRight.isVirtual = true
	rawGamepadRight.actionPath = "Raw/GamepadDPadRight"

	function rawGamepadRight.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local changePos = self.curStopPos - 1

			self:tryMovePuzzle(changePos)
		end
	end

	self:bindCommonCloseHotKey(function()
		self:close()
	end)

	function self.view.btnAgainUButton.luaClick()
		if not self.initSuccess then
			self.view.uIPbJigsawUComponent:TryChangePage("PlayAgain", 1)
			self.view.uIPbJigsawUComponent:TryChangePage("IsFinish", 0)
			self:initPlayUI()
		else
			self.initSuccess = false
			self.showFinishView = false
			self.lastPlayerMoveTime = Time.secondCache

			self.view.uIPbJigsawUComponent:TryChangePage("IsView", 0)
			self.view.btnViewUButton:TryChangePage("State", 0)
			self.view.uIPbJigsawUComponent:TryChangePage("PlayAgain", 1)
			self.view.uIPbJigsawUComponent:TryChangePage("IsFinish", 0)
			self.view.leftPanelRectTransform.gameObject:SetActiveEx(false)

			local inAniLength = self.view.widgetAnimation:GetClip(self.inAniName).length

			self:startTimer(function()
				self:refreshPuzzle(true)
			end, inAniLength)
		end
	end

	function self.view.btnViewUButton.luaClick()
		self.showFinishView = not self.showFinishView
		self.lastPlayerMoveTime = Time.secondCache

		self.view.uIPbJigsawUComponent:TryChangePage("IsView", self.showFinishView and 1 or 0)
		self.view.btnViewUButton:TryChangePage("State", self.showFinishView and 2 or 0)
	end

	function self.view.btnResetUButton.luaClick()
		self:resetPuzzle()
	end

	LuaUIUtils.setCommonConsoleBarList(self.view.consoleBarRectTransform, {
		right = {
			{
				path = "BallDrive/Move",
				label = pg.getGameString("CONSOLE_BAR_MOVE")
			},
			{
				path = "Raw/GamepadButtonSouth",
				label = pg.getGameString("CONSOLE_BAR_CONFIRM")
			},
			{
				path = "Raw/GamepadButtonEast",
				label = pg.getGameString("CONSOLE_BAR_LEAVE")
			}
		}
	})

	local viewHotKeyContent = self.view.btnViewUButton.transform:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")
	local resetHotKeyContent = self.view.btnResetUButton.transform:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")
	local againHotKeyContent = self.view.btnAgainUButton.transform:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")
	local finishHotKeyContent = self.view.btnFinishUButton.transform:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")

	viewHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest)
	resetHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth)
	againHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth)
	finishHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth)
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, self.view.btnViewUButton.luaClick, self.view.btnViewUButton.gameObject)
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth, self.view.btnAgainUButton.luaClick, self.view.btnAgainUButton.gameObject)
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth, self.view.btnResetUButton.luaClick, self.view.btnResetUButton.gameObject)
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, self.view.btnFinishUButton.luaClick, self.view.btnFinishUButton.gameObject)
end

function PuzzleCtrl:initUI()
	self.entity = pg.getEntity(self.info.uiContext.npcGlobalId)

	self.entity.eModel:SetActive(false)
	ClientTextUtils.setText(self.view.titleUBaseText, pg.getLocalizationText(self.puzzleConfig.name))
	ClientTextUtils.setText(self.view.txtNameUBaseText, pg.getLocalizationText(self.puzzleConfig.successName))
	ClientTextUtils.setText(self.view.txtNameUText, pg.getGameString("UI_MEDIAPUZZLE_RESET"))
	ClientTextUtils.setText(self.view.keyHotKeyText, pg.getGameString("UI_MEDIAPUZZLE_WASD_PC"))
	ClientTextUtils.setText(self.view.btnTipsUText, pg.getGameString("UI_MEDIAPUZZLE_MOVE"))
	ClientTextUtils.setText(self.view.txtTitleUBaseText, pg.getGameString("UI_MEDIAPUZZLE_DIFFICULTY"))

	if self.finishImg then
		self.view.imgFinishUImage.forceSyncLoad = true
		self.view.imgFinishUImage.url = self.finishImg
		self.view.vXImgFinishUImage.forceSyncLoad = true
		self.view.vXImgFinishUImage.url = self.finishImg
		self.view.vfxImageUImage.forceSyncLoad = true
		self.view.vfxImageUImage.url = self.finishImg
	end

	if self.tipImg then
		self.view.imgPreviewUImage.url = self.tipImg
	end

	local hasFinish = pg.me.specialContentDict and pg.me.specialContentDict[self.entity.staticId]

	self.view.uIPbJigsawUComponent:TryChangePage("IsFinish", hasFinish and 1 or 0)
	self.view.uIPbJigsawUComponent:TryChangePage("PlayAgain", 0)
	self.view.uIPbJigsawUComponent:TryChangePage("Grade", self.puzzleConfig.difficulty)

	local listData = {}
	local item = {
		id = 1
	}

	listData[1] = item

	self.view.leftPanelRectTransform.gameObject:SetActiveEx(false)

	if hasFinish then
		self:showSuccessUI()
	else
		self:initPlayUI()
	end
end

function PuzzleCtrl:showSuccessUI()
	return
end

function PuzzleCtrl:initPlayUI()
	self.initPosCache = {}
	self.puzzleButtonRoot = self.mode == PuzzleCtrl.ModeType["3X3"] and self.view.times3Transform or self.view.times4Transform

	for i = 1, self.puzzleButtonRoot.childCount do
		local button = self.puzzleButtonRoot:GetChild(i - 1):GetComponent("UButton")

		if self.puzzleImgs[i] then
			local image = button:GetChild("Bg"):GetComponent("UImage")

			image.forceSyncLoad = true
			image.url = self.puzzleImgs[i]
		end
	end

	self:resetCamera()
	self.view.uIPbJigsawUComponent:TryChangePage("Type", self.mode)
	pg.game.audio:triggerEvent("SFX_SceneObject_AKR_BillboardPuzzle_Start")

	local inAniLength = self.view.widgetAnimation:GetClip(self.inAniName).length

	self:startTimer(function()
		self:refreshPuzzle()

		self.gamepadNavSubArea = -1

		if pg.game.input:isUsingGamepad() then
			self.gamepadNavSubArea = self.mode == self.ModeType["3X3"] and 0 or 1
		end
	end, inAniLength)
end

function PuzzleCtrl:refreshPuzzle(isReset)
	self.view.uIPbJigsawUComponent:TryChangePage("PlayAgain", 0)

	self.puzzleButtons = {}
	self.finishPuzzleButtons = {}
	self.stateCache = {}
	self.stateCachePos = {}
	self.anim1Playing = false
	self.anim2Playing = false
	self.puzzleButtonRoot = self.mode == PuzzleCtrl.ModeType["3X3"] and self.view.times3Transform or self.view.times4Transform

	for i = 1, self.puzzleButtonRoot.childCount do
		local button = self.puzzleButtonRoot:GetChild(i - 1):GetComponent("UButton")

		if self.puzzleImgs[i] then
			button:GetChild("Bg"):GetComponent("UImage").url = self.puzzleImgs[i]
		end

		button.gameObject.name = i

		table.insert(self.puzzleButtons, button)
		table.insert(self.finishPuzzleButtons, button)

		if not isReset then
			table.insert(self.initPosCache, button.rectTransform.anchoredPosition)
		else
			button.rectTransform.anchoredPosition = self.initPosCache[i]
		end

		self.puzzleButtons[i]:TryChangePage("IsNoise", 0)
	end

	if not self.stopPosition or self.stopPosition > #self.puzzleButtons then
		self.stopPosition = #self.puzzleButtons
	end

	for btnIndex, button in ipairs(self.puzzleButtons) do
		local btnIndex = tonumber(button.gameObject.name)

		function button.luaClick()
			local index = tonumber(button.gameObject.name)

			self:tryMovePuzzle(index)
		end

		function button.luaHover()
			local index = tonumber(button.gameObject.name)

			if index == self.curStopPos + 1 and self.curStopPos % self.oneRowCount ~= 0 then
				self.showMoveGuide = false

				self.puzzleButtons[self.curStopPos]:TryChangePage("Arrow", 3)
				self.puzzleButtons[index]:TryChangePage("button", 2)
				button.transform:SetAsLastSibling()
			elseif index == self.curStopPos - 1 and self.curStopPos % self.oneRowCount ~= 1 then
				self.showMoveGuide = false

				self.puzzleButtons[self.curStopPos]:TryChangePage("Arrow", 2)
				self.puzzleButtons[index]:TryChangePage("button", 2)
				button.transform:SetAsLastSibling()
			elseif index == self.curStopPos - self.oneRowCount then
				self.showMoveGuide = false

				self.puzzleButtons[self.curStopPos]:TryChangePage("Arrow", 0)
				self.puzzleButtons[index]:TryChangePage("button", 2)
				button.transform:SetAsLastSibling()
			elseif index == self.curStopPos + self.oneRowCount then
				self.showMoveGuide = false

				self.puzzleButtons[self.curStopPos]:TryChangePage("Arrow", 1)
				self.puzzleButtons[index]:TryChangePage("button", 2)
				button.transform:SetAsLastSibling()
			end
		end

		function button.luaUnhover()
			button:TryChangePage("button", 0)

			local index = tonumber(button.gameObject.name)

			if index == self.curStopPos + 1 or index == self.curStopPos - 1 or index == self.curStopPos - self.oneRowCount or index == self.curStopPos + self.oneRowCount then
				self.puzzleButtons[self.curStopPos]:TryChangePage("Arrow", 4)

				self.showMoveGuide = true

				self.puzzleButtons[index]:TryChangePage("button", 0)
			end
		end

		local dragListener = button:GetComponent("DragEventListener")

		function dragListener.onBeginDrag(eventData, eventFlags)
			self.startDragPos = eventData.position
		end

		function dragListener.onEndDrag(eventData, eventFlags)
			local index = tonumber(button.gameObject.name)
			local deltaPos = eventData.position - self.startDragPos

			if math.abs(deltaPos.x) > math.abs(deltaPos.y) then
				if deltaPos.x > 0 then
					if index + 1 == self.curStopPos then
						self:tryMovePuzzle(index)
					end
				elseif index - 1 == self.curStopPos then
					self:tryMovePuzzle(index)
				end
			elseif deltaPos.y > 0 then
				if index - self.oneRowCount == self.curStopPos then
					self:tryMovePuzzle(index)
				end
			elseif index + self.oneRowCount == self.curStopPos then
				self:tryMovePuzzle(index)
			end
		end
	end

	self.puzzleButtons[self.stopPosition]:TryChangePage("IsNoise", 1)

	self.curStopPos = self.stopPosition

	self.puzzleButtons[self.curStopPos]:TryChangePage("Arrow", 4)

	self.isInitProblem = true
	self.curStep = 1

	self:doProblem(self.curStep)
end

function PuzzleCtrl:doProblem(step)
	if step > #self.problem then
		self.isInitProblem = false
		self.initSuccess = true
		self.showFinishView = false
		self.lastPlayerMoveTime = Time.secondCache

		self.view.uIPbJigsawUComponent:TryChangePage("IsView", 0)
		self.view.btnViewUButton:TryChangePage("State", 2)
		self.view.leftPanelRectTransform.gameObject:SetActiveEx(true)

		for btnIndex, button in ipairs(self.puzzleButtons) do
			local btnIndex = tonumber(button.gameObject.name)
			local index = tonumber(button.gameObject.name)

			if index ~= self.curStopPos + 1 and index ~= self.curStopPos - 1 and index ~= self.curStopPos - self.oneRowCount and index ~= self.curStopPos + self.oneRowCount then
				self.puzzleButtons[self.curStopPos]:TryChangePage("Arrow", 4)

				self.showMoveGuide = true

				self.puzzleButtons[index]:TryChangePage("button", 0)
			end
		end

		self:MoveGuide()

		return
	end

	local action = self.problem[step]
	local changePos = self.curStopPos

	if action == 0 then
		changePos = self.curStopPos - self.oneRowCount
	elseif action == 1 then
		changePos = self.curStopPos + self.oneRowCount
	elseif action == 2 then
		if self.curStopPos % self.oneRowCount ~= 1 then
			changePos = self.curStopPos - 1
		end
	elseif action == 3 and self.curStopPos % self.oneRowCount ~= 0 then
		changePos = self.curStopPos + 1
	end

	if changePos >= 1 and changePos <= self.maxCount then
		local curStopPos = self.curStopPos
		local curStep = step

		self:changeTwoPuzzle(changePos, curStopPos, true)
	end
end

function PuzzleCtrl:MoveGuide()
	self.guideArrowIndex = self.curStopPos + 1
	self.showMoveGuide = true

	if self.arrowTimerId ~= nil then
		self:killTimer(self.arrowTimerId)
	end

	self.arrowTimerId = self:startTimer(function()
		if self.showMoveGuide then
			self.guideArrowIndex = self:FindNextArrowIndex()

			if self.guideArrowIndex == self.curStopPos + 1 then
				self.puzzleButtons[self.curStopPos]:TryChangePage("Arrow", 3)
			end

			if self.guideArrowIndex == self.curStopPos + self.oneRowCount then
				self.puzzleButtons[self.curStopPos]:TryChangePage("Arrow", 1)
			end

			if self.guideArrowIndex == self.curStopPos - 1 then
				self.puzzleButtons[self.curStopPos]:TryChangePage("Arrow", 2)
			end

			if self.guideArrowIndex == self.curStopPos - self.oneRowCount then
				self.puzzleButtons[self.curStopPos]:TryChangePage("Arrow", 0)
			end
		end
	end, self.moveGuideDeltaTime, true)
end

function PuzzleCtrl:FindNextArrowIndex()
	local nextArrowIndex = 0

	if self.guideArrowIndex == self.curStopPos + 1 then
		nextArrowIndex = self.curStopPos + self.oneRowCount

		if nextArrowIndex <= self.maxCount then
			return nextArrowIndex
		else
			nextArrowIndex = self.curStopPos - 1

			if self.curStopPos % self.oneRowCount ~= 1 then
				return nextArrowIndex
			else
				nextArrowIndex = self.curStopPos - self.oneRowCount

				if nextArrowIndex >= 1 then
					return nextArrowIndex
				else
					return self.guideArrowIndex
				end
			end
		end
	elseif self.guideArrowIndex == self.curStopPos + self.oneRowCount then
		nextArrowIndex = self.curStopPos - 1

		if self.curStopPos % self.oneRowCount ~= 1 then
			return nextArrowIndex
		else
			nextArrowIndex = self.curStopPos - self.oneRowCount

			if nextArrowIndex >= 1 then
				return nextArrowIndex
			else
				nextArrowIndex = self.curStopPos + 1

				if self.curStopPos % self.oneRowCount ~= 0 then
					return nextArrowIndex
				else
					return self.guideArrowIndex
				end
			end
		end
	elseif self.guideArrowIndex == self.curStopPos - 1 then
		nextArrowIndex = self.curStopPos - self.oneRowCount

		if nextArrowIndex >= 1 then
			return nextArrowIndex
		else
			nextArrowIndex = self.curStopPos + 1

			if self.curStopPos % self.oneRowCount ~= 0 then
				return nextArrowIndex
			else
				nextArrowIndex = self.curStopPos + self.oneRowCount

				if nextArrowIndex <= self.maxCount then
					return nextArrowIndex
				else
					return self.guideArrowIndex
				end
			end
		end
	elseif self.guideArrowIndex == self.curStopPos - self.oneRowCount then
		nextArrowIndex = self.curStopPos + 1

		if self.curStopPos % self.oneRowCount ~= 0 then
			return nextArrowIndex
		else
			nextArrowIndex = self.curStopPos + self.oneRowCount

			if nextArrowIndex <= self.maxCount then
				return nextArrowIndex
			else
				nextArrowIndex = self.curStopPos - 1

				if nextArrowIndex >= 1 then
					return nextArrowIndex
				else
					return self.guideArrowIndex
				end
			end
		end
	end
end

function PuzzleCtrl:tryMovePuzzle(index)
	if self.anim1Playing or self.anim2Playing or index == self.curStopPos or not self.initSuccess then
		return
	end

	if index + self.oneRowCount == self.curStopPos and index > 0 or index - self.oneRowCount == self.curStopPos and index <= self.maxCount or index + 1 == self.curStopPos and self.curStopPos % self.oneRowCount ~= 1 or index - 1 == self.curStopPos and self.curStopPos % self.oneRowCount ~= 0 then
		self:changeTwoPuzzle(index, self.curStopPos)

		self.curStopPos = index
		self.lastPlayerMoveTime = Time.secondCache

		if self:checkPuzzleFinish() then
			pg.game.audio:triggerEvent("SFX_SceneObject_AKR_BillboardPuzzle_Complete")
			self.view.rootUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			pg.me:serverMsg("RPC_CS_SendArkReward", self.puzzleConfig.arkRewardId or 0)
			self.puzzleButtons[self.curStopPos]:TryChangePage("Arrow", 4)
			self.view.leftPanelRectTransform.gameObject:SetActiveEx(false)
		else
			self.guideArrowIndex = self.curStopPos + 1
			self.showMoveGuide = true
		end
	else
		pg.game.audio:triggerEvent("SFX_SceneObject_AKR_BillboardPuzzle_ErrorMove")
	end
end

function PuzzleCtrl:changeTwoPuzzle(index1, index2, isInit)
	local puzzle1 = self.puzzleButtons[index1]
	local puzzle2 = self.puzzleButtons[index2]

	self.puzzleButtons[index1] = puzzle2
	self.puzzleButtons[index2] = puzzle1
	puzzle1.gameObject.name = index2
	puzzle2.gameObject.name = index1

	local deltaTime = self.puzzleConfig.troubleTime

	self.anim1Playing = true

	local puzzle1Tar = puzzle2.rectTransform.anchoredPosition
	local puzzle2Tar = puzzle1.rectTransform.anchoredPosition

	Vector3.enableCreateFromCache()
	DoTweenAnimMgr.AnchorPositionMove(puzzle1.rectTransform, LuaUIUtils.TweenId(PUZZLE1_TWEEN_ID), Vector3(puzzle1Tar.x, puzzle1Tar.y, puzzle1Tar.z), deltaTime, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		self.anim1Playing = false

		if not self.anim2Playing and self.isInitProblem then
			self.curStopPos = index1
			self.curStep = self.curStep + 1

			self:doProblem(self.curStep)
		end
	end)
	puzzle2.transform:SetSiblingIndex(0)

	self.anim2Playing = true

	DoTweenAnimMgr.AnchorPositionMove(puzzle2.rectTransform, LuaUIUtils.TweenId(PUZZLE2_TWEEN_ID), Vector3(puzzle2Tar.x, puzzle2Tar.y, puzzle2Tar.z), deltaTime, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		puzzle2.transform:SetSiblingIndex(#self.puzzleButtons - 1)

		self.anim2Playing = false

		if not self.anim1Playing and self.isInitProblem then
			self.curStopPos = index1
			self.curStep = self.curStep + 1

			self:doProblem(self.curStep)
		end
	end)
	Vector3.disableCreateFromCache()
	pg.game.audio:triggerEvent("SFX_SceneObject_AKR_BillboardPuzzle_CorrectMove")
end

function PuzzleCtrl:checkPuzzleFinish()
	for index, button in ipairs(self.finishPuzzleButtons) do
		if tonumber(button.gameObject.name) ~= index then
			return false
		end
	end

	return true
end

function PuzzleCtrl:resetPuzzle()
	if not self.initSuccess then
		return
	end

	local checkRet = Utils.checkSendArkReward(pg.me, self.puzzleConfig.arkRewardId or 123456)

	if NoticeDef.SUCCESS ~= checkRet and checkRet ~= NoticeDef.ERROR_LIMIT_EXCEED then
		pg.global.showBubbleMessageById(checkRet)

		return
	end

	pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("PUZZLE_RESET"), function()
		self.initSuccess = false

		self.view.uIPbJigsawUComponent:TryChangePage("IsView", 1)
		self.view.leftPanelRectTransform.gameObject:SetActiveEx(false)
		self:refreshPuzzle(true)
	end)
end

function PuzzleCtrl:saveHistory()
	if not self.puzzleConfig then
		return
	end

	for index, value in ipairs(self.puzzleButtons) do
		self.stateCache[index] = value.transform:GetSiblingIndex()
		self.stateCachePos[index] = value.rectTransform.anchoredPosition
		self.stopPosCache = self.curStopPos
	end

	local histroy = {
		stateCache = self.stateCache,
		stateCachePos = self.stateCachePos,
		stopPosCache = self.stopPosCache
	}

	pg.global.prefsCacheUtils:setString(self.HistoryKey .. self.info[1], json.encode(histroy))
end

function PuzzleCtrl:tryUndoHistory()
	local history = pg.global.prefsCacheUtils:getString(self.HistoryKey .. self.info[1], "")

	if history ~= "" then
		local historyDic = json.decode(history)

		for index, value in ipairs(historyDic.stateCache) do
			self.puzzleButtons[index] = self.puzzleButtonRoot:GetChild(value):GetComponent("UButton")
			self.puzzleButtons[index].gameObject.name = index

			local pos = historyDic.stateCachePos[index]

			self.puzzleButtons[index].rectTransform.anchoredPosition = Vector2(pos[1], pos[2])
			self.curStopPos = historyDic.stopPosCache
		end

		self.initSuccess = true

		return true
	end

	return false
end

function PuzzleCtrl:resetCamera()
	local nearHeight, farHeight = pg.pawn:getCameraHeightInfo()
	local offset = pg.pawn:getConfigData().funcMenuCameraOffset or {
		0,
		0,
		0
	}

	Vector3.enableCreateFromCache()

	local pivotOffset = Vector3(offset[1], offset[2] + nearHeight, offset[3])
	local angle = pg.game.camera.playerCameraMode:getCameraDirToPlayerDirAngle()
	local cameraPos = pg.global.cameraMgr.vcManager:GetFuncMenuBackPos(false)
	local cameraRot = pg.global.cameraMgr.vcManager:GetFuncMenuBackRot(false)
	local fov = angle > 90 and pg.global.cameraMgr.vcManager:GetFuncMenuFrontFov(false) or pg.global.cameraMgr.vcManager:GetFuncMenuBackFov(false)

	pg.game.camera:cameraBlendToFixedWithTargetByActorId(cameraPos, cameraRot, fov, pg.me.actorId, 0.5, function()
		if angle > 90 then
			pg.me.eModel.modelModelView:SetLightIntensity(1)
		end
	end, {
		inheritDir = false,
		pivotOffset = pivotOffset
	})
	Vector3.disableCreateFromCache()
end

function PuzzleCtrl:onDestroy()
	UICtrl.onDestroy(self)
	pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.PUZZLE, true)

	local pet = pg.me:getCurPetEntity()

	if pet then
		pet:setVisible(ClientConst.MODEL_VISIBLE_KEY.PUZZLE, true)
	end

	pg.game.camera:cancelBlendToFixedWithTarget(0.5)

	if self.entity then
		self.entity.eModel:SetActive(true)
	end
end

function PuzzleCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PuzzleCtrl:onShow()
	return
end

function PuzzleCtrl:onHide()
	return
end

function PuzzleCtrl:onInputDeviceChanged(deviceType)
	if self.gamepadNavSubArea == -1 then
		self.gamepadNavSubArea = self.mode == self.ModeType["3X3"] and 0 or 1
	end

	for btnIndex, button in ipairs(self.puzzleButtons) do
		button.luaUnhover()
	end
end

return PuzzleCtrl
