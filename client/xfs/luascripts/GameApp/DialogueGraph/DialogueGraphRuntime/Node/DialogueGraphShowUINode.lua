-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphShowUINode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local Utils = require("Common.Utils.Utils")
local DialogueGraphShowUINode = DialogueGraphFlowNode.extend("DialogueGraphShowUINode")

local function onCloseUI(ctx)
	if ctx:tryConsumeRunToken() then
		ctx:stateSet("opened", nil)
		ctx:triggerFlow("CloseOut")
	end
end

function DialogueGraphShowUINode.run(ctx)
	local uid = ctx:getField("uid", 0)

	if ctx:inputPort() == "closeUIFInput" then
		if uid ~= 0 then
			ctx:callCmd(NodeFunc.UI_CLOSE_UI, uid)
		end

		onCloseUI(ctx)

		return
	end

	if uid == 0 then
		ctx:triggerFlow("Out")
		ctx:triggerFlow("CloseOut")

		return
	end

	ctx:stateSet("opened", true)

	local param = ctx:getField("param")

	if param ~= nil then
		param = Utils.deepCopyTable(param)
	end

	ctx:callCmd(NodeFunc.UI_SHOW_UI, uid, param, function()
		onCloseUI(ctx)
	end)
	ctx:triggerFlow("Out")
end

function DialogueGraphShowUINode.onGraphFinished(ctx)
	if ctx:stateGet("opened") == true and ctx:getInput("closeUIWhenFinishVInput", true) then
		ctx:stateSet("opened", nil)

		local uid = ctx:getField("uid", 0)

		if uid ~= 0 then
			ctx:callCmd(NodeFunc.UI_CLOSE_UI, uid)
		end
	end
end

return DialogueGraphShowUINode
