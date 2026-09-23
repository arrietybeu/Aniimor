-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientEcsUtils.lua

local TopLogoElementSwitchItem = require("Guis.Panels.TopLogo.Node.TopLogoElementSwitchItem")
local ECSConst = require("Const.ECSConst")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local LxGeometry = require("Common.Ability.LxGeometry")
local SysConfigData = require("Data.sys_config_data")
local breakable_grade_data = require("Data.breakable_grade_data")
local Vector3 = Vector3
local ClientEcsUtils = {}

function ClientEcsUtils.doChemFunc(funcId, globalId, partId, arg1)
	local ent = pg.getEntityByGlobalId(globalId)

	if not ent then
		return
	end
end

function ClientEcsUtils.showElementActiveTopLogo(attachTrans, type, distance)
	local elementTopLogo = TopLogoElementSwitchItem.new(attachTrans, type, distance)

	elementTopLogo:createTopLogo()

	return elementTopLogo
end

function ClientEcsUtils.getEcsFireVoxelInfo()
	local info = SysConfigData.ECS_FIRE_VOXEL_INFO
	local forceInfo = info[4] or {}

	return {
		info[1][1],
		info[1][2],
		info[2][1],
		info[2][2],
		info[3][1],
		info[3][2],
		forceInfo[1] or 0,
		forceInfo[2] or 0
	}
end

function ClientEcsUtils.getEcsBreakGradeInfo()
	local ret = {}

	for id, data in pairs(breakable_grade_data) do
		ret[data.level + 1] = data.impulseRange
	end

	return ret
end

function ClientEcsUtils.getVoxelShape(isSphereCollider, radius)
	if isSphereCollider then
		return LxGeometry.LxCircle3D(Vector3.zero, 0, radius / 2, radius, radius)
	else
		return LxGeometry.LxCircle3D(Vector3.zero, 0, radius, radius, radius)
	end
end

function ClientEcsUtils.modifyVoxels(shape, x, y, z)
	if pg.me == nil then
		return
	end

	shape.center:Set(x, y, z)

	local space = pg.me.space

	if space then
		VoxelUtils.doVoxelReact(space.id, "ignite", AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, shape)
	end
end

function ClientEcsUtils.getChemTagList(entity, outTagList)
	outTagList = outTagList or {}

	if entity and entity.ecsShare then
		for stateName, b in pairs(ECSConst.EcsStateDef) do
			if bit.band(entity.ecsShare.state, b) > 0 then
				outTagList[#outTagList + 1] = stateName
			end
		end

		for abilityName, b in pairs(ECSConst.EcsAbilityDef) do
			if bit.band(entity.ecsShare.ability, b) > 0 then
				outTagList[#outTagList + 1] = abilityName
			end
		end
	end

	return outTagList
end

function ClientEcsUtils.setTemperaturePointer(temperature)
	local hudV2 = pg.global and pg.global.ui and pg.global.ui.hudV2
	local temperatureComp = hudV2 and hudV2.LU and hudV2.LU.temperature

	if temperatureComp and temperatureComp.setPointerDegree then
		temperatureComp:setPointerDegree(temperature)
	end
end

function ClientEcsUtils.createEcsShare(id)
	local ecsShare = pg.game.ecs:registerEcsShares(id)

	return ecsShare.shell
end

function ClientEcsUtils.destroyEcsShare(id)
	pg.game.ecs:unregisterEcsShares(id)
end

return ClientEcsUtils
