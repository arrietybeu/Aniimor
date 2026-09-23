-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientDungeonBotPlayer.lua

local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local AvatarData = require("Data.avatar_data")
local Const = require("Common.Const.Const")
local EventConst = require("Const.EventConst")
local ClientPlayer = require("Entities.SpaceEntities.ClientPlayer")
local ClientDungeonBotPlayer = class.Class("ClientDungeonBotPlayer", ClientPlayer)
local AIComponent = require("Common.Components.AIComponent")
local AIPlanComponent = require("Common.Components.AIPlanComponent")
local AIGroupBehaviorComponent = require("Common.Components.AIGroupBehaviorComponent")
local AIPlanDynamicComponent = require("Common.Components.AIPlanDynamicComponent")
local AdditiveAIComponent = require("Common.Components.AdditiveAIComponent")
local Utils = require("Common.Utils.Utils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientMotionComponent = require("Entities.SpaceEntities.CommonComponent.ClientMotionComponent")
local ClientPetsFormationComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPetsFormationComponent")
local ClientDispatcherComponent = require("Entities.SpaceEntities.PlayerComponent.ClientDispatcherComponent")
local ClientEducationComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEducationComponent")
local ClientChainAttackComponent = require("Entities.SpaceEntities.PlayerComponent.ClientChainAttackComponent")
local AppearanceData = require("Data.appearance_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local ClientConst = require("Const.ClientConst")
local ClientEcologyComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcologyComponent")
local RealAvatarRobotData = require("Data.real_avatar_robot_data")
local AiConst = require("Common.Const.AiConst")
local AIUtils = require("Common.Utils.AIUtils")
local Components = {
	AIComponent,
	AIPlanComponent,
	AIGroupBehaviorComponent,
	AIPlanDynamicComponent,
	AdditiveAIComponent,
	ClientPetsFormationComponent,
	ClientMotionComponent,
	ClientEducationComponent,
	ClientChainAttackComponent,
	ClientDispatcherComponent,
	ClientEcologyComponent
}

class.AddComponents(ClientDungeonBotPlayer, Components)

function ClientDungeonBotPlayer:ctor(entityId)
	ClientDungeonBotPlayer.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_BOTPLAYER
	self.isDungeonBot = true
end

function ClientDungeonBotPlayer:init(bdict)
	ClientDungeonBotPlayer.super.init(self, bdict)

	self.forbiddenTopLogo = false

	return true
end

function ClientDungeonBotPlayer:initializeComponents()
	ClientDungeonBotPlayer.super.initializeComponents(self)
	self:addEModelComponent(Const.COMPONENT_MOTION)

	if self.authority == Const.AUTHORITY_MASTER then
		self:addEModelComponent(Const.COMPONENT_AI_CONTROLLER)
		self:addEModelComponent(Const.COMPONENT_AUTO_PATH_FIND)
	end
end

function ClientDungeonBotPlayer:postInitializeComponents()
	ClientDungeonBotPlayer.super.postInitializeComponents(self)
	self:applyMotionProp()
end

function ClientDungeonBotPlayer:postInit(dict)
	ClientDungeonBotPlayer.super.postInit(self, dict)

	local pdd = self:getConfigData()

	if not EnableBotTest then
		local bTree = pdd.bTree

		if bTree then
			self:setBtName(pdd.bTree)
		end
	end
end

function ClientDungeonBotPlayer:start()
	ClientDungeonBotPlayer.super.start(self)

	if pg.space and pg.space:isNpcDuel() then
		AIUtils.pauseBt(self, AiConst.PauseBtReason.NpcDuelStart)
	end

	if FREE_WALK then
		return
	end
end

function ClientDungeonBotPlayer:destroy()
	ClientDungeonBotPlayer.super.destroy(self)
end

function ClientDungeonBotPlayer:onEnterSpace()
	ClientPlayer.super.onEnterSpace(self)

	if self.space:isBossRushEnv() then
		self:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
	end
end

function ClientDungeonBotPlayer:tick(deltaTime)
	self:postComponentMethod("tick", deltaTime)
end

function ClientDungeonBotPlayer:getConfigData()
	return RealAvatarRobotData[self.botTemplateId] or AiConst.DefaultNullTable
end

function ClientDungeonBotPlayer:refreshAppearance(forceRefreshPlayable)
	if not self.eModel then
		return
	end

	self:setModelLayer()
	self.eModel:SetClientReady(true)

	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView
	local modelInfo = modelView.modelInfo

	modelInfo:ClearInfo()

	modelInfo.height = configData.topbarHeight or configData.modelHeight or 1.5
	modelInfo.physiqueModelInfo.modelPathID = self.avatarPrefabResID or configData.prefabResID or ""
	modelInfo.physiqueModelInfo.modelInfoPathID = ""
	modelInfo.physiqueModelInfo.animControllerAssetID = ClientModelUtils.getAnimController(configData)
	modelInfo.physiqueModelInfo.modelScale = configData.modelScale or 1
	modelInfo.physiqueModelInfo.modelNeedBones = false
	modelInfo.physiqueModelInfo.isAlwaysAnimate = true

	self.eModel:AddShadowComp(ClientConst.ShadowPriority.Appearance)
	self:setRendererLod(0)
	modelView:RefreshModels()
end

function ClientDungeonBotPlayer:tryApplyRandomClothes()
	if not self.randomSuitId then
		local allSuitIds = {}

		for suitId, suitData in pairs(AppearanceSuitData) do
			if suitData.body and table.contains(suitData.body, self.body) then
				table.insert(allSuitIds, suitId)
			end
		end

		local suitCount = #allSuitIds

		if suitCount > 0 then
			local index = math.random(1, suitCount)

			self.randomSuitId = allSuitIds[index]
		end
	end

	if self.randomSuitId then
		local clothesIdList = AppearanceSuitData[self.randomSuitId].appearanceList or {}

		for _, clothesId in ipairs(clothesIdList) do
			local clothesData = AppearanceData[clothesId]

			if clothesData then
				self.eModel.modelModelView.modelInfo.partModelInfo:ModifyPartItem(clothesData.res, Utils.deepCopyTable(clothesData.points))
			end
		end
	end
end

function ClientDungeonBotPlayer:RPC_SC_Portal_Success()
	return
end

function ClientDungeonBotPlayer:RPC_SC_BossRushGotoGuanka(code)
	return
end

function ClientDungeonBotPlayer:serverMsg(name, ...)
	if pg.me == nil then
		self.logger:warn("%s call serverMsg %s, but main player is nil", self:repr(), name)

		return
	end

	pg.me:serverMsg("RPC_CS_TransferBotPlayerMsg", self.id, name, {
		...
	})
end

function ClientDungeonBotPlayer:transferPetServerMsg(petId, name, ...)
	if pg.me == nil then
		self.logger:warn("%s call serverMsg %s, but main player is nil", self:repr(), name)

		return
	end

	pg.me:serverMsg("RPC_CS_TransferBotPlayerMsg", petId, name, {
		...
	})
end

return ClientDungeonBotPlayer
