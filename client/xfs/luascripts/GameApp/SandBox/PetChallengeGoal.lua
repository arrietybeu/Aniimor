-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\PetChallengeGoal.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local Utils = require("Common.Utils.Utils")
local PetChallengeGoal = Class.LightClass("PetChallengeGoal", LevelItem)

function PetChallengeGoal:ctor(sandbox, spawnInfo, syncInfo)
	PetChallengeGoal.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function PetChallengeGoal:enterGoal(actorId)
	local ent = pg.getEntityByActorId(actorId)
	local gameplay = self.sandbox.gameplay

	if gameplay and gameplay.interactSheep then
		if Utils.isPuppet(ent) then
			gameplay:interactSheep(ent.actorId)
		elseif Utils.isPet(ent) and ent.StickerFeature then
			local stickEntities = ent.StickerFeature.stickEntities

			for entId, v in pairs(stickEntities) do
				local stickEnt = pg.getEntity(entId)

				if stickEnt then
					ent.StickerFeature:exitStick(entId)
					gameplay:interactSheep(stickEnt.actorId)
				end
			end
		end
	end
end

function PetChallengeGoal:exitTrigger()
	return
end

function PetChallengeGoal:destroy()
	PetChallengeGoal.super.destroy(self)
end

return PetChallengeGoal
