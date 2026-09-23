-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AI\\Perceptibility\\VisionSensorDebug.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandler = require("Core.Common.CallbackHandler")
local AiConst = require("Common.Const.AiConst")
local AIUtils = require("Common.Utils.AIUtils")
local VisionSensorDebug = Class.LiteClass("VisionSensorDebug")

function VisionSensorDebug:ctor(entity)
	self.ent = entity
	self.perceptibilityDebugTimer = nil
end

function VisionSensorDebug:init()
	if UNITY_EDITOR and self.perceptibilityDebugTimer == nil then
		self.perceptibilityDebugTimer = TimerManager.addRepeatTimer(1, CallbackHandler(self, "_debugDrawTimer"))
	end
end

function VisionSensorDebug:destroy()
	if UNITY_EDITOR and self.perceptibilityDebugTimer ~= nil then
		TimerManager.removeTimer(self.perceptibilityDebugTimer)

		self.perceptibilityDebugTimer = nil
	end

	self.ent = nil
end

function VisionSensorDebug:_debugDrawTimer()
	if not AIUtils.checkHasPerceptibility(self.ent) or not AiConst.AI_DEBUG.PERCEPTIBILITY then
		return
	end

	if self.ent:isInCombat() then
		return
	end

	if self.ent:checkBtPause() then
		return
	end

	local currentPerceptibilityDebugActorId = AiConst.AI_DEBUG.PERCEPTIBILITY_ID
	local sensor

	if AiConst.AI_DEBUG.PERCEPTIBILITY_NO_IMP then
		sensor = self.ent.perceptibility.noImpVisionSensor
	else
		sensor = self.ent.perceptibility.visionSensor
	end

	if sensor == nil then
		return
	end

	if currentPerceptibilityDebugActorId == self.ent.actorId or currentPerceptibilityDebugActorId == 0 then
		for _, visionArea in ipairs(sensor.VP_visionArea) do
			if visionArea.distanceStart == 0 then
				self:_drawSector(visionArea.angleStart, visionArea.angleEnd, visionArea.distanceEnd, 1)
			else
				self:_drawAnnularSector(visionArea.angleStart, visionArea.angleEnd, visionArea.distanceStart, visionArea.distanceEnd, 1)
			end
		end
	end
end

function VisionSensorDebug:_drawAnnularSector(angleStart, angleEnd, inRadius, outRadius, rgb)
	local shape_kind = 4
	local searchEnt = AIUtils.getPerceptibilitySearchEnt(self.ent)
	local yawDegree = math.deg(searchEnt:getRotation():ToYaw())
	local selfPos = searchEnt:getPosition()
	local rotDegree = yawDegree + (angleStart + angleEnd) / 2
	local halfDegree = (angleEnd - angleStart) / 2
	local hight = 1
	local duration = 1

	CS.FunPlus.WorldX.Utils.DebugDraw.DrawDebugShape(shape_kind, selfPos.x, selfPos.y, selfPos.z, rotDegree, halfDegree, inRadius, outRadius, hight, duration, rgb, 0)
end

function VisionSensorDebug:_drawSector(angleStart, angleEnd, radius, rgb)
	local shape_kind = 2
	local searchEnt = AIUtils.getPerceptibilitySearchEnt(self.ent)
	local yawDegree = math.deg(searchEnt:getRotation():ToYaw())
	local selfPos = searchEnt:getPosition()
	local rotDegree = yawDegree + (angleStart + angleEnd) / 2
	local halfDegree = (angleEnd - angleStart) / 2
	local hight = 1
	local duration = 1

	CS.FunPlus.WorldX.Utils.DebugDraw.DrawDebugShape(shape_kind, selfPos.x, selfPos.y, selfPos.z, rotDegree, halfDegree, radius, hight, duration, rgb, 0, 0)
end

return VisionSensorDebug
