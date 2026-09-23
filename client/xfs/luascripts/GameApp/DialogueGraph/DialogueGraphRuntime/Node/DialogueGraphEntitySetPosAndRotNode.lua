-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEntitySetPosAndRotNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphEntitySetPosAndRotNode = DialogueGraphFlowNode.extend("DialogueGraphEntitySetPosAndRotNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local Utils = require("Common.Utils.Utils")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local Vector3 = Vector3
local Quaternion = Quaternion

function DialogueGraphEntitySetPosAndRotNode.run(ctx)
	local entityId = ctx:getInput("entityIdVInput")
	local staticId = ctx:getInput("staticIdVInput", 0)
	local entity = DialogueGraphUtils.getEntityById(entityId, staticId)

	if entity == nil then
		return false, string.format("找不到Id为%s-%s的实体！", tostring(entityId), tostring(staticId)), true
	end

	local setPosition = ctx:getField("setPosition", true)
	local position = setPosition and DialogueGraphUtils.toVector3(ctx:getInput("targetPositionVInput", nil)) or nil

	if setPosition and position ~= nil then
		local currentPosition = entity:getPosition()
		local distance = Vector3.Distance(currentPosition, position)
		local maxDistance = Utils.isPlayer(entity) and DialogueGraphConst.ENTITY_PLAYER_SET_POSITION_DISTANCE_MAX or DialogueGraphConst.ENTITY_PUPPET_SET_POSITION_DISTANCE_MAX

		if maxDistance < distance then
			return false, string.format("移动距离过大！当前距离：%.2f米，最大允许距离：%s米。\n当前位置：%s，目标位置：%s", distance, tostring(maxDistance), tostring(currentPosition), tostring(position)), true
		end

		if Utils.isPlayer(entity) then
			ctx:callCmd(NodeFunc.ENTITY_FORBID_POSITION_CHECK, position)
			DialogueGraphUtils.forceChangeToIdle(entity)
		end

		DialogueGraphUtils.setEntityPosition(entity, position)
	end

	local setRotation = ctx:getField("setRotation", false)
	local rotationEuler = setRotation and DialogueGraphUtils.toVector3(ctx:getInput("targetEulerAngleVInput", nil)) or nil

	if setRotation and rotationEuler ~= nil then
		local rotation = Quaternion.Euler(rotationEuler.x, rotationEuler.y, rotationEuler.z)

		DialogueGraphUtils.setEntityRotation(entity, rotation.x, rotation.y, rotation.z, rotation.w, true)
	end

	ctx:delayFrame(1, function()
		if not ctx:tryConsumeRunToken() then
			return
		end

		ctx:triggerFlow("Out")
	end)
end

return DialogueGraphEntitySetPosAndRotNode
