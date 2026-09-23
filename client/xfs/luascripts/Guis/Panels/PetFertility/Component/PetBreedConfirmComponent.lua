-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertility\\Component\\PetBreedConfirmComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local Lume = require("Core.Common.lume")
local PetTalentData = require("Data.pet_talent_data")
local PetData = require("Data.pet_data")
local PetBreedConfirmComponent = Class.LightClass("PetBreedConfirmComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")

function PetBreedConfirmComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listCharUList = self.objectReference:GetRefValue("listCharUList")
	self.listGiftUList = self.objectReference:GetRefValue("listGiftUList")
	self.btnInfoUButton = self.objectReference:GetRefValue("btnInfoUButton")
	self.root = self.objectReference:GetRefValue("root")
	self.featureImg = self.objectReference:GetRefValue("featureImg")
	self.featureDisplayCmp = self.objectReference:GetRefValue("featureDisplayCmp")
	self.eggName = self.objectReference:GetRefValue("eggName")
	self.gift1UButton = self.objectReference:GetRefValue("gift1UButton")
	self.gift2UButton = self.objectReference:GetRefValue("gift2UButton")
	self.gift3UButton = self.objectReference:GetRefValue("gift3UButton")
	self.gift4UButton = self.objectReference:GetRefValue("gift4UButton")
	self.talentCount = self.objectReference:GetRefValue("talentCount")
	self.talent1Icon = self.objectReference:GetRefValue("talent1Icon")
	self.talent2Icon = self.objectReference:GetRefValue("talent2Icon")
	self.talent3Icon = self.objectReference:GetRefValue("talent3Icon")
	self.talent4Icon = self.objectReference:GetRefValue("talent4Icon")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.giftBtns = {
		self.gift1UButton,
		self.gift2UButton,
		self.gift3UButton,
		self.gift4UButton
	}
	self.talentIcons = {
		self.talent1Icon,
		self.talent2Icon,
		self.talent3Icon,
		self.talent4Icon
	}
end

function PetBreedConfirmComponent:initView()
	function self.btnInfoUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_PET_FERTILITY_RULE)
	end

	function self.btnConfirmUButton.luaClick()
		self:onConfirmClick()
	end
end

function PetBreedConfirmComponent:openConfirmPage(featureTable, breedTalentTable, malePetId, femalePetId)
	self.featureTable = featureTable
	self.breedTalentTable = breedTalentTable
	self.malePetId = malePetId
	self.femalePetId = femalePetId
	self.selectedFeatureIndex = nil
	self.selectedTalentIndex = {}

	self:initCharList(featureTable)
	self:initTalentList(breedTalentTable)
	self:setEggInfo()
end

function PetBreedConfirmComponent:initCharList(featureTable)
	function self.listCharUList.luaRenderItem(button, index, data)
		self:renderFeatureItem(button, index, data)
	end

	self.listCharUList:SetList(featureTable)
end

function PetBreedConfirmComponent:initTalentList(breedTalentTable)
	function self.listGiftUList.luaRenderItem(button, index, data)
		self:renderTalentItem(button, index, data)
	end

	self.listGiftUList:SetList(breedTalentTable)

	self.talentGroupCount = {}

	for _, v in pairs(breedTalentTable) do
		self.talentGroupCount[v.group] = true
	end
end

function PetBreedConfirmComponent:renderFeatureItem(button, index, data)
	button.name = index + 1

	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local name = objectReference:GetRefValue("name")
	local desc = objectReference:GetRefValue("desc")

	button:TryChangePage("isS", data.rare)

	iconUImage.url = data.icon

	ClientTextUtils.setText(name, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(desc.content, pg.getLocalizationText(data.desc))
	button:TryChangePage("Selected", button.name == tostring(self.selectedFeatureIndex) and 1 or 0)

	function button.luaClick()
		self.selectedFeatureIndex = self.selectedFeatureIndex ~= tonumber(button.name) and tonumber(button.name) or nil

		self:onSelectedFeatureChanged()
	end
end

function PetBreedConfirmComponent:renderTalentItem(button, index, data)
	button.name = index + 1

	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local root = objectReference:GetRefValue("root")

	iconUImage.url = data.icon

	ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(data.name))
	root:TryChangePage("Quality", data.quality)
	root:TryChangePage("Selected", 0)

	if self:isSameGroupExists(tonumber(button.name)) then
		root:TryChangePage("Selected", 2)
	end

	if self:getIndexPos(tonumber(button.name)) then
		root:TryChangePage("Selected", 1)
	end

	function button.luaLongPress(time)
		pg.global.ui:open(UIConst.UI_ID_COMMON_CUSTOM_INFO_TIP, {
			autoHor = true,
			targetRect = button,
			icon = data.icon,
			name = data.name,
			desc = data.desc
		})
	end

	function button.luaEndLongPress()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_CUSTOM_INFO_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_CUSTOM_INFO_TIP)
		end
	end

	function button.luaClick()
		local key = self:getIndexPos(tonumber(button.name))

		if key then
			table.remove(self.selectedTalentIndex, key)
		elseif self:isSameGroupExists(tonumber(button.name)) then
			return
		else
			if #self.selectedTalentIndex >= self.model:getPlayerMaxEggCustomTalentCount() then
				return
			end

			self.selectedTalentIndex[#self.selectedTalentIndex + 1] = tonumber(button.name)
		end

		self:onSelectedTalentChanged(tonumber(button.name))
	end
end

function PetBreedConfirmComponent:setEggInfo()
	local maxEggCustomTalentCount = self.model:getPlayerMaxEggCustomTalentCount()

	if self.selectedFeatureIndex then
		self.featureDisplayCmp:TryChangePage("Empty", 0)
		self.featureDisplayCmp:TryChangePage("isS", self.featureTable[self.selectedFeatureIndex].rare)

		self.featureImg.url = self.featureTable[self.selectedFeatureIndex].icon
	else
		self.featureDisplayCmp:TryChangePage("Empty", 1)
		self.featureDisplayCmp:TryChangePage("isS", 0)
	end

	ClientTextUtils.setText(self.eggName, pg.getGameString("UNKNOWN_EGG"))
	ClientTextUtils.setText(self.talentCount, string.format("%s/%s", #self.selectedTalentIndex, maxEggCustomTalentCount))

	for i = 1, #self.giftBtns do
		if maxEggCustomTalentCount < i then
			self.giftBtns[i]:TryChangePage("IconState", 3)
		else
			self.giftBtns[i]:TryChangePage("IconState", i <= #self.selectedTalentIndex and 1 or 0)
		end
	end

	for i = 1, #self.selectedTalentIndex do
		self.talentIcons[i].url = self.breedTalentTable[self.selectedTalentIndex[i]].icon

		self.giftBtns[i]:TryChangePage("Quality", self.breedTalentTable[self.selectedTalentIndex[i]].quality)
	end
end

function PetBreedConfirmComponent:onSelectedFeatureChanged()
	local btns = self.listCharUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		local _, page = btns[i]:TryGetCurrentPage("Selected")

		if page == 1 or btns[i].name == tostring(self.selectedFeatureIndex) then
			self:renderFeatureItem(btns[i], i, btns[i].dataFromUList)
		end
	end

	self:setEggInfo()
end

function PetBreedConfirmComponent:onSelectedTalentChanged(buttonIdx)
	local btns = self.listGiftUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		if btns[i].dataFromUList.group == self.breedTalentTable[buttonIdx].group then
			self:renderTalentItem(btns[i], i, btns[i].dataFromUList)
		end
	end

	self:setEggInfo()
end

function PetBreedConfirmComponent:isSameGroupExists(index)
	local beCheckedGroup = self.breedTalentTable[index].group
	local temp = {}

	for _, idx in pairs(self.selectedTalentIndex) do
		if beCheckedGroup == self.breedTalentTable[idx].group then
			temp[#temp + 1] = idx
		end
	end

	if #temp <= 0 then
		return false, temp
	end

	return true, temp
end

function PetBreedConfirmComponent:getIndexPos(index)
	for key, idx in pairs(self.selectedTalentIndex) do
		if index == idx then
			return key
		end
	end

	return nil
end

function PetBreedConfirmComponent:onConfirmClick()
	if not self.selectedFeatureIndex then
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("BREED_FEATURE_INVALID"), function()
			return
		end, true)
	else
		local petInfo1 = self.model:getPetInfo(self.malePetId)
		local petInfo2 = self.model:getPetInfo(self.femalePetId)

		if #self.selectedTalentIndex < self.model:getPlayerMaxEggCustomTalentCount() and #self.selectedTalentIndex < Lume.count(self.talentGroupCount) then
			pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("BREED_TALENT_NOT_ALL_FILLED"), function()
				pg.me:serverMsg("RPC_CS_PetBreed", self.malePetId, self.femalePetId, {
					characterId = self.featureTable[self.selectedFeatureIndex].characterId,
					talentIds = self:summarizeTalentIds()
				}, function(noticeId, noticeArg)
					if noticeId == NoticeDef.SUCCESS then
						self:callBreedScene(petInfo1, petInfo2, noticeArg)
					end
				end)
			end, false, function()
				return
			end)
		else
			pg.me:serverMsg("RPC_CS_PetBreed", self.malePetId, self.femalePetId, {
				characterId = self.featureTable[self.selectedFeatureIndex].characterId,
				talentIds = self:summarizeTalentIds()
			}, function(noticeId, noticeArg)
				if noticeId == NoticeDef.SUCCESS then
					self:callBreedScene(petInfo1, petInfo2, noticeArg)
				end
			end)
		end
	end
end

function PetBreedConfirmComponent:callBreedScene(petInfo1, petInfo2, arg)
	self.ctrl:refreshBreedSceneSelectedPetEnt(nil, nil, true)
	self.ctrl:resetBreedChoose()
	self.ctrl:displayPetBallBreed(true, petInfo1.petPrototypeId, petInfo2.petPrototypeId, function()
		self.view.btnBackUButton.luaClick()
		self.view.root:TryChangePage("hideAll", 1)
	end)

	local isShiny = Utils.isLabelShiny(arg[2].label)
	local talent = {}

	for i = 1, #arg[2].talentIds do
		local talentTemplateId = arg[2].talentIds[i]

		if talentTemplateId then
			local name = PetTalentData[talentTemplateId].talentName
			local icon = PetTalentData[talentTemplateId].talentIcon
			local quality = PetTalentData[talentTemplateId].rarity
			local id = talentTemplateId
			local group = PetTalentData[talentTemplateId].group
			local desc = PetTalentData[talentTemplateId].dec

			talent[#talent + 1] = {
				name = name,
				icon = icon,
				quality = quality,
				id = id,
				group = group,
				desc = desc
			}
		end
	end

	table.sort(talent, function(a, b)
		return a.quality > b.quality
	end)
	pg.game.petBall:setEggInfo({
		featureId = arg[2].characterId,
		itemId = arg[1],
		isShiny = isShiny,
		eggName = pg.getLocalizationText(PetData[arg[2].templateId].name),
		talent = talent,
		isDoubleEggs = arg[3] == true
	})
end

function PetBreedConfirmComponent:summarizeTalent()
	local result = {}

	for _, v in pairs(self.selectedTalentIndex) do
		result[#result + 1] = self.breedTalentTable[v]
	end

	return result
end

function PetBreedConfirmComponent:summarizeTalentIds()
	local result = {}

	for _, v in pairs(self.selectedTalentIndex) do
		result[#result + 1] = self.breedTalentTable[v].id
	end

	return result
end

function PetBreedConfirmComponent:destroy()
	return
end

function PetBreedConfirmComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

return PetBreedConfirmComponent
