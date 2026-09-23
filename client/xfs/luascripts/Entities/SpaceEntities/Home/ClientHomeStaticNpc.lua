-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeStaticNpc.lua

local Class = require("Core.Framework.Class")
local ClientHomelandComponent = require("Entities.SpaceEntities.Home.ClientHomelandComponent")
local ClientStaticNpc = require("Entities.SpaceEntities.ClientStaticNpc")
local ClientHomeStaticNpc = Class.Class("ClientHomeStaticNpc", ClientStaticNpc)
local ClientHomeStaticNpcComponents = {
	ClientHomelandComponent
}

Class.AddComponents(ClientHomeStaticNpc, ClientHomeStaticNpcComponents)

return ClientHomeStaticNpc
