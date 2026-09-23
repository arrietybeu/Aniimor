-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemDialogueGraphEnt.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local TopLogoChatComponent = require("Guis.Panels.TopLogo.Component.TopLogoChatComponent")
local TopLogoBubbleComponent = require("Guis.Panels.TopLogo.Component.TopLogoBubbleComponent")
local TopLogoItemDialogueGraphEnt = Class.LightClass("TopLogoItemDialogueGraphEnt", TopLogoItem)

function TopLogoItemDialogueGraphEnt:ctor(entity)
	TopLogoItemDialogueGraphEnt.super.ctor(self, entity)
end

function TopLogoItemDialogueGraphEnt:destroy()
	TopLogoItemDialogueGraphEnt.super.destroy(self)
end

function TopLogoItemDialogueGraphEnt:findObjects()
	return
end

function TopLogoItemDialogueGraphEnt:createLogicComponents()
	self.components = {
		[UIConst.TOPLOGO_COMPONENT.BUBBLE] = TopLogoBubbleComponent.new(nil, self),
		[UIConst.TOPLOGO_COMPONENT.CHAT] = TopLogoChatComponent.new(nil, self)
	}

	self:m_classifyComponents()
end

return TopLogoItemDialogueGraphEnt
