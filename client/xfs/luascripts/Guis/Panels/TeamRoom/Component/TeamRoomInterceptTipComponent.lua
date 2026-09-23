-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoom\\Component\\TeamRoomInterceptTipComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ItemConst = require("Common.Const.ItemConst")
local PetData = require("Data.pet_data")
local ItemData = require("Data.item_data")
local EggPromptInterceptData = require("Data.egg_prompt_intercept_data")
local ClientUtils = require("Utils.ClientUtils")
local TeamRoomInterceptTipComponent = Class.LightClass("TeamRoomInterceptTipComponent", UIComponent)
local EQUIPMENT_CONFIG_GROUP_ID = 1
local PVP_PARAM_INDEX = 5
local PVE_PARAM_INDEX_BY_HARD_LV = {
	nil,
	nil,
	1,
	2,
	3,
	4
}
local CONFIG_INDEXES_BY_GROUP = {
	{
		1,
		2,
		3,
		4,
		5,
		6
	},
	{
		1
	},
	{
		1
	}
}
local CONFIG_GROUPS_BY_DUNGEON = {
	[Const.ROB_EGG_SCENE_CLIP_ID] = {
		1,
		2,
		3
	},
	[Const.ROB_EGG_SCENE_ID] = {
		3
	}
}
local EQUIP_SLOT_BY_PARAM = {
	ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR,
	ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON
}
local COLOR_BY_IMPORTANCE = {
	[2] = 0,
	[1] = 1
}
local WARNING_TITLE_KEY_BY_COLOR = {
	[0] = "GRAB_EGG_INTERCEPT_TIPS_TITLE_2",
	"GRAB_EGG_INTERCEPT_TIPS_TITLE_1"
}
local INTERCEPT_PROMPT_TITLE_KEY = "GRAB_EGG_INTERCEPT_PROMPT_TITLE_2"
local INTERCEPT_PROMPT_MEMBER_DESC_KEY = "GRAB_EGG_INTERCEPT_PROMPT_MEMBER_DESC_2"
local INTERCEPT_PROMPT_CAPTAIN_DESC_KEY = "GRAB_EGG_INTERCEPT_PROMPT_CAPTAIN_DESC_2"
local INTERCEPT_TYPE = {
	HEALING_PET_MISSING = 5,
	BACKPACK_MISSING = 4,
	EQUIP_DURABILITY_LOW = 3,
	EQUIP_QUALITY_LOW = 2,
	EQUIP_MISSING = 1
}

local function getEquippedItem(context, slotIndex)
	local player = context.player

	if not player or not slotIndex or type(player.getItemFromBagSlotIndex) ~= "function" then
		return nil
	end

	return player:getItemFromBagSlotIndex(slotIndex, ItemConst.INV_TYPE_EQUIP_SLOTS)
end

local function getEquipmentItem(context, config)
	return getEquippedItem(context, EQUIP_SLOT_BY_PARAM[config.Param1])
end

local function getDifficultyThreshold(context, config)
	local params = config.Param2

	if params == nil or context.paramIndex == nil then
		return nil
	end

	return tonumber(params[context.paramIndex])
end

local function getCarriedPetInfoList(model, player)
	local teamInfo = model and model.getTeamInfo and model:getTeamInfo()
	local memberInfo = teamInfo and teamInfo.membersInfo and player and teamInfo.membersInfo[player.uid]

	if memberInfo and memberInfo.petInfoList then
		return memberInfo.petInfoList
	end

	return player and player.getTeamPetInfos and player:getTeamPetInfos() or EMPTY_TABLE
end

local function hasHealingPet(context)
	for _, petInfo in pairs(context.petInfoList) do
		local petConfig = petInfo and PetData[petInfo.templateId]

		if petConfig and petConfig.functionId == UIConst.NEW_PET_BATTLE_TYPE.HEAL then
			return true
		end
	end

	return false
end

local INTERCEPT_CHECKS = {
	[INTERCEPT_TYPE.EQUIP_MISSING] = function(context, config)
		return getEquipmentItem(context, config) == nil
	end,
	[INTERCEPT_TYPE.EQUIP_QUALITY_LOW] = function(context, config)
		local item = getEquipmentItem(context, config)
		local itemConfig = item and ItemData[item.id]
		local quality = itemConfig and tonumber(itemConfig.quality)
		local threshold = getDifficultyThreshold(context, config)

		return quality ~= nil and threshold ~= nil and quality <= threshold
	end,
	[INTERCEPT_TYPE.EQUIP_DURABILITY_LOW] = function(context, config)
		local item = getEquipmentItem(context, config)
		local threshold = getDifficultyThreshold(context, config)

		if not item or type(item.getDurability) ~= "function" or threshold == nil then
			return false
		end

		local durability, maxDurability = item:getDurability()

		if not durability or not maxDurability or maxDurability <= 0 then
			return false
		end

		return threshold >= durability * 100 / maxDurability
	end,
	[INTERCEPT_TYPE.BACKPACK_MISSING] = function(context)
		return getEquippedItem(context, ItemConst.ROB_EGG_EQUIP_SLOT.BAG) == nil
	end,
	[INTERCEPT_TYPE.HEALING_PET_MISSING] = function(context)
		return not hasHealingPet(context)
	end
}

local function buildWarningData(groupId, configIndex, config)
	local color = COLOR_BY_IMPORTANCE[config.importance] or 0

	return {
		id = string.format("egg_prompt_intercept_%d_%d", groupId, configIndex),
		icon = config.icon or "",
		color = color,
		title = pg.getGameString(WARNING_TITLE_KEY_BY_COLOR[color]),
		content = config.interceptDesc and pg.getLocalizationText(config.interceptDesc) or ""
	}
end

TeamRoomInterceptTipComponent.messages = {
	[MessageName.SYNC_TEAM_INFO] = {
		"refreshWarningList",
		true
	},
	[MessageName.MODIFY_PET_FORMATION] = {
		"refreshWarningList",
		true
	},
	[MessageName.GRAB_EGG_MY_BAG_EQUIP_SLOT] = {
		"refreshWarningList",
		true
	},
	[MessageName.GRAB_EGG_EQUIP_PROP] = {
		"refreshWarningList",
		true
	}
}

function TeamRoomInterceptTipComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.warningList = objectReference:GetRefValue("warningList")
end

function TeamRoomInterceptTipComponent:registerObjects()
	function self.warningList.luaRenderItem(button, index, data)
		self:renderWarningItem(button, index, data)
	end
end

function TeamRoomInterceptTipComponent:initView()
	self:refreshWarningList()
end

function TeamRoomInterceptTipComponent:setWarningList(dataList)
	self.warningDataList = dataList or EMPTY_TABLE

	self.warningList:SetList(self.warningDataList)
end

function TeamRoomInterceptTipComponent:hasWarning()
	return self.warningDataList ~= nil and #self.warningDataList > 0
end

function TeamRoomInterceptTipComponent:tryShowConfirm(isCaptain, confirmCallback)
	if not self:hasWarning() then
		return false
	end

	local descKey = isCaptain and INTERCEPT_PROMPT_CAPTAIN_DESC_KEY or INTERCEPT_PROMPT_MEMBER_DESC_KEY

	pg.global.showConfirmMsgRaw(pg.getGameString(INTERCEPT_PROMPT_TITLE_KEY), pg.getGameString(descKey), confirmCallback, nil)

	return true
end

function TeamRoomInterceptTipComponent:buildWarningContext()
	local player = pg and pg.me
	local petInfoList = getCarriedPetInfoList(self.model, player)
	local dungeonId

	if self.ctrl and self.ctrl.getTeamRoomFrameDungeonId then
		dungeonId = self.ctrl:getTeamRoomFrameDungeonId()
	end

	local hardLv

	if self.ctrl and self.ctrl.getTeamRoomFrameHardLv then
		hardLv = tonumber(self.ctrl:getTeamRoomFrameHardLv())
	end

	local paramIndex = dungeonId == Const.ROB_EGG_SCENE_ID and PVP_PARAM_INDEX or PVE_PARAM_INDEX_BY_HARD_LV[hardLv]

	return {
		player = player,
		dungeonId = dungeonId,
		hardLv = hardLv,
		paramIndex = paramIndex,
		petInfoList = petInfoList,
		isGrabEggRoom = self.model and self.model.isGrabEggsEquipDungeon and self.model:isGrabEggsEquipDungeon(dungeonId) or false
	}
end

function TeamRoomInterceptTipComponent:evaluateWarningRules(context)
	local warningList = {}
	local groupIds = CONFIG_GROUPS_BY_DUNGEON[context.dungeonId] or EMPTY_TABLE

	for _, groupId in ipairs(groupIds) do
		local configGroup = EggPromptInterceptData[groupId] or EMPTY_TABLE
		local configIndexes = CONFIG_INDEXES_BY_GROUP[groupId] or EMPTY_TABLE
		local combinedWarningData
		local combinedContents = {}

		for _, configIndex in ipairs(configIndexes) do
			local config = configGroup[configIndex]
			local check = config and INTERCEPT_CHECKS[config.interceptType]

			if type(check) == "function" then
				local matched = false
				local checkSuccess = ClientUtils.tryWithLogError(function()
					matched = check(context, config) == true
				end)

				if checkSuccess and matched then
					local warningData
					local buildSuccess = ClientUtils.tryWithLogError(function()
						warningData = buildWarningData(groupId, configIndex, config)
					end)

					if buildSuccess and type(warningData) == "table" then
						if groupId == EQUIPMENT_CONFIG_GROUP_ID then
							combinedWarningData = combinedWarningData or warningData
							combinedContents[#combinedContents + 1] = warningData.content
						else
							warningList[#warningList + 1] = warningData
						end
					end
				end
			end
		end

		if combinedWarningData then
			combinedWarningData.id = string.format("egg_prompt_intercept_%d", groupId)
			combinedWarningData.content = table.concat(combinedContents, "\n")
			warningList[#warningList + 1] = combinedWarningData
		end
	end

	return warningList
end

function TeamRoomInterceptTipComponent:refreshWarningList()
	local context = self:buildWarningContext()
	local isGrabEggRoom = context.isGrabEggRoom == true

	self.warningList.gameObject:SetActiveEx(isGrabEggRoom)

	if not isGrabEggRoom then
		self:setWarningList()

		return
	end

	self:setWarningList(self:evaluateWarningRules(context))
end

function TeamRoomInterceptTipComponent:renderWarningItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local icon = objectReference:GetRefValue("icon")

	icon.url = data.icon or ""

	local color = data.color == 1 and 1 or 0

	button:TryChangePage("Color", color)

	function button.luaRenderTooltip(_, tooltip)
		local tooltipObjectReference = tooltip:GetComponent("ObjectReference")
		local title = tooltipObjectReference:GetRefValue("title")
		local txtNameUSDFText = tooltipObjectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(title, data.title or "")
		ClientTextUtils.setText(txtNameUSDFText, data.content or "")
		tooltip:TryChangePage("Color", color)
	end
end

return TeamRoomInterceptTipComponent
