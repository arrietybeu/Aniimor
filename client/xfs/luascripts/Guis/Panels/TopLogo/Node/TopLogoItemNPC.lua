-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemNPC.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoNpcComponent = require("Guis.Panels.TopLogo.Component.TopLogoNpcComponent")
local TopLogoBubbleComponent = require("Guis.Panels.TopLogo.Component.TopLogoBubbleComponent")
local TopLogoChatComponent = require("Guis.Panels.TopLogo.Component.TopLogoChatComponent")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local TopLogoQuestComponent = require("Guis.Panels.TopLogo.Component.TopLogoQuestComponent")
local TopLogoBattleRoomComponent = require("Guis.Panels.TopLogo.Component.TopLogoBattleRoomComponent")
local TopLogoItemNPC = Class.LightClass("TopLogoItemNPC", TopLogoItem)

function TopLogoItemNPC:ctor(entity)
	TopLogoItemNPC.super.ctor(self, entity)
end

function TopLogoItemNPC:findObjects()
	return
end

function TopLogoItemNPC:createLogicComponents()
	self.components = self:m_buildComponents()

	self:m_classifyComponents()
end

function TopLogoItemNPC:m_buildComponents()
	local comps = {
		[UIConst.TOPLOGO_COMPONENT.NPC] = TopLogoNpcComponent.new(nil, self),
		[UIConst.TOPLOGO_COMPONENT.BUBBLE] = TopLogoBubbleComponent.new(nil, self),
		[UIConst.TOPLOGO_COMPONENT.CHAT] = TopLogoChatComponent.new(nil, self),
		[UIConst.TOPLOGO_COMPONENT.QUEST] = TopLogoQuestComponent.new(nil, self)
	}
	local ent = self.entity
	local configData = ent and ent.getConfigData and ent:getConfigData()

	if configData and configData.npcDuelId and configData.npcDuelId > 0 then
		comps[UIConst.TOPLOGO_COMPONENT.BATTLE_ROOM] = TopLogoBattleRoomComponent.new(nil, self)
	end

	return comps
end

function TopLogoItemNPC:switchNameState(state)
	self.nameState = state

	if self.components[UIConst.TOPLOGO_COMPONENT.NPC] then
		self.components[UIConst.TOPLOGO_COMPONENT.NPC]:setVisibleNpcInfo(state == UIConst.NAME_STATE.DIALOGUE)
	end
end

return TopLogoItemNPC
