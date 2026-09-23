-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\AimUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("AimUIComponent")
local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local MessageName = require("Const.MessageName")
local AimUIComponent = Class.LightClass("AimUIComponent", HudBaseComponent)
local AIM_STATE_NONE = 0
local AIM_STATE_SKILL = 1
local AIM_STATE_HOOK_CLAW = 2

AimUIComponent.messages = {
	[MessageName.ENTER_HOOK_SKILL_AIM] = {
		"onEnterHookSkillAim",
		true
	},
	[MessageName.LEAVE_HOOK_SKILL_AIM] = {
		"onLeaveHookSkillAim",
		true
	},
	[MessageName.ENTER_HOOK_NORMAL_STATE] = {
		"onEnterHookNormalState",
		true
	},
	[MessageName.ENTER_HOOK_FOCUS_STATE] = {
		"onEnterHookFocusState",
		true
	}
}

function AimUIComponent:findObjects()
	return
end

function AimUIComponent:initView()
	local objectReference = self.transform:GetComponent("ObjectReference")
	local panelHookAimUContainer = objectReference:GetRefValue("panelHookAimUContainer")

	panelHookAimUContainer:LoadDefaultUrlManually(function(content)
		local panelHookAimReference = content:GetComponent("ObjectReference")

		self.panelHookAimUComponent = panelHookAimReference:GetRefValue("panelHookAimUComponent")
	end)
end

function AimUIComponent:setIsInAim(isInAim, abilityId)
	self.inAimAbilityId = abilityId
	self.isInAim = isInAim

	if NotNil(self.uWidget) then
		self.uWidget:TryChangePage("AimState", isInAim and AIM_STATE_SKILL or AIM_STATE_NONE)
	end
end

function AimUIComponent:onEnterHookSkillAim()
	self.uWidget:TryChangePage("AimState", AIM_STATE_HOOK_CLAW)
end

function AimUIComponent:onLeaveHookSkillAim()
	self.uWidget:TryChangePage("AimState", AIM_STATE_NONE)
end

function AimUIComponent:onEnterHookNormalState()
	self:tryChangeHookStage(0)
end

function AimUIComponent:onEnterHookFocusState()
	self:tryChangeHookStage(1)
end

function AimUIComponent:tryChangeHookStage(stageIdx)
	if not self.panelHookAimUComponent then
		return
	end

	local _, curIndex = self.panelHookAimUComponent:TryGetCurrentPage("stage")
	local pageChange = stageIdx ~= curIndex

	if pageChange then
		self.panelHookAimUComponent:TryChangePage("stage", stageIdx)
	end
end

function AimUIComponent:onDestroy()
	self.panelHookAimUComponent = nil

	HudBaseComponent.onDestroy(self)
end

return AimUIComponent
