-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\LeylineTreeUpComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("LeylineTreeUpComponent")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local UIComponent = require("Guis.Helper.UIComponent")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local ActivityConst = require("Common.Const.ActivityConst")
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local RedDotConst = require("Const.RedDotConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local GameEventData = require("Data.game_event_data")
local MapBlockConfigData = require("Data.map_block_config_data")
local MapAreaConfigData = require("Data.map_area_config_data")
local EventLeylineTreeUpData = require("Data.event_leylineTree_up_data")
local LeylineTreeData = require("Data.leylinetree_data")
local SysConfigData = require("Data.sys_config_data")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local MapHelper = require("GameApp.Map.MapHelper")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local ItemSourceData = require("Data.item_source_data")
local LeylineTreeUpComponent = Class.LightClass("LeylineTreeUpComponent", EventContainerComponent)
local PetCardType = {
	Prismana = 1,
	Area = 3,
	Normal = 2
}
local PetCardBg = {
	[PetCardType.Prismana] = 2,
	[PetCardType.Normal] = 1,
	[PetCardType.Area] = 0
}

function LeylineTreeUpComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.btnChallengeUButton = objectReference:GetRefValue("btnChallengeUButton")
	self.eventTitleUContainer = objectReference:GetRefValue("eventTitleUContainer")
	self.btnTaskUButton = objectReference:GetRefValue("btnTaskUButton")
	self.listCardUList = objectReference:GetRefValue("listCardUList")
	self.btnGoto = objectReference:GetRefValue("btnGoto")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.txtGoto = objectReference:GetRefValue("txtGoto")
end

function LeylineTreeUpComponent:addListener()
	if self.txtGoto then
		ClientTextUtils.setText(self.txtGoto, pg.getGameString("LEYLINEUP_BTN_GO"))
	end

	function self.btnTaskUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_EVENT_TASK_PANEL, {
			eventIds = {
				self.eventId
			},
			title = pg.getGameString("LEYLINEUP_TASK_TITLE"),
			receiveTaskFunc = function(eventId, taskId)
				pg.me:reqActReceiveTaskReward(taskId, eventId)
			end
		})
	end

	function self.listTabUList.luaRenderItem(button, index, data)
		self:renderTabItem(button, index, data)
	end

	function self.listTabUList.luaClick(button, data)
		self.selectedPetData = data

		self:_refreshPetCardList()
	end

	function self.listCardUList.luaRenderItem(button, index, data)
		self:renderPetCard(button, index, data)
	end

	function self.btnGoto.luaClick()
		self:openLeylineTreeUnlocked()
	end
end

function LeylineTreeUpComponent:renderPetCard(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local imgPet = objectReference:GetRefValue("imgPet")
	local txtTitle = objectReference:GetRefValue("txtTitle")
	local txtDesc = objectReference:GetRefValue("txtDesc")
	local txtExTitle = objectReference:GetRefValue("txtExTitle")
	local txtBtnGo = objectReference:GetRefValue("txtBtnGo")
	local btnGo = objectReference:GetRefValue("btnGo")
	local imgPetHead = objectReference:GetRefValue("imgPetHead")
	local btnShowPet = objectReference:GetRefValue("btnShowPet")
	local tipsUButton = objectReference:GetRefValue("tipsUButton")
	local exPetName = objectReference:GetRefValue("exPetName")
	local checkBtnUButton = objectReference:GetRefValue("checkBtnUButton")
	local superPetImgUImage = objectReference:GetRefValue("superPetImgUImage")
	local cardType = data.cardType
	local petData = data.petData
	local isPrismanaCard = cardType == PetCardType.Prismana
	local isNormalCard = cardType == PetCardType.Normal
	local isAreaCard = cardType == PetCardType.Area
	local blockCfg = petData.mapBlockId and MapBlockConfigData[petData.mapBlockId]
	local areaPrismanaPetId = blockCfg and blockCfg.aurora and blockCfg.aurora[1]
	local isSeasonPrismanaCard = isPrismanaCard and petData.hidePetId
	local displayPetId = isPrismanaCard and (petData.hidePetId or areaPrismanaPetId) or petData.petId
	local superPage

	if isPrismanaCard then
		superPage = self.isInUpTime and 3 or 1
	else
		superPage = self.isInUpTime and 0 or 2
	end

	button:TryChangePage("Bg", PetCardBg[cardType])
	button:TryChangePage("super", superPage)
	button:TryChangePage("Season", isSeasonPrismanaCard and 1 or 0)
	imgPet.gameObject:SetActiveEx(not isAreaCard)
	txtDesc.gameObject:SetActiveEx(not isPrismanaCard)
	txtExTitle.gameObject:SetActiveEx(isPrismanaCard)
	imgPetHead.gameObject:SetActiveEx(isPrismanaCard)
	exPetName.gameObject:SetActiveEx(isPrismanaCard)

	if not isAreaCard then
		local specialPetPic = petData.rainbowPetPicMap and petData.rainbowPetPicMap[displayPetId]
		local petPic = specialPetPic or self:_getPetIcon(displayPetId)

		imgPet.url = petPic
		superPetImgUImage.url = petPic
	end

	if isAreaCard then
		ClientTextUtils.setText(txtTitle, pg.getGameString("LEYLINE_UP_DESC"))
		ClientTextUtils.setText(txtDesc, self:_getRemainingTimesText(petData))
	else
		local massDesc = petData.massDesc and pg.getLocalizationText(petData.massDesc) or ""

		ClientTextUtils.setText(txtTitle, isNormalCard and self:_getPetName(displayPetId) or pg.getGameString("LEYLINE_UP_DESC3"))
		ClientTextUtils.setText(txtDesc, isNormalCard and massDesc or "")
	end

	ClientTextUtils.setText(txtExTitle, isPrismanaCard and pg.getGameString("LEYLINE_UP_DESC2") or "")
	ClientTextUtils.setText(exPetName, isPrismanaCard and self:_getPetName(displayPetId) or "")

	if isPrismanaCard then
		local btnGoTextKey = self.isInUpTime and "LEYLINE_UP_DESC3" or "LEYLINEUP_BTN_GO"

		ClientTextUtils.setText(txtBtnGo, pg.getGameString(btnGoTextKey))
	else
		local btnGoTextKey = "LEYLINE_UP_TIME"

		if self.isInUpTime then
			btnGoTextKey = isNormalCard and "LEYLINE_UP_PET_BUTTON" or "LEYLINEUP_BTN_GO"
		end

		ClientTextUtils.setText(txtBtnGo, pg.getGameString(btnGoTextKey))
	end

	if isPrismanaCard then
		imgPetHead.url = self:_getPetIcon(areaPrismanaPetId)
	end

	if btnShowPet then
		btnShowPet.luaClick = nil

		if not isAreaCard and displayPetId then
			function btnShowPet.luaClick()
				pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
					templateId = displayPetId
				})
			end
		end
	end

	if tipsUButton then
		tipsUButton.enabledTooltip = true
		tipsUButton.tooltipMode = 1

		function tipsUButton.luaRenderTooltip(_, tooltip)
			local objectReference = tooltip:GetComponent("ObjectReference")
			local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("LEYLINE_UP_HIDE_PET_TIPS"))
		end
	end

	if checkBtnUButton then
		function checkBtnUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
				templateId = displayPetId
			})
		end

		local checkBtnHotkeyTransform = checkBtnUButton.transform:Find("Key")

		if checkBtnHotkeyTransform then
			checkBtnUButton:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadSelect, checkBtnHotkeyTransform.gameObject)
			checkBtnUButton:SetHotkeyActiveOnlyInCurrentItem(true)
		end
	end

	if btnGo then
		local canClickBtnGo = superPage ~= 2 and superPage ~= 3

		btnGo.interactable = canClickBtnGo
		btnGo.luaClick = nil

		if canClickBtnGo then
			function btnGo.luaClick()
				if isAreaCard or isPrismanaCard then
					self:openLeylineTreeUnlocked(petData.mapBlockId)
				else
					self:_tracePet(petData.traceId)
				end
			end
		end

		button.interactable = isPrismanaCard or canClickBtnGo

		local btnGotoHotkeyContent = btnGo:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")
		local btnGotoHotkeyWidget = btnGotoHotkeyContent and btnGotoHotkeyContent:GetComponent("UWidget")

		if btnGotoHotkeyWidget then
			btnGotoHotkeyWidget:SetForceInactive(CS.XGUI.ForceInactiveSource.Business, not canClickBtnGo)
		end
	end
end

function LeylineTreeUpComponent:renderTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local petUImage = objectReference:GetRefValue("petUImage")

	petUImage.url = self:_getPetIcon(data.hidePetId)
end

function LeylineTreeUpComponent:_tracePet(traceId)
	local sourceData = traceId and ItemSourceData[traceId]

	if not sourceData then
		pg.global.showBubbleMessageRaw(pg.getGameString("SCHOOL_GUIDE_TRACK_FAIL"))

		return
	end

	LuaUIUtils.clueSeek(sourceData)
end

function LeylineTreeUpComponent:openLeylineTreeUnlocked(mapBlockId)
	mapBlockId = mapBlockId or self.selectedPetData and self.selectedPetData.mapBlockId

	if not mapBlockId then
		if pg.logError() then
			logger:error("@LeylineTreeUpComponent btnGoto: selected mapBlockId nil")
		end

		return
	end

	local blockCfg = MapBlockConfigData[mapBlockId]
	local mapAreaId = blockCfg and blockCfg.mapAreaId

	if not mapAreaId then
		if pg.logError() then
			logger:error("@LeylineTreeUpComponent btnGoto: mapAreaId nil for mapBlockId=" .. tostring(mapBlockId))
		end

		return
	end

	if not MapHelper.checkBlockLeylineTreeUnlocked(mapAreaId, pg.me.leylineTreeInfoMap) then
		pg.global.showBubbleMessageById(NoticeDef.LEYLINETREE_NOT_ACTIVE)

		return
	end

	if not self:_isNourishUnlocked(mapAreaId) then
		pg.global.showBubbleMessageById(NoticeDef.LEYLINENOURISH_LOCKED)

		return
	end

	local isValid = self:checkPlayerInBlockScene(mapBlockId)

	if not isValid then
		pg.global.showBubbleMessageRaw(pg.getGameString("SCHOOL_GUIDE_TRACK_FAIL"), 3)

		return
	end

	pg.me:doEventByData({
		"openNourish",
		{
			mapBlockId,
			true
		}
	})
end

function LeylineTreeUpComponent:onBeforeRefreshPage()
	EventContainerComponent.onBeforeRefreshPage(self)
end

function LeylineTreeUpComponent:refreshPage()
	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)
	local eventEndDayTime = eventTimeCfg and eventTimeCfg.tabEndDayTime
	local eventName = GameEventData[self.eventId] and pg.getLocalizationText(GameEventData[self.eventId].name) or ""
	local actData = self:_getActData()
	local cfg = self:_getCurPhaseConfig()
	local upStartTime = cfg and Utils.getConfigTimeOfArea(cfg, "upStartTime")
	local upEndTime = cfg and Utils.getConfigTimeOfArea(cfg, "upEndTime")
	local now = Time.secondCache
	local isInUpTime = upStartTime and upEndTime and upStartTime <= now and now < upEndTime or false
	local eventDesc = isInUpTime and cfg.upDesc and pg.getLocalizationText(cfg.upDesc) or nil

	self:setEventTitle(self.eventTitleUContainer, eventEndDayTime, eventName, nil, nil, eventDesc)

	self.isInUpTime = isInUpTime

	self.btnTaskUButton.gameObject:SetActiveEx(isInUpTime)

	local redDotStyle = isInUpTime and ClientActivityUtils._getLeylineTreeUpRedDotStyle(self.eventId) or RedDotConst.RedDotStyle.NONE

	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_LEYLINE_UP_TASK, self.btnTaskUButton, redDotStyle ~= RedDotConst.RedDotStyle.NONE, redDotStyle)

	local btnTaskName = self.btnTaskUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

	ClientTextUtils.setText(btnTaskName, pg.getGameString("LEYLINEUP_BTN_TASK"))
	self.rootUComponent:TryChangePage("Status", 0)
	self.listCardUList.gameObject:SetActiveEx(true)

	if not actData or not cfg then
		self:_renderEmpty()

		return
	end

	local petList = self:_buildPetList(cfg)

	self.rootUComponent:TryChangePage("Tab", #petList > 1 and 1 or 0)
	self:_selectPetData(petList)

	if #petList > 1 then
		self.listTabUList:SetList(petList)
		self.listTabUList:SelectItem(self.selectedPetData.listIndex - 1)
	end

	self:_refreshPetCardList()
	self:scheduleDefaultCardFocus()
end

function LeylineTreeUpComponent:_buildPetList(cfg)
	local petList = {}

	for index, mapBlockId in ipairs(cfg.mapBlockIds or {}) do
		local petId = cfg.petIds and cfg.petIds[mapBlockId]
		local hidePetId = cfg.hidePetIds and cfg.hidePetIds[mapBlockId]

		petList[#petList + 1] = {
			listIndex = index,
			mapBlockId = mapBlockId,
			upCount = cfg.upCounts and cfg.upCounts[mapBlockId] or 0,
			petId = petId,
			traceId = cfg.traceIds and cfg.traceIds[mapBlockId],
			hidePetId = hidePetId,
			rainbowPetPicMap = cfg.rainbowPetPic,
			massDesc = cfg.massDesc
		}
	end

	return petList
end

function LeylineTreeUpComponent:_selectPetData(petList)
	local selectedMapBlockId = self.selectedPetData and self.selectedPetData.mapBlockId

	self.selectedPetData = petList[1]

	if not selectedMapBlockId then
		return
	end

	for _, data in ipairs(petList) do
		if data.mapBlockId == selectedMapBlockId then
			self.selectedPetData = data

			return
		end
	end
end

function LeylineTreeUpComponent:_refreshPetCardList()
	if pg.game.input:isUsingGamepad() then
		if not self.selectedPetData then
			self.listCardUList:SetList({})

			return
		end

		local cardList = {
			{
				cardType = PetCardType.Prismana,
				petData = self.selectedPetData
			}
		}

		cardList[#cardList + 1] = {
			cardType = PetCardType.Normal,
			petData = self.selectedPetData
		}
		cardList[#cardList + 1] = {
			cardType = PetCardType.Area,
			petData = self.selectedPetData
		}

		if self.listCardUList.itemCount ~= #cardList then
			self.listCardUList:SetList(cardList)
		elseif self.listCardUList.gameObject.activeInHierarchy then
			for index, cardData in ipairs(cardList) do
				self.listCardUList:SetElement(index - 1, cardData)
			end
		end

		return
	end

	self.listCardUList:SetList({})

	if not self.selectedPetData then
		return
	end

	local cardList = {
		{
			cardType = PetCardType.Prismana,
			petData = self.selectedPetData
		}
	}

	cardList[#cardList + 1] = {
		cardType = PetCardType.Normal,
		petData = self.selectedPetData
	}
	cardList[#cardList + 1] = {
		cardType = PetCardType.Area,
		petData = self.selectedPetData
	}

	self.listCardUList:SetList(cardList)
end

function LeylineTreeUpComponent:_getPetIcon(petId)
	local petCfg = petId and PetData[petId]

	if not petCfg or not petCfg.iconName then
		return ""
	end

	return LuaUIUtils.getPetIcon(petCfg.iconName, LuaUIUtils.PET_ICON) or ""
end

function LeylineTreeUpComponent:_getPetName(petId)
	local petCfg = petId and PetData[petId]

	return petCfg and petCfg.name and pg.getLocalizationText(petCfg.name) or ""
end

function LeylineTreeUpComponent:_getRemainingTimesText(petData)
	local actData = self:_getActData()
	local usedCount = actData and actData.upTimesDailys and actData.upTimesDailys[petData.mapBlockId] or 0
	local totalCount = petData.upCount or 0
	local textTemplate = pg.getGameString("LEYLINEUP_DAILY_BONUS_TPL")

	if textTemplate then
		return string.format(textTemplate, totalCount - usedCount, totalCount)
	end

	return string.format("每日加成 %d 次（%d/%d）", totalCount, usedCount, totalCount)
end

function LeylineTreeUpComponent:_getActData()
	local attrName = ActivityConst.NewFrameEventAttriName[ActivityConst.EventType.LeylineTreeUp]

	return pg.me and pg.me[attrName]
end

function LeylineTreeUpComponent:_getCurPhaseConfig()
	local actData = self:_getActData()
	local phase = actData and actData.activityBase and actData.activityBase.activityPhase

	if not phase then
		return nil
	end

	return EventLeylineTreeUpData[phase]
end

function LeylineTreeUpComponent:_isNourishUnlocked(mapAreaId)
	if not mapAreaId or not pg.me or not pg.me.leylineTreeInfoMap then
		return false
	end

	local areaCfg = MapAreaConfigData[mapAreaId]
	local treeId = areaCfg and areaCfg.treeId

	if not treeId then
		return false
	end

	local treeInfo = pg.me.leylineTreeInfoMap[treeId]

	if not treeInfo then
		return false
	end

	local injectedCount = treeInfo.leylineTreePoint

	if not injectedCount then
		return false
	end

	local treeData = LeylineTreeData[treeId]

	if not treeData then
		return false
	end

	local plentyLevel = SysConfigData.LEYLINETREE_CREATEPLENTY_LEVEL or 4
	local levelData = treeData[plentyLevel]

	if not levelData then
		return false
	end

	local required = levelData.point or 0

	return required <= injectedCount
end

function LeylineTreeUpComponent:_renderEmpty()
	self.selectedPetData = nil

	self.rootUComponent:TryChangePage("Tab", 0)
	self.listCardUList:SetList({})
end

function LeylineTreeUpComponent:checkPlayerInBlockScene(mapBlockId)
	if not mapBlockId then
		return false
	end

	local currentMainSceneId = pg.game.map.sceneId

	if not currentMainSceneId then
		return false
	end

	local blockConfig = MapBlockConfigData[mapBlockId]

	if not blockConfig or not blockConfig.mapAreaId then
		if pg.logError() then
			logger:error("@checkPlayerInBlockScene: blockConfig or mapAreaId not found for mapBlockId=" .. tostring(mapBlockId))
		end

		return false
	end

	local areaConfig = MapAreaConfigData[blockConfig.mapAreaId]

	if not areaConfig or not areaConfig.Mapid then
		if pg.logError() then
			logger:error("@checkPlayerInBlockScene: areaConfig or Mapid not found for mapAreaId=" .. tostring(blockConfig.mapAreaId))
		end

		return false
	end

	local isValid = currentMainSceneId == areaConfig.Mapid

	return isValid
end

function LeylineTreeUpComponent:onDestroy()
	if self._defaultFocusFrameId then
		self:killFrameTimer(self._defaultFocusFrameId)

		self._defaultFocusFrameId = nil
	end

	UIComponent.onDestroy(self)
end

function LeylineTreeUpComponent:scheduleDefaultCardFocus()
	if self.isDestroyed or not self.listCardUList or IsNil(self.listCardUList) then
		return
	end

	if not pg.game.input:isUsingGamepad() then
		return
	end

	if self._defaultFocusFrameId then
		self:killFrameTimer(self._defaultFocusFrameId)
	end

	self._defaultFocusFrameId = self:startFrameTimer(function()
		self._defaultFocusFrameId = nil

		local success, button = self.listCardUList:TryGetChildAt(0)
		local navMgr = pg.global.navMgr

		if not success or not button or not navMgr then
			return
		end

		navMgr:FocusItem(button)
	end, 1)
end

return LeylineTreeUpComponent
