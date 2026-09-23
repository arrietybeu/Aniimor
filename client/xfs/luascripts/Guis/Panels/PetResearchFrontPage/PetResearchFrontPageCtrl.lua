-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchFrontPage\\PetResearchFrontPageCtrl.lua

local MessageName = require("Const.MessageName")
local CountryAreaData = require("Data.country_area_data")
local PetCountryCollectData = require("Data.pet_research_country_collect_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local RedDotConst = require("Const.RedDotConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local Const = require("Common.Const.Const")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetResearchFrontPageCtrl = Class.LightClass("PetResearchFrontPageCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

PetResearchFrontPageCtrl.messages = {
	[MessageName.PET_RESEARCH_COUNTRY_REWARD_STATUS_CHANGE] = {
		"onRewardStatusChanged",
		true
	}
}
PetResearchFrontPageCtrl.default_country_id = 300001

function PetResearchFrontPageCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetResearchFrontPageCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnBackUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.skillListUList.luaRenderItem(button, idx, data)
		PetResearchUtils.renderSkillItem(button, data)
	end

	function self.view.rewardListUList.luaRenderItem(button, idx, data)
		self:renderRewardItem(button, idx, data)
	end

	function self.view.btnGetRewardUButton.luaClick()
		self:tryGetCurLevelReward()
	end

	function self.view.btnCountryShow.luaClick()
		pg.global.ui.petResearchCountryPage:open()
	end

	function self.view.btnStarPreview.luaClick()
		pg.global.ui.playerResearchStarPreview:open()
	end

	self:setSubmitBtnState()
end

function PetResearchFrontPageCtrl:setSubmitBtnState()
	local player = pg.me
	local reportMoney = player.catchReportMap:getTotalMoney()
	local reportPoint = 0

	if player.petHandbookMap and player.petHandbookMap.petCountryMap[PetResearchFrontPageCtrl.default_country_id] and player.petHandbookMap.petCountryMap[PetResearchFrontPageCtrl.default_country_id].researchReportMap then
		reportPoint = player.petHandbookMap.petCountryMap[PetResearchFrontPageCtrl.default_country_id].researchReportMap:getTotalPoint()
	end

	ClientTextUtils.setText(self.view.researchPointUBaseText, reportPoint or 0)

	if reportMoney <= 0 and reportPoint <= 0 then
		self.view.btnSubmitStar.visualInteractable = false

		function self.view.btnSubmitStar.luaClick()
			pg.global.showBubbleMessageRaw(pg.getGameString("SUB_REPORT_NO_PET"))
		end

		self.view.submitBtnTxt = pg.getGameString("REPORT_EMPTY_BTN_STATE")
	else
		self.view.btnSubmitStar.visualInteractable = true
		self.view.submitBtnTxt = pg.getGameString("REPORT_PET_BTN")

		function self.view.btnSubmitStar.luaClick()
			local targetPos = self:getNearestCamp()

			if targetPos then
				pg.global.showConfirmMsgRaw(pg.getGameString("SUB_REPORT_CONFIRM_TITLE"), pg.getGameString("SUB_REPORT_CONFIRM_CONTENT"), function()
					pg.me:serverMsg("RPC_CS_SetBacktrackPos")
					pg.me:serverMsg("RPC_CS_ResetPosByRecord", targetPos, 0, function()
						pg.global.ui:closeAllNormalPanel()
					end)
				end, false)
			else
				pg.global.showBubbleMessageRaw(pg.getGameString("PET_REPORT_CAMP_EMPTY"))
			end
		end
	end

	if reportPoint > 0 and PetResearchUtils.checkHasStarRaiseInReport(self.countryId) then
		pg.global.setRedDot(RedDotConst.RedDotPath.PET_RESEARCH_COUNTRY_STAR_RAISE, self.view.btnSubmitStar, true, RedDotConst.RedDotStyle.STAR_RAISE)
	else
		pg.global.setRedDot(RedDotConst.RedDotPath.PET_RESEARCH_COUNTRY_STAR_RAISE, self.view.btnSubmitStar, false, RedDotConst.RedDotStyle.NONE)
	end
end

function PetResearchFrontPageCtrl:getNearestCamp()
	local player = pg.me
	local sceneId = player.space.sceneId
	local statusMap = player.mapMarkStatusMap[sceneId] or {}
	local campStatus = statusMap[Const.MAP_MARK_CAMP] or {}
	local minDist = math.maxFloat
	local targetPos
	local sceneMarkPointData = SceneUtils.getSceneMarkPointData(sceneId)

	for staticId, status in pairs(campStatus) do
		if status == Const.MAP_MARK_STATUS_UNLOCKED then
			local position = sceneMarkPointData[staticId].markPosition
			local dist = Vector3.SqrDistance(player:getPosition(), position)

			if dist < minDist then
				dist = minDist
				targetPos = position
			end
		end
	end

	return targetPos
end

function PetResearchFrontPageCtrl:teleportToReport()
	pg.global.ui:closeAllNormalPanel()
end

function PetResearchFrontPageCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetResearchFrontPageCtrl:onRewardStatusChanged()
	self:setTargetReward(self.countryId)
end

function PetResearchFrontPageCtrl:dismiss()
	if not pg.global.ui.petResearch:checkUIOpen() and not self.dontSwitchToPetResearch then
		pg.global.ui.petResearch:open({
			{
				templateId = self.focusTemplateId
			}
		})

		self.focusTemplateId = nil
	end

	self:startTimer(function()
		UICtrl.dismiss(self)
	end, 0.2)
end

function PetResearchFrontPageCtrl:renderSkillItem(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local name = objectReference:GetRefValue("name")
	local icon = objectReference:GetRefValue("icon")

	ClientTextUtils.setText(name, data.name)

	icon.url = data.icon

	function button.luaClick()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP, {
				autoHor = true,
				targetRect = button,
				data = data
			})
		end
	end
end

function PetResearchFrontPageCtrl:renderRewardItem(button, idx, data)
	LuaUIUtils.renderRewardItem(button, data)

	local redDotTreePath = string.format(RedDotConst.RedDotPath.PET_RESEARCH_COUNTRY_REWARD_ITEM, idx)

	if self.rewardLevel then
		pg.global.setRedDot(redDotTreePath, button, true, RedDotConst.RedDotStyle.REWARD)
	else
		pg.global.setRedDot(redDotTreePath, button, false, RedDotConst.RedDotStyle.NONE)
	end
end

function PetResearchFrontPageCtrl:setCurPointProgress(countryId)
	local countryData = PetResearchUtils.getCountryResearchContentById(countryId)
	local petHandbookMap = pg.me.petHandbookMap
	local collectLevel, remain = petHandbookMap:getCountryTotalLevel(countryId)
	local curLevelInfo = countryData[collectLevel] or {}
	local nextLevelInfo = countryData[collectLevel + 1] or {}
	local needPoint = (nextLevelInfo.needResearchPoint or 0) - (curLevelInfo.needResearchPoint or 0)

	ClientTextUtils.setText(self.view.textUBaseText, string.format("<b>%s</b>/%s", remain, needPoint))
end

function PetResearchFrontPageCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	info = info or {}
	self.countryId = info.countryId or 300001
	self.focusTemplateId = info.templateId
	self.dontSwitchToPetResearch = info.dontSwitchToPetResearch

	self:refreshCountryCollect(self.countryId)
	self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
end

function PetResearchFrontPageCtrl:refreshCountryCollect(countryId)
	self:setProgressStar(countryId)
	self:setCollectText(countryId)
	self:setPlayerSkill()
	self:setTargetReward(countryId)
end

function PetResearchFrontPageCtrl:setCollectText(countryId)
	self:setCurPointProgress(countryId)

	local countryName = CountryAreaData[countryId].name

	ClientTextUtils.setText(self.view.countryNameUSDFText, pg.getLocalizationText(countryName))

	self.view.cardUImage.url = LuaUIUtils.getCountryIconByType(countryId, LuaUIUtils.PET_IMG)

	local _, caughtNum, _, shinyCaughtNum, totalNum = PetResearchUtils.getCountryCollectInfo(countryId)

	ClientTextUtils.setText(self.view.caughtTextUText, string.format("%s/%s", caughtNum, totalNum))
	ClientTextUtils.setText(self.view.shinyTextUText, string.format("%s/%s", shinyCaughtNum, totalNum))
end

function PetResearchFrontPageCtrl:setProgressStar(countryId)
	local starDatas = PetResearchUtils.getCountryStarData(countryId)

	for level = 1, PetResearchUtils.COUNTRY_START_PAGE_COUNT do
		PetResearchUtils.renderCountryStar(self.view["btnStarItem" .. level], starDatas[level])
	end
end

function PetResearchFrontPageCtrl:setPlayerSkill(countryId)
	local skillDatas = PetResearchUtils:getPlayerSkill(countryId)

	if #skillDatas < 1 then
		self.view.widget:TryChangePage("GrowthRewards", 1)

		return
	end

	self.view.widget:TryChangePage("GrowthRewards", 0)
	self.view.skillListUList:SetList(skillDatas)
end

function PetResearchFrontPageCtrl:setTargetReward(countryId)
	local countryData = PetResearchUtils.getCountryResearchContentById(countryId)
	local maxLevel = table.maxn(countryData)
	local petHandbookMap = pg.me.petHandbookMap
	local collectLevel, remain = petHandbookMap:getCountryTotalLevel(countryId)
	local targetLevel, rewardStatues
	local canReward = false

	self.rewardLevel = nil

	for level = 1, collectLevel do
		rewardStatues = petHandbookMap:getCountryLevelRewardStatus(countryId, level)
		canReward = rewardStatues == Const.REWARD_STATUS_CANREWARD

		if canReward then
			targetLevel = level
			self.rewardLevel = targetLevel

			break
		end
	end

	targetLevel = targetLevel or math.min(collectLevel + 1, maxLevel)
	rewardStatues = petHandbookMap:getCountryLevelRewardStatus(countryId, targetLevel)

	local dropId = countryData[targetLevel].reward
	local rewardDatas = LuaUIUtils.getRewardItemByDropId(dropId, rewardStatues == Const.REWARD_STATUS_DONE, canReward)

	if rewardStatues == Const.REWARD_STATUS_CANREWARD then
		self.view.widget:TryChangePage("State", 2)
	elseif rewardStatues == Const.REWARD_STATUS_INIT then
		self.view.widget:TryChangePage("State", 0)
	else
		self.view.widget:TryChangePage("State", 1)
	end

	self.view.rewardListUList:SetList(rewardDatas)
end

function PetResearchFrontPageCtrl:tryGetCurLevelReward()
	pg.me:getPetHandbookCountryLevelReward(self.countryId, self.rewardLevel)
end

function PetResearchFrontPageCtrl:onShow()
	return
end

function PetResearchFrontPageCtrl:onHide()
	return
end

return PetResearchFrontPageCtrl
