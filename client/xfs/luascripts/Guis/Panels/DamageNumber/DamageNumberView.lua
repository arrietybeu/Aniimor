-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DamageNumber\\DamageNumberView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local AddressDataConst = require("Const.AddressDataConst")
local UIConst = require("Const.UIConst")
local DamageNumberModel = require("Guis.Panels.DamageNumber.DamageNumberModel")
local LuaUIUtils = require("Utils.LuaUIUtils")
local IsNil = IsNil
local NotNil = NotNil
local DamageNumberView = Class.LightClass("DamageNumberView", UIView)
local NUMBER_PRELOAD_COUNT = 3
local NUMBER_SPECIAL_PRELOAD_COUNT = 1
local STATUS_PRELOAD_COUNT = 1

DamageNumberView.TYPE2RES_MAP = {
	[UIConst.DAMAGE_NUMBER_TYPE.PLAYER_NUMBER] = AddressDataConst.PLAYER_DAMAGE_NUMBER_PREFAB_RES,
	[UIConst.DAMAGE_NUMBER_TYPE.PUPPET_NUMBER] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES,
	[UIConst.DAMAGE_NUMBER_TYPE.STATUS] = AddressDataConst.STATUS_PREFAB_NAME_RES,
	[UIConst.DAMAGE_NUMBER_TYPE.EXECUTE] = AddressDataConst.EXECUTE_PREFAB_NAME_RES,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_LOW,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW_BREAK] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_LOW_BREAK,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW_POWERFUL] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_LOW_POWERFUL,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_NORMAL,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL_BREAK] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_NORMAL_BREAK,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL_POWERFUL] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_NORMAL_POWERFUL,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_HIGH,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH_BREAK] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_HIGH_BREAK,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH_POWERFUL] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_HIGH_POWERFUL,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_EP] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_EP,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_RECOVER] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_RECOVER,
	[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH1] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_BOSS_CATCH1,
	[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH2] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_BOSS_CATCH2,
	[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH3] = AddressDataConst.DAMAGE_NUMBER_PREFAB_RES_BOSS_CATCH3
}
DamageNumberView.TYPE2NAME_MAP = {
	[UIConst.DAMAGE_NUMBER_TYPE.PLAYER_NUMBER] = "PlayerDamageNumber",
	[UIConst.DAMAGE_NUMBER_TYPE.PUPPET_NUMBER] = "DamageNumber",
	[UIConst.DAMAGE_NUMBER_TYPE.STATUS] = "DamageStatus",
	[UIConst.DAMAGE_NUMBER_TYPE.EXECUTE] = "DamageExecute",
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW] = "DamageNumberLow",
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW_BREAK] = "DamageNumberLowBreak",
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW_POWERFUL] = "DamageNumberLowPowerful",
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL] = "DamageNumberNormal",
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL_BREAK] = "DamageNumberNormalBreak",
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL_POWERFUL] = "DamageNumberNormalPowerful",
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH] = "DamageNumberHigh",
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH_BREAK] = "DamageNumberHighBreak",
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH_POWERFUL] = "DamageNumberHighPowerful",
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_EP] = "DamageNumberEP",
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_RECOVER] = "DamageNumberRecover",
	[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH1] = "BossCatch1",
	[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH2] = "BossCatch2",
	[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH3] = "BossCatch3"
}
DamageNumberView.TYPE2MINCOUNT_MAP = {
	[UIConst.DAMAGE_NUMBER_TYPE.PLAYER_NUMBER] = 3,
	[UIConst.DAMAGE_NUMBER_TYPE.PUPPET_NUMBER] = 3,
	[UIConst.DAMAGE_NUMBER_TYPE.STATUS] = 1,
	[UIConst.DAMAGE_NUMBER_TYPE.EXECUTE] = 1,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW] = 3,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW_BREAK] = 3,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW_POWERFUL] = 3,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL] = 3,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL_BREAK] = 3,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL_POWERFUL] = 3,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH] = 3,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH_BREAK] = 3,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH_POWERFUL] = 3,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_EP] = 1,
	[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_RECOVER] = 1,
	[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH1] = 0,
	[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH2] = 0,
	[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH3] = 0
}

function DamageNumberView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.itemPool = {
		[UIConst.DAMAGE_NUMBER_TYPE.PLAYER_NUMBER] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.PUPPET_NUMBER] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.STATUS] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.EXECUTE] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW_BREAK] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW_POWERFUL] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL_BREAK] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL_POWERFUL] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH_BREAK] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH_POWERFUL] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_EP] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.NUMBER_RECOVER] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH1] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH2] = {},
		[UIConst.DAMAGE_NUMBER_TYPE.BOSS_CATCH3] = {}
	}
end

function DamageNumberView:initView()
	self:preLoadObj()
	self:preLoadDamageJumpAssets()
end

function DamageNumberView:preLoadObj()
	self:addPrefabToPool(UIConst.DAMAGE_NUMBER_TYPE.STATUS, STATUS_PRELOAD_COUNT)
	self:addPrefabToPool(UIConst.DAMAGE_NUMBER_TYPE.EXECUTE, STATUS_PRELOAD_COUNT)
	self:addPrefabToPool(UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW, NUMBER_PRELOAD_COUNT)
	self:addPrefabToPool(UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW_BREAK, NUMBER_PRELOAD_COUNT)
	self:addPrefabToPool(UIConst.DAMAGE_NUMBER_TYPE.NUMBER_LOW_POWERFUL, NUMBER_PRELOAD_COUNT)
	self:addPrefabToPool(UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL, NUMBER_PRELOAD_COUNT)
	self:addPrefabToPool(UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL_BREAK, NUMBER_PRELOAD_COUNT)
	self:addPrefabToPool(UIConst.DAMAGE_NUMBER_TYPE.NUMBER_NORMAL_POWERFUL, NUMBER_PRELOAD_COUNT)
	self:addPrefabToPool(UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH, NUMBER_PRELOAD_COUNT)
	self:addPrefabToPool(UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH_BREAK, NUMBER_PRELOAD_COUNT)
	self:addPrefabToPool(UIConst.DAMAGE_NUMBER_TYPE.NUMBER_HIGH_POWERFUL, NUMBER_PRELOAD_COUNT)
	self:addPrefabToPool(UIConst.DAMAGE_NUMBER_TYPE.NUMBER_EP, NUMBER_SPECIAL_PRELOAD_COUNT)
	self:addPrefabToPool(UIConst.DAMAGE_NUMBER_TYPE.NUMBER_RECOVER, NUMBER_SPECIAL_PRELOAD_COUNT)
end

function DamageNumberView:preLoadDamageJumpAssets()
	local resIDs = DamageNumberModel.ALL_RES_IDS
	local uiMgr = pg.global.uiMgr

	for i = 1, #resIDs do
		uiMgr:PreloadDamageJumpAsset(resIDs[i])
	end
end

function DamageNumberView:addPrefabToPool(type, count)
	count = count or 1

	if count <= 0 then
		return
	end

	local name = self.TYPE2NAME_MAP[type]

	self:addPrefabWithPathAsyncBatch(self.transform, self.TYPE2RES_MAP[type], count, function(objInfo)
		objInfo.gameObject.name = name

		self:returnObjToPool(type, objInfo.transform)
	end, false, false, 2, true)
end

function DamageNumberView:getObjFromPool(type, callback)
	local pool = self.itemPool[type]
	local minCount = self.TYPE2MINCOUNT_MAP[type]

	while #pool > 0 do
		local idx = #pool
		local item = pool[idx]

		pool[idx] = nil

		if NotNil(item) and NotNil(item.gameObject) then
			local remaining = idx - 1

			if remaining < minCount then
				self:addPrefabToPool(type, minCount - remaining)
			end

			if not item.gameObject.activeSelf then
				item.gameObject:SetActiveEx(true)
			end

			self:setItemVisible(item, true)

			if callback then
				callback(item)
			end

			return
		end
	end

	local name = self.TYPE2NAME_MAP[type]

	self:addPrefabWithPathAsync(self.transform, self.TYPE2RES_MAP[type], function(objInfo)
		if not objInfo or IsNil(objInfo.gameObject) then
			if callback then
				callback(nil)
			end

			return
		end

		objInfo.gameObject.name = name

		local item = objInfo.transform

		if not item.gameObject.activeSelf then
			item.gameObject:SetActiveEx(true)
		end

		self:setItemVisible(item, true)

		if callback then
			callback(item)
		end
	end, true, false, 2)
	self:addPrefabToPool(type, minCount)
end

function DamageNumberView:returnObjToPool(type, item)
	if IsNil(item) or IsNil(item.gameObject) then
		return
	end

	self:setItemVisible(item, false)

	local pool = self.itemPool[type]

	pool[#pool + 1] = item
end

function DamageNumberView:setItemVisible(item, visible)
	local itemUWidget = item:GetComponent("UWidget")

	if itemUWidget then
		itemUWidget:SetActiveFastest(visible)
	else
		LuaUIUtils.setUIVisible(item, visible)
	end
end

return DamageNumberView
