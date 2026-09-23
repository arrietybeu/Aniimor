-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientEntityEditorComponent.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local BuildConst = require("Common.Homeland.OrnamentBuild.BuildConst")
local HomeEditorOutline = require("GameApp.Home.HomeEditorOutline")
local ClientEntityEditorComponent = Class.Component("ClientEntityEditorComponent")

function ClientEntityEditorComponent:ctor()
	self.entityEditorEffectInfo = {}
	self.entityEditorEffectDict = {}
	self.entityEditorEffectVisibleInfo = {}
	self.entityOutlineInfo = {}
end

function ClientEntityEditorComponent:destroy()
	if self.isInMultiSelect then
		facade:SendMessageCommand(MessageName.ON_MULTISELECT_ENT_DESTROY, {
			self
		})
	end

	HomeEditorOutline.setEntityOutlineColor(self, nil)
	self:stopEntityEditorAllEffect()
end

function ClientEntityEditorComponent:getBaseBoundSize()
	local boundSize = self:getConfigData().boundSize

	if not boundSize and self.getHomelandConfigData then
		boundSize = self:getHomelandConfigData().boundSize
	end

	return boundSize or {
		1,
		1
	}
end

function ClientEntityEditorComponent:getBoundSize()
	local baseBoundSize = self:getBaseBoundSize()

	if self.getScale then
		local s = self:getScale()

		if s.x ~= 1 or s.z ~= 1 then
			return {
				baseBoundSize[1] * s.x,
				baseBoundSize[2] * s.z
			}
		end
	end

	return baseBoundSize
end

function ClientEntityEditorComponent:getBaseBoundHeight()
	local boundHeight = self:getConfigData().modelHeight

	if not boundHeight and self.getHomelandConfigData then
		boundHeight = self:getHomelandConfigData().modelHeight
	end

	return boundHeight or 1
end

function ClientEntityEditorComponent:getBoundHeight()
	local baseBoundHeight = self:getBaseBoundHeight()

	if self.getScale then
		local s = self:getScale()

		if s.y ~= 1 then
			return baseBoundHeight * s.y
		end
	end

	return baseBoundHeight
end

function ClientEntityEditorComponent:setInMultiSelect(inMultiSelect)
	self.isInMultiSelect = inMultiSelect

	if inMultiSelect then
		self:setEditorOutline(ClientConst.EntityEditorOutlinePriority.MutiSelect, true, AddressDataConst.HOMELAND_OUTLINE_GREEN)
	else
		self:setEditorOutline(ClientConst.EntityEditorOutlinePriority.MutiSelect, false)
	end
end

function ClientEntityEditorComponent:setPreMultiSelectMode(preSelectType)
	self.preSelectType = preSelectType

	if preSelectType == true then
		self:setEditorOutline(ClientConst.EntityEditorOutlinePriority.PreMultiSelect, true, AddressDataConst.HOMELAND_OUTLINE_GREEN)
	elseif preSelectType == false then
		self:setEditorOutline(ClientConst.EntityEditorOutlinePriority.PreMultiSelect, true, "")
	else
		self:setEditorOutline(ClientConst.EntityEditorOutlinePriority.PreMultiSelect, false)
	end
end

function ClientEntityEditorComponent:setEditorBoundEffectVisible(effectType, reason, visible)
	local curVisible = self:checkBoundEffectVisible(effectType)

	reason = reason or ClientConst.EditorEffectVisibleReason.Default
	self.entityEditorEffectVisibleInfo[effectType] = self.entityEditorEffectVisibleInfo[effectType] or {}

	if visible then
		self.entityEditorEffectVisibleInfo[effectType][reason] = nil
	else
		self.entityEditorEffectVisibleInfo[effectType][reason] = false
	end

	local newVisible = self:checkBoundEffectVisible(effectType)

	if newVisible == curVisible then
		return
	end

	self:updateEntityEditorEffect()
end

function ClientEntityEditorComponent:checkBoundEffectVisible(effectType)
	if Utils.tableIsEmptyOrNil(self.entityEditorEffectVisibleInfo[effectType]) then
		return true
	end

	return false
end

function ClientEntityEditorComponent:playEditorBoundEffect(effectType, effectMode, boundSize, yOffset, baseYPos, normalizeYaw, showArrow, boundHeight, xOffset, zOffset)
	if normalizeYaw == nil then
		normalizeYaw = true
	end

	effectType = effectType or ClientConst.EntityEditorBoundType.Default
	self.entityEditorEffectInfo[effectType] = {
		effectMode = effectMode,
		boundSize = boundSize,
		yOffset = yOffset or 0.05,
		xOffset = xOffset,
		zOffset = zOffset,
		boundHeight = boundHeight,
		baseYPos = baseYPos,
		normalizeYaw = normalizeYaw,
		showArrow = showArrow
	}

	self:updateEntityEditorEffect()
end

function ClientEntityEditorComponent:stopEditorBoundEffect(effectType)
	self.entityEditorEffectInfo[effectType] = nil

	self:updateEntityEditorEffect()
end

function ClientEntityEditorComponent:setEditorInAttach(attachInfo)
	if not self.editorAttachInfo and not attachInfo then
		return
	end

	self.editorAttachInfo = attachInfo

	self:updateEntityEditorEffect()
end

function ClientEntityEditorComponent:calcAttachBoundParam(effectType)
	local attachInfo = self.editorAttachInfo

	if not attachInfo or effectType ~= ClientConst.EntityEditorBoundType.Default then
		return nil
	end

	local OrnamentAttachType = BuildConst.OrnamentAttachType

	if attachInfo.attachType == OrnamentAttachType.Slope then
		return {
			visible = false
		}
	end

	local rx, ry, rz, rw = self.eModel:GetPositionAgentRotationEx()
	local entityRotation = Quaternion(rx, ry, rz, rw)

	if attachInfo.attachType == OrnamentAttachType.Wall then
		local ornamentForward = entityRotation * Vector3.forward
		local boundsRotation = Quaternion.LookRotation(Vector3.up, ornamentForward)
		local position = attachInfo.worldPosition + ornamentForward * BuildConst.AttachEffectOffsetY
		local boundSize = self:getBoundSize()

		return {
			visible = true,
			boundHeight = 0,
			bounds = Vector2(boundSize[1], self:getBoundHeight()),
			position = position,
			rotation = boundsRotation,
			realPosY = position.y
		}
	end

	local boundsRotation = self:getEffectBoundsRotation(entityRotation, true)
	local position = Vector3.New(attachInfo.worldPosition.x, attachInfo.worldPosition.y + BuildConst.AttachEffectOffsetY, attachInfo.worldPosition.z)
	local boundSize = self:getBoundSize()

	return {
		visible = true,
		boundHeight = 0,
		bounds = Vector2(boundSize[1], boundSize[2]),
		position = position,
		rotation = boundsRotation,
		realPosY = attachInfo.worldPosition.y
	}
end

function ClientEntityEditorComponent:EVENT_OnModelVisibleChange()
	self:updateEntityEditorEffect()
end

function ClientEntityEditorComponent:EVENT_onEntityPositionChanged()
	self:updateEditorEffectPos()
end

function ClientEntityEditorComponent:EVENT_onEntityScaleChanged()
	self:updateEntityEditorEffect()
end

function ClientEntityEditorComponent:innerPlayOrUpdateBoundEffect(effectType, effectInfo)
	local effectId = self.entityEditorEffectDict[effectType]
	local attachParam = self:calcAttachBoundParam(effectType)

	if attachParam then
		if not attachParam.visible then
			self:innerStopBoundEffect(effectType)

			return
		end

		if effectId then
			pg.global.homelandMgr:SetBoundEffectInfo(effectId, effectInfo.effectMode, attachParam.bounds, attachParam.boundHeight)
			pg.global.homelandMgr:UpdateBoundEffectPosition(effectId, attachParam.position, attachParam.rotation, attachParam.realPosY)
		else
			effectId = pg.global.homelandMgr:PlayBoundEffect(effectInfo.effectMode, attachParam.bounds, attachParam.position, attachParam.rotation, effectInfo.showArrow or false, attachParam.boundHeight, attachParam.realPosY)
			self.entityEditorEffectDict[effectType] = effectId
		end

		return
	end

	local boundSize = effectInfo.boundSize or {
		1,
		1
	}
	local boundHeight = effectInfo.boundHeight or 0
	local scaleX, scaleY, scaleZ = 1, 1, 1

	if self.getScale then
		local scale = self:getScale()

		scaleX = scale[1]
		scaleZ = scale[3]
		scaleY = scale[2]
	end

	if effectId then
		pg.global.homelandMgr:SetBoundEffectInfo(effectId, effectInfo.effectMode, Vector2(boundSize[1] * scaleX, boundSize[2] * scaleZ), boundHeight * scaleY)
		self:updateEditorEffectPos()
	else
		local position, boundsRotation, realPosY = self:getBoundsFinalPosRot(effectInfo)

		effectId = pg.global.homelandMgr:PlayBoundEffect(effectInfo.effectMode, Vector2(boundSize[1] * scaleX, boundSize[2] * scaleZ), position, boundsRotation, effectInfo.showArrow or false, boundHeight * scaleY, realPosY)
		self.entityEditorEffectDict[effectType] = effectId
	end
end

function ClientEntityEditorComponent:getEffectBoundsRotation(rotation, normalizeYaw)
	if self.getBasePlaceYaw and normalizeYaw then
		local baseYaw = self:getBasePlaceYaw()
		local eulerYaw = Utils.calcBoundsYaw(rotation:GetEulerAnglesY() - baseYaw) + baseYaw

		return Quaternion.Euler(0, eulerYaw, 0)
	end

	return rotation
end

function ClientEntityEditorComponent:innerStopBoundEffect(effectType)
	local effectId = self.entityEditorEffectDict[effectType]

	if effectId then
		pg.global.homelandMgr:StopBoundEffect(effectId)

		self.entityEditorEffectDict[effectType] = nil
	end
end

function ClientEntityEditorComponent:getBoundsFinalPosRot(effectInfo)
	local px, py, pz = self.eModel:GetPositionAgentPosEx()
	local position = Vector3.New(px, py, pz)
	local realPosY = position.y

	if effectInfo.baseYPos then
		position.y = effectInfo.baseYPos + effectInfo.yOffset
	else
		position.y = position.y + effectInfo.yOffset
	end

	local rx, ry, rz, rw = self.eModel:GetPositionAgentRotationEx()
	local boundsRotation = self:getEffectBoundsRotation(Quaternion(rx, ry, rz, rw), effectInfo.normalizeYaw)

	if effectInfo.xOffset or effectInfo.zOffset then
		local offsetPosition = Vector3(effectInfo.xOffset or 0, 0, effectInfo.zOffset or 0)

		position = position + boundsRotation * offsetPosition
	end

	return position, boundsRotation, realPosY
end

function ClientEntityEditorComponent:updateEditorEffectPos()
	for effectType, effectId in pairs(self.entityEditorEffectDict) do
		local attachParam = self:calcAttachBoundParam(effectType)

		if attachParam then
			if attachParam.visible then
				pg.global.homelandMgr:UpdateBoundEffectPosition(effectId, attachParam.position, attachParam.rotation, attachParam.realPosY)
			end
		else
			local effectInfo = self.entityEditorEffectInfo[effectType]
			local position, boundsRotation, realPosY = self:getBoundsFinalPosRot(effectInfo)

			pg.global.homelandMgr:UpdateBoundEffectPosition(effectId, position, boundsRotation, realPosY)
		end
	end
end

function ClientEntityEditorComponent:updateEntityEditorEffect()
	if not self.visible then
		self:stopEntityEditorAllEffect()

		return
	end

	for effectType, effectId in pairs(self.entityEditorEffectDict) do
		if not self.entityEditorEffectInfo[effectType] or not self:checkBoundEffectVisible(effectType) then
			self:innerStopBoundEffect(effectType)
		end
	end

	for effectType, effectInfo in pairs(self.entityEditorEffectInfo) do
		if self:checkBoundEffectVisible(effectType) then
			self:innerPlayOrUpdateBoundEffect(effectType, effectInfo)
		end
	end
end

function ClientEntityEditorComponent:stopEntityEditorAllEffect()
	for effectType, effectId in pairs(self.entityEditorEffectDict) do
		self:innerStopBoundEffect(effectType)
	end
end

function ClientEntityEditorComponent:setEditorOutline(reason, enable, materialId, overrideOutlineMatId)
	reason = reason or ClientConst.EntityEditorOutlinePriority.Default

	if enable then
		self.entityOutlineInfo[reason] = {
			materialId,
			overrideOutlineMatId
		}
	else
		self.entityOutlineInfo[reason] = nil
	end

	self:innerRefreshEditorOutline()
end

function ClientEntityEditorComponent:innerRefreshEditorOutline()
	local finalEnable = false
	local finalMaterialId, overrideOutlineMatId

	for i = ClientConst.EntityEditorOutlinePriority.MaxPriority, 1, -1 do
		if self.entityOutlineInfo[i] then
			finalEnable = true

			if self.entityOutlineInfo[i] then
				finalMaterialId = self.entityOutlineInfo[i][1]
				overrideOutlineMatId = self.entityOutlineInfo[i][2]
			end

			break
		end
	end

	self:innerSetEditorOutline(finalEnable, finalMaterialId, overrideOutlineMatId)
end

function ClientEntityEditorComponent:EVENT_onModelLoaded()
	self:innerSetEditorOutline(self.enableHomeEditorOutline, self.homeEditorMaterialId, self.overrideOutlineMatId, true)
	self:ensureEditorClickBox()
end

function ClientEntityEditorComponent:ensureEditorClickBox()
	if not self:hasEModelComponent(Const.COMPONENT_IDX_PHYSX) then
		return
	end

	local physx = self:getEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)

	if IsNil(physx) then
		return
	end

	local boundSize = self:getBaseBoundSize()
	local h = self:getBaseBoundHeight()

	self.eModel:EnsureHomeObjectClickBox(Const.COMPONENT_IDX_PHYSX, Vector3(0, h * 0.5, 0), Vector3(boundSize[1], h, boundSize[2]))
end

function ClientEntityEditorComponent:innerSetEditorOutline(enable, materialId, overrideOutlineMatId, force)
	if self.enableHomeEditorOutline ~= enable or self.homeEditorMaterialId ~= materialId or force then
		self.homeEditorMaterialId = materialId
		self.enableHomeEditorOutline = enable
		self.overrideOutlineMatId = overrideOutlineMatId

		local finalEnable = enable and not string.isNilOrEmpty(materialId)

		if HomeEditorOutline.checkMobileMode() then
			self.eModel.shaderView:SetMaterialMobileOutlineStencil(finalEnable)
			HomeEditorOutline.setEntityOutlineColor(self, finalEnable and materialId or nil)
		elseif finalEnable then
			local outlineMatId = overrideOutlineMatId or AddressDataConst.HOMELAND_OUTLINE_BASE
			local compressedMaterialIds, ncMaterialIds = self:getHomeOutlineMaterialIds(materialId, outlineMatId)

			self.eModel.shaderView:ChangeHomeOutlineEffectMaterial(compressedMaterialIds, ncMaterialIds)
		else
			self.eModel.shaderView:ChangeEffectMaterial({})
		end

		if self.tempDisableRendererBatch then
			self:tempDisableRendererBatch(ClientConst.DisableBatchReason.EDITOR_OUTLINE, finalEnable)
		end
	end
end

local HOMELAND_OUTLINE_NC_MAP = {
	[AddressDataConst.HOMELAND_OUTLINE_BASE] = AddressDataConst.HOMELAND_OUTLINE_BASE_NC,
	[AddressDataConst.HOMELAND_OUTLINE_RED_INNER] = AddressDataConst.HOMELAND_OUTLINE_RED_INNER_NC,
	[AddressDataConst.HOMELAND_OUTLINE_RED] = AddressDataConst.HOMELAND_OUTLINE_RED_NC,
	[AddressDataConst.HOMELAND_OUTLINE_GREEN] = AddressDataConst.HOMELAND_OUTLINE_GREEN_NC,
	[AddressDataConst.HOMELAND_OUTLINE_ELECTRIC] = AddressDataConst.HOMELAND_OUTLINE_ELECTRIC_NC,
	[AddressDataConst.HOMELAND_OUTLINE_FIRE] = AddressDataConst.HOMELAND_OUTLINE_FIRE_NC,
	[AddressDataConst.HOMELAND_OUTLINE_ICE] = AddressDataConst.HOMELAND_OUTLINE_ICE_NC,
	[AddressDataConst.HOMELAND_OUTLINE_LIGHT] = AddressDataConst.HOMELAND_OUTLINE_LIGHT_NC
}

function ClientEntityEditorComponent:getHomeOutlineMaterialIds(colorMatId, baseMatId)
	local ncMap = HOMELAND_OUTLINE_NC_MAP

	return {
		colorMatId,
		baseMatId
	}, {
		ncMap[colorMatId] or colorMatId,
		ncMap[baseMatId] or baseMatId
	}
end

function ClientEntityEditorComponent:setEnvCoverEffectEnable(enable, chargePresetName)
	if not self.eModel then
		return
	end

	if self.envCoverEffectVisible ~= enable or self.chargePresetName ~= chargePresetName then
		self.chargePresetName = chargePresetName or self.chargePresetName
		self.envCoverEffectVisible = enable

		local shaderView = self.eModel.shaderView

		if enable then
			shaderView:SetHomeEditorCoverEffect(enable, self.chargePresetName)
		elseif self.chargePresetName then
			shaderView:SetHomeEditorCoverEffect(enable, self.chargePresetName)
		end
	end
end

return ClientEntityEditorComponent
