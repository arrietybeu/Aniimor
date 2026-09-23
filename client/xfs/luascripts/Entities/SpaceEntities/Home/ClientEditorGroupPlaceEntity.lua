-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientEditorGroupPlaceEntity.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local ClientEditorTemplateGroupEntity = require("Entities.SpaceEntities.Home.ClientEditorTemplateGroupEntity")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local ClientEditorGroupPlaceEntity = Class.Class("ClientEditorGroupPlaceEntity", ClientEditorTemplateGroupEntity)
local CacheEntityNum = 10
local ExtendDir = {
	MinY = 5,
	MaxZ = 4,
	MinZ = 3,
	MaxX = 2,
	MinX = 1,
	MaxY = 6
}
local DiagonalDir = {
	XNeg = 2,
	XPos = 1,
	ZNeg = 4,
	ZPos = 3
}
local PointDir = {
	XPosZPos = 1,
	XNegZNeg = 4,
	XNegZPos = 3,
	XPosZNeg = 2
}
local DIRECTIONAL_EXTEND_OFFSET = 6

function ClientEditorGroupPlaceEntity:init(dict)
	local result = ClientEditorGroupPlaceEntity.super.init(self, dict)

	self.homeTemplateId = dict.homeTemplateId
	self.templateEntityType = dict.templateType
	self.editor = dict.editor
	self.templateData = dict.templateData or {}
	self.groupPlaceChilds = {}
	self.cacheEntities = {}
	self.groupPlaceChildCount = 0
	self.groupExtend = {
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	}
	self.pointType = self.templateData.groupPlacePoint

	if self.pointType then
		self.groupPlaceType = nil
		self.diagonalType = nil
	else
		self.groupPlaceType = self.templateData.groupPlace
		self.diagonalType = self.templateData.groupPlaceDiagonal
	end

	self.originEntity = dict.originEntity

	return result
end

function ClientEditorGroupPlaceEntity:start()
	ClientEditorGroupPlaceEntity.super.start(self)
	self:initHomePlaceHandles()
	self:refreshChildEntities()
end

function ClientEditorGroupPlaceEntity:destroy()
	self:destroyHomePlaceHandles()
	self:destroyCacheEntities()
	ClientEditorGroupPlaceEntity.super.destroy(self)
end

function ClientEditorGroupPlaceEntity:getChildItemBounds()
	return self.templateData.boundSize or {
		1,
		1
	}
end

function ClientEditorGroupPlaceEntity:getChildItemBoundHeight()
	return self.templateData.modelHeight or 1
end

function ClientEditorGroupPlaceEntity:checkShowBoundAreaEffect()
	return false
end

function ClientEditorGroupPlaceEntity:getGroupMaxNum()
	return self.templateData.groupMaxNum or 9
end

function ClientEditorGroupPlaceEntity:isPointPlace()
	return self.pointType == PointDir.XPosZPos or self.pointType == PointDir.XPosZNeg or self.pointType == PointDir.XNegZPos or self.pointType == PointDir.XNegZNeg
end

function ClientEditorGroupPlaceEntity:getDirectionalDirs()
	if self:isPointPlace() then
		return {
			self.pointType
		}
	end

	if self:isDiagonalX() or self:isDiagonalZ() then
		return {
			self.diagonalType
		}
	end

	return {}
end

function ClientEditorGroupPlaceEntity:isDiagonalX()
	return self.diagonalType == DiagonalDir.XPos or self.diagonalType == DiagonalDir.XNeg
end

function ClientEditorGroupPlaceEntity:isDiagonalZ()
	return self.diagonalType == DiagonalDir.ZPos or self.diagonalType == DiagonalDir.ZNeg
end

function ClientEditorGroupPlaceEntity:getDirectionalStepVector(dir)
	local boundSize = self:getChildItemBounds()
	local boundHeight = self:getChildItemBoundHeight()
	local sx, sz = 0, 0

	if self:isPointPlace() then
		sx = (dir == PointDir.XPosZPos or dir == PointDir.XPosZNeg) and 1 or -1
		sz = (dir == PointDir.XPosZPos or dir == PointDir.XNegZPos) and 1 or -1
	elseif dir == DiagonalDir.XPos then
		sx = 1
	elseif dir == DiagonalDir.XNeg then
		sx = -1
	elseif dir == DiagonalDir.ZPos then
		sz = 1
	elseif dir == DiagonalDir.ZNeg then
		sz = -1
	end

	return Vector3(sx * boundSize[1], boundHeight, sz * boundSize[2])
end

function ClientEditorGroupPlaceEntity:createChildEntity(relativePos, relativeRot, originEntity)
	local position = self:getRelativePosition(relativePos)
	local rotation = self:getRelativeRotation(relativeRot)
	local childEntity

	if #self.cacheEntities > 0 then
		childEntity = table.remove(self.cacheEntities)

		childEntity:setActive(ClientConst.MODEL_VISIBLE_KEY.DESTROYED, true)
		childEntity:setPosition(position)
		childEntity:setRotation(rotation)
		childEntity:onEntityPositionChanged()
	else
		local extraInfo = originEntity and {
			originEntity = originEntity
		} or nil

		childEntity = self.editor:createTemplateObject(self.templateEntityType, self.homeTemplateId, position, rotation, self.templateData, extraInfo)
	end

	self:addChildEntity(childEntity, relativePos, relativeRot)

	self.groupPlaceChildCount = self.groupPlaceChildCount + 1

	self.editor:updateEditingEntities()

	return childEntity
end

function ClientEditorGroupPlaceEntity:onEntityPositionChanged()
	ClientEditorGroupPlaceEntity.super.onEntityPositionChanged(self)
	self:refreshGroupPlaceHandles()
end

function ClientEditorGroupPlaceEntity:returnCacheChildEntity(childEntity)
	self:removeChildEntity(childEntity)

	self.groupPlaceChildCount = self.groupPlaceChildCount - 1

	self.editor:updateEditingEntities()

	if #self.cacheEntities > CacheEntityNum then
		ClientUtils.safeDestroy(childEntity)

		return
	end

	childEntity:setActive(ClientConst.MODEL_VISIBLE_KEY.DESTROYED, false)
	table.insert(self.cacheEntities, childEntity)
end

function ClientEditorGroupPlaceEntity:destroyCacheEntities()
	for _, childEntity in ipairs(self.cacheEntities) do
		ClientUtils.safeDestroy(childEntity)
	end

	self.cacheEntities = {}
end

function ClientEditorGroupPlaceEntity:getGroupPlaceChildCount()
	return self.groupPlaceChildCount
end

function ClientEditorGroupPlaceEntity:getOrnamentsData()
	local ornamentsData = {}

	for _, childEntityInfo in pairs(self.childEntities) do
		local childEntity = childEntityInfo.entity

		table.insert(ornamentsData, {
			position = childEntity:getPosition(),
			rotation = childEntity:getRotation(),
			homeTemplateId = self.homeTemplateId
		})
	end

	return ornamentsData
end

function ClientEditorGroupPlaceEntity:getGroupExtend()
	local ge = self.groupExtend

	return {
		ge[1],
		ge[2],
		ge[3],
		ge[4],
		ge[5],
		ge[6],
		ge[7],
		ge[8],
		ge[9],
		ge[10]
	}
end

function ClientEditorGroupPlaceEntity:setGroupExtend(extend)
	local changed = false

	for i = 1, 10 do
		if extend[i] ~= nil and self.groupExtend[i] ~= extend[i] then
			self.groupExtend[i] = extend[i]
			changed = true
		end
	end

	if changed then
		self:refreshChildEntities()
		self:refreshGroupPlaceHandles()
	end
end

function ClientEditorGroupPlaceEntity:refreshChildEntities()
	local minX = self.groupExtend[1]
	local maxX = self.groupExtend[2]
	local minZ = self.groupExtend[3]
	local maxZ = self.groupExtend[4]
	local minY = self.groupExtend[5]
	local maxY = self.groupExtend[6]

	for _, ent in pairs(self.groupPlaceChilds) do
		ent.markValid = false
	end

	local boundSize = self:getChildItemBounds()
	local boundHeight = self:getChildItemBoundHeight()

	for x = minX, maxX do
		for z = minZ, maxZ do
			for y = minY, maxY do
				local key = x .. "_" .. y .. "_" .. z
				local placeEnt = self.groupPlaceChilds[key]

				if not placeEnt then
					local relativePos = Vector3(x * boundSize[1], y * boundHeight, z * boundSize[2])
					local relativeRot = Quaternion.identity
					local childOriginEntity

					if key == "0_0_0" then
						childOriginEntity = self.originEntity
					end

					placeEnt = self:createChildEntity(relativePos, relativeRot, childOriginEntity)
					self.groupPlaceChilds[key] = placeEnt
				end

				placeEnt.markValid = true
			end
		end
	end

	for _, dir in ipairs(self:getDirectionalDirs()) do
		local count = self.groupExtend[DIRECTIONAL_EXTEND_OFFSET + dir]
		local step = self:getDirectionalStepVector(dir)
		local orthoMin, orthoMax, orthoStep = 0, 0, Vector3(0, 0, 0)

		if not self:isPointPlace() and self:isDiagonalX() then
			orthoMin, orthoMax, orthoStep = minZ, maxZ, Vector3(0, 0, boundSize[2])
		elseif not self:isPointPlace() and self:isDiagonalZ() then
			orthoMin, orthoMax, orthoStep = minX, maxX, Vector3(boundSize[1], 0, 0)
		end

		local keyPrefix = self:isPointPlace() and "p" or "d"

		for ortho = orthoMin, orthoMax do
			local orthoOffset = orthoStep * ortho

			for n = 1, count do
				local key = keyPrefix .. dir .. "_" .. n .. "_" .. ortho
				local placeEnt = self.groupPlaceChilds[key]

				if not placeEnt then
					placeEnt = self:createChildEntity(step * n + orthoOffset, Quaternion.identity)
					self.groupPlaceChilds[key] = placeEnt
				end

				placeEnt.markValid = true
			end
		end
	end

	for key, ent in pairs(self.groupPlaceChilds) do
		if not ent.markValid then
			self:returnCacheChildEntity(ent)

			self.groupPlaceChilds[key] = nil
		end
	end
end

function ClientEditorGroupPlaceEntity:getGroupMainEntity()
	return self.groupPlaceChilds["0_0_0"]
end

function ClientEditorGroupPlaceEntity:getBoundAreaRange(isLocal)
	if self:isPointPlace() or self:isDiagonalX() or self:isDiagonalZ() then
		return ClientEditorGroupPlaceEntity.super.getBoundAreaRange(self, isLocal)
	end

	return self:getBoundAreaRangeBySize(self.groupExtend[1], self.groupExtend[2], self.groupExtend[3], self.groupExtend[4], self.groupExtend[5], self.groupExtend[6], isLocal)
end

function ClientEditorGroupPlaceEntity:getBoundAreaRangeBySize(minX, maxX, minZ, maxZ, minY, maxY, isLocal)
	local boundSize = self:getChildItemBounds()
	local boundHeight = self:getChildItemBoundHeight()
	local areaLocalMinX = minX * boundSize[1] - boundSize[1] * 0.5
	local areaLocalMaxX = maxX * boundSize[1] + boundSize[1] * 0.5
	local areaLocalMinZ = minZ * boundSize[2] - boundSize[2] * 0.5
	local areaLocalMaxZ = maxZ * boundSize[2] + boundSize[2] * 0.5
	local areaLocalMinY = (minY or 0) * boundHeight
	local areaLocalMaxY = ((maxY or 0) + 1) * boundHeight

	if isLocal then
		return areaLocalMinX, areaLocalMaxX, areaLocalMinZ, areaLocalMaxZ, areaLocalMinY, areaLocalMaxY
	end

	Vector3.enableCreateFromCache()

	local worldMinPos = self:getRelativePosition(Vector3(areaLocalMinX, 0, areaLocalMinZ))
	local worldMaxPos = self:getRelativePosition(Vector3(areaLocalMaxX, 0, areaLocalMaxZ))
	local wMinX = math.min(worldMinPos.x, worldMaxPos.x)
	local wMinZ = math.min(worldMinPos.z, worldMaxPos.z)
	local wMaxX = math.max(worldMinPos.x, worldMaxPos.x)
	local wMaxZ = math.max(worldMinPos.z, worldMaxPos.z)
	local selfPosition = self:getPosition()

	if self.baseTransMatrixInv then
		selfPosition = self.baseTransMatrixInv:MultiplyPoint(selfPosition)
	end

	local resultMinX = wMinX - selfPosition.x
	local resultMaxX = wMaxX - selfPosition.x
	local resultMinZ = wMinZ - selfPosition.z
	local resultMaxZ = wMaxZ - selfPosition.z

	Vector3.disableCreateFromCache()

	return resultMinX, resultMaxX, resultMinZ, resultMaxZ, areaLocalMinY, areaLocalMaxY
end

function ClientEditorGroupPlaceEntity:getValidExtendValue(targetValue, extendDir)
	local ge = self.groupExtend

	local function checkAt(eMinX, eMaxX, eMinZ, eMaxZ, eMinY, eMaxY)
		local minX, maxX, minZ, maxZ, minY, maxY = self:getBoundAreaRangeBySize(eMinX, eMaxX, eMinZ, eMaxZ, eMinY, eMaxY)

		return self.editor:checkEditAreaInRangeWithY(self.editor:getLocalPosition(self:getPosition()), minX, maxX, minZ, maxZ, minY, maxY)
	end

	if extendDir == ExtendDir.MinX then
		for x = targetValue, 0 do
			if checkAt(x, ge[2], ge[3], ge[4], ge[5], ge[6]) then
				return x
			end
		end
	elseif extendDir == ExtendDir.MaxX then
		for x = targetValue, 0, -1 do
			if checkAt(ge[1], x, ge[3], ge[4], ge[5], ge[6]) then
				return x
			end
		end
	elseif extendDir == ExtendDir.MinZ then
		for z = targetValue, 0 do
			if checkAt(ge[1], ge[2], z, ge[4], ge[5], ge[6]) then
				return z
			end
		end
	elseif extendDir == ExtendDir.MaxZ then
		for z = targetValue, 0, -1 do
			if checkAt(ge[1], ge[2], ge[3], z, ge[5], ge[6]) then
				return z
			end
		end
	elseif extendDir == ExtendDir.MaxY then
		for y = targetValue, 0, -1 do
			if checkAt(ge[1], ge[2], ge[3], ge[4], ge[5], y) then
				return y
			end
		end
	end

	return targetValue
end

function ClientEditorGroupPlaceEntity:onInteractHandle(handle, extendDir)
	local handlePos = handle:GetHandlePosition()
	local localPosition = self:getInverseRelativePosition(handlePos)
	local value = 0
	local boundSize = self:getChildItemBounds()
	local boundHeight = self:getChildItemBoundHeight()
	local ge = self.groupExtend

	local function emit(newExtend)
		self.editor:doExtend(newExtend)
	end

	local maxNum = self:getGroupMaxNum()

	if extendDir == ExtendDir.MinX then
		value = localPosition.x

		local minX = math.min(0, math.round((value + boundSize[1] * 0.5) / boundSize[1]))

		minX = math.max(minX, ge[2] - maxNum)
		minX = self:getValidExtendValue(minX, extendDir)

		if minX ~= ge[1] then
			emit({
				minX,
				ge[2],
				ge[3],
				ge[4],
				ge[5],
				ge[6]
			})
		else
			self:refreshGroupPlaceHandles()
		end
	elseif extendDir == ExtendDir.MaxX then
		value = localPosition.x

		local maxX = math.max(0, math.round((value - boundSize[1] * 0.5) / boundSize[1]))

		maxX = math.min(maxX, ge[1] + maxNum)
		maxX = self:getValidExtendValue(maxX, extendDir)

		if maxX ~= ge[2] then
			emit({
				ge[1],
				maxX,
				ge[3],
				ge[4],
				ge[5],
				ge[6]
			})
		else
			self:refreshGroupPlaceHandles()
		end
	elseif extendDir == ExtendDir.MinZ then
		value = localPosition.z

		local minZ = math.min(0, math.round((value + boundSize[2] * 0.5) / boundSize[2]))

		minZ = math.max(minZ, ge[4] - maxNum)
		minZ = self:getValidExtendValue(minZ, extendDir)

		if minZ ~= ge[3] then
			emit({
				ge[1],
				ge[2],
				minZ,
				ge[4],
				ge[5],
				ge[6]
			})
		else
			self:refreshGroupPlaceHandles()
		end
	elseif extendDir == ExtendDir.MaxZ then
		value = localPosition.z

		local maxZ = math.max(0, math.round((value - boundSize[2] * 0.5) / boundSize[2]))

		maxZ = math.min(maxZ, ge[3] + maxNum)
		maxZ = self:getValidExtendValue(maxZ, extendDir)

		if maxZ ~= ge[4] then
			emit({
				ge[1],
				ge[2],
				ge[3],
				maxZ,
				ge[5],
				ge[6]
			})
		else
			self:refreshGroupPlaceHandles()
		end
	elseif extendDir == ExtendDir.MaxY then
		value = localPosition.y

		local maxY = math.max(0, math.round(value / boundHeight) - 1)

		maxY = math.min(maxY, maxNum)
		maxY = self:getValidExtendValue(maxY, extendDir)

		if maxY ~= ge[6] then
			emit({
				ge[1],
				ge[2],
				ge[3],
				ge[4],
				ge[5],
				maxY
			})
		else
			self:refreshGroupPlaceHandles()
		end
	end
end

function ClientEditorGroupPlaceEntity:getDirectionalBoundRange(dir, count)
	Vector3.enableCreateFromCache()

	local boundSize = self:getChildItemBounds()
	local boundHeight = self:getChildItemBoundHeight()
	local sizeX, sizeZ = boundSize[1], boundSize[2]
	local step = self:getDirectionalStepVector(dir)
	local minX, maxX = -sizeX * 0.5, sizeX * 0.5
	local minZ, maxZ = -sizeZ * 0.5, sizeZ * 0.5
	local minY, maxY = 0, boundHeight

	for n = 1, count do
		local cx, cy, cz = step.x * n, step.y * n, step.z * n

		minX = math.min(minX, cx - sizeX * 0.5)
		maxX = math.max(maxX, cx + sizeX * 0.5)
		minZ = math.min(minZ, cz - sizeZ * 0.5)
		maxZ = math.max(maxZ, cz + sizeZ * 0.5)
		minY = math.min(minY, cy)
		maxY = math.max(maxY, cy + boundHeight)
	end

	local worldMinPos = self:getRelativePosition(Vector3(minX, 0, minZ))
	local worldMaxPos = self:getRelativePosition(Vector3(maxX, 0, maxZ))
	local wMinX = math.min(worldMinPos.x, worldMaxPos.x)
	local wMinZ = math.min(worldMinPos.z, worldMaxPos.z)
	local wMaxX = math.max(worldMinPos.x, worldMaxPos.x)
	local wMaxZ = math.max(worldMinPos.z, worldMaxPos.z)
	local selfPosition = self:getPosition()

	if self.baseTransMatrixInv then
		selfPosition = self.baseTransMatrixInv:MultiplyPoint(selfPosition)
	end

	local resultMinX = wMinX - selfPosition.x
	local resultMaxX = wMaxX - selfPosition.x
	local resultMinZ = wMinZ - selfPosition.z
	local resultMaxZ = wMaxZ - selfPosition.z

	Vector3.disableCreateFromCache()

	return resultMinX, resultMaxX, resultMinZ, resultMaxZ, minY, maxY
end

function ClientEditorGroupPlaceEntity:getValidDirectionalExtendValue(dir, targetCount)
	for c = targetCount, 0, -1 do
		local minX, maxX, minZ, maxZ, minY, maxY = self:getDirectionalBoundRange(dir, c)

		if self.editor:checkEditAreaInRangeWithY(self.editor:getLocalPosition(self:getPosition()), minX, maxX, minZ, maxZ, minY, maxY) then
			return c
		end
	end

	return 0
end

function ClientEditorGroupPlaceEntity:onInteractDirectionalHandle(handle, dir)
	Vector3.enableCreateFromCache()

	local localPosition = self:getInverseRelativePosition(handle:GetHandlePosition())
	local step = self:getDirectionalStepVector(dir)
	local stepLenSq = step.x * step.x + step.y * step.y + step.z * step.z
	local proj = (localPosition.x * step.x + localPosition.y * step.y + localPosition.z * step.z) / stepLenSq
	local count = math.max(0, math.round(proj - 0.5))

	Vector3.disableCreateFromCache()

	count = math.min(count, self:getGroupMaxNum())
	count = self:getValidDirectionalExtendValue(dir, count)

	local idx = DIRECTIONAL_EXTEND_OFFSET + dir

	if count ~= self.groupExtend[idx] then
		local newExtend = self:getGroupExtend()

		newExtend[idx] = count

		self.editor:doExtend(newExtend)
	else
		self:refreshGroupPlaceHandles()
	end
end

function ClientEditorGroupPlaceEntity:createGroupPlaceHandle(key)
	return pg.global.ui:createEmptyTransformHandle(key, AddressDataConst.HOMELAND_NORMAL_POSITION_HANDLE)
end

function ClientEditorGroupPlaceEntity:hasXHandle()
	if self:isDiagonalX() then
		return false
	end

	local t = self.groupPlaceType

	return t == ClientConst.HomeGroupPlaceType.X or t == ClientConst.HomeGroupPlaceType.XZ or t == ClientConst.HomeGroupPlaceType.XY or t == ClientConst.HomeGroupPlaceType.XYZ
end

function ClientEditorGroupPlaceEntity:hasZHandle()
	if self:isDiagonalZ() then
		return false
	end

	local t = self.groupPlaceType

	return t == ClientConst.HomeGroupPlaceType.Z or t == ClientConst.HomeGroupPlaceType.XZ or t == ClientConst.HomeGroupPlaceType.YZ or t == ClientConst.HomeGroupPlaceType.XYZ
end

function ClientEditorGroupPlaceEntity:hasYHandle()
	if self:isDiagonalX() or self:isDiagonalZ() then
		return false
	end

	local t = self.groupPlaceType

	return t == ClientConst.HomeGroupPlaceType.Y or t == ClientConst.HomeGroupPlaceType.XY or t == ClientConst.HomeGroupPlaceType.YZ or t == ClientConst.HomeGroupPlaceType.XYZ
end

function ClientEditorGroupPlaceEntity:initHomePlaceHandles()
	if self:hasXHandle() then
		local xKey1 = "HomeEntityHandleX1"
		local xKey2 = "HomeEntityHandleX2"

		self.xGroupPlaceHandle1 = self:createGroupPlaceHandle(xKey1)
		self.xGroupPlaceHandle2 = self:createGroupPlaceHandle(xKey2)

		self.xGroupPlaceHandle1:SetHandleAxis(ClientConst.HandleAxis.Z)
		self.xGroupPlaceHandle2:SetHandleAxis(ClientConst.HandleAxis.Z)
		self.xGroupPlaceHandle1:SetHandleSpace(ClientConst.HandleSpaceType.Self)
		self.xGroupPlaceHandle2:SetHandleSpace(ClientConst.HandleSpaceType.Self)

		function self.xGroupPlaceHandle1.luaInteract()
			self:onInteractHandle(self.xGroupPlaceHandle1, ExtendDir.MinX)
		end

		function self.xGroupPlaceHandle1.luaInteractEnd()
			self.editor:endExtend()
		end

		function self.xGroupPlaceHandle2.luaInteract()
			self:onInteractHandle(self.xGroupPlaceHandle2, ExtendDir.MaxX)
		end

		function self.xGroupPlaceHandle2.luaInteractEnd()
			self.editor:endExtend()
		end
	end

	if self:hasZHandle() then
		local zKey1 = "HomeEntityHandleZ1"
		local zKey2 = "HomeEntityHandleZ2"

		self.zGroupPlaceHandle1 = self:createGroupPlaceHandle(zKey1)
		self.zGroupPlaceHandle2 = self:createGroupPlaceHandle(zKey2)

		self.zGroupPlaceHandle1:SetHandleAxis(ClientConst.HandleAxis.Z)
		self.zGroupPlaceHandle2:SetHandleAxis(ClientConst.HandleAxis.Z)
		self.zGroupPlaceHandle1:SetHandleSpace(ClientConst.HandleSpaceType.Self)
		self.zGroupPlaceHandle2:SetHandleSpace(ClientConst.HandleSpaceType.Self)

		function self.zGroupPlaceHandle1.luaInteract()
			self:onInteractHandle(self.zGroupPlaceHandle1, ExtendDir.MinZ)
		end

		function self.zGroupPlaceHandle1.luaInteractEnd()
			self.editor:endExtend()
		end

		function self.zGroupPlaceHandle2.luaInteract()
			self:onInteractHandle(self.zGroupPlaceHandle2, ExtendDir.MaxZ)
		end

		function self.zGroupPlaceHandle2.luaInteractEnd()
			self.editor:endExtend()
		end
	end

	if self:hasYHandle() then
		local yKey2 = "HomeEntityHandleY2"

		self.yGroupPlaceHandle2 = self:createGroupPlaceHandle(yKey2)

		self.yGroupPlaceHandle2:SetHandleAxis(ClientConst.HandleAxis.Z)
		self.yGroupPlaceHandle2:SetHandleSpace(ClientConst.HandleSpaceType.Self)

		function self.yGroupPlaceHandle2.luaInteract()
			self:onInteractHandle(self.yGroupPlaceHandle2, ExtendDir.MaxY)
		end

		function self.yGroupPlaceHandle2.luaInteractEnd()
			self.editor:endExtend()
		end
	end

	local directionalDirs = self:getDirectionalDirs()

	if #directionalDirs > 0 then
		self.directionalHandles = {}

		for _, dir in ipairs(directionalDirs) do
			local keyPrefix = self:isPointPlace() and "HomeEntityHandlePoint" or "HomeEntityHandleDiag"
			local handle = self:createGroupPlaceHandle(keyPrefix .. dir)

			handle:SetHandleAxis(ClientConst.HandleAxis.Z)
			handle:SetHandleSpace(ClientConst.HandleSpaceType.Self)

			function handle.luaInteract()
				self:onInteractDirectionalHandle(handle, dir)
			end

			function handle.luaInteractEnd()
				self.editor:endExtend()
			end

			self.directionalHandles[dir] = handle
		end
	end

	self:refreshGroupPlaceHandles()
end

function ClientEditorGroupPlaceEntity:destroyHomePlaceHandles()
	if self.xGroupPlaceHandle1 then
		pg.global.ui:destroyTransformHandle(self.xGroupPlaceHandle1)

		self.xGroupPlaceHandle1 = nil
	end

	if self.xGroupPlaceHandle2 then
		pg.global.ui:destroyTransformHandle(self.xGroupPlaceHandle2)

		self.xGroupPlaceHandle2 = nil
	end

	if self.zGroupPlaceHandle1 then
		pg.global.ui:destroyTransformHandle(self.zGroupPlaceHandle1)

		self.zGroupPlaceHandle1 = nil
	end

	if self.zGroupPlaceHandle2 then
		pg.global.ui:destroyTransformHandle(self.zGroupPlaceHandle2)

		self.zGroupPlaceHandle2 = nil
	end

	if self.yGroupPlaceHandle2 then
		pg.global.ui:destroyTransformHandle(self.yGroupPlaceHandle2)

		self.yGroupPlaceHandle2 = nil
	end

	if self.directionalHandles then
		for _, handle in pairs(self.directionalHandles) do
			pg.global.ui:destroyTransformHandle(handle)
		end

		self.directionalHandles = nil
	end
end

function ClientEditorGroupPlaceEntity:refreshGroupPlaceHandles()
	local minX = self.groupExtend[1]
	local maxX = self.groupExtend[2]
	local minZ = self.groupExtend[3]
	local maxZ = self.groupExtend[4]
	local minY = self.groupExtend[5]
	local maxY = self.groupExtend[6]
	local boundSize = self:getChildItemBounds()
	local boundHeight = self:getChildItemBoundHeight()

	Vector3.enableCreateFromCache()

	if self.xGroupPlaceHandle1 then
		self.xGroupPlaceHandle1:SetHandlePosition(self:getRelativePosition(Vector3(boundSize[1] * (-0.5 + minX), 0.2, 0)))
		self.xGroupPlaceHandle2:SetHandlePosition(self:getRelativePosition(Vector3(boundSize[1] * (0.5 + maxX), 0.2, 0)))
		self.xGroupPlaceHandle1:SetHandleRotation(self:getRelativeRotation(Quaternion.LookRotation(Vector3(-1, 0, 0), Vector3.constUp)))
		self.xGroupPlaceHandle2:SetHandleRotation(self:getRelativeRotation(Quaternion.LookRotation(Vector3(1, 0, 0), Vector3.constUp)))
	end

	if self.zGroupPlaceHandle1 then
		self.zGroupPlaceHandle1:SetHandlePosition(self:getRelativePosition(Vector3(0, 0.2, boundSize[2] * (-0.5 + minZ))))
		self.zGroupPlaceHandle2:SetHandlePosition(self:getRelativePosition(Vector3(0, 0.2, boundSize[2] * (0.5 + maxZ))))
		self.zGroupPlaceHandle1:SetHandleRotation(self:getRelativeRotation(Quaternion.LookRotation(Vector3(0, 0, -1), Vector3.constUp)))
		self.zGroupPlaceHandle2:SetHandleRotation(self:getRelativeRotation(Quaternion.LookRotation(Vector3(0, 0, 1), Vector3.constUp)))
	end

	if self.yGroupPlaceHandle2 then
		self.yGroupPlaceHandle2:SetHandlePosition(self:getRelativePosition(Vector3(0, boundHeight * (maxY + 1), 0)))
		self.yGroupPlaceHandle2:SetHandleRotation(self:getRelativeRotation(Quaternion.LookRotation(Vector3(0, 1, 0), Vector3.constForward)))
	end

	if self.directionalHandles then
		for dir, handle in pairs(self.directionalHandles) do
			local step = self:getDirectionalStepVector(dir)
			local count = self.groupExtend[DIRECTIONAL_EXTEND_OFFSET + dir]

			handle:SetHandlePosition(self:getRelativePosition(step * (count + 0.5)))
			handle:SetHandleRotation(self:getRelativeRotation(Quaternion.LookRotation(step, Vector3.constUp)))
		end
	end

	Vector3.disableCreateFromCache()
end

return ClientEditorGroupPlaceEntity
