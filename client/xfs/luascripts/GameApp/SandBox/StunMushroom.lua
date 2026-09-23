-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\StunMushroom.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local Const = require("Common.Const.Const")
local StunMushroom = Class.LightClass("StunMushroom", LevelItem)

function StunMushroom:ctor(sandbox, spawnInfo, syncInfo)
	StunMushroom.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function StunMushroom:destroy()
	StunMushroom.super.destroy(self)
end

function StunMushroom:onSandboxReady()
	StunMushroom.super.onSandboxReady(self)
end

function StunMushroom:onValueChange(key, oldValue, value, isInit)
	StunMushroom.super.onValueChange(self, key, oldValue, value, isInit)
end

function StunMushroom:onMushRoomTrigger()
	self:serverMsg("RPC_CS_onMushRoomTrigger")
end

function StunMushroom:onEnterFog(entId)
	local ent = pg.getEntity(entId)

	if ent.authority == Const.AUTHORITY_MASTER then
		self:serverMsg("RPC_CS_onEnterFog", entId)
	end
end

return StunMushroom
