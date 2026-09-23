-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\Component\\SubNodeComps\\PetCardInfoComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetCardInfoComponent")
local Class = require("Core.Framework.Class")
local PetCardInfoComponent = Class.LiteClass("PetCardInfoComponent")
local PetResonaceStarComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetResonaceStarComponent")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetRenameValidator = require("Utils.PetRenameValidator")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local PetLevelData = require("Data.pet_level_data")
local NoticeDef = require("Common.NoticeDef")
local math_floor = math.floor
local string_format = string.format

function PetCardInfoComponent:ctor(petInfoUComponent, extraData)
	self.extraData = extraData or {}
	self.petInfoUComponent = petInfoUComponent

	local objectReference = self.petInfoUComponent:GetComponent("ObjectReference")

	self.petNameUText = objectReference:GetRefValue("petNameUText")
	self.petElementUList = objectReference:GetRefValue("petElementUList")
	self.numCPUText = objectReference:GetRefValue("numCPUText")
	self.btnRenameUButton = objectReference:GetRefValue("btnRenameUButton")
	self.btnFavoriteUButton = objectReference:GetRefValue("btnFavoriteUButton")
	self.numLevelUText = objectReference:GetRefValue("numLevelUText")
	self.expSlider = objectReference:GetRefValue("expSlider")
	self.typeImage = objectReference:GetRefValue("typeImage")
	self.typeDesc = objectReference:GetRefValue("typeDesc")
	self.name01USDFText = objectReference:GetRefValue("name01USDFText")
	self.nameShineUSDFText = objectReference:GetRefValue("nameShineUSDFText")
	self.listExploreAbilityUList = objectReference:GetRefValue("listExploreAbilityUList")
	self.listTagUList = objectReference:GetRefValue("listTagUList")
	self.starUContainer = objectReference:GetRefValue("starUContainer")
	self.btnLevelUButton = objectReference:GetRefValue("btnLevelUButton")

	function self.listTagUList.luaRenderItem(button, idx, data)
		LuaUIUtils.renderPetTagList(button, data)
		LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(self.petInfo.templateId, self.petInfo.label, self.petInfo.bodySizeType, self.petInfo.shinyStyle))
	end

	if self.btnFavoriteUButton then
		function self.btnFavoriteUButton.luaClick()
			self:onClickFavoriteBtn()
		end

		local isShowFavoriteBtn = self.extraData.isShowFavoriteBtn or true
		local isForbidFavoriteClick = self.extraData.isForbidFavoriteClick or false

		self.btnFavoriteUButton:SetActive(isShowFavoriteBtn)

		local rayBox = self.btnFavoriteUButton.transform:Find("RayBox").gameObject

		rayBox:SetActiveEx(not isForbidFavoriteClick)
	end

	function self.btnRenameUButton.luaClick()
		self:showRename()
	end

	function self.btnLevelUButton.luaClick()
		self:onPetLvUpClick()
	end
end

function PetCardInfoComponent:renderPetInfoCard(data, isInRogueDungeon)
	self.petId = data.id
	self.petInfo = data

	self:refreshPetName()

	function self.petElementUList.luaRenderItem(button, _, data1)
		LuaUIUtils.setElementButtonNew(button, data1.element, true, data.templateId)
	end

	LuaUIUtils.renderPetCharList(self.listExploreAbilityUList, data.templateId)

	local tagDatas = LuaUIUtils.getPetTagList(data)

	if self.listTagUList then
		self.listTagUList:SetList(tagDatas)
	end

	self.petElementUList:SetList(data.elementNames)
	ClientTextUtils.setText(self.numCPUText, "CP ", data.cp)

	if data.gender == Const.GENDER_TYPE_MALE then
		self.petInfoUComponent:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		self.petInfoUComponent:TryChangePage("Gender", 1)
	else
		self.petInfoUComponent:TryChangePage("Gender", 2)
	end

	self.petInfoUComponent:TryChangePage("isChange", data.isVariant and 1 or 0)

	local petType = PetData[data.templateId].functionId

	self.typeImage.url = PetConfigData.petFunctionIcon[petType]

	ClientTextUtils.setText(self.typeDesc, pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petType)]) or "")
	self:resetFavouriteBtnState(self.petInfo and self.petInfo.favoriteType or 0)
	self:refreshStarUpContainer()
	self:refreshLevelInfo(data)

	if self.btnLevelUButton then
		self.btnLevelUButton.interactable = not isInRogueDungeon
	end
end

function PetCardInfoComponent:resetFavouriteBtnState(favoriteType)
	PetManagementUtils.refreshFavoriteBtn(self.btnFavoriteUButton, favoriteType)
end

function PetCardInfoComponent:refreshLevelInfo(data)
	ClientTextUtils.setText(self.numLevelUText, data.level)

	local maxExp = PetLevelData[data.level + 1] ~= nil and PetLevelData[data.level + 1].needExp or 0

	self.expSlider.value = maxExp == 0 and 1 or data.exp / maxExp
end

function PetCardInfoComponent:refreshPetName(petName)
	local petNameStr = ""

	if petName and petName ~= "" then
		petNameStr = petName
	else
		petNameStr = PetManagementUtils.getPetL10nName(self.petId)
	end

	ClientTextUtils.setText(self.petNameUText, petNameStr)
	ClientTextUtils.setText(self.nameShineUSDFText, petNameStr)
	ClientTextUtils.setText(self.name01USDFText, petNameStr)
end

function PetCardInfoComponent:onClickFavoriteBtn()
	if not self.petId then
		return
	end

	PetManagementUtils.setRenderFavoriteToolTips(self.btnFavoriteUButton, self.petId)
end

function PetCardInfoComponent:showRename()
	if not self.petId then
		return
	end

	if not PetRenameValidator.canRenamePet() then
		pg.global.showBubbleMessage(NoticeDef.FORBID_CHANGE_PET_NAME)

		return
	end

	local title = pg.getGameString("RENAME_TIPS_PET")
	local id = self.petId
	local text = PetManagementUtils.getPetL10nName(self.petId)

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

function PetCardInfoComponent:refreshStarUpContainer()
	self:m_refreshStarUpContainer(self.petId, self, self.starUContainer)
end

function PetCardInfoComponent:m_refreshStarUpContainer(petId, uiObj, starUContainer)
	if not petId or not uiObj or not starUContainer then
		return
	end

	local curResonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)
	local stage = curResonanceInfo.resonanceStage or 0
	local level = curResonanceInfo.resonanceLevel or 0
	local curStageStarUrl = PetManagementUtils.getStarItemUrl(stage, true)

	starUContainer:SetUrlWithCallback(curStageStarUrl, function()
		if not petId or not uiObj then
			return
		end

		local starUCont = uiObj.starUContainer.content

		uiObj.m_starComp = PetResonaceStarComponent.new(starUCont)

		if uiObj.m_starComp then
			uiObj.m_starComp:updateAndRefresh(petId, {
				stage = stage,
				lv = level,
				pos = UIConst.STARCOMP_POS.PETINFO
			})
		end
	end)
end

function PetCardInfoComponent:onPetLvUpClick()
	if not self.petId then
		return
	end

	local petInfo = pg.me:getPetInfo(self.petId)

	if not petInfo then
		return
	end

	local templateId = petInfo and petInfo.templateId
	local pData = PetData[templateId]

	PetManagementUtils.onPetLvUpClick(self.petId, pData and pData.iconName, petInfo.label, Utils.canLevelBreakthrough(self.petId))
end

return PetCardInfoComponent
