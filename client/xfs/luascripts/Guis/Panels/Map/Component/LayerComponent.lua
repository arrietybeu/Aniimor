-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\LayerComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LayerComponent = Class.LightClass("LayerComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")

function LayerComponent:findObjects()
	self.listMapLayerUList = self.view.listMapLayerUList
	self.contentUWidget = self.view.contentUWidget
end

function LayerComponent:initView()
	function self.listMapLayerUList.luaRenderItem(button, index, data)
		self:renderLayerListITem(button, index, data)
	end
end

function LayerComponent:setListData(sceneId, recovery, forceClick)
	local mapLayerData = pg.game.map:getMapLayerData(sceneId)

	self:internalSetListData(mapLayerData[1], mapLayerData[2], mapLayerData[3], forceClick)

	if recovery then
		self.ctrl:changeMapLayerTemporary(mapLayerData[1], mapLayerData[2], mapLayerData[3], mapLayerData[4])
	end
end

function LayerComponent:internalSetListData(sceneId, layerId, layerLevel, forceClick, manualClick)
	function self.listMapLayerUList.luaFinishRender(_)
		local btns = self.listMapLayerUList:GetAllButtons()

		for i = 0, btns.Length - 1 do
			btns[i].isSelected = false

			if btns[i].name == string.format("%s%s", tostring(layerId), tostring(layerLevel)) then
				btns[i].isSelected = true

				if forceClick then
					btns[i]:OnClickSimulate()
				end

				self.listMapLayerUList:SetUListSwitchCurrentIndex(i)
			end
		end
	end

	self.listData = self.model:getLayerData(sceneId, layerId)

	if #self.listData <= 0 then
		self.contentUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User2)
	else
		self.contentUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end

	self.listMapLayerUList:SetList(self.listData)

	if layerId == 0 and manualClick then
		self.ctrl:changeMapLayerTemporary(sceneId, 0, 0, 0)
	end
end

function LayerComponent:renderLayerListITem(button, index, data)
	button.name = string.format("%s%s", data.layerData[2], data.levelIndex)

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local lineUImage = objectReference:GetRefValue("lineUImage")
	local iconSelUImage = objectReference:GetRefValue("iconSelUImage")
	local iconUnselUImage = objectReference:GetRefValue("iconUnselUImage")

	ClientTextUtils.setText(txtNameUSDFText, data.totalDesc)

	iconSelUImage.url = data.icon
	iconUnselUImage.url = data.deIcon

	lineUImage.gameObject:SetActiveEx(true)

	if #self.listData == index + 1 then
		lineUImage.gameObject:SetActiveEx(false)
	end

	function button.luaClick()
		self:selectBtn(button)
		self.ctrl:changeMapLayerTemporary(data.layerData[1], data.layerData[2], data.layerData[3], data.layerData[4])
	end
end

function LayerComponent:selectBtn(btn)
	local btns = self.listMapLayerUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i].isSelected = false

		if btns[i] == btn then
			btns[i].isSelected = true
		end
	end
end

function LayerComponent:destroy()
	return
end

function LayerComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

return LayerComponent
