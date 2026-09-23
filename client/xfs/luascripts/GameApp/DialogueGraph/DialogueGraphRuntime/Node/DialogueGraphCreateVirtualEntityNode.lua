-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphCreateVirtualEntityNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphCreateVirtualEntityNode = DialogueGraphFlowNode.extend("DialogueGraphCreateVirtualEntityNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")

local function finishCallback(ctx, ent, source)
	if not ctx:tryConsumeRunToken() then
		return
	end

	ctx:cancelTimeout()
	ctx:stateSet("entity", ent)
	ctx:triggerFlow("Finish")
end

function DialogueGraphCreateVirtualEntityNode.run(ctx)
	ctx:startTimeout(5, function()
		finishCallback(ctx, nil, "timeout")
	end)

	local param = {
		entityId = ctx:getField("entityId", 0),
		entityType = ctx:getInput("virtualEntityTypeVInput", 0),
		templateId = ctx:getInput("slotParamVInput", 0),
		position = DialogueGraphUtils.toVector3(ctx:getInput("positionVInput")),
		rotation = DialogueGraphUtils.toVector3(ctx:getInput("rotationVInput")),
		callback = function(ent)
			finishCallback(ctx, ent, "callback")
		end
	}
	local label = ctx:getInput("labelVInput", 0)

	if label > 0 then
		param.label = label
	end

	if ctx:getInput("defaultHideVInput", false) then
		param.visible = false
	end

	if ctx:getField("ignoreGravity", false) then
		param.ignoreGravity = true
	end

	ctx:callCmd(NodeFunc.ENTITY_CREATE_REF_VIRTUAL, param)
	ctx:triggerFlow("Out")
end

function DialogueGraphCreateVirtualEntityNode.getEntityID(ctx)
	local ent = ctx:stateGet("entity", nil)

	if ent == nil then
		return nil
	end

	return ent.id
end

function DialogueGraphCreateVirtualEntityNode.getBoneTransform(ctx)
	local ent = ctx:stateGet("entity", nil)

	if ent == nil then
		return nil
	end

	local boneName = ctx:getInput("boneNameVInput")

	if not string.isNilOrEmpty(boneName) then
		local modelView = ent.modelView or ent.eModel
		local skeletonView = modelView and modelView.skeletonView

		if skeletonView ~= nil then
			local bone

			if skeletonView.GetBone ~= nil then
				bone = skeletonView:GetBone(boneName)
			end

			if bone ~= nil then
				return bone
			end
		end
	end

	local agent = CSEntityManager:GetPositionAgentById(ent.id)

	return agent
end

DialogueGraphCreateVirtualEntityNode.getEntityIDValue = DialogueGraphCreateVirtualEntityNode.getEntityID
DialogueGraphCreateVirtualEntityNode.getBoneTrans = DialogueGraphCreateVirtualEntityNode.getBoneTransform

return DialogueGraphCreateVirtualEntityNode
