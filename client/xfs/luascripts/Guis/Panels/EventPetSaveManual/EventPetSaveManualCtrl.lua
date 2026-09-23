-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventPetSaveManual\\EventPetSaveManualCtrl.lua

local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local RedDotConst = require("Const.RedDotConst")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local EventPetSaveManualCtrl = Class.LightClass("EventPetSaveManualCtrl", UICtrl)
local texStr = {
	"PET_SAVE_WEEK_COMPANY",
	"PET_SAVE_WEEK_FIGHT",
	"PET_SAVE_WEEK_HOME"
}

function EventPetSaveManualCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function EventPetSaveManualCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:dismiss()
	end

	function self.view.btnInfo.luaClick()
		local desc = self.manualCfgs[self.model:getSubActId(self.week)].rule

		pg.global.ui.tips:openEventRuleDesc(desc)
	end

	function self.view.listManualUList.luaRenderItem(button, index, data)
		self:renderManualItem(button, index, data)
	end

	function self.view.listRewardUList.luaRenderItem(button, index, data)
		function data.extraFunc()
			local subActId = self.model:getSubActId(self.week)
			local hasGet = self.model:receivedWeekSumyReward(subActId)

			if not hasGet then
				pg.me:reqActivityPetSaveWeekSumyReward(self.eventId, subActId, function()
					self:refreshReward(subActId)
					facade:sendMsgToUI(MessageName.EVENT_PETSAVE_CHANGE, {})
				end)
			end
		end

		LuaUIUtils.renderRewardItem(button, data)
		pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_PET_SAVE_REWARD .. index, button, data.canGet and not data.hasGet, RedDotConst.RedDotStyle.REWARD)
	end

	function self.view.btnPrev.luaClick()
		self.week = math.max(self.week - 1, 1)

		self:refreshManual()
	end

	function self.view.btnNext.luaClick()
		self.week = math.min(self.week + 1, self.maxWeek)

		self:refreshManual()
		facade:sendMsgToUI(MessageName.EVENT_PETSAVE_CHANGE, {})
	end
end

function EventPetSaveManualCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.manualCfgs = self.model:getManualCfg()

	local weekIndex = info.weekIndex

	self.eventId = info.eventId

	local showWeek = weekIndex - 110

	self.maxWeek = ClientActivityUtils.checkIsPetSaveType(weekIndex) and table.getCount(self.manualCfgs) or showWeek - 1
	self.week = math.min(showWeek, self.maxWeek)

	self:initUI()
end

function EventPetSaveManualCtrl:onShow()
	return
end

function EventPetSaveManualCtrl:onHide()
	return
end

function EventPetSaveManualCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function EventPetSaveManualCtrl:initUI()
	self:refreshManual()
end

function EventPetSaveManualCtrl:refreshManual()
	local subActId = self.model:getSubActId(self.week)
	local showData = self.model:getWeekSumyPetInfo(subActId)

	self.view.rootUComponent:TryChangePage("Empty", showData and next(showData) and 0 or 1)

	if showData and next(showData) then
		self.view.listManualUList:SetList(showData)
	end

	self:refreshReward(subActId)
	self.view.btnPrev:SetActive(self.week > 1)
	self.view.btnNext:SetActive(self.week < self.maxWeek)
	ClientTextUtils.setText(self.view.txtNumUBaseText, self.week)
	ClientTextUtils.setText(self.view.txtEmptyUBaseText, pg.getGameString("PET_SAVE_WEEK_NO"))
end

function EventPetSaveManualCtrl:refreshReward(subActId)
	if self.manualCfgs and next(self.manualCfgs) then
		local rewards = LuaUIUtils.getRewardItemByDropId(self.manualCfgs[subActId].reward)
		local canGet = self.model:getWeekArrival(subActId)
		local hasGet = self.model:receivedWeekSumyReward(subActId)

		for i, data in ipairs(rewards) do
			data.hasGet = hasGet
			data.canGet = canGet
		end

		self.view.listRewardUList:SetList(rewards)
	end
end

function EventPetSaveManualCtrl:renderManualItem(item, index, data)
	local objectReference = item:GetComponent("ObjectReference")
	local texStr = texStr[index + 1]

	item:TryChangePage("Empty", data.name and 0 or 1)

	if not data.name and texStr then
		local txtEmptyUBaseText = objectReference:GetRefValue("txtEmptyUBaseText")

		ClientTextUtils.setText(txtEmptyUBaseText, pg.getGameString(texStr .. "_NO"))

		return
	end

	local imgPetImagePro = objectReference:GetRefValue("imgPetImagePro")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local cData = self.model:getPetCfg(data.templateId)

	if cData then
		imgPetImagePro.url = LuaUIUtils.getPetIcon(cData.iconName, LuaUIUtils.PET_ICON, data.label, data.gender)
	end

	if not texStr then
		return
	end

	local showTex

	if index == 0 then
		showTex = Utils.formatAttrDesc(data.accompanyTime / Const.SECONDS_ONE_HOUR, 2)
	elseif index == 1 then
		showTex = data.killPuppetsAct
	elseif index == 2 then
		showTex = Utils.formatAttrDesc(data.putInHomeTime / Const.SECONDS_ONE_HOUR, 2)
	end

	local name = data.name ~= "" and data.name or cData and pg.getLocalizationText(cData.name) or ""

	ClientTextUtils.setText(txtNameUBaseText, pg.getFormatText(pg.getGameString(texStr), name, showTex))
end

return EventPetSaveManualCtrl
