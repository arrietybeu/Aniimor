-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertility\\Component\\PetBreedComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local PetBreedComponent = Class.LightClass("PetBreedComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")

PetBreedComponent.PAGE_TYPE = {
	MALE = 0,
	FEMALE = 1
}
PetBreedComponent.BREED_REMAINS_COLOR = {
	[0] = "FF0031",
	"FF0031",
	"00FF17",
	"00FF17"
}

function PetBreedComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.breedRoot = self.objectReference:GetRefValue("breedRoot")
	self.btnTabMaleUButton = self.objectReference:GetRefValue("btnTabMaleUButton")
	self.btnTabFemaleUButton = self.objectReference:GetRefValue("btnTabFemaleUButton")
	self.btnMainMaleUButton = self.objectReference:GetRefValue("btnMainMaleUButton")
	self.btnMainFemaleUButton = self.objectReference:GetRefValue("btnMainFemaleUButton")
	self.petSelPanelUComponent = self.objectReference:GetRefValue("petSelPanelUComponent")
	self.petInfoUComponent = self.objectReference:GetRefValue("petInfoUComponent")
	self.petListUList = self.objectReference:GetRefValue("petListUList")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.elementUList = self.objectReference:GetRefValue("elementUList")
	self.nameUText = self.objectReference:GetRefValue("nameUText")
	self.btnFavoriteUButton = self.objectReference:GetRefValue("btnFavoriteUButton")
	self.breedRemainsList = self.objectReference:GetRefValue("breedRemainsList")
	self.breedRemainsText = self.objectReference:GetRefValue("breedRemainsText")
	self.passionUComponent = self.objectReference:GetRefValue("passionUComponent")
	self.featureTitle = self.objectReference:GetRefValue("featureTitle")
	self.featureDesc = self.objectReference:GetRefValue("featureDesc")
	self.featureIconUImage = self.objectReference:GetRefValue("featureIconUImage")
	self.listGiftUList = self.objectReference:GetRefValue("listGiftUList")
	self.selectorUSelector = self.objectReference:GetRefValue("selectorUSelector")
	self.btnLeftUButton = self.objectReference:GetRefValue("btnLeftUButton")
	self.btnRightUButton = self.objectReference:GetRefValue("btnRightUButton")
	self.btnCleanFilterUButton = self.objectReference:GetRefValue("btnCleanFilterUButton")
	self.btnFilter1UButton = self.objectReference:GetRefValue("btnFilter1UButton")
	self.btnFilter2UButton = self.objectReference:GetRefValue("btnFilter2UButton")
	self.btNextUButton = self.objectReference:GetRefValue("btNextUButton")
end

function PetBreedComponent:initView()
	function self.btnMainMaleUButton.luaClick()
		self.ctrl:resetBreedChoose()
		self:switchSexPage(PetBreedComponent.PAGE_TYPE.MALE)
	end

	function self.btnMainFemaleUButton.luaClick()
		self.ctrl:resetBreedChoose()
		self:switchSexPage(PetBreedComponent.PAGE_TYPE.FEMALE)
	end

	function self.btnTabMaleUButton.luaClick()
		self:switchSexPage(PetBreedComponent.PAGE_TYPE.MALE)
	end

	function self.btnTabFemaleUButton.luaClick()
		self:switchSexPage(PetBreedComponent.PAGE_TYPE.FEMALE)
	end

	function self.petListUList.luaRenderItem(button, index, data)
		self:renderPetItem(button, index, data)
	end

	function self.btnFavoriteUButton.luaClick()
		self:onClickFavoriteBtn()
	end

	function self.btnConfirmUButton.luaClick()
		self:onClickConfirmBtn()
	end

	function self.btNextUButton.luaClick()
		self:onClickNextBtn()
	end

	function self.btnLeftUButton.luaClick()
		self:switchBoxPage(false)
	end

	function self.btnRightUButton.luaClick()
		self:switchBoxPage(true)
	end

	function self.btnFilter1UButton.luaClick()
		self:openFilterPanel()
	end

	function self.btnFilter2UButton.luaClick()
		self:openFilterPanel()
	end

	function self.btnCleanFilterUButton.luaClick()
		self:endFilter()
	end
end

function PetBreedComponent:showPage()
	self.curBoxIndex = 1
	self.curSortId = 0
	self.isDescending = true
	self.currentPageSexType = PetBreedComponent.PAGE_TYPE.MALE
	self.currentMalePetId = nil
	self.currentFemalePetId = nil
	self.currentMaleEthnicGroup = nil
	self.currentFemaleEthnicGroup = nil
	self.isFilter = nil

	self:refreshPetList()
	self:refreshNextBtnState()
	self.btnTabMaleUButton:TryChangePage("filled", 0)
	self.btnTabFemaleUButton:TryChangePage("filled", 0)
end

function PetBreedComponent:destroy()
	self.currentPageSexType = nil
	self.currentMalePetId = nil
	self.currentFemalePetId = nil
	self.currentMaleEthnicGroup = nil
	self.currentFemaleEthnicGroup = nil
end

function PetBreedComponent:switchBoxPage(isNxt)
	local maxPage = #pg.me.petBoxMap

	if isNxt then
		if maxPage < self.curBoxIndex + 1 then
			self.curBoxIndex = 1
		else
			self.curBoxIndex = self.curBoxIndex + 1
		end
	elseif self.curBoxIndex - 1 < 1 then
		self.curBoxIndex = maxPage
	else
		self.curBoxIndex = self.curBoxIndex - 1
	end

	self.isFilter = nil

	self:refreshPetList()
end

function PetBreedComponent:switchBoxToIndex(index)
	if not index then
		return
	end

	self.curBoxIndex = index
	self.isFilter = nil

	self:refreshPetList()
end

function PetBreedComponent:openFilterPanel()
	pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT_FILTER, {
		sortId = self.curSortId,
		isDescending = self.isDescending,
		filter = self.model:getFilter(),
		doFilterCallback = function(filter, sortId, isDescending)
			self.curSortId = sortId
			self.isDescending = isDescending

			self.model:setFilter(filter)

			if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_FERTILITY) then
				self:startFilter()
			end
		end
	})
end

function PetBreedComponent:refreshPetList()
	local pets

	if self.isFilter then
		pets = self.model:getFilteredPetsInfo(self.curSortId, self.isDescending, 4, 16)
	else
		pets = self.model:getBoxInfoById(self.model:getBoxIdByBoxSequenceIndex(self.curBoxIndex), self.curSortId, self.isDescending)
	end

	if not pets then
		return
	end

	function self.petListUList.luaFinishRender(_)
		local btn

		if self.currentPageSexType == PetBreedComponent.PAGE_TYPE.MALE then
			btn = self:getPetButtonByPetId(self.currentMalePetId)
		else
			btn = self:getPetButtonByPetId(self.currentFemalePetId)
		end

		self:refreshInfoPanelState(btn and btn.dataFromUList or nil)
	end

	self.petListUList:SetList(pets)
	self.selectorUSelector:ClosePopup()
	self:refreshBoxSelector()
	self.petListUList:GoToIndex(0)
end

function PetBreedComponent:renderPetItem(button, index, data, cb)
	button.draggable = false

	local state = data.empty and 2 or 0

	button:TryChangePage("state", state)

	button.name = "empty"

	local select = 0

	button:TryChangePage("select", select)

	if data.empty then
		return
	end

	button.name = data.id

	button:TryChangePage("Type", data.isShiny and 1 or 0)
	button:TryChangePage("favState", data.isFavorite and 1 or 0)

	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local lifeCellUButton = objectReference:GetRefValue("lifeCellUButton")
	local listUList = objectReference:GetRefValue("listUList")

	iconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender), function()
		return
	end)

	function listUList.luaRenderItem(b, i, d)
		b:TryChangePage("Select", d.select and 1 or 0)
	end

	local temp = {}

	for i = 1, data.breedCountMax do
		temp[#temp + 1] = {
			select = i <= data.breedRemains
		}
	end

	listUList:SetList(temp)

	local reason

	if data.breedRemains <= 0 then
		state = 1
		reason = "FERTILITY_WARN4"
	end

	if data.gender == Const.GENDER_TYPE_MALE then
		lifeCellUButton:TryChangePage("Gender", 0)

		if self.currentPageSexType == PetBreedComponent.PAGE_TYPE.FEMALE then
			state = 1
			reason = "FERTILITY_WARN2"
		elseif self.currentFemaleEthnicGroup and data.ethnicGroup ~= self.currentFemaleEthnicGroup then
			state = 1
			reason = "FERTILITY_WARN6"
		end
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		lifeCellUButton:TryChangePage("Gender", 1)

		if self.currentPageSexType == PetBreedComponent.PAGE_TYPE.MALE then
			state = 1
			reason = "FERTILITY_WARN1"
		elseif self.currentMaleEthnicGroup and data.ethnicGroup ~= self.currentMaleEthnicGroup then
			state = 1
			reason = "FERTILITY_WARN6"
		end
	else
		lifeCellUButton:TryChangePage("Gender", 2)

		state = 1
		reason = "FERTILITY_WARN7"
	end

	button:TryChangePage("state", state)

	if data.gender == Const.GENDER_TYPE_MALE and self.currentPageSexType == PetBreedComponent.PAGE_TYPE.MALE and data.id == self.currentMalePetId then
		select = 1
	elseif data.gender == Const.GENDER_TYPE_FEMALE and self.currentPageSexType == PetBreedComponent.PAGE_TYPE.FEMALE and data.id == self.currentFemalePetId then
		select = 1
	end

	button:TryChangePage("select", select)

	function button.luaClick()
		if reason then
			pg.global.showBubbleMessageRaw(pg.getGameString(reason))
		end

		self:clickPetIcon(state, select, data)
	end

	if cb then
		cb()
	end
end

function PetBreedComponent:clickPetIcon(state, select, data)
	if state ~= 0 then
		return
	end

	if data.gender == Const.GENDER_TYPE_MALE then
		self.currentMalePetId = select == 0 and data.id or nil
		self.currentMaleEthnicGroup = select == 0 and data.ethnicGroup or nil

		self:onCurrentMalePetIdChanged()
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		self.currentFemalePetId = select == 0 and data.id or nil
		self.currentFemaleEthnicGroup = select == 0 and data.ethnicGroup or nil

		self:onCurrentFemalePetIdChanged()
	end
end

function PetBreedComponent:refreshBoxSelector()
	local boxPetMap = pg.me.petBoxMap
	local boxInfos = self.model:getBoxInfos()
	local selectBoxId = self.model:getBoxIdByBoxSequenceIndex(self.curBoxIndex)
	local objRef = self.selectorUSelector:GetComponent("ObjectReference")
	local boxName = objRef:GetRefValue("boxName")
	local txtNameUText = objRef:GetRefValue("txtNameUText")
	local customName = boxPetMap[selectBoxId].customName
	local count = boxPetMap[selectBoxId].count
	local slotCount = boxPetMap[selectBoxId].slotCount
	local boxNameContent = ""

	if customName and customName ~= "" then
		boxNameContent = string.format("%s (%s/%s)", customName, count, slotCount)
	else
		boxNameContent = string.format("%s %s (%s/%s)", pg.getGameString("DEFAULT_PET_BOX_NAME"), selectBoxId, count, slotCount)
	end

	ClientTextUtils.setText(boxName, boxNameContent)
	ClientTextUtils.setText(txtNameUText, boxNameContent)

	function self.selectorUSelector.luaRenderPopup(popup, list)
		local objectReference1 = popup:GetComponent("ObjectReference")
		local boxNameUText = objectReference1:GetRefValue("boxNameUText")

		ClientTextUtils.setText(boxNameUText, boxNameContent)

		function list.luaRenderItem(button, _, data)
			local objectReference = button:GetComponent("ObjectReference")
			local numUText = objectReference:GetRefValue("numUText")
			local nameUText = objectReference:GetRefValue("nameUText")

			button:TryChangePage("hideLockIcon", 1)
			ClientTextUtils.setText(numUText, data.countNum)

			if data.customName and data.customName ~= "" then
				ClientTextUtils.setText(nameUText, data.customName)
			else
				ClientTextUtils.setText(nameUText, string.format("%s %s", pg.getGameString("DEFAULT_PET_BOX_NAME"), data.idx))
			end

			function button.luaClick()
				self:switchBoxToIndex(self.model:getBoxSequenceIndexByBoxId(data.idx))
			end
		end

		function list.luaFinishRender(subList)
			local btns = subList:GetAllButtons()

			for i = 0, btns.Length - 1 do
				btns[i]:TryChangePage("select", btns[i].dataFromUList.idx == selectBoxId and 1 or 0)
			end
		end

		list:SetList(boxInfos)
	end

	self.selectorUSelector:SetOptions(boxInfos)
end

function PetBreedComponent:switchSexPage(sex)
	local _, page = self.breedRoot:TryGetCurrentPage("FertilityState")

	if page == 1 and sex == self.currentPageSexType then
		return
	end

	self.currentPageSexType = sex

	self:onCurrentPageSexTypeChanged()
	self.petSelPanelUComponent:TryChangePage("GenderTab", sex)
	self.breedRoot:TryChangePage("FertilityState", 1)
	self.ctrl:refreshBreedSceneSelectedPetEnt(self.currentMalePetId, true)
	self.ctrl:refreshBreedSceneSelectedPetEnt(self.currentFemalePetId, false)
end

function PetBreedComponent:refreshNextBtnState()
	if self.currentMalePetId and self.currentFemalePetId then
		self.petInfoUComponent:TryChangePage("showConfirmBtn", 1)
	else
		self.petInfoUComponent:TryChangePage("showConfirmBtn", 0)
	end
end

function PetBreedComponent:refreshInfoPanelState(data)
	if not data then
		self.infoPanelPetId = nil

		self.petSelPanelUComponent:TryChangePage("Empty", 1)

		return
	end

	self.infoPanelPetId = data.id

	self.petSelPanelUComponent:TryChangePage("Empty", 0)

	if data.gender == Const.GENDER_TYPE_MALE then
		self.petInfoUComponent:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		self.petInfoUComponent:TryChangePage("Gender", 1)
	else
		self.petInfoUComponent:TryChangePage("Gender", 2)
	end

	self.petInfoUComponent:TryChangePage("isFlash", data.isShiny and 1 or 0)

	function self.elementUList.luaRenderItem(button, _, data1)
		LuaUIUtils.setElementButtonNew(button, data1.element)
	end

	self.elementUList:SetList(data.elementNames)

	local petNameStr = pg.getLocalizationText(self.model:getPetName(data.id))

	ClientTextUtils.setText(self.nameUText, petNameStr)
	self.btnFavoriteUButton:TryChangePage("enable", data.isFavorite and 1 or 0)

	function self.breedRemainsList.luaRenderItem(b, _, d)
		b:TryChangePage("Select", d.select and 1 or 0)
	end

	local temp = {}

	for i = 1, data.breedRemains do
		temp[#temp + 1] = {
			select = true
		}
	end

	self.breedRemainsList:SetList(temp)
	ClientTextUtils.setText(self.breedRemainsText, string.format(pg.getGameString("BREED_REMAIN"), PetBreedComponent.BREED_REMAINS_COLOR[data.breedRemains], data.breedRemains))

	if data.featureInfo then
		self.passionUComponent:TryChangePage("hasFeature", 1)
		self.passionUComponent:TryChangePage("isS", data.featureInfo.rare or 0)
		ClientTextUtils.setText(self.featureDesc.content, pg.getLocalizationText(data.featureInfo.desc))
		ClientTextUtils.setText(self.featureTitle, pg.getLocalizationText(data.featureInfo.name))

		self.featureIconUImage.url = data.featureInfo.icon
	else
		self.passionUComponent:TryChangePage("hasFeature", 0)
	end

	function self.listGiftUList.luaRenderItem(button, _, data1)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local txtNameUText = objectReference:GetRefValue("txtNameUText")
		local root = objectReference:GetRefValue("root")

		iconUImage.url = data1.icon

		ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(data1.name))
		root:TryChangePage("Quality", data1.quality)
		root:TryChangePage("Selected", 0)

		function button.luaClick()
			pg.global.ui:open(UIConst.UI_ID_COMMON_CUSTOM_INFO_TIP, {
				autoHor = true,
				targetRect = button,
				icon = data1.icon,
				name = data1.name,
				desc = data1.desc
			})
		end
	end

	self.listGiftUList:SetList(data.breedTalent)
end

function PetBreedComponent:openBreedPanel()
	self:showPage()
	self.breedRoot:TryChangePage("FertilityState", 0)
end

function PetBreedComponent:startFilter()
	self.isFilter = true

	self:refreshPetList(true)
	self.petSelPanelUComponent:TryChangePage("enableFilter", 1)
end

function PetBreedComponent:endFilter()
	self.curSortId = 0
	self.isDescending = true
	self.isFilter = nil

	self:refreshPetList()
	self.petSelPanelUComponent:TryChangePage("enableFilter", 0)
end

function PetBreedComponent:onClickFavoriteBtn()
	PetManagementUtils.setRenderFavoriteToolTips(self.btnFavoriteUButton, self.infoPanelPetId)
end

function PetBreedComponent:onClickConfirmBtn()
	if not self.currentMalePetId or not self.currentFemalePetId then
		pg.global.showBubbleMessageRaw(pg.getGameString("FERTILITY_WARN"))

		return
	end

	local petInfo1 = self.model:getPetInfo(self.currentMalePetId)
	local petInfo2 = self.model:getPetInfo(self.currentFemalePetId)
	local tempFeatureTable = {
		petInfo1.featureInfo,
		petInfo2.featureInfo
	}

	table.sort(tempFeatureTable, function(a, b)
		return a.rare > b.rare
	end)

	local tempBreedTalentTable = {}

	for _, v in pairs(petInfo1.breedTalent) do
		tempBreedTalentTable[#tempBreedTalentTable + 1] = v
	end

	for _, v in pairs(petInfo2.breedTalent) do
		tempBreedTalentTable[#tempBreedTalentTable + 1] = v
	end

	table.sort(tempBreedTalentTable, function(a, b)
		return a.quality > b.quality
	end)
	self.ctrl:openBreedConfirmPage(tempFeatureTable, tempBreedTalentTable, self.currentMalePetId, self.currentFemalePetId)
	self.breedRoot:TryChangePage("FertilityState", 2)
end

function PetBreedComponent:onClickNextBtn()
	if self.currentPageSexType == PetBreedComponent.PAGE_TYPE.FEMALE then
		self:switchSexPage(PetBreedComponent.PAGE_TYPE.MALE)
	elseif self.currentPageSexType == PetBreedComponent.PAGE_TYPE.MALE then
		self:switchSexPage(PetBreedComponent.PAGE_TYPE.FEMALE)
	end
end

function PetBreedComponent:onCurrentPageSexTypeChanged()
	local btns = self.petListUList:GetAllButtons()
	local selectedBtn

	if self.currentPageSexType == PetBreedComponent.PAGE_TYPE.MALE then
		for i = 0, btns.Length - 1 do
			if btns[i].dataFromUList.gender ~= Const.GENDER_TYPE_NONE then
				self:renderPetItem(btns[i], nil, btns[i].dataFromUList, nil)
			end

			if btns[i].name == self.currentMalePetId then
				self:renderPetItem(btns[i], nil, btns[i].dataFromUList, nil)

				selectedBtn = btns[i]
			end
		end
	else
		for i = 0, btns.Length - 1 do
			if btns[i].dataFromUList.gender ~= Const.GENDER_TYPE_NONE then
				self:renderPetItem(btns[i], nil, btns[i].dataFromUList, nil)
			end

			if btns[i].name == self.currentFemalePetId then
				self:renderPetItem(btns[i], nil, btns[i].dataFromUList, nil)

				selectedBtn = btns[i]
			end
		end
	end

	self:refreshInfoPanelState(selectedBtn and selectedBtn.dataFromUList or nil)
end

function PetBreedComponent:onCurrentMalePetIdChanged()
	local btns = self.petListUList:GetAllButtons()
	local selectedBtn

	for i = 0, btns.Length - 1 do
		local _, page = btns[i]:TryGetCurrentPage("select")

		if page == 1 or btns[i].name == self.currentMalePetId then
			self:renderPetItem(btns[i], nil, btns[i].dataFromUList, nil)
		end

		if btns[i].name == self.currentMalePetId then
			selectedBtn = btns[i]
		end
	end

	self:refreshInfoPanelState(selectedBtn and selectedBtn.dataFromUList or nil)
	self.btnTabMaleUButton:TryChangePage("filled", self.currentMalePetId and 1 or 0)
	self:refreshNextBtnState()
	self.ctrl:refreshBreedSceneSelectedPetEnt(self.currentMalePetId, true)
end

function PetBreedComponent:onCurrentFemalePetIdChanged()
	local btns = self.petListUList:GetAllButtons()
	local selectedBtn

	for i = 0, btns.Length - 1 do
		local _, page = btns[i]:TryGetCurrentPage("select")

		if page == 1 or btns[i].name == self.currentFemalePetId then
			self:renderPetItem(btns[i], nil, btns[i].dataFromUList, nil)
		end

		if btns[i].name == self.currentFemalePetId then
			selectedBtn = btns[i]
		end
	end

	self:refreshInfoPanelState(selectedBtn and selectedBtn.dataFromUList or nil)
	self.btnTabFemaleUButton:TryChangePage("filled", self.currentFemalePetId and 1 or 0)
	self:refreshNextBtnState()
	self.ctrl:refreshBreedSceneSelectedPetEnt(self.currentFemalePetId, false)
end

function PetBreedComponent:onPetFavoriteChanged(data)
	if self.infoPanelPetId == data.id then
		self.btnFavoriteUButton:TryChangePage("enable", data.isFavorite and 1 or 0)
	end

	local btns = self.petListUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		if btns[i].dataFromUList.id == data.id then
			self:renderPetItem(btns[i], nil, data, nil)
		end
	end
end

function PetBreedComponent:onPetBreedRemainsChanged(petInfo)
	local btn = self:getPetButtonByPetId(petInfo.id)

	if btn then
		if petInfo.id == self.currentMalePetId then
			if petInfo.breedRemains <= 0 then
				self.currentMalePetId = nil

				self.btnTabMaleUButton:TryChangePage("filled", self.currentMalePetId and 1 or 0)
				self:refreshNextBtnState()
			end
		elseif petInfo.id == self.currentFemalePetId and petInfo.breedRemains <= 0 then
			self.currentFemalePetId = nil

			self.btnTabFemaleUButton:TryChangePage("filled", self.currentFemalePetId and 1 or 0)
			self:refreshNextBtnState()
		end

		self:refreshPetList()
	end
end

function PetBreedComponent:getPetButtonByPetId(petId)
	local btns = self.petListUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		if btns[i].name == petId then
			return btns[i]
		end
	end

	return nil
end

function PetBreedComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

return PetBreedComponent
