-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonPetTip\\CommonPetTipCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("CommonPetTipCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CommonPetTipCtrl = Class.LightClass("CommonPetTipCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")

CommonPetTipCtrl.messages = {}

function CommonPetTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CommonPetTipCtrl:addListener()
	LuaUIUtils.bindHotKey(self.view.transform.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadB, function()
		self:close()
	end)
	LuaUIUtils.bindHotKey(self.view.transform.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRS, function()
		self:close()
	end)

	function self.view.rootCmp.luaCloseAction()
		if self.iData.extra and self.iData.extra.closeFun then
			self.iData.extra.closeFun()
		end

		self:close()
	end

	function self.view.rootCmp.luaSetScale()
		local scale = Vector3.one * (self.iData.scale or 1)

		self.view.transform.localScale = scale
	end
end

function CommonPetTipCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function CommonPetTipCtrl:checkCanOpen(showNotice, data)
	if data == nil or data.templateId == nil then
		return false
	end

	self.iData = data

	return true
end

function CommonPetTipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshView()
end

function CommonPetTipCtrl:onShow()
	return
end

function CommonPetTipCtrl:refreshView()
	if self.iData == nil then
		return
	end

	self:renderPetView(self.iData)

	local autoVer = self.iData.autoVer or false
	local autoHor = self.iData.autoHor or false

	self.view.rootCmp:SetAutoVertical(autoVer, autoHor)

	if self.iData.autoClose ~= nil then
		self.view.rootCmp:SetAutoClose(self.iData.autoClose)
	end

	if self.iData.checkTouchBegin ~= nil then
		self.view.rootCmp:SetCheckTouchState(self.iData.checkTouchBegin)
	end

	if self.iData.rayCastParent then
		self.view.rootCmp:AddRayOcclusionMask(self.iData.rayCastParent, self.iData.addSibling or 0)
	end

	if self.iData.fixedHeight then
		local oc = self.view.transform:GetComponent("ObjectReference")
		local scrollRect = oc:GetRefValue("scrollInfo")

		self.view.rootCmp:SetFixedHeight(scrollRect, self.iData.fixedHeight)
	end

	if self.iData.padding ~= nil then
		self.view.rootCmp:SetPadding(self.iData.padding)
	end

	if self.iData.hierarchyMode ~= nil then
		self.view.rootCmp:SetHierarchy(self.iData.hierarchyMode, self.iData.sortingOrder or 1)
	end

	self.view.rootCmp:SetSingleDisplay(self.iData.singleDisplay or false)
	self.view.rootCmp:SetValidateTouchFunc(function(pos)
		return not pg.game.guide:isInFocusGuide()
	end)

	if self.iData.targetRect then
		self.view.rootCmp:OpenPopup(self.iData.targetRect)
	end
end

local ClientTextUtils = require("Utils.ClientTextUtils")
local PetResearchContentData = require("Data.pet_research_content_data")
local PetConfigData = require("Data.pet_config_data")
local PetData = require("Data.pet_data")

function CommonPetTipCtrl:renderPetView(data)
	self.view.rootCmp:TryChangePage("Type", 0)

	local templateId = data.templateId
	local petType = PetData[templateId].functionId

	ClientTextUtils.setText(self.view.txtOrientationUSDFText, pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petType)]) or "")
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getLocalizationText(PetData[templateId].name))
	ClientTextUtils.setText(self.view.txtContentUSDFText, PetResearchContentData[templateId] ~= nil and pg.getLocalizationText(PetResearchContentData[templateId].desc) or "EMPTY")

	self.view.iconPetUImage.url = LuaUIUtils.getPetIcon(PetData[templateId].iconName, LuaUIUtils.PET_ICON)

	local _, elementNames = LuaUIUtils.getElementInfo(PetData[templateId].elementType)

	function self.view.listTagUList.luaRenderItem(button1, _, data1)
		LuaUIUtils.setElementButtonNew(button1, data1.element)
	end

	self.view.listTagUList:SetList(elementNames)
end

function CommonPetTipCtrl:onHide()
	return
end

return CommonPetTipCtrl
