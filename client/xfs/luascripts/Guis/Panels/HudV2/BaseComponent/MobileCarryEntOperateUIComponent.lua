-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\MobileCarryEntOperateUIComponent.lua

local Class = require("Core.Framework.Class")
local HoldEntPanelConfig = require("Data.hold_ent_panel_config_data")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MobileCarryEntOperateUIComponent = Class.LightClass("MobileCarryEntOperateUIComponent", HudBaseComponent)

MobileCarryEntOperateUIComponent.messages = {
	[MessageName.UPDATE_INTERACT_VIEW] = {
		"onCarryInteractChange"
	}
}

function MobileCarryEntOperateUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.skillBtn1 = objectReference:GetRefValue("skill1UButton")
	self.skillBtn2 = objectReference:GetRefValue("skill2UButton")
	self.skillBtn3 = objectReference:GetRefValue("skill3UButton")
end

function MobileCarryEntOperateUIComponent:initView()
	self.uWidget:SetActive(false)
end

function MobileCarryEntOperateUIComponent:showOperateBtns()
	self.uWidget:SetActive(true)
	self:setUpInteractBtn()
end

function MobileCarryEntOperateUIComponent:hideOperateBtns()
	self.uWidget:SetActive(false)
end

function MobileCarryEntOperateUIComponent:renderCarryInteraction(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(data.name))

	iconUImage.url = data.icon

	if data.isAssignBtn then
		self.assignBtn = button
	else
		function button.luaClick()
			data.func()
		end
	end
end

function MobileCarryEntOperateUIComponent:setUpInteractBtn()
	local player = pg.me
	local curPet = player:getCurPetEntity()
	local carryType = player.carryType
	local isHomeLand = pg.space and pg.space:isHomeland()
	local isCamp = pg.space and pg.space:isHomeCamp()

	if carryType == Const.CARRY_TYPE.PET then
		if isHomeLand or isCamp then
			self.skillBtn3:SetActive(true)
			self.skillBtn2:SetActive(true)
			self:renderCarryInteraction(self.skillBtn1, {
				icon = HoldEntPanelConfig.pullDownSkillIcon,
				name = pg.getLocalizationText(HoldEntPanelConfig.pullDownSkillDes),
				func = function()
					pg.me:putDownCarryEnt()
				end
			})
			self:renderCarryInteraction(self.skillBtn2, {
				icon = HoldEntPanelConfig.petRetrieveSkillIcon,
				name = pg.getLocalizationText(HoldEntPanelConfig.petRetrieveSkillDes),
				func = function()
					pg.me:putBackPet()
				end
			})
			self:renderCarryInteraction(self.skillBtn3, {
				isAssignBtn = true,
				icon = HoldEntPanelConfig.petArrangeSkillIcon,
				name = pg.getLocalizationText(HoldEntPanelConfig.petArrangeSkillDes)
			})
		else
			self.skillBtn3:SetActive(false)

			if lume.find(player.petPrepareList, curPet.id) then
				self.skillBtn1:SetActive(true)
				self.skillBtn2:SetActive(false)
				self:renderCarryInteraction(self.skillBtn1, {
					icon = HoldEntPanelConfig.pullDownSkillIcon,
					name = pg.getLocalizationText(HoldEntPanelConfig.pullDownSkillDes),
					func = function()
						pg.me:putDownCarryEnt()
					end
				})
			else
				self.skillBtn1:SetActive(false)
				self.skillBtn2:SetActive(true)
				self:renderCarryInteraction(self.skillBtn2, {
					icon = HoldEntPanelConfig.petRetrieveSkillIcon,
					name = pg.getLocalizationText(HoldEntPanelConfig.petRetrieveSkillDes),
					func = function()
						pg.me:putBackPet()
					end
				})
			end
		end
	elseif carryType == Const.CARRY_TYPE.ITEM then
		self.skillBtn2:SetActive(false)
		self.skillBtn3:SetActive(false)
		self:renderCarryInteraction(self.skillBtn1, {
			icon = HoldEntPanelConfig.petRetrieveSkillIcon,
			name = pg.getLocalizationText(HoldEntPanelConfig.petRetrieveSkillDes),
			func = function()
				pg.me:tryPutInItem()
			end
		})
	end

	self:refreshAssignBtn()
end

function MobileCarryEntOperateUIComponent:refreshAssignBtn()
	local isHomeLand = pg.space and pg.space:isHomeland()

	if not isHomeLand then
		return
	end

	if not self.assignBtn then
		return
	end

	self.assignBtn.interactable = false
	self.assignBtn.visualInteractable = false

	if not pg.game.interaction.curChooseEntId then
		return
	end

	local curHomeFacilityEntity = pg.getEntity(pg.game.interaction.curChooseEntId)

	if not curHomeFacilityEntity then
		return
	end

	if not Utils.isClientHomeFacility(curHomeFacilityEntity) then
		return
	end

	if pg.me.carryType ~= Const.CARRY_TYPE.PET then
		return
	end

	self.assignBtn.interactable = true

	local carryEnt = pg.me.carryEnt
	local requireOperIds = curHomeFacilityEntity:getRequireOperIds()
	local isOpMatch = false

	for _, opId in pairs(requireOperIds) do
		if Utils.checkHomePetCanDoOperId(carryEnt.petInfo.templateId, opId) then
			isOpMatch = true

			local allocation = pg.space.allocation
			local isOverPetWorkMaxCount = Utils.checkOverHomePetWorkMaxCount(allocation, curHomeFacilityEntity.id, curHomeFacilityEntity.homeTemplateId, carryEnt.id)

			if isOverPetWorkMaxCount then
				function self.assignBtn.luaClick()
					pg.global.showBubbleMessageById(NoticeDef.HOME_PET_ASSIGN_COUNT_OVER)
				end
			else
				self.assignBtn.visualInteractable = true

				function self.assignBtn.luaClick()
					pg.me:tryAssignPet(curHomeFacilityEntity.ornamentId, opId)
				end
			end

			break
		end
	end

	if not isOpMatch then
		function self.assignBtn.luaClick()
			pg.global.showBubbleMessageById(NoticeDef.HOME_PET_ASSIGN_OPERATE_NOT_MATCH)
		end
	end
end

function MobileCarryEntOperateUIComponent:onCarryInteractChange()
	self:refreshAssignBtn()
end

function MobileCarryEntOperateUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return MobileCarryEntOperateUIComponent
