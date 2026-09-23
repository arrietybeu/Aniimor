-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SludgePile.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local SludgePile = Class.LightClass("SludgePile", LevelItem)

function SludgePile:ctor(sandbox, spawnInfo, syncInfo)
	SludgePile.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function SludgePile:onInit()
	local majorConfig = self:getMajorConfig()

	self.majorCompId = self.spawnInfo.majorCompId
	self.vomitInterval = majorConfig.vomitInterval or 0
end

function SludgePile:_getMajorComp()
	if not self.shell or not self.majorCompId then
		return nil
	end

	return self.shell:GetComponentById(self.majorCompId)
end

function SludgePile:RPC_SC_Vomit()
	local comp = self:_getMajorComp()

	if comp then
		comp:Vomit()
	end
end

function SludgePile:requestSwitchStateOn()
	self:serverMsg("RPC_CS_SetStateOn")
end

function SludgePile:destroy()
	SludgePile.super.destroy(self)
end

return SludgePile
