-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\RestraintUIComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local RestraintUIComponent = Class.LightClass("RestraintUIComponent", UIComponent)
local ElementAgainstData = require("Data.element_against_data")
local ElementPropData = require("Data.element_prop_data")
local Lume = require("Core.Common.lume")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local UIUtils = UIUtils

function RestraintUIComponent:findObjects()
	self.container = self.transform:GetComponent("UContainer")
end

function RestraintUIComponent:registerObjectInner()
	self.objectReference = self.container.content:GetComponent("ObjectReference")
	self.listStateUList = self.objectReference:GetRefValue("listStateUList")
	self.verticallListUList = self.objectReference:GetRefValue("verticallListUList")
	self.horizontalListUList = self.objectReference:GetRefValue("horizontalListUList")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnLeftUButton = self.objectReference:GetRefValue("btnLeftUButton")
	self.elementAgainstUButton = self.objectReference:GetRefValue("elementAgainstUButton")
	self.spaceRelationUButton = self.objectReference:GetRefValue("spaceRelationUButton")
	self.topAllElementsUList = self.objectReference:GetRefValue("topAllElementsUList")
	self.btnRightUButton = self.objectReference:GetRefValue("btnRightUButton")
	self.attackUWidget = self.objectReference:GetRefValue("attackUWidget")
	self.defendUWidget = self.objectReference:GetRefValue("defendUWidget")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.remoteUButton = self.objectReference:GetRefValue("remoteUButton")
	self.boringUButton = self.objectReference:GetRefValue("boringUButton")
	self.flightUButton = self.objectReference:GetRefValue("flightUButton")
	self.earthquakeUButton = self.objectReference:GetRefValue("earthquakeUButton")
	self.bgBlurUIBlurEffect = self.objectReference:GetRefValue("bgBlurUIBlurEffect")
	self.attackComponentObjRef = self.attackUWidget:GetComponent("ObjectReference")
	self.attackAdvantageElementsUList = self.attackComponentObjRef:GetRefValue("attackAdvantageElementsUList")
	self.attackDisadvantageElementsUList = self.attackComponentObjRef:GetRefValue("attackDisadvantageElementsUList")
	self.attackElementUButton = self.attackComponentObjRef:GetRefValue("elementUButton")
	self.defendComponentObjRef = self.defendUWidget:GetComponent("ObjectReference")
	self.defendAdvantageElementsUList = self.defendComponentObjRef:GetRefValue("defendAdvantageElementsUList")
	self.defendDisadvantageElementsUList = self.defendComponentObjRef:GetRefValue("defendDisadvantageElementsUList")
	self.defendElementUButton = self.defendComponentObjRef:GetRefValue("elementUButton")

	local function renderElementBtnFunc(button, index, data)
		button:TryChangePage("type", data.elementName)
	end

	function self.listStateUList.luaRenderItem(button, index, data)
		button:TryChangePage("state", data.state)
		button:TryChangePage("BgState", data.bgState)
	end

	self.horizontalListUList.luaRenderItem = renderElementBtnFunc
	self.verticallListUList.luaRenderItem = renderElementBtnFunc

	function self.topAllElementsUList.luaRenderItem(button, index, data)
		button:TryChangePage("type", data.elementName)

		function button.luaClick()
			self:refreshFocusedElementRelationPanel(data.elementName)
		end
	end

	self.attackAdvantageElementsUList.luaRenderItem = renderElementBtnFunc
	self.attackDisadvantageElementsUList.luaRenderItem = renderElementBtnFunc
	self.defendAdvantageElementsUList.luaRenderItem = renderElementBtnFunc
	self.defendDisadvantageElementsUList.luaRenderItem = renderElementBtnFunc

	function self.btnCloseUButton.luaClick()
		self:hide()
	end

	function self.btnLeftUButton.luaClick()
		self.rootUComponent:TryChangePage("State", 0)
	end

	function self.btnRightUButton.luaClick()
		self.rootUComponent:TryChangePage("State", 1)
	end

	function self.remoteUButton.luaRenderTooltip(button, toolTip)
		self:renderBtnToolTip(toolTip, ClientTextUtils.getGameStringTitle("HELP_RANGED"), pg.getGameString("HELP_RANGED"))
	end

	function self.boringUButton.luaRenderTooltip(button, toolTip)
		self:renderBtnToolTip(toolTip, ClientTextUtils.getGameStringTitle("HELP_BURROW"), pg.getGameString("HELP_BURROW"))
	end

	function self.flightUButton.luaRenderTooltip(button, toolTip)
		self:renderBtnToolTip(toolTip, ClientTextUtils.getGameStringTitle("HELP_FLY"), pg.getGameString("HELP_FLY"))
	end

	function self.earthquakeUButton.luaRenderTooltip(button, toolTip)
		self:renderBtnToolTip(toolTip, ClientTextUtils.getGameStringTitle("HELP_EARTHQUAKE"), pg.getGameString("HELP_EARTHQUAKE"))
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.btnCloseUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:hide()
		end
	end

	self.atkAdvantageList = {}
	self.atkDisadvantageList = {}
	self.defAdvantageList = {}
	self.defDisadvantageList = {}

	self.ctrl:addNavFocusListener(CallbackHandler(self, "refreshConsoleBarState"), "Restraint_SpatialConstraint")
end

function RestraintUIComponent:refreshConsoleBarState()
	if pg.global.navMgr then
		local inSpatialConstraint = pg.global.navMgr.CurrentFocusedGroupName == "SpatialConstraint"

		pg.global.navMgr:SetConsoleBarState("ElementForm_InSpatialConstraint", inSpatialConstraint)
	end
end

function RestraintUIComponent:initView()
	if self.uWidget then
		self.uWidget:SetActive(true)
	end

	self:hide()
end

function RestraintUIComponent:refreshComponentVisible()
	if self.bgBlurUIBlurEffect then
		self.bgBlurUIBlurEffect.enabled = self._visible
	end

	if self._visible then
		self.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	else
		self.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end
end

function RestraintUIComponent:onHide()
	self.ctrl:componentSetIsModel("restraint", false)

	self.rootUComponent.keepAnimWhenHide = true

	LuaUIUtils.setUIVisible(self.rootUComponent, false)
end

function RestraintUIComponent:onShow()
	self.ctrl:componentSetIsModel("restraint", true)
end

function RestraintUIComponent:showRestraint(elementName, cb)
	if not self.container:CheckURLLoaded() then
		self.container:LoadDefaultUrlManually(function()
			self:registerObjectInner()
			self:initAllElementRelationPanel()
			self:showRestraintInternal(elementName, cb)
		end)
	else
		self:showRestraintInternal(elementName, cb)
	end
end

function RestraintUIComponent:showRestraintInternal(elementName, cb)
	if elementName and self.showOrder then
		for idx, data in ipairs(self.showOrder) do
			if data.elementName == elementName then
				self.topAllElementsUList:SelectItem(idx - 1)

				break
			end
		end
	else
		self.topAllElementsUList:SelectItem(0)
	end

	self:refreshFocusedElementRelationPanel(elementName)
	self.rootUComponent:TryChangePage("Tab", 0)
	self.rootUComponent:TryChangePage("State", elementName and 0 or 1)
	self:show()
	LuaUIUtils.setUIVisible(self.rootUComponent, true)
	UIUtils.ScaleVisible(self.rootUComponent.gameObject, true)

	if cb then
		cb()
	end
end

function RestraintUIComponent:initAllElementRelationPanel()
	self.showOrder = {}

	for k, v in pairs(ElementPropData) do
		if v.isShow == 1 then
			table.insert(self.showOrder, {
				elementName = v.name,
				label = pg.getLocalizationText(v.name_ch)
			})
		end
	end

	local data = {}

	for i, attack in ipairs(self.showOrder) do
		for j, def in ipairs(self.showOrder) do
			local value = 1

			if ElementAgainstData[attack.elementName] and ElementAgainstData[attack.elementName][def.elementName] then
				value = ElementAgainstData[attack.elementName][def.elementName]
			end

			local key1 = i % 2 == 0 and 2 or 0
			local key2 = j % 2 == 0 and 1 or 0
			local ele = {
				tIndex = 0,
				bgState = key1 + key2
			}

			if value > 1 then
				ele.state = 1
			elseif value == 1 then
				ele.state = 0
			elseif value > 0 then
				ele.state = 2
			else
				ele.state = 3
			end

			table.insert(data, ele)
		end
	end

	self.listStateUList.colCount = #self.showOrder

	self.listStateUList:SetList(data)
	self.horizontalListUList:SetList(self.showOrder)
	self.verticallListUList:SetList(self.showOrder)
	self.topAllElementsUList:SetList(self.showOrder)
end

function RestraintUIComponent:refreshFocusedElementRelationPanel(elementName)
	elementName = elementName or self.showOrder[1].elementName

	self.attackElementUButton:TryChangePage("type", elementName)
	self.defendElementUButton:TryChangePage("type", elementName)
	Lume.clear(self.atkAdvantageList)
	Lume.clear(self.atkDisadvantageList)
	Lume.clear(self.defAdvantageList)
	Lume.clear(self.defDisadvantageList)

	if ElementAgainstData[elementName] then
		for defElement, value in pairs(ElementAgainstData[elementName]) do
			local elementData = LuaUIUtils.getElementDataTable(defElement)

			if elementData.isShow == 1 then
				if value > 1 then
					table.insert(self.atkAdvantageList, elementData)
				elseif value > 0 and value < 1 then
					table.insert(self.atkDisadvantageList, elementData)
				end
			end
		end
	end

	for attackElement, data in pairs(ElementAgainstData) do
		if data[elementName] then
			local elementData = LuaUIUtils.getElementDataTable(attackElement)

			if elementData.isShow == 1 then
				local value = data[elementName]

				if value > 1 then
					table.insert(self.defAdvantageList, LuaUIUtils.getElementDataTable(attackElement))
				elseif value > 0 and value < 1 then
					table.insert(self.defDisadvantageList, LuaUIUtils.getElementDataTable(attackElement))
				end
			end
		end
	end

	self.attackAdvantageElementsUList:SetList(self.atkAdvantageList)
	self.attackDisadvantageElementsUList:SetList(self.atkDisadvantageList)
	self.defendAdvantageElementsUList:SetList(self.defAdvantageList)
	self.defendDisadvantageElementsUList:SetList(self.defDisadvantageList)
end

function RestraintUIComponent:renderBtnToolTip(toolTip, title, detail)
	local objectReference = toolTip:GetComponent("ObjectReference")
	local txtTitle = objectReference:GetRefValue("txtTitle")
	local txtDesc = objectReference:GetRefValue("txtDesc")

	ClientTextUtils.setText(txtTitle, title)
	ClientTextUtils.setText(txtDesc, detail)
end

return RestraintUIComponent
