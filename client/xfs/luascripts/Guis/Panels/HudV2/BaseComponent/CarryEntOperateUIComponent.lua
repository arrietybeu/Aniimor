-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\CarryEntOperateUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("CarryEntOperateUIComponent")
local HoldEntPanelConfig = require("Data.hold_ent_panel_config_data")
local Const = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local NoticeDef = require("Common.NoticeDef")
local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CarryEntOperateUIComponent = Class.LightClass("CarryEntOperateUIComponent", HudBaseComponent)

CarryEntOperateUIComponent.messages = {
	[MessageName.UPDATE_INTERACT_VIEW] = {
		"onCarryInteractChange"
	}
}

function CarryEntOperateUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listBtnUList = objectReference:GetRefValue("listBtnUList")
end

function CarryEntOperateUIComponent:initView()
	if not self.wantShow then
		self:tryCloseComponent()

		return
	end

	function self.listBtnUList.luaRenderItem(button, idx, data)
		self:renderCarryInteraction(button, idx, data)
	end

	self:refreshOperateBtns()
end

function CarryEntOperateUIComponent:onCarryInteractChange()
	self:refreshAssignBtn()
end

function CarryEntOperateUIComponent:renderCarryInteraction(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local btnNormalKeyBindingPro = objectReference:GetRefValue("btnNormalKeyBindingPro")
	local skillName = objectReference:GetRefValue("skillName")
	local specialUButton = objectReference:GetRefValue("specialUButton")

	ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(data.name))

	iconUImage.url = data.icon
	btnNormalKeyBindingPro.actionPath = data.actionPath

	if data.isAssignBtn then
		self.assignBtn = button
	else
		function button.luaClick()
			data.func()
		end
	end
end

function CarryEntOperateUIComponent:refreshOperateBtns()
	local carryDatas = self:getCancelCarryDatas()

	self.listBtnUList:SetList(carryDatas)
	self:refreshAssignBtn()
end

function CarryEntOperateUIComponent:getCancelCarryDatas()
	local ret = {}
	local player = pg.me
	local curPet = player:getCurPetEntity()
	local carryType = player.carryType
	local isHomeLand = pg.space and pg.space:isHomeland()
	local isCamp = pg.space and pg.space:isHomeCamp()

	if carryType == Const.CARRY_TYPE.PET then
		if isHomeLand or isCamp then
			ret[#ret + 1] = {
				actionPath = "Hud/VehicleSkillT",
				icon = HoldEntPanelConfig.petRetrieveSkillIcon,
				name = pg.getLocalizationText(HoldEntPanelConfig.petRetrieveSkillDes),
				func = function()
					pg.me:putBackPet()
				end
			}
			ret[#ret + 1] = {
				actionPath = "Hud/SkillQ",
				icon = HoldEntPanelConfig.pullDownSkillIcon,
				name = pg.getLocalizationText(HoldEntPanelConfig.pullDownSkillDes),
				func = function()
					pg.me:putDownCarryEnt()
				end
			}

			if isHomeLand and pg.me.space:isSelfHomeland(pg.me) then
				ret[#ret + 1] = {
					actionPath = "Skill/PutItem",
					isAssignBtn = true,
					icon = HoldEntPanelConfig.petArrangeSkillIcon,
					name = pg.getLocalizationText(HoldEntPanelConfig.petArrangeSkillDes)
				}
			end
		elseif curPet and lume.find(player.petPrepareList, curPet.id) then
			ret[#ret + 1] = {
				actionPath = "Hud/VehicleSkillT",
				icon = HoldEntPanelConfig.pullDownSkillIcon,
				name = pg.getLocalizationText(HoldEntPanelConfig.pullDownSkillDes),
				func = function()
					pg.me:putDownCarryEnt()
				end
			}
		else
			ret[#ret + 1] = {
				actionPath = "Hud/SkillQ",
				icon = HoldEntPanelConfig.petRetrieveSkillIcon,
				name = pg.getLocalizationText(HoldEntPanelConfig.petRetrieveSkillDes),
				func = function()
					pg.me:putBackPet()
				end
			}
		end
	elseif carryType == Const.CARRY_TYPE.ITEM then
		ret[#ret + 1] = {
			actionPath = "Hud/VehicleSkillT",
			icon = HoldEntPanelConfig.propRetrieveSkillIcon,
			name = pg.getLocalizationText(HoldEntPanelConfig.propRetrieveSkillDes),
			func = function()
				pg.me:tryPutInItem()
			end
		}
	end

	return ret
end

function CarryEntOperateUIComponent:refreshAssignBtn()
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

function CarryEntOperateUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return CarryEntOperateUIComponent
