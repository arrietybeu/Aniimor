-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RecommendPet\\RecommendPetCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("RecommendPetCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local RecommendPetCtrl = Class.LightClass("RecommendPetCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RecommendPetData = require("Data.recommend_pet_data")
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local ElementPropData = require("Data.element_prop_data")
local UIConst = require("Const.UIConst")
local PetConfigData = require("Data.pet_config_data")
local PetData = require("Data.pet_data")
local Const = require("Common.Const.Const")
local BossRushLevelData = require("Data.bossrush_guanka_data")
local IntelligentFilterData = require("Data.intelligent_filter_data")
local CommonPetGroupData = require("Data.common_pet_group_data")

RecommendPetCtrl.messages = {}

function RecommendPetCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.fromRogue = false

	if info.isRogue then
		local difficultyCfg = RogueDifficultyData[info.levelId]

		if not difficultyCfg then
			return
		end

		self.recommendPetSets = difficultyCfg.recommendPet
		self.fromRogue = true
	elseif info.isBossRush then
		local levelData = BossRushLevelData[info.levelId]

		if not levelData then
			return
		end

		local cfg = IntelligentFilterData[levelData.intelligentFilterId]

		if not cfg then
			return
		end

		self.recommendPetSets = cfg.recommendPetRef
		self.commonTemplateIds = CommonPetGroupData[cfg.commonPetRef]
	elseif info.intelligentFilterId then
		local cfg = IntelligentFilterData[info.intelligentFilterId]

		if not cfg then
			return
		end

		self.recommendPetSets = cfg.recommendPetRef
		self.commonTemplateIds = CommonPetGroupData[cfg.commonPetRef]
	elseif info.recommendPet then
		local recommendPetSets = info.recommendPet
		local commonPetGroupId

		self.recommendPetSets = {}

		for index = 1, #recommendPetSets do
			local recommendId = recommendPetSets[index]
			local cfg = RecommendPetData[recommendId]

			if cfg then
				table.insert(self.recommendPetSets, recommendId)

				commonPetGroupId = commonPetGroupId or cfg.commonPetGroupId
			end
		end

		if #self.recommendPetSets < 1 then
			return
		end

		self.commonTemplateIds = CommonPetGroupData[commonPetGroupId]
	end

	if not self.recommendPetSets then
		return
	end

	self.commonTypeMap = {
		[UIConst.NEW_PET_BATTLE_TYPE.DPS] = "typeDps",
		[UIConst.NEW_PET_BATTLE_TYPE.BREAK] = "typeBreak",
		[UIConst.NEW_PET_BATTLE_TYPE.SUP] = "typeSup",
		[UIConst.NEW_PET_BATTLE_TYPE.HEAL] = "typeHeal",
		[UIConst.NEW_PET_BATTLE_TYPE.ENERGY] = "typeEnergy"
	}
	self.typeKeys = {
		UIConst.NEW_PET_BATTLE_TYPE.DPS,
		UIConst.NEW_PET_BATTLE_TYPE.BREAK,
		UIConst.NEW_PET_BATTLE_TYPE.SUP,
		UIConst.NEW_PET_BATTLE_TYPE.ENERGY,
		UIConst.NEW_PET_BATTLE_TYPE.HEAL
	}

	self:initPetRecommendPopup()
end

function RecommendPetCtrl:getCommonPets(battleType)
	if not self.commonTemplateIds then
		return
	end

	return self.commonTemplateIds[self.commonTypeMap[battleType]]
end

function RecommendPetCtrl:addListener()
	function self.view.confirmBtn.luaClick()
		self:close()
	end

	function self.view.rightUpCornerCloseBtn.luaClick()
		self:close()
	end

	function self.view.elementUList.luaRenderItem(button, index, data)
		self:renderElementBtn(button, data)
	end

	function self.view.petUList.luaRenderItem(button, index, data)
		self:renderRecommendPetList(button, index, data)
	end
end

function RecommendPetCtrl:initPetRecommendPopup()
	self.recommendPetDatas = {}

	ClientTextUtils.setText(self.view.titleText, pg.getGameString("RECOMMEND_PET_POPUP_TITLE"))

	local elementDataList = {}

	for _, recommendId in ipairs(self.recommendPetSets) do
		local dataInfo = RecommendPetData[recommendId]

		if dataInfo then
			table.insert(elementDataList, {
				element = dataInfo.elementType,
				recommendId = recommendId
			})
		end
	end

	if #elementDataList < 1 then
		return
	end

	elementDataList[1].selected = true

	self.view.elementUList:SetList(elementDataList)

	function self.view.elementUList.luaClick(button, data)
		self:refreshRecommendPetList(data.recommendId)
	end

	self:refreshRecommendPetList(elementDataList[1].recommendId)
end

function RecommendPetCtrl:refreshRecommendPetList(recommendId)
	local petSetInfo = RecommendPetData[recommendId] and RecommendPetData[recommendId].petSet

	if not petSetInfo then
		return
	end

	local petSetListData = self.recommendPetDatas[recommendId]

	if not petSetListData then
		local petSetListDataSpecial = {}

		for _, setInfo in ipairs(petSetInfo) do
			local petFunction = setInfo[1]
			local petList = setInfo[2]
			local petListData = {}

			for _, petPrototypeId in ipairs(petList) do
				table.insert(petListData, {
					petPrototypeId = petPrototypeId
				})
			end

			local commonPet = self:getCommonPets(petFunction) or {}

			for _, petPrototypeId in ipairs(commonPet) do
				if not table.contains(petList, petPrototypeId) then
					table.insert(petListData, {
						petPrototypeId = petPrototypeId
					})
				end
			end

			petSetListDataSpecial[petFunction] = {
				petFunction = petFunction,
				petList = petListData
			}
		end

		petSetListData = {}

		for i = 1, 5 do
			local petFunction = self.typeKeys[i]

			if not petSetListDataSpecial[petFunction] then
				local commonPet = self:getCommonPets(petFunction)

				if commonPet and #commonPet > 0 then
					local petListData = {}

					for _, petPrototypeId in ipairs(commonPet) do
						table.insert(petListData, {
							petPrototypeId = petPrototypeId
						})
					end

					table.insert(petSetListData, {
						petFunction = petFunction,
						petList = petListData
					})
				end
			else
				table.insert(petSetListData, petSetListDataSpecial[petFunction])
			end
		end

		self.recommendPetDatas[recommendId] = petSetListData
	end

	self.view.petUList:SetList(petSetListData)
	self.view.petUList:GoToIndex(0)
end

function RecommendPetCtrl:renderElementBtn(button, data)
	local elementId = data.element
	local elementProp = elementId and ElementPropData[elementId]
	local elementPageName = elementProp and elementProp.name
	local elementName = elementProp and elementProp.name_ch

	button:TryChangePage("Element", elementPageName)

	local objectReference = button:GetComponent("ObjectReference")
	local titleBlackUSDFText = objectReference:GetRefValue("titleBlackUSDFText")
	local titleWhiteUSDFText = objectReference:GetRefValue("titleWhiteUSDFText")
	local teamName = pg.getGameString("RECOMMEND_ELEMENT_TEAM")

	teamName = string.gsub(teamName, "{element}", pg.getLocalizationText(elementName))

	ClientTextUtils.setText(titleBlackUSDFText, teamName)
	ClientTextUtils.setText(titleWhiteUSDFText, teamName)
end

function RecommendPetCtrl:renderRecommendPetList(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local nameUSDFText = objectReference:GetRefValue("nameUSDFText")
	local petHeadUList = objectReference:GetRefValue("petHeadUList")
	local petFunction = data.petFunction

	if petFunction then
		local petFunctionKey = UIConst.PET_FUNCTION_TEXT_MAP[petFunction]
		local petFunctionName = petFunctionKey and PetConfigData[petFunctionKey]

		ClientTextUtils.setText(nameUSDFText, pg.getLocalizationText(petFunctionName))

		local petFunctionPageIndex = UIConst.PET_FUNCTION_PAGE_INDEX_MAP[petFunction]

		button:TryChangePage("PetPosition", petFunctionPageIndex)
	end

	function petHeadUList.luaRenderItem(button, index, data)
		self:renderRecommendPetBtn(button, data)
	end

	petHeadUList:SetList(data.petList)
end

function RecommendPetCtrl:renderRecommendPetBtn(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local petUButton = objectReference:GetRefValue("petUButton")
	local petElementUContainer = objectReference:GetRefValue("petElementUContainer")
	local cfgData = PetData[data.petPrototypeId or 0]

	if cfgData then
		if cfgData.iconName then
			local iconUrl = LuaUIUtils.getPetIcon(cfgData.iconName, LuaUIUtils.PET_ICON, Const.PET_LABEL_MASK.NORMAL)

			iconUImage.url = iconUrl
		end

		data.smallAreaId = 0

		LuaUIUtils.renderPetTip(petUButton, data, false, self.fromRogue, false, {
			fromRecommend = true
		})

		function petUButton.luaTooltipPopup(btn, isOpen)
			if not isOpen then
				petUButton.isSelected = false
			end
		end

		if cfgData.elementType and petElementUContainer then
			local mainElementType = cfgData.mainElementType
			local elementData = {
				{
					element = mainElementType
				}
			}

			for k, v in pairs(cfgData.elementType) do
				if k ~= mainElementType then
					table.insert(elementData, {
						element = k
					})
				end
			end

			if petElementUContainer:CheckURLLoaded() then
				local objectReference = petElementUContainer.content:GetComponent("ObjectReference")

				LuaUIUtils.showPetCellElements(objectReference, elementData)
			else
				petElementUContainer:LoadDefaultUrlManually(function(content)
					local objectReference = content:GetComponent("ObjectReference")

					LuaUIUtils.showPetCellElements(objectReference, elementData)
				end)
			end
		end
	end
end

function RecommendPetCtrl:onDestroy()
	self.recommendPetDatas = nil

	UICtrl.onDestroy(self)
end

function RecommendPetCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function RecommendPetCtrl:onShow()
	return
end

function RecommendPetCtrl:onHide()
	return
end

return RecommendPetCtrl
