-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientScreenComponent.lua

local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local ItemConstSourceData = require("Data.item_const_source_data")
local TotemUpgradeData = require("Data.totem_upgrade_data")
local EventConst = require("Const.EventConst")
local ClientScreenComponent = Class.Component("ClientScreenComponent")

function ClientScreenComponent:ctor()
	return
end

function ClientScreenComponent:RPC_SC_SyncArkScreenInfo(screenInfo)
	self.arkScreenInfoMap = screenInfo
end

return ClientScreenComponent
