-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\PosterDisplay.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local PosterDisplay = Class.LightClass("PosterDisplay", LevelItem)

function PosterDisplay:ctor(sandbox, spawnInfo, syncInfo)
	PosterDisplay.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function PosterDisplay:onSandboxReady()
	PosterDisplay.super.onSandboxReady(self)
	pg.game.shop:setShopPosterInteractionEvent(function(visible, posterStaticId)
		self:setSpriteVisible(visible, posterStaticId)
	end, self.id)
end

function PosterDisplay:setSpriteVisible(visible, posterStaticId)
	if self.id ~= posterStaticId then
		return
	end

	local posterDisplay = self.shell.gameObject:GetComponent("PosterDisplay")

	posterDisplay:SetSpriteVisible(visible)
end

function PosterDisplay:destroy()
	PosterDisplay.super.destroy(self)
end

return PosterDisplay
