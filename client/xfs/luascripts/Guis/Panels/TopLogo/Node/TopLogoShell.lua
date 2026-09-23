-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoShell.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local csTopLogoManager = CS.FunPlus.WorldX.GUIS.Panels.TopLogo.TopLogoManager
local TopLogoShell = Class.LightClass("TopLogoShell")

function TopLogoShell:ctor(entity)
	self.entity = entity
	self.shellState = nil

	local manager = csTopLogoManager.Instance

	if manager then
		self.shellState = manager:RegisterShell(entity.actorId)
	end
end

function TopLogoShell:isEntityAlive()
	return self.shellState ~= nil and self.shellState.isEntityAlive
end

function TopLogoShell:isInViewport()
	return self.shellState ~= nil and self.shellState.isInViewport
end

function TopLogoShell:isInViewportStable()
	return self.shellState ~= nil and self.shellState.isInViewportStable
end

function TopLogoShell:isBlocked()
	return self.shellState ~= nil and self.shellState.isBlocked
end

function TopLogoShell:enableRaycast()
	if self.shellState then
		self.shellState:EnableRaycast()
	end
end

function TopLogoShell:disableRaycast()
	if self.shellState then
		self.shellState:DisableRaycast()
	end
end

function TopLogoShell:setFollowStrategy(strategy)
	if self.shellState then
		self.shellState:SetFollowStrategy(strategy or 0)
	end
end

function TopLogoShell:setWorldOffsetY(y)
	if self.shellState then
		self.shellState:SetWorldOffsetY(y or 0)
	end
end

function TopLogoShell:setMaxDistance(dist)
	if self.shellState then
		self.shellState:SetMaxDistance(dist or UIConst.TopLogoEnterRange)
	end
end

function TopLogoShell:isInRange()
	return self.shellState == nil or self.shellState.isInRange
end

function TopLogoShell:getDistance()
	return self.entity:getPlayerDistance()
end

function TopLogoShell:destroy()
	local manager = csTopLogoManager.Instance

	if manager and self.entity then
		manager:UnregisterShell(self.entity.actorId)
	end

	self.shellState = nil
	self.entity = nil
end

return TopLogoShell
