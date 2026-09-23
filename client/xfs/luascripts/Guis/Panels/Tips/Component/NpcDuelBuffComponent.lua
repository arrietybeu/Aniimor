-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\NpcDuelBuffComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local NpcDuelBuffComponent = Class.LightClass("NpcDuelBuffComponent", UIComponent)
local Lume = require("Core.Common.lume")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local UIUtils = UIUtils

function NpcDuelBuffComponent:findObjects()
	self.container = self.transform:GetComponent("UContainer")
end

function NpcDuelBuffComponent:registerObjectInner()
	local objectReference = self.container.content:GetComponent("ObjectReference")

	self.anim = objectReference:GetRefValue("anim")
	self.buffIconUImage = objectReference:GetRefValue("buffIconUImage")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.subInfoUSDFText = objectReference:GetRefValue("subInfoUSDFText")
end

function NpcDuelBuffComponent:initView()
	if self.uWidget then
		self.uWidget:SetActive(true)
	end

	self:hide()
end

function NpcDuelBuffComponent:onHide()
	LuaUIUtils.setUIVisible(self.container.content, false)
end

function NpcDuelBuffComponent:onShow()
	LuaUIUtils.setUIVisible(self.container.content, true)
end

function NpcDuelBuffComponent:showNpcDuelBuff(buffInfo, cb)
	if not self.container:CheckURLLoaded() then
		self.container:LoadDefaultUrlManually(function()
			self:registerObjectInner()
			self:showNpcDuelBuffInternal(buffInfo, cb)
		end)
	else
		self:showNpcDuelBuffInternal(buffInfo, cb)
	end
end

function NpcDuelBuffComponent:showNpcDuelBuffInternal(buffInfo, cb)
	self:refreshBuffDisplay(buffInfo)
	self:show()

	if cb then
		cb()
	end

	self:clearHideTimer()

	self.hideTimerId = self:startTimer(function()
		self.hideTimerId = nil

		self:playOutAnimationAndHide()
	end, 3)
end

function NpcDuelBuffComponent:refreshBuffDisplay(buffInfo)
	ClientTextUtils.setText(self.titleUSDFText, buffInfo.buffName)
	ClientTextUtils.setText(self.subInfoUSDFText, buffInfo.buffDesc)

	self.buffIconUImage.url = buffInfo.buffIcon
end

function NpcDuelBuffComponent:playOutAnimationAndHide()
	if not self.anim then
		self:hide()

		return
	end

	UIUtils.PlayAnimation(self.anim, "VX_Node_HUD_BattleRoom_Buff_Toast_Out", function()
		self:hide()
	end)
end

function NpcDuelBuffComponent:clearHideTimer()
	if self.hideTimerId then
		self:killTimer(self.hideTimerId)

		self.hideTimerId = nil
	end
end

return NpcDuelBuffComponent
