-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BlackBg\\BlackBgCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local BlackBgCtrl = Class.LightClass("BlackBgCtrl", UICtrl)

BlackBgCtrl.DEFAULT_HOLD_DURATION = 1

function BlackBgCtrl:ctor()
	UICtrl.ctor(self)

	self._owners = {}
	self._ownerTimers = {}
end

function BlackBgCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:refreshBackground()
end

function BlackBgCtrl:showBackground(owner, duration)
	if owner == nil then
		return false
	end

	self:clearOwnerTimer(owner)

	self._owners[owner] = true
	self._ownerTimers[owner] = self:startTimer(function()
		self._ownerTimers[owner] = nil
		self._owners[owner] = nil

		self:refreshBackground()
	end, duration or BlackBgCtrl.DEFAULT_HOLD_DURATION)

	self:refreshBackground()

	return true
end

function BlackBgCtrl:hideBackground(owner)
	if owner == nil then
		for ownerItem, _ in pairs(self._ownerTimers) do
			self:clearOwnerTimer(ownerItem)
		end

		self._owners = {}
	else
		self:clearOwnerTimer(owner)

		self._owners[owner] = nil
	end

	self:refreshBackground()
end

function BlackBgCtrl:clearOwnerTimer(owner)
	local timerId = self._ownerTimers[owner]

	if timerId then
		self:killTimer(timerId)

		self._ownerTimers[owner] = nil
	end
end

function BlackBgCtrl:clearInvalidOwners()
	for owner, _ in pairs(self._owners) do
		if owner.checkUIOpen == nil or not owner:checkUIOpen() then
			self:clearOwnerTimer(owner)

			self._owners[owner] = nil
		end
	end
end

function BlackBgCtrl:refreshBackground()
	self:clearInvalidOwners()

	if self.view and NotNil(self.view.blackBgImage) then
		self.view.blackBgImage.gameObject:SetActiveEx(next(self._owners) ~= nil)
	end
end

return BlackBgCtrl
