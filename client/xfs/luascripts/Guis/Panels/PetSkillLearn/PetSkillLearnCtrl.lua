-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSkillLearn\\PetSkillLearnCtrl.lua

local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetSkData = require("Data.pet_skill_data")
local PetSkillLearnGamePadComponent = require("Guis.Panels.PetSkillLearn.Component.PetSkillLearnGamePadComponent")
local PetSkillLearnCtrl = Class.LightClass("PetSkillLearnCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

PetSkillLearnCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PetSkillLearnCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.gamePadComponent = PetSkillLearnGamePadComponent.new(self)

	self:show(info.petId)

	self.isEmpty = false
end

function PetSkillLearnCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end
end

function PetSkillLearnCtrl:closePanel()
	self:dismiss()
end

function PetSkillLearnCtrl:show(petId)
	self.selectPetId = petId

	local dataList = self.model:getSkillLearnData(petId)

	function self.view.listUList.luaRenderItem(button, index, data)
		self:instantiateSkillItem(button, index, data)
	end

	self.isEmpty = not dataList or #dataList <= 0

	if self.isEmpty then
		local areaId = self.gamePadComponent.navigation.AREAS.EMPTY_AREA

		self.gamePadComponent.navigation:specificSet(areaId, 1, 1)
		self.gamePadComponent.navigation:reFocus()
		self.view.root:TryChangePage("showEmpty", 1)
	else
		self:initListArea(dataList)
		self.view.root:TryChangePage("showEmpty", 0)
	end

	self.view.listUList:SetList(dataList)
end

function PetSkillLearnCtrl:instantiateSkillItem(button, index, data)
	button.name = index
	button.draggable = false
	button.enabledIntervalClick = false
	button.enabledLongPress = false

	if data.tIndex == 0 then
		button.enabledTooltip = true

		local objectReference = button:GetComponent("ObjectReference")
		local skillName = objectReference:GetRefValue("skillName")
		local powerNum = objectReference:GetRefValue("powerNum")
		local costNum = objectReference:GetRefValue("costNum")
		local skillIcon = objectReference:GetRefValue("skillIcon")
		local elementButton = objectReference:GetRefValue("elementButton")
		local featureList = objectReference:GetRefValue("featureList")

		ClientTextUtils.setText(skillName, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(powerNum, data.power)
		ClientTextUtils.setText(costNum, data.energy)

		skillIcon.url = LuaUIUtils.getSkillIcon(data.icon)

		button:TryChangePage("isS", data.rare or 0)
		LuaUIUtils.setElementButtonNew(elementButton, data.eType)

		function featureList.luaRenderItem(b, i, d)
			local objectReference1 = b:GetComponent("ObjectReference")
			local txtNameUText = objectReference1:GetRefValue("txtNameUText")

			ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(d.tagName))
		end

		featureList:SetList(data.tagList)

		function button.luaRenderTooltip(btn, component)
			local objectRef = component:GetComponent("ObjectReference")
			local txtName = objectRef:GetRefValue("txtName")
			local listUList = objectRef:GetRefValue("listUList")
			local descText = objectRef:GetRefValue("descText")
			local icon = objectRef:GetRefValue("icon")
			local mainElement = objectRef:GetRefValue("mainElement")
			local consumeList = objectRef:GetRefValue("consumeList")
			local consumeUWidget = objectRef:GetRefValue("consumeUWidget")
			local btnLearnSkillUButton = objectRef:GetRefValue("btnLearnSkillUButton")

			function consumeList.luaRenderItem(b, i, d)
				local objectReference1 = b:GetComponent("ObjectReference")
				local iconUImage = objectReference1:GetRefValue("iconUImage")
				local numUText = objectReference1:GetRefValue("numUText")

				iconUImage.url = LuaUIUtils.getIconByItemId(d[1])

				ClientTextUtils.setText(numUText, d[2])
			end

			component:TryChangePage("SkillState", 0)
			component:TryChangePage("btnState", 1)
			btnLearnSkillUButton:TryChangePage("lock", 0)

			local objectReference2 = btnLearnSkillUButton:GetComponent("ObjectReference")
			local txtNameUText1 = objectReference2:GetRefValue("txtNameUText")

			ClientTextUtils.setText(txtNameUText1, pg.getGameString("LEARN_ABILITY"))

			if not data.consume or #data.consume <= 0 then
				consumeUWidget.gameObject:SetActiveEx(false)
			else
				consumeUWidget.gameObject:SetActiveEx(true)

				local t = {}

				for i = 1, #data.consume do
					t[#t + 1] = {
						data.consume[i][1],
						data.consume[i][2]
					}
				end

				consumeList:SetList(t)
			end

			component:TryChangePage("IsRare", data.rare or 0)
			ClientTextUtils.setText(txtName, pg.getLocalizationText(data.name))

			icon.url = LuaUIUtils.getSkillIcon(data.icon)

			LuaUIUtils.setElementButtonNew(mainElement, data.eType)
			ClientTextUtils.setText(descText, pg.getLocalizationText(data.desc))

			function listUList.luaRenderItem(b, i, d)
				local objectReference1 = b:GetComponent("ObjectReference")
				local txtNameUText = objectReference1:GetRefValue("txtNameUText")
				local numUText = objectReference1:GetRefValue("numUText")

				ClientTextUtils.setText(txtNameUText, d.title)
				ClientTextUtils.setText(numUText, d.value)
				b:TryChangePage("ShowIcon", d.icon == 0 and 1 or 0)
				b:TryChangePage("IconType", d.icon - 1)
			end

			listUList:SetList({
				{
					icon = 0,
					title = pg.getGameString("SKILL_CARD_TYPE"),
					value = pg.getLocalizationText(data.tpName)
				},
				{
					icon = 0,
					title = pg.getGameString("SKILL_CARD_TAG"),
					value = pg.getLocalizationText(data.tagList[1].tagName)
				},
				{
					icon = 1,
					title = pg.getGameString("SKILL_CARD_POWER"),
					value = data.power
				},
				{
					icon = 2,
					title = pg.getGameString("SKILL_CARD_ENERGY"),
					value = data.energy
				}
			})

			function btnLearnSkillUButton.luaClick()
				button:ClosePopup()
				self:onLearnSkill()
			end
		end
	else
		button.enabledTooltip = true

		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local nameUText = objectReference:GetRefValue("nameUText")

		iconUImage.url = LuaUIUtils.getSkillIcon(data.icon)

		ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.name))
		button:TryChangePage("isS", data.rare or 0)

		function button.luaRenderTooltip(btn, component)
			local objectRef = component:GetComponent("ObjectReference")
			local txtName = objectRef:GetRefValue("txtName")
			local descText = objectRef:GetRefValue("descText")
			local mainElement = objectRef:GetRefValue("mainElement")
			local consumeList = objectRef:GetRefValue("consumeList")
			local consumeUWidget = objectRef:GetRefValue("consumeUWidget")
			local btnLearnSkillUButton = objectRef:GetRefValue("btnLearnSkillUButton")
			local iconUnknownUImage = objectRef:GetRefValue("iconUnknownUImage")

			function consumeList.luaRenderItem(b, i, d)
				local objectReference1 = b:GetComponent("ObjectReference")
				local iconUImage1 = objectReference1:GetRefValue("iconUImage")
				local numUText = objectReference1:GetRefValue("numUText")

				iconUImage1.url = LuaUIUtils.getIconByItemId(d[1])

				ClientTextUtils.setText(numUText, d[2])
			end

			component:TryChangePage("SkillState", 1)
			component:TryChangePage("btnState", 1)
			btnLearnSkillUButton:TryChangePage("lock", 1)

			local objectReference2 = btnLearnSkillUButton:GetComponent("ObjectReference")
			local txtNameUText1 = objectReference2:GetRefValue("txtNameUText")

			ClientTextUtils.setText(txtNameUText1, pg.getGameString("LOCKED"))

			if not data.consume or #data.consume <= 0 then
				consumeUWidget.gameObject:SetActiveEx(false)
			else
				consumeUWidget.gameObject:SetActiveEx(true)

				local t = {}

				for i = 1, #data.consume do
					t[#t + 1] = {
						data.consume[i][1],
						data.consume[i][2]
					}
				end

				consumeList:SetList(t)
			end

			component:TryChangePage("IsRare", data.rare or 0)
			ClientTextUtils.setText(txtName, pg.getLocalizationText(data.name))

			iconUnknownUImage.url = LuaUIUtils.getSkillIcon(data.icon)

			LuaUIUtils.setElementButtonNew(mainElement, data.eType)
			ClientTextUtils.setText(descText, pg.getLocalizationText(data.desc))
		end
	end

	function button.luaClick()
		if self.selectSkillData == data then
			return
		end

		self.selectSkillData = data
	end
end

function PetSkillLearnCtrl:onLearnSkill()
	local me = pg.me
	local pet = me:getPetInfo(self.selectPetId)

	if pet == nil then
		return
	end

	local data = self.selectSkillData

	if not data then
		return
	end

	local psdd = PetSkData[pet.templateId] and PetSkData[pet.templateId][data.paramId]

	if psdd == nil then
		return
	end

	local consume = psdd.learnSkillConsume
	local args = {
		title = pg.getGameString("LEARN_ABILITY")
	}

	args.data = consume or {}

	function args.confirmCb()
		me:serverMsg("RPC_CS_LearnPetAbility", self.selectPetId, data.id, CallbackHandler(self, "callbackOnLearnSkill"))
	end

	function args.cancelCb()
		return
	end

	pg.global.ui:open(UIConst.UI_ID_COMMON_USE_CONFIRM, args)
end

function PetSkillLearnCtrl:callbackOnLearnSkill(result)
	if result == NoticeDef.SUCCESS then
		local me = pg.me
		local pet = me:getPetInfo(self.selectPetId)

		LuaUIUtils.parseSkillBubbleMessage({
			isLearn = true,
			petTmpId = pet.templateId,
			skillId = AbilityUtils.getAbilityIdByParamId(pet.templateId, self.selectSkillData.id)
		})
	else
		pg.global.showBubbleMessage(result)

		return
	end

	self:show(self.selectPetId)
end

function PetSkillLearnCtrl:initListArea(data)
	local t = {}

	for i = 1, #data do
		local x = math.floor((i - 1) / 2) + 1
		local y = (i - 1) % 2 + 1

		if y == 1 then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			self.gamePadComponent.navigation:baseFocus(t, x1, y1, self.view.keyListUList)

			local _, button = self.view.listUList:TryGetChildAt(i - 1)

			if button then
				self.gamePadComponent:deSelectAll()
				button:TryChangePage("select", 1)
			end
		end
		t[x][y].Fun1 = function(x1, y1)
			if data[i].unLock then
				local _, button = self.view.listUList:TryGetChildAt(i - 1)

				if button then
					button:ClosePopup()
					self:onLearnSkill()
				end
			end
		end
		t[x][y].Fun3 = function(x1, y1)
			local _, button = self.view.listUList:TryGetChildAt(i - 1)

			if button and button.isTooltipOpen then
				button:ClosePopup()

				return
			end

			self.view.btnCloseUButton.luaClick()
		end
		t[x][y].Fun3Name = pg.getGameString("BACK_TO_PRE")
		t[x][y].Fun4 = function(x1, y1)
			local _, button = self.view.listUList:TryGetChildAt(i - 1)

			if button then
				button:OnClickSimulate()
			end
		end
		t[x][y].Fun4Name = pg.getGameString("GAMEPAD_CHOOSE")
	end

	self.gamePadComponent.navigation:initAreaTableSlots(self.gamePadComponent.navigation.LIST_AREA, t)

	local areaId = self.gamePadComponent.navigation.AREAS.LIST_AREA

	self.gamePadComponent.navigation:specificSet(areaId, 1, 1)
	self.gamePadComponent.navigation:delayFocus(nil, 0.1)
end

function PetSkillLearnCtrl:onInputDeviceChanged(deviceType)
	self.gamePadComponent:onInputDeviceChanged(deviceType)
end

return PetSkillLearnCtrl
