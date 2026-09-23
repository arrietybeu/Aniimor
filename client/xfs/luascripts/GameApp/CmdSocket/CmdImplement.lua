-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\CmdSocket\\CmdImplement.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("CmdImplement")
local CmdImplement = {}

function CmdImplement.registerAll(system)
	system:registerPrefix("", "GameApp.CmdSocket.BuiltinCmdImplement")
	system:registerPrefix("home", "GameApp.CmdSocket.HomeCmdImplement")
	system:registerPrefix("homelandDemo", "GameApp.CmdSocket.HomelandDemoCmdImplement")
end

return CmdImplement
