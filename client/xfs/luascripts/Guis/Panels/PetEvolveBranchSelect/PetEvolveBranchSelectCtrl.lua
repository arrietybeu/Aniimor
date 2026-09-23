-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetEvolveBranchSelect\\PetEvolveBranchSelectCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local MessageName = require("Const.MessageName")
local PetEvolveData = require("Data.pet_evolve_data")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local lume = require("Core.Common.lume")
local UIUtils = UIUtils
local bit = bit
local TimerManager = require("Core.Timer.TimerManager")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetData = require("Data.pet_data")
local lshift = bit.lshift
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local math_ceil = math.ceil
local Class = require("Core.Framework.Class")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local UICtrl = require("Guis.UICtrl")
local PetEvolveBranchSelectCtrl = Class.LightClass("PetEvolveBranchSelectCtrl", UICtrl)
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")

PetEvolveBranchSelectCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PetEvolveBranchSelectCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.timers = {}
end

function PetEvolveBranchSelectCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	self.view.clickObject.camera = pg.global.cameraMgr.uiSceneCameraInst
	self.view.clickObject.layerMask = lshift(1, ClientConst.LayerDefine.LAYER_UI_SCENE)

	function self.view.clickObject.luaClick(go)
		self:onClickScreen(go)
	end

	function self.view.btnEvolveUButton.luaClick()
		self:tryEvolve()
	end

	function self.view.conditionList.luaRenderItem(button, idx, data)
		self:renderEvolveConditionList(button, idx, data)
	end

	function self.view.conditionList.luaFinishRender(list)
		local animation = self.view.branchInfoUWidget:GetComponent("Animation")

		if self.petInfo:canEvolveBranch(self.branchId) then
			local timer = TimerManager.addTimer(self.validConditionCount * 0.2 + 1, function()
				animation:Play("VX_Pb_EvolveBranch_Evolve_In")
			end)

			self.timers[timer] = timer
		end
	end

	function self.view.itemList.luaRenderItem(button, idx, data)
		self:renderEvolveItemList(button, idx, data)
	end
end

function PetEvolveBranchSelectCtrl:getRealCostItem()
	local ret = {}
	local checked, realItems = ItemUtils.getEvolveNeedItemResult(pg.me, self.itemConditions)

	if checked then
		for itemId, count in pairs(realItems) do
			ret[#ret + 1] = {
				itemId,
				count
			}
		end
	end

	return ret
end

function PetEvolveBranchSelectCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetEvolveBranchSelectCtrl:renderEvolveConditionList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local vxGlowUWidget = objectReference:GetRefValue("vxGlowUWidget")
	local conditionUBaseText = objectReference:GetRefValue("conditionUBaseText")
	local desc = objectReference:GetRefValue("textUBaseText")

	LuaUIUtils.setUIViewVisible(vxGlowUWidget, false)
	ClientTextUtils.setText(desc, data.desc)

	if data.reached then
		button:TryChangePage("Reached", 1)

		local timer = TimerManager.addTimer((data.count - 1) * 0.2, function()
			LuaUIUtils.setUIViewVisible(vxGlowUWidget, true)
		end)

		self.timers[timer] = timer
	else
		button:TryChangePage("Reached", 0)
	end

	if data.specialStyle then
		button:TryChangePage("Condition", 1)

		if data.reached then
			ClientTextUtils.setText(conditionUBaseText, pg.getGameString("EVOLVE_CONDITION_FIRST_COMPLETE"))
			button:TryChangePage("Color", 1)
		else
			ClientTextUtils.setText(conditionUBaseText, pg.getGameString("EVOLVE_CONDITION_FIRST_UNCOMPLETE"))
			button:TryChangePage("Color", 0)
		end
	else
		button:TryChangePage("Condition", 0)
	end
end

function PetEvolveBranchSelectCtrl:renderEvolveItemList(button, idx, data)
	local function itemNumFunc(textNode)
		local realItem = data.realItem
		local ownNum
		local preferredState = UIConst.ITEM_STATE.FULL

		if realItem.checked then
			if not realItem.altItem then
				ownNum = realItem.ownCount
			else
				ownNum = data.num
				preferredState = UIConst.ITEM_STATE.EXCHANGE
			end
		else
			ownNum = realItem.itemCount
		end

		LuaUIUtils.renderConsumeText(textNode, ownNum, data.num, preferredState)
	end

	LuaUIUtils.renderItemWithCountCheck(button, data, itemNumFunc)
end

function PetEvolveBranchSelectCtrl:onClickScreen(go)
	if not go then
		return
	end

	local name = go.name

	if string.sub(name, 1, 12) == "evolveGraph_" then
		local infos = string.split(name, "_")

		self.branchId = tonumber(infos[2])

		self:showEvolveCondition()

		local evolveData = PetEvolveData[self.templateId]
		local subStageEvolveData = evolveData[self.branchId]

		self.petScene:playPetEvolveAction(subStageEvolveData.targetPetId)
	end
end

function PetEvolveBranchSelectCtrl:tryEvolve()
	local function requestEvolve()
		pg.me:serverMsg("RPC_CS_StartEvolve", self.petId, self.branchId)
	end

	local function confirmDarkPetEvolve()
		local pet = pg.me:getPetInfo(self.petId)

		if pet and Utils.isLabelDark(pet.label) then
			pg.global.showConfirmMsgRaw(pg.getGameString("IMPORTANT_NOTICE_TITLE"), pg.getGameString("PET_DARK_DISAPPEAR_EVOLUTION_DESC"), requestEvolve)
		else
			requestEvolve()
		end
	end

	local costData = self:getRealCostItem()

	if Utils.tableIsEmptyOrNil(costData) then
		confirmDarkPetEvolve()
	else
		pg.global.ui.commonUseConfirm:open({
			title = pg.getGameString("PET_EVOLVE_CONFIRM"),
			tipTop = pg.getGameString("ACCESSORY_UNLOCK_DESC"),
			data = costData,
			confirmCb = function()
				confirmDarkPetEvolve()
			end,
			cancelCb = function()
				return
			end
		})
	end
end

function PetEvolveBranchSelectCtrl:showEvolveCondition()
	for timerId, _ in pairs(self.timers) do
		TimerManager.removeTimer(timerId)
	end

	self.timers = {}

	local branchInfo = PetEvolveData[self.templateId][self.branchId]
	local targetPos = self.petScene:getEvolveEntPos(branchInfo.targetPetId)

	UIUtils.SetRectLocalPosByWorldPos(targetPos, self.view.selected.transform)

	local evolveData = PetEvolveData[self.templateId]
	local subStageEvolveData = evolveData[self.branchId]
	local handBookInfo = pg.me.petHandbookMap:getInfo(self.templateId)
	local conditionState = handBookInfo:getEvolveResearchInfoWithDefault(self.branchId):getRawTable()
	local handBookConditionState = conditionState.normalConditionStatus

	if subStageEvolveData.normalCondition0 then
		self.normalConditionData, self.validConditionCount = self:getEvolutionNormalConditionData(handBookConditionState, {
			subStageEvolveData.normalCondition0
		}, true)
	else
		self.normalConditionData = {}
		self.validConditionCount = 0
	end

	local normalConditionData, validConditionCount = self:getEvolutionNormalConditionData(handBookConditionState, subStageEvolveData.normalConditions)

	lume.append(self.normalConditionData, normalConditionData)

	self.validConditionCount = self.validConditionCount + validConditionCount

	self.view.conditionList:SetList(self.normalConditionData)

	self.itemConditions = subStageEvolveData.itemConditions
	self.itemRealCostDict = {}

	if self.itemConditions then
		self.itemCheck, self.itemRealCostDict = ItemUtils.getEvolveNeedItemResult(pg.me, self.itemConditions)

		local itemConditionData = PetResearchUtils.getEvolutionItemConditionData(conditionState.itemConditionStatus, self.itemConditions)

		self.view.itemList:SetList(itemConditionData)
		LuaUIUtils.setUIViewVisible(self.view.itemList, true)
	else
		LuaUIUtils.setUIViewVisible(self.view.itemList, false)
	end

	LuaUIUtils.renderPetCharList(self.view.detailInfoListChar, branchInfo.targetPetId)
	PetResearchUtils.setEvolveQuality(self.view.qualityUButton, branchInfo.targetPetId)
	ClientTextUtils.setText(self.view.descText, pg.getLocalizationText(subStageEvolveData.simpleDesc))

	local canEvolveBranch = self.petInfo:canEvolveBranch(self.branchId)

	self.view.btnEvolveUButton:TryChangePage("canEvolve", canEvolveBranch and 1 or 0)

	self.view.btnEvolveUButton.interactable = canEvolveBranch

	LuaUIUtils.setUIViewVisible(self.view.branchInfoUWidget, true)
	LuaUIUtils.setUIViewVisible(self.view.selected, true)

	if not canEvolveBranch then
		local targetBook = pg.me.petHandbookMap[branchInfo.targetPetId]
		local isGot = targetBook and targetBook:isCatched()

		if not isGot then
			ClientTextUtils.setText(self.view.titleUText, "???")
		else
			ClientTextUtils.setText(self.view.titleUText, pg.getLocalizationText(PetData[branchInfo.targetPetId].name))
		end
	else
		ClientTextUtils.setText(self.view.titleUText, pg.getLocalizationText(PetData[branchInfo.targetPetId].name))
	end
end

function PetEvolveBranchSelectCtrl:getEvolutionNormalConditionData(handbookState, normalConditions, specialStyle)
	local ret = {}
	local count = 0

	for idx, info in pairs(normalConditions or EMPTY_TABLE) do
		local item = {}

		item.specialStyle = specialStyle

		local needCond = info[Const.PET_EVOLVE_NORMAL_COND_POS_COND]

		item.reached = self.petInfo.triggerMap:isCompleteOrMeetCondition(needCond)

		if item.reached then
			item.desc = pg.getLocalizationText(info[3])
			count = count + 1
		elseif handbookState[idx] == Const.PET_RESEARCH.STATUS_CLUE then
			item.desc = pg.getLocalizationText(info[2])
		elseif handbookState[idx] == Const.PET_RESEARCH.STATUS_SHOW then
			item.desc = pg.getLocalizationText(info[3])
		else
			item.desc = "?????"
		end

		item.count = count
		ret[#ret + 1] = item
	end

	return ret, count
end

function PetEvolveBranchSelectCtrl:onOpen(info)
	self.branchId = nil

	UICtrl.onOpen(self, info)

	self.petScene = pg.game.uiScene:getScene(UISceneConst.PET_RESEARCH_DETAIL_V3)
	self.petId = info.petId
	self.petInfo = pg.me:getPetInfo(self.petId)
	self.templateId = self.petInfo.templateId

	LuaUIUtils.setUIViewVisible(self.view.branchInfoUWidget, false)
	LuaUIUtils.setUIViewVisible(self.view.selected, false)
	self:tryDefaultSelect()
end

function PetEvolveBranchSelectCtrl:tryDefaultSelect()
	local evolveInfo = PetEvolveData[self.templateId]

	self.branchId = 1

	for idx, branchInfo in pairs(evolveInfo) do
		if branchInfo.targetPetId and self.petInfo:canEvolveBranch(idx) then
			self.branchId = idx

			break
		end
	end

	if self.branchId then
		self:showEvolveCondition()
	end
end

function PetEvolveBranchSelectCtrl:onShow()
	return
end

function PetEvolveBranchSelectCtrl:onHide()
	return
end

function PetEvolveBranchSelectCtrl:onInputDeviceChanged(deviceType)
	return
end

return PetEvolveBranchSelectCtrl
