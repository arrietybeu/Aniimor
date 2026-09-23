-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopCostumeStain\\WorkShopCostumeStainModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local WorkShopCostumeStainModel = Class.LightClass("WorkShopCostumeStainModel", UIModel)
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local WorkShopMaskData = require("Data.design_workshop_data")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AppearanceData = require("Data.appearance_data")
local Const = require("Common.Const.Const")
local MergeMemberTypes = {
	Normal = "Normal",
	SimpleDye = "SimpleDye",
	SecondUV = "SecondUV"
}
local ExampleUnit = {
	stainMatMap = {
		matName_xxx = {
			layerCount = 2,
			matAreas = {
				{
					matTexIdx = -1,
					colors = {
						{
							0,
							0,
							0,
							0
						},
						{
							0,
							0,
							0,
							0
						},
						{
							0,
							0,
							0,
							0
						}
					},
					gradientColors = {
						{
							0,
							0,
							0,
							0
						},
						{
							0,
							0,
							0,
							0
						},
						{
							0,
							0,
							0,
							0
						}
					}
				},
				{
					matTexIdx = -1,
					colors = {
						{
							0,
							0,
							0,
							0
						},
						{
							0,
							0,
							0,
							0
						},
						{
							0,
							0,
							0,
							0
						}
					},
					gradientColors = {
						{
							0,
							0,
							0,
							0
						},
						{
							0,
							0,
							0,
							0
						},
						{
							0,
							0,
							0,
							0
						}
					}
				}
			}
		}
	},
	decalMatMap = {
		matName_xxx = {
			matDecals = {
				{
					scale = 1,
					decTexIdx = -1,
					position = {
						0,
						0,
						0,
						0
					},
					rotation = {
						0,
						0,
						0,
						0
					}
				},
				{
					scale = 1,
					decTexIdx = -1,
					position = {
						0,
						0,
						0,
						0
					},
					rotation = {
						0,
						0,
						0,
						0
					}
				}
			}
		}
	}
}

function WorkShopCostumeStainModel:ctor()
	self.curUnit = {
		stainMatMap = {},
		decalMatMap = {}
	}
	self.adjustDecal = 0
end

function WorkShopCostumeStainModel:initAvatarSceneData(onlyCamera)
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	if self.slotId == AppearancePointEnum.Coat then
		self.avatarScene:setAvatarCameraModeCloseToChest()
	elseif self.slotId == AppearancePointEnum.Trousers then
		self.avatarScene:setAvatarCameraModeCloseToWaist()
	elseif self.slotId == AppearancePointEnum.Gloves then
		self.avatarScene:setAvatarCameraModeCloseToWaist()
	elseif self.slotId == AppearancePointEnum.Socks then
		self.avatarScene:setAvatarCameraModeCloseToThigh()
	elseif self.slotId == AppearancePointEnum.Shoes then
		self.avatarScene:setAvatarCameraModeCloseToFoot()
	end

	if onlyCamera then
		return
	end

	local ent = self.avatarScene:getCurEntity()

	if ent and ent.eModel and self.slotId then
		ent.eModel.modelShaderView:SelectStainOperationSlot(self.slotId)
	end
end

function WorkShopCostumeStainModel:getOperationConsume()
	local consume = {}
	local res = Utils.calculateWsStainConsume(self.curUnit)

	for id, num in pairs(res) do
		consume[#consume + 1] = {
			id = id,
			num = num,
			ownNum = ClientUtils.getItemCountById(id) or 0
		}
	end

	return consume
end

function WorkShopCostumeStainModel:setCurShowClothId(info)
	self.clothId = info.clothId
	self.slotId = info.slotId

	table.clear(self.curUnit)

	if info.unitData then
		table.merge(self.curUnit, info.unitData)
	else
		self:fillCurUnitFromAppliedDesign()
	end

	if self.curUnit.stainMatMap == nil then
		self.curUnit.stainMatMap = {}
	end

	if self.curUnit.decalMatMap == nil then
		self.curUnit.decalMatMap = {}
	end
end

function WorkShopCostumeStainModel:fillCurUnitFromAppliedDesign()
	local appUnit = pg.me and pg.me.appearanceInfo and pg.me.appearanceInfo[self.clothId]

	if not appUnit or not appUnit.designIndex or appUnit.designIndex <= 0 then
		return
	end

	local unit = appUnit.designList and appUnit.designList[appUnit.designIndex]

	if not unit or unit == false or unit == true then
		return
	end

	local rawTable = unit.getRawTable and unit:getRawTable() or unit

	if rawTable and not string.isNilOrEmpty(rawTable.stainMatMap) then
		self.curUnit.stainMatMap = string.toTable(decompressFromStr(rawTable.stainMatMap))
	end

	if rawTable and not string.isNilOrEmpty(rawTable.decalMatMap) then
		self.curUnit.decalMatMap = string.toTable(decompressFromStr(rawTable.decalMatMap))
	end
end

function WorkShopCostumeStainModel:getMatAreas(tab)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView

	if tab == 1 then
		local mergeAreas = self:tryGetMergeGroupAreas(shaderView)

		if mergeAreas then
			return mergeAreas
		end
	end

	local areaList = shaderView:GetMatAreas(tab)
	local res = {}
	local max = areaList.Count or 0

	for i = 1, max do
		res[#res + 1] = {
			idx = areaList[i - 1]
		}
	end

	table.sort(res, function(a, b)
		return a.idx < b.idx
	end)

	for areaIdx, area in ipairs(res) do
		area.name = pg.getFormatText(pg.getGameString("DESIGN_WORKSHOP_AREA"), tostring(areaIdx))
	end

	if tab == 1 then
		local u2Names = shaderView:GetSecondUVDyePresetMatNames()
		local u2n = u2Names.Count or 0

		if u2n > 0 then
			local extraIdx = 0

			for ii = 0, u2n - 1 do
				local matName = u2Names[ii]
				local partCount = shaderView:GetSecondUVDyePartCountByMatName(matName)

				for partIndex = 1, partCount do
					extraIdx = extraIdx + 1
					res[#res + 1] = {
						name = pg.getFormatText(pg.getGameString("DESIGN_WORKSHOP_AREA_1"), tostring(extraIdx)),
						u2MatName = matName,
						u2PartIndex = partIndex
					}
				end
			end
		end

		local simpleNames = shaderView:GetSimpleDyePresetMatNames()
		local sn = simpleNames.Count or 0

		if sn > 0 then
			for simpleIdx = 1, sn do
				res[#res + 1] = {
					name = pg.getFormatText(pg.getGameString("DESIGN_WORKSHOP_AREA_2"), tostring(simpleIdx)),
					simpleMatName = simpleNames[simpleIdx - 1]
				}
			end
		end
	end

	return res
end

function WorkShopCostumeStainModel:buildMergeGroupMembers(shaderView, groupIndex)
	local members = {}
	local memberCount = shaderView:GetValidMergeGroupMemberCount(groupIndex)

	for memberIndex = 0, memberCount - 1 do
		local memberType = shaderView:GetValidMergeGroupMemberType(groupIndex, memberIndex)
		local member = {
			type = memberType
		}

		if memberType == MergeMemberTypes.Normal then
			member.areaIndex = shaderView:GetValidMergeGroupMemberAreaIndex(groupIndex, memberIndex)
		elseif memberType == MergeMemberTypes.SecondUV then
			member.matName = shaderView:GetValidMergeGroupMemberMatName(groupIndex, memberIndex)
			member.partIndex = shaderView:GetValidMergeGroupMemberPartIndex(groupIndex, memberIndex)
		elseif memberType == MergeMemberTypes.SimpleDye then
			member.matName = shaderView:GetValidMergeGroupMemberMatName(groupIndex, memberIndex)
		end

		members[#members + 1] = member
	end

	return members
end

function WorkShopCostumeStainModel:tryGetMergeGroupAreas(shaderView)
	if self.slotId == nil then
		return nil
	end

	local prefabName = shaderView:GetStainPrefabName(self.slotId)

	if prefabName == nil or prefabName == "" then
		return nil
	end

	if not shaderView:TryLoadValidMergeRegionConfig(prefabName) then
		return nil
	end

	local groupCount = shaderView:GetValidMergeGroupCount()

	if groupCount <= 0 then
		return nil
	end

	local res = {}

	for groupIndex = 0, groupCount - 1 do
		local sortOrder = shaderView:GetValidMergeGroupSortOrder(groupIndex)

		res[#res + 1] = {
			mergeGroupId = shaderView:GetValidMergeGroupId(groupIndex),
			groupIndex = groupIndex,
			sortOrder = sortOrder,
			members = self:buildMergeGroupMembers(shaderView, groupIndex),
			enableGradient = shaderView:GetValidMergeGroupEnableGradient(groupIndex) == true,
			name = pg.getFormatText(pg.getGameString("DESIGN_WORKSHOP_MERGE_AREA"), tostring(sortOrder + 1))
		}
	end

	table.sort(res, function(a, b)
		if a.sortOrder == b.sortOrder then
			return (a.groupIndex or 0) < (b.groupIndex or 0)
		end

		return (a.sortOrder or 0) < (b.sortOrder or 0)
	end)

	return res
end

function WorkShopCostumeStainModel:selectMergeGroupHighLight(groupIndex, normalOnly)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView

	shaderView:KillHighLightTween()
	shaderView:SelectHighLightMergeGroup(groupIndex, normalOnly == true)
end

function WorkShopCostumeStainModel:enableMergeGroupSwitches(groupIndex, normalOnly)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView

	shaderView:EnableDyeSwitchesForMergeGroup(groupIndex, normalOnly == true)
end

function WorkShopCostumeStainModel:mergeGroupHasNormal(members)
	if members == nil then
		return false
	end

	for _, member in ipairs(members) do
		if member.type == MergeMemberTypes.Normal then
			return true
		end
	end

	return false
end

function WorkShopCostumeStainModel:getFirstNormalMember(members)
	if members == nil then
		return nil
	end

	for _, member in ipairs(members) do
		if member.type == MergeMemberTypes.Normal then
			return member
		end
	end

	return nil
end

function WorkShopCostumeStainModel:getMergeGroupOriginColor(groupIndex, members, isGradient)
	members = members or self:buildMergeGroupMembers(self.avatarScene:getCurEntity().eModel.shaderView, groupIndex)

	local firstNormal = self:getFirstNormalMember(members)

	if firstNormal then
		return self:getOriginColor(firstNormal.areaIndex, isGradient == true)
	end

	local ent = self.avatarScene:getCurEntity()

	return ent.eModel.shaderView:GetMergeGroupOriginColor(groupIndex)
end

function WorkShopCostumeStainModel:getMergeGroupColor(groupIndex, members, isGradient)
	members = members or self:buildMergeGroupMembers(self.avatarScene:getCurEntity().eModel.shaderView, groupIndex)

	if members == nil or #members == 0 then
		return Color.white
	end

	local firstNormal = self:getFirstNormalMember(members)

	if firstNormal then
		return self:getMatColor(firstNormal.areaIndex, isGradient == true)
	end

	local member = members[1]

	if member.type == MergeMemberTypes.SecondUV then
		return self:getSecondUVDyeColor(member.matName, member.partIndex)
	elseif member.type == MergeMemberTypes.SimpleDye then
		return self:getSimpleDyeColor(member.matName)
	elseif member.type == MergeMemberTypes.Normal then
		return self:getMatColor(member.areaIndex, isGradient == true)
	end

	return Color.white
end

function WorkShopCostumeStainModel:applyMergeGroupColors(members, color, isGradient, enableGradient)
	if members == nil then
		return
	end

	local hasNormal = self:mergeGroupHasNormal(members)

	if hasNormal then
		if enableGradient then
			for _, member in ipairs(members) do
				if member.type == MergeMemberTypes.Normal then
					self:setMatAreaColor(member.areaIndex, color, isGradient == true)
				end
			end
		else
			for _, member in ipairs(members) do
				if member.type == MergeMemberTypes.Normal then
					self:setMatAreaColor(member.areaIndex, color, false)
					self:setMatAreaColor(member.areaIndex, color, true)
				end
			end
		end

		return
	end

	for _, member in ipairs(members) do
		if member.type == MergeMemberTypes.SecondUV then
			self:setSecondUVDyeColor(member.matName, member.partIndex, color)
		elseif member.type == MergeMemberTypes.SimpleDye then
			self:setSimpleDyeColor(member.matName, color)
		elseif member.type == MergeMemberTypes.Normal then
			self:setMatAreaColor(member.areaIndex, color, isGradient == true)
		end
	end
end

function WorkShopCostumeStainModel:selectSimpleDyeHighLight(matName)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView

	shaderView:KillHighLightTween()
	shaderView:SelectHighLightSimpleDyeMat(matName)
	shaderView:EnableDyeSwitchesForSimpleArea(matName)
end

function WorkShopCostumeStainModel:getSimpleDyeColor(matName)
	local cached = self:_getSimpleDyeColorInternal(matName)

	if cached then
		return cached
	end

	local ent = self.avatarScene:getCurEntity()

	return ent.eModel.shaderView:GetSimpleDyeColorByMatName(matName, false)
end

function WorkShopCostumeStainModel:setSimpleDyeColor(matName, color)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView

	shaderView:SetSimpleDyeColorByMatName(matName, color)
	self:_setSimpleDyeColorInternal(matName, color)
end

function WorkShopCostumeStainModel:getSimpleDyeOriginColor(matName)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView

	return shaderView:GetSimpleDyeColorByMatName(matName, true)
end

function WorkShopCostumeStainModel:selectSecondUVHighLight(matName)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView

	shaderView:KillHighLightTween()
	shaderView:SelectHighLightSecondUvMat(matName)
	shaderView:EnableDyeSwitchesFor2UArea(matName)
end

function WorkShopCostumeStainModel:getSecondUVDyeColor(matName, partIndex)
	local cached = self:_getSecondUVDyeColorInternal(matName, partIndex)

	if cached then
		return cached
	end

	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView

	return shaderView:GetSecondUVDyeColorByMatName(matName, partIndex, false)
end

function WorkShopCostumeStainModel:setSecondUVDyeColor(matName, partIndex, color)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView

	shaderView:SetSecondUVDyeColorByMatName(matName, partIndex, color)
	self:_setSecondUVDyeColorInternal(matName, partIndex, color)
end

function WorkShopCostumeStainModel:getSecondUVDyeOriginColor(matName, partIndex)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView

	return shaderView:GetSecondUVDyeColorByMatName(matName, partIndex, true)
end

function WorkShopCostumeStainModel:_getSecondUVDyeColorInternal(matName, partIndex)
	local mat = self.curUnit.stainMatMap[matName]

	if mat == nil then
		return nil
	end

	local parts = mat.secondUVDyeInfo and mat.secondUVDyeInfo.dyeParts or mat.secondUVDyeParts

	if parts == nil then
		return nil
	end

	local p = parts[partIndex]

	if p == nil or p.dyeColor == nil then
		return nil
	end

	local c = p.dyeColor

	return Color(c[1], c[2], c[3], c[4])
end

function WorkShopCostumeStainModel:_setSecondUVDyeColorInternal(matName, partIndex, color)
	local mat = self:getCacheMatInternal(matName)

	if mat.secondUVDyeInfo == nil then
		mat.secondUVDyeInfo = {}
	end

	local suv = mat.secondUVDyeInfo

	suv.enabled = true
	suv.dyeEnable = true
	suv.dyePartCount = math.max(suv.dyePartCount or 0, partIndex)

	if suv.dyeParts == nil then
		suv.dyeParts = {}
	end

	if suv.dyeParts[partIndex] == nil then
		suv.dyeParts[partIndex] = {}
	end

	suv.dyeParts[partIndex].partIndex = partIndex
	suv.dyeParts[partIndex].dyeColor = {
		color.r,
		color.g,
		color.b,
		color.a
	}
end

function WorkShopCostumeStainModel:_getSimpleDyeColorInternal(matName)
	local mat = self.curUnit.stainMatMap[matName]

	if mat == nil or mat.simpleDyeInfo == nil then
		return nil
	end

	local c = mat.simpleDyeInfo.dyeColor

	if c == nil or table.nums(c) < 4 then
		return nil
	end

	return Color(c[1], c[2], c[3], c[4])
end

function WorkShopCostumeStainModel:_setSimpleDyeColorInternal(matName, color)
	local mat = self:getCacheMatInternal(matName)

	if mat.simpleDyeInfo == nil then
		mat.simpleDyeInfo = {
			enabled = true
		}
	end

	mat.simpleDyeInfo.enabled = true
	mat.simpleDyeInfo.dyeColor = {
		color.r,
		color.g,
		color.b,
		color.a
	}
end

function WorkShopCostumeStainModel:getMaskDataList(type)
	local dataList = {}

	for id, v in pairs(WorkShopMaskData) do
		if v.type == type then
			local index = #dataList + 1

			dataList[index] = {
				equip = false,
				res = v.res,
				initialClaim = v.initialClaim,
				id = id
			}
		end
	end

	table.sort(dataList, function(a, b)
		return a.id < b.id
	end)

	for i, v in ipairs(dataList) do
		v.index = i
	end

	return dataList
end

function WorkShopCostumeStainModel:setDecalWithOpName(areaIdx, decalIdx, value, opName)
	if opName == 1 then
		self:setDecalPositionX(areaIdx, decalIdx, value)
	elseif opName == 2 then
		self:setDecalPositionY(areaIdx, decalIdx, value)
	elseif opName == 3 then
		self:setDecalPositionZ(areaIdx, decalIdx, value)
	elseif opName == 4 then
		self:setDecalRotationX(areaIdx, decalIdx, value)
	elseif opName == 5 then
		self:setDecalRotationY(areaIdx, decalIdx, value)
	elseif opName == 6 then
		self:setDecalScale(areaIdx, decalIdx, value)
	end
end

function WorkShopCostumeStainModel:getDecalWithOpName(areaIdx, decalIdx, defaultValue, opName)
	if opName == 1 then
		return self:getDecalPositionX(areaIdx, decalIdx, defaultValue)
	elseif opName == 2 then
		return self:getDecalPositionY(areaIdx, decalIdx, defaultValue)
	elseif opName == 3 then
		return self:getDecalPositionZ(areaIdx, decalIdx, defaultValue)
	elseif opName == 4 then
		return self:getDecalRotationX(areaIdx, decalIdx, defaultValue)
	elseif opName == 5 then
		return self:getDecalRotationY(areaIdx, decalIdx, defaultValue)
	elseif opName == 6 then
		return self:getDecalScale(areaIdx, decalIdx, defaultValue)
	else
		return defaultValue
	end
end

function WorkShopCostumeStainModel:selectAreaHighLight(areaIdx)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView

	shaderView:KillHighLightTween()
	shaderView:SelectHighLight(areaIdx)
	shaderView:EnableDyeSwitchesForNormalArea(areaIdx)
end

function WorkShopCostumeStainModel:killHighLightTween()
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView

	shaderView:KillHighLightTween()
end

function WorkShopCostumeStainModel:setMatAreaColor(areaIdx, color, isGradient)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local passIdx = shaderView:GetPassIndexWithAreaIndex(areaIdx)
	local matName = shaderView:GetMatNameWithAreaIndex(areaIdx)

	shaderView:SetMatAreaColor(areaIdx, color, isGradient)
	self:setMatColorInternal(matName, passIdx, color, isGradient)
end

function WorkShopCostumeStainModel:getMatColor(areaIdx, isGradient)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local passIdx = shaderView:GetPassIndexWithAreaIndex(areaIdx)
	local matName = shaderView:GetMatNameWithAreaIndex(areaIdx)
	local color = self:getMatColorInternal(matName, passIdx, isGradient)

	if color then
		return color
	end

	color = shaderView:GetMatAreaColor(areaIdx or 1, isGradient)

	return color
end

function WorkShopCostumeStainModel:setMatAreaTexIdx(areaIdx, value)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local passIdx = shaderView:GetPassIndexWithAreaIndex(areaIdx)
	local matName = shaderView:GetMatNameWithAreaIndex(areaIdx)

	shaderView:SetMatAreaTexIdx(areaIdx, value)
	self:setMatAreaTexIdxInternal(matName, passIdx, value)
end

function WorkShopCostumeStainModel:getMatAreaTexIdx(areaIdx)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local passIdx = shaderView:GetPassIndexWithAreaIndex(areaIdx)
	local matName = shaderView:GetMatNameWithAreaIndex(areaIdx)
	local value = self:getMatAreaTexIdxInternal(matName, passIdx)

	if value ~= nil then
		return value
	end

	value = shaderView:GetMatAreaTexIdx(areaIdx or 1)

	return value
end

function WorkShopCostumeStainModel:getDecalArrayIdx(decals, decalIdx)
	local index = 0

	for i, v in ipairs(decals) do
		if v.decTexIdx == decalIdx then
			index = i

			break
		end
	end

	return index
end

function WorkShopCostumeStainModel:setDecalTexIdx(areaIdx, value, defaultValue)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)

	for _, v in ipairs(decals.matDecals) do
		if v.decTexIdx == value then
			return
		end
	end

	local decal = {
		decTexIdx = value,
		position = defaultValue.position or {
			0,
			0,
			0,
			0
		},
		rotation = defaultValue.rotation or {
			0,
			0,
			0,
			0
		},
		scale = defaultValue.scale or 1
	}

	decals.matDecals[#decals.matDecals + 1] = decal

	shaderView:SetDecalList(areaIdx, decals.matDecals)
end

function WorkShopCostumeStainModel:unsetDecalTexIdx(areaIdx, value)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)
	local idx = 0

	for i, v in ipairs(decals.matDecals) do
		if v.decTexIdx == value then
			idx = i

			break
		end
	end

	if idx == 0 then
		return
	end

	table.remove(decals.matDecals, idx)
	shaderView:SetDecalList(areaIdx, decals.matDecals)
end

function WorkShopCostumeStainModel:setDecalPositionX(areaIdx, decalIdx, x)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)
	local arrayIdx = self:getDecalArrayIdx(decals.matDecals, decalIdx)
	local decal = decals.matDecals[arrayIdx]

	if decal == nil then
		return
	end

	decal.position[1] = x

	shaderView:SetDecalPosition(areaIdx, decalIdx, decal.position)
end

function WorkShopCostumeStainModel:setDecalPositionY(areaIdx, decalIdx, y)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)
	local arrayIdx = self:getDecalArrayIdx(decals.matDecals, decalIdx)
	local decal = decals.matDecals[arrayIdx]

	if decal == nil then
		return
	end

	decal.position[2] = y

	shaderView:SetDecalPosition(areaIdx, decalIdx, decal.position)
end

function WorkShopCostumeStainModel:setDecalPositionZ(areaIdx, decalIdx, z)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)
	local decal = decals.matDecals[decalIdx]

	if decal == nil then
		return
	end

	decal.position[3] = z

	shaderView:SetDecalPosition(areaIdx, decalIdx, decal.position)
end

function WorkShopCostumeStainModel:setDecalRotationX(areaIdx, decalIdx, x)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)
	local arrayIdx = self:getDecalArrayIdx(decals.matDecals, decalIdx)
	local decal = decals.matDecals[arrayIdx]

	if decal == nil then
		return
	end

	decal.rotation[1] = x

	shaderView:SetDecalRotation(areaIdx, decalIdx, decal.rotation)
end

function WorkShopCostumeStainModel:setDecalRotationY(areaIdx, decalIdx, y)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)
	local arrayIdx = self:getDecalArrayIdx(decals.matDecals, decalIdx)
	local decal = decals.matDecals[arrayIdx]

	if decal == nil then
		return
	end

	decal.rotation[2] = y

	shaderView:SetDecalRotation(areaIdx, decalIdx, decal.rotation)
end

function WorkShopCostumeStainModel:setDecalScale(areaIdx, decalIdx, scale)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)
	local arrayIdx = self:getDecalArrayIdx(decals.matDecals, decalIdx)
	local decal = decals.matDecals[arrayIdx]

	if decal == nil then
		return
	end

	decal.scale = scale

	shaderView:SetDecalScale(areaIdx, decalIdx, scale)
end

function WorkShopCostumeStainModel:getDecalPositionX(areaIdx, decalIdx, defaultValue)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)
	local arrayIdx = self:getDecalArrayIdx(decals.matDecals, decalIdx)
	local decal = decals.matDecals[arrayIdx]

	if decal == nil then
		return defaultValue
	end

	return decal.position[1]
end

function WorkShopCostumeStainModel:getDecalPositionY(areaIdx, decalIdx, defaultValue)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)
	local arrayIdx = self:getDecalArrayIdx(decals.matDecals, decalIdx)
	local decal = decals.matDecals[arrayIdx]

	if decal == nil then
		return defaultValue
	end

	return decal.position[2]
end

function WorkShopCostumeStainModel:getDecalPositionZ(areaIdx, decalIdx, defaultValue)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)
	local decal = decals.matDecals[decalIdx]

	if decal == nil then
		return defaultValue
	end

	return decal.position[3]
end

function WorkShopCostumeStainModel:getDecalRotationX(areaIdx, decalIdx, defaultValue)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)
	local arrayIdx = self:getDecalArrayIdx(decals.matDecals, decalIdx)
	local decal = decals.matDecals[arrayIdx]

	if decal == nil then
		return defaultValue
	end

	return decal.rotation[1]
end

function WorkShopCostumeStainModel:getDecalRotationY(areaIdx, decalIdx, defaultValue)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)
	local arrayIdx = self:getDecalArrayIdx(decals.matDecals, decalIdx)
	local decal = decals.matDecals[arrayIdx]

	if decal == nil then
		return defaultValue
	end

	return decal.rotation[2]
end

function WorkShopCostumeStainModel:getDecalScale(areaIdx, decalIdx, defaultValue)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)
	local arrayIdx = self:getDecalArrayIdx(decals.matDecals, decalIdx)
	local decal = decals.matDecals[arrayIdx]

	if decal == nil then
		return defaultValue
	end

	return decal.scale
end

function WorkShopCostumeStainModel:checkCanAddDecal(areaIdx)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local max = shaderView:GetMaxDecalNum(areaIdx)
	local matName = shaderView:GetDecalMatNameWithAreaIndex(areaIdx)
	local decals = self:getCacheMatDecalInternal(matName)

	return max > #decals.matDecals
end

function WorkShopCostumeStainModel:getMatColorInternal(matName, passIdx, isGradient)
	local area = self:getCacheAreaInternal(matName, passIdx)
	local colorArray

	if isGradient then
		colorArray = area.gradientColors
	else
		colorArray = area.colors
	end

	if colorArray == nil or table.nums(colorArray) < 4 then
		return false
	end

	return Color(colorArray[1], colorArray[2], colorArray[3], colorArray[4])
end

function WorkShopCostumeStainModel:setMatColorInternal(matName, passIdx, color, isGradient)
	local area = self:getCacheAreaInternal(matName, passIdx)

	area.areaEnabled = 1

	if isGradient then
		area.gradientColors = {
			color.r,
			color.g,
			color.b,
			color.a
		}
	else
		area.colors = {
			color.r,
			color.g,
			color.b,
			color.a
		}
	end
end

function WorkShopCostumeStainModel:getMatAreaTexIdxInternal(matName, passIdx)
	local area = self:getCacheAreaInternal(matName, passIdx)

	return area.matTexIdx
end

function WorkShopCostumeStainModel:setMatAreaTexIdxInternal(matName, passIdx, value)
	local area = self:getCacheAreaInternal(matName, passIdx)

	area.matTexIdx = value
end

function WorkShopCostumeStainModel:getCacheAreaInternal(matName, passIdx)
	local mat = self:getCacheMatInternal(matName)
	local matArea = mat.matAreas

	if matArea[passIdx] == nil then
		matArea[passIdx] = {}
	end

	return matArea[passIdx]
end

function WorkShopCostumeStainModel:getCacheMatInternal(matName)
	local mat = self.curUnit.stainMatMap[matName]

	if mat == nil then
		mat = {
			matAreas = {}
		}
		mat.layerCount = self:getMatLayerCount(matName)
		self.curUnit.stainMatMap[matName] = mat
	end

	return mat
end

function WorkShopCostumeStainModel:getCacheMatDecalInternal(matName)
	local mat = self.curUnit.decalMatMap[matName]

	if mat == nil then
		mat = {
			matDecals = {}
		}
		self.curUnit.decalMatMap[matName] = mat
	end

	return mat
end

function WorkShopCostumeStainModel:getMatLayerCount(matName)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local value = shaderView:GetMatLayerCount(matName)

	return value
end

function WorkShopCostumeStainModel:getOriginColor(areaIdx, isGradient)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local value = shaderView:GetOriginColor(areaIdx or 1, isGradient)

	return value
end

function WorkShopCostumeStainModel:getOriginTexIdx(areaIdx)
	local ent = self.avatarScene:getCurEntity()
	local shaderView = ent.eModel.shaderView
	local value = shaderView:GetOriginTexIdx(areaIdx)

	return value
end

function WorkShopCostumeStainModel:onSubmitUnlockPreset(callback)
	pg.me:serverMsg("RPC_CS_UnlockClothesDesignInfo", self.clothId, callback)
end

function WorkShopCostumeStainModel:_onSubmitChangedImpl(index, name, imageKey, callback)
	local submitData = {
		name = name
	}

	submitData.stainMatMap = compressToStr(table.tostring(self.curUnit.stainMatMap))
	submitData.decalMatMap = compressToStr(table.tostring(self.curUnit.decalMatMap))

	pg.me:serverMsg("RPC_CS_DesignClothes", self.clothId, index, submitData, imageKey or "")

	local appearanceData = AppearanceData[self.clothId] or {}
	local points = appearanceData.points or {}

	if pg.me.curShow.customShow[self.slotId] ~= self.clothId then
		pg.me:serverMsg("RPC_CS_SetAppearanceShow", self.clothId, true, self.slotId)
	end

	pg.me:serverMsg("RPC_CS_ApplyClothesDesign", points[1], self.clothId, index, callback)
end

function WorkShopCostumeStainModel:onSubmitChanged(index, name, imageKey, callback)
	local _h = WorkShopCostumeStainModel._platformHooks

	if _h and _h.onSubmitChanged then
		return _h.onSubmitChanged(self, index, name, imageKey, callback)
	end

	self:_onSubmitChangedImpl(index, name, imageKey, callback)
end

function WorkShopCostumeStainModel:redDot_GetPatternItemState(data)
	local showRedDot = false
	local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_CLOTHES_STAIN_PATTERN_ITEM, data.res)

	if not data.initialClaim or data.initialClaim < 1 then
		showRedDot = pg.me:getRedDotRecord(Const.CLIENT_KEY.APPEARANCE_RED_DOT, treePath, true)
	end

	return showRedDot
end

return WorkShopCostumeStainModel
