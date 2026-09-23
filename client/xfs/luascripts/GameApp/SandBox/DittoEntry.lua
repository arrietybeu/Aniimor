-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\DittoEntry.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local InteractionConst = require("Common.Const.InteractionConst")
local PetData = require("Data.pet_data")
local TmpPetTemplateData = require("Data.tmp_pet_template_data")
local Time = require("Core.Common.Time")
local VirtualEntitiesContainer = require("GameApp.Sandbox.VirtualEntitiesContainer")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientSimpleVirtualEntityWithPhysics = require("Entities.ClientSimpleVirtualEntityWithPhysics")
local SandboxConst = require("Common.Const.SandboxConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("DittoEntry", "Sandbox", LoggerConst.ERROR)
local Vector3 = Vector3
local Quaternion = Quaternion
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local DittoEntry = Class.LightClass("DittoEntry", VirtualEntitiesContainer)
local DITTO_PET_IDLE_PM = "Eff_Env_SceneObject_Morphling_Soul"
local AddressDataConst = require("Const.AddressDataConst")
local SysNoticeData = require("Data.sys_notice_data")
local UIConst = require("Const.UIConst")

function DittoEntry:ctor(sandbox, spawnInfo, syncInfo)
	DittoEntry.super.ctor(self, sandbox, spawnInfo, syncInfo)

	local majorConfig = self:getMajorConfig()

	self.sceneId = majorConfig.sceneId
	self.cdTime = majorConfig.cdTime
	self.petTemplateId = majorConfig.petTemplateId
	self.petAnimStateName = majorConfig.petAnimStateName
	self.petScaleFactor = majorConfig.petScaleFactor
	self.dittoPetTemplateId = majorConfig.dittoPetTemplateId
	self.dittoScaleFactor = majorConfig.dittoScaleFactor
	self.dittoAnimStateName = majorConfig.dittoAnimStateName
	self.destroying = false
end

function DittoEntry:destroy()
	pg.me.dittoEnter = false

	pg.me:stopCfgAnimation()

	if pg.me.updateStateCache then
		pg.me:updateStateCache("DITTO_ENTER_ST")
	end

	self.destroying = true

	if self.activeEffId then
		pg.game.effect:stopEffect(nil, self.activeEffId)

		self.activeEffId = nil
	end

	pg.global.ui:close(UIConst.UI_ID_Morphling)
	DittoEntry.super.destroy(self)

	self.cutsceneRoot = nil
end

function DittoEntry:onSandboxReady()
	DittoEntry.super.onSandboxReady(self)

	self.dittoEntrySB = self.shell.gameObject:GetComponent("DittoEntrySB")
	self.petAttachTransform = self.dittoEntrySB.petAttachTransform
	self.dittoPetAttachTransform = self.dittoEntrySB.dittoPetAttachTransform
	self.cutsceneRoot = self.dittoEntrySB.cutsceneRoot

	self:initPetSculpture()
end

function DittoEntry:initPetSculpture()
	if IsNil(self.petAttachTransform) or IsNil(self.cutsceneRoot) then
		return
	end

	if not self.petTemplateId or self.petTemplateId == 0 then
		return
	end

	local tmpPetInfo = TmpPetTemplateData[self.petTemplateId] or {}
	local extraInfo = {}

	extraInfo.templateId = tmpPetInfo.templateBaseId
	extraInfo.label = tmpPetInfo.label
	extraInfo.gender = tmpPetInfo.DefaultGen
	extraInfo.instPriority = ClientConst.InstantiatePriority.Urgent
	extraInfo.modelScale = self.petScaleFactor
	extraInfo.parentTransform = self.petAttachTransform
	self.sculptureEnt = self:createVirtualEntity("puppet1", extraInfo)
	extraInfo.templateId = self.dittoPetTemplateId
	extraInfo.parentTransform = self.dittoPetAttachTransform
	extraInfo.modelScale = self.dittoScaleFactor
	self.dittoPetEnt = self:createVirtualEntity("puppet2", extraInfo)
end

function DittoEntry:onCreateVirtualEntity(refKey, extraInfo)
	local templateId = extraInfo.templateId
	local virtualEnt = ClientSimpleVirtualEntity.new()
	local petInfo = PetData[templateId] or {}

	function virtualEnt.modelLoadedCallback()
		if refKey == "puppet1" then
			virtualEnt:playRawAnimation(self.petAnimStateName)
		else
			virtualEnt:playRawAnimation(self.dittoAnimStateName)
		end

		ClientEffectUtils.PlayPreset(virtualEnt, DITTO_PET_IDLE_PM, -1, false)
		self.cutsceneRoot:SetExternalRefEntity(refKey, virtualEnt.eModel)
	end

	virtualEnt:setConfigData(petInfo)
	virtualEnt:init(extraInfo)
	virtualEnt:postInit(extraInfo)
	virtualEnt:start()
	virtualEnt.eModel:SetTransformParent(extraInfo.parentTransform)
	virtualEnt.eModel:SetTransformLocalPosition()
	virtualEnt.eModel:SetTransformLocalRotation(0, 0, 0, 1)
	virtualEnt:setModelLayer(ClientConst.LayerDefine.LAYER_NOCLIMB)
	virtualEnt:setModelScale(ClientConst.MODEL_SCALE_KEY.DITTO_ENTRY, extraInfo.modelScale)

	return virtualEnt
end

function DittoEntry:onValueChange(key, oldValue, value, isInit)
	DittoEntry.super.onValueChange(self, key, oldValue, value, isInit)

	if self.petAttachTransform and key == "state" and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("jsx-DittoEntry:onStateChange oldV:%s newV:%s isInit:%s", oldValue, value, isInit)
	end
end

function DittoEntry:onInteract(interactUnit)
	pg.me:cancelAbility()

	local forward = pg.me:getForward()
	local direction = self.dittoEntrySB.transform.position - pg.pawn:getPosition()
	local angle = self:GetHorizontalSignedAngle(pg.pawn:getForward(), direction)

	if math.abs(angle) > 30 then
		pg.pawn:faceToPosition(self.dittoEntrySB.transform.position)
	end

	local memberCount = pg.me:getTeamMemberCount()

	if memberCount > 1 then
		local noticeData = SysNoticeData[10906]

		if noticeData then
			pg.global.ui.tips:showTextTip(pg.getLocalizationText(noticeData.text))
		end

		return
	end

	if interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_START_DITTO then
		if self.syncInfo.state == SandboxConst.LEVEL_DITTO_ENTRY_STATE.ACTIVE then
			if pg.me:isControllingPet() then
				local result = pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Catch, nil, function()
					self:playStartDittoEffect()
				end)
			else
				self:playStartDittoEffect()
			end
		elseif self.syncInfo.state == SandboxConst.LEVEL_DITTO_ENTRY_STATE.CD then
			local cdTimeStamp = pg.me.dittoCDTimes[self.sceneId]

			pg.global.showBubbleMessageRaw(string.format(pg.getGameString("FUNC_NOT_AVAILABLE"), cdTimeStamp - Time.secondCache), 3)
		end
	end
end

function DittoEntry:GetHorizontalSignedAngle(a, b)
	Vector3.enableCreateFromCache()

	local aH = Vector3(a.x, 0, a.z).normalized
	local bH = Vector3(b.x, 0, b.z).normalized
	local dot = Vector3.Dot(aH, bH)

	dot = math.max(-1, math.min(1, dot))

	local angle = math.acos(dot) * 57.29578
	local cross = Vector3.Cross(aH, bH)

	if cross.y < 0 then
		angle = -angle
	end

	Vector3.disableCreateFromCache()

	return angle
end

function DittoEntry:playStartDittoEffect()
	if self.startingDitto then
		return
	end

	self.startingDitto = true
	pg.me.dittoEnter = true

	if pg.me.updateStateCache then
		pg.me:updateStateCache("DITTO_ENTER_ST")
	end

	pg.me:playCfgAnimation({
		"Story_TouchHigh_Start",
		"Story_TouchHigh_Loop",
		"Story_TouchHigh_End",
		{
			true
		}
	})

	self._activeEffectTimer = self:addTimer(5, function()
		self.activeEffId = pg.game.effect:playEffectAt(nil, "Eff_Env_SceneObject_MorphlingStatue_KeyItem_Start", self:getPosition(), self:getRotation(), nil, {
			endCallback = function()
				self._effectTimer = self:addTimer(3.5, function()
					self:realStartDitto()
				end)
			end
		})
		self._startScreenEffectTimer = self:addTimer(3, function()
			pg.global.ui:open(UIConst.UI_ID_Morphling, {
				state = 1
			})
		end)
		self._stopScreenEffectTimer = self:addTimer(5, function()
			pg.global.ui:close(UIConst.UI_ID_Morphling)
		end)
	end)
	self._dissolvePMTimer = self:addTimer(7, function()
		self.dittoEntrySB:PlayPM("Eff_Env_Props_MorphlingStatue_Dissove_01", 3)
	end)
	self._saveTimer = self:addTimer(10, function()
		self:realStartDitto()
	end)
end

function DittoEntry:realStartDitto()
	pg.me.dittoEnter = false

	if pg.me.updateStateCache then
		pg.me:updateStateCache("DITTO_ENTER_ST")
	end

	if self._startScreenEffectTimer then
		self:removeTimer(self._startScreenEffectTimer)

		self._startScreenEffectTimer = nil
	end

	if self._stopScreenEffectTimer then
		self:removeTimer(self._stopScreenEffectTimer)

		self._stopScreenEffectTimer = nil
	end

	if self._activeEffectTimer then
		self:removeTimer(self._activeEffectTimer)

		self._activeEffectTimer = nil
	end

	if self._effectTimer then
		self:removeTimer(self._effectTimer)

		self._effectTimer = nil
	end

	if self._saveTimer then
		self:removeTimer(self._saveTimer)

		self._saveTimer = nil
	end

	if self.destroying then
		return
	end

	pg.global.ui.hudV2:showSeamlessVFX()
	self:serverMsg("RPC_CS_StartDitto", self.sceneId)
end

function DittoEntry:checkCanInteract(interactUnit)
	if not pg.me then
		return false
	end

	if not self.petTemplateId or self.petTemplateId == 0 then
		return false
	end

	if self.syncInfo.state == SandboxConst.LEVEL_DITTO_ENTRY_STATE.FINISH then
		return false
	end

	if self.activeEffId then
		return false
	end

	return true
end

function DittoEntry:getInteractionListData(levelItemInteractSB, interactPartId)
	local configData = self:getConfigData()
	local actionPrototypeIds = configData.actionPrototypeIds

	if not actionPrototypeIds then
		return nil
	end

	local interactListData = {}

	for _, actionPrototypeId in ipairs(actionPrototypeIds) do
		local interactData = {
			overrideType = InteractionConst.INTERACTION_TYPE_START_DITTO,
			interactionType = InteractionConst.INTERACTION_TYPE_START_DITTO,
			interactPartId = interactPartId,
			actionPrototypeId = actionPrototypeId,
			globalId = self:getInteractGlobalId(interactPartId),
			interactFunc = function(interactUnit)
				self:onInteract(interactUnit)
				self:informServerInteract()
			end,
			canInteractiveFunc = function(interactUnit)
				local result = self:checkCanInteract(interactUnit)

				return result
			end
		}

		table.insert(interactListData, interactData)
	end

	return interactListData
end

return DittoEntry
