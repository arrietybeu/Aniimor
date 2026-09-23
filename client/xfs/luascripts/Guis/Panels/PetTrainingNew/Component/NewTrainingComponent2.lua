-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\Component\\NewTrainingComponent2.lua

local Time = require("Core.Common.Time")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("NewTrainingComponent2")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local NewTrainingComponent2 = Class.LightClass("NewTrainingComponent2", UIComponent)
local TimerManager = require("Core.Timer.TimerManager")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local AbilityConst = require("Common.Const.AbilityConst")
local PetLevelData = require("Data.pet_level_data")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local ItemData = require("Data.item_data")
local UIConst = require("Const.UIConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local AttributeData = require("Data.attribute_group_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local NoticeDef = require("Common.NoticeDef")
local SysConfigData = require("Data.sys_config_data")
local PetCardInfoComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetCardInfoComponent")
local Utils = require("Common.Utils.Utils")
local BaseProperty = require("CustomTypes.BaseProperty")
local math_floor = math.floor
local string_format = string.format
local hanleFxRatio0ZRotAngles = 450

local function formatTrainingText(key, fallbackText, value)
	local formatText = pg.getGameString(key)

	if not formatText or formatText == "" or formatText == key then
		return fallbackText
	end

	local success, result = pcall(string_format, formatText, value)

	if success then
		return result
	end

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("format training text failed, key=%s, format=%s, error=%s", key, tostring(formatText), tostring(result))
	end

	return fallbackText
end

function NewTrainingComponent2:findObjects()
	local objectReference = self.view.newTalentUComponent.content.transform:GetComponent("ObjectReference")

	self.talentUComponent = objectReference:GetRefValue("talentUComponent")
	self.rootObjectReference = objectReference
	self.centerUWidget = objectReference:GetRefValue("centerUWidget")
	self.hpUButton = objectReference:GetRefValue("hpUButton")
	self.atkUButton = objectReference:GetRefValue("atkUButton")
	self.defUButton = objectReference:GetRefValue("defUButton")
	self.spdUButton = objectReference:GetRefValue("spdUButton")
	self.sdefUButton = objectReference:GetRefValue("sdefUButton")
	self.stakUButton = objectReference:GetRefValue("stakUButton")
	self.propBtns = {
		self.hpUButton,
		self.atkUButton,
		self.defUButton,
		self.stakUButton,
		self.sdefUButton,
		self.spdUButton
	}
	self.m_propTotalRatios = {
		0,
		0,
		0,
		0,
		0,
		0
	}
	self.rightPanelUComponent = objectReference:GetRefValue("rightPanelUComponent")
	self.petInfoUComponent = objectReference:GetRefValue("petInfoUComponent")
	self.emptyUWidget = objectReference:GetRefValue("emptyUWidget")

	local emptyObjectReference = self.emptyUWidget:GetComponent("ObjectReference")

	self.txtEmptyUSDFText = emptyObjectReference:GetRefValue("txtEmptyUSDFText")
	self.talentUWidget = objectReference:GetRefValue("talentUWidget")

	local talentObjectReference = self.talentUWidget:GetComponent("ObjectReference")

	self.attriUWidget = talentObjectReference:GetRefValue("attriUWidget")

	local talentCellTs = self.talentUWidget.transform:Find("TalentCell")

	self.talentCellUButton = talentCellTs and talentCellTs:GetComponent("UButton")
	self.valueUWidget = talentObjectReference:GetRefValue("valueUWidget")
	self.valueListUList = talentObjectReference:GetRefValue("listUList")
	self.txtMaxUSDFText = talentObjectReference:GetRefValue("txtMaxUSDFText")
	self.consumeUWidget = objectReference:GetRefValue("consumeUWidget")
	self.newRatioNodeUComp = objectReference:GetRefValue("newRatioNodeUComp")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.btnRulesUButton = objectReference:GetRefValue("btnRulesUButton")
	self.txtNowUSDFText = objectReference:GetRefValue("txtNowUSDFText")
	self.txtTotalUSDFText = objectReference:GetRefValue("txtTotalUSDFText")
	self.iconTrainUImage = objectReference:GetRefValue("iconTrainUImage")
	self.fxBonusUWidget = objectReference:GetRefValue("fxBonusUWidget")

	local btnResetTs = self.view.newTalentUComponent.content.transform:Find("TalentInfo/BtnReset")

	self.btnReset = btnResetTs and btnResetTs:GetComponent("UButton")
	self.m_isCreated = true
end

function NewTrainingComponent2:initView()
	ClientTextUtils.setText(self.txtEmptyUSDFText, pg.getGameString("PET_TRAIN_EMPTY_TIP"))
	ClientTextUtils.setText(self.txtTitleUSDFText, pg.getGameString("PET_TRAIN_TIPINFO_TITLE"))
	ClientTextUtils.setText(self.txtMaxUSDFText, pg.getGameString("PET_TRAINING_MAX"))

	self.btnRulesUButton.enabledTooltip = false

	function self.btnRulesUButton.luaClick()
		self:onRulesBtnClick()
	end

	if NotNil(self.btnReset) then
		self.btnReset:SetActive(true)

		function self.btnReset.luaClick()
			if self.ctrl:isInRogueDungeon() then
				return
			end

			self:onResetBtnClick()
		end
	end

	function self.valueListUList.luaRenderItem(button, index, data)
		self:m_refreshVaueListItem(button, data)
	end
end

function NewTrainingComponent2:onDestroy()
	self.petId = nil
	self.toLevel = nil
	self.gainsToLevel = nil
	self.propBtns = nil
	self.m_propTotalRatios = nil

	if self.delayHideHandleTimers then
		for _, timerId in pairs(self.delayHideHandleTimers) do
			TimerManager.removeTimer(timerId)
		end
	end

	self.delayHideHandleTimers = nil

	self:killTimer(self.onItemChangedDelayRefreshTimer)

	self.onItemChangedDelayRefreshTimer = nil

	self:killTimer(self._isFxBonusShowTimer)

	self._isFxBonusShowTimer = nil
	self._isFxBonusShow = false

	UIComponent.onDestroy(self)
end

function NewTrainingComponent2:init(info)
	if not self.m_isCreated then
		return
	end

	if not info or not info.petId then
		return
	end

	if info.pvpFailMode or info.onlyShowSkillPage then
		return
	end

	self.petId = info.petId

	local petCardExtraData = {
		isForbidFavoriteClick = true,
		isShowFavoriteBtn = true
	}

	self.petInfoCardComponent = PetCardInfoComponent.new(self.petInfoUComponent, petCardExtraData)

	self:refresh()
end

function NewTrainingComponent2:refresh(isPlayVx, forbidRefreshInfoPanel)
	if not self.petId then
		return
	end

	self.petInfo = self.model:setUpPetInfo(self.petId)

	if self.petInfo and self.petInfo.isCatchReportingStatus then
		self.curSelectedPropIndex = nil

		self.rightPanelUComponent:TryChangePage("InfoState", 4)
	end

	self:renderValue()
	self:renderRatio()

	if not forbidRefreshInfoPanel then
		self.petInfoCardComponent:renderPetInfoCard(self.petInfo, self.ctrl:isInRogueDungeon())
	end

	self:refreshInfoPanel(isPlayVx)
	self:renderProp(isPlayVx)
	self:resetFavouriteBtnState(self.petInfo)

	if NotNil(self.btnReset) then
		local isRogue = self.ctrl:isInRogueDungeon()

		self.btnReset.interactable = not isRogue
	end
end

function NewTrainingComponent2:renderProp(isPlayVx)
	local isCatchReporting = self.petInfo and self.petInfo.isCatchReportingStatus

	self.centerUWidget:SetActive(not isCatchReporting)

	if isCatchReporting then
		return
	end

	local petInfo = pg.me:getPetInfo(self.petId)
	local propLevels = self.model:getPetPropLevels(petInfo)

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		self:renderSpecificPropBtn(i, propLevels, isPlayVx)
	end
end

function NewTrainingComponent2:renderSpecificPropBtn(i, propLevels, isPlayVx)
	self:renderSingleBtn(self.propBtns[i], propLevels, i, isPlayVx and i == self.curSelectedPropIndex)

	self.propBtns[i].luaClick = function(navConfirm)
		self:m_onClickPropBtn(i, navConfirm)
	end
end

function NewTrainingComponent2:m_onClickPropBtn(i, navConfirm)
	for _, v in pairs(self.propBtns) do
		v:TryChangePage("Selected", 0)
		self:m_playHandleVx(i, v, self.m_propTotalRatios[i], false)
	end

	if self.curSelectedPropIndex == i and not navConfirm then
		self.curSelectedPropIndex = nil

		self:refreshInfoPanel()

		return
	end

	self.curSelectedPropIndex = i

	self:refreshInfoPanel()
	self.propBtns[i]:TryChangePage("Selected", 1)
	self:m_playHandleVx(i, self.propBtns[i], self.m_propTotalRatios[i], true)
end

function NewTrainingComponent2:renderSingleBtn(btn, propLevels, index, isPlayVx, extraInfo)
	local objectReference = btn:GetComponent("ObjectReference")
	local sliderBaseUSlider = objectReference:GetRefValue("sliderBaseUSlider")
	local sliderTrainUSlider = objectReference:GetRefValue("sliderTrainUSlider")
	local txtLevelUSDFText = objectReference:GetRefValue("txtLevelUSDFText")
	local iconAttributeUImage = objectReference:GetRefValue("iconAttributeUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local sliderAddUSlider = objectReference:GetRefValue("sliderAddUSlider")
	local sliderAddMaxUSlider = objectReference:GetRefValue("sliderAddMaxUSlider")
	local sliderGlowUWidget = objectReference:GetRefValue("sliderGlowUWidget")
	local fxHandleUWidget = objectReference:GetRefValue("fxHandleUWidget")
	local sixPropInfoUButtoTs = btn.transform:Find("Scale/Attribute/BtnInfo")
	local sixPropInfoUButton = sixPropInfoUButtoTs and sixPropInfoUButtoTs:GetComponent("UButton")
	local propLevelInfo = propLevels[index] or {}
	local isDetailInfo = extraInfo and extraInfo.isDetailInfo

	if isDetailInfo and NotNil(sixPropInfoUButton) then
		sixPropInfoUButton.enabledTooltip = true

		function sixPropInfoUButton.luaRenderTooltip(btn, cmp)
			local objRef = cmp:GetComponent("ObjectReference")
			local txtNameUSDFText = objRef:GetRefValue("txtNameUSDFText")
			local fStr = pg.getGameString("PET_TRAINING_SIXPROP_DESC_TIP")

			fStr = (not fStr or fStr == "" or fStr == "PET_TRAINING_SIXPROP_DESC_TIP") and "petLv=%s;1 point %s up %s num %s" or fStr

			local propName = pg.getLocalizationText(propLevelInfo.l18nNameKey or "")
			local propUpValue = self:m_calculatePropUpValue(propLevelInfo, 1, index) or 0

			fStr = ClientTextUtils.getFormatText(fStr, self.petInfo.level, propName, tostring(propUpValue), propName)

			ClientTextUtils.setText(txtNameUSDFText, fStr)
		end
	end

	fxHandleUWidget:SetActive(false)

	local glowUWidgets = {
		objectReference:GetRefValue("glow01UWidget"),
		objectReference:GetRefValue("glow02UWidget"),
		objectReference:GetRefValue("glow03UWidget"),
		objectReference:GetRefValue("glow04UWidget"),
		objectReference:GetRefValue("glow05UWidget")
	}

	btn:TryChangePage("IsMax", propLevelInfo.isMax and 1 or 0)

	local recommend = self.petInfo.recommend_attr

	if LuaUIUtils.tableContains(recommend, index) then
		btn:TryChangePage("GoodState", 1)
	else
		btn:TryChangePage("GoodState", 0)
	end

	if propLevelInfo.isMax and NotNil(btn.transform) then
		local maxTs = btn.transform:Find("Scale/Talent/LayoutLv/TxtMax")
		local maxUSDFText = maxTs and maxTs:GetComponent("USDFText")

		if NotNil(maxUSDFText) then
			ClientTextUtils.setText(maxUSDFText, pg.getGameString("PET_TRAINING_MAX"))
		end
	end

	local maxLevel = propLevelInfo.max

	sliderBaseUSlider.value = propLevelInfo.complexBaseLv / maxLevel

	local totalRatio = propLevelInfo.baseAndActiveTotalLv / maxLevel

	sliderTrainUSlider.value = totalRatio

	local displayTotal = propLevelInfo.baseAndActiveTotalLv

	ClientTextUtils.setText(txtLevelUSDFText, displayTotal)

	iconAttributeUImage.url = propLevelInfo.iconUrl or ""

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(propLevelInfo.l18nNameKey or ""))

	local total = propLevelInfo.total
	local passiveExtra = propLevelInfo.passiveExtra
	local sliderAddRatio = 0
	local sliderAddMaxRatio = 0

	if passiveExtra > 0 then
		sliderAddRatio = total / maxLevel
		sliderAddMaxRatio = sliderAddRatio - 1

		local txtAddTs = btn.transform:Find("Scale/Talent/LayoutLv/TxtAdd")
		local textAddUSDFText = txtAddTs and txtAddTs:GetComponent("USDFText")

		if NotNil(textAddUSDFText) then
			ClientTextUtils.setText(textAddUSDFText, "+" .. passiveExtra)
		end

		btn:TryChangePage("Extra", 1)

		local btnAddUButtonTs = btn.transform:Find("Scale/Talent/LayoutLv/TxtAdd/BtnAdd")
		local btnAddUButton = btnAddUButtonTs and btnAddUButtonTs:GetComponent("UButton")

		if NotNil(btnAddUButton) then
			function btnAddUButton.luaRenderTooltip(_, component)
				self:m_onRenderToolTipExtraInfo(component, index)
			end
		end
	else
		btn:TryChangePage("Extra", 0)
	end

	sliderAddUSlider.value = sliderAddRatio
	sliderAddMaxUSlider.value = sliderAddMaxRatio

	for _, v in pairs(glowUWidgets) do
		v:SetActive(false)
	end

	self.m_propTotalRatios[index] = totalRatio

	sliderGlowUWidget:SetActive(false)

	local sectionCnt = PetManagementDataHelper.TrainingConfig.UISliderSectionCount

	if isPlayVx then
		local singleSectionLevels = maxLevel / sectionCnt

		if propLevelInfo.baseAndActiveTotalLv % singleSectionLevels == 0 then
			TimerManager.addNextFrameCb(function()
				sliderGlowUWidget:SetActive(true)

				local lightNum = math.floor(totalRatio * sectionCnt + 0.5)

				for i, v in pairs(glowUWidgets) do
					v:SetActive(i <= lightNum)
				end
			end)
		end
	end

	if not isDetailInfo then
		self:m_playHandleVx(index, btn, totalRatio, self.curSelectedPropIndex == index and not propLevelInfo.isMax)
	end
end

function NewTrainingComponent2:m_getExtraStrengthInfos(index)
	if not self.petId then
		return {}
	end

	local petInfo = pg.me:getPetInfo(self.petId)

	if not petInfo then
		return {}
	end

	local propLevels = self.model:getPetPropLevels(petInfo)

	if not propLevels then
		return {}
	end

	local propLevelInfo = propLevels[index]

	if not propLevelInfo then
		return {}
	end

	local extraStrengthInfos = PetManagementUtils.mergeExtraStrengthLvInfos(propLevelInfo.extraSrcMap) or {}
	local retInfos = {}

	for srcKey, extraLv in pairs(extraStrengthInfos) do
		retInfos[#retInfos + 1] = {
			l10nName = pg.getGameString(srcKey),
			addPointDesc = "+" .. extraLv,
			sort = AbilityConst.EXTRA_SRCTYPE_STRKEYS_SORT[srcKey] or 4
		}
	end

	table.sort(retInfos, function(a, b)
		return a.sort < b.sort
	end)

	return retInfos
end

function NewTrainingComponent2:m_onRenderToolTipExtraInfo(component, index)
	local objectReference = component:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

	ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("PET_PRIMARY_EXTRA_TITILE"))

	local listUList = objectReference:GetRefValue("listUList")

	function listUList.luaRenderItem(button, index, data)
		self:m_onRenderAddInfoItem(button, index, data)
	end

	listUList:SetList(self:m_getExtraStrengthInfos(index))
end

function NewTrainingComponent2:m_onRenderAddInfoItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")

	ClientTextUtils.setText(txtDetailsUSDFText, data.l10nName or "")
	ClientTextUtils.setText(txtNumUSDFText, data.addPointDesc or "")
end

function NewTrainingComponent2:m_playHandleVx(index, btn, totalRatio, isShowHandle)
	local objectReference = btn:GetComponent("ObjectReference")
	local fxHandleUWidget = objectReference:GetRefValue("fxHandleUWidget")

	fxHandleUWidget:SetActive(isShowHandle)

	if isShowHandle then
		local fxHandleZRotAngle = hanleFxRatio0ZRotAngles - totalRatio * 360

		fxHandleUWidget.transform:SetLocalEulerAnglesEx(0, 0, fxHandleZRotAngle)
	end
end

function NewTrainingComponent2:renderValue()
	local leftNum, rightNum = self.model:getTrainingTimesData(self.petId)

	ClientTextUtils.setText(self.txtNowUSDFText, leftNum)
	ClientTextUtils.setText(self.txtTotalUSDFText, rightNum)

	self.iconTrainUImage.url = PetConfigData.PET_TRAIN_ITEMICON_PATH or ""
end

function NewTrainingComponent2:onRulesBtnClick()
	if PetConfigData.PET_TRAINING_TIP_INFO_ID then
		pg.global.ui.tips:openCommonPopUpTipById(PetConfigData.PET_TRAINING_TIP_INFO_ID)
	end
end

function NewTrainingComponent2:gradeUp()
	if self.m_isMax then
		self:refresh()

		return
	end

	self.ctrl:learnPetPropLevel(self.petId, self.curSelectedPropIndex, self.gainsToLevel)
end

function NewTrainingComponent2:refreshOnPropLearnLevel()
	self:refresh(true)
end

function NewTrainingComponent2:renderRatio()
	if not self.petId then
		return
	end

	local realPetInfo = pg.me:getPetInfo(self.petId)

	PetManagementUtils.setPetRatioUINode(realPetInfo, self.newRatioNodeUComp, nil, nil, true)
end

function NewTrainingComponent2:resetFavouriteBtnState(petInfo)
	self.petInfoCardComponent:resetFavouriteBtnState(petInfo and petInfo.favoriteType)
end

function NewTrainingComponent2:refreshInfoPanel(isPlayVx)
	local infoStateIndex = 0

	if self.petInfo and self.petInfo.isCatchReportingStatus then
		infoStateIndex = 4

		self.newRatioNodeUComp:SetActiveFastest(false)
	else
		self.newRatioNodeUComp:SetActiveFastest(true)
	end

	if not self.curSelectedPropIndex then
		self.rightPanelUComponent:TryChangePage("InfoState", infoStateIndex)
		self:killTimer(self.delayTimer1)

		self.delayTimer1 = self:startTimer(function()
			self.talentUWidget:SetActive(false)
		end, 0.05, false)
		self.toLevel = nil
		self.gainsToLevel = nil

		self.consumeUWidget:SetActive(false)

		return
	end

	local petInfo = pg.me:getPetInfo(self.petId)
	local propLevels = self.model:getPetPropLevels(petInfo)
	local propLevelInfo = propLevels[self.curSelectedPropIndex]

	self.toLevel = propLevelInfo.total + 1
	self.gainsToLevel = propLevelInfo.baseAndActiveTotalLv + 1
	infoStateIndex = propLevelInfo.isMax and 3 or 1

	self.rightPanelUComponent:TryChangePage("InfoState", infoStateIndex)
	self:killTimer(self.delayTimer2)

	self.delayTimer2 = self:startTimer(function()
		self.talentUWidget:SetActive(true)
	end, 0.05, false)

	if infoStateIndex == 1 then
		self:killTimer(self.delayTimer3)

		self.delayTimer3 = self:startTimer(function()
			self.consumeUWidget:SetActive(true)
		end, 0.05, false)
	else
		self.consumeUWidget:SetActive(false)
	end

	if NotNil(self.talentCellUButton) then
		if NotNil(self.attriUWidget) then
			self.attriUWidget:SetActive(false)
		end

		self.talentCellUButton:SetActive(true)
		self:m_refreshTalentCell(self.talentCellUButton, propLevels, self.curSelectedPropIndex)
	else
		if NotNil(self.attriUWidget) then
			self.attriUWidget:SetActive(true)
		end

		local attriCircleCompObjRef = self.attriUWidget:GetComponent("ObjectReference")

		self:m_refreshAttrCircle(attriCircleCompObjRef, propLevelInfo)
	end

	local valueDescCompObjRef = self.valueUWidget:GetComponent("ObjectReference")

	self:m_refreshValueDesc(valueDescCompObjRef, propLevelInfo)

	local propNextLvGains = self.model:getPetPropNextLvGains(self.curSelectedPropIndex, self.toLevel, propLevelInfo.isMax, isPlayVx)

	self.valueListUList:SetList(propNextLvGains)

	local consumeObjectReference = self.consumeUWidget:GetComponent("ObjectReference")

	self:m_refreshConsumeList(consumeObjectReference, propLevelInfo)

	if isPlayVx then
		self.fxBonusUWidget:SetActive(false)
		TimerManager.addNextFrameCb(function()
			if NotNil(self.fxBonusUWidget) then
				self.fxBonusUWidget:SetActive(true)

				self._isFxBonusShow = true
			end
		end)
		self:killTimer(self._isFxBonusShowTimer)

		self._isFxBonusShowTimer = self:startTimer(function()
			self._isFxBonusShow = false
		end, 1.2)
	elseif not self._isFxBonusShow then
		self.fxBonusUWidget:SetActive(false)
	end
end

function NewTrainingComponent2:m_refreshAttrCircle(attriCircleCompObjRef, propLevelInfo)
	local imgRingUImage = attriCircleCompObjRef:GetRefValue("imgRingUImage")
	local txtFinalUSDFText = attriCircleCompObjRef:GetRefValue("txtFinalUSDFText")
	local txtAttriUSDFText = attriCircleCompObjRef:GetRefValue("txtAttriUSDFText")
	local btnFinalAddUButton = attriCircleCompObjRef:GetRefValue("btnFinalAddUButton")
	local txtNameUSDFText = attriCircleCompObjRef:GetRefValue("txtNameUSDFText")
	local imgBgMaxUWidget = attriCircleCompObjRef:GetRefValue("imgBgMaxUWidget")
	local txtNameUSDFText = attriCircleCompObjRef:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtFinalUSDFText, propLevelInfo.baseAndActiveTotalLv)
	ClientTextUtils.setText(txtAttriUSDFText, pg.getLocalizationText(propLevelInfo.l18nNameKey) or "")
	btnFinalAddUButton:SetActive(propLevelInfo.passiveExtra > 0)
	ClientTextUtils.setText(txtNameUSDFText, "+" .. propLevelInfo.passiveExtra)
	imgBgMaxUWidget:SetActive(propLevelInfo.isMax)

	btnFinalAddUButton.enabledTooltip = true

	function btnFinalAddUButton.luaRenderTooltip(_, component)
		local objectReference = component:GetComponent("ObjectReference")
		local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
		local listUList = objectReference:GetRefValue("listUList")

		function listUList.luaRenderItem(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")

			ClientTextUtils.setText(txtDetailsUSDFText, pg.getGameString(data.nameKey) or "")

			local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")

			ClientTextUtils.setText(txtNumUSDFText, data.lv)
		end

		local propLevelExtraInfos = pg.game.petManage:getPetPropLevelExtraInfo(propLevelInfo)

		listUList:SetList(propLevelExtraInfos)
		ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("PET_PRIMARY_EXTRA_TITILE"))
	end
end

function NewTrainingComponent2:m_refreshTalentCell(talentCellUButton, propLevelInfos, curSelectedPropIndex)
	self:renderSingleBtn(talentCellUButton, propLevelInfos, curSelectedPropIndex, false, {
		isDetailInfo = true
	})

	talentCellUButton.interactable = false
	talentCellUButton.visualInteractable = false
end

function NewTrainingComponent2:m_refreshValueDesc(valueDescCompObjRef, propLevelInfo)
	self.ingLineUWidget = valueDescCompObjRef:GetRefValue("ingLineUWidget")
	self.txtBaseUSDFText = valueDescCompObjRef:GetRefValue("txtBaseUSDFText")
	self.txtAddUSDFText = valueDescCompObjRef:GetRefValue("txtAddUSDFText")
	self.imgLine2UWidget = valueDescCompObjRef:GetRefValue("imgLine2UWidget")

	local txtBaseValueTs = self.valueUWidget.transform:Find("LayoutBox/TxtBaseValue")
	local txtAddValueTs = self.valueUWidget.transform:Find("LayoutBox/TxtAddValue")

	self.txtBaseValueUSDFText = txtBaseValueTs and txtBaseValueTs:GetComponent("USDFText")
	self.txtAddValueUSDFText = txtAddValueTs and txtAddValueTs:GetComponent("USDFText")

	ClientTextUtils.setText(self.txtBaseUSDFText, pg.getGameString("PET_BASE_VALUE_DESC"))
	ClientTextUtils.setText(self.txtAddUSDFText, pg.getGameString("PET_ADD_VALUE_DESC"))
	self.txtBaseUSDFText:SetActive(propLevelInfo.complexBaseLv > 0)
	self.txtAddUSDFText:SetActive(propLevelInfo.learnt > 0)
	self.ingLineUWidget:SetActive(propLevelInfo.learnt > 0)
	self.imgLine2UWidget:SetActive(propLevelInfo.complexBaseLv > 0 and propLevelInfo.learnt > 0)

	if NotNil(self.txtBaseValueUSDFText) then
		ClientTextUtils.setText(self.txtBaseValueUSDFText, tostring(propLevelInfo.complexBaseLv or 0))
		self.txtBaseValueUSDFText:SetActive(propLevelInfo.complexBaseLv > 0)
	end

	if NotNil(self.txtAddValueUSDFText) then
		ClientTextUtils.setText(self.txtAddValueUSDFText, tostring(propLevelInfo.learnt or 0))
		self.txtAddValueUSDFText:SetActive(propLevelInfo.learnt > 0)
	end
end

function NewTrainingComponent2:m_refreshConsumeList(consumeObjectReference, propLevelInfo)
	self.comsumeListUList = consumeObjectReference:GetRefValue("listUList")
	self.btnUpgradeUButton = consumeObjectReference:GetRefValue("btnUpgradeUButton")
	self.txtNameUSDFText = consumeObjectReference:GetRefValue("txtNameUSDFText")
	self.notAchievedUWidget = self.rootObjectReference:GetRefValue("notAchievedUWidget")
	self.notAchieveUSDFText = self.rootObjectReference:GetRefValue("notAchieveUSDFText")

	function self.comsumeListUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderItemWithCountCheck(button, data, nil, true)
	end

	local nextLvCostItems = self.model:getNextLvConsumeInfo(self.petId, self.curSelectedPropIndex, self.gainsToLevel)

	self.comsumeListUList:SetList(nextLvCostItems)

	self.m_isMax = propLevelInfo.isMax

	function self.btnUpgradeUButton.luaClick()
		self:gradeUp()
	end

	local isRogue = self.ctrl:isInRogueDungeon()

	self.btnUpgradeUButton.interactable = not isRogue

	ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("PET_TRAIN_LVUP"))

	local isCanAchieved, needPetLv = pg.game.petManage:checkIsCanManualUpPropLv(self.petInfo, self.curSelectedPropIndex, self.gainsToLevel)

	if propLevelInfo.isMax then
		self.btnUpgradeUButton:SetActive(false)
		self.notAchievedUWidget:SetActive(false)
	else
		self.btnUpgradeUButton:SetActive(isCanAchieved)
		self.notAchievedUWidget:SetActive(not isCanAchieved)
	end

	if not isCanAchieved then
		local hint = formatTrainingText("Pet_NewTraining_NotAchieved", "notAchieved: " .. tostring(needPetLv or ""), needPetLv)

		ClientTextUtils.setText(self.notAchieveUSDFText, hint)
	end
end

function NewTrainingComponent2:m_refreshVaueListItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local textNumUSDFText = objectReference:GetRefValue("textNumUSDFText")
	local textAddUSDFText = objectReference:GetRefValue("textAddUSDFText")
	local rootUComp = objectReference:GetRefValue("rootUComp")
	local fxRefreshUWidget = objectReference:GetRefValue("fxRefreshUWidget")

	button:TryChangePage("State", 0)
	ClientTextUtils.setText(txtNameUSDFText, data.l18nName or "")
	ClientTextUtils.setText(textNumUSDFText, data.displayValStr and "+" .. data.displayValStr or "")
	fxRefreshUWidget:SetActive(false)
end

function NewTrainingComponent2:refreshOnLevelChanged(info)
	local changePetId = info and info.petId or 0

	if changePetId == self.petId then
		local refreshData = {
			level = info.newLevel,
			exp = info.curExp
		}

		self.petInfoCardComponent:refreshLevelInfo(refreshData)
		self:refresh(false, true)
	end
end

function NewTrainingComponent2:m_calculatePropUpValue(propLevelInfo, upLv, propId)
	if not propId or not self.petInfo then
		return 0
	end

	local dict = self.petInfo.basePropertyList and self.petInfo.basePropertyList[propId]

	if not dict then
		return 0
	end

	local function returnRealVal(value)
		return value
	end

	local function roundToOneDecimal(value)
		local rounded = math.floor(value * 10 + 0.5) / 10

		if rounded == math.floor(rounded) then
			return math.floor(rounded)
		end

		return rounded
	end

	local params = {
		needExtraUp = true,
		objLevel = self.petInfo.level or 1,
		mathFloorFun = returnRealVal
	}
	local sTmpId = self.petInfo and self.petInfo.templateId or 0
	local spe = Utils.getBasePropertySpeciesPoint(PetData[sTmpId], propId)
	local currentValue = Utils.PropertyRefreshTotal(propId, dict, params, spe)
	local tempDict = Utils.deepCopyTable(dict)

	tempDict.indLv = (tempDict.indLv or 0) + (upLv or 1)

	local newValue = Utils.PropertyRefreshTotal(propId, tempDict, params, spe)
	local increment = newValue - currentValue

	return roundToOneDecimal(increment)
end

function NewTrainingComponent2:onResetBtnClick()
	local payBack = self.model:getPayBackInfo(self.petId)

	if #payBack <= 0 then
		pg.global.showBubbleMessageRaw(pg.getGameString("PROP_RESET_FAILD"))

		return
	end

	local costItemId, costItemCount
	local costConfig = PetConfigData.petPropLvResetCost

	if costConfig and next(costConfig) then
		for id, cnt in pairs(costConfig) do
			costItemId = id
			costItemCount = cnt

			break
		end
	end

	if not costItemId or not costItemCount then
		pg.global.showBubbleMessageRaw(pg.getGameString("PROP_RESET_FAILD"))

		return
	end

	local itemCount = ClientUtils.getItemCountById(costItemId)
	local str = itemCount < costItemCount and string.format("<color=#ff7676>%s</color>", costItemCount) or costItemCount

	pg.global.showCommonTipUse(pg.getGameString("PROP_RESET"), formatTrainingText("PROP_RESET_TIP", "Reset potential (cost: " .. tostring(str) .. ")?", str), payBack, function()
		self.ctrl:resetPetPropLevel(self.petId, function()
			self:refresh()
			self:playResetVx()

			if pg.global.ui.petManagement then
				pg.global.ui.petManagement:refreshAll()
			end

			pg.global.showBubbleMessageById(NoticeDef.NEW_TRAINING_RESET_SUCCESS)
		end)
	end, function()
		return
	end, true)
end

function NewTrainingComponent2:playResetVx()
	self.talentUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
end

function NewTrainingComponent2:refreshOnItemsChanged()
	self.onItemChangedDelayRefreshTimer = self:startTimer(function()
		self:refresh()
	end, 0.1)
end

return NewTrainingComponent2
