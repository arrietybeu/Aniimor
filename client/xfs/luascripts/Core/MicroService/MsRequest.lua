-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\MicroService\\MsRequest.lua

local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local SafeCallback = require("Core.Framework.SafeCallback")
local MsContext = require("Core.MicroService.MsContext")
local MsRequest = class.LightClass("MsRequest")

function MsRequest:ctor(rid, serviceName, methodName, args, callback, options, msContext)
	self.rid = rid
	self.serviceName = serviceName
	self.methodName = methodName
	self.args = args
	self.callback = callback
	self.callerId = ""
	self.options = options or {}
	self.msContext = msContext or MsContext()

	local timeout = options and options.timeout or 0

	if self.callback ~= nil and timeout <= 0 then
		timeout = 60
	end

	if timeout and timeout > 0 then
		self.timeout = timeout
		self.expireAt = Time.realSecondCache * 1000 + timeout * 1000
	else
		self.timeout = 0
		self.expireAt = 0
	end
end

function MsRequest:onResponse(retStatus, response)
	if self.callback ~= nil then
		SafeCallback(self.callback, retStatus, response)
	elseif self.options.callbackInfo ~= nil then
		self:onPlayerResponseOrTimeout(retStatus, response)
	end
end

function MsRequest:onTimeout()
	if self.callback ~= nil then
		local retStatus = {
			status = false,
			errmsg = "request timeout"
		}

		SafeCallback(self.callback, retStatus)
	elseif self.options.callbackInfo ~= nil then
		self:onPlayerResponseOrTimeout({
			status = false,
			errmsg = "request timeout"
		}, nil)
	end
end

function MsRequest:onPlayerResponseOrTimeout(retStatus, response)
	if self.options.callbackInfo ~= nil then
		local playerMailBox = self.options.callbackInfo.playerMailBox

		if playerMailBox ~= nil then
			local EntityManager = require("Core.Common.EntityManager")
			local player = EntityManager.getEntity(playerMailBox.id)

			if player ~= nil then
				self.options.callbackInfo.rid = nil

				if response ~= nil then
					response.Ret = {
						retStatus.status,
						retStatus.errmsg
					}

					SafeCallback(player.Role2Player_TransferServiceCallbackMsg, player, self.options.callbackInfo, response)
				else
					SafeCallback(player.Role2Player_TransferServiceCallbackMsg, player, self.options.callbackInfo, {
						Ret = {
							retStatus.status,
							retStatus.errmsg
						}
					})
				end
			end
		end
	end
end

return MsRequest
