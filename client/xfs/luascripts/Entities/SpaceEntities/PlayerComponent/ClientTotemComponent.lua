-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientTotemComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local ItemConstSourceData = require("Data.item_const_source_data")
local TotemUpgradeData = require("Data.totem_upgrade_data")
local EventConst = require("Const.EventConst")
local ClientTotemComponent = Class.Component("ClientTotemComponent")

function ClientTotemComponent:ctor()
	return
end

function ClientTotemComponent:RPC_SC_OnAddTotemExp(totemId, totemChangeInfo)
	local levelBefore = totemChangeInfo[1]
	local expBefore = totemChangeInfo[2]
	local isMaxLevelBefore = totemChangeInfo[3]
	local level = totemChangeInfo[4]
	local exp = totemChangeInfo[5]
	local isMaxLevel = totemChangeInfo[6]

	facade:sendMsgToUI(MessageName.ADD_TOTEM_EXP, {
		totemId,
		levelBefore,
		expBefore,
		isMaxLevelBefore,
		level,
		exp,
		isMaxLevel
	})
	self.eventEmitter:emit(EventConst.ON_TOTEM_MAP_CHANGED, totemId)
end

function ClientTotemComponent:RPC_SC_OnAddTotemAbility(totemId, level)
	local totemInfo = (TotemUpgradeData[totemId] or EMPTY_TABLE)[level] or {}

	if totemInfo.abilityVirtualItemId then
		facade:sendMsgToUI(MessageName.ON_NOTIFY_ITEM, {
			{
				[totemInfo.abilityVirtualItemId] = 0
			},
			ItemConstSourceData.ITEM_SOURCE_COMMON
		})
	end
end

return ClientTotemComponent
