-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TargetElementPopup\\TargetElementPopupCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ElementPropData = require("Data.element_prop_data")
local ElementNameToId = require("Data.element_name_to_id")
local ElementAgainstData = require("Data.real_element_against")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local lume = require("Core.Common.lume")
local TargetElementPopupCtrl = Class.LightClass("TargetElementPopupCtrl", UICtrl)

function TargetElementPopupCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	function self.view.listElementUList.luaRenderItem(button, index, data)
		if data.elementName then
			LuaUIUtils.setElementButtonNew(button, data.elementName)
		end
	end

	function self.view.listCommendUList.luaRenderItem(nodeBtn, nodeIdx, nodeData)
		local objectReference = nodeBtn:GetComponent("ObjectReference")
		local listElementUList = objectReference:GetRefValue("listElementUList")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		nodeBtn:TryChangePage("State", nodeData.index)

		function listElementUList.luaRenderItem(button, index, data)
			self:renderTipElement(button, data.elementName)
		end

		local isEmptyList = not ToBool(nodeData.elements)

		nodeBtn:TryChangePage("Empty", isEmptyList and 1 or 0)
		listElementUList:SetList(nodeData.elements)
	end

	self.elementAgainstCnt = {}
	self.recommendElementInfo = {
		{
			index = 0,
			elements = {}
		},
		{
			index = 3,
			elements = {}
		},
		{
			index = 1,
			elements = {}
		},
		{
			index = 4,
			elements = {}
		},
		{
			index = 2,
			elements = {}
		}
	}
end

function TargetElementPopupCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local targetEnt = info and info.targetActorId and pg.getEntityByActorId(info.targetActorId)

	if not targetEnt then
		self:dismiss()

		return
	end

	ClientTextUtils.setText(self.view.txtLvUSDFText, targetEnt.level or 0)
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getLocalizationText(targetEnt:getName()))

	local cfgData = targetEnt:getConfigData()

	if cfgData then
		local iconUrl = LuaUIUtils.getPetIcon(cfgData.iconName, LuaUIUtils.PET_ICON, targetEnt.label)

		self.view.petHeadIcon.url = iconUrl
	end

	self.view.listElementUList:SetList(LuaUIUtils.getTargetElementsInfos(targetEnt.elementTypes))
	self:prepareRecommendElementInfo(targetEnt.elementTypes)
	self.view.listCommendUList:SetList(self.recommendElementInfo)
end

function TargetElementPopupCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end
end

function TargetElementPopupCtrl:prepareRecommendElementInfo(defenceElements)
	if defenceElements == nil then
		return nil
	end

	lume.clear(self.elementAgainstCnt)

	for testElement, _ in pairs(ElementAgainstData) do
		self.elementAgainstCnt[testElement] = 0
	end

	for targetType, _ in pairs(defenceElements) do
		for testElement, data in pairs(ElementAgainstData) do
			if data[targetType] and data[targetType] > 1 then
				self.elementAgainstCnt[testElement] = self.elementAgainstCnt[testElement] + 1
			end

			if data[targetType] and data[targetType] < 1 then
				self.elementAgainstCnt[testElement] = self.elementAgainstCnt[testElement] - 1
			end
		end
	end

	lume.clear(self.recommendElementInfo[1].elements)
	lume.clear(self.recommendElementInfo[2].elements)
	lume.clear(self.recommendElementInfo[3].elements)
	lume.clear(self.recommendElementInfo[4].elements)
	lume.clear(self.recommendElementInfo[5].elements)

	for testElement, cnt in pairs(self.elementAgainstCnt) do
		if cnt == 0 then
			table.insert(self.recommendElementInfo[5].elements, {
				elementName = testElement
			})
		elseif cnt == 1 then
			table.insert(self.recommendElementInfo[3].elements, {
				elementName = testElement
			})
		elseif cnt == 2 then
			table.insert(self.recommendElementInfo[1].elements, {
				elementName = testElement
			})
		elseif cnt == -1 then
			table.insert(self.recommendElementInfo[2].elements, {
				elementName = testElement
			})
		elseif cnt == -2 then
			table.insert(self.recommendElementInfo[4].elements, {
				elementName = testElement
			})
		end
	end
end

function TargetElementPopupCtrl:renderTipElement(button, elementName)
	button.enabledTooltip = true
	button.tooltipMode = 1

	LuaUIUtils.setElementButtonNew(button, elementName, false)
	button:SetHorizontalAlignment(CS.XGUI.EHorizontalAlignment.Center)

	function button.luaRenderTooltip(btn, cmp)
		local objectReference = cmp:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local txtContentUSDFText = objectReference:GetRefValue("txtContentUSDFText")
		local elementUButton = objectReference:GetRefValue("elementUButton")

		cmp:TryChangePage("Type", 1)
		LuaUIUtils.setElementButtonNew(elementUButton, elementName, false)

		local nameCh = ElementPropData[elementName] and ElementPropData[elementName].name_ch

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(nameCh))

		if not ElementPropData[elementName] then
			ClientTextUtils.setText(txtContentUSDFText, "EMPTY")
		elseif ElementPropData[elementName].desc then
			ClientTextUtils.setText(txtContentUSDFText, pg.getLocalizationText(ElementPropData[elementName].desc))
		else
			ClientTextUtils.setText(txtContentUSDFText, "EMPTY")
		end
	end
end

return TargetElementPopupCtrl
