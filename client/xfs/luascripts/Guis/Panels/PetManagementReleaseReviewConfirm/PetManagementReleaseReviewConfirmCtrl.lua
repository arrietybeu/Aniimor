-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagementReleaseReviewConfirm\\PetManagementReleaseReviewConfirmCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local AddressDataConst = require("Const.AddressDataConst")
local PetManagementUtils = require("Utils.PetManagementUtils")
local SysConfigData = require("Data.sys_config_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local NAV_LISTENER_KEY = "PetManagementReleaseReviewConfirm"
local CONSOLE_BAR_STATE_CAN_MOVE = "PetRelease_Confirm_CanMove"
local CONSOLE_BAR_STATE_CAN_SELECT = "PetRelease_Confirm_CanSelect"
local PetManagementReleaseReviewConfirmCtrl = Class.LightClass("PetManagementReleaseReviewConfirmCtrl", UICtrl)

PetManagementReleaseReviewConfirmCtrl.messages = {}

function PetManagementReleaseReviewConfirmCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.releasePetIds = info.releasePetIds or {}
	self.petInfos = self.model:getPetInfos(self.releasePetIds)
	self.ensureCb = info.ensureCb

	ClientTextUtils.setText(self.view.txtTipsWarnUSDFText, pg.getGameString("PET_RELEASE_TIP_IMPORT_USEITEM"))
	ClientTextUtils.setText(self.view.txtNumUSDFText, #self.petInfos)
	self:refreshRecycleRewards()

	self.tips = PetManagementUtils.renderReleaseTips(self.petInfos, self.view.tipsUWidget, self.view.txtTipsUSDFText, info.richTextColor, true)

	self:_startFramedRenderPetList()
end

PetManagementReleaseReviewConfirmCtrl.BATCH_RENDER_PER_FRAME = 5

function PetManagementReleaseReviewConfirmCtrl:_startFramedRenderPetList()
	self:_killFramedRenderTimer()

	local total = #self.petInfos
	local batch = self.BATCH_RENDER_PER_FRAME
	local firstCount = math.min(batch, total)
	local firstBatch = {}

	for i = 1, firstCount do
		firstBatch[i] = self.petInfos[i]
	end

	self.view.listPetUList:SetList(firstBatch)

	if total <= firstCount then
		return
	end

	local nextIndex = firstCount + 1

	self._framedRenderTimer = self:startTimer(function()
		local endIndex = math.min(nextIndex + batch - 1, total)

		for i = nextIndex, endIndex do
			self.view.listPetUList:AddElement(self.petInfos[i])
		end

		nextIndex = endIndex + 1

		if nextIndex > total then
			self:_killFramedRenderTimer()
		end
	end, 0, true)
end

function PetManagementReleaseReviewConfirmCtrl:_killFramedRenderTimer()
	if self._framedRenderTimer then
		self:killTimer(self._framedRenderTimer)

		self._framedRenderTimer = nil
	end
end

function PetManagementReleaseReviewConfirmCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_PET_MANAGEMENT_RELEASE_REVIEW_CONFIRM)
end

function PetManagementReleaseReviewConfirmCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnCancelUButton.luaClick()
		self:closePanel()
	end

	function self.view.listPetUList.luaRenderItem(button, index, data)
		self:renderPetList(button, index, data)
	end

	function self.view.btnConfirmUButton.luaClick()
		if self.ensureCb then
			local tempTips = PetManagementUtils.renderReleaseTips(self.petInfos, self.view.tipsUWidget, self.view.txtTipsUSDFText, nil, true)

			self.ensureCb(tempTips)
		end

		self:closePanel()
	end

	self:_bindLeftListGamepadScroll(self.view.listPetUList)

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener(NAV_LISTENER_KEY, function()
			self:refreshConsoleBarState()
		end)
	end
end

function PetManagementReleaseReviewConfirmCtrl:_bindLeftListGamepadScroll(uList)
	if uList == nil then
		return
	end

	local scrollSpeed = 150
	local bind = KeyBindingPro.GetOrAddKeyBindingByName(uList.gameObject, "listScrollGamepadBind")

	bind.actionPath = "Hud/ScrollGamepad"
	bind.isVirtual = true
	bind.priority = -1

	function bind.luaTrigger(inputInfo)
		self.ScrollGamepadDelta = inputInfo.valueVec2 * scrollSpeed
		self.ScrollGamepadDelta.x = 0

		if inputInfo.phase == "Performed" then
			if self.ScrollGamepadTimer == nil then
				self.ScrollGamepadTimer = self:startTimer(function()
					if pg.global.navMgr and pg.global.navMgr:IsInModalGroup() then
						return
					end

					local targetPos = uList.currentScrollPosition - self.ScrollGamepadDelta

					uList:GoToPos(targetPos, false)
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" and self.ScrollGamepadTimer then
			self:killTimer(self.ScrollGamepadTimer)

			self.ScrollGamepadTimer = nil
		end
	end
end

function PetManagementReleaseReviewConfirmCtrl:refreshConsoleBarState()
	if not pg.global.navMgr then
		return
	end

	local inModal = pg.global.navMgr:IsInModalGroup()

	pg.global.navMgr:SetConsoleBarState(CONSOLE_BAR_STATE_CAN_MOVE, not inModal)
	pg.global.navMgr:SetConsoleBarState(CONSOLE_BAR_STATE_CAN_SELECT, inModal)
end

function PetManagementReleaseReviewConfirmCtrl:onDestroy()
	self:_killFramedRenderTimer()

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener(NAV_LISTENER_KEY)
	end

	UICtrl.onDestroy(self)
end

function PetManagementReleaseReviewConfirmCtrl:renderPetList(button, index, data)
	button.enabledTooltip = false
	button.draggable = false
	button.interactable = false
	button.visualInteractable = false

	LuaUIUtils.renderPetHead(button, data)
	button:TryChangePage("isBoss", 0)

	local objectReference = button:GetComponent("ObjectReference")
	local panelCPUContainer = objectReference:GetRefValue("panelCPUContainer")
	local panelCharListUContainer = objectReference:GetRefValue("panelCharListUContainer")
	local txtBoxUImage = objectReference:GetRefValue("txtBoxUImage")
	local petQualityUContainer = objectReference:GetRefValue("petQualityUContainer")
	local petRareUContainer = objectReference:GetRefValue("petRareUContainer")
	local iconHomeUImage = objectReference:GetRefValue("iconHomeUImage")
	local petRareNmlUContainer = objectReference:GetRefValue("petRareNmlUContainer")

	panelCPUContainer.renderOpacity = 1
	panelCharListUContainer.renderOpacity = 1
	txtBoxUImage.renderOpacity = 0

	petQualityUContainer:DestroyContent()
	petRareUContainer:DestroyContent()
	petRareNmlUContainer:DestroyContent()

	if data.rating >= 2 and not data.isCatchReportingStatus then
		iconHomeUImage.gameObject:SetActiveEx(true)

		iconHomeUImage.url = AddressDataConst["PET_RATING_ICON_" .. data.rating]
	else
		iconHomeUImage.gameObject:SetActiveEx(false)
	end
end

function PetManagementReleaseReviewConfirmCtrl:refreshRecycleRewards()
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

return PetManagementReleaseReviewConfirmCtrl
