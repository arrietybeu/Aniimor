-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\TransLocationListComponent.lua

local Class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TransLocationListComponent = Class.LightClass("TransLocationListComponent", UIComponent)

function TransLocationListComponent:findObjects()
	self.listTransLocUList = self.view.listTransLocUList
end

function TransLocationListComponent:init()
	local teleportData = self.model:getQuickTeleportData(pg.game.map:convertSceneId(self.ctrl.sceneId))

	function self.listTransLocUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local title = pg.getGameString(data.name)

		ClientTextUtils.setText(txtNameUSDFText, title)

		iconUImage.url = data.icon

		function button.luaClick()
			self:onTeleportBtnClick(data, title)
		end
	end

	self.listTransLocUList:SetList(teleportData)
end

function TransLocationListComponent:onTeleportBtnClick(data, title)
	local function inner()
		local sceneId = data.teleportToSceneId

		if pg.me.sceneId == sceneId then
			return
		end

		ClientUtils.playTeleportDissolveEffectAndTeleport(sceneId, 0)
		self.ctrl:closePanel(true)
	end

	local hintShowTs = pg.global.prefsCacheUtils:getInt("TransLocationListComponentQuickTeleportTip", 0, ClientConst.CACHE_TYPE_FLAG.USER)

	if hintShowTs + 604800 <= Time.secondCache then
		pg.global.showConfirmMsgRaw(pg.getGameString("MAP_QUICK_TELEPORT_TIP_1"), string.format(pg.getGameString("MAP_QUICK_TELEPORT_TIP_2"), title), function()
			inner()

			if self.hintHideFlag then
				pg.global.prefsCacheUtils:setInt("TransLocationListComponentQuickTeleportTip", Time.secondCache, ClientConst.CACHE_TYPE_FLAG.USER)
				pg.global.prefsCacheUtils:save()
			end
		end, nil, function()
			return
		end, nil, nil, {
			hint = true,
			hintDesc = string.format(pg.getGameString("DISABLE_HINT"), 7),
			hintCb = function(isSelected)
				if isSelected then
					self.hintHideFlag = true
				else
					self.hintHideFlag = nil
				end
			end
		})
	else
		inner()
	end
end

function TransLocationListComponent:destroy()
	return
end

function TransLocationListComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

return TransLocationListComponent
