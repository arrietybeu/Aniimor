-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\TempleScene.lua

local BaseScene = require("GameApp.Scenes.BaseScene")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local TempleScene = Class.LightClass("TempleScene", BaseScene)

function TempleScene:onCtor()
	self.models = {}
end

function TempleScene:onStart()
	pg.game:setModuleEnable("TEMPLE_MODE", ClientConst.ModuleKey.Map, false)
	pg.game:setModuleEnable("TEMPLE_MODE", ClientConst.ModuleKey.BallAndItem, false)
end

function TempleScene:onLoaded()
	return
end

function TempleScene:onDestroy()
	pg.game:setModuleEnable("TEMPLE_MODE", ClientConst.ModuleKey.Map, true)
	pg.game:setModuleEnable("TEMPLE_MODE", ClientConst.ModuleKey.BallAndItem, true)
end

return TempleScene
