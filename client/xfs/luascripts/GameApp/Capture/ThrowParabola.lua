-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\ThrowParabola.lua

local Class = require("Core.Framework.Class")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local castItemData = require("Data.cast_item_data")
local ItemEffectData = require("Data.item_effect_data")
local ClientConst = require("Const.ClientConst")
local MoveState = ClientConst.MoveState
local messageName = require("Const.MessageName")
local TimerManager = require("Core.Timer.TimerManager")
local ThrowParabola = Class.LightClass("ThrowParabola")

function ThrowParabola:ctor()
	self.loader = ResLoader.new()

	self.loader:load("ParabolaCaster", function(obj)
		self.caster = obj:GetComponent("ParabolaCaster")

		obj:SetActiveEx(false)
	end)
end

function ThrowParabola:show(handTrans, ballData)
	self.ballData = ballData

	self.loader:setParent(handTrans)

	local obj = self.loader.obj

	obj:SetActiveEx(true)

	obj.transform.localPosition = Vector3(unpack(self.ballData.offset))

	local v = self.ballData.initV
	local chargeSpeed = self.ballData.chargeSpeed
	local maxV = self.ballData.maxV

	self.timerId = TimerManager.addRepeatNextFrameCb(function(delta)
		if not self.caster then
			return
		end

		v = math.min(v + 0.02 * chargeSpeed, maxV)

		self.caster:SetVelocity(v)
	end)
end

function ThrowParabola:hide()
	self.loader.obj:SetActiveEx(false)

	if self.timerId then
		TimerManager.delFrameCb(self.timerId)
	end
end

function ThrowParabola:setVelocity(v)
	if self.caster then
		self.caster:SetVelocity(v)
	end
end

function ThrowParabola:getVelocity()
	if self.caster then
		return self.caster:GetRbVelocity()
	end

	return self.ballData.initV
end

function ThrowParabola:destroy()
	self.loader:destroy()

	self.caster = nil
end

return ThrowParabola
