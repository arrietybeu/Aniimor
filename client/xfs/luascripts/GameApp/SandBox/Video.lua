-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\Video.lua

local Class = require("Core.Framework.Class")
local ClientMmoItem = require("Entities.SpaceEntities.ClientMmoItem")
local ClientScreen = Class.OldLightClass("ClientScreen", ClientMmoItem)
local ClientConst = require("Const.ClientConst")

function ClientScreen:ctor(sandbox, spawnInfo, syncInfo)
	ClientScreen.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function ClientScreen:onSandboxReady()
	ClientScreen.super.onSandboxReady(self)

	self.ClientScreenSB = self.shell.gameObject:GetComponent("ClientScreenSB")

	if pg.me.arkScreenInfoMap then
		for _, screenInfo in pairs(pg.me.arkScreenInfoMap) do
			self.ClientScreenSB:Init(screenInfo.screenId, screenInfo.ClientScreenUrl, screenInfo.ClientScreenType, screenInfo.modelOffset, modelOffset.modelScale)
			self.ClientScreenSB:Play()
		end
	end
end

function ClientScreen:destroy()
	ClientScreen.super.destroy(self)
end

return ClientScreen
