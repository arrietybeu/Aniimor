-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Effect\\TeamLinkController.lua

local Class = require("Core.Framework.Class")
local Lume = require("Core.Common.lume")
local EffectConst = require("Const.EffectConst")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local RigidbodyData = require("Data.rigidbody_data")
local TeamLinkCustomEffect = CS.FunPlus.WorldX.Effect.TeamLinkCustomEffect
local TeamLinkController = Class.LiteClass("TeamLinkController")
local pg = pg
local ToBool = ToBool
local Vector3 = Vector3
local Utils = require("Common.Utils.Utils")

function TeamLinkController:ctor()
	self.followInfo = {}
	self.follow2LeaderMap = {}
	self.checkTimer = nil
end

local EFF_PLAYER_LINK_LEADER = "Eff_Player_Link_Leader"
local EFF_PLAYER_LINK_FOLLOW = "Eff_Player_Link_Follow"
local PET_SPHERE_EFF_ID = "Eff_Pet_Link_Sphere"
local PET_SPHERE_EFF_LEADER_ID = "Eff_Pet_Link_Leader"
local LINK_EFF_ID = "Eff_UI_PetExchange_Line"

function TeamLinkController:onSkeletonLoaded(ent)
	local uid = ent.uid

	if not uid then
		return
	end

	if self.followInfo[uid] then
		for followUid, _ in pairs(self.followInfo[uid]) do
			self:addFollowEff(uid, followUid)
		end
	end

	if self.follow2LeaderMap[uid] then
		self:addFollowEff(self.follow2LeaderMap[uid], uid)
	end
end

local function getControlEnt(ent)
	return ent and ent.isControllingPet and ent:isControllingPet() and ent:getCurPetEntity() or ent
end

function TeamLinkController:removeLearEff(uid)
	local ent = pg.getEntityByUid(uid)

	if not ent then
		return
	end

	local controlEnt = getControlEnt(ent)

	if ent.teamHandEffectId then
		ent:stopEffectById(ent.teamHandEffectId)

		ent.teamHandEffectId = nil
	end

	if controlEnt ~= ent and controlEnt and controlEnt.teamHandEffectId then
		controlEnt:stopEffectById(controlEnt.teamHandEffectId)

		controlEnt.teamHandEffectId = nil
	end
end

function TeamLinkController:removeFollowEff(uid)
	local ent = pg.getEntityByUid(uid)

	if ent then
		local controlEnt = getControlEnt(ent)

		self:clearEff(ent)

		if controlEnt ~= ent then
			self:clearEff(controlEnt)
		end
	end
end

function TeamLinkController:setEntityLinkEffectVisible(ent, visible)
	if not ent or not ent.eModel then
		return
	end

	if ent.teamHandEffectId then
		ent.eModel:SetEffectVisibleById(Const.COMPONENT_INDEX_EFFECT, ent.teamHandEffectId, visible)
	end

	if ent.teamFollowEffectId then
		ent.eModel:SetEffectVisibleById(Const.COMPONENT_INDEX_EFFECT, ent.teamFollowEffectId, visible)
	end
end

function TeamLinkController:setFollowLinkEffectVisible(ent, visible)
	self:setEntityLinkEffectVisible(ent, visible)

	local controlEnt = getControlEnt(ent)

	if controlEnt ~= ent then
		self:setEntityLinkEffectVisible(controlEnt, visible)
	end
end

function TeamLinkController:refreshOutOfRangeEffectVisible(uid)
	local leaderUid = self.followInfo[uid] and uid or self.follow2LeaderMap[uid]

	if not leaderUid or not self.followInfo[leaderUid] then
		return
	end

	local hasVisibleFollower = false

	for followUid, _ in pairs(self.followInfo[leaderUid]) do
		local followEnt = pg.getEntityByUid(followUid)
		local visible = followEnt ~= nil and followEnt.followState ~= Const.SpaceFollowMemberState.OutOfRange

		self:setFollowLinkEffectVisible(followEnt, visible)

		hasVisibleFollower = hasVisibleFollower or visible
	end

	self:setFollowLinkEffectVisible(pg.getEntityByUid(leaderUid), hasVisibleFollower)
end

function TeamLinkController:addLeaderEff(leaderUid)
	local leaderEntity = pg.getEntityByUid(leaderUid)

	if not leaderEntity then
		return
	end

	leaderEntity = getControlEnt(leaderEntity)

	if leaderEntity and not leaderEntity.teamHandEffectId then
		self:addHandEffect(leaderEntity, true)
	else
		pg.me.logger:debug("not add handEffect", leaderEntity, leaderEntity and leaderEntity.teamHandEffectId)
	end
end

function TeamLinkController:addHandEffect(entity, isLeader)
	if Utils.isPet(entity) then
		local offsetLocation = Vector3(0, 0, 0)

		if isLeader then
			offsetLocation = entity:getConfigData().petLeaderLocation or SysConfigData.PET_LEADER_LINE_LOCATION or Vector3(0, 0, 0)
		else
			offsetLocation = entity:getConfigData().petFollowLocation or SysConfigData.PET_FOLLOW_LINE_LOCATION or Vector3(0, 0, 0)
		end

		local radius = entity.eModel.radius
		local rigidbodyData = RigidbodyData[entity:getConfigData().rigidbody or ""]
		local scale = entity:getConfigData().modelScaleRange[3]

		if not ToBool(radius) and rigidbodyData.radius then
			radius = rigidbodyData.radius * scale
		end

		local height = entity.eModel.height

		if not ToBool(height) and rigidbodyData.height then
			height = rigidbodyData.height * scale
		end

		local offsetX = offsetLocation[1]
		local offsetHeight = offsetLocation[2] * height
		local offsetZ = offsetLocation[3]
		local position = Vector3(offsetX, offsetHeight, offsetZ)
		local handEffInfo = {
			position = position,
			rotation = Vector3.zero,
			mountType = EffectConst.MountType.PositionAgent,
			followType = EffectConst.FollowType.FollowPos
		}

		entity.teamHandEffectId = entity:playEffect(isLeader and PET_SPHERE_EFF_LEADER_ID or PET_SPHERE_EFF_ID, handEffInfo, true)
	else
		entity.teamHandEffectId = entity:playEffect(isLeader and EFF_PLAYER_LINK_LEADER or EFF_PLAYER_LINK_FOLLOW, nil, true)
	end
end

function TeamLinkController:addFollowEff(leaderUid, followUid)
	local followEnt = pg.getEntityByUid(followUid)

	followEnt = followEnt and getControlEnt(followEnt)

	local leaderEntity = pg.getEntityByUid(leaderUid)

	leaderEntity = getControlEnt(leaderEntity)

	if not leaderEntity then
		self:setFollowLinkEffectVisible(followEnt, false)

		return
	end

	self:addLeaderEff(leaderUid)

	if not leaderEntity.teamHandEffectId then
		self:setFollowLinkEffectVisible(followEnt, false)

		return
	end

	if not leaderEntity.eModel or not leaderEntity:hasEModelComponent(Const.COMPONENT_INDEX_EFFECT) then
		self:setFollowLinkEffectVisible(followEnt, false)

		return
	end

	local linkTargetTrans = leaderEntity.eModel:GetEffect(Const.COMPONENT_INDEX_EFFECT, leaderEntity.teamHandEffectId)

	if not linkTargetTrans then
		self:setFollowLinkEffectVisible(followEnt, false)

		return
	end

	if not followEnt then
		return
	end

	if not followEnt.teamHandEffectId then
		self:addHandEffect(followEnt, false)
	end

	if not followEnt.teamHandEffectId then
		self:setFollowLinkEffectVisible(followEnt, false)

		return
	end

	if not followEnt.eModel or not followEnt:hasEModelComponent(Const.COMPONENT_INDEX_EFFECT) then
		self:setFollowLinkEffectVisible(followEnt, false)

		return
	end

	if not followEnt.teamFollowEffectId then
		local effectTrans = followEnt.eModel:GetEffect(Const.COMPONENT_INDEX_EFFECT, followEnt.teamHandEffectId)

		if not effectTrans then
			self:setFollowLinkEffectVisible(followEnt, false)

			return
		end

		followEnt.teamFollowEffectId = followEnt:playEffectOn(LINK_EFF_ID, nil, effectTrans, true)
	end

	local linkTrans = followEnt.eModel:GetEffect(Const.COMPONENT_INDEX_EFFECT, followEnt.teamFollowEffectId)

	if linkTrans then
		local comp = TeamLinkCustomEffect.GetOrAdd(linkTrans)

		comp.linkTarget = linkTargetTrans

		self:setFollowLinkEffectVisible(followEnt, true)
	else
		self:setFollowLinkEffectVisible(followEnt, false)
	end

	self:refreshOutOfRangeEffectVisible(leaderUid)
end

function TeamLinkController:removeLeader(uid)
	if not self.followInfo[uid] then
		return
	end

	self:removeLearEff(uid)

	for followUid, _ in pairs(self.followInfo[uid]) do
		self:removeFollowEff(followUid)

		self.follow2LeaderMap[followUid] = nil
	end

	self.followInfo[uid] = nil
end

function TeamLinkController:updateFollowInfo(playerEnt, onlyUpdateData, isDestroy)
	local leaderUid = playerEnt.followLeaderUid or ""
	local followUid = playerEnt.uid

	if ToBool(leaderUid) and not isDestroy then
		if not self.followInfo[leaderUid] then
			self.followInfo[leaderUid] = {}
		end

		self.followInfo[leaderUid][followUid] = true
		self.follow2LeaderMap[followUid] = leaderUid

		if not onlyUpdateData then
			self:addFollowEff(leaderUid, followUid)
		end
	else
		if not self.followInfo[leaderUid] and not self.follow2LeaderMap[followUid] then
			return
		end

		if not ToBool(leaderUid) then
			leaderUid = self.follow2LeaderMap[followUid]
		end

		if self.followInfo[leaderUid] then
			self:removeFollowEff(followUid)

			self.followInfo[leaderUid][followUid] = nil
			self.follow2LeaderMap[followUid] = nil

			if not next(self.followInfo[leaderUid]) then
				if not onlyUpdateData then
					self:removeLearEff(leaderUid)
				end

				self.followInfo[leaderUid] = nil
			else
				self:refreshOutOfRangeEffectVisible(leaderUid)
			end
		end
	end
end

function TeamLinkController:onEntityDestroy(entity)
	local uid = entity.uid

	if not uid then
		return
	end

	if self.followInfo[uid] then
		for followUid, _ in pairs(self.followInfo[uid]) do
			self:removeFollowEff(followUid)
		end
	end

	if self.follow2LeaderMap[uid] then
		self:removeFollowEff(uid)
	end
end

function TeamLinkController:switchEffect(uid)
	if self.followInfo[uid] then
		self:addLeaderEff(uid)

		local leaderEntity = pg.getEntityByUid(uid)

		leaderEntity = getControlEnt(leaderEntity)

		if not leaderEntity or not leaderEntity.teamHandEffectId then
			for followUid, _ in pairs(self.followInfo[uid]) do
				local followEntity = pg.getEntityByUid(followUid)

				self:setFollowLinkEffectVisible(followEntity and getControlEnt(followEntity), false)
			end

			return
		end

		if not leaderEntity.eModel or not leaderEntity:hasEModelComponent(Const.COMPONENT_INDEX_EFFECT) then
			for followUid, _ in pairs(self.followInfo[uid]) do
				local followEntity = pg.getEntityByUid(followUid)

				self:setFollowLinkEffectVisible(followEntity and getControlEnt(followEntity), false)
			end

			return
		end

		local teamHandEffectTrans = leaderEntity.eModel:GetEffect(Const.COMPONENT_INDEX_EFFECT, leaderEntity.teamHandEffectId)

		if not teamHandEffectTrans then
			pg.me.logger:error("teamHandEffectTrans not found")

			for followUid, _ in pairs(self.followInfo[uid]) do
				local followEntity = pg.getEntityByUid(followUid)

				self:setFollowLinkEffectVisible(followEntity and getControlEnt(followEntity), false)
			end

			return
		end

		for followUid, _ in pairs(self.followInfo[uid]) do
			local followEntity = pg.getEntityByUid(followUid)

			if followEntity then
				followEntity = getControlEnt(followEntity)

				if followEntity and followEntity.teamFollowEffectId and followEntity:hasEModelComponent(Const.COMPONENT_INDEX_EFFECT) then
					local teamFollowTrans = followEntity.eModel:GetEffect(Const.COMPONENT_INDEX_EFFECT, followEntity.teamFollowEffectId)

					if teamFollowTrans then
						local comp = TeamLinkCustomEffect.GetOrAdd(teamFollowTrans)

						if comp then
							comp.linkTarget = teamHandEffectTrans

							self:setFollowLinkEffectVisible(followEntity, true)
						else
							self:setFollowLinkEffectVisible(followEntity, false)
						end
					else
						self:setFollowLinkEffectVisible(followEntity, false)
					end
				else
					self:addFollowEff(uid, followUid)
				end
			else
				pg.me.logger:error("follow entity not found", followUid)
			end
		end

		self:refreshOutOfRangeEffectVisible(uid)

		return
	end

	if self.follow2LeaderMap[uid] then
		self:addFollowEff(self.follow2LeaderMap[uid], uid)
	end
end

function TeamLinkController:onControlStateChange(entity, controlState, oldPetId)
	local uid = entity.uid

	if not self.followInfo[uid] and not self.follow2LeaderMap[uid] then
		return
	end

	if controlState == Const.CONTROL_STATE_CONTROL then
		self:clearEff(entity)
	else
		local petEntity = oldPetId and oldPetId ~= "" and pg.getEntity(oldPetId) or nil

		if petEntity then
			self:clearEff(petEntity)
		end

		local curPetEntity = entity:getCurPetEntity()

		if curPetEntity and curPetEntity ~= petEntity then
			self:clearEff(curPetEntity)
		end
	end

	local uid = entity.uid

	self:switchEffect(uid)
end

function TeamLinkController:onControlPetChange(entity, oldPet)
	local uid = entity.uid

	if not self.followInfo[uid] and not self.follow2LeaderMap[uid] then
		return
	end

	if entity.controlState ~= Const.CONTROL_STATE_CONTROL then
		return
	end

	self:clearEff(oldPet)

	local uid = entity.uid

	self:switchEffect(uid)
end

function TeamLinkController:onPetStart(entity)
	local uid = entity.uid

	if not self.followInfo[uid] and not self.follow2LeaderMap[uid] then
		return
	end

	self:clearEff(entity)

	local petEntity = entity:getCurPetEntity()

	if petEntity then
		self:clearEff(petEntity)
	end

	local uid = entity.uid

	self:switchEffect(uid)
end

function TeamLinkController:clearEff(ent)
	if not ent then
		return
	end

	if ent.teamHandEffectId then
		ent:stopEffectById(ent.teamHandEffectId)

		ent.teamHandEffectId = nil
	end

	if ent.teamFollowEffectId then
		ent:stopEffectById(ent.teamFollowEffectId)

		ent.teamFollowEffectId = nil
	end
end

return TeamLinkController
