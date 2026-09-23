-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\RoguelikeScene.lua

local BaseScene = require("GameApp.Scenes.BaseScene")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local RoguelikeScene = Class.LightClass("RoguelikeScene", BaseScene)

function RoguelikeScene:onStart()
	return
end

function RoguelikeScene:onLoaded()
	pg.global.ui:open(UIConst.UI_ID_HUD_V2)
	pg.global.ui:open(UIConst.UI_ID_GAMEPAD_MENU_NEW)
	pg.global.ui:open(UIConst.UI_ID_INTERACT)
	pg.global.ui:open(UIConst.UI_ID_CHAIN_ATTACK)
	pg.global.ui:open(UIConst.UI_ID_DAMAGE_NUMBER)
	pg.global.ui:open(UIConst.UI_ID_TIPS)
	pg.global.ui:open(UIConst.UI_ID_BOTTOM_DIALOGUE)
	pg.global.ui:open(UIConst.UI_ID_BOTTOM_PET_CHAT)
	pg.global.ui:open(UIConst.UI_ID_PET_EVOLVE)
	pg.global.ui:open(UIConst.UI_ID_HATRED_ARROW_TIP)
end

function RoguelikeScene:onDestroy()
	pg.global.ui:close(UIConst.UI_ID_ROG_BUFF_SELECT)
end

return RoguelikeScene
