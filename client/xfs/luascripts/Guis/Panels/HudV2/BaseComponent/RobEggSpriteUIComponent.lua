-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\RobEggSpriteUIComponent.lua

local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local RobEggSkillButtonUIComponent = require("Guis.Panels.HudV2.BaseComponent.RobEggSkillButtonUIComponent")
local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local Const = require("Common.Const.Const")
local SysConfigData = require("Data.sys_config_data")
local SlotState = {
	VeryLow = 4,
	Empty = 3,
	Zero = 2,
	Low = 1,
	Normal = 0
}
local equip_dur_color = SysConfigData.GRABEGG_EQUIP_DUR_COLOR
local RobEggSpriteUIComponent = Class.LightClass("RobEggSpriteUIComponent", HudBaseComponent)

RobEggSpriteUIComponent.messages = {
	[MessageName.SCENE_LOADED] = {
		"refreshVisible",
		true
	},
	[MessageName.GRAB_EGG_EQUIP_SHOW_INFO_CHANGED] = {
		"refreshFromEquipShowInfo",
		true
	},
	[MessageName.GRAB_EGG_CHIP_SKILL_ID_CHANGED] = {
		"onChipSkillIdChanged",
		true
	},
	[MessageName.SKILL_CD_END_TIME_UPDATE] = {
		"onSkillCdUpdate",
		true
	}
}

function RobEggSpriteUIComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.shield = self.objectReference:GetRefValue("Shield")
	self.weapon = self.objectReference:GetRefValue("Weapon")
	self.shieldSlide = self.objectReference:GetRefValue("ShieldSlide")
	self.weaponSlide = self.objectReference:GetRefValue("WeaponSlide")
	self.skillUContainer = self.objectReference:GetRefValue("skillUContainer")
	self.isExistShield = false
	self.isExistWeapon = false
	self.curShieldDura = 0
	self.maxShieldDura = 100
	self.curWeaponDura = 0
	self.maxWeaponDura = 100
	self.shieldState = SlotState.Normal
	self.weaponState = SlotState.Normal
	self.isMobile = pg.global.ui:runPlatformByMobile()
	self.isRobEgg = pg.space and pg.space:isGrabEgg()
	self.skillButton = RobEggSkillButtonUIComponent.new(self.skillUContainer)

	self.skillButton:setExternalVisible(self.isMobile and self.isRobEgg)
	self.skillButton:setSkillId(pg.me and pg.me.chipSkillId)
end

function RobEggSpriteUIComponent:onChipSkillIdChanged(skillId)
	if self.skillButton then
		self.skillButton:setSkillId(skillId)
	end
end

function RobEggSpriteUIComponent:initView()
	self:refreshVisible()
end

function RobEggSpriteUIComponent:refreshVisible()
	LuaUIUtils.setUIVisible(self.transform, self.isRobEgg)

	if self.isRobEgg then
		self:refreshFromEquipShowInfo()
	end
end

function RobEggSpriteUIComponent:refreshFromEquipShowInfo()
	local equipShowInfo = pg.me and pg.me.equipShowInfo
	local armorInfo = equipShowInfo and equipShowInfo[ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR]
	local weaponInfo = equipShowInfo and equipShowInfo[ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON]
	local prevShieldDura = self.curShieldDura
	local prevWeaponDura = self.curWeaponDura

	self.isExistShield = armorInfo ~= nil and (armorInfo.equipId or 0) > 0
	self.curShieldDura = armorInfo and armorInfo.curDura or 0
	self.maxShieldDura = armorInfo and armorInfo.maxDura ~= 0 and armorInfo.maxDura or 1
	self.curShieldDura = math.ceil(self.curShieldDura)
	self.isExistWeapon = weaponInfo ~= nil and (weaponInfo.equipId or 0) > 0
	self.curWeaponDura = weaponInfo and weaponInfo.curDura or 0
	self.maxWeaponDura = weaponInfo and weaponInfo.maxDura ~= 0 and weaponInfo.maxDura or 1
	self.curWeaponDura = math.ceil(self.curWeaponDura)

	local shieldJustZero = prevShieldDura > 0 and self.curShieldDura == 0
	local weaponJustZero = prevWeaponDura > 0 and self.curWeaponDura == 0

	if shieldJustZero or weaponJustZero then
		if pg.game and pg.game.audio then
			pg.game.audio:playEvent("GrabEgg_Egg_Dur_depleted")
		end

		local needRepairRemind = shieldJustZero and self:isEquipRepairable(ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR) or weaponJustZero and self:isEquipRepairable(ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON)

		if needRepairRemind then
			pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_Repaire_Remind"))
		end
	end

	self:refreshDura()
end

function RobEggSpriteUIComponent:isEquipRepairable(slot)
	local packSlot = pg.me and pg.me:getItemFromBagSlotIndex(slot, ItemConst.INV_TYPE_EQUIP_SLOTS)

	if not packSlot or not packSlot.id then
		return false
	end

	return ItemUtils.checkRepairRobEquip(packSlot) == Const.CheckFixEquipRet.OK
end

local function calcDuraState(isExist, curDura, maxDura)
	if not isExist then
		return SlotState.Empty
	end

	if curDura <= 0 or maxDura <= 0 then
		return SlotState.Zero
	end

	local pct = curDura / maxDura * 100

	if pct > equip_dur_color[3] then
		return SlotState.Normal
	elseif pct > equip_dur_color[2] then
		return SlotState.Low
	else
		return SlotState.VeryLow
	end
end

function RobEggSpriteUIComponent:refreshDura()
	self.shieldState = calcDuraState(self.isExistShield, self.curShieldDura, self.maxShieldDura)

	if self.shieldSlide then
		self.shieldSlide.value = self.isExistShield and self.maxShieldDura > 0 and self.curShieldDura / self.maxShieldDura or 0
	end

	self.shield:TryChangePage("Durable", self.shieldState)

	self.weaponState = calcDuraState(self.isExistWeapon, self.curWeaponDura, self.maxWeaponDura)

	if self.weaponSlide then
		self.weaponSlide.value = self.isExistWeapon and self.maxWeaponDura > 0 and self.curWeaponDura / self.maxWeaponDura or 0
	end

	self.weapon:TryChangePage("Durable", self.weaponState)
end

function RobEggSpriteUIComponent:onSkillCdUpdate(info)
	if not info or not info.abilityId then
		return
	end

	if self.skillButton then
		self.skillButton:onSkillCdUpdate(info.abilityId)
	end
end

function RobEggSpriteUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

function RobEggSpriteUIComponent:playShowAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function RobEggSpriteUIComponent:playHideAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return RobEggSpriteUIComponent
