-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemEnvObj.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local TopLogoQuestComponent = require("Guis.Panels.TopLogo.Component.TopLogoQuestComponent")
local TopLogoCallFriendsComponent = require("Guis.Panels.TopLogo.Component.TopLogoCallFriendsComponent")
local TopLogoNpcComponent = require("Guis.Panels.TopLogo.Component.TopLogoNpcComponent")
local TopLogoFocusComponent = require("Guis.Panels.TopLogo.Component.TopLogoFocusComponent")
local TopLogoItemEnvObj = Class.LightClass("TopLogoItemEnvObj", TopLogoItem)

function TopLogoItemEnvObj:ctor(entity)
	TopLogoItemEnvObj.super.ctor(self, entity)
end

function TopLogoItemEnvObj:destroy()
	TopLogoItemEnvObj.super.destroy(self)
end

function TopLogoItemEnvObj:findObjects()
	return
end

function TopLogoItemEnvObj:m_isGrabEggSpace()
	local space = self.entity and self.entity.space or pg.space

	return space and space.isGrabEgg and space:isGrabEgg() or false
end

function TopLogoItemEnvObj:createLogicComponents()
	self.components = {
		[UIConst.TOPLOGO_COMPONENT.NPC] = TopLogoNpcComponent.new(nil, self),
		[UIConst.TOPLOGO_COMPONENT.QUEST] = TopLogoQuestComponent.new(nil, self),
		[UIConst.TOPLOGO_COMPONENT.CALL_FRIENDS] = TopLogoCallFriendsComponent.new(nil, self)
	}

	if self:m_isGrabEggSpace() then
		self.components[UIConst.TOPLOGO_COMPONENT.FOCUS] = TopLogoFocusComponent.new(nil, self)
	end

	self:m_classifyComponents()
end

function TopLogoItemEnvObj:switchNameState(state)
	self.nameState = UIConst.NAME_STATE.DIALOGUE

	if self.components[UIConst.TOPLOGO_COMPONENT.NPC] then
		self.components[UIConst.TOPLOGO_COMPONENT.NPC]:setVisibleNpcInfo(true)
	end
end

return TopLogoItemEnvObj
