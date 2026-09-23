-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TrainPreference\\TrainPreferenceCtrl.lua

local LuaUIUtils = require("Utils.LuaUIUtils")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TrainPreferenceCtrl = Class.LightClass("TrainPreferenceCtrl", UICtrl)

TrainPreferenceCtrl.messages = {}

function TrainPreferenceCtrl:onCreate(infos)
	UICtrl.onCreate(self, infos)

	self.curSelectType = pg.me.userPreference

	local dataList = self.model:getPageTypeTb()

	if dataList then
		self.view.listCenter:SetList(dataList)
	end
end

function TrainPreferenceCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function TrainPreferenceCtrl:addListener()
	function self.view.listCenter.luaRenderItem(button, index, data)
		self:renderItemInfo(button, index, data, true)
	end

	function self.view.btnConfirmUButton.luaClick()
		pg.me:setUserPreference(self.curSelectType, function()
			return
		end)
		self:dismiss()
	end

	function self.view.btnCancelUButton.luaClick()
		self:dismiss()
	end
end

function TrainPreferenceCtrl:renderItemInfo(button, index, data)
	if data == nil then
		return
	end

	local coms = self.view:getQuestItemComs(button)

	if coms then
		local typePageConfig = self.model:getTypePageConfig(tonumber(data.trainType))

		ClientTextUtils.setText(coms.name, pg.getLocalizationText(typePageConfig.typeName))

		if typePageConfig then
			ClientTextUtils.setText(coms.details, pg.getLocalizationText(typePageConfig.des))

			coms.image.url = typePageConfig.typeImg or ""
		end

		button.isSelected = self.curSelectType == data.trainType
		coms.button.isSelected = self.curSelectType == data.trainType

		function coms.button.luaClick()
			self.curSelectType = data.trainType

			self:refreshQuestItem()
		end
	end
end

function TrainPreferenceCtrl:refreshQuestItem()
	local allData = self.view.listCenter.itemData
	local targetIdx

	for idx, data in pairs(allData) do
		if data.trainType == self.curSelectType then
			targetIdx = idx

			break
		end
	end

	if targetIdx then
		self.view.listCenter:RefreshElement(targetIdx)
	end
end

return TrainPreferenceCtrl
