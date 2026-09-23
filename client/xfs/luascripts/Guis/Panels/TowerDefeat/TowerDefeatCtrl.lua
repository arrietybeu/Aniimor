-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerDefeat\\TowerDefeatCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TowerDefeatCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local RoguelikeData = require("Data.roguelike_data")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local LevelConditionData = require("Data.level_condition_data")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local TowerDefeatCtrl = Class.LightClass("TowerDefeatCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RogueUtils = require("Utils.RogueUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local CatchRogueLevelReverseData = require("Data.catch_rogue_level_reverse_data")
local NoticeDef = require("Common.NoticeDef")

TowerDefeatCtrl.RecommendTipType = {
	Element = 1,
	Level = 0
}
TowerDefeatCtrl.messages = {}

function TowerDefeatCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initUI(info)
end

function TowerDefeatCtrl:addListener()
	function self.view.btnExitUButton.luaClick()
		if self.fromType == UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE then
			pg.me:settleCatchRogueGame(true)
			self:dismiss()
		else
			pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("TOWER_ROGUE_LEAVE_TIP"), function()
				self:close()
				pg.me:serverMsg("RPC_CS_QuitSpace")
			end, false, nil, true, function()
				self:close()
				pg.global.ui:open(UIConst.UI_ID_TOWER_SETTLEMENT, {
					confirmCb = function()
						pg.me:serverMsg("RPC_CS_QuitSpace")
					end
				})
			end, {
				nextBtnDesc = pg.getGameString("TOWER_ROGUE_SETTLEMENT_ANE_LEAVE"),
				okBtnDesc = pg.getGameString("TOWER_ROGUE_TEMP_LEAVE")
			})
		end
	end

	function self.view.btnGoinUButton.luaClick()
		pg.me:startRogue(pg.me.curRogueLayer)
		self:close()
	end

	function self.view.listMissionUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNoUSDFText = objectReference:GetRefValue("txtNoUSDFText")
		local txtYesUSDFText = objectReference:GetRefValue("txtYesUSDFText")

		ClientTextUtils.setText(txtNoUSDFText, data.desc)
		ClientTextUtils.setText(txtYesUSDFText, data.desc)
		button:TryChangePage("Complete", data.hasComplete and 0 or 1)
	end

	function self.view.listTipsUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local levelUBaseText = objectReference:GetRefValue("levelUBaseText")
		local listElementUList = objectReference:GetRefValue("listElementUList")
		local titleUBaseText = objectReference:GetRefValue("titleUBaseText")

		button:TryChangePage("Recommend", data.type)
		ClientTextUtils.setText(titleUBaseText, data.label)

		if data.type == self.RecommendTipType.Level then
			ClientTextUtils.setText(levelUBaseText, data.level)

			local totalLevel = 0
			local petCount = 0
			local battlePetIds = RogueUtils.getBattlePetIds()

			for index, petId in ipairs(battlePetIds) do
				local pet = pg.me.pets[petId]

				if pet then
					petCount = petCount + 1
					totalLevel = totalLevel + pet.level
				end
			end

			if petCount == 0 then
				button:TryChangePage("NotHave", 0)
			else
				button:TryChangePage("NotHave", totalLevel / petCount >= data.level and 0 or 1)
			end
		elseif data.type == self.RecommendTipType.Element then
			LuaUIUtils.renderPetElement(listElementUList, data.recommendElement)
		end
	end

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId)
	end

	function self.view.btnConfirmUButton.luaClick()
		if self.fromType == UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE then
			if self.failReason == Const.CatchRogue.SETTLE_TIMEOUT then
				if self.catchRogueBuyCnt and self.catchRogueBuyCnt > 0 then
					pg.global.showCommonTipUse(pg.getGameString("CATCH_ROGUE_DEFEAT_BUY_CONFIRM"), pg.getGameString("CATCH_ROGUE_DEFEAT_BUY_TIME"), nil, function()
						pg.me:settleCatchRogueGame(false, Const.CatchRogue.PURCHASE_TIME, function(noticeId, noticeArgs)
							if noticeId ~= NoticeDef.SUCCESS then
								pg.global.showBubbleMessageById(noticeId, noticeArgs)
							else
								self:dismiss()
							end
						end)
					end, nil)
				else
					pg.global.showBubbleMessageRaw(pg.getGameString("CATCH_ROGUE_BUY_TIME_OVER"))
				end
			elseif self.failReason == Const.CatchRogue.SETTLE_PLAYER_DIED then
				if self.catchRogueBuyCnt and self.catchRogueBuyCnt > 0 then
					pg.global.showCommonTipUse(pg.getGameString("CATCH_ROGUE_DEFEAT_BUY_CONFIRM"), pg.getGameString("CATCH_ROGUE_DEFEAT_BUY_LIFE"), nil, function()
						pg.me:settleCatchRogueGame(false, Const.CatchRogue.PURCHASE_REVIVE, function(noticeId, noticeArgs)
							if noticeId ~= NoticeDef.SUCCESS then
								pg.global.showBubbleMessageById(noticeId, noticeArgs)
							else
								self:dismiss()
							end
						end)
					end, nil)
				else
					pg.global.showBubbleMessageRaw(pg.getGameString("CATCH_ROGUE_BUY_TIME_OVER"))
				end
			end
		end
	end
end

function TowerDefeatCtrl:initUI(info)
	self.fromType = info.fromType

	if info.fromType == UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE then
		local levelData = CatchRoguePhaseData[info.gameId]

		if not levelData then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("TowerDefeatCtrl not have levelData! gameId: %s", info.gameId)
			end

			return
		end

		self.failReason = info.failReason

		local curFloorId = pg.me.catchRogueInfo.floorId
		local totalFloor = #CatchRogueLevelReverseData[info.gameId]
		local failKey = ""

		if self.failReason == Const.CatchRogue.SETTLE_TIMEOUT then
			failKey = "CATCH_ROGUE_DEFEAT_TIME"
		elseif self.failReason == Const.CatchRogue.SETTLE_PLAYER_DIED then
			failKey = "CATCH_ROGUE_DEFEAT_DIE"
		end

		local failSubTitle = string.format(pg.getGameString(failKey), curFloorId, totalFloor)

		ClientTextUtils.setText(self.view.failSubTitle, failSubTitle)
		self.view.listCurrencyUList:SetList({
			{
				itemId = 1
			}
		})
		self.view.listCurrencyUList:SetActive(true)
		self.view.btnAddUWidget:SetActive(pg.me:getCatchRogueBuyEnable() == true)
		self.view.btnGoinUButton:SetActive(false)

		local conditionData = self.model:getCatchRogueFailCondition(info.gameId, self.failReason)

		self.view.listMissionUList:SetList(conditionData)

		local tipData = {}

		if levelData.recommendType then
			table.insert(tipData, {
				label = pg.getGameString("Rift_RecommendElement"),
				type = self.RecommendTipType.Element,
				recommendElement = levelData.recommendType
			})
		end

		if levelData.recommendLv then
			table.insert(tipData, {
				label = pg.getGameString("Rift_RecommendLevel"),
				type = self.RecommendTipType.Level,
				level = levelData.recommendLv
			})
		end

		self.view.listTipsUList:SetList(tipData)
		self.view.btnConfirmUButton:SetActive(pg.me:getCatchRogueBuyEnable() == true)

		if pg.me:getCatchRogueBuyEnable() == true then
			local curCnt, totalCnt = 0, 0
			local itemId, itemNum = 0, 0
			local btnTxtKey

			if self.failReason == Const.CatchRogue.SETTLE_TIMEOUT then
				totalCnt = CatchRoguePhaseData[info.gameId].addTimeLimit
				curCnt = totalCnt - (pg.me.catchRogueInfo.purchaseTimeCnt or 0)
				itemId = CatchRoguePhaseData[info.gameId].addTimeCost[1]
				itemNum = CatchRoguePhaseData[info.gameId].addTimeCost[2]
				btnTxtKey = "CATCH_ROGUE_DEFEAT_DELAYTIME"
			elseif self.failReason == Const.CatchRogue.SETTLE_PLAYER_DIED then
				totalCnt = CatchRoguePhaseData[info.gameId].addTimeLimit
				curCnt = totalCnt - (pg.me.catchRogueInfo.reviveLimit or 0)
				itemId = CatchRoguePhaseData[info.gameId].reviveCost[1]
				itemNum = CatchRoguePhaseData[info.gameId].reviveCost[2]
				btnTxtKey = "CATCH_ROGUE_DEFEAT_REBIRTH"
			end

			self.catchRogueBuyCnt = curCnt

			ClientTextUtils.setText(self.view.costTips, string.format(pg.getGameString("CATCH_ROGUE_DEFEAT_BUY"), curCnt, totalCnt))

			self.view.costIcon.url = LuaUIUtils.getIconByItemId(itemId)

			ClientTextUtils.setText(self.view.costNum, itemNum)

			local objectReference = self.view.btnConfirmUButton:GetComponent("ObjectReference")
			local txtNameUText = objectReference:GetRefValue("txtNameUText")

			ClientTextUtils.setText(txtNameUText, pg.getGameString(btnTxtKey))
		end
	else
		self.view.subTitleUWidget:SetActive(false)
		self.view.btnAddUWidget:SetActive(false)
		self.view.btnGoinUButton:SetActive(true)

		local levelCfg = RoguelikeData[pg.me.curRogueLayer]
		local conditions = pg.me.space.battleCondition or {}

		if info and info.failReason then
			conditions[info.failReason] = false
		end

		local conditionData = {}

		for conditionId, hasComplete in pairs(conditions) do
			local item = {}
			local conditionInfo = LevelConditionData[conditionId]

			if conditionInfo then
				item.desc = pg.getLocalizationText(conditionInfo.displayDesc)
				item.hasComplete = hasComplete

				table.insert(conditionData, item)
			end
		end

		self.view.listMissionUList:SetList(conditionData)

		local tipData = {}

		if levelCfg.recommendType then
			table.insert(tipData, {
				label = pg.getGameString("Rift_RecommendElement"),
				type = self.RecommendTipType.Element,
				recommendElement = levelCfg.recommendType
			})
		end

		if levelCfg.recommendLv then
			table.insert(tipData, {
				label = pg.getGameString("Rift_RecommendLevel"),
				type = self.RecommendTipType.Level,
				level = levelCfg.recommendLv
			})
		end

		self.view.listTipsUList:SetList(tipData)
	end
end

function TowerDefeatCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function TowerDefeatCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TowerDefeatCtrl:onShow()
	return
end

function TowerDefeatCtrl:onHide()
	return
end

return TowerDefeatCtrl
