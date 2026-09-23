-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DevelopHint\\DevelopHintCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local DevelopHintCtrl = Class.LightClass("DevelopHintCtrl", UICtrl)
local AddressDataConst = require("Const.AddressDataConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CommonSwitch = require("Common.CommonSwitch")

function DevelopHintCtrl:onShow()
	if self.view.txtHintUText then
		self.view.txtHintUText.gameObject:SetActiveEx(false)
	end

	if ShowWaterMark then
		self.markResId = AddressDataConst.UI_WATER_MARK
		self.markWidth = 500
		self.markHeight = 100
		self.markIntervalWidth = 600
		self.markIntervalHeight = 500
		self.rotateOffsetY = 140
		self.rotateOffsetX = 0
		self.colOffset = 400

		local rootCanvasRect = pg.global.uiMgr.uiRootCanvasRect
		local countX = math.ceil(rootCanvasRect.width / (self.markWidth + self.markIntervalWidth)) + 1
		local countY = math.ceil(rootCanvasRect.height / (self.markHeight + self.markIntervalHeight)) + 1

		self.markIntervalWidth = rootCanvasRect.width / countX - self.markWidth
		self.markIntervalHeight = rootCanvasRect.height / countY - self.markHeight

		local posX = -rootCanvasRect.width / 2 + self.markWidth / 2 + self.rotateOffsetX
		local posY = -rootCanvasRect.height / 2 + self.markHeight / 2 + self.rotateOffsetY

		for i = 1, countX do
			local offset = i % 2 == 0 and self.colOffset or 0

			posY = -rootCanvasRect.height / 2 + self.markHeight / 2 + self.rotateOffsetY + offset

			for j = 1, countY do
				if i % 2 ~= 0 or j % 2 ~= 0 then
					local curPosX = posX
					local curposY = posY

					self.view:addPrefabWithPathAsync(self.view.transform, self.markResId, function(item)
						if IsNil(item.gameObject) then
							return
						end

						local obj = item.gameObject

						obj:GetComponent("RectTransform").anchoredPosition = Vector2(curPosX, curposY)

						ClientTextUtils.setText(obj.transform:Find("Text"):GetComponent("UBaseText"), LOCAL_IP_STR, "  ", LOCAL_MACHINE_NAME)
					end)
				end

				posY = posY + self.markIntervalHeight + self.markHeight
			end

			posX = posX + self.markIntervalWidth + self.markWidth
		end
	end
end

return DevelopHintCtrl
