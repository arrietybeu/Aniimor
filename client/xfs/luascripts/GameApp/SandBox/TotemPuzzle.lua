-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\TotemPuzzle.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SceneUtils = require("Common.Utils.SceneUtils")
local inspect = require("Core.Common.inspect")
local TotemPuzzle = Class.LightClass("TotemPuzzle", LevelItem)

function TotemPuzzle:ctor(sandbox, spawnInfo, syncInfo)
	TotemPuzzle.super.ctor(self, sandbox, spawnInfo, syncInfo)

	local defaultValue = self.spawnInfo.defaultValue or {}

	self.chestSpawnerId = defaultValue.chestSpawnerId
end

function TotemPuzzle:onSandboxReady()
	TotemPuzzle.super.onSandboxReady(self)

	self.totemPuzzleSB = self.shell.gameObject.transform:GetComponentInChildren(typeof(CS.FunPlus.WorldX.GameApp.Sandbox.TotemPuzzle))

	self:initRefChestStaticId()
end

function TotemPuzzle:changeTotemState(currentState)
	self:serverMsg("RPC_CS_TotemPuzzleStateChange", currentState)
end

function TotemPuzzle:destroy()
	self:resetHideChest()
	TotemPuzzle.super.destroy(self)
end

function TotemPuzzle:RPC_SC_PlayTotemFinishEffect()
	self:createFinishEffect()
end

function TotemPuzzle:createFinishEffect()
	if self.chestSpawnerId and self.chestSpawnerId ~= 0 then
		local valid = self.totemPuzzleSB:PlayTotemPuzzleEffect(self.chestPosition, function()
			self:resetHideChest()
		end)

		if valid then
			self:tempHideChest()
		end
	else
		local valid = self.totemPuzzleSB:PlayTotemPuzzleEffectNoChest()
	end
end

function TotemPuzzle:initRefChestStaticId()
	if self.chestSpawnerId and self.chestSpawnerId ~= 0 then
		local sceneSpawnerData = SceneUtils.getSceneSpawnerData(self.sandbox.space.sceneId, self.sandbox.space.id)
		local sceneEntityData = SceneUtils.getSceneEntityData(self.sandbox.space.sceneId, self.sandbox.space.id)
		local spawnerInfo = sceneSpawnerData[self.chestSpawnerId] or {}
		local spawnGroups = spawnerInfo.spawnGroups or {}

		if spawnGroups[1] then
			self.chestStaticId = (spawnGroups[1].spawnIds or EMPTY_TABLE)[1]

			if self.chestStaticId then
				local entityInfo = sceneEntityData[self.chestStaticId]

				self.chestPosition = Vector3(unpack(entityInfo.position))
			end
		end
	end
end

function TotemPuzzle:tempHideChest()
	if self.chestStaticId then
		self.sandbox.space:setClientEntVisible(self.chestStaticId, false, false)
	end
end

function TotemPuzzle:resetHideChest()
	if self.chestStaticId then
		self.sandbox.space:setClientEntVisible(self.chestStaticId, true, true)
	end
end

return TotemPuzzle
