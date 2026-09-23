-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ChainAttack\\ChainAttackCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("HudBreakCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local Utils = require("Common.Utils.Utils")
local AbilityConst = require("Common.Const.AbilityConst")
local AddressDataConst = require("Const.AddressDataConst")
local PlayableConst = require("Common.Const.PlayableConst")
local LuaTimeline = require("GameApp.Timeline.LuaTimeline")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local ChainAttackCtrl = Class.LightClass("ChainAttackCtrl", UICtrl)
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")

ChainAttackCtrl.messages = {
	[MessageName.BREAK_STATE_CHANGE] = {
		"onEntBreakStateChange",
		true
	},
	[MessageName.CHAIN_DAMAGE_CHANGE] = {
		"onChainTotalDamageChanged",
		true
	},
	[MessageName.CHAIN_IN_EXTREME_CHANGE] = {
		"onChainInExtremeChanged",
		true
	},
	[MessageName.CHAIN_ATTACK_KEEP_DAMAGE] = {
		"onKeepChainAttackDamageInfo",
		true
	}
}

local CHAIN_MAX_NUM = 4

function ChainAttackCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.curStage = ClientConst.HUD_BREAK_STAGE.NONE
	self.resetCallback = nil

	self:setDamageNum(0)
end

function ChainAttackCtrl:onDestroy()
	if self.changeSpeedTimeline then
		self.changeSpeedTimeline:stop()

		self.changeSpeedTimeline = nil
	end

	UICtrl.onDestroy(self)
end

function ChainAttackCtrl:addListener()
	self.view.chainPetList.visibility = CS.XGUI.EVisibility.HitTestInvisible

	function self.view.petList.luaRenderItem(button, index, data)
		self:setPetItem(button, index, data)
	end

	function self.view.chainPetList.luaRenderItem(button, index, data)
		self:setChainListPetItem(button, index, data)
	end
end

function ChainAttackCtrl:onShow()
	self:refreshInfo()
end

function ChainAttackCtrl:setPetItem(qteBtn, index, data)
	local keyBinding = qteBtn:GetComponent("KeyBindingPro")
	local petId = data.petId
	local qteIcon = qteBtn:Find("Mask/Icon"):GetComponent("UImage")
	local petEntity = pg.getEntity(petId)
	local petInfo = petEntity and petEntity.getBattlePetInfo and petEntity:getBattlePetInfo() or pg.me:getPetInfo(petId)
	local petData = PetData[petInfo.templateId] or {}

	qteIcon.forceSyncLoad = true
	qteIcon.url = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender)
	keyBinding.actionPath = self:getPetHotkey(petId)

	qteBtn:TryChangePage("hideEffect", 0)

	function qteBtn.luaPress()
		qteBtn:TryChangePage("hideEffect", 1)
		self:chooseNextQte(index + 1)
	end
end

function ChainAttackCtrl:setChainListPetItem(chainItem, index, data)
	local petId = data.petId

	if petId then
		local objectReference = chainItem:GetComponent("ObjectReference")
		local qteIcon = objectReference:GetRefValue("iconUImage")
		local petEntity = pg.getEntity(petId)
		local petInfo = petEntity and petEntity.getBattlePetInfo and petEntity:getBattlePetInfo() or pg.me:getPetInfo(petId)
		local petData = PetData[petInfo.templateId] or {}

		qteIcon.url = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender)

		chainItem:TryChangePage("State", 1)
	else
		chainItem:TryChangePage("State", 0)
	end
end

function ChainAttackCtrl:insertTempChoosePet(nextPetId)
	if not self.view then
		return
	end

	local chainInfo = pg.me.chainAttackInfo
	local petList = chainInfo.petList
	local uiChainListInfo = {}

	for i = 1, CHAIN_MAX_NUM do
		local petId = petList[i]

		uiChainListInfo[i] = {
			petId = petId
		}
	end

	uiChainListInfo[#petList + 1] = {
		petId = nextPetId
	}

	self.view.chainPetList:SetList(uiChainListInfo)
end

function ChainAttackCtrl:getPetHotkey(petId)
	local petPrepareList = pg.me.petPrepareList

	for i = 1, #petPrepareList do
		if petPrepareList[i] == petId then
			return "Hud/Pet" .. i
		end
	end

	return "Hud/Pet1"
end

function ChainAttackCtrl:setCurStageState(state)
	self.curStage = state

	self:refreshInfo()
end

function ChainAttackCtrl:showChainBurstImage()
	self:setCurStageState(ClientConst.HUD_BREAK_STAGE.CHAIN_BURST)

	self.curStage = ClientConst.HUD_BREAK_STAGE.CHAIN_BURST

	self:refreshInfo()

	if self.resetCallback then
		self:killTimer(self.resetCallback)
	end

	self.resetCallback = self:startTimer(function()
		self:resetChainBurstState()
	end, 3)
end

function ChainAttackCtrl:resetChainBurstState()
	self.curStage = ClientConst.HUD_BREAK_STAGE.NONE

	self:refreshInfo()
end

function ChainAttackCtrl:showFinalResult(damageResult)
	if not self.view then
		return
	end
end

function ChainAttackCtrl:onChainTotalDamageChanged(totalDamage)
	self:setDamageNum(totalDamage)
end

function ChainAttackCtrl:onChainInExtremeChanged()
	local chainInfo = pg.me.chainAttackInfo

	if chainInfo.inExtreme then
		self.receiveFinalDamage = true

		self:setDamageNum(self.totalDamage, true)
	else
		self.receiveFinalDamage = nil
	end
end

function ChainAttackCtrl:onKeepChainAttackDamageInfo(duration)
	self.hideDamageTime = Time.realSecondCache + duration
	self.chainAttackDamageState = 3

	self:refreshChainAttackSideBar()
	self:refreshChainState()
end

function ChainAttackCtrl:setDamageNum(totalDamage, forceRefresh)
	if totalDamage == 0 then
		self.view.totalDamageDancer.EndNumber = 0

		self.view.totalDamageDancer:StopDancing(true)

		self.totalDamage = 0
	elseif self.totalDamage ~= totalDamage or forceRefresh then
		self.totalDamage = totalDamage

		if self.receiveFinalDamage then
			ClientTextUtils.setText(self.view.chainTotalDamage, math.floor(totalDamage))
		else
			if self.totalDamage ~= 0 then
				self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			end

			self.view.totalDamageDancer.EndNumber = totalDamage

			self.view.totalDamageDancer:StartDancing()
		end
	end

	self:refreshChainAttackSideBar()
end

function ChainAttackCtrl:refreshChainAttackSideBar()
	local chainAttackDamageState = self.chainAttackDamageState

	self.totalDamage = self.totalDamage or 0

	if chainAttackDamageState ~= 0 then
		if self.totalDamage <= 0 then
			chainAttackDamageState = 0
		elseif self.receiveFinalDamage then
			chainAttackDamageState = 4
		end
	end

	self.view.widget:TryChangePage("QteNum", chainAttackDamageState)
end

function ChainAttackCtrl:refreshChainState()
	local chainInfo = pg.me.chainAttackInfo
	local petList = chainInfo.petList

	if self.resetStateTimer then
		self:killTimer(self.resetStateTimer)

		self.resetStateTimer = nil
	end

	ClientTextUtils.setText(self.view.bonusText, self:getDamageRatio())

	if chainInfo:isInChain() and #petList > 0 then
		self.chainAttackDamageState = #petList

		self:refreshChainAttackSideBar()
	else
		local hideDelay = 2

		if self.hideDamageTime then
			hideDelay = math.max(self.hideDamageTime - Time.realSecondCache, hideDelay)
		end

		self.resetStateTimer = self:startTimer(function()
			self.resetStateTimer = nil
			self.hideDamageTime = nil
			self.chainAttackDamageState = 0

			self:refreshChainAttackSideBar()
		end, hideDelay)
	end
end

function ChainAttackCtrl:updateDamageRatio()
	local chainInfo = pg.me.chainAttackInfo

	if chainInfo:isInChain() then
		self.curDamageRatio = chainInfo:getDamageRatio()
	end
end

function ChainAttackCtrl:getDamageRatio()
	return self.curDamageRatio or 1
end

function ChainAttackCtrl:refreshInfo()
	if not self.view then
		return
	end

	if self.curStage == ClientConst.HUD_BREAK_STAGE.NONE then
		self.view.widget:TryChangePage("QteStage", 0)
	else
		self.view.widget:TryChangePage("QteStage", 3)
	end

	if self.curStage == ClientConst.HUD_BREAK_STAGE.CHOOSE_START or self.curStage == ClientConst.HUD_BREAK_STAGE.QTE or self.curStage == ClientConst.HUD_BREAK_STAGE.CHAIN_BURST then
		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.HUD_BREAK_CTRL, UIConst.UI_BREAK_CTRL_HIDE_WHITELIST)
	else
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.HUD_BREAK_CTRL)
	end
end

function ChainAttackCtrl:startCutsceneTimelineEventCallback(eventParam)
	if not self.startCutscene then
		return
	end

	if self.changeSpeedTimeline then
		self.changeSpeedTimeline:stop()

		self.changeSpeedTimeline = nil
	end

	local startCutsceneEffectTrans = self.startCutscene.cutscene.cutsceneRoot.transform:Find("EffectRoot")
	local effectSpeedComp = startCutsceneEffectTrans:GetComponent("EffectVariableSpeed")

	if string.sub(eventParam, 1, #"speedChange:") == "speedChange:" then
		local speedChangeParam = string.sub(eventParam, #"speedChange:" + 1)
		local params = string.split(speedChangeParam, ",")

		if #params == 2 then
			local toSpeed = tonumber(params[1])
			local blendTime = tonumber(params[2])

			if blendTime > 0 then
				local changeSpeedTimeline = LuaTimeline.new()

				changeSpeedTimeline:setDuration(blendTime)
				changeSpeedTimeline:createAndAddClip(0, blendTime, function(_, curTime)
					if self.startCutscene then
						local speed = math.lerp(1, toSpeed, curTime / blendTime)

						self.startCutscene:setSpeed(speed)

						local virtualEntities = self.startCutscene.virtualEntities

						for i, virtualEnt in ipairs(virtualEntities) do
							virtualEnt:setAnimSpeed(speed)
							virtualEnt:setEffectTimeScale(speed)
						end
					end
				end)
				changeSpeedTimeline:start()

				self.changeSpeedTimeline = changeSpeedTimeline
			else
				self.startCutscene:setSpeed(toSpeed)

				local virtualEntities = self.startCutscene.virtualEntities

				for i, virtualEnt in ipairs(virtualEntities) do
					virtualEnt:setAnimSpeed(toSpeed)
					virtualEnt:setEffectTimeScale(toSpeed)
				end
			end
		end
	end
end

function ChainAttackCtrl:stopChainStartCutscene()
	if self.startCutscene and self.startCutscene:isPlaying() then
		self.startCutscene:destroy()

		self.startCutscene = nil
	end
end

function ChainAttackCtrl:playChainBurstCutscene()
	local cutscenePos = Vector3(-10000, 0, -10000)

	local function bindCallback(cutsceneItem, virtualEntity, bindKey, bindParam)
		local petInfo = {}
		local petPos
		local petScale = 1
		local chainInfo = pg.me.chainAttackInfo
		local petList = chainInfo.petList
		local defaultPetPos = {
			0,
			0,
			0
		}
		local petIndex = 1
		local presetName = "ScreenCutUp"

		if bindParam == "ChainPet1" then
			petIndex = 1
			defaultPetPos = {
				-2.5,
				0,
				0
			}
			presetName = "ScreenCutRight"
		elseif bindParam == "ChainPet2" then
			petIndex = 2
			defaultPetPos = {
				0,
				2.3,
				0
			}
			presetName = "ScreenCutUp"
		elseif bindParam == "ChainPet3" then
			petIndex = 3
			defaultPetPos = {
				2.5,
				0,
				0
			}
			presetName = "ScreenCutLeft"
		end

		local petEntity = pg.getEntity(petList[petIndex])

		petInfo = petEntity and petEntity.getBattlePetInfo and petEntity:getBattlePetInfo() or pg.me:getPetInfo(petList[petIndex])

		local petData = PetData[petInfo.templateId or -1] or {}
		local chainAttackConfig = petData.chainAttackTimelineConfig or {}

		chainAttackConfig = chainAttackConfig[petIndex] or {}
		petPos = chainAttackConfig[1] or defaultPetPos
		petScale = chainAttackConfig[3] or 1

		local chainAttackAnimConfig = petData.chainAttackAnimConfig or {}

		virtualEntity.eModel:SetTransformLocalPosition(petPos[1], petPos[2], petPos[3])
		virtualEntity:setConfigData(petData)
		virtualEntity:setModelLayer(ClientConst.LayerDefine.LAYER_CUTSCENE)

		virtualEntity.templateId = petInfo.templateId

		local modelView = virtualEntity.eModel.modelModelView

		modelView.instPriority = ClientConst.InstantiatePriority.Urgent

		local extraInfo = ClientModelUtils.getModelExtraInfo(petData, petInfo.label or 0, petInfo.gender or 0)

		ClientModelUtils.applyPetAppearance(modelView.modelInfo, petData, extraInfo)
		ClientModelUtils.applyAnimController(virtualEntity, virtualEntity.eModel, petData)
		modelView:RefreshModels()
		virtualEntity:setScaleNumber(petScale)

		local shaderView = modelView.shaderView

		shaderView:SetSurfaceEffect(presetName, true)
		shaderView:SetMultiPassForce32Layer(true, ClientAbilityConst.MULTI_PASS_LAYER)

		local animName = chainAttackAnimConfig[1] or PlayableConst.Attack01
		local animOffset = chainAttackAnimConfig[2] or 0

		virtualEntity:playRawAnimation(animName, nil, animOffset)
		virtualEntity:setFresnelPMEnable(true, "ComboKill")

		return false
	end

	local extraData = {
		applySoundListener = false,
		bindCallback = bindCallback,
		eventCallback = function(cutscene, eventParam)
			if eventParam == "onCutsceneEnd" then
				pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.HUD_BREAK_CTRL_BURST)

				if self.resetCallback then
					self:killTimer(self.resetCallback)
				end

				self.view.damagePanel.visibility = CS.XGUI.EVisibility.Visible

				self:resetChainBurstState()
			end
		end
	}

	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.HUD_BREAK_CTRL_BURST, UIConst.UI_BREAK_CTRL_HIDE_WHITELIST)

	self.view.damagePanel.visibility = CS.XGUI.EVisibility.Hidden

	local cutsceneItem = pg.game.cutscene:playCutscene("chainAttackBurst", AddressDataConst.CHAIN_ATTACK_BURST_TIMELINE, cutscenePos, nil, nil, nil, extraData)
end

function ChainAttackCtrl:triggerExtremeChainV2(petList)
	self.petList = petList

	if self.resetCallback then
		self:killTimer(self.resetCallback)
	end

	self:playChainBurstCutsceneV2(petList)
	self:showChainBurstImage()
	self.view.qteLineUComponent:TryChangePage("Type", #petList == CHAIN_MAX_NUM and 1 or 0)

	self.resetCallback = self:startTimer(function()
		self.curStage = ClientConst.HUD_BREAK_STAGE.NONE

		self:refreshInfo()
	end, 4)
end

function ChainAttackCtrl:playChainBurstCutsceneV2(petList)
	local cutscenePos = Vector3(-10000, 0, -10000)
	local petCount = #petList

	local function bindCallback(cutsceneItem, virtualEntity, bindKey, bindParam)
		local petIndex, presetName = self:getPresetInfoByParam(bindParam, petCount)
		local petEnt = pg.getEntity(petList[petIndex])

		if not petEnt then
			return
		end

		local petData = PetData[petEnt.templateId or -1]

		if not petData then
			return
		end

		local chainAttackConfig = petData.chainAttackTimelineConfig

		if petCount == CHAIN_MAX_NUM then
			chainAttackConfig = petData.chainAttackTimelineConfigV4
		end

		chainAttackConfig = chainAttackConfig and chainAttackConfig[petIndex] or nil

		local petPos = chainAttackConfig and chainAttackConfig[1] or Vector3.constZero
		local petRot = chainAttackConfig and chainAttackConfig[2] or Vector3.constZero
		local petScale = chainAttackConfig and chainAttackConfig[3] or 1
		local chainAttackAnimConfig = petData.chainAttackAnimConfig

		petPos = Vector3(petPos[1], petPos[2], petPos[3])
		petRot = Quaternion.Euler(petRot[1], petRot[2], petRot[3])

		virtualEntity.eModel:SetLocalPosition(petPos[1], petPos[2], petPos[3])
		virtualEntity:setConfigData(petData)
		virtualEntity:setModelLayer(ClientConst.LayerDefine.LAYER_CUTSCENE)

		virtualEntity.templateId = petEnt.templateId

		local modelView = virtualEntity.eModel.modelModelView

		modelView.instPriority = ClientConst.InstantiatePriority.Urgent

		local extraInfo = ClientModelUtils.getModelExtraInfo(petData, petEnt.label or 0, petEnt.gender or 0)

		ClientModelUtils.applyPetAppearance(modelView.modelInfo, petData, extraInfo)
		ClientModelUtils.applyAnimController(virtualEntity, virtualEntity.eModel, petData)
		virtualEntity:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
		virtualEntity:setRendererLod(0)

		local animName = chainAttackAnimConfig and chainAttackAnimConfig[1] or PlayableConst.Attack01
		local animOffset = chainAttackAnimConfig and chainAttackAnimConfig[2] or 0

		virtualEntity:playRawAnimation(animName, 0, animOffset)
		modelView:RefreshModels()
		virtualEntity:setScaleNumber(petScale)

		local shaderView = modelView.shaderView

		shaderView:SetSurfaceEffect(presetName, true)
		shaderView:SetMultiPassForce32Layer(true, ClientAbilityConst.MULTI_PASS_LAYER)
		virtualEntity:setFresnelPMEnable(true, "ComboKill")

		return false
	end

	local extraData = {
		applySoundListener = false,
		bindCallback = bindCallback,
		eventCallback = function(cutscene, eventParam)
			if eventParam == "onCutsceneEnd" then
				pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.HUD_BREAK_CTRL_BURST)

				if self.resetCallback then
					self:killTimer(self.resetCallback)
				end

				self.view.damagePanel.visibility = CS.XGUI.EVisibility.Visible

				self:resetChainBurstState()
			end
		end
	}

	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.HUD_BREAK_CTRL_BURST, UIConst.UI_BREAK_CTRL_HIDE_WHITELIST)

	self.view.damagePanel.visibility = CS.XGUI.EVisibility.Hidden

	local timelineAsset = petCount == CHAIN_MAX_NUM and AddressDataConst.CHAIN_ATTACK_BURST_TIMELINE_V4 or AddressDataConst.CHAIN_ATTACK_BURST_TIMELINE
	local cutsceneItem = pg.game.cutscene:playCutscene("chainAttackBurst", timelineAsset, cutscenePos, nil, nil, nil, extraData)
end

function ChainAttackCtrl:getPresetInfoByParam(bindParam, petCount)
	if petCount == CHAIN_MAX_NUM then
		if bindParam == "ChainPet1" then
			return 1, "ScreenCut_4_1"
		elseif bindParam == "ChainPet2" then
			return 2, "ScreenCut_4_2"
		elseif bindParam == "ChainPet3" then
			return 3, "ScreenCut_4_3"
		elseif bindParam == "ChainPet4" then
			return 4, "ScreenCut_4_4"
		end
	elseif bindParam == "ChainPet1" then
		return 1, "ScreenCut_3_3"
	elseif bindParam == "ChainPet2" then
		return 2, "ScreenCut_3_1"
	elseif bindParam == "ChainPet3" then
		return 3, "ScreenCut_3_2"
	end

	return 1, "ScreenCut_3_1"
end

function ChainAttackCtrl:onEntBreakStateChange(data)
	if not self.view then
		return
	end

	if data.isInit then
		return
	end

	local ent = data.ent
	local isBreak = data.isBreak

	if isBreak and not ent:isFakeDead() then
		if pg.me.lockedActorId == ent.actorId then
			if self.curStage == ClientConst.HUD_BREAK_STAGE.NONE then
				pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonHigh")
			end
		elseif pg.pawn.actorId == ent.actorId and pg.me.space:isPvpEnv() then
			pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonHigh")
		end
	end
end

return ChainAttackCtrl
