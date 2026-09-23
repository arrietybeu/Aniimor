-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientPvpBotPlayer.lua

local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local AvatarData = require("Data.avatar_data")
local Const = require("Common.Const.Const")
local EventConst = require("Const.EventConst")
local ClientPlayer = require("Entities.SpaceEntities.ClientPlayer")
local ClientPvpBotPlayer = class.Class("ClientPvpBotPlayer", ClientPlayer)
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
	ClientDispatcherComponent
}

class.AddComponents(ClientPvpBotPlayer, Components)

function ClientPvpBotPlayer:ctor(entityId)
	ClientPvpBotPlayer.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_PLAYER
end

function ClientPvpBotPlayer:init(bdict)
	ClientPvpBotPlayer.super.init(self, bdict)

	self.forbiddenTopLogo = false

	return true
end

function ClientPvpBotPlayer:start()
	ClientPvpBotPlayer.super.start(self)

	if FREE_WALK then
		return
	end
end

function ClientPvpBotPlayer:destroy()
	ClientPvpBotPlayer.super.destroy(self)
end

function ClientPvpBotPlayer:tick(deltaTime)
	self:postComponentMethod("tick", deltaTime)
end

function ClientPvpBotPlayer:getConfigData()
	return AvatarData[self.templateId] or {}
end

function ClientPvpBotPlayer:refreshAppearance(forceRefreshPlayable)
	if not self.eModel then
		return
	end

	self:setModelLayer()

	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView
	local presetKey = pg.game.avatar:getPresetKey(self)

	ClientModelUtils.initModelInfoByConfig(self, presetKey)
	self:tryApplyRandomClothes()
	modelView:RefreshModels()
end

function ClientPvpBotPlayer:tryApplyRandomClothes()
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

function ClientPvpBotPlayer:serverMsg(name, ...)
	if pg.me == nil then
		self.logger:warn("%s call serverMsg %s, but main player is nil", self:repr(), name)

		return
	end

	pg.me:serverMsg("RPC_CS_TransferBotPlayerMsg", self.id, name, {
		...
	})
end

function ClientPvpBotPlayer:transferPetServerMsg(petId, name, ...)
	if pg.me == nil then
		self.logger:warn("%s call serverMsg %s, but main player is nil", self:repr(), name)

		return
	end

	pg.me:serverMsg("RPC_CS_TransferBotPlayerMsg", petId, name, {
		...
	})
end

return ClientPvpBotPlayer
