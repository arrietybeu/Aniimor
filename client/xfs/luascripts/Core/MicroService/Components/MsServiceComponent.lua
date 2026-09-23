-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\MicroService\\Components\\MsServiceComponent.lua

local class = require("Core.Framework.Class")
local MsServiceComponent = class.Component("MsServiceComponent")

function MsServiceComponent:ctor()
	self.extraConnect = false
end

function MsServiceComponent:init()
	return true
end

function MsServiceComponent:setExtraConnect()
	self.extraConnect = true
end

function MsServiceComponent:isExtraConnect()
	return self.extraConnect
end

function MsServiceComponent:regPushServiceHandler(serviceName, pushServiceHandler)
	self.serviceMgr:regPushServiceHandler(serviceName, pushServiceHandler)
end

function MsServiceComponent:getRequestInfo(rid)
	return self.serviceMgr:getRequestInfo(rid)
end

function MsServiceComponent:delRequestCallback(rid)
	self.serviceMgr:delRequestCallback(rid)
end

function MsServiceComponent:callService(serviceName, methodName, args, callback, options)
	return self.serviceMgr:callService(serviceName, methodName, args, callback, options)
end

function MsServiceComponent:onResponse(rid, retStatus, response)
	self.serviceMgr:onResponse(rid, retStatus, response)
end

function MsServiceComponent:onPush(orgType, targetIds, msgUUId, serviceName, methodName, parameters)
	self.serviceMgr:onPush(orgType, targetIds, msgUUId, serviceName, methodName, parameters)
end

return MsServiceComponent
