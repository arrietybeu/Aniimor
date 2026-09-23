-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoBubblePetBallComponent.lua

local Class = require("Core.Framework.Class")
local TopLogoBubbleComponent = require("Guis.Panels.TopLogo.Component.TopLogoBubbleComponent")
local TopLogoBubblePetBallComponent = Class.LightClass("TopLogoBubblePetBallComponent", TopLogoBubbleComponent)

function TopLogoBubblePetBallComponent:getCameraPos()
	return pg.game.petBall.previewSceneCameraGameObject.transform.position
end

return TopLogoBubblePetBallComponent
