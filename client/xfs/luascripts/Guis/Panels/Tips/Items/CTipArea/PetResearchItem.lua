-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CTipArea\\PetResearchItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local TaskData = require("Data.badge_task_data")
local SysConfigData = require("Data.sys_config_data")
local PetResearchItem = Class.LightClass("PetResearchItem", BaseQueueItem)
local PetResearchTargetData = require("Data.pet_research_target_data")
local PetResearchResultData = require("Data.pet_research_result_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local Utils = require("Common.Utils.Utils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetResearchItem")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local POP_SPEED = 0.25
local CLOSE_ACTION_PATH = "Hud/ItemClose"
local PET_RESEARCH_HOTKEY_PATH = "Hud/PetFirstOpenPetHandBook"
local PET_RESEARCH_DURATION_CONFIG = {
	defaultDuration = 4,
	minDuration = 1,
	decreasePerItem = 1,
	threshold = 3
}

function PetResearchItem:clearHotKeyBind(hotKeyBind)
	if hotKeyBind then
		hotKeyBind.luaTrigger = nil
		hotKeyBind.enabled = false
	end
end

function PetResearchItem:clearItemHotKey(obj, path)
	self:clearHotKeyBind(KeyBindingPro.GetKeyBindingByName(obj, path))
end

function PetResearchItem:bindItemHotKey(obj, path, func, priority)
	local hotKeyBind = LuaUIUtils.bindHotKey(obj, path, func, nil, priority)

	if hotKeyBind then
		hotKeyBind.enabled = true
	end

	return hotKeyBind
end

PetResearchItem.ITEM_TYPE = {
	TOPIC = 2,
	HABIT = 1,
	EVOLUTION = 3
}

local ICON_PAGE_BY_ITEM_TYPE = {
	[PetResearchItem.ITEM_TYPE.HABIT] = 0,
	[PetResearchItem.ITEM_TYPE.EVOLUTION] = 1,
	[PetResearchItem.ITEM_TYPE.TOPIC] = 2
}

function PetResearchItem:getItemType(data)
	if data.isTopic or data.tab == PetResearchUtils.TAB_IDX.TOPIC then
		return self.ITEM_TYPE.TOPIC
	elseif data.evolveId then
		return self.ITEM_TYPE.EVOLUTION
	end

	return self.ITEM_TYPE.HABIT
end

function PetResearchItem:onInit()
	self:setMaxLimit(3, true)
	self:setDynamicDurationConfig(PET_RESEARCH_DURATION_CONFIG)

	self.scrollList = self.uWidget

	function self.scrollList.luaRenderItem(item, data)
		self:RenderItem(item, data)
	end

	self.delayTime = 0
	self.notMobile = not pg.global.ui:runPlatformByMobile()
end

function PetResearchItem:pushData(data)
	if data.fromCommon == true then
		self:enqueue(data)

		return
	end

	if self:checkCondition(data.templateId) or data.GMMode then
		self:enqueue(data)
	end
end

function PetResearchItem:checkCondition(templateId)
	local player = pg.me

	if not player:checkFunctionUnlock("PETRESEARCH") then
		return false
	end

	templateId = Utils.getBasePetPrototypeId(templateId)

	local playerHandBookMap = player.petHandbookMap
	local isCatched = playerHandBookMap:isCatched(templateId)

	if not isCatched then
		return false
	end

	return true
end

function PetResearchItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function PetResearchItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	if Time.realSecondCache < self.delayTime then
		return
	end

	self.delayTime = Time.realSecondCache + POP_SPEED

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or PET_RESEARCH_DURATION_CONFIG.defaultDuration)

	if GmToolUtils.openMask then
		data.endTime = data.endTime + 5
	end

	self:addRunItem(data)
	self.scrollList:PushRenderItem(data)
end

function PetResearchItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function PetResearchItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function PetResearchItem:recycleToast(data, force, closeCallback)
	if closeCallback and not data.recycleCloseCallback then
		data.recycleCloseCallback = closeCallback
	end

	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.User2)
end

function PetResearchItem:finishRecycleToast(data, force)
	self:completeRecycle(data, force)
end

function PetResearchItem:destroyItem(data, force)
	self:completeRecycle(data, force)
end

function PetResearchItem:hideById(templateId)
	local curTime = Time.realSecondCache

	for _, v in ipairs(self.runList) do
		if v.templateId == templateId then
			v.endTime = curTime
		end
	end

	local dataNum = #self.dataQueue

	for i = dataNum, 1, -1 do
		local item = self.dataQueue[i]

		if item.templateId == templateId then
			table.remove(self.dataQueue, i)
		end
	end
end

function PetResearchItem:RenderItem(item, data)
	if data.fromCommon == true then
		self:renderCommonTopicItem(item, data)
	else
		self:renderItem(item, data)
		pg.game.audio:playPetEmotionSound(data.templateId, "Happy")
	end

	self:hideOtherBindKey()
	item:InvokeCallback(CS.XGUI.EInvokeTime.User1)
end

function PetResearchItem:renderItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local petUImage = objectReference:GetRefValue("petUImage")
	local titleUText = objectReference:GetRefValue("titleUText")
	local descUText = objectReference:GetRefValue("descUText")
	local nodeUComponent = objectReference:GetRefValue("nodeUComponent")
	local keyKeyBindingPro = objectReference:GetRefValue("keyKeyBindingPro")
	local rewardItemUButton = objectReference:GetRefValue("rewardItemUButton")
	local taskListUList = objectReference:GetRefValue("taskListUList")
	local iconNewFeaturesUImage = objectReference:GetRefValue("iconNewFeaturesUImage")
	local listKeyUList = objectReference:GetRefValue("listKeyUList")
	local templateId = data.templateId
	local handBookInfo = pg.me.petHandbookMap[templateId]
	local label = handBookInfo and handBookInfo:isShinyCatched() and Const.PET_LABEL_MASK.SHINY or 0
	local itemType = self:getItemType(data)
	local isTopic = itemType == self.ITEM_TYPE.TOPIC
	local adaptiveText = 0
	local title = data.title and pg.getLocalizationText(data.title) or ""
	local desc = data.desc and pg.getLocalizationText(data.desc) or ""
	local subPageIdx = data.subPageIdx or UIConst.HANDBOOK_PAGE_IDX.SURVEY

	button:TryChangePage("IconNewFeatures", ICON_PAGE_BY_ITEM_TYPE[itemType])
	LuaUIUtils.setUIViewVisible(rewardItemUButton, false)

	if isTopic then
		adaptiveText = 1

		local conditionIdx = data.sn
		local templateTopicData = PetResearchTargetData[templateId]
		local topicData = templateTopicData and templateTopicData[conditionIdx] or {}
		local conditions = topicData.condition or {}
		local index = data.index or 0
		local tipsIconData = SysConfigData.TIPS_SIDE_ICON

		if tipsIconData then
			iconNewFeaturesUImage.url = tipsIconData[0]
		end

		title = pg.getLocalizationText(PetResearchResultData.dataStatistic.title)
		desc = pg.getLocalizationText(topicData.conditionDesc)
		subPageIdx = UIConst.HANDBOOK_PAGE_IDX.TOPIC
		taskListUList.luaRenderItem = self:guardRunCallback(data, function(progressButton, progressIndex)
			progressButton:TryChangePage("state", progressIndex + 1 <= index and 1 or 0)
		end)

		local progress = {}

		for _ = 1, #conditions do
			progress[#progress + 1] = {}
		end

		taskListUList:SetList(progress)

		local condition = conditions[index]
		local dropId = condition and condition[4]

		if dropId then
			local rewards = LuaUIUtils.getRewardItemByDropId(dropId)

			if rewards and rewards[1] then
				LuaUIUtils.renderRewardItem(rewardItemUButton, rewards[1])
				LuaUIUtils.setUIViewVisible(rewardItemUButton, true)
			end
		end
	else
		title = pg.getLocalizationText(data.title)
		desc = pg.getLocalizationText(data.desc)
	end

	button:TryChangePage("AdaptiveText", adaptiveText)
	ClientTextUtils.setText(titleUText, title)
	ClientTextUtils.setText(descUText, desc)

	petUImage.url = LuaUIUtils.getPetIconByTemplateId(templateId, LuaUIUtils.PET_ICON, label)

	local openResearch = self:guardRunCallback(data, function()
		pg.game.audio:triggerEvent("ui_sfx_button")
		self:openResearchDetail(templateId, subPageIdx, {
			branchId = data.evolveId
		}, data)
	end)
	local bindResearchKey = self:guardRunCallback(data, function(hotKeyBind)
		data.bindHotKey = hotKeyBind

		self:hideOtherBindKey()

		return true
	end)
	local showKeyList = self.notMobile
	local canOpenResearch = showKeyList and LuaUIUtils.checkFuncCanOpen(Const.FUNCTION_IDS.PETRESEARCH)
	local keyObject = keyKeyBindingPro.gameObject

	self:clearItemHotKey(keyObject, PET_RESEARCH_HOTKEY_PATH)

	data.bindHotKey = nil

	keyObject:SetActiveEx(showKeyList)
	listKeyUList:SetActiveFastest(showKeyList)

	if showKeyList then
		local keyData = {
			{
				path = CLOSE_ACTION_PATH,
				label = pg.getGameString("CLOSE")
			}
		}

		if canOpenResearch then
			keyData[#keyData + 1] = {
				path = PET_RESEARCH_HOTKEY_PATH,
				hotKeyObject = keyObject,
				longPressFunc = openResearch,
				onBound = function(hotKeyBind)
					if not bindResearchKey(hotKeyBind) then
						hotKeyBind.enabled = false
					end
				end,
				label = pg.getGameString("OPEN_PET_RESEARCH")
			}
		end

		listKeyUList.luaRenderItem = self:guardRunCallback(data, function(keyButton, _, keyInfo)
			local keyObjectReference = keyButton.transform:GetComponent("ObjectReference")
			local keyHotKeyContent = keyObjectReference:GetRefValue("keyHotKeyContent")
			local btnTipsUText = keyObjectReference:GetRefValue("btnTipsUText")

			keyHotKeyContent:SetHotKeyPaths(keyInfo.path)
			ClientTextUtils.setText(btnTipsUText, keyInfo.label)
			self:bindHotKeyItemLongPress(keyObjectReference, keyInfo)
		end)

		listKeyUList:SetList(keyData)

		data.bindCloseHotKey = self:bindItemHotKey(keyObject, CLOSE_ACTION_PATH, self:guardRunCallback(data, function()
			self:recycleToast(data)
			pg.game.audio:triggerEvent("ui_sfx_button")
		end), 100)
		data.bindKey = listKeyUList
	else
		self:clearItemHotKey(keyObject, CLOSE_ACTION_PATH)

		data.bindCloseHotKey = nil
		data.bindKey = nil
	end

	if canOpenResearch then
		button.luaClick = openResearch
	else
		button.luaClick = nil

		self:clearItemHotKey(keyObject, PET_RESEARCH_HOTKEY_PATH)

		data.bindHotKey = nil
	end
end

function PetResearchItem:renderCommonTopicItem(button, info)
	local objectReference = button:GetComponent("ObjectReference")
	local petUImage = objectReference:GetRefValue("petUImage")
	local titleUText = objectReference:GetRefValue("titleUText")
	local descUText = objectReference:GetRefValue("descUText")
	local nodeUComponent = objectReference:GetRefValue("nodeUComponent")
	local keyKeyBindingPro = objectReference:GetRefValue("keyKeyBindingPro")
	local rewardItemUButton = objectReference:GetRefValue("rewardItemUButton")
	local taskListUList = objectReference:GetRefValue("taskListUList")
	local iconNewFeaturesUImage = objectReference:GetRefValue("iconNewFeaturesUImage")
	local listKeyUList = objectReference:GetRefValue("listKeyUList")

	button:TryChangePage("IconNewFeatures", 2)
	button:TryChangePage("AdaptiveText", 1)
	nodeUComponent:TryChangePage("pageCut", 1)
	LuaUIUtils.setUIViewVisible(rewardItemUButton, false)
	ClientTextUtils.setText(titleUText, info.name)
	ClientTextUtils.setText(descUText, info.desc)

	if info.clickFunc then
		function button.luaClick()
			info.clickFunc()
			self:recycleToast(info)
		end
	else
		button.luaClick = nil
	end

	iconNewFeaturesUImage.url = info.smallIcon
	petUImage.url = info.bigIcon

	local index = info.processIndex or 0

	function taskListUList.luaRenderItem(b, i, d)
		if i + 1 <= index then
			b:TryChangePage("state", 1)
		else
			b:TryChangePage("state", 0)
		end
	end

	if info.processMax then
		local progress = {}

		for _ = 1, info.processMax do
			progress[#progress + 1] = {}
		end

		taskListUList:SetList(progress)
	else
		taskListUList:SetList({})
	end

	self:clearItemHotKey(keyKeyBindingPro.gameObject, CLOSE_ACTION_PATH)
	self:clearItemHotKey(keyKeyBindingPro.gameObject, PET_RESEARCH_HOTKEY_PATH)
	keyKeyBindingPro.gameObject:SetActiveEx(false)
	listKeyUList:SetActiveFastest(false)

	info.bindKey = nil
	info.bindHotKey = nil
	info.bindCloseHotKey = nil
end

function PetResearchItem:hideOtherBindKey()
	if not self.notMobile then
		return
	end

	local runNum = #self.runList

	for i, v in ipairs(self.runList) do
		local showKey = i == runNum

		if v.bindKey then
			v.bindKey.gameObject:SetActiveEx(showKey)
		end

		if v.bindHotKey then
			v.bindHotKey.enabled = showKey
		end

		if v.bindCloseHotKey then
			v.bindCloseHotKey.enabled = showKey
		end
	end
end

function PetResearchItem:openResearchDetail(templateId, subPageIdx, externalInfo, itemData)
	if self.inOpening then
		return
	end

	self.inOpening = true
	externalInfo = externalInfo or {}

	self:recycleToast(itemData, false, function()
		self:_openResearchUI(templateId, subPageIdx, externalInfo)
	end)
end

function PetResearchItem:_openResearchUI(templateId, subPageIdx, externalInfo)
	PetResearchUtils.openPetResearchDetail({
		templateId = Utils.getBasePetPrototypeId(templateId),
		subPageIdx = subPageIdx,
		branchId = externalInfo.branchId
	})

	self.inOpening = false
end

function PetResearchItem:onInputDeviceChanged()
	BaseQueueItem.onInputDeviceChanged(self)
	self:hideOtherBindKey()
end

local PetData = require("Data.pet_data")
local PetEvolveData = require("Data.pet_evolve_data")
local PetTraitData = require("Data.pet_trait_data")

function PetResearchItem:GMPushData(data)
	local templateId = 1002400
	local evolveId = 1
	local traitId = 1
	local itemType = math.random(self.ITEM_TYPE.HABIT, self.ITEM_TYPE.EVOLUTION)

	data.templateId = templateId
	data.tIndex = 1
	data.evolveId = nil
	data.isTopic = nil
	data.tab = nil
	data.subPageIdx = nil
	data.sn = nil
	data.index = nil
	data.nv = nil

	if itemType == self.ITEM_TYPE.EVOLUTION then
		local evolveData = PetEvolveData[templateId] and PetEvolveData[templateId][evolveId] or {}
		local petData = PetData[evolveData.targetPetId] or {}

		data.researchPoint = evolveData.reward or 0
		data.iconId = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON) or ""
		data.desc = evolveData.simpleDesc or ""
		data.targetName = petData.name
		data.title = pg.getFormatText(pg.getGameString("UNLOCK_EVOLVE"), pg.getLocalizationText(petData.name))
		data.evolveId = evolveId
		data.subPageIdx = PetResearchUtils.TAB_IDX.EVOLUTION
	elseif itemType == self.ITEM_TYPE.TOPIC then
		data.sn = 1
		data.title = PetResearchResultData.dataStatistic.title
		data.index = 1
		data.nv = 2
		data.tab = PetResearchUtils.TAB_IDX.TOPIC
		data.level = 1
		data.exp = 10
		data.researchPoint = 1
		data.isTopic = true
	else
		local traitData = PetTraitData[templateId] and PetTraitData[templateId][traitId] or {}

		data.title = traitData.traitsName or ""
		data.desc = traitData.traitsDesc or ""
		data.researchPoint = traitData.reward or 0
		data.tab = PetResearchUtils.TAB_IDX.SURVEY
	end
end

function PetResearchItem:getRecycleTarget(data)
	return self:getListRecycleTarget(data)
end

function PetResearchItem:onRecycleCleanup(data, target, reason)
	self:cleanupRecycleList(data, target, reason)
end

function PetResearchItem:onRecycleStarted(data, target)
	self:clearHotKeyBind(data.bindHotKey)
	self:clearHotKeyBind(data.bindCloseHotKey)
end

function PetResearchItem:onRecycleFinished(data, reason)
	data.bindKey = nil
	data.bindHotKey = nil
	data.bindCloseHotKey = nil

	local callback = data.recycleCloseCallback

	data.recycleCloseCallback = nil

	if callback then
		self.inOpening = false
	end

	if self:isRecycleCancelled(reason) then
		return
	end

	self:hideOtherBindKey()

	if callback then
		callback()
	end
end

return PetResearchItem
