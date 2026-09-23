-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\PVPScene.lua

local BaseScene = require("GameApp.Scenes.BaseScene")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local SimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientConst = require("Const.ClientConst")
local PetData = require("Data.pet_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local PVPScene = Class.LightClass("PVPScene", BaseScene)

function PVPScene:onCtor()
	self.models = {}
end

function PVPScene:onStart()
	pg.global.ui:close(UIConst.UI_ID_FUNC_MENU)
	pg.game:setModuleEnable("PVP_MODE", ClientConst.ModuleKey.Chat, false)
end

function PVPScene:onLoaded()
	pg.global.ui:open(UIConst.UI_ID_PVP_BATTLE, nil, function()
		pg.game.pvp:pvpResGetReady()
	end)
	pg.global.ui:open(UIConst.UI_ID_INTERACT)
end

function PVPScene:onDestroy()
	pg.global.ui.pvpBattle:close()
	pg.global.ui:close(UIConst.UI_ID_PVP_REWARD)
	pg.global.ui:open(UIConst.UI_ID_HUD_V2)
	pg.game:setModuleEnable("PVP_MODE", ClientConst.ModuleKey.Chat, true)
end

return PVPScene
