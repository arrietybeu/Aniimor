-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemPlayerComponentDefs.lua

local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local TopLogoBubbleComponent = require("Guis.Panels.TopLogo.Component.TopLogoBubbleComponent")
local TopLogoCombatComponent = require("Guis.Panels.TopLogo.Component.TopLogoCombatComponent")
local TopLogoNpcComponent = require("Guis.Panels.TopLogo.Component.TopLogoNpcComponent")
local TopLogoTeamSpeechComponent = require("Guis.Panels.TopLogo.Component.TopLogoTeamSpeechComponent")
local TopLogoPetExchangeComponent = require("Guis.Panels.TopLogo.Component.TopLogoPetExchangeComponent")
local TopLogoSocialComponent = require("Guis.Panels.TopLogo.Component.TopLogoSocialComponent")
local TopLogoTeamMateStateComponent = require("Guis.Panels.TopLogo.Component.TopLogoTeamMateStateComponent")
local TopLogoChatComponent = require("Guis.Panels.TopLogo.Component.TopLogoChatComponent")
local TopLogoPlayerChatComponent = require("Guis.Panels.TopLogo.Component.TopLogoPlayerChatComponent")
local TopLogoSpaceFollowComponent = require("Guis.Panels.TopLogo.Component.TopLogoSpaceFollowComponent")
local TopLogoPlayerHubComponent = require("Guis.Panels.TopLogo.Component.TopLogoPlayerHubComponent")
local TopLogoActionStateComponent = require("Guis.Panels.TopLogo.Component.TopLogoActionStateComponent")

local function shouldCreateNpcInitially(item)
	return item.nameState == UIConst.NAME_STATE.DIALOGUE
end

local function shouldCreatePetExchangeInitially(item)
	local entity = item.entity

	return entity ~= nil and not string.isNilOrEmpty(entity.curSocialId)
end

local function shouldCreateTeamMateInitially(item)
	local entity = item.entity

	return entity ~= nil and (TopLogoTeamMateStateComponent.resolveStateFromEntity(entity) ~= nil or entity.callHelpTimer ~= nil)
end

local function shouldCreateActionStateInitially(item)
	local entity = item.entity

	return entity ~= nil and entity.actionState ~= nil and entity.actionState ~= Const.PlayerActionState.None
end

local ordered = {
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.BUBBLE,
		create = function(item)
			return TopLogoBubbleComponent.new(nil, item)
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
		componentName = UIConst.TOPLOGO_COMPONENT.NPC,
		create = function(item)
			local component = TopLogoNpcComponent.new(nil, item)

			component:setVisibleNpcInfo(item.nameState == UIConst.NAME_STATE.DIALOGUE)

			return component
		end,
		shouldCreateInitially = shouldCreateNpcInitially
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.TEAM_SPEECH,
		create = function(item)
			return TopLogoTeamSpeechComponent.new(nil, item)
		end
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.PET_EXCHANGE,
		create = function(item)
			return TopLogoPetExchangeComponent.new(nil, item)
		end,
		shouldCreateInitially = shouldCreatePetExchangeInitially
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.SOCIAL,
		create = function(item)
			return TopLogoSocialComponent.new(nil, item)
		end
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.TEAM_MATE,
		create = function(item)
			return TopLogoTeamMateStateComponent.new(nil, item)
		end,
		shouldCreateInitially = shouldCreateTeamMateInitially
	},
	{
		componentName = UIConst.TOPLOGO_COMPONENT.CHAT,
		create = function(item)
			return TopLogoChatComponent.new(nil, item)
		end
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.PLAYER_CHAT,
		create = function(item)
			return TopLogoPlayerChatComponent.new(nil, item)
		end
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.SPACE_FOLLOW,
		create = function(item)
			return TopLogoSpaceFollowComponent.new(nil, item)
		end
	},
	{
		componentName = UIConst.TOPLOGO_COMPONENT.PLAYERHUB,
		create = function(item)
			return TopLogoPlayerHubComponent.new(nil, item)
		end
	},
	{
		lazy = true,
		componentName = UIConst.TOPLOGO_COMPONENT.ACTION_STATE,
		create = function(item)
			return TopLogoActionStateComponent.new(nil, item)
		end,
		shouldCreateInitially = shouldCreateActionStateInitially
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
