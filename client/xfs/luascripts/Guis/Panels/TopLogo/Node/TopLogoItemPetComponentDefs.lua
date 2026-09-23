-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemPetComponentDefs.lua

local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local TopLogoAlertComponent = require("Guis.Panels.TopLogo.Component.TopLogoAlertComponent")
local TopLogoBubbleComponent = require("Guis.Panels.TopLogo.Component.TopLogoBubbleComponent")
local TopLogoPetChatComponent = require("Guis.Panels.TopLogo.Component.TopLogoPetChatComponent")
local TopLogoCombatComponent = require("Guis.Panels.TopLogo.Component.TopLogoCombatComponent")
local TopLogoPhotoComponent = require("Guis.Panels.TopLogo.Component.TopLogoPhotoComponent")
local TopLogoQuestComponent = require("Guis.Panels.TopLogo.Component.TopLogoQuestComponent")
local TopLogoChatComponent = require("Guis.Panels.TopLogo.Component.TopLogoChatComponent")
local TopLogoNpcComponent = require("Guis.Panels.TopLogo.Component.TopLogoNpcComponent")
local TopLogoWorkStateComponent = require("Guis.Panels.TopLogo.Component.TopLogoWorkStateComponent")
local TopLogoIconComponent = require("Guis.Panels.TopLogo.Component.TopLogoIconComponent")
local TopLogoVlogComponent = require("Guis.Panels.TopLogo.Component.TopLogoVlogComponent")
local TopLogoPetLevelUpComponent = require("Guis.Panels.TopLogo.Component.TopLogoPetLevelUpComponent")
local TopLogoFocusComponent = require("Guis.Panels.TopLogo.Component.TopLogoFocusComponent")
local TopLogoSocialComponent = require("Guis.Panels.TopLogo.Component.TopLogoSocialComponent")
local TopLogoPlayerChatComponent = require("Guis.Panels.TopLogo.Component.TopLogoPlayerChatComponent")
local TopLogoSpaceFollowComponent = require("Guis.Panels.TopLogo.Component.TopLogoSpaceFollowComponent")
local TopLogoTeamSpeechComponent = require("Guis.Panels.TopLogo.Component.TopLogoTeamSpeechComponent")
local TopLogoActionStateComponent = require("Guis.Panels.TopLogo.Component.TopLogoActionStateComponent")
local TopLogoPlayerHubComponent = require("Guis.Panels.TopLogo.Component.TopLogoPlayerHubComponent")
local TopLogoPetWaterStorageComponent = require("Guis.Panels.TopLogo.Component.TopLogoPetWaterStorageComponent")
local TopLogoBattleRoomComponent = require("Guis.Panels.TopLogo.Component.TopLogoBattleRoomComponent")

local function isHomePet(item)
	return Utils.isHomePet(item.entity)
end

local function isNpcEligible(item)
	local space = pg and pg.space

	return not isHomePet(item) or Utils.isHomeCamp(space and space.spaceType)
end

local function isPlayerPet(item)
	return Utils.isPlayerPet(item.entity)
end

local function isIconEligible(item)
	local entity = item.entity

	return Utils.isPuppet(entity) or Utils.isPlayerPet(entity)
end

local function isVlogEligible(item)
	local entity = item.entity

	return Utils.isPuppet(entity) or Utils.isVirtualPuppet(entity)
end

local function isBattleRoomEligible(item)
	local entity = item.entity
	local configData = entity and entity.getConfigData and entity:getConfigData()

	return configData ~= nil and configData.npcDuelId ~= nil and configData.npcDuelId > 0
end

local function shouldCreateIconInitially(item)
	local entity = item.entity

	return entity ~= nil and entity.getTopLogoIcon ~= nil and entity:getTopLogoIcon() ~= nil
end

local function shouldCreateVlogInitially(item)
	local topLogoData = item.entity and item.entity.topLogoData
	local vlogInfo = topLogoData and topLogoData.vlogInfo

	return vlogInfo ~= nil and vlogInfo.enable == true
end

local function shouldCreateQuestInitially(item)
	local entity = item.entity

	return entity ~= nil and entity.hasTopLogoQuestData ~= nil and entity:hasTopLogoQuestData()
end

local ordered = {
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.ALERT,
		create = function(item)
			return TopLogoAlertComponent.new(nil, item)
		end
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.BUBBLE,
		create = function(item)
			return TopLogoBubbleComponent.new(nil, item)
		end
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.PET_CHAT,
		create = function(item)
			return TopLogoPetChatComponent.new(nil, item)
		end
	},
	{
		componentName = UIConst.TOPLOGO_COMPONENT.COMBAT,
		create = function(item)
			return TopLogoCombatComponent.new(nil, item)
		end
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.PHOTO,
		create = function(item)
			return TopLogoPhotoComponent.new(nil, item)
		end
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.QUEST,
		create = function(item)
			return TopLogoQuestComponent.new(nil, item)
		end,
		shouldCreateInitially = shouldCreateQuestInitially
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.CHAT,
		create = function(item)
			return TopLogoChatComponent.new(nil, item)
		end
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.NPC,
		create = function(item)
			return TopLogoNpcComponent.new(nil, item)
		end,
		isEligible = isNpcEligible
	},
	{
		componentName = UIConst.TOPLOGO_COMPONENT.WORK_STATE,
		create = function(item)
			return TopLogoWorkStateComponent.new(nil, item)
		end,
		isEligible = isHomePet
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.ICON,
		create = function(item)
			return TopLogoIconComponent.new(nil, item)
		end,
		isEligible = isIconEligible,
		shouldCreateInitially = shouldCreateIconInitially
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.VLOG,
		create = function(item)
			return TopLogoVlogComponent.new(nil, item, true)
		end,
		isEligible = isVlogEligible,
		shouldCreateInitially = shouldCreateVlogInitially
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.PET_LEVEL_UP,
		create = function(item)
			return TopLogoPetLevelUpComponent.new(nil, item)
		end,
		isEligible = isPlayerPet
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.FOCUS,
		create = function(item)
			return TopLogoFocusComponent.new(nil, item)
		end,
		isEligible = isPlayerPet
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.SOCIAL,
		create = function(item)
			return TopLogoSocialComponent.new(nil, item)
		end,
		isEligible = isPlayerPet
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.PLAYER_CHAT,
		create = function(item)
			return TopLogoPlayerChatComponent.new(nil, item)
		end,
		isEligible = isPlayerPet
	},
	{
		componentName = UIConst.TOPLOGO_COMPONENT.SPACE_FOLLOW,
		create = function(item)
			return TopLogoSpaceFollowComponent.new(nil, item)
		end,
		isEligible = isPlayerPet
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.TEAM_SPEECH,
		create = function(item)
			return TopLogoTeamSpeechComponent.new(item.playerVoiceContainer, item)
		end,
		isEligible = isPlayerPet
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.ACTION_STATE,
		create = function(item)
			return TopLogoActionStateComponent.new(nil, item)
		end,
		isEligible = isPlayerPet
	},
	{
		componentName = UIConst.TOPLOGO_COMPONENT.PLAYERHUB,
		create = function(item)
			return TopLogoPlayerHubComponent.new(nil, item)
		end,
		isEligible = isPlayerPet
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.WATER_STORAGE,
		create = function(item)
			return TopLogoPetWaterStorageComponent.new(nil, item)
		end,
		isEligible = isPlayerPet
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.BATTLE_ROOM,
		create = function(item)
			return TopLogoBattleRoomComponent.new(nil, item)
		end,
		isEligible = isBattleRoomEligible,
		shouldCreateInitially = function(_item)
			return true
		end
	}
}
local byName = {}

for _, definition in ipairs(ordered) do
	byName[definition.componentName] = definition
end

return {
	ordered = ordered,
	byName = byName
}
