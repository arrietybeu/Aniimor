-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerResearchStarPreview\\PlayerResearchStarPreviewCtrl.lua

local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local RedDotConst = require("Const.RedDotConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PlayerResearchStarPreviewCtrl = Class.LightClass("PlayerResearchStarPreviewCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local MapAreaConfigData = require("Data.map_area_config_data")

PlayerResearchStarPreviewCtrl.MAX_LIST_COUNT = 5
PlayerResearchStarPreviewCtrl.REWARD_STATE = {
	NORMAL = 0,
	CAN_GET = 2,
	IS_GET = 1
}
PlayerResearchStarPreviewCtrl.messages = {
	[MessageName.PET_RESEARCH_COUNTRY_REWARD_STATUS_CHANGE] = {
		"onRewardStatusChanged",
		true
	}
}

function PlayerResearchStarPreviewCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PlayerResearchStarPreviewCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnCloseUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Canceled" then
			self:dismiss()
		end
	end

	function self.view.listRewardUList.luaRenderItem(button, idx, data)
		self:renderPreviewList(button, idx, data)
	end

	function self.view.btnConfirmUButton.luaClick()
		self:ReqGetRewards()
	end

	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("PET_REPORT_GET_ALL_REWARD"))
end

function PlayerResearchStarPreviewCtrl:ReqGetRewards()
	pg.me:getPetHandbookCountryLevelReward(self.countryId, -1)
end

function PlayerResearchStarPreviewCtrl:renderPreviewList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local txtLvUSDFText = objectReference:GetRefValue("txtLvUSDFText")
	local rewardListUList = objectReference:GetRefValue("rewardListUList")
	local txtResearchPointUSDFText = objectReference:GetRefValue("txtResearchPointUSDFText")
	local txtClaimedUSDFText = objectReference:GetRefValue("txtClaimedUSDFText")

	ClientTextUtils.setText(txtClaimedUSDFText, pg.getGameString("PLAYER_BTN_REWARD_NAME"))

	function rewardListUList.luaRenderItem(b, i, d)
		if d.tIndex == 1 then
			return
		end

		LuaUIUtils.renderRewardItem(b, d)
		b:TryChangePage("State", data.stateIdx)

		if data.stateIdx == PlayerResearchStarPreviewCtrl.REWARD_STATE.CAN_GET then
			function b.luaClick()
				self:ReqGetRewards()
			end
		end
	end

	rewardListUList:SetList(data.rewardList)
	button:TryChangePage("State", data.stateIdx)
	ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("RESEARCH_STAR"))
	ClientTextUtils.setText(txtResearchPointUSDFText, string.format("%s/%s", data.curExp, data.maxExp))
	ClientTextUtils.setText(txtLvUSDFText, data.level)
end

function PlayerResearchStarPreviewCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PlayerResearchStarPreviewCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	info = info or {}
	self.countryId = info.countryId or PetResearchUtils.getLastPetResearchAreaId()

	local curResearchPointNum = pg.me.petHandbookMap:getReportResearchPointTotal()

	if curResearchPointNum > 0 then
		self.view.propTextUSDFText:SetActiveFastest(true)

		local areaName = MapAreaConfigData[self.countryId].areaName
		local propText = pg.getFormatText(pg.getGameString("RESEARCH_STAR_PROP"), pg.getLocalizationText(areaName), curResearchPointNum)

		ClientTextUtils.setText(self.view.propTextUSDFText, propText)
	else
		self.view.propTextUSDFText:SetActiveFastest(false)
	end

	self:setPreviewFullList(self.countryId)
end

function PlayerResearchStarPreviewCtrl:onRewardStatusChanged()
	self:setPreviewFullList(self.countryId)
end

function PlayerResearchStarPreviewCtrl:onShow()
	self.view.viewRoot:TryChangePage("Type", 1)
	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("RESEARCH_STAR_TITLE"))
end

function PlayerResearchStarPreviewCtrl:setPreviewFullList(countryId)
	local preDatas = self:getPreviewDatas(countryId)

	self.view.listRewardUList:SetList(preDatas)

	if self.hasRewardIdx > 0 then
		self.view.listRewardUList:GoToIndex(self.hasRewardIdx - 1, true)
	end

	if self.hasReward then
		pg.global.setRedDot(RedDotConst.RedDotPath.PET_RESEARCH_GET_ALL_COUNTRY_REWARD, self.view.btnConfirmUButton, true, RedDotConst.RedDotStyle.REWARD)
	else
		pg.global.setRedDot(RedDotConst.RedDotPath.PET_RESEARCH_GET_ALL_COUNTRY_REWARD, self.view.btnConfirmUButton, false, RedDotConst.RedDotStyle.NONE)
	end

	self.view.btnConfirmUButton.visualInteractable = self.hasReward
end

function PlayerResearchStarPreviewCtrl:getPreviewDatas(countryId)
	local ret = {}

	self.hasRewardIdx = -1
	self.hasReward = false

	local countryData = PetResearchUtils.getCountryResearchContentById(countryId)

	if not countryData then
		return ret
	end

	local petHandbookMap = pg.me.petHandbookMap
	local maxLevel = table.maxn(countryData)
	local collectLevel, remain = petHandbookMap:getCountryTotalLevel(countryId)

	for level = 1, maxLevel do
		local item = {}

		item.level = level

		local dropId = countryData[level].reward

		item.status = petHandbookMap:getCountryLevelRewardStatus(countryId, level)

		local rewardDatas = LuaUIUtils.getRewardItemByDropId(dropId, item.status == Const.REWARD_STATUS_DONE, item.status == Const.REWARD_STATUS_CANREWARD)
		local researchPoint = countryData[level].needResearchPoint

		if level <= collectLevel then
			item.curExp = researchPoint
		elseif level - collectLevel == 1 then
			item.curExp = remain
		else
			item.curExp = 0
		end

		item.maxExp = researchPoint

		if item.status == Const.REWARD_STATUS_INIT then
			item.stateIdx = PlayerResearchStarPreviewCtrl.REWARD_STATE.NORMAL
		elseif item.status == Const.REWARD_STATUS_CANREWARD then
			self.hasReward = true
			item.stateIdx = PlayerResearchStarPreviewCtrl.REWARD_STATE.CAN_GET
		else
			item.stateIdx = PlayerResearchStarPreviewCtrl.REWARD_STATE.IS_GET
		end

		if self.hasRewardIdx < 0 and item.stateIdx ~= PlayerResearchStarPreviewCtrl.REWARD_STATE.IS_GET then
			self.hasRewardIdx = level
		end

		local curRewardCnt = #rewardDatas

		for i = curRewardCnt + 1, self.MAX_LIST_COUNT do
			table.insert(rewardDatas, {
				tIndex = 1
			})
		end

		item.rewardList = rewardDatas
		ret[#ret + 1] = item
	end

	if self.hasRewardIdx < 0 then
		self.hasRewardIdx = collectLevel
	end

	return ret
end

function PlayerResearchStarPreviewCtrl:onHide()
	return
end

return PlayerResearchStarPreviewCtrl
