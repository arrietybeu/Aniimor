-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DamageNumber\\DamageNumberCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AbilityConst = require("Common.Const.AbilityConst")
local Mathf = require("Common.Math.Mathf")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local UICtrl = require("Guis.UICtrl")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local AttributeConst = require("Common.Const.AttributeConst")
local EventConst = require("Const.EventConst")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local logger = LoggerManager.getLogger("DamageNumberCtrl")
local CombatDamageNumberData = require("Data.combat_damage_number_data")
local DamageNumberCtrl = Class.LightClass("DamageNumberCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LIMIT_EQUAL_BORN_TIME_MS = 500
local HEAL_STACK_STEP = 0.4
local HEAL_STACK_MAX = 4
local NUMBER_JUMP_PER_FRAME = 2
local NUMBER_JUMP_QUEUE_MAX = 16
local RAND_OFFSET_STEPS = {
	-3,
	-2,
	2,
	3
}

local function getCachedRefs(self, item)
	local cache = self.m_itemRefsCache[item]

	if not cache then
		cache = {
			objectReference = item:GetComponent("ObjectReference"),
			pageCache = {}
		}
		self.m_itemRefsCache[item] = cache
	end

	return cache
end

local function getRef(refs, name)
	local v = refs[name]

	if v == nil then
		v = refs.objectReference:GetRefValue(name)
		refs[name] = v
	end

	return v
end

local function tryChangePage(refs, rootUComponent, pageName, pageIndex)
	local pageCache = refs.pageCache

	if pageCache[pageName] ~= pageIndex then
		rootUComponent:TryChangePage(pageName, pageIndex)

		pageCache[pageName] = pageIndex
	end
end

DamageNumberCtrl.messages = {
	[MessageName.SHOW_DAMAGE_NUMBER] = {
		"onShowDamageNumber",
		true
	},
	[MessageName.SHOW_ENERGY_NUMBER] = {
		"onShowEnergyNumber",
		true
	},
	[MessageName.SHOW_BREAK_NUMBER] = {
		"onShowBreakNumber",
		true
	},
	[MessageName.ON_ENTITY_DESTROY] = {
		"onDestroyEntity",
		true
	},
	[MessageName.SHOW_BOSS_CATCH_NUMBER] = {
		"onShowBossCatchNumber",
		true
	}
}

function DamageNumberCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.lastAttackInfo = {}
	self.lastBornPos = {}
	self.lastDisappearPos = {}
	self.lastRandEntOffsetResTimeMap = {}
	self.m_itemRefsCache = {}
	self.m_numberQueue = {}
	self.m_numberQueueHead = 1
	self.m_numberQueueTail = 0
	self.m_numberFrameCbId = nil
	self.m_numberFrameStamp = -1
	self.m_numberFrameConsumed = 0
	self.m_healStackCountMap = {}

	self:refreshLocalizationTextCache()

	function self.m_onLanguageChanged()
		self:refreshLocalizationTextCache()
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_LANGUAGE_CHANGED, self.m_onLanguageChanged)
end

function DamageNumberCtrl:onDestroy()
	if self.m_onLanguageChanged then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_LANGUAGE_CHANGED, self.m_onLanguageChanged)

		self.m_onLanguageChanged = nil
	end

	self:m_stopNumberJumpConsume()

	self.m_numberQueue = nil

	UICtrl.onDestroy(self)
end

function DamageNumberCtrl:refreshLocalizationTextCache()
	self.m_breakText = pg.getGameString("ATTRIBUTE_NAT")
	self.m_bossCatchText = pg.getGameString("FC_CRIT_TEXT")
end

function DamageNumberCtrl:onShowDamageNumber(body)
	if not self:checkBodyValidity(body) then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("DamageNumberCtrl>> body invalid")
		end

		return
	end

	local attackActorId = body.attackActorId
	local sourceEntity = pg.getEntityByActorId(attackActorId)
	local targetEntity = pg.getEntityByActorId(body.targetActorId)
	local damageUITags = body.damageUITags
	local targetEntityEModel = targetEntity.eModel
	local _tpx, _tpy, _tpz = targetEntityEModel:GetPositionAgentPosEx()
	local isDot = false
	local isFromRogueEquip = false
	local isPowerfulStrike = false

	for _, tag in pairs(damageUITags) do
		if tag == UIConst.DAMAGE_UI_TYPE_DESC.DOT_DISPLAY then
			isDot = true
		elseif tag == UIConst.DAMAGE_UI_TYPE_DESC.FROM_EQUIPMENT then
			isFromRogueEquip = true
		elseif tag == UIConst.DAMAGE_UI_TYPE_DESC.POWERFUL_STRIKE then
			isPowerfulStrike = true
		end
	end

	local damageInfo = body

	damageInfo.sourceId = sourceEntity and sourceEntity.id
	damageInfo.targetId = targetEntity.id
	damageInfo.targetHitPos = Vector3.New(_tpx, _tpy + 0.5 * targetEntityEModel.height, _tpz)

	local isTargetEntityBreak = targetEntity.inBreak and targetEntity:inBreak() or targetEntity.inBreakRecover and targetEntity:inBreakRecover()

	damageInfo.isBreakEnhance = isTargetEntityBreak
	damageInfo.isCritical = body.attackResultType == AbilityConst.ATTACK_RESULT_CRITICAL
	damageInfo.attackSpaceType = body.spaceInfo.type
	damageInfo.isAttackSpaceHeavy = body.spaceInfo.isAdvantage
	damageInfo.isPlayerBeAttacked = targetEntity == pg.me or pg.me.pets[targetEntity.id] ~= nil or body.isAttackSelfControlEgg
	damageInfo.isDot = isDot
	damageInfo.isFromRogueEquip = isFromRogueEquip
	damageInfo.isPowerfulStrike = isPowerfulStrike

	local numberResID = self:getNumberWordResID(damageInfo)

	if numberResID == nil then
		return
	end

	damageInfo.assetResID = numberResID

	if body.attackResultType == AbilityConst.ATTACK_RESULT_MISS then
		damageInfo.statusIndex = self.model.DAMAGE_STATUS_IDX.MISS

		self:showStatusJumpWord(damageInfo)
	elseif body.attackResultType == AbilityConst.ATTACK_RESULT_IMMUNE then
		damageInfo.statusIndex = self.model.DAMAGE_STATUS_IDX.IMMUNE

		self:showStatusJumpWord(damageInfo)
	elseif body.attackResultType == AbilityConst.ATTACK_RESULT_KILL_THRESHOLD then
		self:showExecuteJumpWord(damageInfo)
	else
		self:m_enqueueNumberJump(damageInfo)
	end
end

function DamageNumberCtrl:onShowEnergyNumber(body)
	if not self:checkBodyValidity(body) then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("DamageNumberCtrl>> body invalid")
		end

		return
	end

	local data = {
		targetId = body.targetId,
		value = body.value,
		assetResID = self.model.RES_EP_CONFIG_ID,
		resType = UIConst.DAMAGE_NUMBER_TYPE.NUMBER_EP
	}

	self:showEnergyJumpWord(data)
end

function DamageNumberCtrl:onShowBreakNumber(body)
	if not self:checkBodyValidity(body) then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("DamageNumberCtrl>> body invalid")
		end

		return
	end

	local target = pg.getEntityByActorId(body.targetActorId) or {}
	local num = Mathf.Ceil(body.value)
	local data = {
		targetId = target.id,
		value = num,
		assetResID = self.model.RES_BP_CONFIG_ID,
		resType = UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL_BREAK
	}

	self:showBreakJumpWord(data)
end

function DamageNumberCtrl:onShowBossCatchNumber(body)
	if not self:checkBodyValidity(body) then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("DamageNumberCtrl>> body invalid")
		end

		return
	end

	local target = pg.getEntityByActorId(body.targetActorId)

	if not target then
		return
	end

	local bossCatchResID = self:getBossCatchWordResID(body.resType)

	if bossCatchResID == nil then
		return
	end

	local num = Mathf.Ceil(body.value)
	local data = {
		sourceId = pg.me and pg.me.id,
		targetId = target.id,
		value = num,
		assetResID = bossCatchResID,
		resType = body.resType
	}

	self:showBossCatchJumpWord(data)
end

function DamageNumberCtrl:checkBodyValidity(body)
	if not body then
		return false
	end

	local player = pg.me

	if not player then
		return false
	end

	if player:isControllingEgg() then
		local eggEnt = player:getCurControllingEgg()

		if eggEnt then
			if body.targetActorId == player.actorId then
				body.targetActorId = eggEnt.actorId
				body.isAttackSelfControlEgg = true

				return true
			else
				local playerPet = player.petPrepareList[1] and pg.getEntity(player.petPrepareList[1])

				if playerPet and playerPet.actorId == body.targetActorId then
					body.targetActorId = eggEnt.actorId
					body.isAttackSelfControlEgg = true

					return true
				end
			end
		end

		return false
	end

	local target = pg.getEntityByActorId(body.targetActorId)

	if not target then
		return false
	end

	if Utils.isPlayerPet(target) or Utils.isPlayer(target) then
		local targetPlayer = Utils.getMasterPlayer(target)

		if targetPlayer and targetPlayer:isControllingEgg() then
			local targetEggEnt = targetPlayer:getCurControllingEgg()

			if targetEggEnt then
				body.targetActorId = targetEggEnt.actorId
				target = targetEggEnt
			end
		end
	end

	if not target.eModel then
		return false
	end

	local modelView = target.eModel.modelModelView

	if not modelView or not modelView:GetModelVisible() then
		return false
	end

	return true
end

function DamageNumberCtrl:showStatusJumpWord(info)
	info.resType = UIConst.DAMAGE_NUMBER_TYPE.STATUS

	self.view:getObjFromPool(info.resType, function(item)
		if not item then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("DamageNumberCtrl>> showStatusJumpWord item Err")
			end

			return
		end

		if info.targetId and IsNil(pg.getEntity(info.targetId)) then
			self.view:returnObjToPool(info.resType, item)

			return
		end

		local damageItemScript = item:GetComponent("DamageJumpWord")

		damageItemScript:SetSourceAndTargetById(info.sourceId, info.targetId)

		if info.targetHitPos then
			self:m_SetRandEntityOffset(info, damageItemScript)
		end

		local enableScaleByDistance = not info.isToPlayer and not info.isToPet

		self:initJumpWordAndMove(damageItemScript, info, enableScaleByDistance, function()
			local refs = getCachedRefs(self, item)
			local rootUComponent = getRef(refs, "rootUComponent")
			local panelAnimation = getRef(refs, "panelAnimation")

			if info.isPlayerBeAttacked then
				tryChangePage(refs, rootUComponent, "Type", 0)
			else
				tryChangePage(refs, rootUComponent, "Type", 1)
			end

			panelAnimation:Play(self.model.VX_NUM_IMMUNE_IN_ANIM)
		end, item)
	end)
end

function DamageNumberCtrl:showNumberJumpWord(info)
	local resType

	if info.hurtType == AbilityConst.HURT_TYPE_HP_ADD then
		resType = UIConst.DAMAGE_NUMBER_TYPE.NUMBER_RECOVER
	elseif info.damageShowEnum == Const.DAMAGE_SHOW_ENUM_WEAK then
		if info.isPowerfulStrike then
			resType = UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW_POWERFUL
		elseif info.isBreakEnhance then
			resType = UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW_BREAK
		else
			resType = UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW
		end
	elseif info.damageShowEnum == Const.DAMAGE_SHOW_ENUM_EXCELLENT then
		if info.isPowerfulStrike then
			resType = UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH_POWERFUL
		elseif info.isBreakEnhance then
			resType = UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH_BREAK
		else
			resType = UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH
		end
	elseif info.isPowerfulStrike then
		resType = UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL_POWERFUL
	elseif info.isBreakEnhance then
		resType = UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL_BREAK
	else
		resType = UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL
	end

	info.resType = resType

	self.view:getObjFromPool(info.resType, function(item)
		if not item then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("DamageNumberCtrl>> showNumberJumpWord item Err", info.resType)
			end

			return
		end

		if info.targetId and IsNil(pg.getEntity(info.targetId)) then
			self.view:returnObjToPool(info.resType, item)

			return
		end

		local damageItemScript = item:GetComponent("DamageJumpWord")
		local enableScaleByDistance = not info.isToPlayer and not info.isToPet
		local value = ClientAbilityUtils.getAttributeStr(AttributeConst.hp_cur, info.damageValue)

		self:startPlayJumpDamageNumber(info, enableScaleByDistance, value, damageItemScript, item, true, function()
			if info.hurtType == AbilityConst.HURT_TYPE_HP_ADD then
				self:refreshNumberRecover(item, info, value)
			elseif info.isPowerfulStrike then
				self:refreshNumberPowerful(item, info, value)
			elseif info.isBreakEnhance then
				self:refreshNumberBreak(item, info, value)
			else
				self:refreshNumber(item, info, value)
			end
		end)
	end)
end

function DamageNumberCtrl:m_acquireFrameQuota()
	local frame = Time.frameCount

	if self.m_numberFrameStamp ~= frame then
		self.m_numberFrameStamp = frame
		self.m_numberFrameConsumed = 0
	end

	if self.m_numberFrameConsumed < NUMBER_JUMP_PER_FRAME then
		self.m_numberFrameConsumed = self.m_numberFrameConsumed + 1

		return true
	end

	return false
end

function DamageNumberCtrl:m_enqueueNumberJump(damageInfo)
	if self.m_numberQueueHead > self.m_numberQueueTail and self:m_acquireFrameQuota() then
		self:showNumberJumpWord(damageInfo)

		return
	end

	local tail = self.m_numberQueueTail + 1

	self.m_numberQueue[tail] = damageInfo
	self.m_numberQueueTail = tail

	local len = self.m_numberQueueTail - self.m_numberQueueHead + 1

	if len > NUMBER_JUMP_QUEUE_MAX then
		local drop = len - NUMBER_JUMP_QUEUE_MAX

		for i = self.m_numberQueueHead, self.m_numberQueueHead + drop - 1 do
			self.m_numberQueue[i] = nil
		end

		self.m_numberQueueHead = self.m_numberQueueHead + drop
	end

	if not self.m_numberFrameCbId then
		self.m_numberFrameCbId = TimerManager.addRepeatNextFrameCb(function()
			self:m_consumeNumberJump()
		end)
	end
end

function DamageNumberCtrl:m_consumeNumberJump()
	local queue = self.m_numberQueue

	if not queue then
		return
	end

	while self.m_numberQueueHead <= self.m_numberQueueTail do
		local head = self.m_numberQueueHead
		local info = queue[head]

		if not info or not pg.getEntity(info.targetId) then
			queue[head] = nil
			self.m_numberQueueHead = head + 1
		elseif self:m_acquireFrameQuota() then
			queue[head] = nil
			self.m_numberQueueHead = head + 1

			self:showNumberJumpWord(info)
		else
			break
		end
	end

	if self.m_numberQueueHead > self.m_numberQueueTail then
		self.m_numberQueueHead = 1
		self.m_numberQueueTail = 0

		self:m_stopNumberJumpConsume()
	end
end

function DamageNumberCtrl:m_stopNumberJumpConsume()
	if self.m_numberFrameCbId then
		TimerManager.delFrameCb(self.m_numberFrameCbId)

		self.m_numberFrameCbId = nil
	end
end

function DamageNumberCtrl:showEnergyJumpWord(info)
	self.view:getObjFromPool(info.resType, function(item)
		if not item then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("DamageNumberCtrl>> showEnergyJumpWord item Err")
			end

			return
		end

		if info.targetId and IsNil(pg.getEntity(info.targetId)) then
			self.view:returnObjToPool(info.resType, item)

			return
		end

		local damageItemScript = item:GetComponent("DamageJumpWord")

		info.isEpRecover = true

		self:startPlayJumpDamageNumber(info, false, info.value, damageItemScript, item, nil, function()
			self:refreshNumberRecover(item, info, info.value)
		end)
	end)
end

function DamageNumberCtrl:showBreakJumpWord(info)
	self.view:getObjFromPool(info.resType, function(item)
		if not item then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("DamageNumberCtrl>> showBreakJumpWord item Err")
			end

			return
		end

		if info.targetId and IsNil(pg.getEntity(info.targetId)) then
			self.view:returnObjToPool(info.resType, item)

			return
		end

		local damageItemScript = item:GetComponent("DamageJumpWord")
		local enableScaleByDistance = not info.isToPlayer and not info.isToPet

		info.isBpAtk = true

		self:startPlayJumpDamageNumber(info, enableScaleByDistance, info.value, damageItemScript, item, nil, function()
			self:refreshNumberBreak(item, info, info.value)
		end)
	end)
end

function DamageNumberCtrl:showBossCatchJumpWord(info)
	self.view:getObjFromPool(info.resType, function(item)
		if not item then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("DamageNumberCtrl>> showBossCatchJumpWord item Err")
			end

			return
		end

		if info.targetId and IsNil(pg.getEntity(info.targetId)) then
			self.view:returnObjToPool(info.resType, item)

			return
		end

		local damageItemScript = item:GetComponent("DamageJumpWord")
		local enableScaleByDistance = not info.isToPlayer and not info.isToPet

		self:startPlayJumpDamageNumber(info, enableScaleByDistance, info.value, damageItemScript, item, nil, function()
			self:refreshNumberBossCatch(item, info, info.value)
		end)
	end)
end

function DamageNumberCtrl:showExecuteJumpWord(info)
	info.resType = UIConst.DAMAGE_NUMBER_TYPE.EXECUTE

	self.view:getObjFromPool(info.resType, function(item)
		if not item then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("DamageNumberCtrl>> showExecuteJumpWord item Err")
			end

			return
		end

		if info.targetId and IsNil(pg.getEntity(info.targetId)) then
			self.view:returnObjToPool(info.resType, item)

			return
		end

		local damageItemScript = item:GetComponent("DamageJumpWord")

		damageItemScript:SetSourceAndTargetById(info.sourceId, info.targetId)

		if info.targetHitPos then
			self:m_SetRandEntityOffset(info, damageItemScript)
		end

		self:initJumpWordAndMove(damageItemScript, info, false, function()
			local refs = getCachedRefs(self, item)
			local panelAnimation = getRef(refs, "panelAnimation")

			panelAnimation:Play(self.model.VX_NUM_EXECUTE_IN_ANIM)
		end, item)
	end)
end

function DamageNumberCtrl:isDamageSelf(damageInfo)
	if damageInfo.isAttackSelfControlEgg then
		return true
	end

	if not pg.me then
		return false
	end

	local isSelf = pg.me.id == damageInfo.targetId
	local isSelfPet = pg.me.pets and pg.me.pets[damageInfo.targetId]

	return isSelf or isSelfPet
end

function DamageNumberCtrl:refreshNumber(item, damageInfo, value)
	local refs = getCachedRefs(self, item)
	local rootUComponent = getRef(refs, "rootUComponent")
	local numTextRefVal = getRef(refs, "numTextPlus")
	local animationRefVal = getRef(refs, "animation")

	if numTextRefVal then
		ClientTextUtils.setText(numTextRefVal, value)
	end

	tryChangePage(refs, rootUComponent, "Critical", damageInfo.isCritical and 1 or 0)
	tryChangePage(refs, rootUComponent, "Team", self:isDamageSelf(damageInfo) and 1 or 0)

	local dmgNumAniName = self.model:getFinalDmgAniByDmgType(damageInfo, damageInfo.damageShowEnum)

	if animationRefVal and dmgNumAniName then
		animationRefVal:Play(dmgNumAniName)
	end

	if damageInfo.damageShowEnum == Const.DAMAGE_SHOW_ENUM_EXCELLENT then
		local attackSpaceType = damageInfo.attackSpaceType
		local isAttackSpaceHeavy = damageInfo.isAttackSpaceHeavy

		if attackSpaceType == AbilityConst.ATTACK_SPACE_TYPE.IN_AIR and isAttackSpaceHeavy then
			tryChangePage(refs, rootUComponent, "ResType", "Wind")
		elseif attackSpaceType == AbilityConst.ATTACK_SPACE_TYPE.UNDER_GROUND and isAttackSpaceHeavy then
			tryChangePage(refs, rootUComponent, "ResType", "Land")
		else
			tryChangePage(refs, rootUComponent, "ResType", "None")
		end
	elseif damageInfo.damageShowEnum == Const.DAMAGE_SHOW_ENUM_NORMAL then
		if damageInfo.isFromRogueEquip then
			tryChangePage(refs, rootUComponent, "NormalType", 1)
		else
			tryChangePage(refs, rootUComponent, "NormalType", 0)
		end
	end

	if damageInfo.damageShowEnum == Const.DAMAGE_SHOW_ENUM_EXCELLENT or damageInfo.damageShowEnum == Const.DAMAGE_SHOW_ENUM_NORMAL then
		tryChangePage(refs, rootUComponent, "HitType", damageInfo.isDot and 1 or 0)
	end
end

function DamageNumberCtrl:refreshNumberBreak(item, damageInfo, value)
	self:refreshNumber(item, damageInfo, value)

	local refs = getCachedRefs(self, item)
	local rootUComponent = getRef(refs, "rootUComponent")
	local numBgTextPlusRefVal = getRef(refs, "numBgTextPlus")
	local textBreakTextPlusRefVal = getRef(refs, "textBreakTextPlus")

	if numBgTextPlusRefVal then
		ClientTextUtils.setText(numBgTextPlusRefVal, value)
	end

	if textBreakTextPlusRefVal then
		ClientTextUtils.setText(textBreakTextPlusRefVal, self.m_breakText)
	end

	if damageInfo.damageShowEnum == Const.DAMAGE_SHOW_ENUM_EXCELLENT then
		local numBg1TextPlusRefVal = getRef(refs, "numBg1TextPlus")

		if numBg1TextPlusRefVal then
			ClientTextUtils.setText(numBg1TextPlusRefVal, value)
		end

		local numAddTextPlusRefVal = getRef(refs, "numAddTextPlus")

		if numAddTextPlusRefVal then
			ClientTextUtils.setText(numAddTextPlusRefVal, value)
		end
	end
end

function DamageNumberCtrl:refreshNumberBossCatch(item, damageInfo, value)
	local refs = getCachedRefs(self, item)
	local tipsUSDFText = getRef(refs, "tipsUSDFText")
	local valueUSDFText = getRef(refs, "valueUSDFText")
	local animation = item:GetComponent("Animation")

	if tipsUSDFText then
		ClientTextUtils.setText(tipsUSDFText, self.m_bossCatchText)
	end

	if valueUSDFText then
		ClientTextUtils.setText(valueUSDFText, value)
	end

	if NotNil(animation) then
		animation:Play()
	end
end

function DamageNumberCtrl:refreshNumberPowerful(item, damageInfo, value)
	self:refreshNumber(item, damageInfo, value)

	local refs = getCachedRefs(self, item)
	local rootUComponent = getRef(refs, "rootUComponent")

	tryChangePage(refs, rootUComponent, "Break", damageInfo.isBpAtk and 1 or 0)

	if damageInfo.isBreakEnhance then
		local textBreakTextPlusRefVal = getRef(refs, "textBreakTextPlus")

		if textBreakTextPlusRefVal then
			ClientTextUtils.setText(textBreakTextPlusRefVal, self.m_breakText)
		end
	end
end

function DamageNumberCtrl:refreshNumberRecover(item, damageInfo, value)
	local refs = getCachedRefs(self, item)
	local rootUComponent = getRef(refs, "rootUComponent")
	local numTextPlus = getRef(refs, "numTextPlus")
	local recoverAnimation = getRef(refs, "recoverAnimation")

	if damageInfo.isEpRecover then
		value = math.ceil(value * 100) / 100
	end

	if numTextPlus then
		ClientTextUtils.setText(numTextPlus, value)
	end

	if recoverAnimation then
		recoverAnimation:Play(self.model.VX_NUM_RECOVER_IN_ANIM)
	end

	tryChangePage(refs, rootUComponent, "HitType", damageInfo.isDot and 1 or 0)
end

function DamageNumberCtrl:initJumpWordAndMove(ctrlScript, info, enableScaleByDistance, extraFunc, item)
	local isLoad = ctrlScript:LoadConfig(info.assetResID)

	self:startTimer(function()
		ctrlScript:StopMoving()
		self.view:returnObjToPool(info.resType, item)
	end, ctrlScript:GetDuration())

	if isLoad then
		local bornPoint = self:generateRandomPoint(ctrlScript, info.assetResID, self.lastBornPos)
		local applyComboOffset, comboCount = self:checkIfApplyComboOffset(ctrlScript, info.assetResID)

		ctrlScript:Init(bornPoint.x, bornPoint.y, applyComboOffset, comboCount, enableScaleByDistance)
		extraFunc()
		ctrlScript:StartMoving()
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(string.format("DamageNumberCtrl>> load asset %s failed", info.assetResID))
		end

		return
	end
end

function DamageNumberCtrl:generateRandomPoint(ctrlScript, assetResID, lastPosTable)
	local lastPos = lastPosTable[assetResID]
	local generateCount = 0
	local point = ctrlScript:GenerateNormalizedRandomPoint()

	if lastPos ~= nil then
		if Mathf.Equal(lastPos.x, point.x) and Mathf.Equal(lastPos.y, point.y) then
			while generateCount < 3 do
				local newPoint = ctrlScript:GenerateNormalizedRandomPoint()

				if Mathf.Equal(lastPos.x, newPoint.x) and Mathf.Equal(lastPos.y, newPoint.y) then
					generateCount = generateCount + 1
				else
					lastPosTable[assetResID] = newPoint

					return newPoint
				end
			end
		end

		lastPosTable[assetResID] = point

		return point
	else
		lastPosTable[assetResID] = point

		return point
	end
end

function DamageNumberCtrl:checkIfApplyComboOffset(ctrlScript, assetResID)
	if ctrlScript:IsEnableCombo() == true then
		local interval = ctrlScript:GetComboInterval()
		local curTime = Time.realSecondCache
		local info = self.lastAttackInfo[assetResID]

		if info ~= nil then
			if curTime > info.lastAttackTime + interval then
				self.lastAttackInfo[assetResID].lastAttackTime = curTime
				self.lastAttackInfo[assetResID].comboCount = 0

				return false, info.comboCount
			else
				self.lastAttackInfo[assetResID].comboCount = info.comboCount + 1

				return true, info.comboCount
			end
		else
			self.lastAttackInfo[assetResID] = {
				comboCount = 0,
				lastAttackTime = curTime
			}

			return false, self.lastAttackInfo[assetResID].comboCount
		end
	else
		return false, 0
	end
end

function DamageNumberCtrl:startPlayJumpDamageNumber(info, enableScaleByDistance, value, damageItemScript, item, isLog, extraFunc)
	damageItemScript:SetSourceAndTargetById(info.sourceId, info.targetId)

	if info.targetHitPos then
		self:m_SetRandEntityOffset(info, damageItemScript, isLog)
	end

	self:initJumpWordAndMove(damageItemScript, info, enableScaleByDistance, extraFunc, item)
end

function DamageNumberCtrl:getNumberWordResID(damageInfo)
	local R = self.model.WORD_RES

	if damageInfo.isPowerfulStrike then
		return R.POWER_BREAK
	end

	if damageInfo.hurtType == AbilityConst.HURT_TYPE_HP_ADD or damageInfo.isDot then
		return R.HEAL
	end

	if damageInfo.isEpRecover then
		return R.ENERGY
	end

	if damageInfo.attackResultType == AbilityConst.ATTACK_RESULT_IMMUNE then
		return R.IMMUNE
	end

	if damageInfo.isCritical then
		return R.CRITICAL
	end

	if damageInfo.attackResultType == AbilityConst.ATTACK_RESULT_KILL_THRESHOLD then
		return R.EXECUTE
	end

	local resID = self.model.BASIC_RES_BY_SHOW_ENUM[damageInfo.damageShowEnum]

	if not resID and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("damageNumberCtrl Err damageShowEnum > %s", damageInfo.damageShowEnum)
	end

	return resID
end

function DamageNumberCtrl:getBossCatchWordResID(resType)
	return resType and self.model.BOSS_CATCH_TYPE_RES_MAP[resType]
end

function DamageNumberCtrl:onDestroyEntity(entityId)
	self:m_clearHealOffsetStateByEntity(entityId)
end

function DamageNumberCtrl:m_clearHealOffsetStateByEntity(entityId)
	if entityId == nil or not Utils.isTable(self.m_healStackCountMap) then
		return
	end

	local suffix = "_" .. tostring(entityId)
	local removeKeys = {}

	for key, _ in pairs(self.m_healStackCountMap) do
		local keyStr = tostring(key)

		if string.sub(keyStr, -#suffix) == suffix then
			removeKeys[#removeKeys + 1] = key
		end
	end

	for _, key in pairs(removeKeys) do
		self.m_healStackCountMap[key] = nil

		if Utils.isTable(self.lastRandEntOffsetResTimeMap) then
			self.lastRandEntOffsetResTimeMap[key] = nil
		end
	end
end

function DamageNumberCtrl:m_SetRandEntityOffset(info, damageItemScript, isLog)
	if not info or not info.targetHitPos then
		return
	end

	if not damageItemScript then
		return
	end

	local posX = info.targetHitPos[1]
	local posY = info.targetHitPos[2]
	local posZ = info.targetHitPos[3]
	local offX = 0
	local offY = 0
	local timeMs = Time.realSecondCache * 1000
	local offsetKey = info.assetResID

	if info.hurtType == AbilityConst.HURT_TYPE_HP_ADD then
		offsetKey = string.format("%s_%s", tostring(info.assetResID), tostring(info.targetId))
	end

	self.lastRandEntOffsetResTimeMap = self.lastRandEntOffsetResTimeMap or {}

	local preBornResTimeMs = offsetKey and self.lastRandEntOffsetResTimeMap[offsetKey] or 0
	local forceRandPos = timeMs and preBornResTimeMs and preBornResTimeMs > 0 and timeMs - preBornResTimeMs <= LIMIT_EQUAL_BORN_TIME_MS

	if offsetKey then
		self.lastRandEntOffsetResTimeMap[offsetKey] = timeMs
	end

	if info.hurtType == AbilityConst.HURT_TYPE_HP_ADD then
		self.m_healStackCountMap = self.m_healStackCountMap or {}

		local healStackCount = offsetKey and (self.m_healStackCountMap[offsetKey] or 0) or 0

		if forceRandPos then
			healStackCount = healStackCount % HEAL_STACK_MAX + 1
			offY = healStackCount * HEAL_STACK_STEP

			if offsetKey then
				self.m_healStackCountMap[offsetKey] = healStackCount
			end

			offX = RAND_OFFSET_STEPS[math.random(1, #RAND_OFFSET_STEPS)] * 0.1
		elseif offsetKey then
			self.m_healStackCountMap[offsetKey] = 0
		end
	elseif forceRandPos then
		self.m_randIndex = (self.m_randIndex or 0) % 4 + 1
		offX = RAND_OFFSET_STEPS[math.random(1, #RAND_OFFSET_STEPS)] * 0.1
		offY = RAND_OFFSET_STEPS[math.random(1, #RAND_OFFSET_STEPS)] * 0.1
	end

	damageItemScript:SetEntityOffset(offX + posX, offY + posY, posZ)
end

return DamageNumberCtrl
