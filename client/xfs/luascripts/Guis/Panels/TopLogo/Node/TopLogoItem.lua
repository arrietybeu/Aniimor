-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItem.lua

local Class = require("Core.Framework.Class")
local TopLogoItemBase = require("Guis.Panels.TopLogo.Node.TopLogoItemBase")
local AddressDataConst = require("Const.AddressDataConst")
local RuntimeTopLogoName = "TopLogo"
local TopLogoSuffixUnUse = "_UnUse"
local TopLogoSuffixUse = "_Use"
local TopLogoItem = Class.LightClass("TopLogoItem", TopLogoItemBase)

function TopLogoItem:ctor(entity)
	TopLogoItem.super.ctor(self)

	self.entity = entity
	self.partId = 0
	self.resId = self.resId or AddressDataConst.TOPLOGO_TOP_RESID
end

function TopLogoItem:getTopLogoGlobalId()
	if self.entity ~= nil then
		return self.entity:getGlobalId()
	else
		return TopLogoItem.super.getTopLogoGlobalId(self)
	end
end

function TopLogoItem:destroy()
	TopLogoItem.super.destroy(self)
end

function TopLogoItem:getTopLogoName()
	local usePost = self.topLogoScript == nil and TopLogoSuffixUnUse or TopLogoSuffixUse
	local actorType = self.entity.actorType or "-1"

	return RuntimeTopLogoName .. self.entity.actorId .. "_" .. actorType .. usePost
end

function TopLogoItem:initTopLogoAttach()
	self:setTopLogoAttachTrans(self.partId)
end

local _offset = Vector3(0, 0, 0)
local _zero = Vector2.zero

function TopLogoItem:setTopLogoAttachTrans(partId)
	self.partId = partId or 0

	local eModel = self.entity.eModel

	if eModel == nil then
		return
	end

	if NotNil(self.topLogoScript) then
		local offset = self.entity.topLogoData.height
		local strategy = self.entity.topLogoData.strategy

		_offset[2] = offset or 0

		self.topLogoScript:SetOffset(_offset, _zero)
		self.topLogoScript:AttachToEntity(eModel, strategy)
	end
end

function TopLogoItem:createTopLogo(callback, topLogoScript)
	if self:checkCreate() then
		return
	end

	self.entity:clearTopLogoState()
	TopLogoItem.super.createTopLogo(self, callback, topLogoScript)
end

function TopLogoItem:onTopLogoLoaded()
	TopLogoItem.super.onTopLogoLoaded(self)
end

function TopLogoItem:onActiveCompsNonEmpty()
	if self.entity and not self.entity.topLogoCreated then
		self.entity:showTopLogoEx(nil, "active_component_wake")
	end
end

return TopLogoItem
