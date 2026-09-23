-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SoundGame\\SoundGameView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local vehicleSeatSkillData = require("Data.vehicle_seat_skill_data")
local JUMP_BUTTON_STYLE = 5
local EXIT_BUTTON_STYLE = 6
local SoundGameView = Class.LightClass("SoundGameView", UIView)

function SoundGameView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.perfectAnimation = objectReference:GetRefValue("perfectAnimation")
	self.perfectUWidget = objectReference:GetRefValue("perfectUWidget")
	self.missAnimation = objectReference:GetRefValue("missAnimation")
	self.missUWidget = objectReference:GetRefValue("missUWidget")
	self.interactionUContainer = objectReference:GetRefValue("interactionUContainer")
	self.jumpBtnUButton = objectReference:GetRefValue("jumpBtnUButton")
	self.exitBtnUButton = objectReference:GetRefValue("exitBtnUButton")
end

function SoundGameView:registerObjects()
	if pg.global.ui:runPlatformByMobile() then
		if not self.interactionUContainer:CheckURLLoaded() then
			self.interactionUContainer:LoadDefaultUrlManually(function()
				self:initGamePad()
			end)
		else
			self:initGamePad()
		end

		LuaUIUtils.setUIVisible(self.jumpBtnUButton, false)
		LuaUIUtils.setUIVisible(self.exitBtnUButton, false)
	else
		function self.jumpBtnUButton.luaClick()
			pg.global.ui.soundGame:hit()
		end

		function self.exitBtnUButton.luaClick()
			pg.global.ui.soundGame:closePanel()
		end
	end

	LuaUIUtils.setUIVisible(self.perfectUWidget, false)
	LuaUIUtils.setUIVisible(self.missUWidget, false)
end

function SoundGameView:initGamePad()
	local content = self.interactionUContainer.content
	local skill1 = content:Find("Skill/Skill1")

	self:setSkillInfo(skill1, JUMP_BUTTON_STYLE)

	function skill1.luaClick()
		pg.global.ui.soundGame:hit()
	end

	local skill2 = content:Find("Skill/Skill2")

	LuaUIUtils.setUIVisible(skill2, false)

	local skill3 = content:Find("Skill/Skill3")

	LuaUIUtils.setUIVisible(skill3, false)

	local skillMain = content:Find("Skill/SkillMain")

	LuaUIUtils.setUIVisible(skillMain, false)

	local btnClose = content:Find("Skill/BtnClose")

	btnClose:SetActive(true)

	function btnClose.luaClick()
		pg.global.ui.soundGame:closePanel()
	end
end

function SoundGameView:initView()
	self:setSkillInfo(self.jumpBtnUButton, JUMP_BUTTON_STYLE)
	self:setSkillInfo(self.exitBtnUButton, EXIT_BUTTON_STYLE)
end

function SoundGameView:setSkillInfo(button, styleId)
	local data = vehicleSeatSkillData[styleId]
	local objectReference = button:GetComponent("ObjectReference")
	local skillName = objectReference:GetRefValue("txtNameUText")
	local icon = objectReference:GetRefValue("iconUImage")

	ClientTextUtils.setText(skillName, pg.getLocalizationText(data.vehicleSkillName or ""))

	icon.url = data.vehicleSkillIcon
end

function SoundGameView:perfect()
	LuaUIUtils.setUIVisible(self.perfectUWidget, true)
	LuaUIUtils.setUIVisible(self.missUWidget, false)
	self.perfectAnimation:Stop()
	self.perfectAnimation:Play()
end

function SoundGameView:miss()
	LuaUIUtils.setUIVisible(self.perfectUWidget, false)
	LuaUIUtils.setUIVisible(self.missUWidget, true)
	self.missAnimation:Stop()
	self.missAnimation:Play()
end

return SoundGameView
