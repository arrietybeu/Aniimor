-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\EnvObj\\EnvObjSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local ClientUtils = require("Utils.ClientUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local Const = require("Common.Const.Const")
local EnvObjectManager = CS.FunPlus.WorldX.Entities.EnvObj.EnvObjectManager
local EnvObjSystem = Class.LightClass("EnvObjSystem", SystemBase)

function EnvObjSystem:onInit()
	return
end

function EnvObjSystem:createServerEntAt(templateId, position, rotation)
	pg.me:serverSpaceMsg("RPC_CS_CreateEnvEntity", {
		templateId,
		position,
		rotation
	})
end

function EnvObjSystem:genEnvId()
	return EnvObjectManager.GenEnvId()
end

function EnvObjSystem:destroyEnvObject(envObjEnt, delaySecond, reason)
	pg.me:reliableServerSpaceMsg("RPC_CS_DestroyEnvEntity", {
		envObjEnt.envId,
		delaySecond or 0,
		envObjEnt:getPosition(),
		reason or 0
	})
end

return EnvObjSystem
