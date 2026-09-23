-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\ConfigParser.lua

local EntityFactory = require("Core.Common.EntityFactory")
local PropertyParser = require("Core.Common.PropertyParser")
local RpcArgValidator = require("Core.Common.RpcArgValidator")
local ConfigParser = {}

function ConfigParser.parseConfig(path)
	local config = require(path)

	RpcArgValidator.parseArgTypes(config)

	local RpcSendValidator = require("Core.Common.RpcSendValidator")

	RpcSendValidator.init()
	EntityFactory.parseCustomTypesComponent(config)
	PropertyParser.parseCustomTypes(config)
	EntityFactory.parseComponent(config)
	PropertyParser.parseComponent(config)
	EntityFactory.parseEntity(config)
	PropertyParser.parseEntity(config)
	EntityFactory.parseUniversal(config)
	PropertyParser.parseUniversal(config)
end

function ConfigParser.parseRpc(path)
	local RpcIndex = require("Core.Common.RpcIndex")
	local config = require(path)

	for name, _ in pairs(config) do
		RpcIndex.registerRpc(name)
	end
end

return ConfigParser
