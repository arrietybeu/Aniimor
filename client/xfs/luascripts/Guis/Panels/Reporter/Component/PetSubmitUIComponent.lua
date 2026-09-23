-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Reporter\\Component\\PetSubmitUIComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local Class = require("Core.Framework.Class")
local PetSubmitUIComponent = Class.LightClass("PetSubmitUIComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SUBMIT_TYPE_NAME = {
	[1] = "CONSUME_SUBMIT",
	[2] = "NO_CONSUME_SUBMIT"
}

function PetSubmitUIComponent:findObjects()
	if IsNil(self.transform) then
		return
	end

	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.component = self.objectReference:GetRefValue("component")
	self.exitBtn = self.objectReference:GetRefValue("exitBtn")
	self.requiredList = self.objectReference:GetRefValue("requiredList")
	self.choseList = self.objectReference:GetRefValue("choseList")
	self.btnTake = self.objectReference:GetRefValue("btnTake")
	self.submitTip = self.objectReference:GetRefValue("submitTip")

	function self.exitBtn.luaClick()
		self:switchReportState(false)
	end

	function self.requiredList.luaRenderItem(item, index, data)
		self:instantiateNeedItem(item, index, data)
	end

	function self.choseList.luaRenderItem(item, index, data)
		self:instantiateChoseItem(item, index, data)
	end

	function self.btnTake.luaClick()
		self:onTakeReward()
	end
end

function PetSubmitUIComponent:initView()
	self.eventParam = nil
	self.successSubmitCallback = nil

	self:clearData()
end

function PetSubmitUIComponent:switchReportState(active, eventData, type, cb)
	self.ctrl:setPageIndex(active and self.model.PET_SUBMIT_REPORTER or self.model.NONE)
	pg.game.camera:enableNpcInteract(active)

	if active then
		ClientTextUtils.setText(self.submitTip, pg.getLocalizationText(SUBMIT_TYPE_NAME[type]))

		self.eventParam = eventData
		self.successSubmitCallback = cb

		self:refreshView()
	end
end

function PetSubmitUIComponent:refreshView()
	self.needList, self.item2ConditionMap = self.model:getPetSubmitData(self.eventParam)

	self.requiredList:SetList(self.needList)

	self.ownList = self.model:getOwnPetData(self.needList)

	if table.nums(self.ownList) > 0 then
		self.component:TryChangePage("state", 0)

		self.btnTake.interactable = true

		self.btnTake:TryChangePage("button", "normal")
		self.choseList:SetList(self.ownList)
	else
		self.component:TryChangePage("state", 1)

		self.btnTake.interactable = false

		self.btnTake:TryChangePage("button", "disabled")
	end
end

function PetSubmitUIComponent:instantiateNeedItem(item, index, data)
	local objRef = item:GetComponent("ObjectReference")
	local iIcon = objRef:GetRefValue("iconUImage")
	local iNumb = objRef:GetRefValue("submitUSDFText")

	item:TryChangePage("Scene", 1)

	item.draggable = false
	iIcon.url = data.icon

	local selectNum = table.nums(self.selectMap[data.id] or {}) or 0

	if selectNum < data.needNum then
		ClientTextUtils.setText(iNumb, string.format("<color=#FE7676>%d</color>/%d", selectNum, data.needNum))
	else
		ClientTextUtils.setText(iNumb, string.format("%d/%d", selectNum, data.needNum))
	end
end

function PetSubmitUIComponent:instantiateChoseItem(item, index, data)
	local objectReference = item:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local numCPUText = objectReference:GetRefValue("numCPUSDFText")
	local singleElement = objectReference:GetRefValue("singleElement")
	local doubleElement1 = objectReference:GetRefValue("doubleElement1")
	local doubleElement2 = objectReference:GetRefValue("doubleElement2")

	iconUImage.url = data.icon

	if #data.elementNames > 1 then
		item:TryChangePage("ElementDouble", 1)
		LuaUIUtils.setElementButtonNew(doubleElement1, data.elementNames[1].element)
		LuaUIUtils.setElementButtonNew(doubleElement2, data.elementNames[2].element)
	else
		item:TryChangePage("ElementDouble", 0)
		LuaUIUtils.setElementButtonNew(singleElement, data.elementNames[1].element)
	end

	item.draggable = false
	self.holdItems[#self.holdItems + 1] = item

	function item.luaClick()
		self:clickItem(data)
	end

	if data.isShiny or data.isBoos then
		item:TryChangePage("Type", 1)
	else
		item:TryChangePage("Type", 0)
	end

	item:TryChangePage("batchRelease", data.select and 2 or 0)

	if self.selectMap[data.templateId] ~= nil and table.getCount(self.selectMap[data.templateId]) >= self.item2ConditionMap[data.templateId].needNum and not data.select then
		item:TryChangePage("state", 1)

		item.interactable = false
	else
		item:TryChangePage("state", 0)

		item.interactable = true
	end

	ClientTextUtils.setText(numCPUText, item.cp)
end

function PetSubmitUIComponent:clickItem(data)
	data.select = not data.select

	self:selectedItem(data.select, data)
	self.choseList:RefreshList()
end

function PetSubmitUIComponent:selectedItem(selected, data)
	if self.selectMap[data.templateId] == nil then
		self.selectMap[data.templateId] = {}
	end

	if selected then
		self.selectMap[data.templateId][data.id] = data
	else
		self.selectMap[data.templateId][data.id] = nil
	end

	self.requiredList:RefreshList()
end

function PetSubmitUIComponent:clearData()
	self.selectMap = {}
	self.item2ConditionMap = {}
	self.needList = {}
	self.ownList = {}
	self.holdItems = {}
	self.curSelected = nil
end

function PetSubmitUIComponent:onTakeReward()
	if not self:checkHasSelection() then
		pg.global.showBubbleMessageById(NoticeDef.PLEASE_SELECT_SUBMIT_PET)

		return
	end

	if not self:checkCanSubmit() then
		pg.global.showBubbleMessageById(NoticeDef.SUBMIT_PET_COUNT_NOT_ENOUGH)

		return
	end

	local me = pg.me

	for pid, map in pairs(self.selectMap) do
		local submitList = {}

		for id, _ in pairs(map) do
			submitList[#submitList + 1] = id
		end

		local conditionData = self.item2ConditionMap[pid].params
		local npcId = self.item2ConditionMap[pid].npcId

		me:serverMsg("RPC_CS_SubPet", conditionData[1], conditionData[2], conditionData[3], npcId, submitList, CallbackHandler(self, "callbackOnPetSubmit"))
	end
end

function PetSubmitUIComponent:callbackOnPetSubmit(noticeId)
	if noticeId ~= NoticeDef.SUCCESS then
		pg.global.showBubbleMessageRaw(pg.getGameString("FAILED"))

		return
	end

	self.selectMap = {}

	self:refreshView()
	self:switchReportState(false)

	if self.successSubmitCallback then
		self.successSubmitCallback()

		self.successSubmitCallback = nil
	end
end

function PetSubmitUIComponent:checkHasSelection()
	local hasSelect = false

	for templateId, data in pairs(self.selectMap) do
		if table.getCount(data) > 0 then
			hasSelect = true

			break
		end
	end

	return hasSelect
end

function PetSubmitUIComponent:checkCanSubmit()
	local isEnough = true

	for _, v in ipairs(self.needList) do
		local ownMap = self.selectMap[v.id]

		if ownMap == nil then
			isEnough = false

			break
		end

		if table.nums(ownMap) < v.needNum then
			isEnough = false

			break
		end
	end

	return isEnough
end

return PetSubmitUIComponent
