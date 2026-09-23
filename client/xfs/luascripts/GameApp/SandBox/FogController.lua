-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\FogController.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local FogController = Class.LightClass("FogController", LevelItem)

function FogController:ctor(sandbox, spawnInfo, syncInfo)
	FogController.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function FogController:onSandboxReady()
	local space = self.sandbox.space

	space:registerLevelItemAreaData(self.id, {
		areaShapeType = 1,
		id = self.id,
		entityTypeList = {
			1,
			2,
			4
		},
		logics = {
			{
				states = {
					{
						"InFog"
					}
				}
			}
		}
	})
end

function FogController:destroy()
	local space = self.sandbox.space

	space:unregisterLevelItemAreaData(self.id)
	FogController.super.destroy(self)
end

return FogController
