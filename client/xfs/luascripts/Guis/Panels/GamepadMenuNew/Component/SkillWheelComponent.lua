-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GamepadMenuNew\\Component\\SkillWheelComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local AudioConst = require("Const.AudioConst")
local AbilityConst = require("Common.Const.AbilityConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SkillWheelComponent = Class.LightClass("SkillWheelComponent", UIComponent)
local SKILL_ITEM_NUM = 8

function SkillWheelComponent:initView()
	self.skillWheels = {}
	self.skillGroupCount = 0
	self.selectedWheelIndex = nil
end

function SkillWheelComponent:clearWheels()
	self.skillWheels = {}
	self.selectedWheelIndex = nil
end

function SkillWheelComponent:initSkillWheel(button)
	local skillWheelTransform = button.transform

	skillWheelTransform:GetComponent("UButton"):TryChangePage("Type", 0)

	local skillWheelObjRef = skillWheelTransform:GetComponent("ObjectReference")
	local skillWheel = skillWheelObjRef:GetRefValue("menu")
	local skillListBtn = skillWheelObjRef:GetRefValue("listSkillButton")
	local skillListName = skillWheelObjRef:GetRefValue("name")
	local titleText = skillWheelObjRef:GetRefValue("txtWheelUSDFText")

	if titleText then
		ClientTextUtils.setText(titleText, pg.getGameString("GAMEPADMENU_EXPLORESKILLS"))
	end

	skillWheel.areaNum = SKILL_ITEM_NUM

	local items = {}

	for i = 1, SKILL_ITEM_NUM do
		items[i] = skillWheel.transform:GetChild(i - 1):GetComponent("UButton")
	end

	local entry = {
		transform = skillWheelTransform,
		wheel = skillWheel,
		listBtn = skillListBtn,
		listName = skillListName,
		items = items
	}

	table.insert(self.skillWheels, entry)

	function skillListBtn.luaRenderItem(b, idx, data)
		self:setupSkillList(b, idx, data)
	end

	function skillWheel.onLuaWheelIndexChange(index)
		self:refreshSkill()

		if index ~= -1 then
			if pg.me:isInCombat() then
				pg.global.ui.tips:showTextTip(pg.getGameString("SKILL_WHEEL_BATTLE_TIP"))
			elseif not pg.game.controller:isInControlMainPlayer() then
				pg.global.ui.tips:showTextTip(pg.getGameString("SKILL_WHEEL_LINK_TIP"))
			end
		end

		if index >= self.skillGroupCount then
			self:_broadcastListName("")
			self:_broadcastListBtnList({})
		elseif index ~= -1 and index < self.skillGroupCount then
			self:refreshSkillGroup(index + 1)
		end

		pg.game.audio:triggerEvent(AudioConst.EVENT_GAMEPAD_MENU_SELECTED_CHANGED)
	end

	function skillWheel.onLuaWheelSelect(index)
		index = self.selectedWheelIndex or index

		if not index or index < 0 then
			self.ctrl:setMenuOpen(false)

			return
		end

		if index >= self.skillGroupCount then
			pg.global.ui.tips:showTextTip(pg.getGameString("WHEEL_EMPTY"))
		end

		if not pg.me:isInCombat() then
			pg.me:switchToAbilityGroup(index + 1)
		end

		self:_broadcastWheelIndex(-1)
		self.ctrl:setMenuOpen(false)
	end

	self.skillGroupCount = math.min(SKILL_ITEM_NUM, #pg.me.exploreCustomAbilityIds)

	self:refreshSkill()

	if #self.skillWheels == 1 then
		self:refreshSkillGroup(pg.me.exploreCustomIndex)
	end
end

function SkillWheelComponent:setWheelOffset(offset)
	if #self.skillWheels == 0 then
		return
	end

	self.skillWheels[1].wheel:SetWheelOffset(offset)
end

function SkillWheelComponent:resetWheel()
	for _, entry in ipairs(self.skillWheels) do
		entry.wheel:ResetWheel()
	end
end

function SkillWheelComponent:_broadcastWheelIndex(value)
	for _, entry in ipairs(self.skillWheels) do
		entry.wheel.wheelIndex = value
	end
end

function SkillWheelComponent:_broadcastListName(text)
	for _, entry in ipairs(self.skillWheels) do
		ClientTextUtils.setText(entry.listName, text)
	end
end

function SkillWheelComponent:_broadcastListBtnList(data)
	for _, entry in ipairs(self.skillWheels) do
		entry.listBtn:SetList(data)
	end
end

function SkillWheelComponent:refreshSkillGroup(index)
	local skillList = {}
	local skillGroup = pg.me.exploreCustomAbilityIds[index].abilityIds

	for type, id in pairs(skillGroup) do
		if type == AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_Q or type == AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_E then
			local abilityParamData = pg.global.abilityMgr:getAbilityParamData(id)
			local skillInfo = {
				skillIcon = LuaUIUtils.getSkillIcon(abilityParamData.icon),
				name = abilityParamData.name
			}

			skillList[#skillList + 1] = skillInfo

			self:_broadcastListBtnList(skillList)
		end
	end

	if string.isNilOrEmpty(pg.me.exploreCustomAbilityIds[index].name) then
		self:_broadcastListName(string.format("%s %d", pg.getGameString("EXPLORE_SKILL_GROUP"), index))
	else
		self:_broadcastListName(pg.me.exploreCustomAbilityIds[index].name)
	end
end

function SkillWheelComponent:setupSkillList(button, index, data)
	button.transform:GetComponent("UButton"):TryChangePage("State", 1)

	local objectReference = button:GetComponent("ObjectReference")
	local iconNormalUImage = objectReference:GetRefValue("iconNormalUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))

	iconNormalUImage.url = data.skillIcon
end

function SkillWheelComponent:refreshSkill()
	self.skillGroupCount = math.min(SKILL_ITEM_NUM, #pg.me.exploreCustomAbilityIds)

	if #self.skillWheels == 0 then
		return
	end

	local rawIndex = self.skillWheels[1].wheel.wheelIndex

	if self.ctrl.isOpen and self.ctrl.curWheelListIndex == 2 and rawIndex ~= -1 then
		self.selectedWheelIndex = rawIndex
	end

	local wheelIndex = self.ctrl.curWheelListIndex == 2 and rawIndex + 1 or -1
	local rootEmpty = self.skillGroupCount == 0 and 0 or 1

	for _, entry in ipairs(self.skillWheels) do
		entry.transform:GetComponent("UButton"):TryChangePage("Empty", rootEmpty)

		for i, skillItem in ipairs(entry.items) do
			if i <= self.skillGroupCount then
				skillItem:TryChangePage("Empty", 1)
			else
				skillItem:TryChangePage("Empty", 0)
			end

			if i == wheelIndex then
				skillItem:TryChangePage("button", 5)
			else
				skillItem:TryChangePage("button", 0)
			end
		end
	end
end

return SkillWheelComponent
