-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\CmdSocket\\CmdSocketBridge.lua

local CmdSocketBridge = {}

function CmdSocketBridge.onConnectionOpen(connId)
	if pg.game and pg.game.cmdSocket then
		pg.game.cmdSocket:onConnectionOpen(connId)
	end
end

function CmdSocketBridge.onConnectionClose(connId)
	if pg.game and pg.game.cmdSocket then
		pg.game.cmdSocket:onConnectionClose(connId)
	end
end

function CmdSocketBridge.onMessage(connId, jsonStr)
	if pg.game and pg.game.cmdSocket then
		pg.game.cmdSocket:onMessage(connId, jsonStr)
	end
end

return CmdSocketBridge
