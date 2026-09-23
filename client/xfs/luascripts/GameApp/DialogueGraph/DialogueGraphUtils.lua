-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphUtils.lua

local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("DialogueItemCmd")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local AudioConst = require("Const.AudioConst")
local AIConst = require("Common.Const.AiConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local CommonSwitch = require("Common.CommonSwitch")
local SysConfigData = require("Data.sys_config_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local DialogueConst = require("Const.DialogueConst")
local PetSwitchAnim = require("GameApp.PetSwitch.PetSwitchAnim")
local AbilityConst = require("Common.Const.AbilityConst")
local TimerManager = require("Core.Timer.TimerManager")
local NpcDialogueData = require("Data.npc_dialogue_data")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local DialogueGraphConfig = require("Data.dialogue_graph_data")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local EntityLookAtUtils = require("GameApp.Communication.EntityLookAtUtils")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local Vector3 = Vector3
local Quaternion = Quaternion
local DialogueGraphUtils = {}

function DialogueGraphUtils.executeCallbacks(...)
	local argCount = select("#", ...)

	for i = 1, argCount do
		local arg = select(i, ...)

		DialogueGraphUtils.invokeCallbackValue(arg)
	end
end

function DialogueGraphUtils.invokeCallbackValue(arg)
	if arg == nil then
		return
	end

	if type(arg) == "function" then
		arg()
	elseif type(arg) == "userdata" then
		local mt = getmetatable(arg)

		if mt and mt.__call and type(mt.__call) == "function" then
			arg()
		end
	elseif type(arg) == "table" then
		for key, value in pairs(arg) do
			DialogueGraphUtils.invokeCallbackValue(value)
		end
	end
end

local function callGraphItem(cmd, methodName, ...)
	local graphItem = cmd and cmd.graphItem or nil

	if graphItem == nil then
		return nil
	end

	local method = graphItem[methodName]

	if method == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("DialogueGraphItem接口不存在 method=%s", tostring(methodName))
		end

		return nil
	end

	local status, result = SafeCallbackWithStatusAndReturn(method, graphItem, ...)

	if not status then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("DialogueGraphItem接口执行失败 method=%s", tostring(methodName))
		end

		return nil
	end

	return result
end

function DialogueGraphUtils.toVector3(value)
	if value == nil then
		return Vector3.constZero
	end

	if type(value) == "table" or type(value) == "userdata" then
		local x = value[1] or value.x or 0
		local y = value[2] or value.y or 0
		local z = value[3] or value.z or 0

		return Vector3.New(x, y, z)
	elseif type(value) == "string" then
		local vectorString = string.match(value, "^%s*%((.*)%)%s*$") or value
		local x, y, z = string.match(vectorString, "^%s*([^,]+),([^,]+),([^,]+)%s*$")

		return Vector3.New(tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0)
	elseif type(value) == "number" then
		return Vector3.New(value, value, value)
	end

	return Vector3.constZero
end

function DialogueGraphUtils.toQuaternion(value)
	if value == nil then
		return Quaternion.identity
	end

	if type(value) == "table" or type(value) == "userdata" then
		local x = value[1] or value.x or 0
		local y = value[2] or value.y or 0
		local z = value[3] or value.z or 0
		local w = value[4] or value.w or 1

		return Quaternion.New(x, y, z, w)
	elseif type(value) == "string" then
		local quaternionString = string.match(value, "^%s*%((.*)%)%s*$") or value
		local x, y, z, w = string.match(quaternionString, "^%s*([^,]+),([^,]+),([^,]+),([^,]+)%s*$")

		return Quaternion.New(tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0, tonumber(w) or 1)
	end

	return Quaternion.identity
end

function DialogueGraphUtils.ApproximatelyVector3(a, b, eps)
	if a == nil or b == nil then
		return false
	end

	local typeA = type(a)
	local typeB = type(b)

	if typeA ~= "table" and typeA ~= "userdata" or typeB ~= "table" and typeB ~= "userdata" then
		return false
	end

	eps = tonumber(eps) or 0.001

	local ax = a.x or a[1] or 0
	local ay = a.y or a[2] or 0
	local az = a.z or a[3] or 0
	local bx = b.x or b[1] or 0
	local by = b.y or b[2] or 0
	local bz = b.z or b[3] or 0

	return eps > math.abs(ax - bx) and eps > math.abs(ay - by) and eps > math.abs(az - bz)
end

function DialogueGraphUtils.toColor(value, defaultVal)
	if value == nil then
		return defaultVal or Color(0, 0, 0, 0)
	end

	if type(value) == "table" then
		local r = value[1] or value.r or value.x or 0
		local g = value[2] or value.g or value.y or 0
		local b = value[3] or value.b or value.z or 0
		local a = value[4] or value.a or value.w or 1

		return Color(r, g, b, a)
	end

	return Color(0, 0, 0, 0)
end

function DialogueGraphUtils.isInWhiteList(dialogueId)
	return CommonSwitch.DIALOGUE_WHITE_LIST[dialogueId]
end

function DialogueGraphUtils.canShowID()
	return pg.game.setting:getShowDebugId() and CommonSwitch.DIALOGUE_GRAPH_SHOW_ID
end

function DialogueGraphUtils.isLuaGraphEnabled(taskInfo)
	local forceAsset = taskInfo ~= nil and taskInfo.extraData ~= nil and taskInfo.extraData.forceAsset == true

	return forceAsset ~= true
end

function DialogueGraphUtils.getEntity(id)
	if string.isNilOrEmpty(id) or pg.me == nil or pg.me.space == nil then
		return
	end

	local ent
	local staticId = id

	if type(id) == "string" then
		ent = pg.getEntity(id) or pg.getEntityByGlobalId(id)

		if ent ~= nil then
			return ent
		end

		staticId = tonumber(id)
	end

	if staticId == 2 then
		ent = pg.pawn
	elseif staticId == 1 then
		ent = pg.me:getCurPetEntity()
	else
		ent = pg.me.space:getEntityByStaticId(staticId)
	end

	if ent == nil then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("找不到对应的实体 staticId", staticId)
		end

		return
	end

	return ent
end

function DialogueGraphUtils.getEntityById(entityId, staticId)
	if staticId ~= nil and staticId ~= 0 then
		return DialogueGraphUtils.getEntityByStaticId(staticId)
	end

	return DialogueGraphUtils.getEntity(entityId)
end

function DialogueGraphUtils.getEntityByStaticId(staticId)
	if staticId == nil or pg.me == nil or pg.me.space == nil then
		return
	end

	if staticId == 2 then
		return pg.pawn
	elseif staticId == 1 then
		return pg.me:getCurPetEntity()
	else
		return pg.me.space:getEntityByStaticId(staticId)
	end
end

function DialogueGraphUtils.getEntityByGlobalId(entityId)
	if string.isNilOrEmpty(entityId) or pg == nil or pg.getEntityByGlobalId == nil then
		return
	end

	return pg.getEntityByGlobalId(entityId)
end

function DialogueGraphUtils.getEntityByEntityId(entityId)
	if string.isNilOrEmpty(entityId) or pg == nil then
		return
	end

	return pg.getEntity(entityId) or pg.getEntityByGlobalId(entityId)
end

function DialogueGraphUtils.getHomeFacilityEntity(staticId)
	local HomeLandUtils = require("Common.Utils.HomeLandUtils")

	return HomeLandUtils.getHomeFacilityEntity(pg and pg.me or nil, staticId)
end

function DialogueGraphUtils.tryGetHomeFacilityPointPose(staticId)
	local HomeLandUtils = require("Common.Utils.HomeLandUtils")

	return HomeLandUtils.getHomeFacilityPointPose(pg and pg.me or nil, staticId)
end

function DialogueGraphUtils.setEntityPosition(entity, position)
	EModelUtils.setAgentPosition(entity, position)
end

function DialogueGraphUtils.setEntityRotation(entity, x, y, z, w, instant)
	pg.game.communication:clearRecoverTargetNpc(entity)
	EModelUtils.setAgentRotation(entity, Quaternion(x, y, z, w), instant)
end

function DialogueGraphUtils.setEntityRotationByQua(entity, rot, instant)
	EModelUtils.setAgentRotation(entity, rot, instant)
end

function DialogueGraphUtils.forceChangeToIdle(entity)
	if entity == nil or entity.eModel == nil or entity.characterState == CharacterStateConst.IDLE then
		return
	end

	if CharacterStateConst.isChildOfState(entity.characterState, CharacterStateConst.LOCOMOTION) or CharacterStateConst.isChildOfState(entity.characterState, CharacterStateConst.AIRING) or entity.characterState == CharacterStateConst.LAND then
		entity.eModel:ForceChangeToState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterStateConst.IDLE)
	end
end

function DialogueGraphUtils.setFuncTypeStateCheckSetMode(cmd, param)
	if param.modeType then
		return param.modeType == DialogueGraphConst.MODE_TYPE.Control
	end

	return true
end

function DialogueGraphUtils.showDialog(cmd, dialogId, entId, param)
	local dialogueCallback = param.callback
	local hasBranch = param.branch ~= nil

	function param.callback(id, index)
		cmd:cancelNodeFuncTypeState(DialogueGraphConst.NODE_FUNC_TYPE.DIALOGUE_SHOW_DIALOG)

		if dialogueCallback ~= nil then
			id = id or 1
			index = index or 0

			dialogueCallback(id, index)
		end
	end

	local ret, errors = ClientUtils.tryWithLogError(function()
		local chatType = param.chatType

		if chatType == nil then
			local data = NpcDialogueData[dialogId]

			chatType = data and data[1] and data[1].chatType
		end

		if entId ~= nil and not string.isNilOrEmpty(entId) then
			param.targetEntity = DialogueGraphUtils.getEntity(entId)
		end

		if param.disableCameraAnim and cmd.config.initInfo.applyAutoCamera then
			param.disableCameraAnim = nil
		end

		param.cmd = cmd

		pg.game.communication:showDialogText(dialogId, entId, param, cmd.taskInfo.context)

		if param.cameraData then
			DialogueGraphUtils.applyDialogsetCamera(cmd, param.cameraData)
		end
	end)

	if not ret then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("异常执行对白回调", errors)
		end

		param.callback(1, 0)
	elseif cmd.taskInfo.extraData and cmd.taskInfo.extraData.debugMode then
		local TimerManager = require("Core.Timer.TimerManager")

		TimerManager.addTimer(2, function()
			if hasBranch then
				local extraData = cmd.taskInfo.extraData
				local smokeChoiceDialogueId = tonumber(extraData.smokeChoiceDialogueId)
				local selectedBranchIndex, selectedDialogueId

				if smokeChoiceDialogueId ~= nil and smokeChoiceDialogueId > 0 then
					for i = 1, #param.branch do
						local branch = param.branch[i]
						local branchDialogueId = type(branch) == "table" and branch.dialogueId or branch

						if tonumber(branchDialogueId) == smokeChoiceDialogueId then
							selectedBranchIndex = i
							selectedDialogueId = tonumber(branchDialogueId)
							extraData.smokeChoiceMatched = true

							if pg ~= nil then
								pg.__dialogueGraphSmokeChoiceMatched = true
							end

							break
						end
					end
				end

				if selectedBranchIndex == nil and smokeChoiceDialogueId ~= nil and smokeChoiceDialogueId > 0 then
					selectedBranchIndex = tonumber(param.defaultSkipBranch) or 1

					local defaultBranch = param.branch[selectedBranchIndex]

					selectedDialogueId = type(defaultBranch) == "table" and defaultBranch.dialogueId or defaultBranch

					param.callback(selectedBranchIndex, selectedBranchIndex - 1)
				elseif selectedBranchIndex ~= nil then
					param.callback(selectedBranchIndex, selectedBranchIndex - 1)
				else
					selectedBranchIndex = tonumber(param.defaultSkipBranch) or 1

					local defaultBranch = param.branch[selectedBranchIndex]

					selectedDialogueId = type(defaultBranch) == "table" and defaultBranch.dialogueId or defaultBranch

					param.callback(selectedBranchIndex, selectedBranchIndex - 1)
				end
			else
				param.callback(1, 0)
			end
		end)
	end
end

function DialogueGraphUtils.closeDialog(cmd, resumeNpc)
	if resumeNpc then
		pg.game.communication:recoverTargetNpcFaceTowards()
	end

	pg.game.communication:finishNpcDialog(not resumeNpc, DialogueConst.DIALOGUE_CLOSE_KEY.DIALOG_CLOSE_NODE)
end

function DialogueGraphUtils.playSimpleNpcCallAnim(cmd, npcTemplateId, callback)
	pg.game.communication:playSimpleNpcCallAnim(npcTemplateId, callback)
end

function DialogueGraphUtils.stopSimpleNpcCallAnim(cmd)
	pg.game.communication:stopSimpleNpcCallAnim()
end

function DialogueGraphUtils.enterDialoguePreset(cmd, mode, npcIdStr, param, callback)
	local entityId = npcIdStr

	if npcIdStr ~= nil then
		local ent = DialogueGraphUtils.getEntity(npcIdStr)

		if ent then
			entityId = ent.id

			DialogueGraphUtils.pauseEntityBt(cmd, ent)
		else
			DialogueGraphUtils.pauseBt(cmd, npcIdStr)
		end
	end

	pg.game.communication:prepareDialogue(cmd.id, mode, entityId, param, callback)
end

function DialogueGraphUtils.exitDialoguePreset(cmd, npcId)
	pg.game.communication:recoverTargetNpcFaceTowards(npcId)
end

function DialogueGraphUtils.playPlotPhoneCallAnim(cmd, npcTemplateId, disableAni, callback)
	pg.game.communication:playPlotPhoneCallAnim(npcTemplateId, disableAni, callback)
end

function DialogueGraphUtils.stopPlotPhoneCallAnim(cmd)
	pg.game.communication:stopPlotPhoneCallAnim()
end

function DialogueGraphUtils.enableSkip(cmd, skipMsg)
	return
end

function DialogueGraphUtils.disableSkip(cmd)
	return
end

function DialogueGraphUtils.showUI(cmd, uid, param, uiCloseCb)
	local canShowSkipPanel = DialogueGraphUtils.canShowSkipPanel(cmd, uid)

	if not canShowSkipPanel then
		cmd:disableSkipPermission()
	end

	local function onCloseCB()
		if not canShowSkipPanel then
			cmd:enableSkipPermission()
		end

		if uiCloseCb ~= nil then
			uiCloseCb()
		end
	end

	local ret, errors = ClientUtils.tryWithLogError(function()
		local info = param or {}

		function info.scheduleRPC(type, param)
			cmd:scheduleRPC(type, param)
		end

		info.dialogueContext = cmd.taskInfo.context

		if uid == UIConst.UI_ID_ITEM_VIEWER then
			if info[1] and type(info[1]) == "table" then
				LuaUIUtils.openItemViewer(info[1], onCloseCB)
			else
				LuaUIUtils.openItemViewer(info, onCloseCB)
			end
		else
			pg.global.ui:open(uid, info, nil, onCloseCB)
		end
	end)

	if not ret then
		onCloseCB()
	elseif cmd.taskInfo.extraData and cmd.taskInfo.extraData.debugMode then
		local TimerManager = require("Core.Timer.TimerManager")

		TimerManager.addTimer(2, function()
			onCloseCB()
		end)
	end
end

function DialogueGraphUtils.setSkipUIBlackList(cmd, blackList)
	cmd.skipUIBlackList = cmd.skipUIBlackList or {}

	if blackList then
		for pid, v in pairs(blackList) do
			cmd.skipUIBlackList[pid] = true
		end
	end

	local cfgBlackList = SysConfigData.DIALOGUE_SKIP_BLACKLIST

	if cfgBlackList then
		for _, pid in pairs(cfgBlackList) do
			cmd.skipUIBlackList[pid] = true
		end
	end
end

function DialogueGraphUtils.canShowSkipPanel(cmd, uid)
	return cmd.skipUIBlackList == nil or cmd.skipUIBlackList[uid] == nil
end

function DialogueGraphUtils.isUIFullScreen(uid)
	local config = UIConst.UI_CONFIGS[uid] or {}

	return config.fullScreen or false
end

function DialogueGraphUtils.closeUI(cmd, uid)
	if pg.global.ui:checkUIOpen(uid) then
		pg.global.ui:close(uid)
	end
end

function DialogueGraphUtils.showBlackScreen(cmd, blendTime)
	local param = {}

	param.blendTime = blendTime or 0
	param.chatType = DialogueConst.ChatType.BLACK_SCREEN
	param.isDialogueGraph = true
	param.autoCloseByConfig = false

	pg.global.ui:open(UIConst.UI_ID_BLACK_SCREEN, param)
end

function DialogueGraphUtils.closeBlackScreen(cmd, blendOutTime)
	if pg.global.ui.blackScreen then
		pg.global.ui.blackScreen:startCloseScreen(blendOutTime)
	end
end

function DialogueGraphUtils.showWhiteScreen(cmd, blendTime)
	local param = {}

	param.blendTime = blendTime or 0
	param.chatType = DialogueConst.ChatType.BLACK_SCREEN
	param.isDialogueGraph = true
	param.autoCloseByConfig = false

	pg.global.ui:open(UIConst.UI_ID_WHITE_SCREEN, param)
end

function DialogueGraphUtils.closeWhiteScreen(cmd, blendOutTime)
	if pg.global.ui.whiteScreen and pg.global.ui.whiteScreen:isInDialogueGraphSystem() then
		pg.global.ui.whiteScreen:startCloseScreen(blendOutTime)
	end
end

function DialogueGraphUtils.waitUIClose(cmd, nodeId, uid, waitDestroy, callback)
	if uid == nil or uid == 0 then
		if callback then
			callback()
		end

		return
	end

	if waitDestroy then
		if not pg.global.ui:checkUIOpen(uid) then
			if callback then
				callback()
			end

			return
		end

		cmd:registUICloseCB(nodeId, uid, function()
			cmd:unregistUICloseCB(nodeId)

			if callback then
				callback()
			end
		end)
	else
		if not pg.global.ui:checkUIShow(uid) then
			if callback then
				callback()
			end

			return
		end

		cmd:registUIHideCB(nodeId, uid, function()
			cmd:unregistUIHideCB(nodeId)

			if callback then
				callback()
			end
		end)
	end
end

function DialogueGraphUtils.handleHideUI(cmd, uid)
	cmd:handleHideUI(uid)
end

function DialogueGraphUtils.handleCloseUI(cmd, uid)
	cmd:handleCloseUI(uid)
end

function DialogueGraphUtils.startGraphCameraBlend(cmd, position, rotation, fov, blendTime, callback, extraParam)
	return callGraphItem(cmd, "BlendToFixedCamera", position, rotation, fov, blendTime, callback, extraParam)
end

function DialogueGraphUtils.cancelGraphCameraBlend(cmd, blendTime, resetPlayerDirection)
	return callGraphItem(cmd, "CancelBlendToFixedCamera", blendTime, resetPlayerDirection)
end

function DialogueGraphUtils.setCameraDofActive(cmd, active)
	return callGraphItem(cmd, "SetCameraDofActive", active)
end

function DialogueGraphUtils.applyCameraDof(cmd, nodeId, param)
	return callGraphItem(cmd, "ApplyCameraDof", nodeId, param)
end

function DialogueGraphUtils.resetDialogsetCamera(cmd)
	return callGraphItem(cmd, "ResetDialogsetCamera")
end

function DialogueGraphUtils.enableNpcDialogueCamera(cmd, enable, presetName, targetEntId, callback)
	local targetEntity = DialogueGraphUtils.getEntity(targetEntId)

	pg.game.camera:enableNpcDialogue(enable, presetName, targetEntity, callback)
end

function DialogueGraphUtils.cameraBlendToFixed(cmd, position, rotation, fov, blendTime, callback, extraParam)
	if cmd.cameraBlendInfo == nil then
		cmd.cameraBlendInfo = {}
	end

	extraParam = extraParam or {}
	extraParam.enableShake = true

	if extraParam.cameraId ~= nil then
		local arg = {}

		arg.position = position
		arg.rotation = rotation
		arg.fov = fov
		arg.blendTime = blendTime
		arg.extraParam = extraParam
		cmd.cameraBlendInfo[extraParam.cameraId] = arg
	end

	pg.game.camera:cameraBlendToFixed(position, rotation, fov, blendTime, callback, callback, extraParam)
end

function DialogueGraphUtils.cancelBlendToFixed(cmd, blendTime, resetPlayerDir)
	blendTime = blendTime or 1

	pg.game.camera:cancelBlendToFixed(blendTime, resetPlayerDir)
end

function DialogueGraphUtils.applyCameraBlendToFixed(cmd, cameraId, callback)
	if cmd.cameraBlendInfo == nil or cmd.cameraBlendInfo[cameraId] == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("找不到对应的相机过渡信息", cameraId)
		end

		if callback then
			callback()
		end

		return
	end

	local arg = cmd.cameraBlendInfo[cameraId]

	pg.game.camera:cameraBlendToFixed(arg.position, arg.rotation, arg.fov, arg.blendTime, callback, callback, arg.extraParam)
end

function DialogueGraphUtils.setPlayerCameraZoomAndRotation(cmd, param)
	if pg.game == nil then
		return
	end

	if param.zoomValue ~= nil then
		pg.game.camera.playerCameraMode:zoomToValue(param.zoomValue)
		pg.game.camera.playerCameraMode:setEnableAutoZoomAndRecenter(false)
	end

	if param.controlRotation ~= nil then
		pg.game.camera.playerCameraMode.cameraMode.cameraController:SetControlRotation(param.controlRotation)
	end
end

function DialogueGraphUtils.modifyPlayerCameraInfo(cmd, param)
	if param.faceToTarget then
		local rotSpeedCurve = param.rotSpeedCurve

		if rotSpeedCurve ~= nil and type(rotSpeedCurve) == "table" then
			rotSpeedCurve = callGraphItem(cmd, "CreateAnimationCurve", rotSpeedCurve)
		end

		pg.game.camera.playerCameraMode:faceToTargetTransfomWithTargetShoulder(param.faceToTarget, param.heightDelta, param.maxLockTime, param.shoulder, param.transitionSpeed, rotSpeedCurve, param.resetOnFinish)
	end

	if param.fov ~= nil then
		pg.game.camera.playerCameraMode:blendToFov(param.fov, param.fovBlendTime, param.fovBlendFunc)
	end

	if param.targetZoom ~= nil then
		pg.game.camera.playerCameraMode:zoomToValue(param.targetZoom)
		pg.game.camera.playerCameraMode:setEnableAutoZoomAndRecenter(false)
	end

	if param.yawSpeedRatio or param.pitchSpeedRatio then
		pg.game.camera.playerCameraMode:setYawSpeedAndPitchSpeedRatio(param.yawSpeedRatio, param.pitchSpeedRatio)
	end

	if param.playerCamShoulder then
		pg.game.camera.playerCameraMode:setPlayerCameraTargetShoulder(param.playerCamShoulder, param.playerCamTransitionSpeed)
	end
end

function DialogueGraphUtils.cancelModifyPlayerCameraInfo(cmd, param)
	if param == nil or param.cancelFaceToTarget ~= nil then
		pg.game.camera.playerCameraMode:cancelFaceToTarget()
	end

	if param == nil or param.cancelFovBlend ~= nil then
		local fovBlendOutTime = param and param.fovBlendOutTime or 0.2
		local fovBlendOutFunc = param and param.fovBlendOutFunc or nil

		pg.game.camera.playerCameraMode:cancelFovBlend(fovBlendOutTime, fovBlendOutFunc)
	end

	if param == nil or param.cancelModifyYawSpeedRatioZoom or param.cancelModifyPitchSpeedRatioZoom then
		pg.game.camera.playerCameraMode:resetSpeedAndPitchSpeedRatio()
	end

	if param == nil or param.cancelSetPlayerCamShoulder then
		pg.game.camera.playerCameraMode:setPlayerCameraTargetShoulder(Vector3.zero)
	end

	pg.game.camera.playerCameraMode:setEnableAutoZoomAndRecenter(true)
end

function DialogueGraphUtils.getCameraBlendFunction(blendFunc)
	if type(blendFunc) == "string" then
		return DialogueGraphConst.CameraBlendFunction[blendFunc]
	else
		return DialogueGraphConst.CameraBlendFunction.Linear
	end
end

function DialogueGraphUtils.switchPet(cmd, switchToPet, clientSwitchReason, callback)
	if switchToPet then
		if not pg.me:isControllingPet() then
			return pg.me:requestSwitchToPet(clientSwitchReason)
		end
	elseif pg.me:isControllingPet() then
		return pg.me:requestSwitchToPlayer(clientSwitchReason, nil, callback)
	end

	return false
end

function DialogueGraphUtils.switchCrouch(cmd)
	pg.game.controller:onHandleCrouch(true)
end

function DialogueGraphUtils.onMount(cmd, id)
	local ent = DialogueGraphUtils.getEntity(id)

	if ent and ent.tryMount then
		ent:tryMount(pg.pawn)
	end
end

function DialogueGraphUtils.onDismount(cmd)
	pg.pawn:dismountSelf()
end

function DialogueGraphUtils.changeEntityState(cmd, entityId, staticId, characterState, playableStateName, autoResume)
	local entity = DialogueGraphUtils.getEntityById(entityId, staticId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("实体不存在！", tostring(entityId))
		end

		return
	end

	DialogueGraphUtils.pauseEntityBt(cmd, entity)

	return callGraphItem(cmd, "ChangeEntityState", entityId, staticId, characterState, playableStateName, autoResume)
end

function DialogueGraphUtils.startEntityMove(cmd, moveConfig)
	if moveConfig == nil then
		return false
	end

	local entity = DialogueGraphUtils.getEntityById(moveConfig.entityId, moveConfig.staticId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("实体不存在！", tostring(moveConfig.entityId), tostring(moveConfig.staticId))
		end

		return false
	end

	DialogueGraphUtils.pauseEntityBt(cmd, entity)

	local ret = callGraphItem(cmd, "StartEntityMove", moveConfig)

	if ret and moveConfig.speed ~= nil and moveConfig.speed ~= 1 then
		DialogueGraphUtils.setEntityAnimSpeed(cmd, entity.id, moveConfig.speed)
	end

	return ret
end

function DialogueGraphUtils.steerEntity(cmd, entityId, staticId, targetEulerAngle, timeoutDuration, callback)
	local entity = DialogueGraphUtils.getEntityById(entityId, staticId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("实体不存在！", tostring(entityId))
		end

		return
	end

	DialogueGraphUtils.pauseEntityBt(cmd, entity)

	return callGraphItem(cmd, "SteerEntity", entityId, staticId, targetEulerAngle, timeoutDuration, callback)
end

function DialogueGraphUtils.playEntityAnimation(cmd, ...)
	return callGraphItem(cmd, "PlayEntityAnimation", ...)
end

function DialogueGraphUtils.stopEntityAnimation(cmd, entityId, stopImmediately)
	return callGraphItem(cmd, "StopEntityAnimation", entityId, stopImmediately)
end

function DialogueGraphUtils.playEntityFacialAnimation(cmd, entityId, playLip, playEmotion, facialEmotion, noBlink)
	local entity = DialogueGraphUtils.getEntity(entityId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("实体不存在！", tostring(entityId))
		end

		return nil
	end

	DialogueGraphUtils.pauseEntityBt(cmd, entity)

	return callGraphItem(cmd, "PlayEntityFacialAnimation", entityId, playLip, playEmotion, facialEmotion, noBlink)
end

function DialogueGraphUtils.stopEntityFacialAnimation(cmd, entityId, stopLip, stopEmotion, noBlink)
	return callGraphItem(cmd, "StopEntityFacialAnimation", entityId, stopLip, stopEmotion, noBlink)
end

function DialogueGraphUtils.playAnimatorState(cmd, target, stateName)
	return callGraphItem(cmd, "PlayAnimatorState", target, stateName)
end

function DialogueGraphUtils.disableEntityDialogueController(cmd, entityId)
	return callGraphItem(cmd, "DisableEntityDialogueController", entityId)
end

local function playResolvedEntityVisibilityEffect(cmd, entity, isFadeIn, duration, resetOnFinish, callback)
	local entityId = entity.id
	local isFadeIn = isFadeIn == true
	local duration = duration or 0

	if cmd.entitiesVisibilityInfo ~= nil then
		local info = cmd.entitiesVisibilityInfo[entityId]

		if info ~= nil and info.timerId ~= nil then
			TimerManager.removeTimer(info.timerId)

			info.timerId = nil
		end
	end

	local ret = callGraphItem(cmd, "PlayEntityVisibilityEffect", entityId, isFadeIn, duration)

	if ret then
		local resetOnFinish = resetOnFinish == true

		if resetOnFinish then
			cmd.entitiesVisibilityInfo = cmd.entitiesVisibilityInfo or {}
			cmd.entitiesVisibilityInfo[entityId] = cmd.entitiesVisibilityInfo[entityId] or {}
			cmd.entitiesVisibilityInfo[entityId].resetOnFinish = true
		end

		if duration > 0 then
			if isFadeIn then
				DialogueGraphUtils.setEntityVisible(cmd, entityId, isFadeIn)
			end

			local timerId = TimerManager.addTimer(duration, function()
				if not isFadeIn then
					DialogueGraphUtils.setEntityVisible(cmd, entityId, isFadeIn)
				end

				local info = cmd.entitiesVisibilityInfo and cmd.entitiesVisibilityInfo[entityId] or nil

				if info then
					info.timerId = nil
				end

				if callback then
					callback()
				end
			end)

			cmd.entitiesVisibilityInfo = cmd.entitiesVisibilityInfo or {}
			cmd.entitiesVisibilityInfo[entityId] = cmd.entitiesVisibilityInfo[entityId] or {}
			cmd.entitiesVisibilityInfo[entityId].timerId = timerId
		else
			DialogueGraphUtils.setEntityVisible(cmd, entityId, isFadeIn)

			if callback then
				callback()
			end
		end
	elseif callback then
		callback()
	end

	return ret
end

function DialogueGraphUtils.playEntityVisibilityEffect(cmd, param, callback)
	if param == nil then
		if callback then
			callback()
		end

		return false
	end

	local entity = DialogueGraphUtils.getEntityById(param.entityId, param.staticId)

	if entity == nil then
		if callback then
			callback()
		end

		return false
	end

	local ret = playResolvedEntityVisibilityEffect(cmd, entity, param.isFadeIn, param.duration, param.resetOnFinish, callback)

	return ret
end

function DialogueGraphUtils.playEntitiesVisibilityEffect(cmd, param, callback)
	if param == nil then
		if callback then
			callback()
		end

		return
	end

	local invokeCallback = false

	local function finishCallback()
		if invokeCallback then
			return
		end

		invokeCallback = true

		if callback then
			callback()
		end
	end

	local result = false
	local isFadeIn = param.isFadeIn == true
	local duration = param.duration or 0
	local resetOnFinish = param.resetOnFinish == true

	if param.entityIds ~= nil then
		for _, entityId in ipairs(param.entityIds) do
			local entity = DialogueGraphUtils.getEntity(entityId)

			if entity ~= nil then
				playResolvedEntityVisibilityEffect(cmd, entity, isFadeIn, duration, resetOnFinish, finishCallback)

				result = true
			end
		end
	end

	if param.staticIds ~= nil then
		for _, staticId in ipairs(param.staticIds) do
			local entity = DialogueGraphUtils.getEntity(staticId)

			if entity ~= nil then
				playResolvedEntityVisibilityEffect(cmd, entity, isFadeIn, duration, resetOnFinish, finishCallback)

				result = true
			end
		end
	end

	if not result and callback then
		callback()
	end

	return result
end

function DialogueGraphUtils.resetAllEntitiesVisibilityEffect(cmd)
	if cmd.entitiesVisibilityInfo == nil then
		return
	end

	for entityId, info in pairs(cmd.entitiesVisibilityInfo) do
		if info.timerId ~= nil then
			TimerManager.removeTimer(info.timerId)

			info.timerId = nil
		end

		if info.resetOnFinish then
			DialogueGraphUtils.setEntityVisible(cmd, entityId, true)
			callGraphItem(cmd, "PlayEntityVisibilityEffect", entityId, true, 1)
		end
	end

	cmd.entitiesVisibilityInfo = nil
end

function DialogueGraphUtils.isEntityIdle(cmd, staticId, entityId)
	return callGraphItem(cmd, "IsEntityIdle", staticId, entityId)
end

function DialogueGraphUtils.resetPlayerActions(cmd)
	pg.game.input:resetAllActions()

	return true
end

function DialogueGraphUtils.isPlayerIdle(cmd)
	return callGraphItem(cmd, "IsPlayerIdle")
end

function DialogueGraphUtils.getSandboxLevelItemTransform(cmd, sandboxId, staticId)
	return callGraphItem(cmd, "GetSandboxLevelItemTransform", sandboxId, staticId)
end

function DialogueGraphUtils.getOrCreateHomeFacilityProxy(cmd, nodeId, position, eulerAngles)
	return callGraphItem(cmd, "GetOrCreateHomeFacilityProxy", nodeId, position, eulerAngles)
end

function DialogueGraphUtils.getOrCreateAnimationCurveValue(cmd, nodeId, curveData, evaluateType)
	return callGraphItem(cmd, "GetOrCreateAnimationCurveValue", nodeId, curveData, evaluateType)
end

function DialogueGraphUtils.getOrCreateColorGradientValue(cmd, nodeId, sourceColor, targetColor, curveData, evaluateType, duration)
	return callGraphItem(cmd, "GetOrCreateColorGradientValue", nodeId, sourceColor, targetColor, curveData, evaluateType, duration)
end

function DialogueGraphUtils.getOrCreateDynamicDistanceValue(cmd, nodeId, source, target, distanceType, offset, scaleFactor)
	return callGraphItem(cmd, "GetOrCreateDynamicDistanceValue", nodeId, source, target, distanceType, offset, scaleFactor)
end

function DialogueGraphUtils.bindDynamicValue(cmd, ownerNodeId, portId, dynamicValueId)
	return callGraphItem(cmd, "BindDynamicValue", ownerNodeId, portId, dynamicValueId)
end

function DialogueGraphUtils.setEntityVisible(cmd, entId, visible)
	local ent = pg ~= nil and pg.getEntity ~= nil and pg.getEntity(entId) or nil

	if ent == nil then
		ent = DialogueGraphUtils.getEntity(entId)
	end

	if ent == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("对话图设置实体显隐失败，找不到实体 entityId=%s", tostring(entId))
		end

		return
	end

	if ent.setVisible then
		ent:setVisible(ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_GRAPH, visible)
	end
end

function DialogueGraphUtils.tryAttachOnVehicle(cmd, entId, vehicleEntId, seatId)
	local ent = DialogueGraphUtils.getEntity(entId)

	if ent == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s DialogueItemCmd.tryAttachOnVehicle failed ent == nil!, %s", entId)
		end

		return false
	end

	local vehicleEnt = DialogueGraphUtils.getEntity(vehicleEntId)

	if vehicleEnt == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s DialogueItemCmd.tryAttachOnVehicle failed vehicleEnt == nil!, %s", vehicleEntId)
		end

		return false
	end

	if ent.getSeatAttachData == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s DialogueItemCmd.tryAttachOnVehicle failed getSeatAttachData == nil!")
		end

		return false
	end

	local seatData = ent:getSeatAttachData(seatId)

	if seatData == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s DialogueItemCmd.tryAttachOnVehicle failed seatData == nil!, %d", seatId)
		end

		return false
	end

	local attachData = {
		isPhysics = false,
		offset = seatData.offset,
		rotate = seatData.rotationOffset,
		actorId = vehicleEnt.actorId,
		targetHP = seatData.seatHP,
		selfHP = seatData.passengerHP,
		freeRotation = vehicleEnt:isFreeRotation()
	}

	ent:attachByTable(attachData)

	return true
end

function DialogueGraphUtils.tryDetachFromVehicle(cmd, entId)
	local ent = DialogueGraphUtils.getEntity(entId)

	if ent == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s DialogueItemCmd.tryDetachFromVehicle failed ent == nil!, %s", entId)
		end

		return
	end

	ent:detach()
end

local function finishEntityAutoPathFinding(param)
	if param.finished then
		return
	end

	param.finished = true

	if param.arriveCallback ~= nil then
		param.arriveCallback()
	end
end

function DialogueGraphUtils.entAutoPathFinding(cmd, param)
	local ent = DialogueGraphUtils.getEntity(param.entityId)

	if ent == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s DialogueItemCmd.entAutoPathFinding failed ent == nil!, %s", param.entityId)
		end

		return
	end

	if ent.pawnAutoPathFinding then
		if param.animSpeed ~= nil then
			DialogueGraphUtils.setEntityAnimSpeed(cmd, param.entityId, param.animSpeed)
		end

		local function arriveCallback(ret)
			if param.finished then
				return
			end

			if param.animSpeed ~= nil then
				DialogueGraphUtils.setEntityAnimSpeed(cmd, param.entityId, -1)
			end

			if ret and param.steerToRot then
				local started = DialogueGraphUtils.steerEntity(cmd, ent.id, 0, param.steerToRot, 3, function()
					finishEntityAutoPathFinding(param)
				end)

				if not started then
					finishEntityAutoPathFinding(param)
				end

				return
			end

			finishEntityAutoPathFinding(param)
		end

		DialogueGraphUtils.pauseEntityBt(cmd, ent)
		cmd:setEntityTakeOver(param.entityId)
		ent:pawnAutoPathFinding(param.toPos, arriveCallback, param.pathFindingType, nil, param.moveState, true)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("%s DialogueItemCmd.entAutoPathFinding failed ent.pawnAutoPathFinding == nil!, %s", param.entityId)
	end
end

function DialogueGraphUtils.stopEntityAutoPathFinding(cmd, entityId)
	if entityId == nil then
		return
	end

	local ent = DialogueGraphUtils.getEntity(entityId)

	if ent == nil then
		return
	end

	if ent.eModel ~= nil then
		ent.eModel:StopAutoPath(Const.COMPONENT_AUTO_PATH_FIND, false)
	end
end

function DialogueGraphUtils.pauseBt(cmd, entityId, staticId)
	if type(entityId) == "string" and string.find(entityId, ",", 1, true) then
		for singleEntityId in string.gmatch(entityId, "([^,]+)") do
			local entity = DialogueGraphUtils.getEntityById(singleEntityId, nil)

			if entity ~= nil then
				DialogueGraphUtils.pauseEntityBt(cmd, entity)
			end
		end
	else
		local entity = DialogueGraphUtils.getEntityById(entityId, staticId)

		DialogueGraphUtils.pauseEntityBt(cmd, entity)
	end
end

function DialogueGraphUtils.pauseEntityBt(cmd, entity)
	if entity == nil or entity.pauseBt == nil then
		return false
	end

	entity.dialogueGraphPauseAIData = entity.dialogueGraphPauseAIData or {}

	if entity.dialogueGraphPauseAIData[cmd.id] ~= nil then
		return
	end

	entity.dialogueGraphPauseAIData[cmd.id] = true

	entity:pauseBt(AIConst.PauseBtReason.DialogueGraph)

	cmd.pauseBtEntities[entity.id] = true

	cmd:addActorRenewInvincible(entity)

	return true
end

function DialogueGraphUtils.resumeBt(cmd, entityId, staticId)
	if type(entityId) == "string" and string.find(entityId, ",", 1, true) then
		for singleEntityId in string.gmatch(entityId, "([^,]+)") do
			local entity = DialogueGraphUtils.getEntityById(singleEntityId, nil)

			DialogueGraphUtils.resumeEntityBt(cmd, entity)
		end
	else
		local entity = DialogueGraphUtils.getEntityById(entityId, staticId)

		DialogueGraphUtils.resumeEntityBt(cmd, entity)
	end
end

function DialogueGraphUtils.resumeEntityBt(cmd, entity)
	if entity == nil or entity.resumeBt == nil then
		return
	end

	if entity.dialogueGraphPauseAIData == nil or entity.dialogueGraphPauseAIData[cmd.id] == nil then
		return false
	end

	cmd.pauseBtEntities[entity.id] = true
	entity.dialogueGraphPauseAIData[cmd.id] = nil

	local canResume = table.getCount(entity.dialogueGraphPauseAIData) == 0

	if canResume then
		entity:resumeBt(AIConst.PauseBtReason.DialogueGraph)

		entity.dialogueGraphPauseAIData = nil
	end

	return true
end

function DialogueGraphUtils.pauseNearbyMonsterAI(cmd)
	local entities = pg.me:entitiesInRange(DialogueGraphConst.MONSTER_PAUSE_AI_RANGE, Const.SEARCH_USR_TYPE_MONSTER)
	local actorIds

	for k, v in pairs(entities) do
		local ent = pg.getEntityByActorId(v)

		if ent and not Utils.isNpc(ent) then
			DialogueGraphUtils.pauseEntityBt(cmd, ent)

			if ent.actorId then
				actorIds = actorIds or {}

				table.insert(actorIds, ent.actorId)
			end
		end
	end

	cmd:addActorsRenewInvincible(actorIds)
end

function DialogueGraphUtils.resumeNearbyMonsterAI(cmd)
	DialogueGraphUtils.resumeAllEntitiesBt(cmd)
	cmd:removeRenewInvincible()
end

function DialogueGraphUtils.resumeAllEntitiesBt(cmd)
	local entityIds = {}

	for entityId in pairs(cmd.pauseBtEntities) do
		table.insert(entityIds, entityId)
	end

	for _, entityId in ipairs(entityIds) do
		DialogueGraphUtils.resumeBt(cmd, entityId, nil, true)
	end

	cmd.pauseBtEntities = {}
end

function DialogueGraphUtils.pauseEntityAoi(cmd, ent)
	if ent == nil then
		return
	end

	ent:setTempPosSync(false, Const.TEMP_POS_SYNC_REASON.DIALOGUE_GRAPH)
end

function DialogueGraphUtils.resumeEntityAoi(cmd, ent)
	if ent == nil then
		return
	end

	ent:clearTempPosSync(Const.TEMP_POS_SYNC_REASON.DIALOGUE_GRAPH)
end

function DialogueGraphUtils.isEntityAIRunning(entity)
	if entity == nil then
		return false
	end

	if not entity.isAIRunning or type(entity.isAIRunning) ~= "function" then
		return false
	end

	local isRunning = entity:isAIRunning()

	return isRunning
end

function DialogueGraphUtils.checkEntityAIRunning(cmd, entityId, staticId)
	local ent = DialogueGraphUtils.getEntityById(entityId, staticId)

	if ent == nil then
		return false
	end

	return DialogueGraphUtils.isEntityAIRunning(ent)
end

function DialogueGraphUtils.setEntityAnimSpeed(cmd, entId, speed)
	local entity = DialogueGraphUtils.getEntity(entId)

	if entity == nil then
		return
	end

	entity:setAnimScaleByDialogueGraph(speed)

	if speed < 0 then
		if cmd.entitiesAnimSpeed ~= nil then
			cmd.entitiesAnimSpeed[entId] = nil
		end
	else
		if cmd.entitiesAnimSpeed == nil then
			cmd.entitiesAnimSpeed = {}
		end

		cmd.entitiesAnimSpeed[entId] = speed
	end
end

function DialogueGraphUtils.resetEntitiesAnimSpeed(cmd)
	if cmd.entitiesAnimSpeed == nil then
		return
	end

	for k, v in pairs(cmd.entitiesAnimSpeed) do
		local entity = DialogueGraphUtils.getEntity(k)

		if entity ~= nil then
			entity:setAnimScaleByDialogueGraph(-1)
		end
	end

	cmd.entitiesAnimSpeed = nil
end

function DialogueGraphUtils.canPlaySpecialIdleInDialogueGraph(cmd, ent, can)
	if ent == nil then
		return
	end

	ent.isInDialogueGraph = not can
end

function DialogueGraphUtils.lookAtRole(cmd, srcEntId, destEntId)
	if string.isNilOrEmpty(srcEntId) or string.isNilOrEmpty(destEntId) then
		return
	end

	local srcEnt = DialogueGraphUtils.getEntity(srcEntId)

	if srcEnt == nil then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("找不到对应的实体 GlobalID", srcEntId)
		end

		return
	end

	local destEnt = DialogueGraphUtils.getEntity(destEntId)

	if destEnt == nil then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("找不到对应的Role实体 GlobalID", destEntId)
		end

		return
	end

	DialogueGraphUtils.pauseEntityBt(cmd, srcEnt)
	EntityLookAtUtils.setLookAtManual(srcEnt, destEnt)
	EntityLookAtUtils.doModifyLookAt()

	if cmd.lookAtRoleInfo == nil then
		cmd.lookAtRoleInfo = {}
	end

	cmd.lookAtRoleInfo[srcEntId] = true
end

function DialogueGraphUtils.cancelLookAtRole(cmd, srcEntId)
	if string.isNilOrEmpty(srcEntId) then
		return
	end

	local srcEnt = DialogueGraphUtils.getEntity(srcEntId)

	if srcEnt == nil then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("找不到对应的实体 GlobalID", srcEntId)
		end

		return
	end

	EntityLookAtUtils.removeLookAtManual(srcEnt, 0.5)
	EntityLookAtUtils.doModifyLookAt()

	if cmd.lookAtRoleInfo ~= nil then
		cmd.lookAtRoleInfo[srcEntId] = nil
	end
end

function DialogueGraphUtils.cancelAllLookAtRole(cmd)
	if cmd.lookAtRoleInfo == nil then
		return
	end

	for entityId, v in pairs(cmd.lookAtRoleInfo) do
		DialogueGraphUtils.cancelLookAtRole(cmd, entityId)
	end

	cmd.lookAtRoleInfo = nil
end

function DialogueGraphUtils.multiLookAt(cmd, param)
	if param == nil then
		return
	end

	if cmd.lookAtRoleInfo == nil then
		cmd.lookAtRoleInfo = {}
	end

	local lookingDic = {}

	for i, item in ipairs(param) do
		local lookAt = item.lookAt
		local lookAtEnt = DialogueGraphUtils.getEntity(lookAt.entityId or lookAt.staticId)

		if lookAtEnt then
			for j, watcher in ipairs(item.watchers) do
				local watchId = watcher.entityId or watcher.staticId
				local watchEnt = DialogueGraphUtils.getEntity(watchId)

				if watchEnt and lookingDic[watchEnt] == nil then
					lookingDic[watchEnt] = 1
					cmd.lookAtRoleInfo[watchId] = true

					EntityLookAtUtils.setLookAtManual(watchEnt, lookAtEnt)
				end
			end
		end
	end

	EntityLookAtUtils.doModifyLookAt()
end

function DialogueGraphUtils.cancelMultiLookAt(cmd, param)
	if param == nil then
		return
	end

	for j, watcher in ipairs(param) do
		local watchId = watcher.entityId or watcher.staticId
		local watchEnt = DialogueGraphUtils.getEntity(watcher.entityId or watcher.staticId)

		EntityLookAtUtils.removeLookAtManual(watchEnt)

		if cmd.lookAtRoleInfo then
			cmd.lookAtRoleInfo[watchId] = nil
		end
	end

	EntityLookAtUtils.doModifyLookAt()
end

function DialogueGraphUtils.entityShowBubbleEmoji(cmd, entId, emojiName, duration)
	if entId == nil then
		return
	end

	local ent = DialogueGraphUtils.getEntity(entId)

	if ent == nil or ent.eventEmitter == nil then
		return
	end

	local EventConst = require("Const.EventConst")

	ent.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, true, emojiName, duration, nil, true)
end

function DialogueGraphUtils.toggleLodTick(cmd, ent, open)
	if ent == nil then
		return
	end

	if not open then
		ent:setRendererLod(0)
	else
		ent:setRendererLod(-1)
	end

	ent:setLodTickEnable(Const.LOD_TICK_KEY.DIALOGUE_GRAPH, open)
end

function DialogueGraphUtils.changeAmbientIntensity(cmd)
	local targetIntensity = SysConfigData.dialogueGraphAmbientIntensity or 1.5
	local blendTime = SysConfigData.dialogueGraphAmbientIntensityBlendTime

	cmd.graphItem:ChangeAmbientIntensity(targetIntensity, blendTime)
end

function DialogueGraphUtils.restoreAmbientIntensity(cmd)
	local blendTime = SysConfigData.dialogueGraphAmbientIntensityBlendTime or 1.5

	cmd.graphItem:RestoreAmbientIntensity(blendTime)
end

function DialogueGraphUtils.playSwitchToPet(cmd, playerEntId, petEntId, isIdyll, finishedCallback)
	local playerEnt = DialogueGraphUtils.getEntity(playerEntId)

	if playerEnt == nil then
		return
	end

	local petEnt = DialogueGraphUtils.getEntity(petEntId)

	if petEnt == nil then
		return
	end

	DialogueGraphUtils.pauseEntityBt(cmd, playerEnt)
	DialogueGraphUtils.pauseEntityBt(cmd, petEnt)

	if cmd.petSwitchAnim == nil then
		cmd.petSwitchAnim = PetSwitchAnim.new()
	end

	local petSwitchAnim = cmd.petSwitchAnim
	local extraData = {}

	extraData.ignoreCamera = true
	extraData.forcePlay = true
	extraData.isIdyllSwitch = isIdyll

	function extraData.finishedCallback()
		playerEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_GRAPH, false)
		petSwitchAnim:destroy()

		if finishedCallback then
			finishedCallback()
		end
	end

	local ret, errors = ClientUtils.tryWithLogError(function()
		petSwitchAnim:playSwitchToPetAnimSpecial2(petEnt, playerEnt, extraData)
	end)

	if not ret and finishedCallback then
		finishedCallback()
	end
end

function DialogueGraphUtils.playSwitchToPlayer(cmd, playerEntId, petEntId, isIdyll, finishedCallback)
	local playerEnt = DialogueGraphUtils.getEntity(playerEntId)

	if playerEnt == nil then
		return
	end

	local petEnt = DialogueGraphUtils.getEntity(petEntId)

	if petEnt == nil then
		return
	end

	DialogueGraphUtils.pauseEntityBt(cmd, playerEnt)
	DialogueGraphUtils.pauseEntityBt(cmd, petEnt)

	if cmd.petSwitchAnim == nil then
		cmd.petSwitchAnim = PetSwitchAnim.new()
	end

	local petSwitchAnim = cmd.petSwitchAnim
	local extraData = {}

	extraData.ignoreCamera = true
	extraData.forcePlay = true
	extraData.isIdyllSwitch = isIdyll

	function extraData.finishedCallback()
		petSwitchAnim:destroy()

		if finishedCallback then
			finishedCallback()
		end
	end

	local ret, errors = ClientUtils.tryWithLogError(function()
		playerEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_GRAPH, true)
		petSwitchAnim:playSwitchToPlayerAnim(petEnt, playerEnt, extraData)
	end)

	if not ret and finishedCallback then
		finishedCallback()
	end
end

function DialogueGraphUtils.entityCastAbility(cmd, entId, abilityId, targetEntityId)
	if entId == nil then
		return
	end

	local castEnt = DialogueGraphUtils.getEntity(entId)

	if castEnt == nil then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("找不到对应的实体 GlobalID", entId)
		end

		return
	end

	local targetEnt

	if targetEntityId ~= nil and targetEntityId ~= 0 then
		targetEnt = DialogueGraphUtils.getEntity(targetEntityId)
	end

	if targetEnt == nil and castEnt.castAbilityNoTarget then
		castEnt:castAbilityNoTarget(abilityId, AbilityConst.CAST_SOURCE.DIALOGUE_GRAPH)
	elseif targetEnt ~= nil and castEnt.castAbilityOnTarget then
		castEnt:castAbilityOnTarget(abilityId, targetEnt.actorId, AbilityConst.CAST_SOURCE.DIALOGUE_GRAPH)
	end
end

function DialogueGraphUtils.entityCancelAbility(cmd, entId)
	if entId == nil then
		return
	end

	local ent = DialogueGraphUtils.getEntity(entId)

	if ent and ent.cancelAbility then
		ent:cancelAbility()
	end
end

function DialogueGraphUtils.createRefVirtualEntity(cmd, refVirtualEntity)
	local function callback(ent)
		if ent == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("虚拟实体创建失败 ", refVirtualEntity.entityId)
			end

			if refVirtualEntity.callback then
				refVirtualEntity.callback(nil)
			end

			return
		end

		if cmd.playState == DialogueGraphConst.DIALOGUE_GRAPH_STATE.DESTROY then
			ClientUtils.safeDestroy(ent)

			return
		end

		for k, virtualEnt in pairs(cmd.virtualEntities) do
			if virtualEnt.staticId == refVirtualEntity.entityId and virtualEnt.id ~= ent.id then
				ClientUtils.safeDestroy(ent)

				if refVirtualEntity.callback then
					refVirtualEntity.callback(nil)
				end

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("虚拟实体已经创建，请勿我重复创建 ", refVirtualEntity.entityId)
				end

				return
			end
		end

		if refVirtualEntity.visible == false and ent.setVisible then
			ent:setVisible(ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_GRAPH, false)
		end

		if refVirtualEntity.ignoreGravity and ent.eModel then
			ent.eModel:SetComputeGravity(Const.COMPONENT_MOTION, ClientConst.GravityMask.DialogueGraph, false)
		end

		DialogueGraphUtils.toggleLodTick(cmd, ent, false)
		ent.eModel:SetTransformParent(cmd.graphItem.rootObject.transform)

		if refVirtualEntity.callback then
			refVirtualEntity.callback(ent.eModel)
		end
	end

	if DialogueGraphUtils.isVirtualEntityExist(cmd, refVirtualEntity.entityId) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("虚拟实体已经创建，请勿我重复创建 ", refVirtualEntity.entityId)
		end

		callback(nil)

		return
	end

	local virtualActor = cmd:getVirtualActorInfo(refVirtualEntity.entityId)
	local entityType = virtualActor and virtualActor.virtualEntType or refVirtualEntity.entityType
	local templateId = virtualActor and virtualActor.templateId or refVirtualEntity.templateId
	local label = virtualActor and virtualActor.label or refVirtualEntity.label
	local virtualData = {}

	virtualData.actorId = refVirtualEntity.entityId
	virtualData.staticId = refVirtualEntity.entityId
	virtualData.position = refVirtualEntity.position
	virtualData.rotation = refVirtualEntity.rotation
	virtualData.extraAngle = virtualActor and virtualActor.angleDelta or 0
	virtualData.syncLoad = true
	virtualData.animatorReadyCallback = callback

	if entityType == DialogueGraphConst.VIRTUAL_ENTITY_TYPE.PLAYER then
		virtualData.copyEntity = pg.me
		virtualData.templateId = pg.me.templateId
		virtualData.virtualTemplateActorType = Const.ACTOR_TYPE_PLAYER
	elseif entityType == DialogueGraphConst.VIRTUAL_ENTITY_TYPE.PLAYER_PET then
		local curPet = pg.me:getCurPetEntity()

		if curPet == nil then
			callback(nil)

			return
		end

		virtualData.copyEntity = curPet
		virtualData.templateId = curPet.templateId
		virtualData.virtualTemplateActorType = Const.ACTOR_TYPE_PET
	elseif entityType == DialogueGraphConst.VIRTUAL_ENTITY_TYPE.NPC then
		virtualData.templateId = templateId
		virtualData.label = label
		virtualData.virtualTemplateActorType = Const.ACTOR_TYPE_PUPPET
	elseif entityType == DialogueGraphConst.VIRTUAL_ENTITY_TYPE.PLAYER_MATE_1 or entityType == DialogueGraphConst.VIRTUAL_ENTITY_TYPE.PLAYER_MATE_2 or entityType == DialogueGraphConst.VIRTUAL_ENTITY_TYPE.PLAYER_MATE_3 or entityType == DialogueGraphConst.VIRTUAL_ENTITY_TYPE.PLAYER_MATE_4 then
		if not pg.me:isInTeam() then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("没有组队信息！")
			end

			callback()

			return
		end

		local sortIndex = entityType - DialogueGraphConst.VIRTUAL_ENTITY_TYPE.PLAYER_PET
		local teamInfo = pg.me:getCurTeamInfo()
		local uid = teamInfo.sortList[sortIndex]
		local memInfo = teamInfo.membersInfo[uid]

		if memInfo == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("当前位置队友信息不存在！")
			end

			callback()

			return
		end

		local menEnt = DialogueGraphUtils.getEntity(memInfo.entityId)

		if menEnt == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("队友实体不存在！")
			end

			callback()

			return
		end

		virtualData.copyEntity = menEnt
		virtualData.templateId = menEnt.templateId
		virtualData.virtualTemplateActorType = Const.ACTOR_TYPE_PLAYER
	end

	local ent
	local ret, errors = ClientUtils.tryWithLogError(function()
		ent = ClientVirtualEntityUtils.createTempVirtualNpc(virtualData)

		if ent then
			cmd.virtualEntities[ent.id] = ent
		end
	end)

	if not ret then
		callback(ent)
	end
end

function DialogueGraphUtils.isVirtualEntityExist(cmd, staticId)
	for k, virtualEnt in pairs(cmd.virtualEntities) do
		if virtualEnt.staticId == staticId then
			return true
		end
	end

	return false
end

function DialogueGraphUtils.destroyAllVirtualEntities(cmd)
	for k, virtualEnt in pairs(cmd.virtualEntities) do
		if virtualEnt.destroy then
			ClientUtils.safeDestroy(virtualEnt)
		end

		cmd.virtualEntities[k] = nil
	end
end

function DialogueGraphUtils.startLight(cmd, ...)
	return callGraphItem(cmd, "StartLight", ...)
end

function DialogueGraphUtils.disableLight(cmd, nodeId)
	return callGraphItem(cmd, "DisableLight", nodeId)
end

function DialogueGraphUtils.stopLight(cmd, nodeId)
	return callGraphItem(cmd, "StopLight", nodeId)
end

function DialogueGraphUtils.startEntityLight(cmd, nodeId, lightResId, position, rotation)
	return callGraphItem(cmd, "StartEntityLight", nodeId, lightResId, position, rotation)
end

function DialogueGraphUtils.disableEntityLight(cmd, nodeId)
	return callGraphItem(cmd, "DisableEntityLight", nodeId)
end

function DialogueGraphUtils.stopEntityLight(cmd, nodeId)
	return callGraphItem(cmd, "StopEntityLight", nodeId)
end

function DialogueGraphUtils.startCameraShake(cmd, nodeId, shakeType, shakeConfig)
	return callGraphItem(cmd, "StartCameraShake", nodeId, shakeType, shakeConfig)
end

function DialogueGraphUtils.stopCameraShake(cmd, nodeId)
	return callGraphItem(cmd, "StopCameraShake", nodeId)
end

function DialogueGraphUtils.startLocalWind(cmd, nodeId, startPosition, endPosition, maxIntensity, maxSpeed)
	return callGraphItem(cmd, "StartLocalWind", nodeId, startPosition, endPosition, maxIntensity, maxSpeed)
end

function DialogueGraphUtils.disableLocalWind(cmd, nodeId)
	return callGraphItem(cmd, "DisableLocalWind", nodeId)
end

function DialogueGraphUtils.startLocalEnvironment(cmd, nodeId, resId, position)
	return callGraphItem(cmd, "StartLocalEnvironment", nodeId, resId, position)
end

function DialogueGraphUtils.stopLocalEnvironment(cmd, nodeId)
	return callGraphItem(cmd, "StopLocalEnvironment", nodeId)
end

function DialogueGraphUtils.applyVolume(cmd, nodeId, data)
	return callGraphItem(cmd, "ApplyVolume", nodeId, data)
end

function DialogueGraphUtils.disableVolume(cmd, nodeId)
	return callGraphItem(cmd, "DisableVolume", nodeId)
end

function DialogueGraphUtils.stopVolumeAnimation(cmd, nodeId)
	return callGraphItem(cmd, "StopVolumeAnimation", nodeId)
end

function DialogueGraphUtils.resetVolume(cmd, nodeId)
	return callGraphItem(cmd, "ResetVolume", nodeId)
end

function DialogueGraphUtils.attachToGraphRoot(cmd, gameObject)
	local rootObject = cmd and cmd.graphItem and cmd.graphItem.rootObject or nil

	if gameObject == nil or gameObject.transform == nil or rootObject == nil or rootObject.transform == nil then
		return false
	end

	gameObject.transform:SetParent(rootObject.transform)

	return true
end

function DialogueGraphUtils.setCharacterFillLight(cmd, enabled, intensity)
	cmd.graphItem:SetCharacterFillLight(enabled == true, intensity or 0)
end

function DialogueGraphUtils.preloadCutscenes(cutsceneList)
	if cutsceneList == nil then
		return
	end

	local preloadCutscenes = {}

	for i = 1, #cutsceneList do
		local param = cutsceneList[i]
		local cutscene = pg.game.cutscene:preloadCutscene(param.resId, param.resId, param.pos, param.rot)

		table.insert(preloadCutscenes, cutscene)
	end

	return preloadCutscenes
end

function DialogueGraphUtils.unPreloadCutScenes(cutsceneList)
	if cutsceneList == nil then
		return
	end

	for i = 1, #cutsceneList do
		local cutscene = cutsceneList[i]

		DialogueGraphUtils.unPreloadCutScene(nil, cutscene.name)
	end
end

function DialogueGraphUtils.preloadCutscene(cmd, param)
	local function startPlayCallback()
		param.startPlayCallback()
	end

	local function prePlayEndCallback()
		cmd:cancelNodeFuncTypeState(DialogueGraphConst.NODE_FUNC_TYPE.PLAY_CUTSCENE)
		param.preEndCallback()
	end

	local function playEndCallback()
		cmd:cancelNodeFuncTypeState(DialogueGraphConst.NODE_FUNC_TYPE.PLAY_CUTSCENE)
		param.endCallback()
	end

	local cutscene = pg.game.cutscene:getPreloadCutscene(param.resId)

	if cutscene then
		cutscene.extraData.startPlayCallback = startPlayCallback
		cutscene.extraData.prePlayEndCallback = prePlayEndCallback
		cutscene.extraData.playEndCallback = playEndCallback

		return
	end

	local extraData = {}

	extraData.startPlayCallback = startPlayCallback
	extraData.prePlayEndCallback = prePlayEndCallback
	extraData.playEndCallback = playEndCallback
	cutscene = pg.game.cutscene:preloadCutscene(param.resId, param.resId, param.pos, param.rot, extraData)

	local id = cutscene and cutscene.id or -1

	return id
end

function DialogueGraphUtils.unPreloadCutScene(cmd, cutsceneName)
	pg.game.cutscene:unPreloadCutScene(cutsceneName)
end

function DialogueGraphUtils.playCutscene(cmd, name)
	ClientUtils.forceExitGhostEyeState()

	local ret, id = pg.game.cutscene:playPreloadCutscene(name)

	return ret
end

function DialogueGraphUtils.stopCutscene(cmd, cutsceneId)
	pg.game.cutscene:stopCutscene(cutsceneId)
end

function DialogueGraphUtils.getEffectGeneratorId(cmd, entId)
	local generatorId

	if not string.isNilOrEmpty(entId) then
		generatorId = pg.game.effect:getEntityGeneratorId(entId)
	else
		generatorId = pg.game.effect:createGenerator(cmd.graphItem.rootObject.transform)
	end

	return generatorId
end

function DialogueGraphUtils.playEffect(cmd, generatorId, effectKey, pos, rotation)
	local effectId

	if pos == nil then
		effectId = pg.game.effect:playEffect(generatorId, effectKey)
	else
		effectId = pg.game.effect:playRawEffectAt(generatorId, effectKey, pos, {
			duration = -1,
			rotation = rotation
		})
	end

	if cmd.playEffectInfo == nil then
		cmd.playEffectInfo = {}
	end

	table.insert(cmd.playEffectInfo, {
		generatorId = generatorId,
		effectId = effectId
	})

	return effectId
end

function DialogueGraphUtils.stopPlayAllEffect(cmd)
	if cmd.playEffectInfo == nil then
		return
	end

	for _, info in ipairs(cmd.playEffectInfo) do
		DialogueGraphUtils.stopPlayEffect(cmd, info.generatorId, info.effectId)
	end

	cmd.playEffectInfo = nil
end

function DialogueGraphUtils.stopPlayEffect(cmd, generatorId, effectId)
	pg.game.effect:stopEffect(generatorId, effectId)

	if cmd.playEffectInfo ~= nil then
		for idx, info in ipairs(cmd.playEffectInfo) do
			if generatorId == info.generatorId and effectId == info.effectId then
				table.remove(cmd.playEffectInfo, idx)

				break
			end
		end
	end
end

function DialogueGraphUtils.triggerCustomCallback(cmd, ret, key)
	if cmd.taskInfo.extraData ~= nil and cmd.taskInfo.extraData.customCallback then
		cmd.taskInfo.extraData.customCallback(ret)
	end

	if facade ~= nil and facade.sendLuaEvent ~= nil then
		facade:sendLuaEvent("DialogueGraphCustomCallback", cmd.id or 0, key or "", ret or 0)
	end
end

function DialogueGraphUtils.startGuide(cmd, guideId, callback)
	pg.game.guide:clientStartGuide(guideId, callback)
end

function DialogueGraphUtils.changeWeather(cmd, timePeriod, param)
	local st, err = SafeCallbackWithStatusAndReturn(function()
		if timePeriod > 0 then
			pg.game.weather:changeTodTime(0, 0, timePeriod)
		end

		if param.type == 0 then
			if param.cloud >= 0 then
				appFacade.pipelineManager:TrySetLightFunctionCloudShadowContrast(param.cloud)
			end
		elseif param.type == 1 then
			pg.game.weather:setClientWeather(param.weather)
		end
	end)

	if not st and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("DialogueGraphUtils.changeWeather failed dialogueId=%s error=%s", tostring(cmd and cmd.id), tostring(err))
	end

	return st
end

function DialogueGraphUtils.resetWeather(cmd, resetTimePeriod, resetCloudShadowContrast, resetWeather)
	if resetTimePeriod then
		pg.space:onRenderTimePeriodChange()
	end

	if resetCloudShadowContrast then
		appFacade.pipelineManager:TryResetLightFunctionCloudShadowContrast()
	end

	if resetWeather then
		pg.game.weather:resetClientWeather()
	end
end

function DialogueGraphUtils.setVegetationCullingDisabled(cmd, disabled)
	local effectMgr = pg and pg.global and pg.global.effectMgr

	if effectMgr == nil then
		return false
	end

	effectMgr:EnableAreaDithering(not disabled)

	return true
end

function DialogueGraphUtils.resetVegetationCulling(cmd)
	local effectMgr = pg and pg.global and pg.global.effectMgr

	if effectMgr == nil then
		return false
	end

	effectMgr:EnableAreaDithering(true)

	return true
end

function DialogueGraphUtils.setSetting(key, value)
	pg.me:setClientInfo(Const.CLIENT_KEY.DIALOGUE_GRAPH, key, value)
end

function DialogueGraphUtils.getSetting(key, defaultVal)
	return pg.me:getClientInfo(Const.CLIENT_KEY.DIALOGUE_GRAPH, key) or defaultVal
end

function DialogueGraphUtils.doEventByData(cmd, eventName, eventData)
	eventData = eventData or {}

	pg.me:doEventByData({
		eventName,
		eventData
	})
end

function DialogueGraphUtils.canDialogueGraphSkip()
	return pg.me.space and not pg.me.space:isMultiPlayerEnv()
end

function DialogueGraphUtils.enterDialogset(cmd, param)
	if param.cancelled then
		return
	end

	DialogueGraphUtils.applyDialogsetSlot(cmd, param, function()
		if param.cancelled then
			return
		end

		DialogueGraphUtils.applyDialogsetCamera(cmd, param)
	end)
end

local function finishDialogsetTask(cmd, param, task, stopMove)
	param.pendingTasks[task] = nil

	if task.timerId ~= nil then
		TimerManager.removeTimer(task.timerId)

		task.timerId = nil
	end

	if task.restoreAnimSpeed then
		task.restoreAnimSpeed = false

		DialogueGraphUtils.setEntityAnimSpeed(cmd, task.entityId, 1)
	end

	if stopMove and task.moving then
		task.moving = false

		DialogueGraphUtils.disableEntityDialogueController(cmd, task.entityId)
	end
end

function DialogueGraphUtils.cancelPendingDialogset(cmd, param)
	if param == nil or param.cancelled then
		return
	end

	param.cancelled = true

	local tasks = param.pendingTasks

	param.pendingTasks = {}

	for task in pairs(tasks or {}) do
		local ok, err = SafeCallbackWithStatusAndReturn(finishDialogsetTask, cmd, param, task, true)

		if not ok then
			logger:error("取消站位预设任务失败 entityId=%s error=%s", tostring(task.entityId), tostring(err))
		end
	end
end

function DialogueGraphUtils.getDialogsetData(sceneId, dialogsetId)
	if sceneId == nil or dialogsetId == nil or sceneId == 0 or dialogsetId == 0 then
		return
	end

	local sceneDialogsetData = SceneUtils.getSceneDialogsetData(sceneId)

	return sceneDialogsetData and sceneDialogsetData[dialogsetId] or nil
end

local function applyDialogsetEntity(cmd, param, ent, slotInfo, callback, task)
	if param.cancelled then
		return
	end

	local targetPosData = slotInfo.position
	local targetRotationData = slotInfo.rotation

	if targetPosData == nil or targetRotationData == nil then
		callback(false)

		return
	end

	local targetPos = DialogueGraphUtils.toVector3(targetPosData)
	local targetRot = DialogueGraphUtils.toQuaternion(targetRotationData)
	local targetEuler = targetRot:ToEulerAngles()
	local curPos = ent:getPosition()

	if DialogueGraphUtils.ApproximatelyVector3(curPos, targetPos, 0.1) then
		DialogueGraphUtils.setEntityRotationByQua(ent, targetRot, true)
		callback(true)

		return
	end

	if param.enterType == DialogueGraphConst.DialogsetEnterType.Teleport then
		DialogueGraphUtils.setEntityPositionAndRotation(ent, targetPos, targetRot)
		callback(true)

		return
	end

	local moveConfig = {
		faceMoveDirection = true,
		autoPathfinding = false,
		moveType = 1,
		moveMode = 0,
		staticId = 0,
		finishToSteer = true,
		speed = 1,
		duration = 0,
		maxLimitTime = -1,
		taskId = param.taskId,
		entityId = ent.id,
		targetPosition = targetPos,
		targetEulerAngle = targetEuler,
		callback = callback
	}

	if task ~= nil then
		task.moving = true
	end

	local started = DialogueGraphUtils.startEntityMove(cmd, moveConfig)

	if param.cancelled then
		if started then
			DialogueGraphUtils.disableEntityDialogueController(cmd, ent.id)
		end
	elseif not started then
		if task ~= nil then
			task.moving = false
		end

		callback(false)
	end
end

function DialogueGraphUtils.applyDialogsetSlot(cmd, param, callback)
	if param.cancelled then
		return
	end

	param.pendingTasks = param.pendingTasks or {}

	local sceneId = cmd.config.sceneId
	local dialogsetId = cmd.config.dialogsetId

	if sceneId == nil or dialogsetId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[DialogueGraphUtils] enterDialogset failed, sceneId or dialogsetId is nil")
		end

		if callback then
			callback()
		end

		return
	end

	local dialogsetData = DialogueGraphUtils.getDialogsetData(sceneId, dialogsetId)

	if not dialogsetData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[DialogueGraphUtils] enterDialogset failed, sceneDialogsetData[%d] is nil", sceneId)
		end

		if callback then
			callback()
		end

		return
	end

	if dialogsetData.slotIds == nil then
		if callback then
			callback()
		end

		return
	end

	local moveFinishedCount = 0
	local slotCount = #dialogsetData.slotIds

	if slotCount == 0 then
		if callback then
			callback()
		end

		return
	end

	local function checkFinished()
		if param.cancelled then
			return
		end

		moveFinishedCount = moveFinishedCount + 1

		if moveFinishedCount >= slotCount and callback then
			callback()
		end
	end

	for i = 1, slotCount do
		if param.cancelled then
			return
		end

		local ent
		local slotInfo = dialogsetData.slots[dialogsetData.slotIds[i]]

		if slotInfo.type == DialogueGraphConst.DialogsetSlotType.MainPlayer then
			ent = pg.pawn

			cmd:forbidPositionCheck(slotInfo.position)
		elseif slotInfo.type == DialogueGraphConst.DialogsetSlotType.MainPlayerPet then
			ent = pg.me:getCurPetEntity()
		elseif slotInfo.type == DialogueGraphConst.DialogsetSlotType.VirtualNpc then
			ent = DialogueGraphUtils.getEntity(slotInfo.VirtualActorId)
		else
			ent = DialogueGraphUtils.getEntity(slotInfo.entityId)
		end

		if ent ~= nil then
			if param.enterType == DialogueGraphConst.DialogsetEnterType.Teleport then
				applyDialogsetEntity(cmd, param, ent, slotInfo, checkFinished)
			else
				local task = {
					entityId = ent.id
				}

				param.pendingTasks[task] = true
				task.timerId = TimerManager.addTimer(8, function()
					if param.cancelled or not param.pendingTasks[task] then
						return
					end

					finishDialogsetTask(cmd, param, task, true)

					if param.cancelled then
						return
					end

					if slotInfo.type == DialogueGraphConst.DialogsetSlotType.MainPlayer then
						cmd:forbidPositionCheck(slotInfo.position)
					end

					DialogueGraphUtils.setEntityPositionAndRotation(ent, DialogueGraphUtils.toVector3(slotInfo.position), DialogueGraphUtils.toQuaternion(slotInfo.rotation))
					checkFinished()
				end)

				if slotInfo.type == DialogueGraphConst.DialogsetSlotType.MainPlayer then
					task.restoreAnimSpeed = true

					DialogueGraphUtils.setEntityAnimSpeed(cmd, ent.id, 1.2)
				end

				applyDialogsetEntity(cmd, param, ent, slotInfo, function()
					if param.cancelled or not param.pendingTasks[task] then
						return
					end

					finishDialogsetTask(cmd, param, task, false)
					checkFinished()
				end, task)
			end
		else
			checkFinished()

			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:error("[DialogueGraphUtils] applyDialogsetSlot target entity type %d  %d is nil!", slotInfo.type, slotInfo.entityId)
			end
		end
	end
end

function DialogueGraphUtils.setEntityPositionAndRotation(entity, position, rotation)
	if entity and entity.eModel then
		EModelUtils.setAgentPositionAndRotation(entity, position, rotation, true)
	end
end

function DialogueGraphUtils.applyDialogsetCamera(cmd, param)
	if param.cancelled then
		return
	end

	local cameraId = param.cameraId

	if not cameraId or cameraId == 0 then
		if param.applyCameraFinishCallback then
			param.applyCameraFinishCallback()
		end

		return
	end

	local sceneId = cmd.config.sceneId
	local dialogsetId = cmd.config.dialogsetId

	if sceneId == nil or dialogsetId == nil then
		if param.applyCameraFinishCallback then
			param.applyCameraFinishCallback()
		end

		return
	end

	local dialogsetData = DialogueGraphUtils.getDialogsetData(sceneId, dialogsetId)

	if not dialogsetData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[DialogueGraphUtils] enterDialogset failed, sceneDialogsetData[%d] is nil", sceneId)
		end

		if param.applyCameraFinishCallback then
			param.applyCameraFinishCallback()
		end

		return
	end

	local cameraData = dialogsetData.cameras[cameraId]

	if cameraData == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[DialogueGraphUtils] applyDialogsetCamera failed, dialogsetData.cameras[%d] is nil", cameraId)
		end

		if param.applyCameraFinishCallback then
			param.applyCameraFinishCallback()
		end

		return
	end

	local slots = dialogsetData.slots
	local dialogsetCameraData = Utils.deepCopyTable(cameraData)

	if dialogsetCameraData.followTargetType == 1 then
		local virtualEnt = Utils.deepCopyTable(dialogsetData.virtualTargets[dialogsetCameraData.followTargetID])
		local slotInfo = slots[virtualEnt.slotId]

		virtualEnt.type = slotInfo and slotInfo.type
		virtualEnt.entityId = slotInfo and slotInfo.entityId
		dialogsetCameraData.followVirtualTarget = virtualEnt
	elseif dialogsetCameraData.followTargetType == 2 then
		dialogsetCameraData.followTargetGroup = Utils.deepCopyTable(dialogsetData.targetGroups[dialogsetCameraData.followTargetID])

		local targets = dialogsetCameraData.followTargetGroup and dialogsetCameraData.followTargetGroup.targets

		for i = 1, #targets do
			local target = targets[i]
			local virtualEnt = dialogsetData.virtualTargets[target.virtualTargetId]
			local slotInfo = slots[virtualEnt.slotId]

			target.type = slotInfo and slotInfo.type
			target.entityId = slotInfo and slotInfo.entityId
			target.bindingBoneName = virtualEnt.bindingBoneName
			target.bindingMode = virtualEnt.bindingMode
			target.partID = virtualEnt.partID
			target.partIndex = virtualEnt.partIndex
			target.subPartIndex = virtualEnt.subPartIndex
			target.position = Utils.deepCopyTable(virtualEnt.position)
			target.rotation = Utils.deepCopyTable(virtualEnt.rotation)
		end
	end

	if dialogsetCameraData.lookAtTargetType == 1 then
		local virtualEnt = Utils.deepCopyTable(dialogsetData.virtualTargets[dialogsetCameraData.lookAtTargetID])
		local slotInfo = slots[virtualEnt.slotId]

		virtualEnt.type = slotInfo and slotInfo.type
		virtualEnt.entityId = slotInfo and slotInfo.entityId
		dialogsetCameraData.lookAtVirtualTarget = virtualEnt
	elseif dialogsetCameraData.lookAtTargetType == 2 then
		dialogsetCameraData.lookAtTargetGroup = Utils.deepCopyTable(dialogsetData.targetGroups[dialogsetCameraData.lookAtTargetID])

		local targets = dialogsetCameraData.lookAtTargetGroup and dialogsetCameraData.lookAtTargetGroup.targets

		for i = 1, #targets do
			local target = targets[i]
			local virtualEnt = dialogsetData.virtualTargets[target.virtualTargetId]
			local slotInfo = slots[virtualEnt.slotId]

			target.type = slotInfo and slotInfo.type
			target.entityId = slotInfo and slotInfo.entityId
			target.bindingBoneName = virtualEnt.bindingBoneName
			target.bindingMode = virtualEnt.bindingMode
			target.partID = virtualEnt.partID
			target.partIndex = virtualEnt.partIndex
			target.subPartIndex = virtualEnt.subPartIndex
			target.position = Utils.deepCopyTable(virtualEnt.position)
			target.rotation = Utils.deepCopyTable(virtualEnt.rotation)
		end
	end

	dialogsetCameraData.openDof = param.cameraOpenDOF

	local function onCameraFinished()
		if not param.cancelled and param.applyCameraFinishCallback then
			param.applyCameraFinishCallback()
		end
	end

	dialogsetCameraData.blendData = {
		blendInTime = param.cameraBlendInTime,
		blendOutTime = param.cameraBlendOutTime,
		BlendFunc = param.cameraBlendFunction,
		finishCallback = onCameraFinished
	}
	dialogsetCameraData.movementData = param.movementData

	cmd.graphItem:ApplayDialogsetCamera(dialogsetCameraData, onCameraFinished)
end

function DialogueGraphUtils.exitDialogset(cmd, param)
	local sceneDialogsetData = SceneUtils.getSceneDialogsetData(param.sceneId)
	local dialogsetData = sceneDialogsetData[param.dialogsetId]

	if not dialogsetData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[DialogueGraphUtils] leaveDialogset failed, sceneDialogsetData[%d] is nil", param.sceneId)
		end

		return
	end
end

function DialogueGraphUtils.getDialogsetPositionByID(cmd, sceneId, dialogsetId, slotId)
	local sceneDialogsetData = SceneUtils.getSceneDialogsetData(sceneId)

	if sceneDialogsetData == nil then
		return nil
	end

	local dialogsetData = sceneDialogsetData[dialogsetId]

	if dialogsetData == nil or dialogsetData.slots == nil then
		return nil
	end

	local slotData = dialogsetData.slots[slotId]

	if slotData == nil then
		return nil
	end

	return Vector3(slotData.position[1], slotData.position[2], slotData.position[3])
end

function DialogueGraphUtils.getDialogsetPositionByIndex(cmd, sceneId, dialogsetId, slotIndex)
	local sceneDialogsetData = SceneUtils.getSceneDialogsetData(sceneId)

	if sceneDialogsetData == nil then
		return nil
	end

	local dialogsetData = sceneDialogsetData[dialogsetId]

	if dialogsetData == nil or dialogsetData.slots == nil or dialogsetData.slotIds == nil then
		return nil
	end

	local slotId = dialogsetData.slotIds[slotIndex]

	if slotId == nil then
		return nil
	end

	local slotData = dialogsetData.slots[slotId]

	if slotData == nil then
		return nil
	end

	return Vector3(slotData.position[1], slotData.position[2], slotData.position[3])
end

function DialogueGraphUtils.getDialogsetRotationByID(cmd, sceneId, dialogsetId, slotId)
	local sceneDialogsetData = SceneUtils.getSceneDialogsetData(sceneId)

	if sceneDialogsetData == nil then
		return nil
	end

	local dialogsetData = sceneDialogsetData[dialogsetId]

	if dialogsetData == nil or dialogsetData.slots == nil then
		return nil
	end

	local slotData = dialogsetData.slots[slotId]

	if slotData == nil then
		return nil
	end

	return DialogueGraphUtils.toQuaternion(slotData.rotation)
end

function DialogueGraphUtils.getDialogsetRotationByIndex(cmd, sceneId, dialogsetId, slotIndex)
	local sceneDialogsetData = SceneUtils.getSceneDialogsetData(sceneId)

	if sceneDialogsetData == nil then
		return nil
	end

	local dialogsetData = sceneDialogsetData[dialogsetId]

	if dialogsetData == nil or dialogsetData.slots == nil or dialogsetData.slotIds == nil then
		return nil
	end

	local slotId = dialogsetData.slotIds[slotIndex]

	if slotId == nil then
		return nil
	end

	local slotData = dialogsetData.slots[slotId]

	if slotData == nil then
		return nil
	end

	return DialogueGraphUtils.toQuaternion(slotData.rotation)
end

function DialogueGraphUtils.getDialogsetEntityIdByID(cmd, sceneId, dialogsetId, slotId)
	local sceneDialogsetData = SceneUtils.getSceneDialogsetData(sceneId)

	if sceneDialogsetData == nil then
		return nil
	end

	local dialogsetData = sceneDialogsetData[dialogsetId]

	if dialogsetData == nil or dialogsetData.slots == nil then
		return nil
	end

	local slotData = dialogsetData.slots[slotId]

	if slotData == nil then
		return nil
	end

	return slotData.entityId
end

function DialogueGraphUtils.getDialogsetEntityIdByIndex(cmd, sceneId, dialogsetId, slotIndex)
	local sceneDialogsetData = SceneUtils.getSceneDialogsetData(sceneId)

	if sceneDialogsetData == nil then
		return nil
	end

	local dialogsetData = sceneDialogsetData[dialogsetId]

	if dialogsetData == nil or dialogsetData.slots == nil or dialogsetData.slotIds == nil then
		return nil
	end

	local slotId = dialogsetData.slotIds[slotIndex]

	if slotId == nil then
		return nil
	end

	local slotData = dialogsetData.slots[slotId]

	if slotData == nil then
		return nil
	end

	return slotData.entityId
end

function DialogueGraphUtils.conditionCheckStatus(cmd, cond)
	return ClientUtils.checkSingleStatusCondition(cond)
end

function DialogueGraphUtils.isCompleteCondition(cmd, triggerId)
	if pg ~= nil and pg.me ~= nil and pg.me.triggerMap ~= nil and pg.me.triggerMap.isCompleteOrMeetCondition ~= nil then
		return pg.me.triggerMap:isCompleteOrMeetCondition(triggerId)
	end

	return false
end

function DialogueGraphUtils.canPlayDialogueGraph(dialogueGraphId)
	local dgc = DialogueGraphConfig[dialogueGraphId]

	if dgc == nil or pg.me == nil then
		return false
	end

	if dgc.sceneId ~= nil then
		local curSceneId = pg.me.space.sceneId

		if dgc.sceneId ~= curSceneId then
			return false
		end

		if dgc.targetPosition ~= nil then
			local targetScenePositionData = SceneUtils.getSceneTargetPositionData(dgc.sceneId)
			local targetScenePosition = targetScenePositionData and targetScenePositionData[dgc.targetPosition] or nil

			if targetScenePosition then
				local curPos = pg.me:getPosition()
				local distance = Vector3.SqrMagnitude(targetScenePosition.position - curPos)

				if distance > DialogueGraphConst.DIALOGUE_GRAPH_PLAY_APPROXIMATELY_EPS then
					return false
				end
			end
		end
	end

	return true
end

function DialogueGraphUtils.getDialogueGraphTargetPosition(dialogueGraphId)
	local dgc = DialogueGraphConfig[dialogueGraphId]

	if dgc ~= nil then
		return dgc.sceneId, dgc.targetPosition
	end

	return nil
end

function DialogueGraphUtils.setGameTime(timeScale)
	if pg.space then
		pg.space:startGameTime(timeScale, Const.GameTimeScaleType.DIALOGUE_GRAPH)
	end
end

function DialogueGraphUtils.pauseGame(timeScaleType)
	if pg.space then
		timeScaleType = timeScaleType or Const.GameTimeScaleType.DIALOGUE_GRAPH

		pg.space:pauseGameByType(timeScaleType, -1)
	end
end

function DialogueGraphUtils.resumeGame(timeScaleType)
	if pg.space then
		timeScaleType = timeScaleType or Const.GameTimeScaleType.DIALOGUE_GRAPH

		pg.space:resumeGameByType(timeScaleType)
	end
end

function DialogueGraphUtils.sendDialogueGraphReport(dialogueGraphId, dialogueGraphDuration)
	LuaUIUtils.sendCustomLog(Const.BILogName.DIALOGUE_GRAPH, {
		dialoguegraph_id = dialogueGraphId,
		dialoguegraph_duration = dialogueGraphDuration
	})
end

function DialogueGraphUtils.playSound(cmd, name, isBgm, player)
	if string.isNilOrEmpty(name) then
		return
	end

	if isBgm then
		pg.game.audio:playBgm(name, AudioConst.BgmPriority.DialogueGraph)
	else
		if player ~= nil then
			pg.game.audio:setPlayerSexSwitch(player)
		end

		pg.game.audio:playEvent(name, player)
	end

	if cmd.cacheSoundInfo == nil then
		cmd.cacheSoundInfo = {}
	end

	cmd.cacheSoundInfo[name] = {
		isBgm = isBgm
	}
end

function DialogueGraphUtils.stopSound(cmd, name)
	if string.isNilOrEmpty(name) then
		return
	end

	local isBgm = false

	if cmd.cacheSoundInfo then
		local info = cmd.cacheSoundInfo[name]

		isBgm = info and info.isBgm ~= nil and info.isBgm or false
		cmd.cacheSoundInfo[name] = nil
	end

	if isBgm then
		pg.game.audio:stopBgm(AudioConst.BgmPriority.DialogueGraph)
	else
		pg.game.audio:stopEvent(name)
	end
end

function DialogueGraphUtils.stopAllSound(cmd)
	if cmd.cacheSoundInfo then
		for name, v in pairs(cmd.cacheSoundInfo) do
			DialogueGraphUtils.stopSound(cmd, name)
		end
	end

	cmd.cacheSoundInfo = nil
end

function DialogueGraphUtils.openNpcObserve(cmd, info)
	DialogueGraphUtils.showUI(cmd, UIConst.UI_ID_NPC_EVENT_CHAIN, info)
end

function DialogueGraphUtils.clearNpcObserve()
	pg.global.ui:closePanel(UIConst.UI_ID_NPC_EVENT_CHAIN)
end

return DialogueGraphUtils
