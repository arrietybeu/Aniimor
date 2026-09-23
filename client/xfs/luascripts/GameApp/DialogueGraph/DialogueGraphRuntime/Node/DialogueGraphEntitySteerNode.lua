-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEntitySteerNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphEntitySteerNode = DialogueGraphFlowNode.extend("DialogueGraphEntitySteerNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local Vector3 = Vector3
local Quaternion = Quaternion

local function stopSteer(ctx)
	local entityId = ctx:stateGet("entityId")

	if entityId == nil then
		return
	end

	ctx:stateSet("entityId", nil)
	ctx:callCmd(NodeFunc.ENTITY_DISABLE_DIALOGUE_CONTROLLER, entityId)
end

local function onFinish(ctx)
	if not ctx:tryConsumeRunToken() then
		return
	end

	ctx:stateSet("entityId", nil)
	ctx:triggerFlow("FinishOut")
end

function DialogueGraphEntitySteerNode.run(ctx)
	local entityId = ctx:getInput("entityIdVInput")
	local staticId = ctx:getInput("staticIdVInput")
	local entity = DialogueGraphUtils.getEntityById(entityId, staticId)

	if entity == nil then
		return false, string.format("找不到对应实体！EntityId:%s StaticId:%s", tostring(entityId), tostring(staticId)), true
	end

	local duration = ctx:getInput("durationVInput", nil)

	if duration == nil then
		duration = ctx:getField("duration", 0.3)
	end

	local timeoutDuration

	if duration > 0 then
		timeoutDuration = duration + 3
	else
		timeoutDuration = 2
	end

	local targetEulerAngle = DialogueGraphUtils.toVector3(ctx:getInput("targetEulerAngleVInput", {
		z = 0,
		y = 0,
		x = 0
	}))
	local faceTransform = ctx:getInput("faceTransVInput")

	if faceTransform ~= nil then
		local entity

		if not string.isNilOrEmpty(entityId) then
			entity = DialogueGraphUtils.getEntity(entityId)
		else
			entity = DialogueGraphUtils.getEntityByStaticId(staticId)
		end

		if entity ~= nil and entity.getPosition then
			local direction = faceTransform.position - entity:getPosition()

			direction.y = 0
			direction = direction.normalized

			if math.abs(direction.x) <= 0.01 and math.abs(direction.y) <= 0.01 and math.abs(direction.z) <= 0.01 then
				onFinish(ctx)
				ctx:triggerFlow("Out")

				return
			end

			targetEulerAngle = Quaternion.LookRotation(direction, Vector3.up):ToEulerAngles()
		end
	end

	ctx:stateSet("entityId", entity.id)

	local ret = ctx:callCmd(NodeFunc.ENTITY_STEER, entityId, staticId, targetEulerAngle, timeoutDuration, function()
		onFinish(ctx)
	end)

	if not ret then
		ctx:stateSet("entityId", nil)

		return false, string.format("发起转身失败 EntityId: %s", entity.id)
	end

	ctx:triggerFlow("Out")
end

function DialogueGraphEntitySteerNode.onGraphFinished(ctx)
	stopSteer(ctx)
end

return DialogueGraphEntitySteerNode
