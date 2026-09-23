-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeAttachSoundComponent.lua

local Class = require("Core.Framework.Class")
local ClientHomeAttachSoundComponent = Class.Component("ClientHomeAttachSoundComponent")

function ClientHomeAttachSoundComponent:ctor()
	self.attachSound = nil
end

function ClientHomeAttachSoundComponent:start()
	local configData = self:getConfigData()

	if not configData or not configData.attachSound then
		return
	end

	self.attachSound = configData.attachSound

	if configData.attachSoundVolumeRatio ~= nil then
		self:setSoundOutputBusVolume(configData.attachSoundVolumeRatio)
	end

	self:playSoundEvent(self.attachSound)
end

function ClientHomeAttachSoundComponent:preDestroy()
	if not self.attachSound then
		return
	end

	self:stopSoundEvent(self.attachSound, 0)
	self:setSoundOutputBusVolume(1)
end

function ClientHomeAttachSoundComponent:destroy()
	self.attachSound = nil
end

return ClientHomeAttachSoundComponent
