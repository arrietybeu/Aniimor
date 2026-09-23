-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerFinal\\TowerFinalCtrl.lua

local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")
local DungeonConst = require("Common.Const.DungeonConst")
local RoguelikeData = require("Data.roguelike_data")
local LevelRewardRouge = require("Data.level_reward_rouge")
local SysConfigData = require("Data.sys_config_data")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TowerFinalCtrl = Class.LightClass("TowerFinalCtrl", UICtrl)
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

TowerFinalCtrl.messages = {}

function TowerFinalCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.param = info
	self.lastRoguePassLayer = pg.me.lastRoguePassLayer
	self.lastDifficulty = pg.me.curRogueLevel or 1

	pg.me:resetRogue()
	self:initUI()
end

function TowerFinalCtrl:addListener()
	function self.view.btnConfirmUButton.luaClick()
		self:close()

		if self.hasFinish and pg.me.space:isRogueEnv() then
			pg.me:serverMsg("RPC_CS_QuitSpace")

			return
		end

		if self.param and self.param.confirmCb then
			self.param.confirmCb()
		end
	end
end

function TowerFinalCtrl:initUI()
	function self.view.listPetUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local petIconUImage = objectReference:GetRefValue("petIconUImage")
		local bottomName = objectReference:GetRefValue("bottomName")
		local numberUText = objectReference:GetRefValue("numberUText")
		local mainElement = objectReference:GetRefValue("mainElement")
		local subElement = objectReference:GetRefValue("subElement")
		local videoPlayerUVideoPlayer = objectReference:GetRefValue("videoPlayerUVideoPlayer")

		petIconUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK, data.label)

		ClientTextUtils.setText(bottomName, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(numberUText, data.level and "Lv.", data.level or data.cp)

		if #data.elementNames > 1 then
			button:TryChangePage("PropertyNum", 1)
			LuaUIUtils.setElementButtonNew(subElement, data.elementNames[1].element)
			LuaUIUtils.setElementButtonNew(mainElement, data.elementNames[2].element)
		else
			button:TryChangePage("PropertyNum", 0)
			LuaUIUtils.setElementButtonNew(mainElement, data.elementNames[1].element)
		end

		if data.isShiny then
			local res = string.format("$%s_Shiny.mp4", data.templateId)

			if pg.global.resMgr:CheckAssetExist(res) then
				videoPlayerUVideoPlayer:SetVideoWithCallback(res)
			else
				videoPlayerUVideoPlayer:SetVideoWithCallback(string.format("$%s.mp4", data.templateId))
			end

			button:TryChangePage("ShineCard", 0)
		else
			videoPlayerUVideoPlayer:SetVideoWithCallback(string.format("$%s.mp4", data.templateId))
			button:TryChangePage("ShineCard", 1)
		end
	end

	function self.view.listBuffUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		iconUImage.url = data.buffIcon

		button:TryChangePage("Quality", data.buffQuality)

		function button.luaRenderTooltip(button, popup)
			PetManagementUtils.customRefreshBuffInfoTooltip(popup, PetManagementDataHelper.BuffInfoToolTipType.Quality, {
				quality = data.buffQuality,
				buffName = pg.getLocalizationText(data.buffName),
				buffDesc = pg.getLocalizationText(data.buffDesc),
				buffIcon = data.buffIcon
			})
		end
	end

	local hasFinish = self.lastRoguePassLayer == RogueDifficultyData[self.lastDifficulty].roguelikeIDEnd

	self.view.uIPbTowerFinalUComponent:TryChangePage("Result", hasFinish and 0 or 1)

	self.hasFinish = hasFinish

	local battlePetIds = pg.me.roguePets or {}
	local data = {}

	for index, petId in ipairs(battlePetIds) do
		local pet = pg.me.pets[petId]

		if pet then
			table.insert(data, LuaUIUtils.generatePetInfo(pet))
		end
	end

	self.view.listPetUList:SetList(data)

	local buffs = pg.me:getRogueBuffs()

	self.view.listBuffUList:SetList(buffs)
	self.view.uIPbTowerFinalUComponent:TryChangePage("EmptyBuff", #buffs == 0 and 1 or 0)

	local levelCfg = RoguelikeData[self.lastRoguePassLayer]

	if levelCfg then
		local dropData = {}
		local hasGetFirst = pg.me.rogueSettlementCnt[self.lastRoguePassLayer] and pg.me.rogueSettlementCnt[self.lastRoguePassLayer] > 0

		if not hasGetFirst then
			if levelCfg.firstSettlementRewardId then
				table.insert(dropData, {
					dropId = levelCfg.firstSettlementRewardId
				})
			end
		elseif levelCfg.settlementRewardId then
			table.insert(dropData, {
				dropId = levelCfg.settlementRewardId
			})
		end

		LuaUIUtils.setRewardListByDropIds(self.view.listItemUList, dropData)
		ClientTextUtils.setText(self.view.txtNumUText, string.format("%d%s %s", levelCfg.floor, pg.getGameString("TOWER_ROGUE_FLOOR_NAME"), pg.getLocalizationText(levelCfg.name)))
	else
		ClientTextUtils.setText(self.view.txtNumUText, string.format("%d%s", 0, pg.getGameString("TOWER_ROGUE_FLOOR_NAME")))
	end

	self.view.uIPbTowerFinalUComponent:TryChangePage("EmptyReward", self.view.listItemUList.itemCount == 0 and 1 or 0)
end

function TowerFinalCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function TowerFinalCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TowerFinalCtrl:onShow()
	return
end

function TowerFinalCtrl:onHide()
	return
end

return TowerFinalCtrl
