-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphGetEntityInfoNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local DialogueGraphGetEntityInfoNode = DialogueGraphFlowNode.extend("DialogueGraphGetEntityInfoNode")
local EntityType = require("Const.DialogueGraphConst").EntityType

local function shouldResolveRandomMapStaticId(entityType, staticId)
	staticId = tonumber(staticId) or 0

	return entityType == EntityType.Puppet and staticId > 0
end

local function resolveRandomMapEntityByOriginStaticId(staticId)
	staticId = tonumber(staticId) or 0

	if staticId <= 0 or pg == nil or pg.getEntity == nil then
		return nil
	end

	local ClientUtils = require("Utils.ClientUtils")
	local entityId = ClientUtils.getRandomMapEntityIdByOriginStaticIdForCS(staticId)

	if entityId == nil or entityId == "" then
		return nil
	end

	return pg.getEntity(entityId)
end

local function resolveEntity(ctx)
	local entityType = tonumber(ctx:getField("entityType", EntityType.Player)) or EntityType.Player
	local staticId = ctx:getInput("staticIdVInput", 0)

	if entityType == EntityType.Player then
		return pg and pg.me or nil
	elseif entityType == EntityType.PlayerPet then
		return pg and pg.me and pg.me:getCurPetEntity() or nil
	elseif entityType == EntityType.Pawn then
		return pg and pg.pawn or nil
	elseif entityType == EntityType.Puppet then
		local entity = DialogueGraphUtils.getEntityByStaticId(staticId)

		if entity ~= nil or not shouldResolveRandomMapStaticId(entityType, staticId) then
			return entity
		end

		return resolveRandomMapEntityByOriginStaticId(staticId)
	elseif entityType == EntityType.HomeFacility then
		local me = pg and pg.me
		local ent = HomeLandUtils.getHomeFacilityEntity(me, staticId)

		if ent then
			return ent
		end

		local ok, pos, rot = HomeLandUtils.getHomeFacilityPointPose(me, staticId)

		if not ok then
			return nil
		end

		return {
			isHomeFacilityPoint = true,
			positionAgent = {
				position = pos,
				eulerAngles = rot and rot.eulerAngles or Vector3.zero
			}
		}
	end

	return DialogueGraphUtils.getEntityByStaticId(staticId)
end

local function getPositionAgentTransform(entity)
	if entity == nil or entity.actorId == nil or CSEntityManager == nil then
		return nil
	end

	local transform = CSEntityManager:GetPositionAgentById(entity.id)

	return not IsNil(transform) and transform or nil
end

local function readEntityPosition(entity)
	if entity == nil then
		return Vector3.zero
	end

	if entity.getPosition then
		return entity:getPosition()
	end

	if entity.positionAgent ~= nil and entity.positionAgent.position ~= nil then
		return entity.positionAgent.position
	end

	return Vector3.zero
end

local function readEntityEuler(entity)
	if entity == nil then
		return Vector3.zero
	end

	if entity.getRotation then
		return entity:getRotation():ToEulerAngles()
	end

	if entity.positionAgent ~= nil and entity.positionAgent.eulerAngles ~= nil then
		return entity.positionAgent.eulerAngles
	end

	return Vector3.zero
end

local function getEntityId(entity)
	if entity == nil then
		return nil
	end

	return entity.id
end

local function getTemplateId(entity)
	if entity == nil then
		return nil
	end

	if entity.templateId ~= nil then
		return entity.templateId
	end

	local luaComponent = entity.luaComponent

	if luaComponent ~= nil and luaComponent.InvokeLua ~= nil then
		local ok, value = SafeCallbackWithStatusAndReturn(function()
			return luaComponent:InvokeLua("getTemplateId")
		end)

		if ok then
			return value
		end
	end

	if entity.getTemplateId ~= nil then
		return entity:getTemplateId()
	end

	return nil
end

local function getBoneTransform(ctx, entity)
	if entity == nil then
		return nil
	end

	local boneName = ctx:getInput("boneNameVInput")

	if not string.isNilOrEmpty(boneName) and entity.eModel ~= nil and entity.eModel.skeletonView ~= nil then
		local skeletonView = entity.eModel.skeletonView

		if skeletonView.GetBone ~= nil then
			local bone = skeletonView:GetBone(boneName)

			if bone ~= nil then
				return bone
			end
		end
	end

	if entity.isHomeFacilityPoint == true and entity.positionAgent ~= nil then
		return ctx:callCmd(NodeFunc.ENTITY_GET_OR_CREATE_HOME_FACILITY_PROXY, ctx:nodeId(), entity.positionAgent.position, entity.positionAgent.eulerAngles)
	end

	return getPositionAgentTransform(entity)
end

function DialogueGraphGetEntityInfoNode.getEntityID(ctx)
	return getEntityId(resolveEntity(ctx))
end

function DialogueGraphGetEntityInfoNode.getTemplateID(ctx)
	return getTemplateId(resolveEntity(ctx)) or -1
end

function DialogueGraphGetEntityInfoNode.getPosition(ctx)
	return readEntityPosition(resolveEntity(ctx))
end

function DialogueGraphGetEntityInfoNode.getEulerAngles(ctx)
	return readEntityEuler(resolveEntity(ctx))
end

function DialogueGraphGetEntityInfoNode.getBoneTransform(ctx)
	return getBoneTransform(ctx, resolveEntity(ctx))
end

return DialogueGraphGetEntityInfoNode
