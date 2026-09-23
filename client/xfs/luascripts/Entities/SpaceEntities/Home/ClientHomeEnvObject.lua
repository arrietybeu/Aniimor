-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeEnvObject.lua

local Class = require("Core.Framework.Class")
local ClientEnvObject = require("Entities.SpaceEntities.ClientEnvObject")
local ClientHomelandComponent = require("Entities.SpaceEntities.Home.ClientHomelandComponent")
local ClientHomeEnvObject = Class.Class("ClientHomeEnvObject", ClientEnvObject)
local ClientHomeEnvObjectComponents = {
	ClientHomelandComponent
}

Class.AddComponents(ClientHomeEnvObject, ClientHomeEnvObjectComponents)

return ClientHomeEnvObject
