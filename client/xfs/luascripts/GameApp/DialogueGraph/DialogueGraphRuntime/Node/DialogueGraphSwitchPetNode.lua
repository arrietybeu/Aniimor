-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphSwitchPetNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphSwitchPetNode = DialogueGraphFlowNode.extend("DialogueGraphSwitchPetNode")

local function getPlayerEntityId()
	local pgValue = pg

	if pgValue ~= nil and pgValue.me ~= nil and pgValue.me.id ~= nil then
		return pgValue.me.id
	end

	if pgValue ~= nil and pgValue.pawn ~= nil and pgValue.pawn.id ~= nil then
		return pgValue.pawn.id
	end

	return nil
end

local function setWalk(ctx, enabled)
	if enabled then
		local entityId = ctx:getInput("entityIdVInput")

		if not string.isNilOrEmpty(entityId) then
			local speed = ctx:getInput("speedVInput", 1)

			ctx:callCmd(NodeFunc.ENTITY_SET_ANIM_SPEED, entityId, speed)
		end

		ctx:stateSet("editWalk", true)
	else
		ctx:stateSet("editWalk", false)
	end

	if pg.me and pg.me.eModel then
		pg.me.eModel.InPerformanceWalk = enabled

		local speed = ctx:getInput("speedVInput", 1)

		pg.me.eModel.InPerformanceWalkSpeed = enabled and speed or 1
	end
end

function DialogueGraphSwitchPetNode.run(ctx)
	local meId = getPlayerEntityId()

	if ctx:callCmd(NodeFunc.ENTITY_SET_ENTITY_TAKE_OVER, meId) == false then
		return false, "player entity takeover failed"
	end

	local switchToWalk = ctx:getInput("switchToWalkVInput", false)
	local switchToLocomotion = ctx:getInput("switchToLocomotionVInput", false)

	if switchToWalk or switchToLocomotion then
		setWalk(ctx, switchToWalk == true)
	end

	if ctx:getInput("switchToPetVInput", false) then
		ctx:callCmd(NodeFunc.PLAYER_SWITCH_PET, true, 7)
	elseif ctx:getInput("switchToPlayerVInput", false) then
		local function finishCallback()
			if not ctx:tryConsumeRunToken() then
				return
			end

			ctx:triggerFlow("Out")
		end

		ctx:delay(3, finishCallback)

		local ret = ctx:callCmd(NodeFunc.PLAYER_SWITCH_PET, false, 7, finishCallback)

		if ret == false then
			finishCallback()
		end

		return
	elseif ctx:getInput("switchToCrouchVInput", false) or ctx:getInput("switchToDeCrouchVInput", false) then
		ctx:callCmd(NodeFunc.PLAYER_SWITCH_CROUCH)
	elseif ctx:getInput("switchOnMountVInput", false) then
		local entityId = ctx:getInput("entityIdVInput", "")

		ctx:callCmd(NodeFunc.PLAYER_STATE_ON_MOUNT, tonumber(entityId) or entityId)
	elseif ctx:getInput("switchOnDismountVInput", false) then
		ctx:callCmd(NodeFunc.PLAYER_STATE_ON_DISMOUNT)
	end

	ctx:triggerFlow("Out")
end

function DialogueGraphSwitchPetNode.onGraphFinished(ctx)
	if ctx:stateGet("editWalk", false) then
		setWalk(ctx, false)
	end
end

return DialogueGraphSwitchPetNode
