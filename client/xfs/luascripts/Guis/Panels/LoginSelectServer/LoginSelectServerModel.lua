-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LoginSelectServer\\LoginSelectServerModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("LoginSelectServerModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local LoginSelectServerModel = Class.LightClass("LoginSelectServerModel", UIModel)
local ClientRepo = require("Core.Client.ClientRepo")

function LoginSelectServerModel.getServerListData()
	return ClientRepo.netHandler:getServerList() or {}
end

return LoginSelectServerModel
