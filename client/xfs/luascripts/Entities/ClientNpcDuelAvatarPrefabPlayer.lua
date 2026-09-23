-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientNpcDuelAvatarPrefabPlayer.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientNpcDuelAvatarPrefabPlayer = Class.Class("ClientNpcDuelAvatarPrefabPlayer", ClientSimpleVirtualPlayer)

function ClientNpcDuelAvatarPrefabPlayer:init(dict)
	ClientNpcDuelAvatarPrefabPlayer.super.init(self, dict)

	self.avatarPrefabResID = dict and dict.avatarPrefabResID
end

function ClientNpcDuelAvatarPrefabPlayer:refreshAppearance()
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
	modelView:RefreshModels()
end

function ClientNpcDuelAvatarPrefabPlayer:onAnimatorReady()
	return
end

return ClientNpcDuelAvatarPrefabPlayer
