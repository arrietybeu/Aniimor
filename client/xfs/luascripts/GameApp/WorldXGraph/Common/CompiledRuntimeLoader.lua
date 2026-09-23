-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\WorldXGraph\\Common\\CompiledRuntimeLoader.lua

local CompiledRuntimeLoader = {}
local Runtime = require("GameApp.WorldXGraph.Common.Runtime")

local function GetDialogueGraphModuleName(dialogueId)
	return "Data.CompiledLua.Dialogue.DialogueGraph_" .. tostring(dialogueId)
end

function CompiledRuntimeLoader.Create(data, context)
	return Runtime.Load(data, context.graphItem, context.luaCmd)
end

function CompiledRuntimeLoader.CreateForDialogue(dialogueId, context)
	local moduleName = GetDialogueGraphModuleName(dialogueId)

	if context ~= nil and context.reloadGraphModule then
		package.loaded[moduleName] = nil
	end

	local data = require(moduleName)
	local oldFactory = data.new

	if oldFactory ~= nil then
		return {
			module = data,
			runner = oldFactory(context)
		}
	end

	return {
		module = data,
		runner = CompiledRuntimeLoader.Create(data, context)
	}
end

return CompiledRuntimeLoader
