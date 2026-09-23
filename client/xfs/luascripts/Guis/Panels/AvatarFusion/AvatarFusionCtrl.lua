-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarFusion\\AvatarFusionCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local Utils = require("Common.Utils.Utils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local AvatarPresetData = require("Data.avatar_preset_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local Time = require("Core.Common.Time")
local AvatarFusionCtrl = Class.LightClass("AvatarFusionCtrl", UICtrl)
local avatarBody = pg.global.avatarMgr.avatarBody
local avatarFace = pg.global.avatarMgr.avatarFace
local avatarHair = pg.global.avatarMgr.avatarHair
local avatarMakeup = pg.global.avatarMgr.avatarMakeup

AvatarFusionCtrl.messages = {}
AvatarFusionCtrl.SLOT_INDEX = {
	BOT_LEFT = "botLeft",
	BOT_RIGHT = "botRight",
	UP = "up"
}
AvatarFusionCtrl.JOYSTICK_RANGE = 250

function AvatarFusionCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.avatarScene.pauseAutoSave = true
	self.presetKey = info.presetKey

	local presetData = pg.game.avatar:getAvatarPresetData(self.presetKey) or {}

	self.body = presetData.body

	self.view.root:TryChangePage("Gender", self.body == self.model.GENDER.GIRL and 1 or 0)

	self.backFunc = info.backFunc
	self.slotUpPreset = nil
	self.slotBotLeftPreset = nil
	self.slotBotRightPreset = nil
	self.recordBodyData = {}
	self.recordFaceData = {}
	self.resultBodyData = {}
	self.resultFaceData = {}
	self.curSelectedSlotIndex = nil
	self.joyStickX = 0
	self.joyStickY = 0
	self.lastCount = 0
	self.lastPersistTime = 0
	self._nextRandomPickAllowedTime = 0
	self._randomPickBusy = false
	self._makeupRefreshTimerId = nil

	self:changeRootPage(0)

	self.pickedHairPreset = nil
	self.pickedMakeupPreset = nil
	self.aniOnce = false
	self.firstPick = nil

	if info.fusionData then
		self.fusionData = info.fusionData
		self.slotUpPreset = self.fusionData.slotUp
		self.slotBotLeftPreset = self.fusionData.slotBotLeft
		self.slotBotRightPreset = self.fusionData.slotBotRight
		self.joyStickX = self.fusionData.joyStickX or 0
		self.joyStickY = self.fusionData.joyStickY or 0

		self:renderSlot(self.view.btnAdd1UButton, self.slotUpPreset and pg.game.avatar:getAvatarPresetData(self.slotUpPreset).icon or nil, true)
		self:renderSlot(self.view.btnAdd2UButton, self.slotBotLeftPreset and pg.game.avatar:getAvatarPresetData(self.slotBotLeftPreset).icon or nil, true)
		self:renderSlot(self.view.btnAdd3UButton, self.slotBotRightPreset and pg.game.avatar:getAvatarPresetData(self.slotBotRightPreset).icon or nil, true)
		self:recordData()

		self.view.handleRectTransform.anchoredPosition = Vector2(AvatarFusionCtrl.JOYSTICK_RANGE * self.joyStickX, AvatarFusionCtrl.JOYSTICK_RANGE * self.joyStickY)
		self.pickedHairPreset = self.fusionData.pickedHairPreset
		self.pickedMakeupPreset = self.fusionData.pickedMakeupPreset
		self.firstPick = self.fusionData.firstPick

		self:refreshPartsList()
	end

	self:initPresetList()
	self:setTipText(true)
end

function AvatarFusionCtrl:_setRandomPickBusy(busy)
	self._randomPickBusy = busy == true

	if self.view and self.view.btnDiceUButton then
		self.view.btnDiceUButton.interactable = not self._randomPickBusy
	end
end

function AvatarFusionCtrl:persistFusionProgress(forceSave)
	local currentTime = Time.realtimeSinceStartup

	if not forceSave and currentTime - self.lastPersistTime < 0.5 then
		return
	end

	self.lastPersistTime = currentTime

	if self:emptyPick() then
		pg.game.avatar:setFusionData()
	else
		pg.game.avatar:setFusionData({
			slotUp = self.slotUpPreset,
			slotBotLeft = self.slotBotLeftPreset,
			slotBotRight = self.slotBotRightPreset,
			joyStickX = self.joyStickX,
			joyStickY = self.joyStickY,
			firstPick = self.firstPick,
			pickedHairPreset = self.pickedHairPreset,
			pickedMakeupPreset = self.pickedMakeupPreset
		})
	end

	AvatarUtils.saveCustomDataToDisk(self.presetKey)
end

function AvatarFusionCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.root.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.view.btnBackUButton.luaClick()
		end
	end

	function self.view.btnBackUButton.luaClick()
		if self.fusionData then
			if self:compareRecordedFusionData() then
				pg.global.showConfirmMsgRaw(pg.getGameString("FUSION_AVATAR_TIP_2"), pg.getGameString("FUSION_AVATAR_TIP_3"), function()
					self:revertAll()
					self:closePanel()
				end)
			else
				self:closePanel()
			end
		elseif self:emptyPick() then
			self:revertAll()
			self:closePanel()
		else
			pg.global.showConfirmMsgRaw(pg.getGameString("FUSION_AVATAR_TIP_2"), pg.getGameString("FUSION_AVATAR_TIP_3"), function()
				self:revertAll()
				self:closePanel()
			end)
		end
	end

	function self.view.btnUseUButton.luaClick()
		if not self:emptyPick() then
			pg.game.avatar.fusionUseCount = (pg.game.avatar.fusionUseCount or 0) + 1

			pg.game.avatar:setFusionData({
				slotUp = self.slotUpPreset,
				slotBotLeft = self.slotBotLeftPreset,
				slotBotRight = self.slotBotRightPreset,
				joyStickX = self.joyStickX,
				joyStickY = self.joyStickY,
				firstPick = self.firstPick,
				pickedHairPreset = self.pickedHairPreset,
				pickedMakeupPreset = self.pickedMakeupPreset
			})
			pg.global.showBubbleMessageRaw(pg.getGameString("FUSION_AVATAR_TIP_6"))
		else
			pg.game.avatar:setFusionData()
		end

		self:closePanel()
	end

	function self.view.btnAdd1UButton.luaClick()
		self:selectSlot(AvatarFusionCtrl.SLOT_INDEX.UP, self.view.btnAdd1UButton)
	end

	function self.view.btnAdd2UButton.luaClick()
		self:selectSlot(AvatarFusionCtrl.SLOT_INDEX.BOT_LEFT, self.view.btnAdd2UButton)
	end

	function self.view.btnAdd3UButton.luaClick()
		self:selectSlot(AvatarFusionCtrl.SLOT_INDEX.BOT_RIGHT, self.view.btnAdd3UButton)
	end

	self:registerAddBtnEvent(AvatarFusionCtrl.SLOT_INDEX.UP, self.view.btnAdd1UButton)
	self:registerAddBtnEvent(AvatarFusionCtrl.SLOT_INDEX.BOT_LEFT, self.view.btnAdd2UButton)
	self:registerAddBtnEvent(AvatarFusionCtrl.SLOT_INDEX.BOT_RIGHT, self.view.btnAdd3UButton)

	function self.view.btnDiceUButton.luaClick()
		self:randomPick()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		button.name = data.presetKey

		local objectReference = button:GetComponent("ObjectReference")
		local avatarUImage = objectReference:GetRefValue("avatarUImage")

		avatarUImage.url = data.icon

		if data.presetKey == self.slotUpPreset or data.presetKey == self.slotBotLeftPreset or data.presetKey == self.slotBotRightPreset then
			button.isSelected = true
		else
			button.isSelected = false
		end

		function button.luaClick()
			if self.curSelectedSlotIndex == AvatarFusionCtrl.SLOT_INDEX.UP then
				if self.slotUpPreset then
					self.recordFaceData[self.slotUpPreset] = nil
					self.recordBodyData[self.slotUpPreset] = nil
				end

				self.slotUpPreset = data.presetKey

				self:renderSlot(self.view.btnAdd1UButton, data.icon)
			elseif self.curSelectedSlotIndex == AvatarFusionCtrl.SLOT_INDEX.BOT_LEFT then
				if self.slotBotLeftPreset then
					self.recordFaceData[self.slotBotLeftPreset] = nil
					self.recordBodyData[self.slotBotLeftPreset] = nil
				end

				self.slotBotLeftPreset = data.presetKey

				self:renderSlot(self.view.btnAdd2UButton, data.icon)
			elseif self.curSelectedSlotIndex == AvatarFusionCtrl.SLOT_INDEX.BOT_RIGHT then
				if self.slotBotRightPreset then
					self.recordFaceData[self.slotBotRightPreset] = nil
					self.recordBodyData[self.slotBotRightPreset] = nil
				end

				self.slotBotRightPreset = data.presetKey

				self:renderSlot(self.view.btnAdd3UButton, data.icon)
			end

			self:initPresetList()
			self:refreshPartsList()

			local exists = self:checkFirstExists()

			if not exists then
				self:findExistsPresetKey()

				self.pickedHairPreset = self.firstPick
				self.pickedMakeupPreset = self.firstPick

				self:changeToPresetHair(self.pickedHairPreset)
				self:changeToPresetMakeUp(self.pickedMakeupPreset)
			elseif self:countPick() == 1 then
				self.firstPick = data.presetKey
				self.pickedHairPreset = self.firstPick
				self.pickedMakeupPreset = self.firstPick

				self:changeToPresetHair(self.pickedHairPreset)
				self:changeToPresetMakeUp(self.pickedMakeupPreset)
			end
		end
	end

	function self.view.hairList.luaRenderItem(button, index, data)
		button.isSelected = false
		button.name = data.presetKey

		local objectReference = button:GetComponent("ObjectReference")
		local avatarUImage = objectReference:GetRefValue("avatarUImage")

		avatarUImage.url = data.icon

		if data.presetKey and data.presetKey == self.pickedHairPreset then
			button.isSelected = true
		end

		button.interactable = not data.empty

		function button.luaClick()
			if data.empty then
				return
			end

			self:changeToPresetHair(data.presetKey)

			self.pickedHairPreset = data.presetKey

			self:persistFusionProgress(true)

			local btns = self.view.hairList:GetAllButtons()

			for i = 0, btns.Length - 1 do
				btns[i].isSelected = btns[i].name == tostring(data.presetKey)
			end
		end
	end

	function self.view.makeUpList.luaRenderItem(button, index, data)
		button.isSelected = false
		button.name = data.presetKey

		local objectReference = button:GetComponent("ObjectReference")
		local avatarUImage = objectReference:GetRefValue("avatarUImage")

		avatarUImage.url = data.icon

		if data.presetKey and data.presetKey == self.pickedMakeupPreset then
			button.isSelected = true
		end

		button.interactable = not data.empty

		function button.luaClick()
			if data.empty then
				return
			end

			self:changeToPresetMakeUp(data.presetKey)

			self.pickedMakeupPreset = data.presetKey

			self:persistFusionProgress(true)

			local btns = self.view.makeUpList:GetAllButtons()

			for i = 0, btns.Length - 1 do
				btns[i].isSelected = btns[i].name == tostring(data.presetKey)
			end
		end
	end

	self.view.joyStickUJoyStick.clickMoveEnabled = true

	function self.view.joyStickUJoyStick.luaValueChangedWhileDragging(x, y)
		x = self.view.handleRectTransform.anchoredPosition.x / AvatarFusionCtrl.JOYSTICK_RANGE
		y = self.view.handleRectTransform.anchoredPosition.y / AvatarFusionCtrl.JOYSTICK_RANGE
		self.joyStickX = x
		self.joyStickY = y

		self:doRatioFusion()

		if self:emptyPick() then
			self:changeRootPage(0)
		else
			self:changeRootPage(2)
		end
	end

	function self.view.closeListUButton.luaClick()
		if self:emptyPick() then
			self:changeRootPage(0)
		else
			self:changeRootPage(2)
		end
	end
end

function AvatarFusionCtrl:checkFirstExists()
	if not self.firstPick then
		return false
	end

	if self.slotUpPreset == self.firstPick then
		return true
	end

	if self.slotBotLeftPreset == self.firstPick then
		return true
	end

	if self.slotBotRightPreset == self.firstPick then
		return true
	end

	self.firstPick = nil

	return false
end

function AvatarFusionCtrl:changeRootPage(state)
	self.view.root:TryChangePage("LeftState", state)

	if state == 0 or state == 2 then
		self.curSelectedSlotIndex = nil
		self.view.btnAdd1UButton.isSelected = false
		self.view.btnAdd2UButton.isSelected = false
		self.view.btnAdd3UButton.isSelected = false
	end
end

function AvatarFusionCtrl:renderSlot(button, icon, noLogic)
	if icon then
		local objectReference = button:GetComponent("ObjectReference")

		button:TryChangePage("State", 0)
		button:TryChangePage("State", 1)

		local avatarUImage = objectReference:GetRefValue("avatarUImage")

		avatarUImage.url = icon
	else
		button:TryChangePage("State", 0)
	end

	if noLogic then
		return
	end

	self:recordData()
	self:doRatioFusion()
	self:persistFusionProgress(true)
	self:setTipText()
end

function AvatarFusionCtrl:setTipText(onCreate)
	ClientTextUtils.setText(self.view.text1USDFText, pg.getGameString("AVATAR_FUSION_TIP_1"))
	ClientTextUtils.setText(self.view.text2USDFText, pg.getGameString("FACE_SLIDER_ADJUST"))
	ClientTextUtils.setText(self.view.text3USDFText, pg.getGameString("UI_PinchFace_ConsoleHandleTips"))

	local count = 0

	if self.slotUpPreset then
		count = count + 1
	end

	if self.slotBotLeftPreset then
		count = count + 1
	end

	if self.slotBotRightPreset then
		count = count + 1
	end

	self.view.text2USDFText.gameObject:SetActiveEx(count >= 2 and pg.game.input:isUsingGamepad() == false)
	self.view.text3USDFText.gameObject:SetActiveEx(count >= 2 and pg.game.input:isUsingGamepad() == true)
	self.view.rayBoxURayBox.gameObject:SetActiveEx(count < 2)

	if count >= 2 and self.lastCount < 2 then
		if not self.aniOnce and not onCreate then
			self.view.rightUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)

			self.aniOnce = true
		else
			self.view.rightUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User3)
		end

		self.view.btnUseUButton.interactable = true
	elseif count < 2 then
		self.view.rightUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User2)

		self.view.btnUseUButton.interactable = false
		self.joyStickX = 0
		self.joyStickY = 0
		self.view.handleRectTransform.anchoredPosition = Vector2.zero
	end

	self.lastCount = count
end

function AvatarFusionCtrl:findExistsPresetKey()
	if not self.firstPick then
		local allPresets = {
			self.slotUpPreset,
			self.slotBotLeftPreset,
			self.slotBotRightPreset
		}

		for _, presetKey in pairs(allPresets) do
			if presetKey then
				self.firstPick = presetKey

				break
			end
		end
	end
end

function AvatarFusionCtrl:registerAddBtnEvent(slotIndex, button)
	local objectReference = button:GetComponent("ObjectReference")
	local btnMinusUButton = objectReference:GetRefValue("btnMinusUButton")

	function btnMinusUButton.luaClick()
		button:TryChangePage("State", 0)

		local key

		if slotIndex == AvatarFusionCtrl.SLOT_INDEX.UP then
			key = self.slotUpPreset
			self.slotUpPreset = nil
		elseif slotIndex == AvatarFusionCtrl.SLOT_INDEX.BOT_LEFT then
			key = self.slotBotLeftPreset
			self.slotBotLeftPreset = nil
		elseif slotIndex == AvatarFusionCtrl.SLOT_INDEX.BOT_RIGHT then
			key = self.slotBotRightPreset
			self.slotBotRightPreset = nil
		end

		self:initPresetList()

		if self.recordFaceData[key] then
			self.recordFaceData[key] = nil
		end

		if self.recordBodyData[key] then
			self.recordBodyData[key] = nil
		end

		if self.firstPick == key then
			self.firstPick = nil

			self:findExistsPresetKey()
		end

		if self.firstPick then
			self.pickedHairPreset = self.firstPick

			self:changeToPresetHair(self.firstPick)

			self.pickedMakeupPreset = self.firstPick

			self:changeToPresetMakeUp(self.firstPick)
		else
			self.pickedHairPreset = nil
			self.pickedMakeupPreset = nil

			self:revertAll()
		end

		self:setTipText()
		self:doRatioFusion()
		self:refreshPartsList()
	end
end

function AvatarFusionCtrl:selectSlot(slotIndex, button)
	self.curSelectedSlotIndex = slotIndex

	if slotIndex == AvatarFusionCtrl.SLOT_INDEX.UP then
		button.isSelected = true
		self.view.btnAdd2UButton.isSelected = false
		self.view.btnAdd3UButton.isSelected = false
	elseif slotIndex == AvatarFusionCtrl.SLOT_INDEX.BOT_LEFT then
		self.view.btnAdd1UButton.isSelected = false
		button.isSelected = true
		self.view.btnAdd3UButton.isSelected = false
	elseif slotIndex == AvatarFusionCtrl.SLOT_INDEX.BOT_RIGHT then
		self.view.btnAdd1UButton.isSelected = false
		self.view.btnAdd2UButton.isSelected = false
		button.isSelected = true
	end

	self:initPresetList()
	self:changeRootPage(1)
end

function AvatarFusionCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function AvatarFusionCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.avatarScene:addCameraZoomKeyBinding(self.view.root.gameObject)
end

function AvatarFusionCtrl:refreshConsoleBarState()
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_AvatarFusion_CameraZoom", true)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_AvatarFusion_CameraMove", true)
end

function AvatarFusionCtrl:onShow()
	return
end

function AvatarFusionCtrl:onHide()
	return
end

function AvatarFusionCtrl:emptyPick()
	return self.slotUpPreset == nil and self.slotBotLeftPreset == nil and self.slotBotRightPreset == nil
end

function AvatarFusionCtrl:countPick()
	local count = 0

	if self.slotUpPreset then
		count = count + 1
	end

	if self.slotBotLeftPreset then
		count = count + 1
	end

	if self.slotBotRightPreset then
		count = count + 1
	end

	return count
end

function AvatarFusionCtrl:compareRecordedFusionData()
	local isDiff = false

	if self.fusionData.slotUp ~= self.slotUpPreset then
		isDiff = true
	end

	if self.fusionData.slotBotLeft ~= self.slotBotLeftPreset then
		isDiff = true
	end

	if self.fusionData.slotBotRight ~= self.slotBotRightPreset then
		isDiff = true
	end

	if math.abs(self.fusionData.joyStickX - self.joyStickX) > 0.0001 then
		isDiff = true
	end

	if math.abs(self.fusionData.joyStickY - self.joyStickY) > 0.0001 then
		isDiff = true
	end

	if self.fusionData.pickedHairPreset ~= self.pickedHairPreset then
		isDiff = true
	end

	if self.fusionData.pickedMakeupPreset ~= self.pickedMakeupPreset then
		isDiff = true
	end

	if self.fusionData.firstPick ~= self.firstPick then
		isDiff = true
	end

	return isDiff
end

function AvatarFusionCtrl:closePanel()
	if self.backFunc ~= nil then
		self.backFunc()
	end

	self.avatarScene.pauseAutoSave = false

	pg.global.ui:close(UIConst.UI_ID_AVATAR_FUSION)
end

function AvatarFusionCtrl:onVisibleChange(visible)
	if visible then
		self.avatarScene:registerGesture(self.uid)
		self.avatarScene:setAvatarCameraModeCloseHead()
	else
		self.avatarScene:unRegisterGesture(self.uid)
	end
end

function AvatarFusionCtrl:collectAllEditReactionFacePartId(presetKey, isOrigin)
	local ret = {}
	local facePresetKey = AvatarUtils.getPartAssetIdByPreset(presetKey, "face")
	local AvatarFaceData = require(string.format("Data.Avatar.face.face_%s_data", facePresetKey))
	local originConfig = Utils.deepCopyTable(AvatarFaceData)
	local sortedGroup = AvatarUtils.getSortedGroup(originConfig)
	local sortedKind = AvatarUtils.getSortedKind(originConfig)
	local runtimeDataResId = pg.global.avatarMgr:GetRuntimeDataResID(presetKey)

	for _, v in pairs(sortedGroup) do
		local groupKey = v.key

		for _, v2 in pairs(sortedKind[groupKey]) do
			local kindKey = v2.key
			local reactions = self.model:getReactions(originConfig, groupKey, kindKey)

			for _, reactionData in pairs(reactions) do
				ret[reactionData.key] = isOrigin and avatarFace:GetReactionValue(reactionData.key) or pg.global.avatarMgr:GetRuntimeFaceDataRes(runtimeDataResId, reactionData.key)
			end
		end
	end

	return ret
end

function AvatarFusionCtrl:collectAllEditReactionBodyPartId(presetKey, isOrigin)
	local ret = {}
	local bodyPresetKey = AvatarUtils.getPartAssetIdByPreset(presetKey, "body")
	local AvatarBodyData = require(string.format("Data.Avatar.body.body_%s_data", bodyPresetKey))
	local originConfig = Utils.deepCopyTable(AvatarBodyData)
	local sortedGroup = AvatarUtils.getSortedGroup(originConfig)
	local sortedKind = AvatarUtils.getSortedKind(originConfig)
	local runtimeDataResId = pg.global.avatarMgr:GetRuntimeDataResID(presetKey)

	for _, v in pairs(sortedGroup) do
		local groupKey = v.key

		for _, v2 in pairs(sortedKind[groupKey]) do
			local kindKey = v2.key
			local reactions = self.model:getReactions(originConfig, groupKey, kindKey)

			for _, reactionData in pairs(reactions) do
				ret[reactionData.key] = isOrigin and avatarBody:GetReactionValue(reactionData.key) or pg.global.avatarMgr:GetRuntimeBodyDataRes(runtimeDataResId, reactionData.key)
			end
		end
	end

	return ret
end

function AvatarFusionCtrl:recordData()
	if self.slotUpPreset ~= nil then
		self.recordFaceData[self.slotUpPreset] = self:collectAllEditReactionFacePartId(self.slotUpPreset)
		self.recordBodyData[self.slotUpPreset] = self:collectAllEditReactionBodyPartId(self.slotUpPreset)
	end

	if self.slotBotLeftPreset ~= nil then
		self.recordFaceData[self.slotBotLeftPreset] = self:collectAllEditReactionFacePartId(self.slotBotLeftPreset)
		self.recordBodyData[self.slotBotLeftPreset] = self:collectAllEditReactionBodyPartId(self.slotBotLeftPreset)
	end

	if self.slotBotRightPreset ~= nil then
		self.recordFaceData[self.slotBotRightPreset] = self:collectAllEditReactionFacePartId(self.slotBotRightPreset)
		self.recordBodyData[self.slotBotRightPreset] = self:collectAllEditReactionBodyPartId(self.slotBotRightPreset)
	end
end

function AvatarFusionCtrl:initPresetList()
	local alreadyContains = {}

	if self.slotUpPreset ~= nil then
		alreadyContains[self.slotUpPreset] = true
	end

	if self.slotBotLeftPreset ~= nil then
		alreadyContains[self.slotBotLeftPreset] = true
	end

	if self.slotBotRightPreset ~= nil then
		alreadyContains[self.slotBotRightPreset] = true
	end

	local bodyInfo = self.model:getPresetList(self.body, alreadyContains)

	self.view.listUList:SetList(bodyInfo)
end

function AvatarFusionCtrl:calculateRatios(x, y, enableA, enableB, enableC)
	enableA = enableA == true
	enableB = enableB == true
	enableC = enableC == true

	local enabledCount = (enableA and 1 or 0) + (enableB and 1 or 0) + (enableC and 1 or 0)

	if enabledCount == 1 then
		return {
			A = enableA and 1 or 0,
			B = enableB and 1 or 0,
			C = enableC and 1 or 0
		}
	end

	if enabledCount == 0 then
		return {
			C = 0,
			B = 0,
			A = 0
		}
	end

	local pointA = {
		y = 1,
		x = 0
	}
	local pointB = {
		y = -0.5,
		x = -math.sqrt(3) / 2
	}
	local pointC = {
		y = -0.5,
		x = math.sqrt(3) / 2
	}
	local dA_sq = (x - pointA.x)^2 + (y - pointA.y)^2
	local dB_sq = (x - pointB.x)^2 + (y - pointB.y)^2
	local dC_sq = (x - pointC.x)^2 + (y - pointC.y)^2
	local epsilon = 1e-06
	local wA = enableA and 1 / (dA_sq + epsilon) or 0
	local wB = enableB and 1 / (dB_sq + epsilon) or 0
	local wC = enableC and 1 / (dC_sq + epsilon) or 0
	local total = wA + wB + wC
	local ratioA = enableA and wA / total or 0
	local ratioB = enableB and wB / total or 0
	local ratioC = enableC and wC / total or 0

	return {
		A = ratioA,
		B = ratioB,
		C = ratioC
	}
end

function AvatarFusionCtrl:doRatioFusion()
	local ratio = self:calculateRatios(self.joyStickX, self.joyStickY, self.slotUpPreset ~= nil, self.slotBotLeftPreset ~= nil, self.slotBotRightPreset ~= nil)

	self.resultFaceData = {}
	self.resultBodyData = {}

	if self.slotUpPreset and self.recordFaceData[self.slotUpPreset] then
		for key, value in pairs(self.recordFaceData[self.slotUpPreset]) do
			self.resultFaceData[key] = (self.resultFaceData[key] or 0) + value * ratio.A
		end
	end

	if self.slotUpPreset and self.recordBodyData[self.slotUpPreset] then
		for key, value in pairs(self.recordBodyData[self.slotUpPreset]) do
			self.resultBodyData[key] = (self.resultBodyData[key] or 0) + value * ratio.A
		end
	end

	if self.slotBotLeftPreset and self.recordFaceData[self.slotBotLeftPreset] then
		for key, value in pairs(self.recordFaceData[self.slotBotLeftPreset]) do
			self.resultFaceData[key] = (self.resultFaceData[key] or 0) + value * ratio.B
		end
	end

	if self.slotBotLeftPreset and self.recordBodyData[self.slotBotLeftPreset] then
		for key, value in pairs(self.recordBodyData[self.slotBotLeftPreset]) do
			self.resultBodyData[key] = (self.resultBodyData[key] or 0) + value * ratio.B
		end
	end

	if self.slotBotRightPreset and self.recordFaceData[self.slotBotRightPreset] then
		for key, value in pairs(self.recordFaceData[self.slotBotRightPreset]) do
			self.resultFaceData[key] = (self.resultFaceData[key] or 0) + value * ratio.C
		end
	end

	if self.slotBotRightPreset and self.recordBodyData[self.slotBotRightPreset] then
		for key, value in pairs(self.recordBodyData[self.slotBotRightPreset]) do
			self.resultBodyData[key] = (self.resultBodyData[key] or 0) + value * ratio.C
		end
	end

	if next(self.resultFaceData) ~= nil then
		avatarFace:ManualBatchEditReactionData(self.resultFaceData)
	end

	if next(self.resultBodyData) ~= nil then
		avatarBody:ManualBatchEditReactionData(self.resultBodyData)
	end

	self:persistFusionProgress(false)
end

function AvatarFusionCtrl:revertAll()
	self.avatarScene:showAvatarTemplate(self.presetKey, function()
		self.avatarScene:setCurEntityRot(0)
	end, nil, true)
	pg.game.avatar:setFusionData()

	AvatarUtils.hairAssetIdRecord = nil
end

function AvatarFusionCtrl:randomPick()
	local now = Time.realtimeSinceStartup

	if self._randomPickBusy or now < (self._nextRandomPickAllowedTime or 0) then
		return
	end

	self._nextRandomPickAllowedTime = now + (CS.UnityEngine.Application.isEditor and 1.2 or 0.35)

	self:_setRandomPickBusy(true)

	self.recordFaceData = {}
	self.recordBodyData = {}

	local choices = self.model:getRandomThreePreset(self.body)

	self.slotUpPreset = choices[1] and choices[1].presetKey or nil
	self.slotBotLeftPreset = choices[2] and choices[2].presetKey or nil
	self.slotBotRightPreset = choices[3] and choices[3].presetKey or nil

	self:renderSlot(self.view.btnAdd1UButton, choices[1] and choices[1].icon or nil, true)
	self:renderSlot(self.view.btnAdd2UButton, choices[2] and choices[2].icon or nil, true)
	self:renderSlot(self.view.btnAdd3UButton, choices[3] and choices[3].icon or nil, true)
	self:recordData()

	local theta = math.random() * 2 * math.pi
	local r = math.sqrt(math.random())
	local x = r * math.cos(theta)
	local y = r * math.sin(theta)

	self.joyStickX = x
	self.joyStickY = y
	self.view.handleRectTransform.anchoredPosition = Vector2(AvatarFusionCtrl.JOYSTICK_RANGE * self.joyStickX, AvatarFusionCtrl.JOYSTICK_RANGE * self.joyStickY)

	self:setTipText()
	self:doRatioFusion()

	self.curSelectedSlotIndex = nil

	if #choices < 1 then
		self.pickedHairPreset = nil
		self.pickedMakeupPreset = nil

		self:changeToPresetHair(self.presetKey)
		self:changeToPresetMakeUp(self.presetKey)
		self:refreshPartsList()

		return
	end

	local hairChoice = math.random(1, #choices)
	local makeupChoice = math.random(1, #choices)
	local hairC = choices[hairChoice]
	local makeupC = choices[makeupChoice]

	self.pickedHairPreset = hairC.presetKey
	self.pickedMakeupPreset = makeupC.presetKey

	self:changeToPresetHair(hairC.presetKey)
	self:changeToPresetMakeUp(makeupC.presetKey)

	self.firstPick = choices[1].presetKey

	self:refreshPartsList()
	self:persistFusionProgress(true)
	self:_setRandomPickBusy(false)
end

function AvatarFusionCtrl:refreshPartsList()
	local bodyInfo = self.model:getPickPresetList(self.slotUpPreset, self.slotBotLeftPreset, self.slotBotRightPreset)

	self.view.hairList:SetList(bodyInfo)
	self.view.makeUpList:SetList(bodyInfo)

	if not next(bodyInfo) then
		self:changeRootPage(0)
	end
end

function AvatarFusionCtrl:changeToPresetHair(preset)
	if not preset then
		return
	end

	local newAssetId = AvatarUtils.getPartAssetIdByPreset(preset, "hair")

	avatarHair:ManualChangeToPresetHair(preset, newAssetId)

	AvatarUtils.hairAssetIdRecord = newAssetId
end

function AvatarFusionCtrl:changeToPresetMakeUp(preset)
	if not preset then
		return
	end

	avatarMakeup:ManualChangeToPresetMakeUp(preset)

	if self._makeupRefreshTimerId then
		self:killTimer(self._makeupRefreshTimerId)

		self._makeupRefreshTimerId = nil
	end

	self._makeupRefreshTimerId = self:startTimer(function()
		self._makeupRefreshTimerId = nil

		local ent = self.avatarScene and self.avatarScene:getCurEntity()

		if not ent or not ent.eModel then
			return
		end

		ent.eModel.modelModelView:RefreshDecal()
	end, 0.1)
end

return AvatarFusionCtrl
