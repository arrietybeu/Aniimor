-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerSettlement\\TowerSettlementCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerSettlementCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TowerSettlementCtrl = Class.LightClass("TowerSettlementCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local RogueTransformData = require("Data.rogue_transform_data")
local Const = require("Common.Const.Const")
local RandomBuffSeriesName = require("Data.random_buff_series_name")
local RogueUtils = require("Utils.RogueUtils")
local UIConst = require("Const.UIConst")
local RoguelikeData = require("Data.roguelike_data")
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local RogueWeekBossRewardData = require("Data.rogue_week_boss_reward_data")
local PetData = require("Data.pet_data")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AbilityParamData = require("Data.ability_param_data")
local SysConfigData = require("Data.sys_config_data")
local ClientUtils = require("Utils.ClientUtils")
local ItemData = require("Data.item_data")
local EventConst = require("Common.Const.EventConst")

TowerSettlementCtrl.messages = {
	[MessageName.ROGUE_RECV_COMBAT_RECORD] = {
		"refreshBattleData",
		true
	}
}
TowerSettlementCtrl.CombatDataType = {
	Equipment = "RogueBossSkill",
	Boss = "BossEquipmentBuff",
	DPS = UIConst.NEW_PET_BATTLE_TYPE.DPS,
	ENERGY = UIConst.NEW_PET_BATTLE_TYPE.ENERGY,
	HEAL = UIConst.NEW_PET_BATTLE_TYPE.HEAL
}

function TowerSettlementCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.param = info

	self:initUI()
end

function TowerSettlementCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
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

function TowerSettlementCtrl:refreshBattleData(param)
	local battleData = self:parseBattleData(param.battleData)

	for index = 1, 5 do
		local item = battleData[index]

		if item then
			local isBossOrEquip = item.type == TowerSettlementCtrl.CombatDataType.Boss or item.type == TowerSettlementCtrl.CombatDataType.Equipment
			local isEquip = item.type == TowerSettlementCtrl.CombatDataType.Equipment

			self.view["scoreUComponent" .. index]:TryChangePage("State", 0)

			if index == 1 then
				self.view.scoreUComponent1:TryChangePage("Status", self.hasFinish and 0 or 1)
				self.view.mvpPetUImage:SetActive(not isEquip)

				if not isEquip then
					self.view.mvpPetUImage.url = item.icon
				end

				self.view.equipmentUImage1:SetActive(isEquip)

				if isEquip then
					self.view.equipmentUImage1.url = item.icon
				end

				ClientTextUtils.setText(self.view.mvpPetNameUBaseText, item.name)
				ClientTextUtils.setText(self.view.mvpLvUBaseText, "lv." .. item.level)
				ClientTextUtils.setText(self.view.mvpAttackUBaseText, string.format("%d%%", item.attack / self.totalAttack * 100))
				ClientTextUtils.setText(self.view.mvpDefUBaseText, string.format("%d%%", item.def / self.totalDef * 100))
				ClientTextUtils.setText(self.view.mvpHealUBaseText, string.format("%d%%", item.heal / self.totalHeal * 100))
				self.view.mvpLvUBaseText:SetActive(not isBossOrEquip)
			elseif index <= 5 then
				self.view["petUImage" .. index]:SetActive(not isEquip)

				if not isEquip then
					self.view["petUImage" .. index].url = item.icon
				end

				self.view["equipmentUImage" .. index]:SetActive(isEquip)

				if isEquip then
					self.view["equipmentUImage" .. index].url = item.icon
				end

				ClientTextUtils.setText(self.view["petNameUBaseText" .. index], item.name)
				ClientTextUtils.setText(self.view["petLvUBaseText" .. index], "lv." .. item.level)
				self.view["petLvUBaseText" .. index]:SetActive(not isBossOrEquip)
			end
		else
			self.view["scoreUComponent" .. index]:TryChangePage("State", 1)
		end
	end
end

function TowerSettlementCtrl:initUI()
	self:clearRogueInfo()

	local difficultyCfg = RogueDifficultyData[pg.me.curRogueLevel]

	if not difficultyCfg then
		return
	end

	if difficultyCfg.battleResultBackground then
		self.view.backgroundUImage.url = difficultyCfg.battleResultBackground
	end

	pg.me:getRogueBattleRecord()

	local hasFinish = pg.me.lastRoguePassLayer == difficultyCfg.roguelikeIDEnd

	self.view.rootUComponent:TryChangePage("Status", hasFinish and 0 or 1)

	self.hasFinish = hasFinish

	local audio = hasFinish and "SFX_UI_Rouge_SuccessfullyClearedTheLevel" or "SFX_UI_Rouge_ChallengeFailed"

	pg.game.audio:playEvent(audio)

	local equipmentBuffs = {}
	local buffs = pg.me:getRogueBuffs()

	for _, buff in ipairs(buffs) do
		if buff.buffQuality == Const.RogueBuffQuality.Equipment then
			table.insert(equipmentBuffs, buff)
		end
	end

	local maxEquipmentCount = RogueUtils.getCurRogueLevelMaxEquipmentCount()

	for i = 1, maxEquipmentCount do
		if not equipmentBuffs[i] then
			equipmentBuffs[i] = {
				isEmpty = true
			}
		end
	end

	self.equipmentBuffs = equipmentBuffs

	local battleTime = LuaUIUtils.formatDuration(pg.me.rogueLevelChallengeTime)
	local timeText = string.gsub(pg.getGameString("TOWER_SETTLEMENT_BATTLE_TIME"), "{0}", battleTime)

	ClientTextUtils.setText(self.view.timeUBaseText1, timeText)
	ClientTextUtils.setText(self.view.timeUBaseText2, timeText)

	local levelName = pg.getLocalizationText(difficultyCfg.interfaceName)

	if hasFinish then
		ClientTextUtils.setText(self.view.levelNameSuccUBaseText, levelName)
	else
		ClientTextUtils.setText(self.view.levelNameFailedUBaseText, levelName)
	end

	local coinCount = pg.me.rogueCombatData[AbilityConst.ROGUE_BATTLE_DATA_KEY.ACCUMULATED_COIN] or 0

	ClientTextUtils.setText(self.view.coinNumberUBaseText, math.floor(coinCount))

	local hasRogueSkill = pg.me.rogueUltimateSeries >= 0

	if hasRogueSkill then
		local seriesCfg = RogueTransformData[pg.me.rogueUltimateSeries]

		self:renderBuffButton(self.view.bossBuffUButton, {
			status = 0,
			progress = pg.me.rogueUltimateLevel,
			bossIcon = seriesCfg.transformIcon or ""
		})

		function self.view.bossBuffUButton.luaClick()
			return
		end
	else
		self:renderBuffButton(self.view.bossBuffUButton, {
			status = 2
		})
	end

	function self.view.equipmentUList.luaRenderItem(button, index, data)
		if not data.isEmpty then
			self:renderBuffButton(button, {
				status = 1,
				progress = data.buffCount,
				equipmentIcon = data.buffIcon,
				buffTagIcon = data.buffTagIcon
			})
		else
			self:renderBuffButton(button, {
				status = 2
			})
		end
	end

	function self.view.equipmentUList.luaClick(button, data)
		if not data.isEmpty then
			pg.global.ui:open(UIConst.UI_ID_TOWER_BUFF_DETAIL, {
				buffSeries = data.buffSeries
			})
		end
	end

	self.view.equipmentUList:SetList(equipmentBuffs)

	function self.view.listBuffUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local txtUBaseText = objectReference:GetRefValue("txtUBaseText")
		local remainderUBaseText = objectReference:GetRefValue("remainderUBaseText")

		button:TryChangePage("State", data.state)

		if data.state == 0 then
			iconUImage.url = data.icon

			ClientTextUtils.setText(txtUBaseText, data.count)
		elseif data.state == 1 then
			ClientTextUtils.setText(remainderUBaseText, "+" .. data.count)
		end
	end

	function self.view.listBuffUList.luaClick(button, data)
		if data.state ~= 2 then
			pg.global.ui:open(UIConst.UI_ID_TOWER_BUFF_DETAIL, {
				buffSeries = data.type
			})
		end
	end

	self.view.listBuffUList:SetList(self:getSettlementBuffTypes())

	local dropData = {}
	local levelCfg = RoguelikeData[pg.me.lastRoguePassLayer]
	local haveFirstReward = false

	if levelCfg then
		local hasGetFirst = pg.me.rogueSettlementCnt[pg.me.lastRoguePassLayer] and pg.me.rogueSettlementCnt[pg.me.lastRoguePassLayer] > 0

		if not hasGetFirst and self.hasFinish and levelCfg.firstSettlementRewardId then
			table.insert(dropData, {
				firstReward = true,
				dropId = levelCfg.firstSettlementRewardId
			})

			haveFirstReward = true
		end

		if levelCfg.settlementRewardId then
			table.insert(dropData, {
				dropId = levelCfg.settlementRewardId
			})
		end

		self.view.rootUComponent:TryChangePage("State", haveFirstReward and 0 or 1)
	else
		self.view.rootUComponent:TryChangePage("State", 1)
	end

	LuaUIUtils.setRewardListByDropIds(self.view.listRewardUList, dropData)

	local exchangeReward = {}

	for index, value in pairs(pg.me.rogueExchangeRewardInfo) do
		local itemCfg = ItemData[index]

		if itemCfg then
			table.insert(exchangeReward, {
				tIndex = 0,
				type = 0,
				num = value,
				id = index,
				quality = itemCfg.quality
			})
		end
	end

	local isRewardUp = ClientActivityUtils.isRogueRewardUp()

	ClientActivityUtils.initRogueRewardUpWidget(self.view.doubleRewardUWidget)

	for index, value in pairs(pg.me.upRogueExchangeRewardInfo) do
		local itemCfg = ItemData[index]

		if itemCfg then
			table.insert(exchangeReward, {
				tIndex = 0,
				type = 0,
				num = value,
				id = index,
				quality = itemCfg.quality,
				isExtra = isRewardUp
			})
		end
	end

	table.sort(exchangeReward, function(a, b)
		return a.quality > b.quality
	end)

	for _, element in ipairs(exchangeReward) do
		self.view.listRewardUList:AddElement(element)
	end

	local count = self.view.listRewardUList.itemData.Count

	while count < 8 do
		self.view.listRewardUList:AddElement({
			tIndex = 1
		})

		count = count + 1
	end

	local bossKillCount = pg.me.rogueLevelBossKillCount or 0
	local totalKillCount = pg.me.rogueWeeklyBossKillCount

	ClientTextUtils.setText(self.view.killCountUBaseText, "+", bossKillCount)
	self.view.maxUWidget:SetActive(totalKillCount >= #RogueWeekBossRewardData)

	if hasFinish and pg.global and pg.global.eventEmitter and pg.me then
		pg.global.eventEmitter:emit(EventConst.PLATFORM_ACHIEVEMENT_ROGUE_PASSED, {
			levelId = pg.me.curRogueLevel
		})
	end
end

function TowerSettlementCtrl:getSettlementBuffTypes()
	local data = {}

	for i = 0, #RandomBuffSeriesName do
		if RandomBuffSeriesName[i] then
			local count = RogueUtils.getRogueBuffCountBySeries(i)

			if count > 0 then
				local seriesCfg = RandomBuffSeriesName[i]

				table.insert(data, {
					state = 0,
					type = i,
					icon = seriesCfg.buffSeriesIcon,
					count = RogueUtils.getRogueBuffCountBySeries(i)
				})
			end
		end
	end

	if #data > 7 then
		local count = 0

		while #data > 6 do
			count = count + table.remove(data).count
		end

		table.insert(data, {
			state = 1,
			count = count
		})
	end

	while #data < 7 do
		table.insert(data, {
			state = 2
		})
	end

	return data
end

function TowerSettlementCtrl:renderBuffButton(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")
	local imgBossUImage = objectReference:GetRefValue("imgBossUImage")
	local iconEquipmentUImage = objectReference:GetRefValue("iconEquipmentUImage")
	local buffSeriesIconUImage = objectReference:GetRefValue("buffSeriesIconUImage")
	local bgSkillIUWidget = objectReference:GetRefValue("bgSkillIUWidget")

	rootUComponent:TryChangePage("Status", data.status)
	rootUComponent:TryChangePage("ProgressBar", data.progress)

	if data.status == 0 then
		imgBossUImage.url = data.bossIcon
	elseif data.status == 1 then
		iconEquipmentUImage.url = data.equipmentIcon

		bgSkillIUWidget:SetActive(data.buffTagIcon ~= nil and data.buffTagIcon ~= "")

		if data.buffTagIcon then
			buffSeriesIconUImage.url = data.buffTagIcon
		end
	end
end

function TowerSettlementCtrl:parseBattleData(battleData)
	local adjustRateCommon = SysConfigData.ROGUE_MVP_COMMON_COEFFICIENT
	local adjustRateDPS = SysConfigData.ROGUE_MVP_DPS_COEFFICIENT
	local adjustRateTank = SysConfigData.ROGUE_MVP_TANK_COEFFICIENT
	local adjustRateHeal = SysConfigData.ROGUE_MVP_HEAL_COEFFICIENT
	local adjustRateBoss = SysConfigData.ROGUE_MVP_TRANSFORM_COEFFICIENT
	local adjustRateEquipment = SysConfigData.ROGUE_MVP_EQUIPMENT_COEFFICIENT
	local data = {}
	local totalAttack = 0
	local totalDef = 0
	local totalHeal = 0
	local battlePetIds = pg.me.selectRoguePets or {}

	for petId, index in pairs(battlePetIds) do
		local pet = pg.me.pets[petId]

		if pet then
			local petInfo = {}

			petInfo.name = pg.getLocalizationText(LuaUIUtils.getPetName(pet.id))
			petInfo.icon = LuaUIUtils.getPetIcon(PetData[pet.templateId].iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK, pet.label, pet.gender)
			petInfo.level = pet.level
			petInfo.type = PetData[pet.templateId].functionId
			petInfo.attack = 0
			petInfo.def = 0
			petInfo.heal = 0

			if battleData.pet[petId] then
				petInfo.attack = battleData.pet[petId].damage
				petInfo.heal = battleData.pet[petId].heal
				petInfo.def = battleData.pet[petId].takenDamage
			end

			totalAttack = totalAttack + petInfo.attack
			totalDef = totalDef + petInfo.def
			totalHeal = totalHeal + petInfo.heal

			table.insert(data, petInfo)
		end
	end

	if pg.me.rogueUltimateSeries >= 0 then
		local abilityId = RogueUtils.getUltimatePetTransformAbilityId()
		local templateIdStr = tostring(RogueUtils.getUltimatePetTemplateID())
		local abilityParamId = AbilityUtils.getAbilityParamId(abilityId)
		local abilityCfg = AbilityParamData[abilityParamId]
		local seriesCfg = RogueTransformData[pg.me.rogueUltimateSeries]
		local bossSkillInfo = {}

		bossSkillInfo.name = pg.getLocalizationText(abilityCfg.name)
		bossSkillInfo.icon = seriesCfg.transformIcon or abilityCfg.icon
		bossSkillInfo.level = pg.me.rogueUltimateLevel
		bossSkillInfo.type = TowerSettlementCtrl.CombatDataType.Boss
		bossSkillInfo.attack = 0
		bossSkillInfo.def = 0
		bossSkillInfo.heal = 0

		if battleData.tempPet[templateIdStr] then
			bossSkillInfo.attack = battleData.tempPet[templateIdStr].damage
			bossSkillInfo.def = battleData.tempPet[templateIdStr].takenDamage
			bossSkillInfo.heal = battleData.tempPet[templateIdStr].heal
		end

		totalAttack = totalAttack + bossSkillInfo.attack
		totalDef = totalDef + bossSkillInfo.def
		totalHeal = totalHeal + bossSkillInfo.heal

		table.insert(data, bossSkillInfo)
	end

	local maxEquipmentCount = RogueUtils.getCurRogueLevelMaxEquipmentCount()

	for i = 1, maxEquipmentCount do
		if self.equipmentBuffs[i] and not self.equipmentBuffs[i].isEmpty then
			local equipmentInfo = {}

			equipmentInfo.name = pg.getLocalizationText(self.equipmentBuffs[i].buffName)
			equipmentInfo.icon = self.equipmentBuffs[i].buffIcon
			equipmentInfo.level = self.equipmentBuffs[i].buffCount
			equipmentInfo.type = TowerSettlementCtrl.CombatDataType.Equipment
			equipmentInfo.attack = 0
			equipmentInfo.def = 0
			equipmentInfo.heal = 0

			local buffId = tostring(self.equipmentBuffs[i].buffId)

			if battleData.buff[buffId] then
				equipmentInfo.attack = battleData.buff[buffId].damage
				equipmentInfo.def = battleData.buff[buffId].takenDamage
				equipmentInfo.heal = battleData.buff[buffId].heal
			end

			totalAttack = totalAttack + equipmentInfo.attack
			totalDef = totalDef + equipmentInfo.def
			totalHeal = totalHeal + equipmentInfo.heal

			table.insert(data, equipmentInfo)
		end
	end

	totalAttack = math.max(math.floor(totalAttack), 1)
	totalDef = math.max(math.floor(totalDef), 1)
	totalHeal = math.max(math.floor(totalHeal), 1)
	self.totalAttack = totalAttack
	self.totalDef = totalDef
	self.totalHeal = totalHeal

	for _, item in ipairs(data) do
		local adjust = {
			1,
			1,
			1
		}

		if string.find(item.type, TowerSettlementCtrl.CombatDataType.DPS) then
			adjust = adjustRateDPS
		elseif item.type == TowerSettlementCtrl.CombatDataType.ENERGY then
			adjust = adjustRateTank
		elseif item.type == TowerSettlementCtrl.CombatDataType.HEAL then
			adjust = adjustRateHeal
		elseif item.type == TowerSettlementCtrl.CombatDataType.Equipment then
			adjust = adjustRateEquipment
		elseif item.type == TowerSettlementCtrl.CombatDataType.Boss then
			adjust = adjustRateBoss
		end

		item.score = math.floor(item.attack) / totalAttack * adjust[1] * adjustRateCommon[1] + math.floor(item.def) / totalDef * adjust[2] * adjustRateCommon[2] + math.floor(item.heal) / totalHeal * adjust[3] * adjustRateCommon[3]
	end

	local function sortFunc(a, b)
		return a.score > b.score
	end

	table.sort(data, sortFunc)

	return data
end

function TowerSettlementCtrl:clearRogueInfo()
	ClientUtils.hideBattleUICountDown()

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_ROG_BUFF_SELECT) then
		pg.global.ui:close(UIConst.UI_ID_ROG_BUFF_SELECT)
	end
end

function TowerSettlementCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if pg.space:isRogueEnv() then
		local hudCtrl = pg.global.ui.hudV2

		if hudCtrl then
			hudCtrl.needOpenTowerMain = true
		end
	end

	pg.me:resetRogue()
end

function TowerSettlementCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TowerSettlementCtrl:onShow()
	return
end

function TowerSettlementCtrl:onHide()
	return
end

return TowerSettlementCtrl
