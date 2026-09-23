-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\DialogueUtils.lua

local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local DialogueConst = require("Const.DialogueConst")
local UIConst = require("Const.UIConst")
local lume = require("Core.Common.lume")
local PuppetData = require("Data.puppet_data")
local CameraConst = require("GameApp.Camera.CameraConst")
local PlayableConst = require("Common.Const.PlayableConst")
local PetFamilyData = require("Data.pet_family_data")
local SysConfigData = require("Data.sys_config_data")
local NpcDialogueData = require("Data.npc_dialogue_data")
local NpcSpecialStateData = require("Data.npc_special_state_data")
local DialogueDurationData = require("Data.dialogue_duration_data")
local Lume = require("Core.Common.lume")
local AttributeConst = require("Common.Const.AttributeConst")
local AttributeUtils = require("Common.Ability.Attribute.AttributeUtils")
local Vector3 = Vector3
local Quaternion = Quaternion
local ToBool = ToBool
local DialogueUtils = {}

DialogueUtils.cacheNpcIds = {}
DialogueUtils.cacheArgsTable = {}
DialogueUtils.cahceArgsNum = 0

function DialogueUtils.getDialogueEntity(npcTemplateId, npcStaticId, priorityList)
	local speakerType, speakerEntity

	if npcStaticId == 2 then
		return pg.me:isControllingPet() and pg.me:getCurPetEntity() or pg.me, DialogueConst.SpeakerType.Player
	end

	if npcStaticId and npcStaticId ~= DialogueConst.SpeakerType.Illegal then
		if npcStaticId == DialogueConst.SpeakerType.Player then
			speakerType = DialogueConst.SpeakerType.Player
			speakerEntity = pg.me:isControllingPet() and pg.me:getCurPetEntity() or pg.me
		elseif npcStaticId == DialogueConst.SpeakerType.Pet then
			speakerType = DialogueConst.SpeakerType.Pet
			speakerEntity = pg.me:getCurPetEntity() or pg.me
		elseif npcStaticId == DialogueConst.SpeakerType.PlayerTwinPet then
			speakerType = DialogueConst.SpeakerType.PlayerTwinPet

			local templateId = Utils.getTwinPuppetTemplateId(pg.me.twinPetChoiceIndex)

			speakerEntity = DialogueUtils.getNpcEntityByTemplateId(templateId, priorityList)
		elseif npcStaticId == DialogueConst.SpeakerType.OpponentTwinPet then
			speakerType = DialogueConst.SpeakerType.OpponentTwinPet

			local templateId = Utils.getTwinPuppetTemplateId(Const.TWIN_PET_CHOICE_MAP[pg.me.twinPetChoiceIndex])

			speakerEntity = DialogueUtils.getNpcEntityByTemplateId(templateId, priorityList)
		else
			speakerType = DialogueConst.SpeakerType.Puppet
			speakerEntity = pg.me.space:getEntityByStaticId(npcStaticId)
		end
	else
		speakerType = npcTemplateId
		speakerEntity = DialogueUtils.getDialogueEntityByTemplateId(npcTemplateId, priorityList)
	end

	return speakerEntity, speakerType
end

function DialogueUtils.getDialogueEntityByTemplateId(npcTemplateId, priorityList)
	if not npcTemplateId then
		return nil
	end

	local targetEntity

	if npcTemplateId == DialogueConst.SpeakerType.Player then
		targetEntity = pg.me:isControllingPet() and pg.me:getCurPetEntity() or pg.me
	elseif npcTemplateId == DialogueConst.SpeakerType.Pet then
		targetEntity = pg.me:getCurPetEntity() or pg.me
	elseif npcTemplateId == DialogueConst.SpeakerType.PlayerTwinPet then
		local templateId = Utils.getTwinPuppetTemplateId(pg.me.twinPetChoiceIndex)

		targetEntity = DialogueUtils.getNpcEntityByTemplateId(templateId, priorityList)
	elseif npcTemplateId == DialogueConst.SpeakerType.OpponentTwinPet then
		local templateId = Utils.getTwinPuppetTemplateId(Const.TWIN_PET_CHOICE_MAP[pg.me.twinPetChoiceIndex])

		targetEntity = DialogueUtils.getNpcEntityByTemplateId(templateId, priorityList)
	else
		targetEntity = DialogueUtils.getNpcEntityByTemplateId(npcTemplateId, priorityList)
	end

	return targetEntity
end

function DialogueUtils.getNpcEntityByTemplateId(templateId, priorityList)
	local npcEntity

	if priorityList then
		for _, entityId in ipairs(priorityList) do
			local entity = pg.getEntity(entityId)

			if entity and entity.templateId == templateId then
				npcEntity = entity

				break
			end
		end
	end

	if not npcEntity then
		local closestDistance = 10
		local curPawnPos = pg.pawn:getPosition()

		table.clearArray(DialogueUtils.cacheNpcIds)

		local ents = pg.getEntitiesByTemplateId(templateId)

		for id, ent in pairs(ents) do
			if ent and ent.visible then
				local dis = Vector3.Distance(ent:getPosition(), curPawnPos)

				if dis < closestDistance then
					closestDistance = dis
					npcEntity = ent
				end
			end
		end
	end

	return npcEntity
end

function DialogueUtils.calculateClosestInitialRotation(playerPos, npcPos)
	Vector3.enableCreateFromCache()

	local player2NpcDir = npcPos - playerPos

	player2NpcDir.y = 0

	player2NpcDir:SetNormalize()

	local cameraPosX, cameraPosY, cameraPosZ = pg.global.cameraMgr:GetWorldCameraPositionEx()
	local cameraPos = Vector3(cameraPosX, cameraPosY, cameraPosZ)
	local player2CameraDir = cameraPos - playerPos

	player2CameraDir.y = 0

	player2CameraDir:SetNormalize()

	local isRight = Vector3.Cross(player2NpcDir, player2CameraDir).y < 0
	local angle = Vector3.Angle(player2NpcDir, player2CameraDir)
	local resultDir
	local xRotBiasSign = player2NpcDir.z > 0 and 1 or -1

	if isRight then
		if angle <= 90 then
			resultDir = Quaternion.Euler(xRotBiasSign * -20, -20, 0):MulVec3(-player2NpcDir)
		else
			resultDir = Quaternion.Euler(xRotBiasSign * 20, 20, 0):MulVec3(player2NpcDir)
		end
	elseif angle <= 90 then
		resultDir = Quaternion.Euler(xRotBiasSign * -20, 20, 0):MulVec3(-player2NpcDir)
	else
		resultDir = Quaternion.Euler(xRotBiasSign * 20, -20, 0):MulVec3(player2NpcDir)
	end

	Vector3.disableCreateFromCache()

	if Vector3.SqrMagnitude(resultDir) < 0.001 then
		return pg.pawn:getRotation()
	end

	return Quaternion.LookRotation(resultDir, Vector3.up)
end

function DialogueUtils.getPetBodySizeTypeCamAnimStr(ent)
	local bodySizeType = ClientUtils.getPetBodySizeType(ent)

	if bodySizeType == ClientConst.PetBodySizeType.SMALL then
		return "Short"
	elseif bodySizeType == ClientConst.PetBodySizeType.MEDIUM then
		return "Mid"
	else
		return "Tall"
	end
end

function DialogueUtils.enterGroupCameraMode(modeType, entityIds)
	if modeType ~= DialogueConst.CAMERA_MODE.FREEDOM then
		return
	end

	local playerPos = pg.pawn:getPosition()
	local cameraLookAtPos = playerPos

	for _, npcId in ipairs(entityIds) do
		local npcEntity = pg.getEntity(npcId)

		if npcEntity then
			cameraLookAtPos = cameraLookAtPos + npcEntity:getPosition()
		end
	end

	cameraLookAtPos = cameraLookAtPos / (#entityIds + 1)
	cameraLookAtPos.y = cameraLookAtPos.y + pg.pawn:getHeight()

	local initRot = DialogueUtils.calculateClosestInitialRotation(playerPos, cameraLookAtPos)

	pg.game.camera.npcDialogueCameraMode:enableFreedomCamera(true, initRot, cameraLookAtPos, 3, 5, 4, 45)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Dialogue_HumanVSHuman, true)

	local targetDir = cameraLookAtPos - playerPos

	targetDir.y = 0

	if Vector3.SqrMagnitude(targetDir) < 0.1 then
		return
	end

	local targetRotation = Quaternion.LookRotation(targetDir, Vector3.up)

	pg.pawn:turnToRotation(targetRotation)
end

function DialogueUtils.playDialogueAnimation(entity, animKey, forceLayer)
	if not entity or not animKey then
		return
	end

	local isSleAni = type(animKey) == "table"

	if not isSleAni then
		if not forceLayer then
			local configLayer = entity:getPlayableStateConfigLayer(animKey)

			if configLayer < PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY then
				forceLayer = PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY
			end
		end

		entity:playAnimation(animKey, true, nil, nil, forceLayer)
	else
		entity:playCfgAnimation(animKey, forceLayer)
	end

	return isSleAni
end

function DialogueUtils.showDialogueUI(uiId, showFuncName, isDialogueGraph, callback, cmd, ...)
	local moduleName = UIConst.UI_CONFIGS[uiId].module
	local uiAdapter = pg.global.ui
	local uiModule = uiAdapter[moduleName]

	if not uiModule then
		return
	end

	Lume.clear(DialogueUtils.cacheArgsTable)
	DialogueUtils.processVarArgs(callback, ...)

	if uiModule:checkUIClosing() then
		uiModule:open(nil, function()
			local ret, errors = ClientUtils.tryWithLogError(function()
				DialogueUtils.innerShowUI(uiModule, showFuncName, isDialogueGraph, cmd)
			end)

			if not ret and callback then
				callback()
			end
		end)
	elseif not uiModule:checkUIAssetReady() then
		-- block empty
	else
		local ret, errors = ClientUtils.tryWithLogError(function()
			DialogueUtils.innerShowUI(uiModule, showFuncName, isDialogueGraph, cmd)
		end)

		if not ret and callback then
			callback()
		end
	end
end

function DialogueUtils.innerShowUI(uiModule, showFuncName, isDialogueGraph, cmd)
	uiModule.isDialogueGraph = isDialogueGraph

	local showFunc = uiModule[showFuncName]

	if showFunc then
		if uiModule.onPreShow then
			uiModule:onPreShow(cmd)
		end

		showFunc(uiModule, unpack(DialogueUtils.cacheArgsTable, 1, DialogueUtils.cahceArgsNum))
		uiModule:show()
	end
end

function DialogueUtils.processVarArgs(callback, ...)
	local numArgs = select("#", ...)

	for i = 1, numArgs do
		local arg = select(i, ...)

		DialogueUtils.cacheArgsTable[i] = arg
	end

	DialogueUtils.cacheArgsTable[numArgs + 1] = callback
	DialogueUtils.cahceArgsNum = numArgs + 1
end

function DialogueUtils.sendDialogueInfoReport(dialogueId, timesSpeed, index, action, duration)
	LuaUIUtils.sendCustomLog(Const.BILogName.DIALOGUE, {
		dialog_id = dialogueId,
		times_speed = timesSpeed,
		list_id = index,
		action = action,
		duration = duration
	})
end

function DialogueUtils.sendDialogueOptionInfoReport(dialogueId, branchIndex, duration)
	LuaUIUtils.sendCustomLog(Const.BILogName.OPTION, {
		dialog_id = dialogueId,
		choice_id = branchIndex,
		duration = duration
	})
end

function DialogueUtils.getDialogueDuration(chatType, dialogueId, curIndex)
	if dialogueId == nil or dialogueId == 0 then
		return 0
	end

	local curDialogue = NpcDialogueData[dialogueId]

	if curDialogue == nil then
		return 0
	end

	local duration

	chatType = chatType or curDialogue[curIndex or 1].chatType

	if DialogueConst.ChatType.BLACK_SCREEN == chatType or DialogueConst.ChatType.WHITE_SCREEN == chatType then
		duration = 4

		return duration
	end

	local dialogueDurationInfo = DialogueDurationData[dialogueId]

	if dialogueDurationInfo == nil then
		return duration or 2
	end

	curIndex = curIndex or 1

	local language = pg.languageType or 0

	if dialogueDurationInfo[curIndex] then
		duration = dialogueDurationInfo[curIndex][language + 1]
	end

	return duration or 2
end

function DialogueUtils.getAudioName(dialogueId, index)
	if dialogueId == nil or dialogueId == 0 then
		return nil
	end

	local curDialogueData = NpcDialogueData[dialogueId]

	if curDialogueData == nil then
		return nil
	end

	return curDialogueData[index or 1].audioName
end

function DialogueUtils.getAudioDuration(dialogueId, index, customAudioName)
	local audioName = customAudioName

	if audioName == nil then
		if dialogueId == nil or dialogueId == 0 then
			return -1
		end

		audioName = DialogueUtils.getAudioName(dialogueId, index)
	end

	if audioName then
		local audioDuration = pg.game.audio.mgrInst.soundFactory:GetDuration(audioName)

		if audioDuration < 0.01 then
			audioDuration = DialogueUtils.getDialogueDuration(nil, dialogueId, index) or 2
		end

		return math.max(audioDuration, 2)
	end

	return -1
end

function DialogueUtils.isPetsSameEthnic(petEnt1, petEnt2)
	local cfg1 = petEnt1 and petEnt1.getConfigData and petEnt1:getConfigData()
	local cfg2 = petEnt2 and petEnt2.getConfigData and petEnt2:getConfigData()
	local e1 = cfg1 and cfg1.ethnicGroup
	local e2 = cfg2 and cfg2.ethnicGroup

	if e1 ~= nil and e2 ~= nil and e1 == e2 then
		return true
	end

	if pg.me and pg.me.attrEntrysMap and e2 ~= nil then
		local closePetSet = AttributeUtils.getAttrComplexValue(pg.me, AttributeConst.close_pet)

		if closePetSet and closePetSet[e2] == true then
			return true
		end
	end

	local family1 = PetFamilyData[e1]
	local family2 = PetFamilyData[e2]

	if family1 and family2 then
		local can1 = family1.canCommunicateEthnicGroup
		local can2 = family2.canCommunicateEthnicGroup

		if can1 and can1[e2] or can2 and can2[e1] then
			return true
		end
	end

	return false
end

function DialogueUtils.checkPetsSameEthnicDialogue(petEnt1, petEnt2)
	local type = 2
	local specialEthnicId, newDialogueId
	local ethnicGroup_1 = petEnt1 ~= nil and petEnt1:getConfigData() ~= nil and petEnt1:getConfigData().ethnicGroup or nil
	local ethnicGroup_2 = petEnt2 ~= nil and petEnt2:getConfigData() ~= nil and petEnt2:getConfigData().ethnicGroup or nil

	if ethnicGroup_1 ~= nil and ethnicGroup_2 ~= nil and ethnicGroup_1 == ethnicGroup_2 then
		return newDialogueId == nil, type, newDialogueId
	end

	local templateId_2 = petEnt2 and petEnt2.templateId or 0
	local npcData = PuppetData[templateId_2]

	if npcData == nil then
		return newDialogueId == nil, type, newDialogueId
	end

	local familyData_1 = PetFamilyData[ethnicGroup_1]
	local familyData_2 = PetFamilyData[ethnicGroup_2]

	if familyData_1 and familyData_2 then
		local specialDialogue_2 = familyData_2.specialDialogue or npcData.specialDialogue

		if specialDialogue_2 then
			specialEthnicId = specialDialogue_2[2]

			if specialEthnicId == ethnicGroup_1 then
				type = specialDialogue_2[1]
				newDialogueId = specialDialogue_2[3]

				return newDialogueId == nil, type, newDialogueId, specialEthnicId
			end
		end

		local canCommunicateEthnicGroup_1 = familyData_1.canCommunicateEthnicGroup
		local canCommunicateEthnicGroup_2 = familyData_2.canCommunicateEthnicGroup

		if canCommunicateEthnicGroup_1 and canCommunicateEthnicGroup_1[ethnicGroup_2] or canCommunicateEthnicGroup_2 and canCommunicateEthnicGroup_2[ethnicGroup_1] then
			return newDialogueId == nil, type, newDialogueId
		end
	end

	local spData = DialogueUtils.getNPCSpecialState(petEnt2.staticId)

	if spData then
		local specialDialogue = spData.specialDialogue or spData.specialDialogue

		if specialDialogue then
			specialEthnicId = specialDialogue[2]

			if specialEthnicId == ethnicGroup_1 then
				type = specialDialogue[1]
				newDialogueId = specialDialogue[3]

				return newDialogueId == nil, type, newDialogueId, specialEthnicId
			end
		end

		if spData.unknowDialogue and spData.unknowDialogue > 0 then
			newDialogueId = spData.unknowDialogue

			return newDialogueId == nil, type, newDialogueId
		end
	end

	if npcData.specialDialogue then
		specialEthnicId = npcData.specialDialogue[2]

		if specialEthnicId == ethnicGroup_1 then
			type = npcData.specialDialogue[1]
			newDialogueId = npcData.specialDialogue[3]

			return newDialogueId == nil, type, newDialogueId, specialEthnicId
		end
	end

	newDialogueId = npcData and npcData.unknowDialogue or nil

	return newDialogueId == nil, type, newDialogueId, specialEthnicId
end

function DialogueUtils.getSpecialStateDialogue(staticId)
	local spData = DialogueUtils.getNPCSpecialState(staticId)

	if spData and spData.unknowDialogue and spData.unknowDialogue > 0 then
		return spData.unknowDialogue
	end
end

function DialogueUtils.getNPCSpecialState(staticId)
	local player = pg.me

	if player.specialContentDict then
		local spId = player.specialContentDict[staticId]

		if spId then
			return NpcSpecialStateData[spId]
		end
	end
end

function DialogueUtils.getDialogueChat(dialogueId, index)
	local index = index or 1

	if NpcDialogueData[dialogueId] and NpcDialogueData[dialogueId][index] then
		return NpcDialogueData[dialogueId][index].chat
	end
end

function DialogueUtils.isMultiDialogue(dialogueId)
	if not dialogueId or not NpcDialogueData[dialogueId] then
		return false
	end

	return table.maxn(NpcDialogueData[dialogueId]) > 1
end

function DialogueUtils.getDialoguePriority()
	local chatTypePriority = {}
	local chatLevelData = SysConfigData.CHAT_LEVEL

	for order, types in ipairs(chatLevelData) do
		for _, type in ipairs(types) do
			chatTypePriority[type] = order
		end
	end

	return chatTypePriority
end

return DialogueUtils
