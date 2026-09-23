-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEntityAttachNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local DialogueGraphEntityAttachNode = DialogueGraphFlowNode.extend("DialogueGraphEntityAttachNode")

local function detach(ctx)
	local entityId = ctx:stateGet("entityId")

	if not string.isNilOrEmpty(entityId) then
		ctx:callCmd(NodeFunc.ENTITY_TRY_DETACH_FROM_VEHICLE, entityId)
	end
end

function DialogueGraphEntityAttachNode.run(ctx)
	if ctx:inputPort() == "Stop" then
		ctx:stateSet("needReset", false)
		detach(ctx)

		return
	end

	local source = DialogueGraphUtils.getEntity(ctx:getInput("entityIdVInput"))
	local vehicle = DialogueGraphUtils.getEntity(ctx:getInput("vehicleEntityIdVInput"))

	if source == nil or vehicle == nil then
		return false, "当前实体或者载具实体为空！", true
	end

	local entityId = source.id or source.entityId
	local vehicleEntityId = vehicle.id or vehicle.entityId

	ctx:stateSet("entityId", entityId)
	ctx:stateSet("needReset", ctx:callCmd(NodeFunc.ENTITY_TRY_ATTACH_ON_VEHICLE, entityId, vehicleEntityId, ctx:getInput("seatIdVInput", 0)) == true)
	ctx:triggerFlow("Out")
end

function DialogueGraphEntityAttachNode.onGraphFinished(ctx)
	if ctx:stateGet("needReset", false) then
		detach(ctx)
	end
end

return DialogueGraphEntityAttachNode
