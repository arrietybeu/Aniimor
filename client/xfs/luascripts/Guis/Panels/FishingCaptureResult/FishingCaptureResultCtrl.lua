-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureResult\\FishingCaptureResultCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local EXIT_REQUEST_RETRY_TIMEOUT = 5
local FishingCaptureResultCtrl = Class.LightClass("FishingCaptureResultCtrl", UICtrl)

FishingCaptureResultCtrl.messages = {
	[MessageName.UI_ON_SHOW] = {
		"onUIShow",
		true
	}
}

function FishingCaptureResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function FishingCaptureResultCtrl:addListener()
	function self.view.btnBackCloseUButton.luaClick()
		self:onConfirmClick()
	end

	function self.view.listTagUList.luaRenderItem(button, idx, data)
		LuaUIUtils.renderPetTagList(button, data)
		LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(self.petInfo.templateId, self.petInfo.label, self.petInfo.bodySizeType, self.petInfo.shinyStyle))
	end
end

function FishingCaptureResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:_resetExitPending()
	pg.game.audio:playEvent(FishingCaptureConst.SFX_CAPTURE_SUCCESS)
	self.model:loadSettlementData(info, function(data)
		if data then
			self:_refresh()
		end
	end)
end

function FishingCaptureResultCtrl:_refresh()
	local data = self.model:getSettlementData()

	if not data then
		return
	end

	local petId = data.petId
	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		return
	end

	self.petInfo = petInfo

	local bossTemplateId = petInfo.templateId
	local pData = PetData[bossTemplateId]

	ClientTextUtils.setText(self.view.textPetNameUBaseText, pg.getLocalizationText(LuaUIUtils.getPetName(petId)))

	local petType = pData.functionId

	petInfo.petType = petType
	petInfo.petTypeUrl = PetConfigData.petFunctionIcon[petType]
	self.view.petTypeIcon.url = petInfo.petTypeUrl

	local petFunctionKey = UIConst.PET_FUNCTION_TEXT_MAP[petInfo.petType]
	local petFunctionName = petFunctionKey and PetConfigData[petFunctionKey]

	ClientTextUtils.setText(self.view.petTypeName, pg.getLocalizationText(petFunctionName))

	local _, names = LuaUIUtils.getElementInfo(pData.elementType)
	local temp = {}

	for _, info in ipairs(names) do
		temp[#temp + 1] = info.element
	end

	LuaUIUtils.renderPetElement(self.view.listElementUList, temp)

	local tagDatas = LuaUIUtils.getPetTagList(petInfo)
	local ret = {}

	for idx = 1, #tagDatas do
		ret[#ret + 1] = {
			tagDatas[idx]
		}
	end

	self.view.listTagUList:SetList(ret)

	local realStage = 3

	if petInfo.stage then
		realStage = petInfo.stage - 1
	end

	self.view.widget:TryChangePage("Gender", self.petInfo.gender)
	self.view.widget:TryChangePage("Quality", petInfo.propertyScoreStage)
	self.view.widget:TryChangePage("TimeQuality", realStage)
	ClientTextUtils.setText(self.view.stageTxt, pg.getGameString("PET_STAGE_TXT_4"))
	ClientTextUtils.setText(self.view.tipsUBaseText, pg.getGameString("FC_CAPTURE_SUCCESS_SUB_TITLE"))
end

function FishingCaptureResultCtrl:onConfirmClick()
	if self.exitRequestPending then
		return
	end

	if not self.waitingExitLoading then
		local sceneAdapter = pg.global.scene

		self.exitSourceSceneId = sceneAdapter and sceneAdapter.curScene and sceneAdapter.curScene.sceneId or nil
		self.waitingExitLoading = true
	end

	self.exitRequestPending = true
	self.view.btnBackCloseUButton.interactable = false
	self.exitRequestRetryTimer = self:startTimer(function()
		self.exitRequestRetryTimer = nil

		self:_resetExitRequestPending()
	end, EXIT_REQUEST_RETRY_TIMEOUT)

	local widget = self.view.widget

	if NotNil(widget) and widget:CheckHasEvent(CS.XGUI.EInvokeTime.User1) then
		widget:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.User1, function()
			self:_requestExit()
		end)
	else
		self:_requestExit()
	end
end

function FishingCaptureResultCtrl:_requestExit()
	if not self.exitRequestPending then
		return
	end

	if pg.me and pg.me.onResultClose then
		pg.me:onResultClose()
	else
		self:_resetExitPending()
	end
end

function FishingCaptureResultCtrl:onUIShow(uid)
	if not self.waitingExitLoading then
		return
	end

	local sceneAdapter = pg.global.scene
	local targetSceneId = sceneAdapter and sceneAdapter.targetSceneId or nil

	if not sceneAdapter or uid ~= sceneAdapter.curLoadingPanelId or not targetSceneId or targetSceneId == self.exitSourceSceneId then
		return
	end

	if pg.me and pg.me.onResultLoadingShown then
		pg.me:onResultLoadingShown()
	end

	self:_resetExitPending()
	self:dismiss()
end

function FishingCaptureResultCtrl:_resetExitRequestPending()
	if self.exitRequestRetryTimer then
		self:killTimer(self.exitRequestRetryTimer)

		self.exitRequestRetryTimer = nil
	end

	self.exitRequestPending = false

	if self.view and self.view.btnBackCloseUButton then
		self.view.btnBackCloseUButton.interactable = true
	end
end

function FishingCaptureResultCtrl:_resetExitPending()
	self:_resetExitRequestPending()

	self.waitingExitLoading = false
	self.exitSourceSceneId = nil
end

function FishingCaptureResultCtrl:onDestroy()
	if self.waitingExitLoading and pg.me and pg.me.onResultLoadingShown then
		pg.me:onResultLoadingShown()
	end

	self:_resetExitPending()
	UICtrl.onDestroy(self)
end

return FishingCaptureResultCtrl
