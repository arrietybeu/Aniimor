-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\MapBlockListComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local MapBlockListComponent = Class.LightClass("MapBlockListComponent", UIComponent)

function MapBlockListComponent:findObjects()
	self.btnAreaSortUSelector = self.view.btnAreaSortUSelector
end

function MapBlockListComponent:renderPopup()
	local blockData = self.model:getAllSmallAreaInfo(self.ctrl.sceneId)

	function self.btnAreaSortUSelector.luaRenderPopup(popup, list)
		local objectReference = popup:GetComponent("ObjectReference")
		local listUList = objectReference:GetRefValue("listUList")

		function listUList.luaRenderItem(button, _, data)
			local objectReference1 = button:GetComponent("ObjectReference")
			local txtUText = objectReference1:GetRefValue("txtUText")
			local textUSDFText = objectReference1:GetRefValue("textUSDFText")

			button.isSelected = false

			function button.luaClick()
				local markName = string.format("mark_%s_%s", Const.MAP_MARK_LEYLINETREE, data.campId)

				self.ctrl:centralizeMark(markName, false, function()
					self.ctrl:selectMark(markName, true)
				end)
				self.btnAreaSortUSelector:ClosePopup()
			end

			ClientTextUtils.setText(txtUText, data.areaName)

			local progress = self.ctrl.mapPetAreaComponent:getAreaPetProgressStr(data.areaId)

			ClientTextUtils.setText(textUSDFText, progress)
		end

		listUList:SetList(blockData)
	end

	self.btnAreaSortUSelector:SetOptions()

	if not next(blockData) then
		self.btnAreaSortUSelector.gameObject:SetActiveEx(false)
	else
		self.btnAreaSortUSelector.gameObject:SetActiveEx(true)
	end
end

function MapBlockListComponent:destroy()
	return
end

function MapBlockListComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

return MapBlockListComponent
