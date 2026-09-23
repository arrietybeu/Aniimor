-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MapLocation\\MapLocationCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MapLocationCtrl = Class.LightClass("MapLocationCtrl", UICtrl)

MapLocationCtrl.messages = {}

function MapLocationCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.finishedCb = info.finishedCb

	local clipboardContent = UIUtils.ClipboardReader()

	ClientTextUtils.setText(self.view.xInput.placeHolder, pg.getGameString("MAP_COOR_TIP_X"))
	ClientTextUtils.setText(self.view.zInput.placeHolder, pg.getGameString("MAP_COOR_TIP_Y"))

	if string.find(clipboardContent, "MAPCOORDINATE_") then
		local arr = string.split(clipboardContent, "_")

		if #arr == 3 then
			if arr[2] and arr[3] then
				self.view.xInput.text = arr[2]
				self.view.zInput.text = arr[3]
			end
		else
			self.view.xInput:Select()
			CS.XGUI.Navigation.NavManager.Instance:PushFocusNavGroupOf(self.view.content)
		end
	else
		self.view.xInput:Select()
		CS.XGUI.Navigation.NavManager.Instance:PushFocusNavGroupOf(self.view.content)
	end

	CS.XGUI.Navigation.NavManager.Instance:AddLuaHotkeyActivationChangedListener("UI_MapLocationCtrl_Content", function()
		self:refreshConsoleBarState()
	end)
end

function MapLocationCtrl:refreshConsoleBarState()
	local inNavModal = pg.global.navMgr and pg.global.navMgr:IsInModalGroup()

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_Node_MapLocInput_Back", inNavModal)
end

function MapLocationCtrl:closePanel()
	CS.XGUI.Navigation.NavManager.Instance:RemoveLuaHotkeyActivationChangedListener("UI_MapLocationCtrl_Content")
	pg.global.ui:close(UIConst.UI_ID_MAP_LOCATION)
end

function MapLocationCtrl:addListener()
	self.view.keyHandler:AddKeyListener(9, function()
		if self.view.xInput.allowInput then
			self.view.xInput:DeSelect()
			self.view.zInput:Select()
			CS.XGUI.Navigation.NavManager.Instance:FocusItem(self.view.zInput)
		else
			self.view.xInput:Select()
			self.view.zInput:DeSelect()
			CS.XGUI.Navigation.NavManager.Instance:FocusItem(self.view.xInput)
		end
	end)

	function self.view.btnCancelUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnConfirmUButton.luaClick()
		if string.isNilOrEmpty(self.view.xInput.text) or string.isNilOrEmpty(self.view.zInput.text) then
			pg.global.showBubbleMessageRaw(pg.getGameString("MAP_COOR_VALID_WARNING"))

			return
		end

		local x = tonumber(self.view.xInput.text)
		local z = tonumber(self.view.zInput.text)

		if self.finishedCb then
			self.finishedCb(x, z)
		end

		self:closePanel()
	end
end

return MapLocationCtrl
