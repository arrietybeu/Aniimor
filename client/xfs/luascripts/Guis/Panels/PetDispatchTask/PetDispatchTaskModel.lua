-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDispatchTask\\PetDispatchTaskModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetDispatchUtils = require("GameApp.PetDispatch.PetDispatchUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")
local lume = require("Core.Common.lume")
local PetDispatchTaskModel = Class.LightClass("PetDispatchTaskModel", UIModel)

function PetDispatchTaskModel:ctor()
	self.eventId = nil
	self.clueId = nil
	self.taskState = nil
	self.endTime = nil
	self.selectMode = "leader"
	self.pickingMode = nil
	self.selectedLeaderId = nil
	self.selectedFollowerIds = {}
	self.conditions = {}
	self.rewardTiers = {
		B = {},
		A = {},
		S = {}
	}
	self.rating = "B"
	self.currentRewards = {}
	self.timeReduceRatio = 0
	self.countdownSeconds = 0
	self.followerSlots = {}
end

function PetDispatchTaskModel:refresh()
	local clueConfig = PetDispatchUtils.getClueConfig(self.clueId) or {}
	local taskInfo = ClientActivityUtils.getTaskInfoByTaskId(ActivityConst.EventType.PetDispatch, self.clueId)

	self.taskState = taskInfo and taskInfo.taskState or ActivityConst.TaskState.UnFinished
	self.conditions = PetDispatchUtils.getExtraConditions(self.clueId)
	self.eventTitle = clueConfig.eventTitle
	self.taskDes = clueConfig.taskDes
	self.awardDes = clueConfig.awardDes

	local extraAward = clueConfig.extraAward or {}

	self.rewardTiers = {
		B = extraAward[0] and LuaUIUtils.getRewardItemByDropId(extraAward[0]) or {},
		A = extraAward[1] and LuaUIUtils.getRewardItemByDropId(extraAward[1]) or {},
		S = extraAward[2] and LuaUIUtils.getRewardItemByDropId(extraAward[2]) or {}
	}

	local dispatchInfo = taskInfo and taskInfo.sparam and lume.deserialize(taskInfo.sparam) or nil

	if dispatchInfo and dispatchInfo.dispatchPetList then
		self:updateTeam(dispatchInfo.dispatchPetList)
	end

	local team = self:getTeamPets()

	for _, condition in ipairs(self.conditions) do
		condition.completed = PetDispatchUtils.isTeamMatchCondition(team, condition)
	end

	self.rating = PetDispatchUtils.calcRating(team, self.conditions)
	self.currentRewards = self.rewardTiers[self.rating] or {}
	self.timeReduceRatio = PetDispatchUtils.getDispatchTimeReduceRatio(team)

	local baseSeconds = (SysConfigData.DISPATCH_TIME or 0) * 3600
	local dispatchSeconds = PetDispatchUtils.calcDispatchSeconds(baseSeconds, team)
	local beginTime = dispatchInfo and dispatchInfo.dispatchBegTm or nil

	self.endTime = beginTime and beginTime > 0 and beginTime + dispatchSeconds or nil
	self.countdownSeconds = self.endTime and math.max(0, self.endTime - Time.secondCache) or dispatchSeconds
	self.followerSlots = {}

	for i = 1, 3 do
		self.followerSlots[i] = {
			slotIndex = i,
			petId = self.selectedFollowerIds[i],
			pet = self:getPetDisplayData(self.selectedFollowerIds[i])
		}
	end
end

function PetDispatchTaskModel:updateTeam(petIds)
	self.selectedLeaderId = petIds[1]
	self.selectedFollowerIds = {}

	for i = 2, 4 do
		self.selectedFollowerIds[i - 1] = petIds[i]
	end
end

function PetDispatchTaskModel:getTeamPets()
	local pets = {}

	if self.selectedLeaderId then
		pets[#pets + 1] = pg.me:getPetInfo(self.selectedLeaderId)
	end

	for _, petId in pairs(self.selectedFollowerIds) do
		if petId then
			pets[#pets + 1] = pg.me:getPetInfo(petId)
		end
	end

	return pets
end

function PetDispatchTaskModel:getPetDisplayData(petId)
	local pet = petId and pg.me:getPetInfo(petId)

	return pet and LuaUIUtils.getDispatchPetInfo(pet) or nil
end

return PetDispatchTaskModel
