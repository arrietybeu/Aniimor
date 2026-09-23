-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SeasonHeadTips\\SeasonHeadTipsCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SeasonHeadTipsCtrl = Class.LightClass("SeasonHeadTipsCtrl", UICtrl)

SeasonHeadTipsCtrl.messages = {}

function SeasonHeadTipsCtrl:addListener()
	self:_bindClick(self.view.btnUButton, function()
		self:dismiss()
	end)
end

function SeasonHeadTipsCtrl:onOpen(info)
	self:_refreshTipsContent()
end

function SeasonHeadTipsCtrl:onShow()
	return
end

function SeasonHeadTipsCtrl:_refreshTipsContent()
	ClientTextUtils.setText(self.view.txtBtnNameUSDFText, pg.getGameString("PET_RESEARCH_HELP_TIP"))

	local subPopDesc = self.model:getSubPopDesc()
	local mainTitle = subPopDesc and pg.getLocalizationText(subPopDesc) or ""

	ClientTextUtils.setText(self.view.mainTitleUSDFText, mainTitle)
	ClientTextUtils.setText(self.view.subTitleUSDFText, "THE SEASON HAS BEGUN")
end

function SeasonHeadTipsCtrl:_bindClick(btn, callback)
	if not btn then
		return
	end

	btn.luaClick = callback
end

return SeasonHeadTipsCtrl
