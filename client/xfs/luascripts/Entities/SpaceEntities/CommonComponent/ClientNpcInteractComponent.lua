-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientNpcInteractComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local NpcFuncData = require("Data.npc_func_data")
local InteractData = require("Data.interact_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local logger = LoggerManager.getLogger("ClientNpcInteractComponent")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local InteractionConst = require("Common.Const.InteractionConst")
local EventConst = require("Const.EventConst")
local Utils = require("Common.Utils.Utils")
local HomeEventTextData = require("Data.home_event_text_data")
local HomeEventTypeData = require("Data.home_event_type_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemConst = require("Common.Const.ItemConst")
local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
local Time = require("Core.Common.Time")
local ClientFKeyInteractBase = require("Entities.SpaceEntities.CommonComponent.ClientFKeyInteractBase")
local NpcIdData = require("Data.npc_id_data")
local QuestInteract = require("Entities.SpaceEntities.CommonComponent.NpcInteract.QuestInteract")
local SpecialInteract = require("Entities.SpaceEntities.CommonComponent.NpcInteract.SpecialInteract")
local RandomDialogue = require("Entities.SpaceEntities.CommonComponent.NpcInteract.RandomDialogue")
local SandboxInteract = require("Entities.SpaceEntities.CommonComponent.NpcInteract.SandboxInteract")
local InteractTurn = require("Entities.SpaceEntities.CommonComponent.NpcInteract.InteractTurn")
local PuppetData = require("Data.puppet_data")
local ClientNpcInteractComponent = Class.Component("ClientNpcInteractComponent", ClientFKeyInteractBase)

function ClientNpcInteractComponent:init()
	self:refreshIsNpcEntity()
end

function ClientNpcInteractComponent:start()
	local pdd = PuppetData[self.templateId]

	self.npcType = pdd and pdd.npcType or Const.NPC_TYPE.Human

	self:refreshIsNpcEntity()

	if self.eModel == nil then
		return
	end

	self.playerInTrigger = false
	self.sandboxCustomInteractionData = {}
	self.bornRotation = self:getRotation():Clone()
	self.funcMenuId = self:getNpcFuncId()

	local pdata = self:getConfigData()

	self.notAllowFriendsInteract = pdata.notAllowFriendsInteract or 0
	self.onlyTriggerClientEvent = pdata.OnlyClientEvent

	function self.onPlayerSwitchControl()
		self:refreshInteractTrigger()
	end

	self.registSwitchControl = false
end

function ClientNpcInteractComponent:getInteractiveDist()
	local interactiveDist = 0
	local cfgData = self:getConfigData()

	if cfgData.interactiveDist then
		return cfgData.interactiveDist
	end

	local actionPrototypeIds = self:getNpcActionPrototypeIds()

	if actionPrototypeIds then
		for _, aId in ipairs(actionPrototypeIds) do
			local interactData = InteractData[aId] or {}

			interactiveDist = math.max(interactiveDist, interactData.interactiveDist or 0, interactData.interactiveIconDist or 0)
		end
	end

	if self.getInteractionListData then
		local interactionListData = self:getInteractionListData()

		for _, interactData in ipairs(interactionListData) do
			interactiveDist = math.max(interactiveDist, interactData.interactiveDist or 0, interactData.interactiveIconDist or 0)
		end
	end

	local npcFuncData = NpcFuncData[self.templateId]

	if npcFuncData then
		interactiveDist = math.max(interactiveDist, npcFuncData.funcDistance or 0)
	end

	interactiveDist = math.max(interactiveDist, SandboxInteract.contributeDist(self))
	interactiveDist = math.max(interactiveDist, SpecialInteract.contributeDist(self))
	interactiveDist = math.max(interactiveDist, QuestInteract.contributeDist(self, interactiveDist))
	interactiveDist = math.max(interactiveDist, RandomDialogue.contributeDist(self))

	if self.isHomePet then
		interactiveDist = math.max(interactiveDist, 2)
	end

	if self.getBeHoldDistance then
		interactiveDist = math.max(interactiveDist, self:getBeHoldDistance() or 0)
	end

	return interactiveDist
end

function ClientNpcInteractComponent:getNpcFuncId()
	local space = pg.space

	if space then
		local sceneData = SceneUtils.getSceneEntityData(space.sceneId, space.id) or {}

		if self.staticId then
			local entConfig = sceneData[self.staticId] or {}
			local funcMenuId = entConfig.funcMenuId

			if funcMenuId then
				return funcMenuId
			end
		end
	end

	local npcFuncData = NpcFuncData[self.templateId]

	if npcFuncData then
		return npcFuncData.funcMenuId
	end
end

function ClientNpcInteractComponent:onEnterSpace()
	RandomDialogue.onEnterSpace(self)
	self:refreshInteractTrigger()
end

function ClientNpcInteractComponent:getNpcActionPrototypeIds()
	if self.spActionPrototypeIds ~= nil then
		return self.spActionPrototypeIds
	end

	if self.isHomePet and pg.space and pg.space.homeEventMap and pg.me.space:isSelfHomeland(pg.me) then
		local homeEventInsId = pg.space:getPetHomeEventInsId(self.petInfo.id)
		local eventInfo = pg.space.homeEventMap[homeEventInsId]

		if eventInfo then
			local eventType = HomeEventTextData[eventInfo.textId].eventType
			local eventTypeData = HomeEventTypeData[eventType]

			self.eventTypeId = eventType

			local interactId = eventTypeData.interact

			return {
				interactId
			}
		end
	end

	local configData = self:getConfigData()

	return configData.actionPrototypeIds
end

function ClientNpcInteractComponent:getNpcInteractTriggerLocalOffset()
	local interactLocalOffset

	if self.spInteractLocalOffset ~= nil then
		interactLocalOffset = self.spInteractLocalOffset
	else
		local configData = self:getConfigData()

		interactLocalOffset = configData.interactLocalOffset or Vector3.constZero
	end

	return interactLocalOffset[1], interactLocalOffset[2], interactLocalOffset[3]
end

function ClientNpcInteractComponent:preDestroy()
	if self.recoverInteractRotationTimer then
		self:removeTimer(self.recoverInteractRotationTimer)

		self.recoverInteractRotationTimer = nil
	end

	self:onInteractRotationRecovered()
	ClientFKeyInteractBase.preDestroy(self)
end

function ClientNpcInteractComponent:destroy()
	local onPlayerSwitchControlHandler = self.onPlayerSwitchControl

	if onPlayerSwitchControlHandler then
		self.onPlayerSwitchControl = nil

		if self.registSwitchControl then
			pg.global.eventEmitter:removeEventListener(EventConst.ON_PLAYER_SWITCH_CONTROL, onPlayerSwitchControlHandler)

			self.registSwitchControl = false
		end
	end
end

function ClientNpcInteractComponent:useReentryGuard()
	return true
end

function ClientNpcInteractComponent:getInteractTriggerOffset()
	return self:getNpcInteractTriggerLocalOffset()
end

function ClientNpcInteractComponent:checkCanInteract(interactUnit)
	if Utils.isVirtualEntity(self) then
		return self:checkNpcCanInteract(interactUnit)
	end

	if not self:belongsToPlayer(pg.me) then
		return false
	end

	return true
end

function ClientNpcInteractComponent:belongsToPlayer(player)
	if self.notAllowFriendsInteract == 1 then
		return self.ownerId == player.id
	end

	return true
end

function ClientNpcInteractComponent:checkNpcInteractState()
	if self.isInCombat and self:isInCombat() then
		return false
	end

	if self.isMagnesisControlling then
		return false
	end

	if not self:checkCanInteract() then
		return false
	end

	local pawn = pg.pawn

	if not pawn then
		return false
	end

	if self.checkAICanInteract then
		if not self:checkAICanInteract() then
			return false
		end

		if Utils.IsSameSpecies(pawn, self) then
			-- block empty
		elseif not self:isEnemy(pawn) and (not self.isInCombat or not self:isInCombat()) then
			-- block empty
		else
			return false
		end
	end

	return true
end

function ClientNpcInteractComponent:onEnterInteractTrigger()
	if pg.me:GM_OBSERVE_ST() or self.GM_OBSERVE_ST and self:GM_OBSERVE_ST() then
		return
	end

	if self.playerInTrigger then
		return
	end

	self.playerInTrigger = true
	self._interactionData = self:getNpcInteractionData()

	if self.getCarryInteractionListData then
		self._carryInteractionData = self:getCarryInteractionListData()

		if self._carryInteractionData then
			facade:SendMessageCommand(MessageName.ENTER_TRIGGER, self._carryInteractionData)
		end
	end

	QuestInteract.onEnter(self)

	if self._interactionData then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER_MULTI_INTERACT, self._interactionData)
	end

	SpecialInteract.onEnter(self)
	SandboxInteract.onEnter(self)
	RandomDialogue.onEnter(self)

	if RandomDialogue.needRefreshOnPlayerSwitch(self) then
		pg.global.eventEmitter:addEventListener(EventConst.ON_PLAYER_SWITCH_CONTROL, self.onPlayerSwitchControl)

		self.registSwitchControl = true
	end
end

function ClientNpcInteractComponent:onLeaveInteractTrigger()
	self.playerInTrigger = false

	if self.onPlayerSwitchControl and self.registSwitchControl then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_PLAYER_SWITCH_CONTROL, self.onPlayerSwitchControl)

		self.registSwitchControl = false
	end

	QuestInteract.onLeave(self)

	if self._interactionData then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER_MULTI_INTERACT, self._interactionData)
	end

	SpecialInteract.onLeave(self)
	SandboxInteract.onLeave(self)
	RandomDialogue.onLeave(self)

	if self._carryInteractionData then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, self._carryInteractionData)

		self._carryInteractionData = nil
	end
end

function ClientNpcInteractComponent:getNpcInteractionData()
	local ret = {}

	if self.funcMenuId then
		ret[#ret + 1] = {
			globalId = self:getGlobalId(),
			interactionType = InteractionConst.INTERACTION_TYPE_NPC_FUNC,
			actionPrototypeId = InteractionConst.DEFAULT_INTERACTION_CUSTOM_ID,
			funcMenuId = self.funcMenuId,
			dist = self.interactiveDist,
			isClient = self.onlyTriggerClientEvent
		}
	end

	local actionPrototypeIds = self:getNpcActionPrototypeIds() or {}

	for _, interactId in ipairs(actionPrototypeIds) do
		local interactData = InteractData[interactId]
		local interactionType = InteractionConst.INTERACTION_TYPE_NPC_INTERACTION

		if interactData.type then
			interactionType = interactData.type
		end

		ret[#ret + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = interactId,
			interactionType = interactionType
		}
	end

	if self.getInteractionListData then
		local interactionListData = self:getInteractionListData() or {}

		for _, interactionData in ipairs(interactionListData) do
			ret[#ret + 1] = interactionData
		end
	end

	return ret
end

function ClientNpcInteractComponent:getQuestInteractionData()
	return QuestInteract.getInteractionData(self)
end

function ClientNpcInteractComponent:getQuestCommitInfo()
	return QuestInteract.getQuestCommitInfo(self)
end

function ClientNpcInteractComponent:getNpcSpecialInteractionData()
	return SpecialInteract.getData(self)
end

function ClientNpcInteractComponent:getEntityDialogueGraphData()
	return RandomDialogue.buildEntityDialogueGraphData(self)
end

function ClientNpcInteractComponent:getRandomDialogueTextData()
	return RandomDialogue.buildRandomDialogueTextData(self)
end

function ClientNpcInteractComponent:getWeightedRandomDialogueText()
	return RandomDialogue.getWeightedRandomText(self)
end

function ClientNpcInteractComponent:canInteractRandomDialogueText()
	return RandomDialogue.canInteract(self)
end

function ClientNpcInteractComponent:addCustomInteraction(interactId, interactConfigId, handlePetEthnicGroup, callback, sandBoxId, doOnce, overrideNpcTemplateId)
	SandboxInteract.addCustomInteraction(self, interactId, interactConfigId, handlePetEthnicGroup, callback, sandBoxId, doOnce, overrideNpcTemplateId)
end

function ClientNpcInteractComponent:removeCustomInteraction(interactId)
	SandboxInteract.removeCustomInteraction(self, interactId)
end

function ClientNpcInteractComponent:enableInteractCallFriend(interactId, enable, distance, callback, sandBoxId, doOnce)
	SandboxInteract.enableInteractCallFriend(self, interactId, enable, distance, callback, sandBoxId, doOnce)
end

function ClientNpcInteractComponent:enableListenBallHitEvent(interactId, enable, callback, sandBoxId, doOnce)
	SandboxInteract.enableListenBallHitEvent(self, interactId, enable, callback, sandBoxId, doOnce)
end

function ClientNpcInteractComponent:enableShowVlogTopLogo(interactId, enable, callback, sandBoxId, doOnce, distanceShow, distanceInter, showStyle)
	SandboxInteract.enableShowVlogTopLogo(self, interactId, enable, callback, sandBoxId, doOnce, distanceShow, distanceInter, showStyle)
end

function ClientNpcInteractComponent:onInteractRotationRecovered()
	InteractTurn.onInteractRotationRecovered(self)
end

function ClientNpcInteractComponent:startInteractTurnTimer(npcTurnTime)
	InteractTurn.startInteractTurnTimer(self, npcTurnTime)
end

function ClientNpcInteractComponent:onInteractResult(fromEnt, actionPrototypeId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("ClientNpcInteractComponent:onInteractResult")
	end

	if self.staticId and self.staticId ~= 0 and fromEnt.authority == Const.AUTHORITY_MASTER then
		local eventData = {
			fromEnt = fromEnt,
			actionPrototypeId = actionPrototypeId
		}

		facade:sendLuaEvent(self.staticId .. ClientConst.LuaEventPostFix.EntityInteract, eventData)
	end
end

function ClientNpcInteractComponent:interact(interactUnit)
	if Utils.isVirtualEntity(self) then
		self:npcInteract(interactUnit)

		return
	end

	if self.isHomePet then
		self:postComponentMethod("startHomeEventReturnCollision")
		pg.me:startInteract(Const.IACT_TP_HOME_PET, self.id, interactUnit.actionPrototypeId, {}, function()
			local eventTypeData = HomeEventTypeData[self.eventTypeId]
			local message = ClientTextUtils.getLocalizationText(eventTypeData.feedback)
			local petName = ClientTextUtils.getLocalizationText(self:getConfigData().name)

			message = string.format(message, petName)

			pg.global.showBubbleMessageRaw(message)
			self:refreshInteractTrigger()
		end)
	elseif self:checkConfirmInteract(interactUnit) then
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("DUNGEONDOOR_ENTER_TIPS"), function()
			pg.me:startInteract(Const.IACT_TP_NPC, self.id, interactUnit.actionPrototypeId, {}, nil)
		end)
	elseif self:checkLeylineFlowerConfirmInteract(interactUnit) then
		self:doLeylineFlowerInteractConfirmMsg(function()
			pg.me:startInteract(Const.IACT_TP_NPC, self.id, interactUnit.actionPrototypeId, {}, nil)
		end)
	else
		pg.me:startInteract(Const.IACT_TP_NPC, self.id, interactUnit.actionPrototypeId, {}, nil)
	end
end

function ClientNpcInteractComponent:checkConfirmInteract(interactUnit)
	if interactUnit.actionPrototypeId ~= ItemConst.ROB_EGG_INTERACT_TYPE.EGG_DOOR_ENTER then
		return false
	end

	if pg.space and pg.space.realDoor and table.contains(pg.space.realDoor, self.id) then
		return true
	end

	return false
end

function ClientNpcInteractComponent:checkLeylineFlowerConfirmInteract(interactUnit)
	if interactUnit.actionPrototypeId ~= ItemConst.ROB_EGG_INTERACT_TYPE.PLENTY_HAPPEN_INTERACT_ID then
		return false
	end

	local remainSlots = pg.me.petBoxMap:getValidEmptySlot() or 0

	if remainSlots >= LeylineFlowerUtils.INV_SLOT_COUNT_REQUIRED then
		return false
	end

	return true
end

function ClientNpcInteractComponent:doLeylineFlowerInteractConfirmMsg(confirmCallback)
	local hintShowTs = pg.global.prefsCacheUtils:getInt("leylineFlowerInteractHint", 0, ClientConst.CACHE_TYPE_FLAG.USER)

	if hintShowTs + 86400 <= Time.secondCache then
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), string.format(pg.getGameString("LEYLINE_FLOWER_INTERACT_TIP_1"), LeylineFlowerUtils.INV_SLOT_COUNT_REQUIRED), function()
			if self._leylineFlowerInteractHintHideFlag then
				pg.global.prefsCacheUtils:setInt("leylineFlowerInteractHint", Time.secondCache, ClientConst.CACHE_TYPE_FLAG.USER)
				pg.global.prefsCacheUtils:save()
			end

			if confirmCallback then
				confirmCallback()
			end
		end, nil, function()
			return
		end, nil, nil, {
			hint = true,
			hintDesc = string.format(pg.getGameString("DISABLE_HINT"), 1),
			hintCb = function(isSelected)
				if isSelected then
					self._leylineFlowerInteractHintHideFlag = true
				else
					self._leylineFlowerInteractHintHideFlag = nil
				end
			end
		})
	elseif confirmCallback then
		confirmCallback()
	end
end

function ClientNpcInteractComponent:tryGetNpcTrapEventId()
	local interactInfo = NpcFuncData[self.templateId]

	if not interactInfo then
		return
	end

	return interactInfo.trapEventId
end

function ClientNpcInteractComponent:showSimpleDialogue(cd, trap)
	local prob = trap[3]

	if prob < math.random() then
		return
	end

	pg.game.communication:startNpcDialog(trap[2], self.id)
end

function ClientNpcInteractComponent:NPCINFO_OnAciveChange(active)
	local interactInfo = NpcFuncData[self.templateId]

	if interactInfo then
		if active then
			self:openTopLogo()
		else
			self:closeTopLogo()
		end
	end
end

function ClientNpcInteractComponent:onEnterCombat()
	RandomDialogue.onEnterCombat(self)
end

function ClientNpcInteractComponent:onLeaveSpace()
	self:clearInteractTrigger()
end

function ClientNpcInteractComponent:refreshIsNpcEntity()
	self.isNpcEntity = Utils._isNpc(self)
end

return ClientNpcInteractComponent
