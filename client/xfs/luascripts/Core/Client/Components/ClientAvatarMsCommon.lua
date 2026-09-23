-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Client\\Components\\ClientAvatarMsCommon.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientRepo = require("Core.Client.ClientRepo")
local GlobalData = require("Core.Client.GlobalData")
local ClientAvatarMsCommon = class.Component("ClientAvatarMsCommon")

function ClientAvatarMsCommon:ctor()
	self.pushHandler = nil
	self.bindCallback = nil
end

function ClientAvatarMsCommon:init(avtDict)
	return true
end

function ClientAvatarMsCommon:start()
	self:bindGlobalMsGate()
	self:bindExtraGlobalMsGate()
end

function ClientAvatarMsCommon:destroy()
	return
end

function ClientAvatarMsCommon:rebind()
	return
end

function ClientAvatarMsCommon:bindGlobalMsGate()
	if GlobalData.LastBindMsUid ~= self.uid then
		ClientRepo.loginAgent:bindGlobalMsGate(self.uid, self.msAuth)
	end
end

function ClientAvatarMsCommon:bindExtraGlobalMsGate()
	if GlobalData.LastBindExtraMsUid ~= self.uid then
		ClientRepo.loginAgent:bindExtraGlobalMsGate(self.uid, self.msAuth)
	end
end

function ClientAvatarMsCommon:on_msAuth_changed(newVal, oldVal)
	self:bindGlobalMsGate()
	self:bindExtraGlobalMsGate()
end

function ClientAvatarMsCommon:refreshAuth()
	self:serverMsg("RPC_CS_Avatar_RefreshAuth")
end

return ClientAvatarMsCommon
