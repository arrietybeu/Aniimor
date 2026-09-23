-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\MechanismBallHole.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local MechanismBallHole = Class.LightClass("MechanismBallHole", LevelItem)

function MechanismBallHole:ctor(sandbox, spawnInfo, syncInfo)
	MechanismBallHole.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function MechanismBallHole:onSandboxReady()
	MechanismBallHole.super.onSandboxReady(self)

	self.holeSB = self.shell.gameObject:GetComponent("MechanismBallHoleSB")

	self:refreshRelatedBall()
end

function MechanismBallHole:destroy()
	MechanismBallHole.super.destroy(self)
end

function MechanismBallHole:onMechanismTrigger(ballEnt)
	if ballEnt.MechanismBallFeature then
		self:serverMsg("RPC_CS_onMechanismTrigger", ballEnt.id)
	end
end

function MechanismBallHole:refreshRelatedBall()
	if self.holeSB then
		local ballEntId = self.syncInfo.ballEntId

		self.holeSB:SetAbsorbEntity(ballEntId)
	end
end

function MechanismBallHole:RPC_SC_onBallTriggered(args)
	self:refreshRelatedBall()
end

return MechanismBallHole
