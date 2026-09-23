-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\FilterCurtain.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local Const = require("Common.Const.Const")
local FilterCurtain = Class.LightClass("FilterCurtain", LevelItem)
local SandboxConst = require("Common.Const.SandboxConst")
local EModelUtils = require("Entities.Utils.EModelUtils")
local logger = LoggerManager.getLogger("FilterCurtain")
local Vector3 = Vector3

function FilterCurtain:ctor(sandbox, spawnInfo, syncInfo)
	FilterCurtain.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function FilterCurtain:enterFilterCurtain(entity, resetPosition)
	if not self:isFruit(entity) then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("*********the env is not fruit")
		end

		return
	end

	local lifterEnt = entity:getLifterEntity()

	if lifterEnt then
		entity:getLifterEntity():unLiftEntity(true, nil, nil, false)
	elseif LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("********* not lift fruit")
	end

	EModelUtils.setAgentPosition(entity, resetPosition)
end

function FilterCurtain:isFruit(entity)
	if entity.templateId == 10001 then
		return true
	end

	return false
end

function FilterCurtain:destroy()
	FilterCurtain.super.destroy(self)
end

return FilterCurtain
