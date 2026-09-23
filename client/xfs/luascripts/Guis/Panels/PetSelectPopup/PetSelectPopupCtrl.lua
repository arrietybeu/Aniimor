-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSelectPopup\\PetSelectPopupCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientConst = require("Const.ClientConst")
local PetSelectPopupCtrl = Class.LightClass("PetSelectPopupCtrl", UICtrl)
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PetData = require("Data.pet_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AddressDataConst = require("Const.AddressDataConst")
local PetManagementUtils = require("Utils.PetManagementUtils")
local OpDef = require("Common.OpDef")
local SceneData = require("Data.scene_data")
local NoticeDef = require("Common.NoticeDef")
local EventConst = require("Common.Const.EventConst")

PetSelectPopupCtrl.messages = {
	[MessageName.PLAYER_START_CARRY] = {
		"onPlayerStartCarry",
		true
	}
}

function PetSelectPopupCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initPetSelectPanel()

	if self.uiScene then
		self.uiScene:setLocalEnv()
	end
end

function PetSelectPopupCtrl:addListener()
	function self.view.bgCloseUButton.luaClick()
		self:close()
	end

	local closeCommonBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.bgCloseUButton.gameObject, "closeCommonBind")

	closeCommonBind.isVirtual = true
	closeCommonBind.priority = 1
	closeCommonBind.actionPath = "Common/ClosePanelCommon"

	function closeCommonBind.luaTrigger(inputInfo)
		self.view.bgCloseUButton.luaClick()
	end

	function self.view.btnConfirmUButton.luaClick()
		if not self.selectedPetData then
			return
		end

		if pg.space and SceneData[pg.space.sceneId].canTakeOutPet then
			local player = pg.me

			player:tryCarryEnt(self.selectedPetData.id, OpDef.OP.CS_PC_PetTakeOut, Const.CARRY_REQ_FROM_POPUP, function(noticeId, noticeArgs)
				if noticeId == NoticeDef.SUCCESS and pg.global and pg.global.eventEmitter then
					pg.global.eventEmitter:emit(EventConst.PLATFORM_ACHIEVEMENT_HUG_PET, {
						count = 1
					})
				end
			end)
			player:serverMsg("RPC_CS_PlayAppearanceAction", ClientConst.PlayHugEntActionId, "", false)
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("SCENE_CANNOT_HUG_PET_TIPS"))
		end
	end

	function self.view.btnLeftUButton.luaClick()
		if self.isSearching and not string.isNilOrEmpty(self.view.inputFieldUTMPInputField.text) then
			self.curSearchedIndex = self.curSearchedIndex - 1

			self:refreshSearchedPetList(self.curSearchedIndex)

			return
		end

		self.curBoxIndex = self.curBoxIndex == 1 and self.maxBoxIndex or self.curBoxIndex - 1

		self:refreshPetList(self.curBoxIndex)
	end

	function self.view.btnRightUButton.luaClick()
		if self.isSearching and not string.isNilOrEmpty(self.view.inputFieldUTMPInputField.text) then
			self.curSearchedIndex = self.curSearchedIndex + 1

			self:refreshSearchedPetList(self.curSearchedIndex)

			return
		end

		self.curBoxIndex = self.curBoxIndex == self.maxBoxIndex and 1 or self.curBoxIndex + 1

		self:refreshPetList(self.curBoxIndex)
	end

	function self.view.buttonSearchUButton.luaClick()
		self.isSearching = not self.isSearching

		self.view.widget:TryChangePage("Search", self.isSearching and 1 or 0)

		self.view.inputFieldUTMPInputField.text = ""

		self:refreshPetList(self.curBoxIndex)
		self.view.btnLeftUButton:SetActive(true)
		self.view.btnRightUButton:SetActive(true)
	end

	function self.view.inputFieldUTMPInputField.luaValueChanged(text)
		self.searchedPetList = {}

		for _, pet in pairs(pg.me.pets) do
			if string.isNilOrEmpty(text) then
				self:refreshPetList(self.curBoxIndex)

				return
			end

			if string.find(pet.customName, text) or PetData[pet.templateId] and string.find(pg.getLocalizationText(PetData[pet.templateId].name), text) then
				table.insert(self.searchedPetList, pet)
			end
		end

		self.curSearchedIndex = 0

		self:refreshSearchedPetList(self.curSearchedIndex)
	end

	function self.view.selectorUSelector.luaRenderPopup(popup, list)
		function list.luaRenderItem(button, _, data)
			local objectReference = button:GetComponent("ObjectReference")
			local txtUText = objectReference:GetRefValue("txtUText")

			if data.customName and data.customName ~= "" then
				ClientTextUtils.setText(txtUText, data.customName)
			else
				ClientTextUtils.setText(txtUText, pg.getGameString("DEFAULT_PET_BOX_NAME") .. " " .. data.idx)
			end
		end

		function list.luaSelectedChanged(selectorList)
			self.curBoxIndex = selectorList.selectedItem and selectorList.selectedItem.idx or 1

			self:refreshPetList(self.curBoxIndex)

			if self.selectedPetBtn then
				self.selectedPetBtn.isSelected = false
			end

			self.selectedPetData = nil

			self.view.selectorUSelector:ClosePopup()
			self.view.widget:TryChangePage("Selected", 0)
		end

		list:SetList(self.boxInfos)
		list:SelectItem(self.curBoxIndex - 1 or 0)
	end

	function self.view.btnAllSelectedUButton.luaSelectChanged(isSelected)
		if isSelected then
			self:showPetInfo()
		else
			self.view.widget:TryChangePage("ShowPetInfo", 0)
		end
	end
end

function PetSelectPopupCtrl:onPlayerStartCarry()
	pg.global.ui:closeAllNormalPanel()
end

function PetSelectPopupCtrl:initPetSelectPanel()
	self.view.btnAllSelectedUButton.isSelected = true

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("TAKE_OUT_PET"))

	self.isSearching = false
	self.curSearchedIndex = 0
	self.selectedPetBtn = nil
	self.boxPetNewListContainers = {}

	for i = 0, 23 do
		self.boxPetNewListContainers[i] = self.view.petListUWidget.transform:GetChild(i).transform:GetComponent("UContainer")
	end

	self.curBoxIndex = 1
	self.maxBoxIndex = #pg.me.petBoxMap
	self.boxInfos = PetManagementDataHelper.getBoxInfos()

	self.view.widget:TryChangePage("Selected", 0)
	self:refreshPetList(self.curBoxIndex)
end

function PetSelectPopupCtrl:refreshSearchedPetList(index)
	if math.floor(#self.searchedPetList / 24) == 0 then
		self.view.btnLeftUButton:SetActive(false)
		self.view.btnRightUButton:SetActive(false)
	elseif index <= 0 then
		self.view.btnLeftUButton:SetActive(false)
		self.view.btnRightUButton:SetActive(true)
	elseif index >= math.floor(#self.searchedPetList / 24) then
		self.view.btnLeftUButton:SetActive(true)
		self.view.btnRightUButton:SetActive(false)
	else
		self.view.btnLeftUButton:SetActive(true)
		self.view.btnRightUButton:SetActive(true)
	end

	for i = 0, #self.boxPetNewListContainers do
		local data = self.searchedPetList[i + 1 + index * 24]

		if not data or data.isEmpty then
			self.boxPetNewListContainers[i].url = AddressDataConst.PET_EMPTY_SLOT
		else
			self.boxPetNewListContainers[i].url = AddressDataConst.PET_NORMAL_SLOT
		end

		if data and not data.isEmpty then
			local uBtn = self.boxPetNewListContainers[i].content:GetComponent("UButton")
			local petData = PetManagementDataHelper.setUpPetInfo(data)

			self:setBoxPetListData(uBtn, i, petData)

			uBtn.dataFromUList = data
		else
			self:setEmptyButton(self.boxPetNewListContainers[i].content)
		end
	end
end

function PetSelectPopupCtrl:refreshPetList(index)
	self.selectedPetData = nil

	for idx, info in pairs(self.boxInfos) do
		info.selected = idx == index
	end

	self.view.widget:TryChangePage("ShowPetInfo", 0)
	self.view.widget:TryChangePage("Selected", 0)

	local boxId = pg.me.petBoxMap.sequence[index]
	local extraPetInfo = PetManagementDataHelper.getBoxInfoById(boxId)

	for i = 0, #self.boxPetNewListContainers do
		local data = extraPetInfo[i + 1]

		if not data or data.isEmpty then
			self.boxPetNewListContainers[i].url = AddressDataConst.PET_EMPTY_SLOT
		else
			self.boxPetNewListContainers[i].url = AddressDataConst.PET_NORMAL_SLOT
		end

		if data and not data.isEmpty then
			local uBtn = self.boxPetNewListContainers[i].content:GetComponent("UButton")

			self:setBoxPetListData(uBtn, i, data)

			uBtn.dataFromUList = data
		else
			self:setEmptyButton(self.boxPetNewListContainers[i].content)
		end
	end

	if self.boxInfos[index].customName and self.boxInfos[index].customName ~= "" then
		ClientTextUtils.setText(self.view.selectorNameUSDFText, self.boxInfos[index].customName)
	else
		ClientTextUtils.setText(self.view.selectorNameUSDFText, pg.getGameString("DEFAULT_PET_BOX_NAME") .. " " .. self.boxInfos[index].idx)
	end
end

function PetSelectPopupCtrl:setBoxPetListData(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtBoxUImage = objectReference:GetRefValue("txtBoxUImage")

	txtBoxUImage:SetActive(false)

	local battleNum = 0
	local inFightPetInfos = pg.global.ui.petManagement.model:getGroupInfoById(pg.global.ui.petManagement.model:getSelectGroupId())

	if #inFightPetInfos > 0 then
		for i, v in pairs(inFightPetInfos) do
			if v.id == data.id then
				battleNum = i

				break
			end
		end

		local battleNumUContainer = objectReference:GetRefValue("battleNumUContainer")

		if battleNum > 0 then
			if battleNumUContainer:CheckURLLoaded() then
				battleNumUContainer.content:TryChangePage("number", battleNum - 1)
			else
				battleNumUContainer:LoadDefaultUrlManually(function(widget)
					widget:TryChangePage("number", battleNum - 1)
				end)
			end
		else
			battleNumUContainer:DestroyContent()
		end
	end

	LuaUIUtils.renderPetHead(button, data)

	button.isSelected = false

	function button.luaClick()
		if self.selectedPetBtn then
			self.selectedPetBtn.isSelected = false
		end

		button.isSelected = true
		self.selectedPetBtn = button

		local petInfo = pg.me:getPetInfo(data.id)

		self.selectedPetData = PetManagementDataHelper.setUpPetInfo(petInfo)

		self.view.widget:TryChangePage("Selected", 1)

		if self.view.btnAllSelectedUButton.isSelected then
			self:showPetInfo()
		else
			self.view.widget:TryChangePage("ShowPetInfo", 0)
		end
	end
end

function PetSelectPopupCtrl:showPetInfo()
	if not self.selectedPetData then
		return
	end

	self.view.widget:TryChangePage("ShowPetInfo", 1)

	if not self.view.petDetailsUContainer:CheckURLLoaded() then
		self.view.petDetailsUContainer:LoadDefaultUrlManually(function()
			self.view.petDetailsUContainer.content:TryChangePage("BgState", 1)
			PetManagementUtils.initSimpleInfoTemplate(self.view.petDetailsUContainer.content, {
				defaultSelectTabIndex = 0,
				useLocalEnv = true,
				uiScene = self.uiScene,
				extraLogic = function()
					if PetManagementUtils.btnRenameUButton then
						PetManagementUtils.btnRenameUButton.gameObject:SetActiveEx(false)
					end

					if PetManagementUtils.btnFavoriteUButton then
						PetManagementUtils.btnFavoriteUButton.gameObject:SetActiveEx(false)
					end

					if PetManagementUtils.btnSkillPresetsUButton then
						PetManagementUtils.btnSkillPresetsUButton.gameObject:SetActiveEx(false)
					end

					if PetManagementUtils.btnPetManualUButton then
						PetManagementUtils.btnPetManualUButton.gameObject:SetActiveEx(false)
					end
				end
			})
			PetManagementUtils.showPetInfo(self.selectedPetData)
		end)
	else
		PetManagementUtils.showPetInfo(self.selectedPetData)
	end
end

function PetSelectPopupCtrl:setEmptyButton(button)
	button.isSelected = false

	function button.luaClick()
		if self.selectedPetBtn then
			self.selectedPetBtn.isSelected = false
		end

		button.isSelected = true
		self.selectedPetBtn = button
		self.selectedPetData = nil

		self.view.widget:TryChangePage("Selected", 0)
		self.view.widget:TryChangePage("ShowPetInfo", 0)
	end
end

function PetSelectPopupCtrl:onDestroy()
	self.selectedPetBtn = nil

	PetManagementUtils.destroyTemplate()
end

return PetSelectPopupCtrl
