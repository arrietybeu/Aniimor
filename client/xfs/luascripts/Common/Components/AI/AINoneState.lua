-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AI\\AINoneState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local behaviac = require("Common.AI.Behaviac.Init")
local AgentMeta = behaviac.AgentMeta
local AINoneState = Class.LiteClass("AINoneState", State)

function AINoneState:onEnter(controller, oldState)
	AINoneState.super.onEnter(self, controller, oldState)
end

return AINoneState
