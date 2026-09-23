-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchFrontPageV2\\PetResearchFrontPageV2Ctrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetResearchFrontPageV2Ctrl")
local MessageName = require("Const.MessageName")
local lume = require("Core.Common.lume")
local HotkeyConst = require("Const.HotkeyConst")
local Class = require("Core.Framework.Class")
local RedDotConst = require("Const.RedDotConst")
local UICtrl = require("Guis.UICtrl")
local Const = require("Common.Const.Const")
local CountryAreaData = require("Data.country_area_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetResearchFrontPageV2Ctrl = Class.LightClass("PetResearchFrontPageV2Ctrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local MapAreaData = require("Data.map_area_config_data")

PetResearchFrontPageV2Ctrl.messages = {
	[MessageName.PET_RESEARCH_COUNTRY_REWARD_STATUS_CHANGE] = {
		"onRewardStatusChanged",
		true
	}
}

function PetResearchFrontPageV2Ctrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetResearchFrontPageV2Ctrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.rewardListUList.luaRenderItem(button, idx, data)
		self:renderRewardItem(button, idx, data)
	end

	function self.view.btnStarPreview.luaClick()
		pg.global.ui.playerResearchStarPreview:open({
			countryId = self.countryId
		})
	end

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui.help:open({
			helpId = 115
		})
	end

	function self.view.btnAreaSwitch.luaClick()
		pg.global.ui.petResearchCountryPage:open(nil, PetResearchFrontPageV2Ctrl._openCountryPageCallback)
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

	ClientTextUtils.setText(self.view.propTextUSDFText, pg.getGameString("ITEM_REWARD_TITLE"))
end

function PetResearchFrontPageV2Ctrl:_reqGetReward()
	pg.me:getPetHandbookCountryLevelReward(self.countryId, -1)
end

function PetResearchFrontPageV2Ctrl._openCountryPageCallback()
	return
end

function PetResearchFrontPageV2Ctrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetResearchFrontPageV2Ctrl:onRewardStatusChanged()
	self:setRewardList()
end

function PetResearchFrontPageV2Ctrl:renderRewardItem(button, idx, data)
	LuaUIUtils.renderRewardItem(button, data)

	local redDotTreePath = string.format(RedDotConst.RedDotPath.PET_RESEARCH_COUNTRY_REWARD_ITEM, idx)

	if self.hasReward then
		pg.global.setRedDot(redDotTreePath, button, true, RedDotConst.RedDotStyle.REWARD)
	else
		pg.global.setRedDot(redDotTreePath, button, false, RedDotConst.RedDotStyle.NONE)
	end
end

function PetResearchFrontPageV2Ctrl:setRewardList()
	local countryData = PetResearchUtils.getCountryResearchContentById(self.countryId)

	if countryData == nil then
		return
	end

	local maxLevel = table.maxn(countryData)
	local petHandbookMap = pg.me.petHandbookMap
	local collectLevel, remain = petHandbookMap:getCountryTotalLevel(self.countryId)
	local targetLevel, rewardStatues
	local canRewardLevel = {}

	for level = 1, collectLevel do
		rewardStatues = petHandbookMap:getCountryLevelRewardStatus(self.countryId, level)

		if rewardStatues == Const.REWARD_STATUS_CANREWARD then
			local dropId = countryData[level].reward
			local rewardDatas = LuaUIUtils.getRewardItemByDropId(dropId, rewardStatues == Const.REWARD_STATUS_DONE, true, nil, function()
				self:_reqGetReward()
			end)

			self:getMergeRewardDatas(canRewardLevel, rewardDatas)
		end
	end

	if #canRewardLevel < 1 then
		targetLevel = math.min(collectLevel + 1, maxLevel)
		rewardStatues = petHandbookMap:getCountryLevelRewardStatus(self.countryId, targetLevel)

		local dropId = countryData[targetLevel].reward
		local rewardDatas = LuaUIUtils.getRewardItemByDropId(dropId, rewardStatues == Const.REWARD_STATUS_DONE, false)

		if rewardStatues == Const.REWARD_STATUS_INIT then
			self.view.widget:TryChangePage("State", 0)
		else
			self.view.widget:TryChangePage("State", 1)
		end

		self.hasReward = false

		self.view.rewardListUList:SetList(rewardDatas)
	else
		self.view.widget:TryChangePage("State", 2)

		self.hasReward = true

		self.view.rewardListUList:SetList(canRewardLevel)
	end

	self.view.btnGetRewardUButton:SetActiveFastest(false)
end

function PetResearchFrontPageV2Ctrl:getMergeRewardDatas(canRewardLevel, appendReward)
	for _, info in ipairs(appendReward) do
		local exist = false

		for _, info2 in ipairs(canRewardLevel) do
			if info.id == info2.id then
				exist = true
				info2.num = info2.num + info.num

				break
			end
		end

		if not exist then
			table.insert(canRewardLevel, info)
		end
	end
end

function PetResearchFrontPageV2Ctrl:setSubmitBtnState()
	local player = pg.me
	local reportMoney = player.catchReportMap:getTotalMoney()
	local reportPoint = 0

	if player.petHandbookMap and player.petHandbookMap.petCountryMap[self.countryId] and player.petHandbookMap.petCountryMap[self.countryId].researchReportMap then
		reportPoint = player.petHandbookMap.petCountryMap[self.countryId].researchReportMap:getTotalPoint()
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
			local campStaticId, sceneId = PetResearchUtils.getMainCamp()

			if campStaticId then
				pg.global.showConfirmMsgRaw(pg.getGameString("SUB_REPORT_CONFIRM_TITLE"), pg.getGameString("SUB_REPORT_CONFIRM_CONTENT"), function()
					pg.me:serverMsg("RPC_CS_SetBacktrackPos")
					ClientUtils.playTeleportDissolveEffectAndTeleportByFunc(function()
						pg.me:tryTeleportToScene(pg.game.map:convertSceneId(sceneId), campStaticId)
					end)
					pg.global.ui:closeAllNormalPanel()
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

function PetResearchFrontPageV2Ctrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.countryId = info.countryId or PetResearchUtils.getLastPetResearchAreaId()

	self:setProgress()
	self:setCollectText()
	self:setRewardList()
	self:setSubmitBtnState()
end

function PetResearchFrontPageV2Ctrl:onShow()
	return
end

function PetResearchFrontPageV2Ctrl:onHide()
	return
end

function PetResearchFrontPageV2Ctrl:setProgress()
	local curLevel, remain, needExp, isMax = PetResearchUtils.getCountryLevelInfo(self.countryId)

	self.view.sliderUSlider.maxValue = needExp
	self.view.sliderUSlider.value = remain
	self.view.txtLevelUSDFText.text = curLevel
	self.view.txtExp.text = string.format("<b>%s</b>/%s", remain, needExp)

	self.view.maxUWidget:SetActiveFastest(isMax)
end

function PetResearchFrontPageV2Ctrl:setCollectText()
	local countryName = CountryAreaData[self.countryId].name

	ClientTextUtils.setText(self.view.countryNameUSDFText, pg.getLocalizationText(countryName))

	self.view.cardUImage.url = LuaUIUtils.getCountryIconByType(self.countryId, LuaUIUtils.PET_IMG)

	local _, caughtNum, _, shinyCaughtNum = PetResearchUtils.getCountryCollectInfo(self.countryId)
	local normalSumCount, shinySumCount = PetResearchUtils.getPetResearchPetCountSum(self.countryId)

	ClientTextUtils.setText(self.view.normalCountTxt, string.format("%s/%s", caughtNum, normalSumCount))
	ClientTextUtils.setText(self.view.shinyCountTxt, string.format("%s/%s", shinyCaughtNum, shinySumCount))

	local mapData = MapAreaData[self.countryId]

	self.view.backgroundUImage.url = mapData.areaBackground1
	self.view.imgPicUImage.url = mapData.areaBackground2
end

return PetResearchFrontPageV2Ctrl
