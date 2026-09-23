-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\DeathBox.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local EnvObjData = require("Data.envobj_data")
local PuppetData = require("Data.puppet_data")
local DeathBox = Class.LightClass("DeathBox", LevelItem)
local Vector3 = Vector3

function DeathBox:ctor(sandbox, spawnInfo, syncInfo)
	DeathBox.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function DeathBox:sendDeathBoxTeleport(entityId, resetPos, posList, bloodProportion)
	pg.space:reliableServerSpaceMsg("RPC_CS_DeathBoxTeleport", {
		entityId,
		resetPos,
		posList,
		bloodProportion
	})
end

function DeathBox:enterDeathBox(actorId)
	local majorConfig = self:getMajorConfig()
	local ent = pg.getEntityByActorId(actorId)

	if ent.isInControl then
		local pos

		if majorConfig.playerRevivePos then
			pos = Vector3(unpack(majorConfig.playerRevivePos))
		else
			pos = Vector3.New(0, 0, 0)
		end

		local rot

		if majorConfig.playerReviveRot then
			rot = Vector3(unpack(majorConfig.playerReviveRot))
		else
			rot = Vector3.New(0, 0, 0)
		end

		ent:doDieWithAutoRevive(Const.LIFE_DEAD_BY_CLIFF, majorConfig.blackScreenId, majorConfig.playerReviveType, pos, rot, majorConfig.playerBloodProportion or 0)
	else
		if not self.sandbox.isMain then
			return
		end

		if Utils.isEnvObj(ent) then
			local isNeedReset = true

			if majorConfig.envobjReviveType == 1 then
				if EnvObjData[ent.templateId] and EnvObjData[ent.templateId].canBeDestory == 1 then
					isNeedReset = false
				else
					return
				end
			end

			self:sendDeathBoxTeleport(ent.id, isNeedReset, majorConfig.envobjRevivePos or {}, 0)
		elseif Utils.isPuppet(ent) then
			if majorConfig.puppetReviveType == 1 then
				if PuppetData[ent.templateId] and PuppetData[ent.templateId].canBeDestory == 1 then
					self:sendDeathBoxTeleport(ent.id, false, majorConfig.puppetRevivePos or {}, 1)
				end
			else
				self:sendDeathBoxTeleport(ent.id, true, majorConfig.puppetRevivePos or {}, majorConfig.puppetBloodProportion)
			end
		end
	end
end

function DeathBox:destroy()
	DeathBox.super.destroy(self)
end

return DeathBox
