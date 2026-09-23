-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AI\\AIInitState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local behaviac = require("Common.AI.Behaviac.Init")
local AgentMeta = behaviac.AgentMeta
local AIInitState = Class.LiteClass("AIInitState", State)

function AIInitState:onEnter(controller, oldState)
	AIInitState.super.onEnter(self, controller, oldState)

	local attachEntity = controller:getAttachEntity()

	attachEntity:clearAIAgent()
end

return AIInitState
