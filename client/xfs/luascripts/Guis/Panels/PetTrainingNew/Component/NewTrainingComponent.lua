-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\Component\\NewTrainingComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("NewTrainingComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local NewTrainingComponent = Class.LightClass("NewTrainingComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
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
local PetCardInfoComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetCardInfoComponent")
local PetRenameValidator = require("Utils.PetRenameValidator")
local math_floor = math.floor
local string_format = string.format
local RINFO_STATE_NAME = "InfoState"
local RINFO_STATE = {
	Max_3 = 3,
	ReadyMax_2 = 2,
	Upgrade_1 = 1,
	Empty_0 = 0
}

function NewTrainingComponent:findObjects()
	local objectReference = self.view.newTalentUComponent.content.transform:GetComponent("ObjectReference")

	self.hpUButton = objectReference:GetRefValue("hpUButton")
	self.atkUButton = objectReference:GetRefValue("atkUButton")
	self.defUButton = objectReference:GetRefValue("defUButton")
	self.spdUButton = objectReference:GetRefValue("spdUButton")
	self.sdefUButton = objectReference:GetRefValue("sdefUButton")
	self.stakUButton = objectReference:GetRefValue("stakUButton")
	self.talentUComponent = objectReference:GetRefValue("talentUComponent")
	self.propBtns = {
		self.atkUButton,
		self.hpUButton,
		self.defUButton,
		self.sdefUButton,
		self.stakUButton,
		self.spdUButton
	}
	self.btnRulesUButton = objectReference:GetRefValue("btnRulesUButton")
	self.btnResetUButton = objectReference:GetRefValue("btnResetUButton")
	self.ratingText = objectReference:GetRefValue("ratingText")
	self.txtNowUSDFText = objectReference:GetRefValue("txtNowUSDFText")
	self.txtTotalUSDFText = objectReference:GetRefValue("txtTotalUSDFText")
	self.petInfoUComponent = objectReference:GetRefValue("petInfoUComponent")
	self.petInfoCardComponent = PetCardInfoComponent.new(self.petInfoUComponent)
	self.rightPanelUComponent = objectReference:GetRefValue("rightPanelUComponent")
	self.newRatioNodeUComp = objectReference:GetRefValue("newRatioNodeUComp")
	self.m_curSelectedPropIndex = nil
	self.m_targetSLv = 0
	self.m_RInfoState = RINFO_STATE.Empty_0
	self.m_isCreated = true
end

function NewTrainingComponent:initView()
	function self.btnRulesUButton.luaClick()
		self:onRulesBtnClick()
	end

	function self.btnResetUButton.luaClick()
		if self.ctrl:isInRogueDungeon() then
			return
		end

		self:onResetBtnClick()
	end
end

function NewTrainingComponent:init(info)
	if not self.m_isCreated then
		return
	end

	self.petId = info.petId

	if info.pvpFailMode or info.onlyShowSkillPage then
		return
	end

	self.petInfo = self.model:setUpPetInfo(self.petId)

	self:refreshPetName(self.model:getPetLocName(self.petId))
	self:refreshNewPropUI()
end

function NewTrainingComponent:refreshNewPropUI(isFormUIMsg)
	local petInfo = self.model:setUpPetInfo(self.petId)

	self:renderPotentialPoint()
	self:renderRatio()
	self.petInfoCardComponent:renderPetInfoCard(petInfo)

	if self.petInfoCardComponent.btnLevelUButton then
		self.petInfoCardComponent.btnLevelUButton.interactable = not self.ctrl:isInRogueDungeon()
	end

	self:renderNewProp()
	self:refreshInfoPanel(isFormUIMsg)
end

function NewTrainingComponent:onSelected()
	self:m_onClickPropBtn()
end

function NewTrainingComponent:refreshPetName(petName)
	self.petInfoCardComponent:refreshPetName(petName)
end

function NewTrainingComponent:renderPotentialPoint()
	local leftNum, rightNum = self.model:getPetPotentialPoints(self.petId)

	ClientTextUtils.setText(self.txtNowUSDFText, leftNum)
	ClientTextUtils.setText(self.txtTotalUSDFText, rightNum)
end

function NewTrainingComponent:renderRatio()
	if not self.petId then
		return
	end

	local realPetInfo = pg.me:getPetInfo(self.petId)

	PetManagementUtils.setPetRatioUINode(realPetInfo, self.newRatioNodeUComp)
end

function NewTrainingComponent:onRulesBtnClick()
	function self.btnRulesUButton.luaRenderTooltip(_, component)
		local objectReference = component:GetComponent("ObjectReference")
		local contentUScrollRect = objectReference:GetRefValue("contentUScrollRect")

		ClientTextUtils.setText(contentUScrollRect.content:GetComponent("UBaseText"), pg.getGameString("PET_STRENGTH_TIP"))
	end
end

function NewTrainingComponent:resetFavouriteBtnState(favoriteType)
	favoriteType = favoriteType or 0

	self.petInfoCardComponent:resetFavouriteBtnState(favoriteType)
end

function NewTrainingComponent:showRename()
	if not PetRenameValidator.canRenamePet() then
		pg.global.showBubbleMessage(NoticeDef.FORBID_CHANGE_PET_NAME)

		return
	end

	local title = pg.getGameString("RENAME_TIPS_PET")
	local id = self.petId
	local text = self.model:getPetLocName(self.petId)

	pg.global.ui.tips:setIsModel(true)
	pg.global.ui.tips:showCommonInput(title, function(newName)
		pg.me:serverMsg("RPC_CS_CustomPetName", id, newName)
		pg.global.ui.tips:setIsModel(false)
	end, function()
		pg.global.ui.tips:setIsModel(false)
	end, {
		characterLimit = 14,
		text = text or ""
	})
end

function NewTrainingComponent:renderNewProp()
	for newPId, _ in pairs(Const.NEW_BASE_PROP_IDX2ATTR_MAP) do
		self:renderSpecificPropBtn(self.petId, newPId)
	end
end

function NewTrainingComponent:renderSpecificPropBtn(petId, newPropId)
	local detailPropInfo = PetManagementUtils.getPetNewSixPropInfo(petId, newPropId)

	self:renderSingleBtn(self.propBtns[newPropId], detailPropInfo, newPropId)

	self.propBtns[newPropId].luaClick = function()
		self:m_onClickPropBtn(newPropId)
	end
end

function NewTrainingComponent:m_onClickPropBtn(newPropId)
	if self.m_curSelectedPropIndex == newPropId then
		return
	end

	for _, v in pairs(self.propBtns) do
		v:TryChangePage("Selected", 0)
	end

	self.m_curSelectedPropIndex = newPropId

	if newPropId and self.propBtns[newPropId] then
		self.propBtns[newPropId]:TryChangePage("Selected", 1)
	end

	self:refreshNewPropUI()
end

function NewTrainingComponent:renderSingleBtn(btn, detailPropInfo, index)
	local objectReference = btn:GetComponent("ObjectReference")
	local sliderBaseUSlider = objectReference:GetRefValue("sliderBaseUSlider")
	local sliderTrainUSlider = objectReference:GetRefValue("sliderTrainUSlider")
	local sliderExtraUSlider = objectReference:GetRefValue("sliderExtraUSlider")
	local txtLevelUSDFText = objectReference:GetRefValue("txtLevelUSDFText")
	local iconAttributeUImage = objectReference:GetRefValue("iconAttributeUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local newPropAtomAttrCfg = PetManagementUtils.getPetNewSixPropAtomAttrCfg(detailPropInfo and detailPropInfo.propId)

	iconAttributeUImage.url = newPropAtomAttrCfg and newPropAtomAttrCfg.icon or ""

	local propName = pg.getGameString(PetManagementDataHelper.NEW_PROP_NAMES[detailPropInfo.propId])

	ClientTextUtils.setText(txtNameUSDFText, propName)

	local isMax = detailPropInfo.propertyStrengPoint >= detailPropInfo.propertyStrengMax

	btn:TryChangePage("IsMax", isMax and 1 or 0)

	local recommend = self.petInfo.recommend_attr

	if LuaUIUtils.tableContains(recommend, index) then
		btn:TryChangePage("GoodState", 1)
	else
		btn:TryChangePage("GoodState", 0)
	end

	local manualSLvPro, extraLvPro, specialSLvPro = PetManagementUtils.getPPointProgressRatios(detailPropInfo.propertyStrengPoint, detailPropInfo.propertyStrengMax, detailPropInfo.extraStrengthLv)

	sliderBaseUSlider.value = manualSLvPro
	sliderTrainUSlider.value = specialSLvPro
	sliderExtraUSlider.value = extraLvPro

	ClientTextUtils.setText(txtLevelUSDFText, detailPropInfo.propertyStrengPoint + detailPropInfo.extraStrengthLv)
end

function NewTrainingComponent:onResetBtnClick()
	PetManagementUtils.popupResetAllocatePoint(self.petId, self.m_totalUsedPPoint)
end

function NewTrainingComponent:onDestroy()
	self.m_curSelectedPropIndex = nil
	self.toLevel = nil

	UIComponent.onDestroy(self)
end

function NewTrainingComponent:refreshInfoPanel(isFormUIMsg)
	self.m_RInfoState = RINFO_STATE.Empty_0

	if not self.m_curSelectedPropIndex then
		self.rightPanelUComponent:TryChangePage(RINFO_STATE_NAME, RINFO_STATE.Empty_0)

		return
	end

	self._isInitRInfoUI = self._isInitRInfoUI or false

	if not self._isInitRInfoUI and self.rightPanelUComponent then
		local objectReference = self.rightPanelUComponent:GetComponent("ObjectReference")

		self.normalUWidget = objectReference:GetRefValue("normalUWidget")
		self.n_iconUImage = objectReference:GetRefValue("iconUImage")
		self.n_numUSDFText = objectReference:GetRefValue("numUSDFText")
		self.n_txtTitleRUSDFText = objectReference:GetRefValue("txtTitleRUSDFText")
		self.n_iconLeftUImage = objectReference:GetRefValue("iconLeftUImage")
		self.n_txtBeforeUSDFText = objectReference:GetRefValue("txtBeforeUSDFText")
		self.n_iconRightUImage = objectReference:GetRefValue("iconRightUImage")
		self.n_txtAfterUSDFText = objectReference:GetRefValue("txtAfterUSDFText")
		self.n_btnAfterAddUButton = objectReference:GetRefValue("btnAfterAddUButton")
		self.n_btnAddBeforeText = objectReference:GetRefValue("btnAddBeforeText")
		self.n_txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		self.n_btnBeforeAddUButton = objectReference:GetRefValue("btnBeforeAddUButton")
		self.n_btnAddAfterText = objectReference:GetRefValue("btnAddAfterText")
		self.n_listUList = objectReference:GetRefValue("listUList")
		self.n_txtTitleLUSDFText = objectReference:GetRefValue("txtTitleLUSDFText")
		self.max_txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
		self.max_iconFinalUImage = objectReference:GetRefValue("iconFinalUImage")
		self.max_txtFinalUSDFText = objectReference:GetRefValue("txtFinalUSDFText")
		self.max_btnFinalAddUButton = objectReference:GetRefValue("btnFinalAddUButton")
		self.max_maxTtxtNameUSDFtext = objectReference:GetRefValue("maxTtxtNameUSDFtext")
		self.max_txtMaxUSDFText = objectReference:GetRefValue("txtMaxUSDFText")
		self.n_txtAttriUSDFText = objectReference:GetRefValue("txtAttriUSDFText")
		self.m_txtAttriUSDFText = objectReference:GetRefValue("mtxtAttriUSDFText")

		function self.n_btnAfterAddUButton.luaClick()
			self:onClickExtraPropsBtn(1)
		end

		function self.n_btnBeforeAddUButton.luaClick()
			self:onClickExtraPropsBtn(2)
		end

		function self.max_btnFinalAddUButton.luaClick()
			self:onClickExtraPropsBtn(3)
		end

		function self.n_listUList.luaRenderItem(button, index, data)
			self:renderAddInfoItem(button, index, data)
		end

		self.bot_txtNowUSDFText = objectReference:GetRefValue("txtNowUSDFText")
		self.btnUpgradeUButton = objectReference:GetRefValue("btnUpgradeUButton")
		self.btnBatchUButton = objectReference:GetRefValue("btnBatchUButton")
		self.btnRecommendUButton = objectReference:GetRefValue("btnRecommendUButton")

		function self.btnUpgradeUButton.luaClick()
			if not self.ctrl:isInRogueDungeon() then
				self:onClickUpgrade()
			end
		end

		function self.btnBatchUButton.luaClick()
			if not self.ctrl:isInRogueDungeon() then
				self:onClickBatchAddPoints()
			end
		end

		function self.btnRecommendUButton.luaClick()
			if not self.ctrl:isInRogueDungeon() then
				self:onClickRecommend()
			end
		end

		self.tipsUWidget = objectReference:GetRefValue("tipsUWidget")

		local btnRecObjRefrence = self.btnRecommendUButton:GetComponent("ObjectReference")
		local btnRecommendText = btnRecObjRefrence:GetRefValue("txtNameUText")

		ClientTextUtils.setText(btnRecommendText, pg.getGameString("PET_NEW_RECOMMEND_CONT"))
		self:initExtraBtnsTooltipFunc()

		self._isInitRInfoUI = true
	end

	local petInfo = pg.me:getPetInfo(self.petId)

	if not petInfo then
		return
	end

	local curSelectedPropId = self.m_curSelectedPropIndex
	local selectedPropInfo = PetManagementUtils.getPetNewSixPropInfo(petInfo.id, curSelectedPropId)

	if not selectedPropInfo then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("2个参数 %s; %s", curSelectedPropId, petInfo.id)
		end

		return
	end

	local curSelectedSLv = selectedPropInfo.propertyStrengPoint + selectedPropInfo.extraStrengthLv
	local addLv = 1

	self.m_targetSLv = selectedPropInfo.propertyStrengPoint + selectedPropInfo.extraStrengthLv + addLv
	self.m_totalUsedPPoint = selectedPropInfo.usedPotentialPointSum or 0

	local isNearlyMax = selectedPropInfo.propertyStrengPoint >= selectedPropInfo.propertyStrengMax - 1
	local isReachedMax = selectedPropInfo.propertyStrengPoint >= selectedPropInfo.propertyStrengMax
	local reachNextSLvNeedPPoint = PetManagementUtils.getNewPropRangeLvChangePotentialPoint(self.petId, curSelectedPropId, curSelectedSLv, self.m_targetSLv)
	local reachManualNextSLvNeedPPoint = PetManagementUtils.getNewPropRangeLvChangePotentialPoint(self.petId, curSelectedPropId, selectedPropInfo.propertyStrengPoint, selectedPropInfo.propertyStrengPoint + addLv, true)
	local remainPPoint = selectedPropInfo.remainPotentialPointSum or 0

	ClientTextUtils.setText(self.n_txtAttriUSDFText, selectedPropInfo.propL10NName)
	ClientTextUtils.setText(self.m_txtAttriUSDFText, selectedPropInfo.propL10NName)

	self.m_reachNextSLvNeedPPoint = reachManualNextSLvNeedPPoint
	self.m_remainPPoint = remainPPoint

	if isReachedMax then
		self.m_RInfoState = RINFO_STATE.Max_3
	elseif isNearlyMax then
		self.m_RInfoState = RINFO_STATE.ReadyMax_2
	else
		self.m_RInfoState = RINFO_STATE.Upgrade_1
	end

	self.rightPanelUComponent:TryChangePage(RINFO_STATE_NAME, self.m_RInfoState)

	local newPropAtomAttrCfg = PetManagementUtils.getPetNewSixPropAtomAttrCfg(curSelectedPropId)

	if self.m_RInfoState == RINFO_STATE.Upgrade_1 or self.m_RInfoState == RINFO_STATE.ReadyMax_2 then
		self.n_iconUImage.url = newPropAtomAttrCfg and newPropAtomAttrCfg.icon or ""

		local needPointCnt, desc = PetManagementUtils.getNextStrengthExtraAtomPropDesc(curSelectedPropId, selectedPropInfo.propertyStrengPoint + selectedPropInfo.extraStrengthLv)

		ClientTextUtils.setText(self.n_numUSDFText, needPointCnt)

		local preStr = pg.getGameString("PET_NEW_ATTR_CAN_GET_TIP")

		preStr = (not preStr or preStr == "PET_NEW_ATTR_CAN_GET_TIP") and "ExtraTip:" or preStr

		ClientTextUtils.setText(self.n_txtTitleRUSDFText, preStr .. (desc or ""))
		ClientTextUtils.setText(self.n_txtTitleLUSDFText, pg.getGameString("PET_NEW_PROP_NEED"))

		if isFormUIMsg and self.preNeedPPoint and self.normalUWidget then
			if needPointCnt == 1 then
				self.normalUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
			elseif needPointCnt < 5 then
				self.normalUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
			end
		end

		self.preNeedPPoint = needPointCnt
		self.n_iconLeftUImage.url = newPropAtomAttrCfg and newPropAtomAttrCfg.icon or ""

		ClientTextUtils.setText(self.n_txtBeforeUSDFText, selectedPropInfo.propertyStrengPoint)

		self.n_iconRightUImage.url = newPropAtomAttrCfg and newPropAtomAttrCfg.icon or ""

		ClientTextUtils.setText(self.n_txtAfterUSDFText, selectedPropInfo.propertyStrengPoint + addLv)

		local extraStrengthLv = selectedPropInfo.extraStrengthLv

		self.n_btnAfterAddUButton:SetActive(extraStrengthLv > 0)
		self.n_btnBeforeAddUButton:SetActive(extraStrengthLv > 0)
		ClientTextUtils.setText(self.n_btnAddBeforeText, extraStrengthLv > 0 and "+" .. tostring(extraStrengthLv) or "")
		ClientTextUtils.setText(self.n_btnAddAfterText, extraStrengthLv > 0 and "+" .. tostring(extraStrengthLv) or "")

		local addLvs = self.m_targetSLv - selectedPropInfo.propertyStrengPoint - extraStrengthLv
		local previewAttrs = PetManagementUtils.getPreviewAddedAtomPropInfo2(self.petId, curSelectedPropId, addLvs, self.m_targetSLv)

		self.n_listUList:SetList(previewAttrs or {})
		ClientTextUtils.setText(self.bot_txtNowUSDFText, self.m_reachNextSLvNeedPPoint)

		local isRogue = self.ctrl:isInRogueDungeon()

		self.btnUpgradeUButton.interactable = not isRogue
		self.btnBatchUButton.interactable = not isRogue
		self.btnRecommendUButton.interactable = not isRogue

		self.tipsUWidget:SetActive(not PetManagementUtils.getIsAppliedgRecommend(self.petId))
	elseif self.m_RInfoState == RINFO_STATE.Max_3 then
		local fStr = pg.getGameString("PET_NEW_TIP_EXTRA_GAIN")

		fStr = (not fStr or fStr == "PET_NEW_TIP_EXTRA_GAIN") and "Need %s Get Extra Gain %s" or fStr

		local needPointCnt, desc = PetManagementUtils.getNextStrengthExtraAtomPropDesc(curSelectedPropId, selectedPropInfo.propertyStrengPoint + selectedPropInfo.extraStrengthLv)

		ClientTextUtils.setText(self.n_numUSDFText, needPointCnt)

		local ret, retStr = pcall(string_format, fStr, needPointCnt, desc or "")

		if not ret then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("format PET_NEW_TIP_EXTRA_GAIN failed, format=%s, error=%s", tostring(fStr), tostring(retStr))
			end

			retStr = string_format("Need %s Get Extra Gain %s", tostring(needPointCnt or ""), tostring(desc or ""))
		end

		ClientTextUtils.setText(self.max_txtTitleUSDFText, retStr)

		self.max_iconFinalUImage.url = newPropAtomAttrCfg and newPropAtomAttrCfg.icon or ""

		ClientTextUtils.setText(self.max_txtFinalUSDFText, selectedPropInfo.propertyStrengMax)

		local extraStrengthLv = selectedPropInfo.extraStrengthLv

		self.max_btnFinalAddUButton:SetActive(extraStrengthLv > 0)
		ClientTextUtils.setText(self.max_maxTtxtNameUSDFtext, extraStrengthLv > 0 and "+" .. tostring(extraStrengthLv) or "")

		fStr = pg.getGameString("PET_NEW_TIP_REACHED_ADD_MAX ")
		fStr = (not fStr or fStr == "PET_NEW_TIP_REACHED_ADD_MAX ") and "ReachedMax  %s" or fStr

		local propName = PetManagementDataHelper.FINAL_PROP_NAMES[curSelectedPropId]
		local ret2, retStr2 = pcall(string_format, fStr, propName)

		if not ret2 then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("format PET_NEW_TIP_REACHED_ADD_MAX failed, format=%s, error=%s", tostring(fStr), tostring(retStr2))
			end

			retStr2 = string_format("ReachedMax  %s", tostring(propName or ""))
		end

		ClientTextUtils.setText(self.max_txtMaxUSDFText, retStr2)
	end
end

function NewTrainingComponent:renderAddInfoItem(button, index, data)
	if not data then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local rootUComp = objectReference:GetRefValue("rootUComp")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local textNumUSDFText = objectReference:GetRefValue("textNumUSDFText")
	local textAddUSDFText = objectReference:GetRefValue("textAddUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, data.l10nName or "")

	local isAdd = data.diffV > 0

	rootUComp:TryChangePage("State", 0)
	ClientTextUtils.setText(textNumUSDFText, data.newVDispTxt)
	ClientTextUtils.setText(textAddUSDFText, data.newVDispTxt)
end

function NewTrainingComponent:onClickExtraPropsBtn(extraPropType)
	if not self.m_curSelectedPropIndex then
		return
	end

	local retInfos = {}
	local extraStrengthLvInfos = PetManagementUtils.getExtraStrengthLvInfos(self.petId, self.m_curSelectedPropIndex)

	for strKey, extraLv in pairs(extraStrengthLvInfos) do
		retInfos[#retInfos + 1] = {
			l10nName = pg.getGameString(strKey),
			addPointDesc = "+" .. extraLv
		}
	end

	self.m_extraStrengthInfos = retInfos
end

function NewTrainingComponent:initExtraBtnsTooltipFunc()
	function self.n_btnAfterAddUButton.luaRenderTooltip(_, component)
		self:m_onRenderToolTip1(component)
	end

	function self.n_btnBeforeAddUButton.luaRenderTooltip(_, component)
		self:m_onRenderToolTip2(component)
	end

	function self.max_btnFinalAddUButton.luaRenderTooltip(_, component)
		self:m_onRenderToolTip3(component)
	end
end

function NewTrainingComponent:m_onRenderToolTip1(component)
	if not self.m_extraStrengthInfos then
		return
	end

	local objectReference = component:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

	ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("PET_PRIMARY_EXTRA_TITILE"))

	local listUList = objectReference:GetRefValue("listUList")

	function listUList.luaRenderItem(button, index, data)
		self:m_onRenderAddInfoItem(button, index, data)
	end

	listUList:SetList(self.m_extraStrengthInfos or {})
end

function NewTrainingComponent:m_onRenderToolTip2(component)
	if not self.m_extraStrengthInfos then
		return
	end

	local objectReference = component:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

	ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("PET_PRIMARY_EXTRA_TITILE"))

	local listUList = objectReference:GetRefValue("listUList")

	function listUList.luaRenderItem(button, index, data)
		self:m_onRenderAddInfoItem(button, index, data)
	end

	listUList:SetList(self.m_extraStrengthInfos or {})
end

function NewTrainingComponent:m_onRenderToolTip3(component)
	if not self.m_extraStrengthInfos then
		return
	end

	local objectReference = component:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local listUList = objectReference:GetRefValue("listUList")

	function listUList.luaRenderItem(button, index, data)
		self:m_onRenderAddInfoItem(button, index, data)
	end

	listUList:SetList(self.m_extraStrengthInfos or {})
end

function NewTrainingComponent:m_onRenderAddInfoItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")

	ClientTextUtils.setText(txtDetailsUSDFText, data.l10nName or "")
	ClientTextUtils.setText(txtNumUSDFText, data.addPointDesc or "")
end

function NewTrainingComponent:onClickUpgrade()
	if not self.m_curSelectedPropIndex then
		return
	end

	local newPropAttrName = PetManagementUtils.getPetNewPropAttrNameByNewId(self.m_curSelectedPropIndex)

	if not newPropAttrName then
		return
	end

	if self.m_remainPPoint < self.m_reachNextSLvNeedPPoint then
		pg.global.showBubbleMessage(NoticeDef.PET_NEW_PROP_NOT_ENOUGH)

		return
	end

	PetManagementUtils.reqAllocateEffort(self.petId, newPropAttrName, 1)
end

function NewTrainingComponent:onClickBatchAddPoints()
	pg.global.ui:open(UIConst.UI_ID_PET_BATCH_STRENGTH_POINT, {
		petId = self.petId
	})
end

function NewTrainingComponent:onClickRecommend()
	pg.global.ui:open(UIConst.UI_ID_PET_RECOMMEND_STRENGTH_POINT, {
		petId = self.petId
	})
end

return NewTrainingComponent
