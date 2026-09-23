-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmog\\PetTransmogView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetTransmogView = Class.LightClass("PetTransmogView", UIView)

function PetTransmogView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.title = objectReference:GetRefValue("title")
	self.btnBack = objectReference:GetRefValue("btnBack")
	self.btnInfo = objectReference:GetRefValue("btnInfo")
	self.currencyList = objectReference:GetRefValue("currencyList")
	self.planInfo = objectReference:GetRefValue("planInfo")
	self.holeList = objectReference:GetRefValue("holeList")
	self.btnGoon = objectReference:GetRefValue("btnGoon")

	if self.btnGoon then
		local consumeTransform = self.btnGoon.transform:Find("Btn/Consume")
		local iconTransform = consumeTransform and consumeTransform:Find("IconConsume")
		local numTransform = consumeTransform and consumeTransform:Find("TxtNum")

		self.imgCostItem = iconTransform and iconTransform:GetComponent("UImage")
		self.txtCostNum = numTransform and numTransform:GetComponent("USDFText")
	end

	self.btnPlanChange = objectReference:GetRefValue("btnPlanChange")
	self.slider = objectReference:GetRefValue("slider")
	self.stars = {}

	for i = 1, 5 do
		self.stars[i] = objectReference:GetRefValue("star" .. i)
	end

	self.btnSavePlan = objectReference:GetRefValue("btnSavePlan")
	self.schemeList = objectReference:GetRefValue("schemeList")
	self.planStarList = objectReference:GetRefValue("planStarList")
	self.btnDelPlan = objectReference:GetRefValue("btnDelPlan")
	self.btnComfilmPlan = objectReference:GetRefValue("btnComfilmPlan")
	self.txtPlanNum = objectReference:GetRefValue("txtPlanNum")
	self.btnComfirmPlanMain = objectReference:GetRefValue("btnComfirmPlanMain")
	self.btnHideUI = objectReference:GetRefValue("btnHideUI")
	self.txtBtnPlanChange = objectReference:GetRefValue("txtBtnPlanChange")
	self.txtBtnSavePlan = objectReference:GetRefValue("txtBtnSavePlan")
	self.txtbtnComfirmPlanMain = objectReference:GetRefValue("txtbtnComfirmPlanMain")
	self.txtbtnGoon = objectReference:GetRefValue("txtbtnGoon")
	self.txtpetName = objectReference:GetRefValue("txtpetName")
	self.txtBtnDelPlan = objectReference:GetRefValue("txtBtnDelPlan")
	self.txtBtnComfilmPlan = objectReference:GetRefValue("txtBtnComfilmPlan")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.txtnumAdd = objectReference:GetRefValue("txtnumAdd")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnPreview = objectReference:GetRefValue("btnPreview")
	self.btnVideo = objectReference:GetRefValue("btnVideo")
	self.textPlanInfoName = objectReference:GetRefValue("textPlanInfoName")
	self.tMPBeatUTextBeat = objectReference:GetRefValue("tMPBeatUTextBeat")
	self.planPanelUComponent = objectReference:GetRefValue("planPanelUComponent")
	self.txtNameView = objectReference:GetRefValue("txtNameView")
	self.txtNameDef = objectReference:GetRefValue("txtNameDef")
	self.txtNameNow = objectReference:GetRefValue("txtNameNow")
	self.txtCashUSDFText = objectReference:GetRefValue("txtCashUSDFText")
	self.btnCheck = objectReference:GetRefValue("btnCheck")
	self.txtBtnCheck = objectReference:GetRefValue("txtBtnCheck")
end

function PetTransmogView:registerObjects()
	return
end

function PetTransmogView:initView()
	ClientTextUtils.setText(self.title, pg.getGameString("PETTRANSMOGRIFY_TITLE"))
	ClientTextUtils.setText(self.txtBtnPlanChange, pg.getGameString("PETTRANSMOGRIFY_SCHEME"))
	ClientTextUtils.setText(self.txtBtnSavePlan, pg.getGameString("PETTRANSMOGRIFY_TEMP"))
	ClientTextUtils.setText(self.txtbtnComfirmPlanMain, pg.getGameString("PETTRANSMOGRIFY_SAVE_CUSTOM"))
	ClientTextUtils.setText(self.txtbtnGoon, pg.getGameString("PETTRANSMOGRIFY_BUTTON"))
	ClientTextUtils.setText(self.txtBtnDelPlan, pg.getGameString("PETTRANSMOGRIFY_DELETE"))
	ClientTextUtils.setText(self.txtBtnComfilmPlan, pg.getGameString("PETTRANSMOGRIFY_APPLY"))
	ClientTextUtils.setText(self.txtNameView, pg.getGameString("PETTRANSMOGRIFY_PREVIEW_ONLY"))
	ClientTextUtils.setText(self.txtNameDef, pg.getGameString("PETTRANSMOGRIFY_DEFAULT_FIXED"))
	ClientTextUtils.setText(self.txtNameNow, pg.getGameString("PETTRANSMOGRIFY_APPLICATION"))
end

return PetTransmogView
