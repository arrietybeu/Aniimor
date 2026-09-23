-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Event\\EventSystem.lua

local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("DialogueItemCmd")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local SceneData = require("Data.scene_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local SystemBase = require("GameApp.Core.SystemBase")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local PuppetData = require("Data.puppet_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local EventArkCarnData = require("Data.event_ark_carn_data")
local TimerManager = require("Core.Timer.TimerManager")
local SandboxConst = require("Common.Const.SandboxConst")
local EventTaskData = require("Data.event_task_data")
local Time = require("Core.Common.Time")
local ActivityConst = require("Common.Const.ActivityConst")
local EventSystem = Class.LightClass("EventSystem", SystemBase)

function EventSystem:onCtor()
	SystemBase.onCtor(self)

	self.worldSceneId = 3000
	self.sunWeatherId = 1
	self.todTimes = {}
	self.playingDialogues = {}
	self.arkSceneId = 501
	self.dialogueDeltaTime = 7
	self.dialogueCurTime = 0
	self.maxDialogueCount = 10
end

function EventSystem:onInit()
	SystemBase.onInit(self)
	self:onClear()
end

function EventSystem:onSceneLoaded(sceneId, sceneName)
	self:refreshStagePets(sceneId)
end

function EventSystem:onSceneUnloaded(sceneId, sceneName)
	if self.stageTimer then
		TimerManager.removeTimer(self.stageTimer)
	end
end

function EventSystem:playArkCarnDialogueGraph(dialogueId)
	if self.stageTimer and #self.playingDialogues < self.maxDialogueCount then
		table.insert(self.playingDialogues, dialogueId)
		pg.game.dialogue:playDialogueGraph(dialogueId)
	end
end

function EventSystem:refreshStagePets(sceneId)
	if sceneId == self.arkSceneId then
		if self.stageTimer then
			TimerManager.removeTimer(self.stageTimer)
		end

		self.stageTimer = TimerManager.addRepeatTimer(1, function()
			self:refreshStagePetsInner()

			self.dialogueCurTime = self.dialogueCurTime + 1

			if self.dialogueCurTime % self.dialogueDeltaTime == 0 then
				if #self.playingDialogues > 0 then
					table.remove(self.playingDialogues, 1)
				end

				self.dialogueCurTime = 0
			end
		end)
	else
		self.hasInitStage = false
	end
end

function EventSystem:refreshStagePetsInner()
	local phaseId = pg.me.arkcarnCurPhaseId

	if phaseId and phaseId > 0 then
		local eventArkCarnData1 = EventArkCarnData[phaseId][1]
		local eventArkCarnData3 = EventArkCarnData[phaseId][3]
		local entity

		if pg.me.space then
			entity = pg.me.space:getEntityByStaticId(eventArkCarnData3.carnivalStageId)
		end

		if entity then
			if self.hasInitStage then
				return
			end

			local modelRoot = entity.eModel.modelRoot
			local stageController = modelRoot:GetComponentInChildren(typeof(CS.FunPlus.WorldX.GameApp.Sandbox.Components.ArkCarnStageController))

			if stageController then
				local templateIds = self:getVotedPetTemplateIds()

				if not self:hasPullVoteData() then
					self:pullVoteData()

					return
				end

				local prefabIds = {}
				local accompanyIndex = 0

				for _, id in ipairs(templateIds) do
					local prefabId = PetPrototypeData[id].prefabResID

					table.insert(prefabIds, prefabId)

					if accompanyIndex == 0 then
						for index, configId in pairs(eventArkCarnData1.votePetListAccompany) do
							local targetId = self:getPetPrototypeId(configId)

							if targetId == id then
								accompanyIndex = index

								break
							end
						end
					end
				end

				if accompanyIndex > 0 then
					local id2 = eventArkCarnData1.petListAccompany2[accompanyIndex]
					local templateId2 = self:getPetPrototypeId(id2)

					table.insert(templateIds, templateId2)
					table.insert(prefabIds, PetPrototypeData[templateId2].prefabResID)

					local id3 = eventArkCarnData1.petListAccompany3[accompanyIndex]
					local templateId3 = self:getPetPrototypeId(id3)

					table.insert(templateIds, templateId3)
					table.insert(prefabIds, PetPrototypeData[templateId3].prefabResID)
				end

				local fixedStagePetList = eventArkCarnData1.petFixAtmosId

				if fixedStagePetList then
					for _, configId in ipairs(fixedStagePetList) do
						local fixedPrototypeData = PetPrototypeData[configId]

						if fixedPrototypeData then
							table.insert(templateIds, configId)
							table.insert(prefabIds, fixedPrototypeData.prefabResID)
						else
							logger:error("[ArkCarn] fixedStagePetList 宠物原型缺失,已跳过 configId=%s", tostring(configId))
						end
					end
				end

				local startTime = (Time.secondCache - Utils.getConfigTimeOfAreaByData(eventArkCarnData3.startTime)) % eventArkCarnData3.carnivalTimelineTime[1]

				if startTime < 0 then
					startTime = 0
				end

				stageController:SetPets(templateIds, prefabIds, startTime)

				self.hasInitStage = true
			end
		elseif self.hasInitStage then
			self.hasInitStage = false
		end
	end
end

function EventSystem:pullVoteData()
	if pg.me.arkcarnCurPhaseId and pg.me.arkcarnCurPhaseId > 0 then
		local eventArkCarnData = EventArkCarnData[pg.me.arkcarnCurPhaseId][1]

		if eventArkCarnData then
			pg.me:pullActivityVotePetData(eventArkCarnData.voteDrummerKey, ActivityConst.EventType.ArkCarn)
			pg.me:pullActivityVotePetData(eventArkCarnData.voteDancerKey, ActivityConst.EventType.ArkCarn)
			pg.me:pullActivityVotePetData(eventArkCarnData.voteAccompanyKey, ActivityConst.EventType.ArkCarn)
			pg.me:pullActivityVotePetData(eventArkCarnData.voteAtmosKey, ActivityConst.EventType.ArkCarn)
		end
	end
end

function EventSystem:hasPullVoteData()
	local phaseId = pg.me.arkcarnCurPhaseId

	if phaseId and phaseId > 0 then
		local eventArkCarnData = EventArkCarnData[phaseId][1]
		local id1, num1 = self:getArkPartyVoteInfo(eventArkCarnData.voteDrummerKey)
		local id2, num2 = self:getArkPartyVoteInfo(eventArkCarnData.voteDancerKey)
		local id3, num3 = self:getArkPartyVoteInfo(eventArkCarnData.voteAccompanyKey)
		local id4, num4 = self:getArkPartyVoteInfo(eventArkCarnData.voteAtmosKey)

		if not id1 then
			return false
		end

		if not id2 then
			return false
		end

		if not id3 then
			return false
		end

		if not id4 then
			return false
		end

		return true
	end

	return false
end

function EventSystem:setArkPartyVoteInfo(voteInfo)
	if not voteInfo then
		return
	end

	self.arkPartyVoteInfo = self.arkPartyVoteInfo or {}

	local activityId = voteInfo.activityId and tonumber(voteInfo.activityId)

	if not activityId then
		return
	end

	self.arkPartyVoteInfo[activityId] = {}

	local votePets = {}

	for id, num in pairs(voteInfo.votePets) do
		votePets[tonumber(id)] = num
	end

	self.arkPartyVoteInfo[activityId].votePets = votePets

	local sumNum = 0

	for _, num in pairs(votePets) do
		sumNum = sumNum + num
	end

	self.arkPartyVoteInfo[activityId].sumNum = sumNum

	local infoCount = 0

	for _, voteInfo in pairs(self.arkPartyVoteInfo) do
		infoCount = infoCount + 1
	end
end

function EventSystem:getArkPartyVoteSumNum(voteKey)
	local key = tonumber(voteKey)

	if not self.arkPartyVoteInfo then
		return nil
	end

	local voteInfo = self.arkPartyVoteInfo[key]

	if not voteInfo then
		return nil
	end

	return voteInfo.sumNum
end

function EventSystem:getArkPartyVoteNum(voteKey, petId)
	local key = tonumber(voteKey)

	if not self.arkPartyVoteInfo then
		return nil
	end

	local voteInfo = self.arkPartyVoteInfo[key]

	if not voteInfo then
		return nil
	end

	if not voteInfo.votePets then
		return nil
	end

	return voteInfo.votePets[petId]
end

function EventSystem:getArkPartyVoteInfo(voteKey)
	local key = tonumber(voteKey)

	if not self.arkPartyVoteInfo then
		return nil
	end

	local voteInfo = self.arkPartyVoteInfo[key]

	if not voteInfo then
		return nil
	end

	local keys = {}

	for key in pairs(voteInfo.votePets) do
		table.insert(keys, key)
	end

	table.sort(keys)

	local petId = 0
	local voteNum = 0

	for i = 1, #keys do
		local id = keys[i]
		local num = voteInfo.votePets[id]

		if petId == 0 then
			petId = id
			voteNum = num
		end

		if voteNum < num then
			petId = id
			voteNum = num
		end
	end

	return petId, voteNum
end

function EventSystem:getVotedPetTemplateIds()
	local templateIds = {}
	local petIds = self:getVotedPetIds()

	for _, id in ipairs(petIds) do
		table.insert(templateIds, self:getPetPrototypeId(id))
	end

	return templateIds
end

function EventSystem:getVotedPetIds()
	local petIds = {}
	local phaseId = pg.me.arkcarnCurPhaseId

	if phaseId and phaseId > 0 then
		local eventArkCarnData = EventArkCarnData[phaseId][1]
		local id1, num1 = self:getArkPartyVoteInfo(eventArkCarnData.voteDrummerKey)
		local id2, num2 = self:getArkPartyVoteInfo(eventArkCarnData.voteDancerKey)
		local id3, num3 = self:getArkPartyVoteInfo(eventArkCarnData.voteAccompanyKey)
		local id4, num4 = self:getArkPartyVoteInfo(eventArkCarnData.voteAtmosKey)

		if not id1 then
			id1 = eventArkCarnData.votePetListeDrummer[1]
			num1 = 0
		end

		if not id2 then
			id2 = eventArkCarnData.votePetListDancer[1]
			num2 = 0
		end

		if not id3 then
			id3 = eventArkCarnData.votePetListAccompany[1]
			num3 = 0
		end

		if not id4 then
			id4 = eventArkCarnData.votePetListAtmos[1]
			num4 = 0
		end

		if id1 and id2 and id3 and id4 then
			local id5 = eventArkCarnData.petMainDancerId

			table.insert(petIds, id1)
			table.insert(petIds, id2)
			table.insert(petIds, id3)
			table.insert(petIds, id4)
			table.insert(petIds, id5)
		end
	end

	return petIds
end

function EventSystem:takePetPhoto(pets, isSelfie, photoPath)
	local phaseId = pg.me.arkcarnCurPhaseId

	if phaseId and phaseId > 0 then
		local targetPets = self:getVotedPetTemplateIds()

		for _, petId in pairs(pets) do
			if table.contains(targetPets, petId) then
				pg.me:serverMsg("RPC_CS_ActArkCarnTakePhotePet", {
					petId
				})

				if not string.isNilOrEmpty(photoPath) then
					local keyId = pg.me.id .. "_ARKCARN_PHOTO_PATH_" .. petId

					pg.global.prefsCacheUtils:setString(keyId, photoPath)
				end
			end
		end

		local stageId = 3

		if isSelfie and pg.me.arkCarnStageState and pg.me.arkCarnStageState[stageId] and pg.me.arkCarnStageState[stageId] == 1 and pg.me.space.sceneId == 501 then
			local photoTask = self:getPhotoTask(pg.me.arkcarnCurActId, stageId * 1000)

			if photoTask then
				local curPos = pg.me:getPosition()
				local targetPos = Vector3(photoTask.carnivalScopeId[1], photoTask.carnivalScopeId[2], photoTask.carnivalScopeId[3])

				if Vector3.Distance(curPos, targetPos) < photoTask.carnivalScopeId[4] then
					pg.me:serverMsg("RPC_CS_ActArkCarnTakePhotoStagePet")
				end
			end
		end
	end
end

function EventSystem:getPetPhoto(petId)
	local keyId = pg.me.id .. "_ARKCARN_PHOTO_PATH_" .. petId
	local path = pg.global.prefsCacheUtils:getString(keyId)

	return pg.global.mobileCameraMgr:GetSpriteByFilePath(path)
end

function EventSystem:getPhotoTask(activityId, groupId)
	for id, taskInfo in pairs(EventTaskData) do
		if taskInfo.activityId == activityId and taskInfo.groupId == groupId and taskInfo.taskCondition == 9048 then
			return taskInfo
		end
	end

	return nil
end

function EventSystem:getPetPrototypeId(id)
	local puppetData = PuppetData[id]

	if puppetData then
		return puppetData.petPrototypeId
	end

	return id
end

function EventSystem:onClear()
	return
end

return EventSystem
