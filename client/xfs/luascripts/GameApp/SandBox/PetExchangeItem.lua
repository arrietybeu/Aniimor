-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\PetExchangeItem.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local TimerManager = require("Core.Timer.TimerManager")
local InteractionConst = require("Common.Const.InteractionConst")
local PlayableConst = require("Common.Const.PlayableConst")
local ClientSimpleVirtualEntityWithPhysics = require("Entities.ClientSimpleVirtualEntityWithPhysics")
local PetData = require("Data.pet_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local TmpPetTemplateData = require("Data.tmp_pet_template_data")
local Time = require("Core.Common.Time")
local VirtualEntitiesContainer = require("GameApp.Sandbox.VirtualEntitiesContainer")
local ClientUtils = require("Utils.ClientUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local AddressDataConst = require("Const.AddressDataConst")
local LuaTimeline = require("GameApp.Timeline.LuaTimeline")
local PetExchangeItem = Class.LightClass("PetExchangeItem", VirtualEntitiesContainer)

function PetExchangeItem:ctor(sandbox, spawnInfo, syncInfo)
	PetExchangeItem.super.ctor(self, sandbox, spawnInfo, syncInfo)

	local defaultValue = spawnInfo.defaultValue or {}

	self.tempPetTemplateId = defaultValue.tempPetTemplateId
	self.canReturn = defaultValue.canReturn
	self.characters = defaultValue.realCharacters
	self.noticeKey = defaultValue.noticeKey
	self.guideId = defaultValue.guideId
end

function PetExchangeItem:destroy()
	self:resetSculptureShaderBorrowEffect()
	pg.global.ui.tips:hideA1Tips("ArchaicCharacter")

	if self.deActiveTimerId then
		TimerManager.removeTimer(self.deActiveTimerId)

		self.deActiveTimerId = nil
	end

	PetExchangeItem.super.destroy(self)
end

function PetExchangeItem:onSandboxReady()
	PetExchangeItem.super.onSandboxReady(self)

	self.exchangeSB = self.shell.gameObject:GetComponent("PetExchangeSB")
	self.attachTrans = self.exchangeSB.petAttachTrans
	self.cutsceneAttachTrans = self.exchangeSB.cutsceneAttachTrans

	self:initPetSculpture()
end

function PetExchangeItem:onCreateVirtualEntity(refKey, extraInfo)
	local templateId = extraInfo.templateId
	local virtualEnt = ClientSimpleVirtualEntityWithPhysics.new()
	local petInfo = PetData[templateId] or {}

	virtualEnt:setConfigData(petInfo)
	virtualEnt:init(extraInfo)
	virtualEnt:postInit(extraInfo)
	virtualEnt:start()

	function virtualEnt.modelLoadedCallback()
		if virtualEnt.eModel.shaderView then
			ClientEffectUtils.ApplyMaterialEffect(virtualEnt, "Temple_StoneStatueBase", true)
		end
	end

	local modelView = virtualEnt.eModel.modelModelView

	modelView.instPriority = ClientConst.InstantiatePriority.Urgent

	local modelExtraInfo = ClientModelUtils.getModelExtraInfo(petInfo, extraInfo.label or 0, extraInfo.gender or 0)

	ClientModelUtils.applyPetAppearance(modelView.modelInfo, petInfo, modelExtraInfo)
	ClientModelUtils.applyAnimController(virtualEnt, virtualEnt.eModel, petInfo)
	modelView:RefreshModels()

	local animOffset = extraInfo.animOffset or 0
	local animName = extraInfo.animName or "Idle"
	local idleState = virtualEnt:playRawAnimation("Idle", nil, animOffset, 0)

	idleState:RemoveAutoTransition()

	local animState = virtualEnt:playRawAnimation(animName, nil, animOffset, 0)

	animState:RemoveAutoTransition()
	virtualEnt:setMultiPassRenderEnable(false)
	virtualEnt.eModel:SetTransformLocalPosition()
	virtualEnt.eModel:SetTransformLocalRotation(0, 0, 0, 1)
	virtualEnt:refreshPhysxData()
	virtualEnt:setModelLayer(ClientConst.LayerDefine.LAYER_NOCLIMB)

	return virtualEnt
end

function PetExchangeItem:initPetSculpture()
	if IsNil(self.attachTrans) then
		return
	end

	if not self.tempPetTemplateId or self.tempPetTemplateId == 0 then
		return
	end

	local tmpPetInfo = TmpPetTemplateData[self.tempPetTemplateId] or {}
	local extraInfo = {}

	extraInfo.templateId = tmpPetInfo.templateBaseId

	local sculptureConfig = tmpPetInfo.sculptureConfig or {}

	extraInfo.animName = sculptureConfig[1]
	extraInfo.animOffset = sculptureConfig[2]
	extraInfo.label = tmpPetInfo.label
	extraInfo.gender = tmpPetInfo.DefaultGen
	self.sculptureEnt = self:createVirtualEntity("Sculpture", extraInfo)

	if self.syncInfo.state == Const.PetExchangeItemState.Ready then
		self.attachTrans.gameObject:SetActiveEx(true)
	else
		self.attachTrans.gameObject:SetActiveEx(false)
	end

	self:refreshSculptureAttach()
end

function PetExchangeItem:setInCutscene(isInCutscene)
	self.isInCutscene = isInCutscene

	self:refreshSculptureAttach()

	if not self.isInCutscene then
		pg.me:setInLevelItemInteract(false)
		self:resetSculptureShaderBorrowEffect()
	else
		pg.me:setInLevelItemInteract(true)
	end
end

function PetExchangeItem:refreshSculptureAttach()
	if not self.sculptureEnt then
		return
	end

	if self.isInCutscene then
		self.sculptureEnt.eModel:SetTransformParent(self.cutsceneAttachTrans, false)
	else
		self.sculptureEnt.eModel:SetTransformParent(self.attachTrans, false)
	end
end

function PetExchangeItem:onValueChange(key, oldValue, value, isInit)
	PetExchangeItem.super.onValueChange(self, key, oldValue, value, isInit)

	if self.attachTrans and key == "state" then
		if self.deActiveTimerId then
			TimerManager.removeTimer(self.deActiveTimerId)

			self.deActiveTimerId = nil
		end

		if self.syncInfo.state == Const.PetExchangeItemState.Ready then
			self.attachTrans.gameObject:SetActiveEx(true)
		else
			self.attachTrans.gameObject:SetActiveEx(false)
		end

		if not self.isInCutscene then
			self.shell:SendEventToFlowScript("RefreshEffect")
		end
	end
end

function PetExchangeItem:onInteract(interactUnit)
	if interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_GET_TEMP_PET then
		self:serverMsg("RPC_CS_borrowPet")
	elseif interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_RETURN_TEMP_PET then
		self:serverMsg("RPC_CS_returnPet")
	end
end

function PetExchangeItem:checkCanInteract(interactUnit)
	if not pg.me then
		return false
	end

	if not self.tempPetTemplateId or self.tempPetTemplateId == 0 then
		return false
	end

	if self.canInteractTime and self.canInteractTime > Time.realSecondCache then
		return false
	end

	if pg.me.inTeammateView then
		return false
	end

	local templateIdPetIdMap = pg.me.templateIdPetIdMap or {}
	local borrowPetId = templateIdPetIdMap[self.tempPetTemplateId]

	if interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_GET_TEMP_PET then
		if self.syncInfo.state == Const.PetExchangeItemState.Borrowed then
			return false
		end

		if borrowPetId then
			return false
		end
	elseif interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_RETURN_TEMP_PET then
		if self.syncInfo.state == Const.PetExchangeItemState.Ready then
			return false
		end

		if not borrowPetId then
			return false
		end

		if not self.canReturn then
			return false
		end
	end

	return true
end

function PetExchangeItem:resetSculptureShaderBorrowEffect()
	if self.sculptureTimeline then
		self.sculptureTimeline:stop()

		self.sculptureTimeline = nil
	end

	if self.sculptureEnt then
		self.sculptureEnt:setMaterialProperty("_EmissiveColor", Color(0, 0, 0, 1))
		self.sculptureEnt:setMaterialProperty("_Luminance", 2)
	end
end

function PetExchangeItem:playSculptureShaderBorrowEffect()
	self:resetSculptureShaderBorrowEffect()

	if self.sculptureEnt then
		local duration = 3
		local sculptureTimeline = LuaTimeline.new()

		sculptureTimeline:setDuration(duration)
		sculptureTimeline:createAndAddClip(0, duration, function(_, curTime)
			if self.sculptureEnt then
				local blendValue = curTime / duration
				local luminance = 2^math.lerp(1, 16, blendValue)
				local colorValue = blendValue

				self.sculptureEnt:setMaterialProperty("_EmissiveColor", Color(colorValue, colorValue, colorValue, 1))
				self.sculptureEnt:setMaterialProperty("_Luminance", luminance)
			end
		end)
		sculptureTimeline:start()

		self.sculptureTimeline = sculptureTimeline
	end
end

function PetExchangeItem:playSculptureShaderReturnEffect()
	self:resetSculptureShaderBorrowEffect()

	if self.sculptureEnt then
		self.sculptureEnt:setMaterialProperty("_EmissiveColor", Color(1, 1, 1, 1))

		local duration = 2
		local sculptureTimeline = LuaTimeline.new()

		sculptureTimeline:setDuration(duration)
		sculptureTimeline:createAndAddClip(0, duration, function(_, curTime)
			if self.sculptureEnt then
				local blendValue = curTime / duration
				local luminance = 2^math.lerp(16, 1, blendValue)
				local colorValue = 1 - blendValue

				self.sculptureEnt:setMaterialProperty("_EmissiveColor", Color(colorValue, colorValue, colorValue, 1))
				self.sculptureEnt:setMaterialProperty("_Luminance", luminance)
			end
		end)
		sculptureTimeline:start()

		self.sculptureTimeline = sculptureTimeline
	end
end

function PetExchangeItem:showArchaicCharacter()
	pg.global.ui.tips:showA1Tips({
		id = "ArchaicCharacter",
		duration = 10,
		noticeKey = self.noticeKey,
		characters = self.characters
	})
end

function PetExchangeItem:playGuide()
	pg.global.ui.tips:hideA1Tips("ArchaicCharacter")
	self:serverMsg("RPC_CS_StartGuidance")
end

function PetExchangeItem:RPC_SC_PlayPetExchangeItemCutscene(firstTime)
	if self.shell then
		if firstTime then
			self.shell:SendEventToFlowScript("FirstPlayBorrowCutscene")
		else
			self.shell:SendEventToFlowScript("PlayBorrowCutscene")
		end
	end

	self.canInteractTime = Time.realSecondCache + 5.5
end

function PetExchangeItem:RPC_SC_PlayPetExchangeItemReturnCutscene(firstTime)
	if self.shell then
		if firstTime then
			self.shell:SendEventToFlowScript("FirstPlayReturnCutscene")
		else
			self.shell:SendEventToFlowScript("PlayReturnCutscene")
		end
	end

	self.canInteractTime = Time.realSecondCache + 5.5
end

return PetExchangeItem
