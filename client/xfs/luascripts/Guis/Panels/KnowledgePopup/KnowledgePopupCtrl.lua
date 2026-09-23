-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\KnowledgePopup\\KnowledgePopupCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local KnowledgePopupCtrl = Class.LightClass("KnowledgePopupCtrl", UICtrl)

function KnowledgePopupCtrl:onOpen(info)
	local knowledgeItemData = info.knowledgeItemData

	self.view.photo.url = knowledgeItemData.data.icon
end

function KnowledgePopupCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.exitButton.luaClick()
		self:dismiss()
	end
end

return KnowledgePopupCtrl
