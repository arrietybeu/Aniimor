-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\DungeonSavePoint.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local NoticeDef = require("Common.NoticeDef")
local DungeonSavePoint = Class.LightClass("DungeonSavePoint", LevelItem)
local RECOVER_BUFF_EFFECT_KEY = "Eff_Buff_FlashHeal"

function DungeonSavePoint:ctor(sandbox, spawnInfo, syncInfo)
	DungeonSavePoint.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function DungeonSavePoint:setSavePointActive(active)
	self:serverMsg("RPC_CS_SetSavePointActive", active)
end

function DungeonSavePoint:RPC_SC_PlayerRecover(playerIds)
	for _, playerId in ipairs(playerIds) do
		local player = pg.getEntity(playerId)

		if player and player.playEffect then
			player:playEffect(RECOVER_BUFF_EFFECT_KEY)

			local petEnt = player:getCurPetEntity()

			if petEnt then
				petEnt:playEffect(RECOVER_BUFF_EFFECT_KEY)
			end
		end

		if playerId == pg.me.id then
			pg.global.showBubbleMessageById(NoticeDef.PET_RECOVER)
		end
	end
end

function DungeonSavePoint:destroy()
	pg.pawn:stopEffect(RECOVER_BUFF_EFFECT_KEY)
	DungeonSavePoint.super.destroy(self)
end

return DungeonSavePoint
