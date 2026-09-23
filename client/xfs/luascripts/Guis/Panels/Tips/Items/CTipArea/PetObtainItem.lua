-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CTipArea\\PetObtainItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UICtrl = require("Guis.UICtrl")
local PetObtainItem = Class.LightClass("PetObtainItem", BaseQueueItem)
local Const = require("Common.Const.Const")
local PetData = require("Data.pet_data")
local GIVE_PET_GAMEPAD_ACTION = "Hud/GivePet"
local GIVE_PET_PRESS_NAME = GIVE_PET_GAMEPAD_ACTION .. "press"
local GIVE_PET_PRESS_TIME_NAME = GIVE_PET_GAMEPAD_ACTION .. "pressTime"
local INTERVAL_POP_Pet = 0.2
local PET_GOT_SHOW_SECONDS = 4
local PET_GOT_SHOW_SECONDS2 = 1
local PET_OBTAIN_DURATION_CONFIG = {
	decreasePerItem = 1,
	threshold = 3,
	defaultDuration = PET_GOT_SHOW_SECONDS,
	minDuration = PET_GOT_SHOW_SECONDS2
}
local GM_MASK_EXTRA_DURATION = 5

function PetObtainItem:onInit()
	self:setMaxLimit(3, true)
	self:setDynamicDurationConfig(PET_OBTAIN_DURATION_CONFIG)

	self.scrollList = self.uWidget
	self.keyItemDataMap = {}

	function self.scrollList.luaRenderItem(item, data)
		self:RenderItem(item, data)
	end

	self.delayTime = 0
end

function PetObtainItem:pushData(data)
	for _, v in ipairs(data.newPets or {}) do
		self:enqueue(v)
	end
end

function PetObtainItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function PetObtainItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	if Time.realSecondCache < self.delayTime then
		return
	end

	self.delayTime = Time.realSecondCache + INTERVAL_POP_Pet

	local data = self:dequeue()
	local duration = data.duration or PET_GOT_SHOW_SECONDS

	data.endTime = Time.realSecondCache + duration

	if GmToolUtils.openMask then
		data.endTime = data.endTime + GM_MASK_EXTRA_DURATION
	end

	self:addRunItem(data)
	self.scrollList:PushRenderItem(data)
	self:refreshHotKeyVisible()
end

function PetObtainItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function PetObtainItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function PetObtainItem:cancelGivePetLongPress(data)
	if data and self.givePetPressData ~= data then
		return
	end

	if self[GIVE_PET_PRESS_NAME] then
		self:killTimer(self[GIVE_PET_PRESS_NAME])

		self[GIVE_PET_PRESS_NAME] = nil
	end

	self[GIVE_PET_PRESS_TIME_NAME] = nil

	if self.givePetPressProgress and not IsNil(self.givePetPressProgress) then
		self.givePetPressProgress:ProgressToValue(0, nil, 0)
	end

	self.givePetPressData = nil
	self.givePetPressProgress = nil
end

function PetObtainItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.User2)
end

function PetObtainItem:RenderItem(item, data)
	self:refreshSingleView(item, data)
	self:refreshHotKeyVisible()
	item:InvokeCallback(CS.XGUI.EInvokeTime.User1)
end

function PetObtainItem:isLatestData(data)
	return data ~= nil and data == self.runList[#self.runList]
end

function PetObtainItem:refreshHotKeyVisible()
	local maxNum = #self.runList
	local showKey = true

	for i = maxNum, 1, -1 do
		local data = self.runList[i]
		local isLastData = showKey

		showKey = false

		local showGetPetKey = data._showGetPetKey and isLastData
		local showGivePetKey = data._showGivePetKey and isLastData
		local showKeyList = data._showKeyList and isLastData

		if data._listKeyUList then
			data._listKeyUList:SetActiveFastest(showKeyList)
		end

		if data._hotKeyUWidget then
			data._hotKeyUWidget:SetActiveFastest(showKeyList or showGetPetKey)
		end

		if data._bindCloseSinglePet then
			data._bindCloseSinglePet.enabled = showKeyList
		end

		if data._showGetPetKey ~= nil and data._bindGetSinglePet then
			data._bindGetSinglePet.enabled = showGetPetKey
		end

		if data._bindGivePetBind then
			data._bindGivePetBind.enabled = showGivePetKey
		end

		if not showGivePetKey then
			self:cancelGivePetLongPress(data)
		end
	end
end

function PetObtainItem:refreshSingleView(item, data)
	item = item:GetComponent("ObjectReference")
	data._showGetPetKey = false
	data._showGivePetKey = false
	data._showKeyList = false

	local button = item:GetRefValue("button")

	button.luaClick = nil

	self:clearHotKeyBindByPath(button.gameObject, "Hud/GetSinglePet")

	data._bindGetSinglePet = nil

	local headIcon = item:GetRefValue("headIcon")
	local name = item:GetRefValue("name")
	local lv = item:GetRefValue("lv")
	local hotKeyUWidget = item:GetRefValue("hotKeyUWidget")
	local listTagUList = item:GetRefValue("listTagUList")
	local listKeyUList = item:GetRefValue("listKeyUList")
	local petHeadObjectReference = item:GetRefValue("petHeadObjectReference")
	local textFriendSendUSDFText = item:GetRefValue("textFriendSendUSDFText")
	local btnGiveUButton = item:GetRefValue("btnGiveUButton")

	btnGiveUButton.luaClick = nil

	local umbralUContainer = petHeadObjectReference:GetRefValue("umbralUContainer")
	local petInfo = pg.me:getPetInfo(data.id)

	data.shinyStyle = data.shinyStyle or petInfo and petInfo.shinyStyle or 0

	if data.isDark then
		umbralUContainer:SetActive(true)
		umbralUContainer:LoadDefaultUrlManually()
	else
		umbralUContainer:SetActive(false)
	end

	data._listKeyUList = listKeyUList

	function listTagUList.luaRenderItem(btn, _, tagData)
		LuaUIUtils.renderPetTagList(btn, tagData)
		LuaUIUtils.setPetTagLabelToolTip(btn, LuaUIUtils.getPetTagInfo(data.templateId, data.label, data.bodySizeType, data.shinyStyle))
		btn:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end

	local petTagList = LuaUIUtils.getPetTagList(data, true)

	listTagUList:SetList(petTagList)

	if #petTagList > 0 then
		if not data._singlePetRumblePlayed then
			data._singlePetRumblePlayed = true

			pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonMiddle")
		end

		self:startTimer(function()
			pg.game.audio:triggerEvent("SFX_UI_GetSinglePet_Special")
		end, 0.5)
	end

	data._hotKeyUWidget = hotKeyUWidget

	if data.isRare or data.isBoss then
		pg.game.audio:triggerEvent("ui_hud_catch_single_rare")
	else
		pg.game.audio:triggerEvent("ui_hud_catch_single_normal")
	end

	headIcon.url = LuaUIUtils.getPetIcon(data.headIconName, LuaUIUtils.PET_ICON, data.label, data.gender)

	local isMobile = pg.global.ui:runPlatformByMobile()
	local isDouYinOffline = ClientUtils.isInDouYinOfflineScene()
	local canShowKeyList = not isMobile and not isDouYinOffline
	local canOpenPetManagement = canShowKeyList and LuaUIUtils.checkFuncUnlock(Const.FUNCTION_IDS.PETENTRY)

	listKeyUList:SetActiveFastest(false)
	button:TryChangePage("GiveAway", 0)

	local showGiveKey = false

	if not isDouYinOffline and petInfo then
		local giveFromUid = pg.me:getPetGiveFromUid(petInfo)

		if giveFromUid and giveFromUid ~= "" then
			button:TryChangePage("GiveAway", 2)
			ClientTextUtils.setText(textFriendSendUSDFText, pg.getGameString("COMPANION_GIFT"))
		elseif pg.game.chat:checkCanGivePetAway(data.id) then
			button:TryChangePage("GiveAway", 1)

			function btnGiveUButton.luaClick()
				self:onGivePet(data)
			end

			if canShowKeyList then
				showGiveKey = true
				data._showGivePetKey = true
			end
		end
	end

	if canShowKeyList then
		data._showKeyList = true

		function listKeyUList.luaRenderItem(btn, index, keyData)
			self:_renderKeyItem(btn, index, keyData)
		end

		local keyListData = {
			{
				actionKey = "Hud/ItemClose",
				label = pg.getGameString("CLOSE")
			}
		}

		if canOpenPetManagement then
			keyListData[#keyListData + 1] = {
				actionKey = "Hud/GetSinglePet",
				label = pg.getGameString("CONSOLE_BAR_VIEW"),
				hotKeyObject = button.gameObject,
				longPressFunc = function()
					if button.luaClick then
						button.luaClick()
					end
				end,
				onBound = function(hotKeyBind)
					if data.removing then
						hotKeyBind.enabled = false

						return
					end

					data._bindGetSinglePet = hotKeyBind

					self:refreshHotKeyVisible()
				end
			}
		end

		if showGiveKey then
			keyListData[#keyListData + 1] = {
				isGivePet = true,
				actionKey = GIVE_PET_GAMEPAD_ACTION,
				label = pg.getGameString("PET_INFO_GIVE_AWAY"),
				petObtainData = data
			}
		end

		listKeyUList:SetList(keyListData)

		data._bindCloseSinglePet = LuaUIUtils.bindHotKey(button.gameObject, "Hud/ItemClose", function()
			self:recycleToast(data)
		end, nil, 100)
	end

	ClientTextUtils.setText(name, pg.getLocalizationText(data.name))
	button:TryChangePage("NotVerified", 1)

	lv.text = "Lv." .. data.lv

	if data.isRare == true then
		local petInfo = not isDouYinOffline and data.id and pg.me:getPetInfo(data.id)
		local shinyStyle = data.shinyStyle or petInfo and petInfo.shinyStyle or 0

		if shinyStyle == Const.PET_SHINY_STYLE.BLACK then
			button:TryChangePage("Flash", 2)
		elseif shinyStyle == Const.PET_SHINY_STYLE.WHITE then
			button:TryChangePage("Flash", 3)
		else
			button:TryChangePage("Flash", 0)
		end

		LuaUIUtils.renderPetHeadFlashBgAndFrame(petHeadObjectReference, true, shinyStyle)
	else
		button:TryChangePage("Flash", 1)
		LuaUIUtils.renderPetHeadFlashBgAndFrame(petHeadObjectReference, false)
	end

	if isDouYinOffline then
		data._showKeyList = false
		data._showGetPetKey = false

		listKeyUList:SetActiveFastest(false)
		hotKeyUWidget:SetActiveFastest(false)

		return
	end

	if canOpenPetManagement then
		data._showGetPetKey = true

		hotKeyUWidget:SetActiveFastest(true)

		function button.luaClick()
			self:_openPetManagement(data)
		end
	else
		hotKeyUWidget:SetActiveFastest(data._showKeyList)
	end
end

function PetObtainItem:_openPetManagement(data)
	pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT, {
		petId = data.id
	})
	self:recycleToast(data)
	pg.game.audio:triggerEvent("ui_sfx_button")
end

function PetObtainItem:onGivePet(data)
	if not data then
		return
	end

	self:cancelGivePetLongPress(data)

	if data.removing or not pg.game.chat:checkCanGivePetAway(data.id) then
		return
	end

	pg.game.chat:openSpaceFollowPetGivePanel(data.id)
	self:recycleToast(data)
end

function PetObtainItem:onGivePetHotKey(inputInfo, keyData, progress)
	local petObtainData = keyData.petObtainData

	if inputInfo.phase == "Performed" then
		if not self:isLatestData(petObtainData) or petObtainData.removing or not petObtainData._showGivePetKey then
			return false
		end

		self:cancelGivePetLongPress()

		self.givePetPressData = petObtainData
		self.givePetPressProgress = progress
	elseif inputInfo.phase == "Canceled" and self.givePetPressData ~= petObtainData then
		return false
	end

	UICtrl.longClickLuafunction(self, inputInfo, keyData.actionKey, 0.55, 0.25, function()
		if not self:isLatestData(petObtainData) then
			self:cancelGivePetLongPress(petObtainData)

			return
		end

		self:onGivePet(petObtainData)
	end, progress)

	if inputInfo.phase == "Canceled" and not self[GIVE_PET_PRESS_NAME] then
		self.givePetPressData = nil
		self.givePetPressProgress = nil
	end

	return false
end

function PetObtainItem:_renderKeyItem(button, index, keyData)
	local objectReference = button:GetComponent("ObjectReference")
	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
	local btnTipsUText = objectReference:GetRefValue("btnTipsUText")
	local progressPressContainerUContainer = objectReference:GetRefValue("progressPressContainerUContainer")
	local keyBinding = button:GetComponent("KeyBindingPro")

	keyHotKeyContent:SetHotKeyPaths(keyData.actionKey)
	ClientTextUtils.setText(btnTipsUText, keyData.label)

	if keyBinding then
		local oldKeyData = self.keyItemDataMap[keyBinding]

		if oldKeyData and oldKeyData.petObtainData then
			self:cancelGivePetLongPress(oldKeyData.petObtainData)
		end

		self.keyItemDataMap[keyBinding] = keyData
		keyBinding.enabled = false
		keyBinding.luaTrigger = nil
	end

	if progressPressContainerUContainer then
		progressPressContainerUContainer:SetActive(keyData.isGivePet == true or keyData.longPressFunc ~= nil)
	end

	if keyData.longPressFunc then
		self:bindHotKeyItemLongPress(objectReference, keyData)

		return
	end

	if not keyData.isGivePet or not keyBinding or not progressPressContainerUContainer then
		return
	end

	progressPressContainerUContainer:LoadDefaultUrlManually(function(progress)
		local petObtainData = keyData.petObtainData

		if IsNil(progress) or IsNil(keyBinding) or not petObtainData or self.keyItemDataMap[keyBinding] ~= keyData then
			return
		end

		progress:ProgressToValue(0, nil, 0)

		keyBinding.actionPath = keyData.actionKey
		keyBinding.isVirtual = true
		keyBinding.priority = 10000
		keyBinding.enabled = not petObtainData.removing and petObtainData._showGivePetKey and self:isLatestData(petObtainData)

		function keyBinding.luaTrigger(inputInfo)
			return self:onGivePetHotKey(inputInfo, keyData, progress)
		end

		petObtainData._bindGivePetBind = keyBinding
	end)
end

function PetObtainItem:GMPushData(data)
	local petCandidates = {}

	for _, petInfo in pairs(pg.me and pg.me.pets or {}) do
		if petInfo and PetData[petInfo.templateId] then
			petCandidates[#petCandidates + 1] = petInfo
		end
	end

	local newPets = {}

	if #petCandidates > 0 then
		local maxCount = math.min(#petCandidates, math.max(self.maxRunNum or 3, 1))
		local petCount = math.random(1, maxCount)

		for i = 1, petCount do
			local randomIndex = math.random(1, #petCandidates)
			local petInfo = table.remove(petCandidates, randomIndex)
			local petData = PetData[petInfo.templateId]
			local label = petInfo.label

			newPets[i] = {
				elementTypes = petData.elementType,
				gender = petInfo.gender,
				headIconName = petData.iconName,
				iconName = petData.iconName,
				id = petInfo.id,
				isBoss = Utils.isLabelElite(label),
				isDark = Utils.isLabelDark(label),
				isRare = Utils.isLabelShiny(label),
				isVariant = Utils.isLabelVariant(label),
				label = label,
				lv = petInfo.level,
				name = petData.name,
				templateId = petInfo.templateId,
				bodySizeType = petInfo.bodySizeType,
				shinyStyle = petInfo.shinyStyle
			}
		end
	end

	data.newPets = newPets
end

function PetObtainItem:onDestroy()
	self:cancelGivePetLongPress()

	self.keyItemDataMap = {}

	BaseQueueItem.onDestroy(self)
end

function PetObtainItem:getRecycleTarget(data)
	return self:getListRecycleTarget(data)
end

function PetObtainItem:onRecycleCleanup(data, target, reason)
	self:cleanupRecycleList(data, target, reason)
end

function PetObtainItem:onRecycleStarted(data, target)
	self:cancelGivePetLongPress(data)

	if data._bindGivePetBind then
		data._bindGivePetBind.enabled = false
	end
end

function PetObtainItem:onRecycleFinished(data, reason)
	self:refreshHotKeyVisible()
end

return PetObtainItem
