-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Spectate\\Component\\SpectateTeamInfoComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local SpectateTeamInfoComponent = Class.LightClass("SpectateTeamInfoComponent", UIComponent)
local TeamUIComponent = require("Guis.Panels.HudV2.BaseComponent.TeamUIComponent")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")

SpectateTeamInfoComponent.messages = {
	[MessageName.TEAM_MATCHED_STATUS_CHANGE] = {
		"onTeamMatchedStatusChange",
		true
	},
	[MessageName.EGG_MATCH_STATE_CHANGE] = {
		"onTeamMatchedStatusChange",
		true
	},
	[MessageName.SYNC_TEAM_INFO] = {
		"refreshTeamInfo",
		true
	},
	[MessageName.TEAM_ENTER_DUNGEON] = {
		"refreshTeamInfo",
		true
	},
	[MessageName.TEAM_PET_HP_CHANGED] = {
		"onTeamPetHpChanged",
		true
	},
	[MessageName.TEAM_PET_MAX_HP_CHANGED] = {
		"onTeamPetMaxHpChanged",
		true
	},
	[MessageName.CUR_COMBAT_PET_CHANGED] = {
		"onCurCombatPetChanged",
		true
	},
	[MessageName.SPACE_FOLLOW_UPDATE] = {
		"onSpaceFollowInfoChanged",
		true
	},
	[MessageName.GRAB_EGG_DUNGEON_TEAM_READY] = {
		"onGrabEggTeamReady",
		true
	},
	[MessageName.TEAM_PLAYER_STATE_CHANGED] = {
		"onTeamMemberLifeStateChanged",
		true
	},
	[MessageName.TEAM_PLAYER_HP_CHANGED] = {
		"onTeamMemberHpChanged",
		true
	},
	[MessageName.TEAM_PLAYER_MAX_HP_CHANGED] = {
		"onTeamMemberMaxHpChanged",
		true
	}
}

function SpectateTeamInfoComponent:ctor(ctrl)
	UIComponent.ctor(self, ctrl)
end

function SpectateTeamInfoComponent:initView()
	self.view.teamPanelUContainer:LoadDefaultUrlManually(function(widget)
		self.teamInfoComponent = TeamUIComponent.new(self, self.view.teamPanelUContainer.content.transform, {
			needLoadRes = false,
			compName = HudSplicingCfg.componentName.team
		})

		self:onTeamMatchedStatusChange()
		self:refreshTeamInfo()
	end)
end

function SpectateTeamInfoComponent:onTeamMatchedStatusChange()
	if self.teamInfoComponent then
		self.teamInfoComponent:onTeamMatchedStatusChange()
	end
end

function SpectateTeamInfoComponent:refreshTeamInfo(param)
	if self.teamInfoComponent then
		self.teamInfoComponent:onTeamInfoChanged()
	end
end

function SpectateTeamInfoComponent:onTeamPetHpChanged(info)
	if self.teamInfoComponent then
		self.teamInfoComponent:onTeamPetHpChanged(info)
	end
end

function SpectateTeamInfoComponent:onTeamPetMaxHpChanged(info)
	if self.teamInfoComponent then
		self.teamInfoComponent:onTeamPetMaxHpChanged(info)
	end
end

function SpectateTeamInfoComponent:onCurCombatPetChanged(info)
	if self.teamInfoComponent then
		self.teamInfoComponent:onCurCombatPetChanged(info)
	end
end

function SpectateTeamInfoComponent:onSpaceFollowInfoChanged(info)
	if self.teamInfoComponent then
		self.teamInfoComponent:refreshTeamInfo()
	end
end

function SpectateTeamInfoComponent:setSceneType()
	return
end

function SpectateTeamInfoComponent:onGrabEggTeamReady(teamInfo)
	if self.teamInfoComponent then
		self.teamInfoComponent.eggBattleExtraTeamInfo = teamInfo

		self.teamInfoComponent:onTeamInfoReady()
	end
end

function SpectateTeamInfoComponent:onTeamInfoChanged()
	if self.teamInfoComponent then
		self.teamInfoComponent:onTeamInfoChanged()
	end
end

function SpectateTeamInfoComponent:onTeamMemberLifeStateChanged(info)
	if self.teamInfoComponent then
		self.teamInfoComponent:refreshMemberState(info)
	end
end

function SpectateTeamInfoComponent:onTeamMemberHpChanged(info)
	if self.teamInfoComponent then
		self.teamInfoComponent:refreshMemberHp(info)
	end
end

function SpectateTeamInfoComponent:onTeamMemberMaxHpChanged(info)
	if self.teamInfoComponent then
		self.teamInfoComponent:refreshMemberMaxHp(info)
	end
end

return SpectateTeamInfoComponent
