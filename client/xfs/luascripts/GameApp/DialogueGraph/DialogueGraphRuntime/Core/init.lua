-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Core\\init.lua

local WorldXGraph = {}

WorldXGraph.Scheduler = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.Scheduler")
WorldXGraph.Context = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.Context")
WorldXGraph.Runtime = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.Runtime")
WorldXGraph.Performance = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.Performance")
WorldXGraph.NodeRegistry = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.NodeRegistry")
WorldXGraph.RuntimeGuard = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.RuntimeGuard")

return WorldXGraph
