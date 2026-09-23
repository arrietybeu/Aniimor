-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientGameFlowUtil.lua

local EventConst = require("Const.EventConst")
local ClientResMgrUtil = require("Utils.ClientResMgrUtil")
local ClientGameFlowUtil = {}

function ClientGameFlowUtil.initSystem()
	pg.global.eventEmitter:addEventListener(EventConst.GAMEFLOW_CHANGE, ClientGameFlowUtil.onEventGameFlowChange)
end

function ClientGameFlowUtil.onEventGameFlowChange(sOldState, sNewState, tParam)
	ClientResMgrUtil.onEventGameFlowChange(sOldState, sNewState, tParam)
end

function ClientGameFlowUtil.onMainPlayerEnterSpace(mainPlayer)
	ClientResMgrUtil.onMainPlayerEnterSpace(mainPlayer)
end

function ClientGameFlowUtil.onMainPlayerLeaveSpace(mainPlayer)
	ClientResMgrUtil.onMainPlayerLeaveSpace(mainPlayer)
end

return ClientGameFlowUtil
