-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\PlantNursery.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local TimerManager = require("Core.Timer.TimerManager")
local PlantNursery = Class.LightClass("PlantNursery", LevelItem)

function PlantNursery:ctor(sandbox, spawnInfo, syncInfo)
	PlantNursery.super.ctor(self, sandbox, spawnInfo, syncInfo)

	local defaultValue = spawnInfo.defaultValue or {}

	self.checkTemplateId = defaultValue.checkTemplateId
end

function PlantNursery:onInteract(interactUnit)
	local state = pg.pawn:playAnimation("Lift_Quit")

	if state then
		pg.pawn:disableMotion(ClientConst.DISABLE_MOTION_KEY.LIFTING, true)

		self.inPlanting = true

		state:AddEndCallback(function(reason)
			self.inPlanting = false

			pg.pawn:disableMotion(ClientConst.DISABLE_MOTION_KEY.LIFTING, false)
		end)
	end

	self.interactTimerId = self:addTimer(0.1, function()
		self:serverMsg("plantSeed", pg.pawn.id)
	end)
end

function PlantNursery:checkCanInteract(interactUnit)
	if not pg.pawn then
		return false
	end

	if self.syncInfo.state == Const.NurseryState.Plant then
		return false
	end

	if self.inPlanting then
		return false
	end

	local liftEntity = pg.pawn:getLiftEntity()

	if liftEntity and Utils.isEnvObj(liftEntity) then
		local templateId = liftEntity.templateId

		if self.checkTemplateId then
			return templateId == self.checkTemplateId
		end
	end

	return false
end

function PlantNursery:destroy()
	PlantNursery.super.destroy(self)
end

return PlantNursery
