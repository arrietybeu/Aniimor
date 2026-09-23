-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\MobileExploreUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("MobileExploreUIComponent")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local AbilityUIUtils = require("Utils.AbilityUIUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AvatarData = require("Data.avatar_data")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local AddressDataConst = require("Const.AddressDataConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local SceneData = require("Data.scene_data")
local MobileExploreUIComponent = Class.LightClass("MobileExploreUIComponent", HudBaseComponent)

MobileExploreUIComponent.messages = {
	[MessageName.PLAYER_COMBAT_STATUS_UPDATE] = {
		"onCombatStatusChange",
		true
	}
}

function MobileExploreUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btn1UButton = objectReference:GetRefValue("btn1UButton")
	self.btn2UButton = objectReference:GetRefValue("btn2UButton")
	self.btn3UButton = objectReference:GetRefValue("btn3UButton")
end

function MobileExploreUIComponent:initView()
	self:refreshSkillList()
end

function MobileExploreUIComponent:refreshSkillList()
	local btnDatas = {}

	if CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.FLYING) then
		local playerSpace = pg.me and pg.me.space
		local curSceneCfg = playerSpace and SceneData[playerSpace.sceneId] or Const.CACHED_EMPTY_TABLE
		local inCombat = pg.me:isInCombat()

		if not inCombat then
			local downBtn = {}

			downBtn.btnText = pg.getGameString("HUD_FLOAT_BUTTON_DOWN")
			downBtn.btnIcon = AddressDataConst.EXPORE_SKILL_FLY_DROP

			function downBtn.luaPress()
				pg.pawn:beginStraightDown()
			end

			function downBtn.luaRelease()
				pg.pawn:endStraightDown()
			end

			downBtn.isDisabled = inCombat or curSceneCfg.canFlyVerticalAndSprint ~= 1

			table.insert(btnDatas, downBtn)

			local upBtn = {}

			upBtn.btnText = pg.getGameString("HUD_FLOAT_BUTTON_UP")
			upBtn.btnIcon = AddressDataConst.EXPORE_SKILL_FLY_RISE

			function upBtn.luaPress()
				pg.pawn:beginStraightUp()
			end

			function upBtn.luaRelease()
				pg.pawn:endStraightUp()
			end

			upBtn.isDisabled = inCombat or curSceneCfg.canFlyVerticalAndSprint ~= 1

			table.insert(btnDatas, upBtn)
		end
	end

	local btns = {
		self.btn1UButton,
		self.btn2UButton,
		self.btn3UButton
	}

	for i = 1, 3 do
		local btn = btns[i]
		local data = btnDatas[i]

		if data then
			local objectReference = btn:GetComponent("ObjectReference")
			local txtNameUText = objectReference:GetRefValue("txtNameUText")
			local iconUImage = objectReference:GetRefValue("iconUImage")

			ClientTextUtils.setText(txtNameUText, data.btnText)

			iconUImage.url = data.btnIcon or ""
			btn.luaPress = data.luaPress
			btn.luaRelease = data.luaRelease

			btn:SetActive(true)
			btn:TryChangePage("button", data.isDisabled and 4 or 0)

			btn.interactable = not data.isDisabled
		else
			btn:TryChangePage("button", 0)
			btn:SetActive(false)
		end
	end
end

function MobileExploreUIComponent:onCombatStatusChange()
	self:refreshSkillList()
end

function MobileExploreUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

function MobileExploreUIComponent:playShowAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function MobileExploreUIComponent:playHideAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return MobileExploreUIComponent
