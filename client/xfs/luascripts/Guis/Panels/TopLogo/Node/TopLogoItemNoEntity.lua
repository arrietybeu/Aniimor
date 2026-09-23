-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemNoEntity.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoAlertComponent = require("Guis.Panels.TopLogo.Component.TopLogoAlertComponent")
local TopLogoBubbleComponent = require("Guis.Panels.TopLogo.Component.TopLogoBubbleComponent")
local TopLogoCombatComponent = require("Guis.Panels.TopLogo.Component.TopLogoCombatComponent")
local TopLogoChatComponent = require("Guis.Panels.TopLogo.Component.TopLogoChatComponent")
local TopLogoNpcComponent = require("Guis.Panels.TopLogo.Component.TopLogoNpcComponent")
local TopLogoItemBase = require("Guis.Panels.TopLogo.Node.TopLogoItemBase")
local TopLogoItemNoEntity = Class.LightClass("TopLogoItemNoEntity", TopLogoItemBase)

function TopLogoItemNoEntity:ctor(attachTrans, maxDistance, resId)
	TopLogoItemNoEntity.super.ctor(self)

	self.attachTrans = attachTrans
	self.maxDistance = maxDistance
	self.resId = resId

	pg.global.uiMgr:RegisterTopLogo(self, attachTrans, maxDistance)
end

function TopLogoItemNoEntity:destroy()
	pg.global.uiMgr:UnregisterTopLogo(self)
	TopLogoItemNoEntity.super.destroy(self)
end

return TopLogoItemNoEntity
