-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\RobEggSkillButtonUIComponent.lua

local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AbilityUtils = require("Utils.AbilityUtils")
local AbilityParamData = require("Data.ability_param_data")
local SkillTagData = require("Data.skill_tag_data")
local RobEggSkillButtonUIComponent = Class.LightClass("RobEggSkillButtonUIComponent")

function RobEggSkillButtonUIComponent:ctor(uContainer)
	self.uContainer = uContainer
	self.skillId = nil
	self.externalVisible = true
	self.countDown = nil
end

function RobEggSkillButtonUIComponent:setSkillId(skillId)
	if ToBool(skillId) then
		self.skillId = skillId
	else
		self.skillId = nil
	end

	self:refresh()
end

function RobEggSkillButtonUIComponent:setExternalVisible(visible)
	self.externalVisible = visible and true or false

	self:refresh()
end

function RobEggSkillButtonUIComponent:refresh()
	if IsNil(self.uContainer) then
		return
	end

	local visible = self.externalVisible and self.skillId ~= nil

	self.uContainer.ignoreLayout = not visible

	LuaUIUtils.setUIVisible(self.uContainer, visible)

	if not visible then
		return
	end

	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(function()
			self:render()
		end)
	else
		self:render()
	end
end

function RobEggSkillButtonUIComponent:render()
	local content = self.uContainer.content

	if IsNil(content) then
		return
	end

	if not self.skillId then
		return
	end

	local objRef = content:GetComponent("ObjectReference")

	self.specialUButton = objRef:GetRefValue("specialUButton")

	local iconUImage = objRef:GetRefValue("iconUImage")
	local txtNameUText = objRef:GetRefValue("txtNameUText")
	local btnNormalKeyBindingPro = objRef:GetRefValue("btnNormalKeyBindingPro")
	local keyHotKeyContent = objRef:GetRefValue("keyHotKeyContent")

	self.countDown = objRef:GetRefValue("countDown")

	local abilityParamData = AbilityParamData[self.skillId] or {}

	iconUImage.url = abilityParamData.icon or ""

	local tags = abilityParamData.tags or {}
	local mainTag = tags[1]
	local tagData = mainTag and SkillTagData[mainTag]

	ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(tagData and tagData.tagName or ""))

	local actionPath = "Hud/EggChipSkill"

	if btnNormalKeyBindingPro then
		btnNormalKeyBindingPro.actionPath = actionPath
	end

	if keyHotKeyContent then
		keyHotKeyContent:SetHotKeyPaths(actionPath)
	end

	if self.specialUButton then
		local skillId = self.skillId

		function self.specialUButton.luaClick()
			local result, reason = pg.me:clientCastAbilityNoTarget(skillId)

			if not result then
				pg.game.controller:showUseSkillFailedMsg(skillId, result, reason)
			end
		end
	end

	self:refreshCD()
end

function RobEggSkillButtonUIComponent:onSkillCdUpdate(abilityId)
	if abilityId ~= self.skillId then
		return
	end

	self:refreshCD()
end

function RobEggSkillButtonUIComponent:refreshCD()
	if not self.countDown or not self.skillId then
		return
	end

	local pawn = pg.me

	if not pawn then
		return
	end

	local ability = pawn:getAbility(self.skillId)

	if ability and ability.cdEndTime then
		local duration = ability.cdEndTime - pawn:getGameTime()
		local cd = AbilityUtils.getAbilityParamCdForUI(self.skillId, pawn)
		local totalDuration = math.max(duration, cd)

		if duration > 0 then
			self.countDown:SetActive(true)
			self.countDown:Play(duration, totalDuration)

			function self.countDown.luaFinished()
				self.countDown:SetActive(false)
				self.specialUButton:TryChangePage("Ready", 1)
			end

			return
		end
	end

	self.countDown:SetActive(false)
end

return RobEggSkillButtonUIComponent
