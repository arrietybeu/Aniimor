-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientShadowVirtualEntity.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AddressDataConst = require("Const.AddressDataConst")
local ClientShadowVirtualEntity = Class.Class("ClientShadowVirtualEntity", ClientVirtualEntity)
local ClientShadowComponent = require("Entities.SpaceEntities.CommonComponent.ClientShadowComponent")

Class.AddComponent(ClientShadowVirtualEntity, ClientShadowComponent)

function ClientShadowVirtualEntity:init(dict)
	if dict then
		self.mainEnt = dict.mainEnt
	end
end

function ClientShadowVirtualEntity:refreshAppearance()
	if not self.eModel then
		return
	end

	self:setModelLayer(ClientConst.LayerDefine.LAYER_DEFAULT)

	local configData = self.mainEnt:getConfigData()
	local modelView = self.eModel.modelModelView
	local extraData = ClientModelUtils.getModelExtraInfo(configData, 0, nil, nil, "_shadow")

	if pg.global.resMgr:CheckAssetExist(extraData.prefabResID) then
		ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	else
		extraData = ClientModelUtils.getModelExtraInfo(configData, 0, nil, nil)

		ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
		modelView.shaderView:SetTransparent(AddressDataConst.MAT_ENERGY_BODY, true)
	end

	modelView:RefreshModels()
end

return ClientShadowVirtualEntity
