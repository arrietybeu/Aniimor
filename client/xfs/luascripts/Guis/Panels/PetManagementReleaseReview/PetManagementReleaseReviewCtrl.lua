-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagementReleaseReview\\PetManagementReleaseReviewCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local SysConfigData = require("Data.sys_config_data")
local PetManagementReleaseReviewCtrl = Class.LightClass("PetManagementReleaseReviewCtrl", UICtrl)

PetManagementReleaseReviewCtrl.BATCH_RENDER_PER_FRAME = 10
PetManagementReleaseReviewCtrl.messages = {}

function PetManagementReleaseReviewCtrl:getManagedBlurEffect()
	return self.view and self.view.bgBlurUIBlurEffect
end

function PetManagementReleaseReviewCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initializeManagedBlur()

	self.releasePetIds = info.releasePetIds or {}
	self.petInfos = self.model:getPetInfos(self.releasePetIds)

	local firstPetInfo = self.petInfos[1]

	self.selectedPetId = firstPetInfo and firstPetInfo.id

	self:_refreshPetListByFrame()
	PetManagementUtils.initSimpleInfoTemplate(self.view.petInfoPanelUComponent, {
		noNeedTabIndex = true,
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
	self:setSelectedPetInfo(firstPetInfo)
	self:refreshRecycleRewards()
	PetManagementUtils.renderReleaseTips(self.petInfos, self.view.widgetTipsUWidget, self.view.txtTipsUSDFText, "#FDDA0D")

	self.closeCb = info.closeCb
end

function PetManagementReleaseReviewCtrl:_refreshPetListByFrame()
	self:_killFramedRenderTimer()

	local petInfos = self.petInfos or {}
	local total = #petInfos
	local batch = self.BATCH_RENDER_PER_FRAME

	if total <= batch then
		self.view.listPetUList:SetList(petInfos)

		return
	end

	local firstBatch = {}

	for i = 1, batch do
		firstBatch[i] = petInfos[i]
	end

	self.view.listPetUList:SetList(firstBatch)

	local nextIndex = batch + 1

	self._framedRenderTimer = self:startTimer(function()
		local endIndex = math.min(nextIndex + batch - 1, total)

		for i = nextIndex, endIndex do
			self.view.listPetUList:AddElement(petInfos[i])
		end

		nextIndex = endIndex + 1

		if nextIndex > total then
			self:_killFramedRenderTimer()
		end
	end, 0, true)
end

function PetManagementReleaseReviewCtrl:_killFramedRenderTimer()
	if self._framedRenderTimer then
		self:killTimer(self._framedRenderTimer)

		self._framedRenderTimer = nil
	end
end

function PetManagementReleaseReviewCtrl:closePanel()
	PetManagementUtils.destroyTemplate()

	if self.closeCb then
		self.closeCb(self.releasePetIds)
	end

	pg.global.ui:close(UIConst.UI_ID_PET_MANAGEMENT_RELEASE_REVIEW)
end

function PetManagementReleaseReviewCtrl:setSelectedPetInfo(petInfo)
	self.selectedPetId = petInfo and petInfo.id

	PetManagementUtils.showPetInfo(petInfo or {
		empty = true
	})
end

function PetManagementReleaseReviewCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	function self.view.listPetUList.luaRenderItem(button, index, data)
		self:renderPetList(button, index, data)
	end
end

function PetManagementReleaseReviewCtrl:renderPetList(button, index, data)
	button.enabledTooltip = false
	button.draggable = false

	LuaUIUtils.renderPetHead(button, data, {
		forceHideEvo = true
	})

	local objectReference = button:GetComponent("ObjectReference")
	local panelCPUContainer = objectReference:GetRefValue("panelCPUContainer")
	local panelCharListUContainer = objectReference:GetRefValue("panelCharListUContainer")
	local txtBoxUImage = objectReference:GetRefValue("txtBoxUImage")
	local petQualityUContainer = objectReference:GetRefValue("petQualityUContainer")
	local petRareUContainer = objectReference:GetRefValue("petRareUContainer")
	local btnDelUContainer = objectReference:GetRefValue("btnDelUContainer")
	local petRareNmlUContainer = objectReference:GetRefValue("petRareNmlUContainer")

	button.isSelected = self.selectedPetId == data.id
	panelCPUContainer.renderOpacity = 1
	panelCharListUContainer.renderOpacity = 1
	txtBoxUImage.renderOpacity = 0

	petQualityUContainer:DestroyContent()
	petRareUContainer:DestroyContent()
	petRareNmlUContainer:DestroyContent()
	btnDelUContainer.gameObject:SetActiveEx(true)
	btnDelUContainer:LoadDefaultUrlManually()

	function btnDelUContainer.content.luaClick()
		local needReselect = self.selectedPetId == data.id

		self.releasePetIds[data.id] = nil
		self.petInfos = self.model:getPetInfos(self.releasePetIds)

		if needReselect then
			self:setSelectedPetInfo(self.petInfos[1])
		end

		self:_refreshPetListByFrame()
		self:refreshRecycleRewards()
		PetManagementUtils.renderReleaseTips(self.petInfos, self.view.widgetTipsUWidget, self.view.txtTipsUSDFText, "#FDDA0D")
	end

	btnDelUContainer.content:SetGamepadAction("Raw/GamepadButtonWest", nil, function()
		btnDelUContainer.content:OnClickSimulate()
	end)
	btnDelUContainer.content:SetHotkeyActiveOnlyInCurrentItem(true)
	btnDelUContainer.content:SetHotkeyConsoleBar("CONSOLE_BAR_REMOVE", -1)

	function button.luaPress()
		self:deSelectAllBtn()
		self:setSelectedPetInfo(data)

		button.isSelected = true
	end
end

function PetManagementReleaseReviewCtrl:onDestroy()
	self:_killFramedRenderTimer()
	UICtrl.onDestroy(self)
end

function PetManagementReleaseReviewCtrl:deSelectAllBtn()
	local btns = self.view.listPetUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i]:TryChangePage("button", 0)

		btns[i].isSelected = false
	end
end

function PetManagementReleaseReviewCtrl:refreshRecycleRewards()
	local petList = {}

	for petId, _ in pairs(self.releasePetIds) do
		petList[#petList + 1] = petId
	end

	local recycleBack = ItemUtils.getBatchRecyclePetClientDisplayItem(pg.me, petList)

	function self.view.listRewardUList.luaRenderItem(button, _, data)
		LuaUIUtils.renderRewardItem(button, data)
	end

	self.recycleBackInfo = self.model:parsePropData(recycleBack)

	self.view.listRewardUList:SetList(self.recycleBackInfo)
end

return PetManagementReleaseReviewCtrl
