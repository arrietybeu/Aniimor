-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Social\\Component\\PetSocialBehaviorComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local AiConst = require("Common.Const.AiConst")
local Const = require("Common.Const.Const")
local EventConst = require("Common.Const.EventConst")
local NoticeDef = require("Common.NoticeDef")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local SysConfigData = require("Data.sys_config_data")
local SysNoticeData = require("Data.sys_notice_data")
local PetData = require("Data.pet_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local PetPeekTag = require("GameApp.Social.Component.PetPeekTag")
local CocktailInviteBubble = require("GameApp.Social.Component.CocktailInviteBubble")
local PlayableConst = require("Common.Const.PlayableConst")
local Utils = require("Common.Utils.Utils")
local SocialConst = require("Common.Const.SocialConst")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local PetSocialBehaviorComponent = Class.LiteClass("PetSocialBehaviorComponent")

PetSocialBehaviorComponent.PET_AI_TRACK_ICON = "$UI_Icon_MarkPoint_PetCoordinates.png"
PetSocialBehaviorComponent.CAFE_PET_NOTICE_SET = {
	[NoticeDef.SOCIAL_PARTY_SNUGGLE_START] = true,
	[NoticeDef.SOCIAL_PARTY_SNUGGLE_DROP_TOAST1] = true,
	[NoticeDef.SOCIAL_PARTY_SNUGGLE_DROP_TOAST2] = true,
	[NoticeDef.SOCIAL_PARTY_SNUGGLE_DROP_TOAST3] = true,
	[NoticeDef.SOCIAL_PARTY_SNUGGLE_PET_PROP] = true,
	[NoticeDef.SOCIAL_PARTY_FOLLOW_START] = true,
	[NoticeDef.SOCIAL_PARTY_FOLLOW_DROP_TOAST] = true,
	[NoticeDef.SOCIAL_PARTY_FOLLOW_PET_PROP] = true
}
PetSocialBehaviorComponent.CAFE_PET_IV_NOTICE_SET = {
	[NoticeDef.SOCIAL_PARTY_SNUGGLE_PET_PROP] = true,
	[NoticeDef.SOCIAL_PARTY_FOLLOW_PET_PROP] = true
}

function PetSocialBehaviorComponent:getPetInteractDesignPerformSec()
	local performSec = tonumber(SysConfigData.SOCIAL_PARTY_PET_AI_TIME)

	if performSec == nil or performSec <= 0 then
		return SocialConst.PET_INTERACT_DESIGN_PERFORM_SEC
	end

	return performSec
end

function PetSocialBehaviorComponent:getPetInteractPerformSec()
	local cdSec = tonumber(SysConfigData.SOCIAL_PARTY_PET_AI_CD)

	if cdSec == nil or cdSec <= 0 then
		return self:getPetInteractDesignPerformSec()
	end

	local maxPerformSec = math.max(SocialConst.MIN_PET_INTERACT_PERFORM_SEC, cdSec - SocialConst.PET_INTERACT_CD_GUARD_SEC)

	return math.min(self:getPetInteractDesignPerformSec(), maxPerformSec)
end

function PetSocialBehaviorComponent:resetData()
	if self._activePerforms ~= nil then
		for groupKey, _ in pairs(self._activePerforms) do
			self:_clearPerform(groupKey)
		end
	end

	self._sceneIdGuard = SocialConst.ARK_SCENE_ID
	self._activePerforms = {}
	self._interactCtxByGroupKey = {}
	self._petAiHudTraceGroupKey = nil
	self._petAiHudTracePetId = nil

	if self._petPeekTag == nil then
		self._petPeekTag = PetPeekTag.new()
	end

	self._petPeekTag:resetData()

	if self._cocktailInviteBubble == nil then
		self._cocktailInviteBubble = CocktailInviteBubble.new()
	end

	self._cocktailInviteBubble:resetData()
	self:_safeResetMyPetAi()
end

function PetSocialBehaviorComponent:_isInGuardScene()
	if pg.me == nil then
		return false
	end

	if self._sceneIdGuard == nil then
		return true
	end

	local space = pg.me.space

	if space == nil then
		return false
	end

	return space.sceneId == self._sceneIdGuard
end

function PetSocialBehaviorComponent:_setInteractMode(flag)
	pg.game.social:setInPetInteractMode(flag)
end

function PetSocialBehaviorComponent:_safeResetMyPetAi()
	local pet = pg.me and pg.me:getCurPetEntity()

	if pet == nil then
		return
	end

	pet:stopAllAnimation()
	pet:resumeBt(AiConst.PauseBtReason.PetCafeInteract)
end

function PetSocialBehaviorComponent:_getPetAiTraceTargetPetId(pets)
	if not pets or #pets <= 0 then
		return nil
	end

	for _, pet in ipairs(pets) do
		if pet.isMainPet then
			return pet.id
		end
	end

	return nil
end

function PetSocialBehaviorComponent:_sendPetAiHudTrace(entityId, enable)
	if entityId == nil then
		return
	end

	facade:sendMsgToUI(MessageName.UI_TRACK_SINGLE_ENT, {
		edgeOnly = true,
		sizeSmall = true,
		enable = enable == true,
		entityId = entityId,
		img = PetSocialBehaviorComponent.PET_AI_TRACK_ICON,
		edgeOnlyTopLogoComponent = UIConst.TOPLOGO_COMPONENT.ICON
	})
end

function PetSocialBehaviorComponent:_setPetAiTopLogoIcon(petId, visible)
	local pet = pg.getEntity(petId)

	if pet == nil then
		return
	end

	pet.topLogoData = pet.topLogoData or {}
	pet.topLogoData.petAiTrackingIcon = visible == true and PetSocialBehaviorComponent.PET_AI_TRACK_ICON or nil

	local iconComp

	if visible == true then
		pet:ensureTopLogoItem("pet_ai_tracking")

		if pet:getTopLogoIcon() ~= nil then
			iconComp = pet:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.ICON)
		end
	else
		iconComp = pet:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.ICON)
	end

	if iconComp and iconComp.m_refreshIcon then
		iconComp:m_refreshIcon()
	end
end

function PetSocialBehaviorComponent:_startPetAiTrace(groupKey, pets)
	if groupKey == nil or not pets or #pets <= 0 then
		return nil
	end

	local myPet = self:splitMyAndOtherPet(pets)
	local targetPetId = self:_getPetAiTraceTargetPetId(pets)

	if targetPetId ~= nil then
		self._petAiHudTraceGroupKey = groupKey
		self._petAiHudTracePetId = targetPetId

		self:_sendPetAiHudTrace(targetPetId, true)
	end

	if myPet ~= nil then
		self:_setPetAiTopLogoIcon(myPet.id, true)
	end

	return {
		targetPetId = targetPetId,
		topLogoPetId = myPet and myPet.id or nil
	}
end

function PetSocialBehaviorComponent:_stopPetAiTrace(groupKey, traceInfo)
	if traceInfo ~= nil and traceInfo.topLogoPetId ~= nil then
		self:_setPetAiTopLogoIcon(traceInfo.topLogoPetId, false)
	end

	if self._petAiHudTraceGroupKey == groupKey then
		if self._petAiHudTracePetId ~= nil then
			self:_sendPetAiHudTrace(self._petAiHudTracePetId, false)
		end

		self._petAiHudTraceGroupKey = nil
		self._petAiHudTracePetId = nil
	end
end

function PetSocialBehaviorComponent:_clearPetAiHudTrace()
	if self._petAiHudTracePetId ~= nil then
		self:_sendPetAiHudTrace(self._petAiHudTracePetId, false)
	end

	self._petAiHudTraceGroupKey = nil
	self._petAiHudTracePetId = nil
end

function PetSocialBehaviorComponent:_retainRewardContext(groupKey)
	if self._interactCtxByGroupKey == nil then
		return
	end

	local ctx = self._interactCtxByGroupKey[groupKey]

	if ctx == nil then
		return
	end

	local expireSec = os.time() + SocialConst.PET_INTERACT_REWARD_CONTEXT_KEEP_SEC

	if ctx.expireSec == nil or expireSec > ctx.expireSec then
		ctx.expireSec = expireSec
	end
end

function PetSocialBehaviorComponent:onPetInteractAction(sourcePlayerEntId, behaviorType, memberPetIds)
	if self:_isInGuardScene() ~= true then
		return
	end

	if behaviorType == Const.BehaviorType.NONE then
		self:abortAllPerforms()

		return
	end

	if not memberPetIds or #memberPetIds == 0 then
		return
	end

	local pets = {}

	for _, petId in ipairs(memberPetIds) do
		local pet = pg.getEntity(petId)

		if pet ~= nil then
			pets[#pets + 1] = pet
		end
	end

	if #pets == 0 then
		return
	end

	local groupKey = memberPetIds[1]

	self:_clearPerform(groupKey)

	local pausedPetIds = {}

	for _, pet in ipairs(pets) do
		pet:pauseBt(AiConst.PauseBtReason.PetCafeInteract)

		pausedPetIds[#pausedPetIds + 1] = pet.id
	end

	self:_applyBehaviorPose(behaviorType, pets)
	self:_tryAttachCocktailInvite(pets)

	local traceInfo = self:_startPetAiTrace(groupKey, pets)
	local performSec = self:getPetInteractPerformSec()
	local now = os.time()
	local ctx = {
		behaviorType = behaviorType,
		petIds = {},
		startSec = now,
		expireSec = now + performSec + SocialConst.PET_INTERACT_REWARD_CONTEXT_KEEP_SEC
	}

	for _, p in ipairs(pets) do
		ctx.petIds[#ctx.petIds + 1] = p.id
	end

	ctx.myPetId, ctx.myPetName, ctx.beforePropLevels = self:_snapshotMyPetProps(pets)
	self._interactCtxByGroupKey[groupKey] = ctx

	pg.game.social:setInPetInteractMode(true)

	local timerId = TimerManager.addTimer(performSec, function()
		self:_finishPerform(groupKey)
	end)

	self._activePerforms[groupKey] = {
		pausedPetIds = pausedPetIds,
		timerId = timerId,
		traceInfo = traceInfo
	}
end

function PetSocialBehaviorComponent:safePetName(pet)
	if pet == nil then
		return ""
	end

	local name = pet:getName()

	if name ~= nil and name ~= "" then
		return name
	end

	if not string.isNilOrEmpty(pet.customName) then
		return pet.customName
	end

	return ""
end

function PetSocialBehaviorComponent:splitMyAndOtherPet(pets)
	local myId = pg.me ~= nil and pg.me.id or nil
	local myPet, otherPet, otherMaster

	for _, p in ipairs(pets) do
		local master = p:getMasterEntity()
		local masterId = master ~= nil and master.id or nil

		if masterId ~= nil and masterId == myId then
			myPet = myPet or p
		else
			otherPet = otherPet or p
			otherMaster = otherMaster or master
		end
	end

	return myPet, otherPet, otherMaster
end

function PetSocialBehaviorComponent:collectCafePetNoticeArgs(noticeArgs)
	local args = {}

	if Utils.isTable(noticeArgs) then
		for i = 1, #noticeArgs do
			args[#args + 1] = noticeArgs[i]
		end
	elseif noticeArgs ~= nil then
		args[#args + 1] = noticeArgs
	end

	return args
end

function PetSocialBehaviorComponent:isCafePetNotice(noticeId)
	return PetSocialBehaviorComponent.CAFE_PET_NOTICE_SET[noticeId] == true
end

function PetSocialBehaviorComponent:isCafePetIvNotice(noticeId)
	return PetSocialBehaviorComponent.CAFE_PET_IV_NOTICE_SET[noticeId] == true
end

function PetSocialBehaviorComponent:snapshotPropLevels(petId)
	if petId == nil then
		return nil
	end

	if pg.me == nil then
		return nil
	end

	local petInfo = pg.me:getPetInfo(petId)

	if petInfo == nil then
		return nil
	end

	local propLevels = pg.game.petManage:getPetPropLevels(petInfo)

	if not propLevels then
		return nil
	end

	local attributeMap = PetAttributeCalcUtils.getAttributeMapByPetInfo(pg.me, petInfo)
	local snapshot = {}

	for index, propInfo in pairs(propLevels) do
		local attrId = PetManagementDataHelper.CUR_PROP[index]
		local attributeTotal

		if attrId ~= nil then
			attributeTotal = attributeMap[attrId]
		end

		if attributeTotal == nil then
			attributeTotal = propInfo.propDisplayVal
		end

		snapshot[index] = {
			complexBaseLv = propInfo.complexBaseLv,
			baseAndActiveTotalLv = propInfo.baseAndActiveTotalLv,
			total = propInfo.total,
			attributeTotal = attributeTotal,
			propDisplayVal = propInfo.propDisplayVal,
			isMax = propInfo.isMax == true,
			l18nNameKey = propInfo.l18nNameKey
		}
	end

	return snapshot
end

function PetSocialBehaviorComponent:_snapshotMyPetProps(pets)
	local myPet = self:splitMyAndOtherPet(pets)

	if myPet == nil then
		return nil, nil, nil
	end

	return myPet.id, self:safePetName(myPet), self:snapshotPropLevels(myPet.id)
end

function PetSocialBehaviorComponent:_tryAttachCocktailInvite(pets)
	if self._cocktailInviteBubble == nil then
		self._cocktailInviteBubble = CocktailInviteBubble.new()

		self._cocktailInviteBubble:resetData()
	end

	local myPet, _, otherMaster = self:splitMyAndOtherPet(pets)

	if myPet == nil or otherMaster == nil then
		return
	end

	self._cocktailInviteBubble:tryAttach(otherMaster)
end

function PetSocialBehaviorComponent:_showCafePetNoticeWithArgs(noticeId, args)
	local msgData = SysNoticeData[noticeId]

	if msgData == nil then
		return false
	end

	local template = pg.getLocalizationText(msgData.text)

	if template == nil or template == "" then
		return false
	end

	local textArgs = {}

	if Utils.isTable(args) then
		for i, value in ipairs(args) do
			textArgs[i] = pg.getLocalizationText(value)
		end
	end

	local argIndex = 1
	local hasPlaceholder = false
	local text = string.gsub(template, "{%d+}", function(placeholder)
		hasPlaceholder = true

		local value = textArgs[argIndex]

		argIndex = argIndex + 1

		if value == nil then
			return placeholder
		end

		return value
	end)

	if hasPlaceholder ~= true then
		text = template
	end

	pg.global.ui.tips:showTextTip(text, msgData.stay, msgData.tipStyle, nil, nil, nil, nil, nil, msgData.delete)

	return true
end

function PetSocialBehaviorComponent:tryShowCafePetNotice(noticeId, noticeArgs)
	if self:isCafePetNotice(noticeId) ~= true then
		return false
	end

	if self:isCafePetIvNotice(noticeId) == true then
		self:onCafePetIvUpNotice(noticeId, noticeArgs)
	end

	local args = self:collectCafePetNoticeArgs(noticeArgs)

	if #args == 0 or args[1] == "" then
		return true
	end

	return self:_showCafePetNoticeWithArgs(noticeId, args)
end

PetSocialBehaviorComponent.COIN_DROP_EFFECT_KEY = "SOCIAL_PARTY_PET_GET_ITEM"
PetSocialBehaviorComponent.IV_UP_EFFECT_KEY = "SOCIAL_PARTY_PET_IMPROVE"

function PetSocialBehaviorComponent:_playCoinDropEffect(pet)
	if pet == nil then
		return
	end

	pet:playEffect(PetSocialBehaviorComponent.COIN_DROP_EFFECT_KEY)
end

function PetSocialBehaviorComponent:_playIvUpEffect(pet)
	if pet == nil then
		return
	end

	pet:playEffect(PetSocialBehaviorComponent.IV_UP_EFFECT_KEY)
end

function PetSocialBehaviorComponent:_getLatestDropContext()
	if self._interactCtxByGroupKey == nil then
		return nil
	end

	local now = os.time()
	local bestCtx

	for groupKey, ctx in pairs(self._interactCtxByGroupKey) do
		local expireSec = ctx.expireSec or 0

		if expireSec < now then
			self._interactCtxByGroupKey[groupKey] = nil
		elseif bestCtx == nil or (ctx.startSec or 0) > (bestCtx.startSec or 0) then
			bestCtx = ctx
		end
	end

	return bestCtx
end

function PetSocialBehaviorComponent:_getLatestIvUpContext()
	if self._interactCtxByGroupKey == nil then
		return nil
	end

	local now = os.time()
	local bestCtx

	for groupKey, ctx in pairs(self._interactCtxByGroupKey) do
		local expireSec = ctx.expireSec or 0

		if expireSec < now then
			self._interactCtxByGroupKey[groupKey] = nil
		elseif ctx.myPetId ~= nil and (bestCtx == nil or (ctx.startSec or 0) > (bestCtx.startSec or 0)) then
			bestCtx = ctx
		end
	end

	return bestCtx
end

function PetSocialBehaviorComponent:onCafePetIvUpNotice(noticeId, noticeArgs)
	if self:_isInGuardScene() ~= true then
		return
	end

	if self._petPeekTag == nil then
		self._petPeekTag = PetPeekTag.new()

		self._petPeekTag:resetData()
	end

	local ctx = self:_getLatestIvUpContext()
	local petEntityId = ctx ~= nil and ctx.myPetId or nil
	local petName = ctx ~= nil and ctx.myPetName or nil
	local beforePropLevels = ctx ~= nil and ctx.beforePropLevels or nil

	if petEntityId == nil then
		local myPet = pg.me and pg.me:getCurPetEntity()

		if myPet ~= nil then
			petEntityId = myPet.id
			petName = self:safePetName(myPet)
		end
	end

	if (petName == nil or petName == "") and Utils.isTable(noticeArgs) then
		petName = tostring(noticeArgs[1] or "")
	end

	if petEntityId == nil then
		return
	end

	local pet = pg.getEntity(petEntityId)

	if pet == nil then
		pet = pg.me and pg.me:getCurPetEntity()
	end

	self:_playIvUpEffect(pet)

	for i, value in ipairs(noticeArgs) do
		noticeArgs[i] = pg.getLocalizationText(value)
	end

	local argIndex = 1
	local ivUpNoticeText = string.gsub(pg.getLocalizationText(SysNoticeData[noticeId].text), "{%d+}", function(placeholder)
		local value = noticeArgs[argIndex]

		argIndex = argIndex + 1

		return value or placeholder
	end)

	self._petPeekTag:attach(petEntityId, petName, {
		beforePropLevels = beforePropLevels,
		ivUpNoticeText = ivUpNoticeText
	})
end

function PetSocialBehaviorComponent:debugSimulateCafePetIvUp(params)
	params = params or {}

	if self._petPeekTag == nil then
		self._petPeekTag = PetPeekTag.new()

		self._petPeekTag:resetData()
	end

	local petEntityId = params.petEntityId
	local pet = petEntityId ~= nil and pg.getEntity(petEntityId) or nil

	if pet == nil then
		pet = pg.me and pg.me:getCurPetEntity()
	end

	if pet == nil or pet.id == nil then
		return false, "no current pet entity"
	end

	local beforePropLevels = self:snapshotPropLevels(pet.id)
	local propIndex = tonumber(params.propIndex) or Const.BASE_PROPERTY_HP_IDX
	local addValue = tonumber(params.addValue) or 1

	if addValue <= 0 then
		addValue = 1
	end

	if beforePropLevels ~= nil and beforePropLevels[propIndex] ~= nil then
		local propInfo = beforePropLevels[propIndex]
		local attributeTotal = tonumber(propInfo.attributeTotal or propInfo.propDisplayVal)

		if attributeTotal ~= nil then
			local oldAttributeTotal = math.max(0, attributeTotal - addValue)

			propInfo.attributeTotal = oldAttributeTotal
			propInfo.propDisplayVal = oldAttributeTotal
		end
	end

	local petName = self:safePetName(pet)

	self:_playIvUpEffect(pet)
	self._petPeekTag:attach(pet.id, petName, {
		beforePropLevels = beforePropLevels,
		ivUpNoticeText = pg.getLocalizationText(SysNoticeData[NoticeDef.SOCIAL_PARTY_SNUGGLE_PET_PROP].text)
	})

	if params.openNow == true then
		self._petPeekTag:openPendingIvUpDialog(pet.id)
	end

	return true, {
		petEntityId = pet.id,
		petName = petName,
		propIndex = propIndex,
		addValue = addValue,
		openNow = params.openNow == true
	}
end

function PetSocialBehaviorComponent:onCafePetCoinDrop(coinNum)
	coinNum = tonumber(coinNum)

	if coinNum == nil or coinNum <= 0 then
		return
	end

	local ctx = self:_getLatestDropContext()

	if ctx == nil then
		self:_playCoinDropEffect(pg.me and pg.me:getCurPetEntity())

		return
	end

	for _, petId in ipairs(ctx.petIds or EMPTY_TABLE) do
		local pet = pg.getEntity(petId)

		if pet ~= nil then
			self:_playCoinDropEffect(pet)
		end
	end
end

PetSocialBehaviorComponent.SNUGGLE_ANIM_KEYS = {
	"Behav_LoveStart",
	"Behav_LoveLoop",
	"Behav_LoveEnd"
}
PetSocialBehaviorComponent.FOLLOW_ANIM_KEYS = {
	"Behav_HappyStart",
	"Behav_HappyLoop",
	"Behav_HappyEnd"
}

function PetSocialBehaviorComponent:buildPerformAnimCfg(keys, durationSec)
	return {
		keys[1],
		keys[2],
		keys[3],
		{
			false,
			durationSec
		}
	}
end

PetSocialBehaviorComponent.SNUGGLE_MATCH_EMOJI = "Kiss"
PetSocialBehaviorComponent.SNUGGLE_MISMATCH_EMOJIS = {
	"Happy",
	"Laugh",
	"Shy",
	"Surprise",
	"Halo"
}
PetSocialBehaviorComponent.FOLLOW_EMOJI = "Laugh"

function PetSocialBehaviorComponent:pickSnuggleEmoji(petA, petB)
	if petA == nil or petB == nil then
		return PetSocialBehaviorComponent.SNUGGLE_MATCH_EMOJI
	end

	local pdA = PetData[petA.templateId]
	local pdB = PetData[petB.templateId]

	if pdA == nil or pdB == nil then
		return PetSocialBehaviorComponent.SNUGGLE_MATCH_EMOJI
	end

	local matched = pdA.elementType ~= nil and pdA.elementType == pdB.elementType or pdA.ethnicGroup ~= nil and pdA.ethnicGroup == pdB.ethnicGroup

	if matched then
		return PetSocialBehaviorComponent.SNUGGLE_MATCH_EMOJI
	end

	return PetSocialBehaviorComponent.SNUGGLE_MISMATCH_EMOJIS[math.random(1, #PetSocialBehaviorComponent.SNUGGLE_MISMATCH_EMOJIS)]
end

function PetSocialBehaviorComponent:tryPlayCfgAnim(pet, cfg)
	if pet == nil or cfg == nil then
		return
	end

	pet:playCfgAnimation(cfg, PlayableConst.AnimationLayer.HUMAN_LAYER_BASE)
end

function PetSocialBehaviorComponent:tryShowEmojiBubble(pet, emojiName, duration)
	if pet == nil or emojiName == nil or emojiName == "" then
		return
	end

	if pet.eventEmitter == nil then
		return
	end

	pet.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, true, emojiName, duration or 5)
end

function PetSocialBehaviorComponent:tryForcePetPos(pet, target)
	if pet == nil or target == nil then
		return
	end

	pet:forceSetPos(target, true)
	pet:onSyncPos(target.x, target.y, target.z)
end

function PetSocialBehaviorComponent:tryGatherTo(pet, headPet, anchorPos, idx, callback)
	if pet == nil or anchorPos == nil then
		callback()

		return
	end

	if Vector3 == nil then
		callback()

		return
	end

	local angle = (idx - 0.5) * (math.pi * 2 / 4)
	local targetRadius = (headPet.eModel and headPet.eModel.radius or 1) + (pet.eModel and pet.eModel.radius or 1) + 1
	local dx = math.cos(angle) * targetRadius
	local dz = math.sin(angle) * targetRadius
	local target = Vector3.New(anchorPos.x + dx, anchorPos.y, anchorPos.z + dz)

	if AutoPathFindUtils.findPathToPos(pet, target.x, target.y, target.z, nil, AutoPathFindUtils.PathFindType.Voxel) and pet:pawnAutoPathFinding(target, function()
		callback()
	end, AutoPathFindUtils.PathFindType.Voxel) then
		AutoPathFindUtils.setTempSpeed(pet, AIControllerUtils.getRunSpeed(pet) * SocialConst.PET_INTERACT_GATHER_SPEED_RATE)

		return
	end

	self:tryForcePetPos(pet, target)
	callback()
end

function PetSocialBehaviorComponent:_applyBehaviorPose(behaviorType, pets)
	if #pets < 2 then
		return
	end

	local head = pets[1]
	local emojiDurationSec = self:getPetInteractPerformSec()
	local snuggleAnimCfg = self:buildPerformAnimCfg(PetSocialBehaviorComponent.SNUGGLE_ANIM_KEYS, emojiDurationSec)
	local followAnimCfg = self:buildPerformAnimCfg(PetSocialBehaviorComponent.FOLLOW_ANIM_KEYS, emojiDurationSec)
	local anchorPos

	anchorPos = head:getPosition()

	if behaviorType == Const.BehaviorType.SNUGGLE then
		self:tryGatherTo(pets[2], head, anchorPos, 1, function()
			head:faceToEnt(pets[2], true)
			pets[2]:faceToEnt(head, true)
			self:tryPlayCfgAnim(head, snuggleAnimCfg)
			self:tryPlayCfgAnim(pets[2], snuggleAnimCfg)

			local snuggleEmoji = self:pickSnuggleEmoji(head, pets[2])

			self:tryShowEmojiBubble(head, snuggleEmoji, emojiDurationSec)
			self:tryShowEmojiBubble(pets[2], snuggleEmoji, emojiDurationSec)
		end)
	else
		local waitCount = #pets - 1

		for i = 2, #pets do
			local p = pets[i]

			self:tryGatherTo(p, head, anchorPos, i, function()
				waitCount = waitCount - 1

				if waitCount > 0 then
					return
				end

				self:tryPlayCfgAnim(head, followAnimCfg)
				self:tryShowEmojiBubble(head, PetSocialBehaviorComponent.FOLLOW_EMOJI, emojiDurationSec)

				for j = 2, #pets do
					local memberPet = pets[j]

					memberPet:faceToEnt(head, true)
					self:tryPlayCfgAnim(memberPet, followAnimCfg)
					self:tryShowEmojiBubble(memberPet, PetSocialBehaviorComponent.FOLLOW_EMOJI, emojiDurationSec)
				end
			end)
		end
	end
end

function PetSocialBehaviorComponent:_clearPerform(groupKey)
	local perform = self._activePerforms[groupKey]

	if perform == nil then
		return
	end

	if perform.timerId ~= nil then
		TimerManager.removeTimer(perform.timerId)
	end

	self:_stopPetAiTrace(groupKey, perform.traceInfo)
	self:_resumePausedPets(perform.pausedPetIds)

	self._activePerforms[groupKey] = nil

	if self._interactCtxByGroupKey ~= nil then
		self._interactCtxByGroupKey[groupKey] = nil
	end
end

function PetSocialBehaviorComponent:_resumePausedPets(pausedPetIds)
	if Utils.isTable(pausedPetIds) ~= true then
		return
	end

	for _, petId in ipairs(pausedPetIds) do
		local pet = pg.getEntity(petId)

		if pet ~= nil then
			pet:stopAllAnimation()
			pet:resumeBt(AiConst.PauseBtReason.PetCafeInteract)
		end
	end
end

function PetSocialBehaviorComponent:isMyPetInteracting()
	if self._activePerforms == nil or self._interactCtxByGroupKey == nil then
		return false
	end

	for groupKey, _ in pairs(self._activePerforms) do
		local ctx = self._interactCtxByGroupKey[groupKey]

		if ctx ~= nil and ctx.myPetId ~= nil then
			return true
		end
	end

	return false
end

function PetSocialBehaviorComponent:abortAllPerforms()
	if self._activePerforms == nil then
		return
	end

	local hadAny = false

	for groupKey, _ in pairs(self._activePerforms) do
		hadAny = true

		self:_clearPerform(groupKey)
	end

	self._activePerforms = {}
	self._interactCtxByGroupKey = {}

	self:_clearPetAiHudTrace()

	if self._petPeekTag ~= nil then
		self._petPeekTag:resetData()
	end

	if self._cocktailInviteBubble ~= nil then
		self._cocktailInviteBubble:resetData()
	end

	if hadAny then
		pg.game.social:setInPetInteractMode(false)
	end
end

function PetSocialBehaviorComponent:_finishPerform(groupKey)
	local perform = self._activePerforms[groupKey]

	if perform == nil then
		return
	end

	perform.timerId = nil

	self:_stopPetAiTrace(groupKey, perform.traceInfo)
	self:_resumePausedPets(perform.pausedPetIds)

	self._activePerforms[groupKey] = nil

	self:_retainRewardContext(groupKey)

	if next(self._activePerforms) == nil then
		pg.game.social:setInPetInteractMode(false)
	end
end

function PetSocialBehaviorComponent:destroy()
	if self._activePerforms ~= nil then
		for groupKey, _ in pairs(self._activePerforms) do
			self:_clearPerform(groupKey)
		end

		self._activePerforms = {}
	end

	self._interactCtxByGroupKey = {}

	self:_clearPetAiHudTrace()

	if self._petPeekTag ~= nil then
		self._petPeekTag:destroy()

		self._petPeekTag = nil
	end

	if self._cocktailInviteBubble ~= nil then
		self._cocktailInviteBubble:destroy()

		self._cocktailInviteBubble = nil
	end

	self:_setInteractMode(false)
end

return PetSocialBehaviorComponent
