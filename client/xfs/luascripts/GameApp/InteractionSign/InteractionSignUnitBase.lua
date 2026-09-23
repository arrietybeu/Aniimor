-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\InteractionSign\\InteractionSignUnitBase.lua

local Class = require("Core.Framework.Class")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local InteractionSignUnitBase = Class.LightClass("InteractionSignUnitBase")

function InteractionSignUnitBase:ctor(globalId, data)
	self.globalId = globalId
	self.cfgId = data.cfgId
	self.funcId = data.funcId

	if data.checkBlock == nil then
		self.checkBlock = true
	else
		self.checkBlock = data.checkBlock
	end

	self.skeletonName = data.skeletonName
	self.offset = data.offset
	self.activeByFuncAction = data.activeByFuncAction or false
	self.isShowInInteractDist = data.isShowInInteractDist or false
	self.distanceGroupMin, self.distanceGroupMax, self.groupNum = self:_preDealDistanceGroup(data.distanceGroup)
	self.animeGroup = data.animeGroup or {}
	self.interactAnimeGroup = data.interactAnimeGroup or {}
	self.prefabPath = data.prefabPath
	self.anchorCacheKey = self:buildAnchorCacheKey()
end

function InteractionSignUnitBase:buildAnchorCacheKey()
	return tostring(self.skeletonName or "") .. "|" .. tostring(self.offset or "")
end

function InteractionSignUnitBase:_preDealDistanceGroup(distanceGroup)
	if distanceGroup then
		local minDistance = {}
		local maxDistance = {}

		for idx, group in ipairs(distanceGroup) do
			minDistance[idx] = group[2]
			maxDistance[idx] = group[1]
		end

		return minDistance, maxDistance, #minDistance
	end

	return nil, nil, 0
end

function InteractionSignUnitBase:checkCanShow()
	local ent = pg.getEntityByGlobalId(self.globalId)

	if not ent then
		return false
	end

	local pawn = pg.pawn

	if not pawn then
		return false
	end

	local ret = not AutoPathFindUtils.checkEntityBlock(pawn, ent)

	return ret
end

function InteractionSignUnitBase:getTargetPos(ent)
	ent = ent or pg.getEntityByGlobalId(self.globalId)

	if not ent then
		return
	end

	local targetPos

	if self.skeletonName and ent.eModel then
		local res, bonePos = ent.eModel.skeletonView:TryGetBonePos(self.skeletonName)

		if res == true then
			targetPos = bonePos
		end
	end

	if targetPos == nil then
		local headY = 0

		if ent.eModel then
			headY = ent.eModel.height
		end

		targetPos = ent:getPosition() + Vector3(0, headY * 0.5, 0)
	end

	if self.offset then
		targetPos = targetPos + self.offset
	end

	return targetPos
end

function InteractionSignUnitBase:getDistanceWithPlayer(ent)
	if not ent then
		return 999
	end

	if ent.getPlayerDistance then
		return ent:getPlayerDistance()
	end

	if ent.getPlayerYDistance then
		return ent:getPlayerYDistance()
	end
end

function InteractionSignUnitBase:getDistanceGroupIdx(curDistance)
	if self.groupNum > 0 then
		for i = 1, self.groupNum do
			if curDistance <= self.distanceGroupMax[i] and curDistance > self.distanceGroupMin[i] then
				return i
			end
		end
	end

	return -1
end

return InteractionSignUnitBase
