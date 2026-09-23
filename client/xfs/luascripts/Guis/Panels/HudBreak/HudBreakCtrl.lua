-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudBreak\\HudBreakCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("HudBreakCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local Utils = require("Common.Utils.Utils")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HudBreakCtrl = Class.LightClass("HudBreakCtrl", UICtrl)
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")

HudBreakCtrl.messages = {}

function HudBreakCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function HudBreakCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function HudBreakCtrl:addListener()
	return
end

function HudBreakCtrl:onShow()
	return
end

function HudBreakCtrl:onEntBreakStateChange(data)
	if not self.view then
		return
	end

	local ent = data.ent
	local isBreak = data.isBreak

	if isBreak and not ent:isFakeDead() then
		if pg.me.lockedActorId == ent.actorId then
			self:playEnemyBreakAnim("VX_Ani_EnemyBreak_In", 1.5)
			pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonHigh")
		elseif pg.pawn.actorId == ent.actorId and pg.me.space:isPvpEnv() then
			self:playSelfBreakAnim("VX_Ani_PlayerBreak_In", 1.5)
			pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonHigh")
		end
	end
end

function HudBreakCtrl:playAnimationIgnoreTimeScale(clipName)
	self.view.animPlayer:PlayAnimExtend(clipName, true)
end

function HudBreakCtrl:playEnemyBreakAnim(clipName, duration)
	LuaUIUtils.setUIViewVisible(self.view.enemyBreakPlayer, true)
	self.view.enemyBreakPlayer:PlayAnimExtend(clipName, true)

	if self.enemyBreakEndTimer then
		self:killTimer(self.enemyBreakEndTimer)
	end

	self.enemyBreakEndTimer = self:startTimer(function()
		LuaUIUtils.setUIViewVisible(self.view.enemyBreakPlayer, false)

		self.enemyBreakEndTimer = nil
	end, duration)
end

function HudBreakCtrl:playSelfBreakAnim(clipName, duration)
	LuaUIUtils.setUIViewVisible(self.view.selfBreakPlayer, true)
	self.view.selfBreakPlayer:PlayAnimExtend(clipName, true)

	if self.selfBreakEndTimer then
		self:killTimer(self.selfBreakEndTimer)
	end

	self.selfBreakEndTimer = self:startTimer(function()
		LuaUIUtils.setUIViewVisible(self.view.selfBreakPlayer, false)

		self.selfBreakEndTimer = nil
	end, duration)
end

return HudBreakCtrl
