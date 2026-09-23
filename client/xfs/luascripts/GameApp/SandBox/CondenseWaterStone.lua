-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\CondenseWaterStone.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local CondenseWaterStone = Class.LightClass("CondenseWaterStone", LevelItem)

function CondenseWaterStone:ctor(sandbox, spawnInfo, syncInfo)
	CondenseWaterStone.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function CondenseWaterStone:onInit()
	self.majorCompId = self.spawnInfo.majorCompId
end

function CondenseWaterStone:_getMajorComp()
	if not self.shell or not self.majorCompId then
		return nil
	end

	return self.shell:GetComponentById(self.majorCompId)
end

function CondenseWaterStone:RPC_SC_StartMove(args)
	local comp = self:_getMajorComp()

	if comp and comp.OnStartMove then
		comp:OnStartMove(args.from, args.to)
	end
end

function CondenseWaterStone:RPC_SC_CancelMove(args)
	local comp = self:_getMajorComp()

	if comp and comp.OnCancelMove then
		comp:OnCancelMove(args.locationIndex)
	end
end

function CondenseWaterStone:confirmPush(targetLocation)
	self:serverMsg("RPC_CS_ConfirmPush", targetLocation)
end

function CondenseWaterStone:notifyMoveCompleted()
	self:serverMsg("RPC_CS_MoveCompleted")
end

function CondenseWaterStone:cancelMove()
	self:serverMsg("RPC_CS_CancelMove")
end

function CondenseWaterStone:notifyClientReady()
	self:serverMsg("RPC_CS_NotifyClientReady")
end

function CondenseWaterStone:setWet(isWet)
	self:serverMsg("RPC_CS_SetWet", isWet)
end

function CondenseWaterStone:destroy()
	CondenseWaterStone.super.destroy(self)
end

return CondenseWaterStone
