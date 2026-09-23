-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\CallbackContext.lua

local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local CallbackContext = class.Class("CallbackContext")
local logger = LoggerManager.getLogger("CallbackContext")

function CallbackContext:ctor(entity, callbackid)
	self.entity = entity
	self.callbackid = callbackid
end

function CallbackContext:sendResponse(parameters)
	if self.callbackid == nil or self.callbackid == 0 then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("%s sendResponse with invalid rid -1", tostring(self.entity:repr()))
		end

		return
	end

	self.entity:clientMsg("RPC_SC_OnServerMsgCallabck", self.callbackid, parameters)
end

return CallbackContext
