-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemFocusIndicator.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local TopLogoItemNoEntity = require("Guis.Panels.TopLogo.Node.TopLogoItemNoEntity")
local TopLogoItemFocusIndicator = Class.LightClass("TopLogoItemFocusIndicator", TopLogoItemNoEntity)

function TopLogoItemFocusIndicator:ctor(attachTrans, eModel)
	self.eModel = eModel
	self.resId = AddressDataConst.TOPLOGO_TOP_RESID

	TopLogoItemFocusIndicator.super.ctor(self, attachTrans, 9999)
end

function TopLogoItemFocusIndicator:getTopLogoName()
	return "FocusIndicator"
end

function TopLogoItemFocusIndicator:destroy()
	TopLogoItemFocusIndicator.super.destroy(self)

	self.eModel = nil
end

function TopLogoItemFocusIndicator:onTopLogoDestroy()
	self.focusContainer = nil

	TopLogoItemFocusIndicator.super.onTopLogoDestroy(self)
end

function TopLogoItemFocusIndicator:initTopLogoAttach()
	if not self.topLogoScript then
		return
	end

	self.topLogoScript.maxDistance = self.maxDistance

	if self.eModel then
		local offset = Vector3(0, 0.3, 0)

		self.topLogoScript:SetOffset(offset, Vector2.zero)
		self.topLogoScript:AttachToEntity(self.eModel, ClientConst.TopLogoFollowStrategy.FxRoot)
	else
		self.topLogoScript:AttachToTrans(self.attachTrans)
	end
end

function TopLogoItemFocusIndicator:refreshTopLogoItemOnLoaded()
	self:loadFocusContainer()
end

function TopLogoItemFocusIndicator:loadFocusContainer()
	if self.focusContainer then
		return
	end

	self:getOrAddCompRootContainer(UIConst.TOPLOGO_COMPONENT.FOCUS, function(rootContainer)
		if self.isDestroyed or not rootContainer or IsNil(rootContainer) then
			return
		end

		self.focusContainer = rootContainer
		rootContainer.IsEnableAdaptChildRectSize = true
		rootContainer.defaultUrl = AddressDataConst.TOPLOGO_COMP_RES_FOCUS

		rootContainer:LoadDefaultUrlManually(function(content)
			if content and not self.isDestroyed and self.focusContainer == rootContainer and NotNil(rootContainer) then
				rootContainer:SetActive(true)
			end
		end)
	end)
end

return TopLogoItemFocusIndicator
