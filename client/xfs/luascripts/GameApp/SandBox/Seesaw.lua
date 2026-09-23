-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\Seesaw.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local Seesaw = Class.LightClass("Seesaw", LevelItem)

function Seesaw:ctor(sandbox, spawnInfo, syncInfo)
	Seesaw.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function Seesaw:turn(state, isFall)
	self:syncFieldValue({
		state = state,
		isFall = isFall
	})
end

function Seesaw:setSyncInfo(syncInfo, isInit)
	if syncInfo.state then
		self:onValueChange("state", syncInfo.state, isInit)

		if not isInit then
			-- block empty
		end
	end
end

function Seesaw:destroy()
	Seesaw.super.destroy(self)
end

return Seesaw
