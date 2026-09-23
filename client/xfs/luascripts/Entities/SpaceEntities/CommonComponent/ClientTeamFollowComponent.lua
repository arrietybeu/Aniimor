-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientTeamFollowComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local SysConfigData = require("Data.sys_config_data")
local Utils = require("Common.Utils.Utils")
local EffectConst = require("Const.EffectConst")
local RigidbodyData = require("Data.rigidbody_data")
local MessageName = require("Const.MessageName")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local ClientTeamFollowComponent = class.Component("ClientTeamFollowComponent")

function ClientTeamFollowComponent.getTeamFollowButterflyEffect()
	return "Eff_Player_Link_Follow"
end

function ClientTeamFollowComponent.getTeamFollowAttachHp()
	return "Bip001 Pelvis"
end

function ClientTeamFollowComponent.getAwayStateDelayTime()
	return SysConfigData.FollowBackToNormalDelay or 2
end

function ClientTeamFollowComponent.getAwayStateCountdownTime()
	return SysConfigData.FollowBackToNormalCountdown or 3
end

function ClientTeamFollowComponent.getAwayQuitInterruptLimit()
	return SysConfigData.FollowBackToNormalInterruptCountLimit or 3
end

function ClientTeamFollowComponent.getSpaceFollowStateFunc(state)
	if state == Const.SpaceFollowMemberState.Normal then
		return "switchToNormalState"
	elseif state == Const.SpaceFollowMemberState.Away then
		return "switchToAwayState"
	elseif state == Const.SpaceFollowMemberState.Moving then
		return "switchToMovingState"
	elseif state == Const.SpaceFollowMemberState.Attach then
		return "switchToAttachState"
	end

	return nil
end

function ClientTeamFollowComponent.isSpaceFollowDynamicCharacterState(parentState)
	return parentState == CharacterStateConst.SWIMMING or parentState == CharacterStateConst.CLIMBING or parentState == CharacterStateConst.FLYING or parentState == CharacterStateConst.GLIDING
end

function ClientTeamFollowComponent.getControlEnt(ent)
	if ent and ent.isControllingPet and ent:isControllingPet() then
		return ent:getCurPetEntity() or ent
	end

	return ent
end

function ClientTeamFollowComponent.getMySpaceFollowLeaderUid()
	return pg.me and pg.me.space and pg.me.space:getSpaceFollowLeader(pg.me.uid) or nil
end

function ClientTeamFollowComponent:shouldHideByMySpaceFollowTeam(uid)
	local space = pg.me and pg.me.space or nil
	local myLeaderUid = ClientTeamFollowComponent.getMySpaceFollowLeaderUid()

	if not space or not myLeaderUid or not uid or uid == pg.me.uid then
		return false
	end

	local leaderEnt = pg.getEntityByUid(myLeaderUid)

	return leaderEnt and leaderEnt.followState == Const.SpaceFollowMemberState.SpecialCharacterState and space:getSpaceFollowLeader(uid) == myLeaderUid
end

function ClientTeamFollowComponent.refreshTeamFollowAllyMark(ent)
	if not ent or ent.isMainPlayer or not pg.me then
		return
	end

	local teamInfo = pg.me.getCurTeamInfo and pg.me:getCurTeamInfo() or nil
	local memberInfo = teamInfo and teamInfo.membersInfo or {}
	local memberData = memberInfo[ent.uid]

	if not memberData or not memberData.entityId then
		return
	end

	local entryAdd = not pg.me.shouldHideByMySpaceFollowTeam or not pg.me:shouldHideByMySpaceFollowTeam(ent.uid)

	if entryAdd then
		local tempMarkPointData = pg.game and pg.game.map and pg.game.map.tempMarkPointData or nil
		local markData = tempMarkPointData and tempMarkPointData[memberData.entityId]

		if pg.me.inTeammateView or not markData or markData.markType ~= Const.MAP_MARK_ALLY then
			return
		end
	end

	local mapMarkTipComponent = pg.global and pg.global.ui and pg.global.ui.hatredArrowTip and pg.global.ui.hatredArrowTip.mapMarkTipComponent

	if mapMarkTipComponent then
		mapMarkTipComponent:onAllyChanged({
			entryAdd = entryAdd,
			refEntityId = memberData.entityId
		})
	end
end

function ClientTeamFollowComponent.refreshMySpaceFollowTeamEntUI(uid)
	local ent = pg.getEntityByUid(uid)

	ClientTeamFollowComponent.refreshTeamFollowAllyMark(ent)

	if ent and ent.refreshSpaceFollowInteraction then
		ent:refreshSpaceFollowInteraction()
	end
end

function ClientTeamFollowComponent.refreshMySpaceFollowTeamUI()
	local space = pg.me and pg.me.space or nil
	local leaderUid = ClientTeamFollowComponent.getMySpaceFollowLeaderUid()

	if not space or not leaderUid then
		return
	end

	ClientTeamFollowComponent.refreshMySpaceFollowTeamEntUI(leaderUid)

	for _, uid in ipairs(space.followInfo and space.followInfo[leaderUid] or EMPTY_TABLE) do
		ClientTeamFollowComponent.refreshMySpaceFollowTeamEntUI(uid)
	end
end

function ClientTeamFollowComponent.getAttachEntList(ownEnt)
	local entList = {}

	if ownEnt then
		entList[#entList + 1] = ownEnt
	end

	local petEnt = ownEnt:getCurPetEntity()

	if petEnt then
		entList[#entList + 1] = petEnt
	end

	return entList
end

function ClientTeamFollowComponent.getTeamFollowEffectData(data)
	if Utils.isTable(data) then
		return data.effectId, data.entId
	end

	return data, nil
end

function ClientTeamFollowComponent.setTeamFollowEffectIds(uid, effectId, entId)
	if not pg.me or not uid then
		return
	end

	if not effectId then
		if pg.me.teamFollowButterflyEffectIds then
			pg.me.teamFollowButterflyEffectIds[uid] = nil
		end

		return
	end

	if not pg.me.teamFollowButterflyEffectIds then
		pg.me.teamFollowButterflyEffectIds = {}
	end

	pg.me.teamFollowButterflyEffectIds[uid] = {
		effectId = effectId,
		entId = entId
	}
end

function ClientTeamFollowComponent.getTeamFollowEffectId(uid)
	if not pg.me then
		return nil
	end

	return ClientTeamFollowComponent.getTeamFollowEffectData(pg.me.teamFollowButterflyEffectIds and pg.me.teamFollowButterflyEffectIds[uid] or nil)
end

function ClientTeamFollowComponent.clearTeamFollowEffectIds()
	if pg.me then
		pg.me.teamFollowButterflyEffectIds = nil
	end
end

function ClientTeamFollowComponent.restoreTeamFollowAttachedEnt(attachedEnt)
	if not attachedEnt then
		return
	end

	local position

	if attachedEnt.eModel and attachedEnt.eModel:CheckPositionAgent() then
		local x, y, z = attachedEnt.eModel:GetPositionAgentPosEx()

		position = Vector3.New(x, y, z)
	else
		position = attachedEnt:getPosition()
	end

	local rotation = attachedEnt:getRotation()
	local targetYaw = rotation and rotation:GetEulerAnglesY() or 0

	attachedEnt:forceSetPosRot(position, Quaternion.Euler(0, targetYaw, 0), true, true)

	if attachedEnt.characterState == CharacterStateConst.BEATTACHED then
		AnimationUtils.playAnimationState(attachedEnt, CharacterStateConst.LOCOMOTION)
	end

	attachedEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.SPACE_FOLLOW, true, true)
end

function ClientTeamFollowComponent.getAttachOffset(ownEnt)
	local space = ownEnt and ownEnt.space or pg.me and pg.me.space
	local uid = ownEnt and ownEnt.uid

	if not space or not uid then
		return {
			0,
			0,
			0
		}
	end

	local followIndex = 0

	for _, followList in pairs(space.followInfo) do
		for idx, followerUid in ipairs(followList) do
			if followerUid == uid then
				followIndex = idx

				break
			end
		end
	end

	if followIndex > 0 then
		return SysConfigData.PET_FOLLOW_LIST_LOCATION[followIndex]
	end

	return {
		0,
		0,
		0
	}
end

function ClientTeamFollowComponent.getAttachEffectPosition(leaderEnt, ownEnt)
	local offsetLocation = ClientTeamFollowComponent.getAttachOffset(ownEnt)
	local height = leaderEnt and leaderEnt.eModel and leaderEnt.eModel.height or nil

	if not ToBool(height) and leaderEnt then
		local configData = leaderEnt:getConfigData()
		local rigidbodyData = configData and RigidbodyData[configData.rigidbody or ""] or nil
		local modelScaleRange = configData and configData.modelScaleRange or nil
		local scale = modelScaleRange and modelScaleRange[3] or 1

		if rigidbodyData and rigidbodyData.height then
			height = rigidbodyData.height * scale
		end
	end

	height = ToBool(height) and height or 1

	local offset = Vector3(offsetLocation[1] or 0, (offsetLocation[2] or 0) * height, offsetLocation[3] or 0)
	local rotation = leaderEnt and leaderEnt.getPositionAgentRotation and leaderEnt:getPositionAgentRotation() or nil

	if rotation then
		local yawOffset = Quaternion.MulVec3(Quaternion.Euler(0, rotation:GetEulerAnglesY(), 0), offset)

		return Quaternion.MulVec3(Quaternion.Inverse(rotation), yawOffset)
	end

	return offset
end

function ClientTeamFollowComponent.refreshAttachEffectPosition(effectItem, leaderEnt, ownEnt)
	if effectItem and NotNil(effectItem.effectTrans) then
		effectItem.effectTrans.localPosition = ClientTeamFollowComponent.getAttachEffectPosition(leaderEnt, ownEnt)
	end
end

function ClientTeamFollowComponent.setEffectVisibleById(ent, effectId, visible)
	if effectId and effectId ~= 0 and ent and ent.eModel then
		ent.eModel:SetEffectVisibleById(Const.COMPONENT_INDEX_EFFECT, effectId, visible)
	end
end

function ClientTeamFollowComponent.checkIsSpecialCharacterState(state)
	if not state or not CharacterStateConst[state] then
		return false
	end

	local parentState = CharacterStateConst.getParentState(state)

	return ClientTeamFollowComponent.isSpaceFollowDynamicCharacterState(parentState)
end

function ClientTeamFollowComponent:ctor()
	self.keepAwayStateMap = {}
end

function ClientTeamFollowComponent:init(avtDict)
	return
end

function ClientTeamFollowComponent:preDestroy()
	self:clearAwayState(true)

	if self.isMainPlayer then
		self:stopAllTeamFollowButterflyEffects()
	else
		self:stopTeamFollowButterflyEffect()
	end
end

function ClientTeamFollowComponent:EVENT_OnCharacterStateChange(oldState, newState)
	if pg.me.space and pg.me.space:isSpaceFollowLeader(pg.me.uid) then
		pg.me:setFollowState(ClientTeamFollowComponent.checkIsSpecialCharacterState(newState) and Const.SpaceFollowMemberState.SpecialCharacterState or Const.SpaceFollowMemberState.Normal)
	end
end

function ClientTeamFollowComponent:onSkeletonLoaded()
	if self.followState and self.followState ~= Const.SpaceFollowMemberState.Normal then
		self:on_followState_changed(1, self.followState)
	end
end

function ClientTeamFollowComponent:on_followState_changed(oldV, newV)
	local leaderUid = self.space and self.space:getSpaceFollowLeader(self.uid) or nil
	local myLeaderUid = ClientTeamFollowComponent.getMySpaceFollowLeaderUid()

	if leaderUid == self.uid then
		local ent = ClientTeamFollowComponent.getControlEnt(self)

		self:refreshTeamFollowButterflyEffects(ent)
	end

	if oldV == Const.SpaceFollowMemberState.OutOfRange or newV == Const.SpaceFollowMemberState.OutOfRange then
		pg.game.effect:getTeamLinkController():refreshOutOfRangeEffectVisible(leaderUid or self.uid)
	end

	if leaderUid == self.uid and pg.me.uid ~= self.uid and myLeaderUid == leaderUid and (pg.me.followState == Const.SpaceFollowMemberState.Normal or pg.me.followState == Const.SpaceFollowMemberState.Attach) then
		pg.me:setFollowState(newV == Const.SpaceFollowMemberState.SpecialCharacterState and Const.SpaceFollowMemberState.Attach or Const.SpaceFollowMemberState.Normal)

		return
	end

	if newV == Const.SpaceFollowMemberState.Away and not self.isMainPlayer then
		return
	end

	local switchFunc = ClientTeamFollowComponent.getSpaceFollowStateFunc(newV)

	if switchFunc then
		self[switchFunc](self, oldV)
	end

	if self.isMainPlayer then
		pg.game.input:enablePlayerInput(newV ~= Const.SpaceFollowMemberState.Attach or not pg.me.space or not pg.me.space:isSpaceFollowMember(pg.me.uid))
		facade:SendMessageCommand(MessageName.SPACE_FOLLOW_UPDATE, {
			followInfo = self.space and self.space.followInfo or {}
		})
	end

	if oldV == Const.SpaceFollowMemberState.Attach or newV == Const.SpaceFollowMemberState.Attach or oldV == Const.SpaceFollowMemberState.SpecialCharacterState or newV == Const.SpaceFollowMemberState.SpecialCharacterState then
		ClientTeamFollowComponent.refreshMySpaceFollowTeamUI()
	end
end

function ClientTeamFollowComponent:setFollowState(state)
	local targetState = state

	if self.isMainPlayer then
		self:serverMsg("RPC_CS_NotifyFollowState", targetState)
	end
end

function ClientTeamFollowComponent:switchToNormalState(oldState)
	self:clearAwayState(true)

	self.awayQuitInterruptCount = 0

	if oldState == Const.SpaceFollowMemberState.Attach then
		self:attachToTeamFollowLeader(false)
	end

	if self.isMainPlayer then
		pg.game.chat:spaceFollowCurLeader()
	end
end

function ClientTeamFollowComponent:switchToMovingState(oldState)
	if not self.isMainPlayer then
		return
	end

	pg.pawn:followTarget(0)
	self:clearAwayState(true)
end

function ClientTeamFollowComponent:hasKeepAwayState()
	return next(self.keepAwayStateMap) ~= nil
end

function ClientTeamFollowComponent:setKeepAwayState(reason, isKeepAway)
	if not self.isMainPlayer then
		return
	end

	if isKeepAway then
		if self.keepAwayStateMap[reason] then
			return
		end

		local hasKeepAwayState = self:hasKeepAwayState()

		self.keepAwayStateMap[reason] = true

		if hasKeepAwayState or not self.space or not self.space:isSpaceFollowMember(self.uid) then
			return
		end

		self:clearAwayState(true)
		self:setFollowState(Const.SpaceFollowMemberState.Away)

		return
	end

	if not self.keepAwayStateMap[reason] then
		return
	end

	self.keepAwayStateMap[reason] = nil

	if not self:hasKeepAwayState() and self.space and self.space:isSpaceFollowMember(self.uid) and self.followState == Const.SpaceFollowMemberState.Away then
		self:switchToAwayState()
	end
end

function ClientTeamFollowComponent:tryInterruptAwayQuitTimer()
	if not self.awayQuitTimer then
		return false
	end

	self.awayQuitInterruptCount = (self.awayQuitInterruptCount or 0) + 1

	if self.awayQuitInterruptCount < ClientTeamFollowComponent.getAwayQuitInterruptLimit() then
		return false
	end

	self:clearAwayState(true)

	self.awayQuitInterruptCount = 0

	if pg.global and pg.global.showBubbleMessageRaw then
		pg.global.showBubbleMessageRaw(pg.getGameString("MANUALLY_INTERRUPT_SPACE_FOLLOW_WARNING"), 2)
	end

	if pg.me and pg.me.exitSpaceFollow then
		pg.me:exitSpaceFollow(true)
	end

	return true
end

function ClientTeamFollowComponent:switchToAwayState(oldState)
	if not self.isMainPlayer then
		return
	end

	if self:hasKeepAwayState() then
		return
	end

	self:clearAwayState(true)

	self.awayDelayTimer = self:addTimer(ClientTeamFollowComponent.getAwayStateDelayTime(), function()
		if self.followState ~= Const.SpaceFollowMemberState.Away then
			return
		end

		local startTime = Time.realSecondCache

		self.awayControlPanelShowing = true

		pg.global.ui.tips:showControlPanel(startTime + ClientTeamFollowComponent.getAwayStateCountdownTime(), pg.getGameString("SPACE_FOLLOW_BACK_TO_LEADER"), 1, startTime)

		self.awayQuitTimer = self:addTimer(ClientTeamFollowComponent.getAwayStateCountdownTime(), function()
			if self.followState ~= Const.SpaceFollowMemberState.Away then
				return
			end

			self.awayControlPanelShowing = false
			self.awayQuitTimer = nil
			self.awayQuitInterruptCount = 0

			local leader = self.space and self.space:getSpaceFollowLeader(self.uid) or nil

			if leader == self.uid then
				return
			end

			local leaderEnt = pg.getEntityByUid(leader)

			if not leaderEnt then
				self:setFollowState(Const.SpaceFollowMemberState.Normal)

				return
			end

			if leaderEnt.followState == Const.SpaceFollowMemberState.SpecialCharacterState then
				self:setFollowState(Const.SpaceFollowMemberState.Attach)
			else
				self:setFollowState(Const.SpaceFollowMemberState.Normal)
			end
		end)
	end)
end

function ClientTeamFollowComponent:switchToAttachState(oldState)
	self:clearAwayState(true)

	self.awayQuitInterruptCount = 0

	self:attachToTeamFollowLeader(true)
end

function ClientTeamFollowComponent:clearAwayState(hideControlPanel)
	if self.awayDelayTimer then
		self:removeTimer(self.awayDelayTimer)

		self.awayDelayTimer = nil
	end

	if self.awayQuitTimer then
		self:removeTimer(self.awayQuitTimer)

		self.awayQuitTimer = nil
	end

	if hideControlPanel and self.awayControlPanelShowing and pg.global and pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:hideControlPanel()
	end

	self.awayControlPanelShowing = false
end

function ClientTeamFollowComponent:EVENT_OnMoveInputStateChanged(nv)
	if not self.isMainPlayer or not self.space or not self.space:isSpaceFollowMember(self.uid) or self:hasKeepAwayState() then
		return
	end

	if nv and self:tryInterruptAwayQuitTimer() then
		return
	end

	self:setFollowState(nv and Const.SpaceFollowMemberState.Moving or Const.SpaceFollowMemberState.Away)
end

function ClientTeamFollowComponent:attachToTeamFollowLeader(isAttached)
	local leader = self.space and self.space:getSpaceFollowLeader(self.uid) or nil

	if leader == self.uid then
		return
	end

	if not isAttached then
		self:detachToNormal()

		return
	end

	local leaderEnt = ClientTeamFollowComponent.getControlEnt(pg.getEntityByUid(leader))
	local attachEntList = ClientTeamFollowComponent.getAttachEntList(self)

	if not leaderEnt or leaderEnt == self or not leaderEnt.eModel or #attachEntList <= 0 then
		return
	end

	for _, attachEnt in ipairs(attachEntList) do
		attachEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.SPACE_FOLLOW, false, false)
	end

	self:stopTeamFollowButterflyEffect()

	local effectInfo = {
		bone = "",
		neverHide = true,
		position = ClientTeamFollowComponent.getAttachEffectPosition(leaderEnt, self),
		rotation = Vector3.zero,
		mountType = EffectConst.MountType.PositionAgent,
		followType = EffectConst.FollowType.FollowPos,
		customUpdateCallback = function(effectItem)
			ClientTeamFollowComponent.refreshAttachEffectPosition(effectItem, leaderEnt, self)
		end
	}
	local effectId = leaderEnt:playEffect(ClientTeamFollowComponent.getTeamFollowButterflyEffect(), effectInfo, true)

	if effectId and effectId ~= 0 then
		ClientTeamFollowComponent.setTeamFollowEffectIds(self.uid, effectId, leaderEnt.id)
		ClientTeamFollowComponent.setEffectVisibleById(leaderEnt, leaderEnt and leaderEnt.teamHandEffectId, false)
	end

	if self.isMainPlayer then
		for _, attachEnt in ipairs(attachEntList) do
			attachEnt:attachByTable({
				isPhysics = false,
				ignoreEntityCollide = true,
				ignoreGroundWall = true,
				freeRotation = true,
				entId = leaderEnt.id,
				targetHP = ClientTeamFollowComponent.getTeamFollowAttachHp(),
				selfHP = ClientTeamFollowComponent.getTeamFollowAttachHp(),
				offset = {
					0,
					0,
					0
				}
			})
		end
	end
end

function ClientTeamFollowComponent:stopTeamFollowButterflyEffect()
	local uid = self and self.uid
	local effectId, entId = ClientTeamFollowComponent.getTeamFollowEffectId(uid)

	if not effectId then
		return
	end

	local effectEnt = entId and pg.getEntity(entId) or nil

	effectEnt = effectEnt or ClientTeamFollowComponent.getControlEnt(self)

	if effectEnt and effectEnt.stopEffectById then
		effectEnt:stopEffectById(effectId)
	end

	ClientTeamFollowComponent.setTeamFollowEffectIds(uid, nil)
end

function ClientTeamFollowComponent:stopAllTeamFollowButterflyEffects()
	if not pg.me or not pg.me.teamFollowButterflyEffectIds then
		return
	end

	for uid, data in pairs(pg.me.teamFollowButterflyEffectIds) do
		local effectId, entId = ClientTeamFollowComponent.getTeamFollowEffectData(data)
		local effectEnt = entId and pg.getEntity(entId) or nil

		if effectId and effectEnt and effectEnt.stopEffectById then
			effectEnt:stopEffectById(effectId)
		end
	end

	ClientTeamFollowComponent.clearTeamFollowEffectIds()
end

function ClientTeamFollowComponent:refreshTeamFollowButterflyEffects(ent)
	if not ent or not ent.id or not ent.eModel or not pg.me or not pg.me.teamFollowButterflyEffectIds then
		return
	end

	local hasAttach = false

	for uid, data in pairs(pg.me.teamFollowButterflyEffectIds) do
		local effectId, entId = ClientTeamFollowComponent.getTeamFollowEffectData(data)

		if effectId and entId ~= ent.id then
			local oldEffectEnt = entId and pg.getEntity(entId) or nil

			if oldEffectEnt and oldEffectEnt.stopEffectById then
				oldEffectEnt:stopEffectById(effectId)
			end

			local ownEnt = pg.getEntityByUid(uid) or self
			local effectInfo = {
				bone = "",
				neverHide = true,
				position = ClientTeamFollowComponent.getAttachEffectPosition(ent, ownEnt),
				rotation = Vector3.zero,
				mountType = EffectConst.MountType.PositionAgent,
				followType = EffectConst.FollowType.FollowPos,
				customUpdateCallback = function(effectItem)
					ClientTeamFollowComponent.refreshAttachEffectPosition(effectItem, ent, ownEnt)
				end
			}
			local newEffectId = ent:playEffect(ClientTeamFollowComponent.getTeamFollowButterflyEffect(), effectInfo, true)

			hasAttach = true

			ClientTeamFollowComponent.setTeamFollowEffectIds(uid, newEffectId and newEffectId ~= 0 and newEffectId or nil, ent.id)
		end
	end

	ClientTeamFollowComponent.setEffectVisibleById(ent, ent and ent.teamHandEffectId, not hasAttach)
end

function ClientTeamFollowComponent:refreshTeamFollowAttachOnControlEntChanged()
	if not self.space or not self.space:isSpaceFollowed(self.uid) then
		return
	end

	self:attachToTeamFollowLeader(self.followState == Const.SpaceFollowMemberState.Attach)
end

function ClientTeamFollowComponent:EVENT_onControlPetSwitchToPlayer()
	self:refreshTeamFollowAttachOnControlEntChanged()
end

function ClientTeamFollowComponent:EVENT_onControlPlayerSwitchToPet()
	self:refreshTeamFollowAttachOnControlEntChanged()
end

function ClientTeamFollowComponent:EVENT_onControlPetSwitchToAnotherPet()
	self:refreshTeamFollowAttachOnControlEntChanged()
end

function ClientTeamFollowComponent:EVENT_OnPetStart(actorId)
	if not self.space or not self.space:isSpaceFollowed(self.uid) then
		return
	end

	pg.game.effect:getTeamLinkController():onPetStart(self)
	self:attachToTeamFollowLeader(self.followState == Const.SpaceFollowMemberState.Attach)

	local leaderUid = ClientTeamFollowComponent.getMySpaceFollowLeaderUid()

	if self.followState == Const.SpaceFollowMemberState.SpecialCharacterState and leaderUid == self.uid and not self.isMainPlayer then
		local ent = ClientTeamFollowComponent.getControlEnt(self)

		self:refreshTeamFollowButterflyEffects(ent)
	end
end

function ClientTeamFollowComponent:detachToNormal()
	local attachedEntList = ClientTeamFollowComponent.getAttachEntList(self)

	if self.isMainPlayer then
		for _, attachedEnt in ipairs(attachedEntList) do
			if attachedEnt and attachedEnt.detach then
				attachedEnt:detach()
			end
		end
	end

	self:stopTeamFollowButterflyEffect()

	for _, attachedEnt in ipairs(attachedEntList) do
		ClientTeamFollowComponent.restoreTeamFollowAttachedEnt(attachedEnt)
	end
end

return ClientTeamFollowComponent
