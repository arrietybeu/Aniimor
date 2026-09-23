-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\OrnamentBuild\\LinkHelper.lua

local HomeBuildData = require("Data.home_build_data")
local HomeBuildLinkData = require("Data.home_build_link_data")
local HomelandConfigData = require("Data.homeland_config_data")
local BuildConst = require("Common.Homeland.OrnamentBuild.BuildConst")
local Utils = require("Common.Utils.Utils")
local LinkHelper = {}

LinkHelper.DEFAULT_LINK_ATTACH_DISTANCE_XZ = 0.5
LinkHelper.DEFAULT_LINK_ATTACH_DISTANCE_Y = 1.1

function LinkHelper.getLinkData(homeTemplateId)
	local buildInfo = HomeBuildData[homeTemplateId]

	if not buildInfo or not buildInfo.linkTemplateId then
		return nil
	end

	return HomeBuildLinkData[buildInfo.linkTemplateId]
end

function LinkHelper.getDirType(rotation)
	local eulerYaw = rotation:GetEulerAnglesY()

	eulerYaw = Utils.normalizeAngle(eulerYaw)

	if eulerYaw <= 45 or eulerYaw > 315 then
		return BuildConst.DirectionType.Front
	elseif eulerYaw <= 135 then
		return BuildConst.DirectionType.Right
	elseif eulerYaw <= 225 then
		return BuildConst.DirectionType.Back
	else
		return BuildConst.DirectionType.Left
	end
end

function LinkHelper.checkFitDir(fitType, checkDirType, checkDirTypeEnt, srcSocketDirConvert, srcDirConvert, targetDirType)
	local DirFitType = BuildConst.DirFitType

	if fitType == DirFitType.Default or not checkDirType and not checkDirTypeEnt then
		return true
	end

	local checkWorldDir

	if checkDirType then
		checkWorldDir = srcSocketDirConvert[checkDirType]
	elseif checkDirTypeEnt then
		checkWorldDir = srcDirConvert[checkDirTypeEnt]
	end

	if not checkWorldDir then
		return true
	end

	if checkWorldDir == targetDirType then
		return bit.band(fitType, DirFitType.FrontFit) ~= 0
	elseif BuildConst.SocketDirMatchInfo[checkWorldDir] == targetDirType then
		return bit.band(fitType, DirFitType.BackFit) ~= 0
	elseif BuildConst.DirConvertInfo[BuildConst.DirectionType.Left][checkWorldDir] == targetDirType then
		return bit.band(fitType, DirFitType.LeftFit) ~= 0
	elseif BuildConst.DirConvertInfo[BuildConst.DirectionType.Right][checkWorldDir] == targetDirType then
		return bit.band(fitType, DirFitType.RightFit) ~= 0
	end

	return true
end

local LINK_OVERLAP_THRESHOLD = 0.1

function LinkHelper.checkLinkPositionOverlap(srcEntity, snapPosition, srcBuildType, buildAttachCandidates)
	if not buildAttachCandidates then
		return false
	end

	local srcOrnamentId = srcEntity.ornamentId

	for _, fastInfo in pairs(buildAttachCandidates) do
		local ent = fastInfo.extraInfo and fastInfo.extraInfo.ent

		if ent and ent ~= srcEntity and (not srcOrnamentId or ent.ornamentId ~= srcOrnamentId) then
			local linkData = LinkHelper.getLinkData(ent.homeTemplateId)

			if linkData and linkData.buildType == srcBuildType then
				local pos = fastInfo.position

				if math.abs(snapPosition.x - pos.x) < LINK_OVERLAP_THRESHOLD and math.abs(snapPosition.y - pos.y) < LINK_OVERLAP_THRESHOLD and math.abs(snapPosition.z - pos.z) < LINK_OVERLAP_THRESHOLD then
					return true
				end
			end
		end
	end

	return false
end

local tempSocketOffset = Vector3(0, 0, 0)

function LinkHelper.getSocketOffset(socketInfo)
	local pos = socketInfo.position

	if pos then
		tempSocketOffset:Set(pos[1], pos[2], pos[3])
	else
		tempSocketOffset:Set(0, 0, 0)
	end

	return tempSocketOffset
end

function LinkHelper.isSocketMainWorldDir(baseWorldDir, presetData, worldDir)
	local mainDirTypes = presetData and presetData.mainDirTypes

	if mainDirTypes then
		for _, mainDirType in ipairs(mainDirTypes) do
			if BuildConst.DirConvertInfo[baseWorldDir][mainDirType] == worldDir then
				return true
			end
		end

		return false
	end

	local mainDirType = presetData and presetData.mainDirType

	if mainDirType then
		return BuildConst.DirConvertInfo[baseWorldDir][mainDirType] == worldDir
	end

	return baseWorldDir == worldDir
end

function LinkHelper.checkTargetSocketMainDir(targetDirConvert, targetSocketInfo, needTargetMainDir)
	local targetSocketDirType = targetSocketInfo.dirType or BuildConst.DirectionType.Front
	local baseWorldDir = targetDirConvert[targetSocketDirType]
	local targetPresetData = BuildConst.LinkPresetData[targetSocketInfo.presetType]

	return LinkHelper.isSocketMainWorldDir(baseWorldDir, targetPresetData, needTargetMainDir)
end

function LinkHelper.checkSnapPositionValid(editor, srcEntity, srcPosition, srcRotation, moveDelta, srcBuildType, buildAttachCandidates)
	if not editor then
		return true
	end

	local snapPosition = srcPosition + moveDelta

	if not editor:checkBoundInArea(snapPosition, srcRotation, srcEntity:getBoundSize()) then
		return false
	end

	return not LinkHelper.checkLinkPositionOverlap(srcEntity, snapPosition, srcBuildType, buildAttachCandidates)
end

function LinkHelper.getTargetConnectSlotInfo(targetPresetData, targetSocketBaseWorldDir, needTargetMainDir)
	if not targetPresetData or not targetPresetData.dirData then
		return nil
	end

	local dirConvert = BuildConst.DirConvertInfo[targetSocketBaseWorldDir]

	if not dirConvert then
		return nil
	end

	for slotDir, slotInfo in pairs(targetPresetData.dirData) do
		if dirConvert[slotDir] == needTargetMainDir then
			return slotInfo
		end
	end

	return nil
end

function LinkHelper.checkBuildTypeStrict(targetSlotInfo, srcBuildType)
	local srcBuildTypeStrict = targetSlotInfo and targetSlotInfo.srcBuildTypeStrict

	if not srcBuildTypeStrict then
		return true
	end

	return srcBuildTypeStrict[srcBuildType] ~= nil
end

function LinkHelper.checkSocketPresetTypeStrict(socketFitData, targetPresetType)
	local targetSocketPresetStrict = socketFitData and socketFitData.targetSocketPresetStrict

	if not targetSocketPresetStrict then
		return true, nil
	end

	local strictEntry = targetSocketPresetStrict[targetPresetType]

	if strictEntry == nil then
		return false, nil
	end

	return true, strictEntry
end

function LinkHelper.checkMoveDeltaInAttachDistance(moveDelta, buildExtraConfig)
	local yAttachDistance = buildExtraConfig and buildExtraConfig.yAttachDistance or HomelandConfigData.linkAttachDistanceY or LinkHelper.DEFAULT_LINK_ATTACH_DISTANCE_Y
	local xzAttachDistance = buildExtraConfig and buildExtraConfig.xzAttachDistance or HomelandConfigData.linkAttachDistanceXZ or LinkHelper.DEFAULT_LINK_ATTACH_DISTANCE_XZ

	return yAttachDistance >= math.abs(moveDelta.y) and xzAttachDistance >= math.abs(moveDelta.x) and xzAttachDistance >= math.abs(moveDelta.z)
end

function LinkHelper.tryMatchSocketPair(srcSocketPosition, needTargetMainDir, fitType, slotInfo, socketFitData, srcSocketDirConvert, srcDirConvert, targetPosition, targetRotation, targetDirType, targetDirConvert, targetSocketInfo, srcBuildType, buildExtraConfig)
	if not LinkHelper.checkTargetSocketMainDir(targetDirConvert, targetSocketInfo, needTargetMainDir) then
		return nil
	end

	local targetPresetData = BuildConst.LinkPresetData[targetSocketInfo.presetType]
	local targetSocketBaseWorldDir = targetDirConvert[targetSocketInfo.dirType or BuildConst.DirectionType.Front]
	local targetConnectSlotInfo = LinkHelper.getTargetConnectSlotInfo(targetPresetData, targetSocketBaseWorldDir, needTargetMainDir)

	if not LinkHelper.checkBuildTypeStrict(targetConnectSlotInfo, srcBuildType) then
		return nil
	end

	local passPresetStrict, strictEntry = LinkHelper.checkSocketPresetTypeStrict(socketFitData, targetSocketInfo.presetType)

	if not passPresetStrict then
		return nil
	end

	local fitTypeForCheck = fitType

	if strictEntry and strictEntry.dirFitType then
		fitTypeForCheck = strictEntry.dirFitType
	end

	if not LinkHelper.checkFitDir(fitTypeForCheck, slotInfo.checkDirType, slotInfo.checkDirTypeEnt, srcSocketDirConvert, srcDirConvert, targetDirType) then
		return nil
	end

	local targetSocketOffset = LinkHelper.getSocketOffset(targetSocketInfo)
	local targetSocketPosition = targetPosition + targetRotation * targetSocketOffset
	local moveDelta = targetSocketPosition - srcSocketPosition

	return moveDelta, targetSocketPosition
end

function LinkHelper.tryLinkEntity(editor, srcEntity, srcPosition, srcRotation, targetEntity, targetPosition, targetRotation, buildAttachCandidates, buildExtraConfig, outSocketPosition, outMoveDelta, linkPointCollector)
	local srcLinkData = LinkHelper.getLinkData(srcEntity.homeTemplateId)
	local targetLinkData = LinkHelper.getLinkData(targetEntity.homeTemplateId)

	if not srcLinkData or not targetLinkData then
		return false
	end

	local srcBuildType = srcLinkData.buildType
	local targetBuildType = targetLinkData.buildType
	local srcSockets = srcLinkData.linkSockets
	local targetSockets = targetLinkData.linkSockets

	if not srcSockets or not targetSockets then
		return false
	end

	local srcDirType = LinkHelper.getDirType(srcRotation)
	local targetDirType = LinkHelper.getDirType(targetRotation)
	local srcDirConvert = BuildConst.DirConvertInfo[srcDirType]
	local targetDirConvert = BuildConst.DirConvertInfo[targetDirType]

	if not srcDirConvert or not targetDirConvert then
		return false
	end

	local srcPresetFilter = buildExtraConfig and buildExtraConfig.srcEntityLinkPresetFilter
	local srcDirFilter = buildExtraConfig and buildExtraConfig.srcEntityLinkDirFilter
	local bestSqrDist, bestSocketPosition, bestMoveDelta, bestSrcSocketIndex, bestSlotDir

	Vector3.enableCreateFromCache()

	for srcSocketIndex, srcSocketInfo in ipairs(srcSockets) do
		local passFilter = (srcPresetFilter == nil or srcSocketInfo.presetType == srcPresetFilter) and (srcDirFilter == nil or srcSocketInfo.dirType == srcDirFilter)
		local socketDirType = srcDirConvert[srcSocketInfo.dirType or BuildConst.DirectionType.Front]
		local srcPresetData = BuildConst.LinkPresetData[srcSocketInfo.presetType]
		local srcSocketDirConvert = socketDirType and BuildConst.DirConvertInfo[socketDirType]

		if passFilter and srcPresetData and srcSocketDirConvert then
			local srcSocketPosition = srcPosition + srcRotation * LinkHelper.getSocketOffset(srcSocketInfo)

			for slotDir, slotInfo in pairs(srcPresetData.dirData) do
				local socketFitData = slotInfo.socketData and slotInfo.socketData[targetBuildType]
				local fitType = socketFitData and socketFitData.dirFitType
				local slotWorldDir = fitType and srcSocketDirConvert[slotDir]
				local needTargetMainDir = slotWorldDir and BuildConst.SocketDirMatchInfo[slotWorldDir]

				if needTargetMainDir then
					for _, targetSocketInfo in ipairs(targetSockets) do
						local moveDelta, targetSocketPosition = LinkHelper.tryMatchSocketPair(srcSocketPosition, needTargetMainDir, fitType, slotInfo, socketFitData, srcSocketDirConvert, srcDirConvert, targetPosition, targetRotation, targetDirType, targetDirConvert, targetSocketInfo, srcBuildType, buildExtraConfig)

						if moveDelta then
							local positionValid

							if linkPointCollector then
								positionValid = LinkHelper.checkSnapPositionValid(editor, srcEntity, srcPosition, srcRotation, moveDelta, srcBuildType, buildAttachCandidates)

								if positionValid then
									linkPointCollector(srcSocketPosition, targetSocketPosition)
								end
							end

							if LinkHelper.checkMoveDeltaInAttachDistance(moveDelta, buildExtraConfig) then
								local sqrDist = moveDelta:SqrMagnitude()

								if not bestSqrDist or sqrDist < bestSqrDist then
									if positionValid == nil then
										positionValid = LinkHelper.checkSnapPositionValid(editor, srcEntity, srcPosition, srcRotation, moveDelta, srcBuildType, buildAttachCandidates)
									end

									if positionValid then
										bestSqrDist = sqrDist
										bestSocketPosition = targetSocketPosition
										bestMoveDelta = moveDelta
										bestSrcSocketIndex = srcSocketIndex
										bestSlotDir = slotDir
									end
								end
							end
						end
					end
				end
			end
		end
	end

	if bestSqrDist then
		outSocketPosition:Copy(bestSocketPosition)
		outMoveDelta:Copy(bestMoveDelta)
		Vector3.disableCreateFromCache()

		return true, outSocketPosition, outMoveDelta, bestSrcSocketIndex, bestSlotDir
	end

	Vector3.disableCreateFromCache()

	return false
end

return LinkHelper
