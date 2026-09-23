-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityIncubateResult\\PetFertilityIncubateResultCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetFertilityIncubateResultCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local SoulEggEvolutionConst = require("Common.Const.EvolutionConst").SoulEggEvolution
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local PetManagementUtils = require("Utils.PetManagementUtils")
local UIConst = require("Const.UIConst")
local PetData = require("Data.pet_data")
local Utils = require("Common.Utils.Utils")
local PetAvatarData = require("Data.pet_avatar_data")
local PetFertilityIncubateResultCtrl = Class.LightClass("PetFertilityIncubateResultCtrl", UICtrl)

PetFertilityIncubateResultCtrl.messages = {}

function PetFertilityIncubateResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self._petInfo = self.model:setUpPetInfo(info.petInfo)
	self._closeCallBack = info.closeCallback
	self._needDelay = info.needDelay

	self:init()
end

function PetFertilityIncubateResultCtrl:addListener()
	function self.view.btnDetailUButton.luaClick()
		local _, curPage = self.view.rootUComponent:TryGetCurrentPage("expand")

		self.view.rootUComponent:TryChangePage("expand", 1 - curPage)

		local extraInfo = {
			isHideVx = true
		}

		PetManagementUtils.renderPetAttribute(self._petInfo, self.view.petDemensionTransform, nil, nil, extraInfo)
		pg.game.soulEggEvolution:playPetDetail(curPage == 0)
	end

	function self.view.btnHaveitUButton.luaClick()
		self:dismiss()

		if self._closeCallBack then
			self._closeCallBack()
		end
	end

	function self.view.btnFertilityUButton.luaClick()
		self:dismiss()

		if self._closeCallBack then
			self._closeCallBack()
		end

		LuaUIUtils.petManagementSelectPet(self._petInfo.id, true)
	end
end

function PetFertilityIncubateResultCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if self._changeStateTimer then
		self:killTimer(self._changeStateTimer)

		self._changeStateTimer = nil
	end
end

function PetFertilityIncubateResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if self._changeStateTimer then
		self:killTimer(self._changeStateTimer)

		self._changeStateTimer = nil
	end

	local function enterShowState()
		self.view.rootUComponent:TryChangePage("State", 1)
		pg.game.input:playRumbleByName(ClientConst.RumbleLayer.PET_INCUBATE, "CommonHigh")
	end

	if self._needDelay then
		self._changeStateTimer = self:startTimer(enterShowState, SoulEggEvolutionConst.IncubateResultChangeTime)
	else
		enterShowState()
	end
end

function PetFertilityIncubateResultCtrl:onShow()
	return
end

function PetFertilityIncubateResultCtrl:onHide()
	return
end

function PetFertilityIncubateResultCtrl:openBreedTalentTips(targetRect)
	local talentData = {}

	talentData.targetRect = targetRect
	talentData.autoHor = true
	talentData.type = UIConst.GIFT_TYPE.BATTLE
	talentData.showType = UIConst.GIFT_SHOW_TYPE.GIFT
	talentData.giftType = UIConst.GIFT_TYPE.HOME
	talentData.breedTalent = self._petInfo.breedTalent
	talentData.petId = self._petInfo.id

	pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS, talentData)
end

function PetFertilityIncubateResultCtrl:init()
	self.view.rootUComponent:TryChangePage("State", 0)

	self.view.careerIcon.url = self._petInfo.petFunctionIcon

	ClientTextUtils.setText(self.view.careerName, self._petInfo.petFunctionText)

	local nameTxtCom = self.view.nameText

	ClientTextUtils.setText(nameTxtCom, self._petInfo.name)

	local genderState = 2

	if self._petInfo.gender == Const.GENDER_TYPE_MALE then
		genderState = 0
	elseif self._petInfo.gender == Const.GENDER_TYPE_FEMALE then
		genderState = 1
	end

	self.view.petInfoUComponent:TryChangePage("Gender", genderState)

	function self.view.charUList.luaRenderItem(button, index, data)
		LuaUIUtils.setElementButtonNew(button, data.element, false, self._petInfo.templateId)
	end

	self.view.charUList:SetList(self._petInfo.elementNames)

	function self.view.accessListUList.luaRenderItem(button, index, data)
		local objRef = button:GetComponent("ObjectReference")
		local icon = objRef:GetRefValue("iconUImage")

		icon.url = data.icon
		button.enabledTooltip = false

		button:TryChangePage("Quality", data.quality)
	end

	function self.view.accessListUList.luaClick(button, data)
		self:openBreedTalentTips(button)
	end

	self.view.accessListUList:SetList(self._petInfo.breedTalent)

	if self.view.btnAccessListUButton then
		self.view.btnAccessListUButton:SetGamepadAction("Raw/GamepadSelect", nil, function()
			self:openBreedTalentTips(self.view.btnAccessListUButton)

			return false
		end)
	end

	LuaUIUtils.setUIVisible(self.view.bossWidget, self._petInfo.isBoss)

	local hasCatch = pg.me.petHandbookMap:isCatched(self._petInfo.templateId, Const.GROUP_TYPE_SELF)

	LuaUIUtils.setUIVisible(self.view.iconNewUWidget, not hasCatch)

	local tagInfos, tagKey2IndexMap = LuaUIUtils.getPetTagInfo(self._petInfo.templateId, self._petInfo.label, self._petInfo.bodySizeType, self._petInfo.shinyStyle, true)
	local tagDatas = LuaUIUtils.getPetTagList(self._petInfo)

	self:rereshRightLaoutItems(tagDatas, tagInfos, tagKey2IndexMap)

	local petCubeItemId = self._petInfo.cubeItemId

	LuaUIUtils.refreshPetFertilityCubeInfo(petCubeItemId, self.view.ballGetUWidget, self.view.iconBallUImage)
end

function PetFertilityIncubateResultCtrl:rereshRightLaoutItems(tagDatas, tagInfos, tagKey2IndexMap)
	tagDatas = tagDatas or {}

	local finalTagDatas = {}
	local formTypeData = Utils.getPetFormTypeDataByTemplateId(self._petInfo.templateId)

	finalTagDatas.b = {
		l10nName = pg.getLocalizationText(formTypeData and formTypeData.name or ""),
		formQuality = formTypeData and formTypeData.formQuality or 0
	}

	for _, data in ipairs(tagDatas) do
		if data and data.formQuality then
			finalTagDatas.a = data
		end

		if data and data.labelMask == Const.PET_LABEL_MASK.DARK then
			finalTagDatas.c = data or {}
			finalTagDatas.c.l10nName = pg.getGameString("FILTER_DARK")
		end

		if data and data.labelMask == Const.PET_LABEL_MASK.SHINY then
			finalTagDatas.d = data
		end

		if data and data.isBoss ~= nil and data.isMini ~= nil then
			finalTagDatas.e = data
		end
	end

	local itemIndexTags = {
		"a",
		"b",
		"c",
		"d",
		"e"
	}
	local pageIndexDef = {
		[0] = {
			"a",
			"b",
			"c",
			"d",
			"e"
		},
		{
			"a",
			"b",
			"c",
			"d"
		},
		{
			"a",
			"b",
			"c",
			"e"
		},
		{
			"a",
			"b",
			"d",
			"e"
		},
		{
			"a",
			"b",
			"c"
		},
		{
			"a",
			"b",
			"d"
		},
		{
			"a",
			"b",
			"e"
		},
		{
			"a",
			"b"
		}
	}
	local pageIndex = 0

	for retPageIndex, def in pairs(pageIndexDef) do
		local defTagMap = {}

		for _, tag in ipairs(def) do
			defTagMap[tag] = true
		end

		local isMatched = true

		for _, tag in ipairs(itemIndexTags) do
			if finalTagDatas[tag] ~= nil ~= (defTagMap[tag] ~= nil) then
				isMatched = false

				break
			end
		end

		if isMatched then
			pageIndex = retPageIndex

			break
		end
	end

	self.view.widget:TryChangePage("layout", pageIndex)

	for tag, data in pairs(finalTagDatas) do
		local tagIndex = tagKey2IndexMap[tag]
		local tagInfo = tagIndex and tagInfos[tagIndex]

		if tag == "a" then
			self.view.qualityItemUComponent:TryChangePage("Quality", self._petInfo.ratingPageIdx)
			ClientTextUtils.setText(self.view.qualityNameTxt, pg.getGameString(self._petInfo.ratingStr))
		elseif tag == "b" then
			local objectReference = self.view.formItemUButton:GetComponent("ObjectReference")
			local txtFormUSDFText = objectReference:GetRefValue("txtFormUSDFText")

			self.view.formItemUButton:TryChangePage("Quality", data.formQuality)
			ClientTextUtils.setText(txtFormUSDFText, data.l10nName)
			LuaUIUtils.setPetTagLabelToolTip(self.view.formItemUButton, {
				tagInfo
			})
		elseif tag == "c" then
			ClientTextUtils.setText(self.view.txtUmbralUSDFText, data.l10nName)
			LuaUIUtils.setPetTagLabelToolTip(self.view.umbralItemUButton, {
				tagInfo
			})
		elseif tag == "d" then
			self.view.flashItemUButton:TryChangePage("Type", data.shinyIndex or 0)
			LuaUIUtils.setPetTagLabelToolTip(self.view.flashItemUButton, {
				tagInfo
			})
		elseif tag == "e" then
			local objectReference = self.view.physiqueItemUButton:GetComponent("ObjectReference")
			local txtPhysiqueUSDFText = objectReference:GetRefValue("txtPhysiqueUSDFText")
			local physiqueL10nName = ""
			local ePageIndex = 0

			if data.isMini then
				ePageIndex = 1
				physiqueL10nName = pg.getGameString("PET_ELITESIZE_LABEL_TITLE_MINI")
			elseif data.isBoss then
				physiqueL10nName = pg.getGameString("PET_ELITESIZE_LABEL_TITLE")
			end

			self.view.physiqueItemUButton:TryChangePage("Type", ePageIndex)
			ClientTextUtils.setText(txtPhysiqueUSDFText, physiqueL10nName)
			LuaUIUtils.setPetTagLabelToolTip(self.view.physiqueItemUButton, {
				tagInfo
			})
		end
	end
end

return PetFertilityIncubateResultCtrl
