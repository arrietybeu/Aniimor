-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\TimelineExchange.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local ClientUtils = require("Utils.ClientUtils")
local TimelineExchange = Class.LightClass("TimelineExchange", LevelItem)

function TimelineExchange:ctor(sandbox, spawnInfo, syncInfo)
	TimelineExchange.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function TimelineExchange:RPC_SC_StartExchange(rewardIndex)
	local majorCompId = self.spawnInfo.majorCompId
	local comp = self.shell:GetComponentById(majorCompId)

	if not comp or not comp.StartExchange then
		self.logger:error("TimelineExchange:RPC_SC_StartExchange() - component not found, id:", majorCompId)

		return
	end

	comp:StartExchange(rewardIndex)
end

function TimelineExchange:onTimelineStop()
	pg.me:serverMsg("RPC_CS_FinishCommonExchange")
end

function TimelineExchange:destroy()
	TimelineExchange.super.destroy(self)
end

return TimelineExchange
