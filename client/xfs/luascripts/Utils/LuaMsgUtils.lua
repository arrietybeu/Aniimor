-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaMsgUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("LuaUIUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local NoticeDef = require("Common.NoticeDef")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemEffectData = require("Data.item_effect_data")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local LimitData = require("Data.limit_data")
local Const = require("Common.Const.Const")
local LuaMsgUtils = {
	__batchCallback = {}
}

LuaMsgUtils.USE_ITEM_ERROR_CODE2FUNC_MAP = {
	[NoticeDef.ERROR_LIMIT_EXCEED] = "showBubbleLimitExceed"
}

local function showUseItemError(errorCode, errorArgs)
	if errorArgs then
		pg.global.showBubbleMessage(errorCode, unpack(errorArgs))
	else
		pg.global.showBubbleMessage(errorCode)
	end
end

function LuaMsgUtils.useItemBatch(itemMap, clientArgs, callback)
	if table.nums(itemMap) == 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[LuaMsgUtils.useItemBatch] itemMap is empty.")
		end

		return
	end

	local hasProp = false
	local canUseMap = {}

	for id, num in pairs(itemMap) do
		if num > 0 then
			canUseMap[id] = num
			hasProp = true
		end
	end

	if not hasProp then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[LuaMsgUtils.useItemBatch] itemMap`s items is zero.")
		end

		return
	end

	local callNum = 0
	local me = pg.me

	for itemId, num in pairs(canUseMap) do
		local cData = ItemEffectData[itemId]

		if cData and cData.reuseTimes ~= nil and cData.reuseTimes ~= 1 then
			local itemList = ItemUtils.getItemsById(me, itemId)

			if ToBool(itemList) then
				local genId = itemList[1].genID
				local invId = ItemUtils.getInvIdByItemId(itemId)

				me:serverMsg("RPC_CS_UseItem", invId, genId, num, clientArgs, CallbackHandler(LuaMsgUtils, "useItemBatchCallBack", callback))

				callNum = callNum + 1
			elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("[LuaMsgUtils.useItemBatch] items is nil.")
			end
		else
			me:serverMsg("RPC_CS_UseItemById", itemId, num, clientArgs, CallbackHandler(LuaMsgUtils, "useItemBatchCallBack", callback))

			callNum = callNum + 1
		end
	end

	if callNum > 0 then
		LuaMsgUtils.__batchCallback[callback] = callNum
	end
end

function LuaMsgUtils.useItemBatchCallBack(_, callback, res, errorCode, errorArgs)
	if not res and errorCode then
		showUseItemError(errorCode, errorArgs)
	end

	local num = LuaMsgUtils.__batchCallback[callback] or 0

	if num > 0 then
		local remandNum = num - 1

		LuaMsgUtils.__batchCallback[callback] = remandNum

		if remandNum == 0 then
			LuaMsgUtils.__batchCallback[callback] = nil
		end

		if remandNum > 0 then
			return
		end
	end

	if callback then
		callback()
	end
end

function LuaMsgUtils.useItemById(itemId, itemNum, customData, callback, failureCallback)
	if itemId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[LuaMsgUtils.useItemById] itemId is nil.")
		end

		if failureCallback then
			failureCallback()
		end

		return
	end

	local me = pg.me
	local iedd = ItemEffectData[itemId]

	if iedd ~= nil and iedd.reuseTimes ~= nil and iedd.reuseTimes ~= 1 then
		local itemList = ItemUtils.getItemsById(me, itemId)

		if ToBool(itemList) then
			local genId = itemList[1].genID
			local invId = ItemUtils.getInvIdByItemId(itemId)

			me:serverMsg("RPC_CS_UseItem", invId, genId, itemNum, customData, CallbackHandler(LuaMsgUtils, "useItemCallBack", itemId, callback, failureCallback))
		else
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("[LuaMsgUtils.useItemById] items is nil.")
			end

			if failureCallback then
				failureCallback()
			end
		end

		return
	end

	me:serverMsg("RPC_CS_UseItemById", itemId, itemNum, customData, CallbackHandler(LuaMsgUtils, "useItemCallBack", itemId, callback, failureCallback))
end

function LuaMsgUtils.useItem(itemId, invId, genId, itemNum, clientArgs, callback)
	if invId == nil or genId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[LuaMsgUtils.useItem] args is nil.")
		end

		return
	end

	local me = pg.me

	me:serverMsg("RPC_CS_UseItem", invId, genId, itemNum, clientArgs, CallbackHandler(LuaMsgUtils, "useItemCallBack", itemId, callback, nil))
end

function LuaMsgUtils.useItemCallBack(_, itemId, callback, failureCallback, res, errorCode, errorArgs)
	if errorCode ~= nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("[LuaMsgUtils.useItemCallBack] errorCode = ", errorCode)
	end

	if not res then
		if failureCallback then
			failureCallback(errorCode, errorArgs)
		end

		local ied = ItemEffectData[itemId] or {}

		if ied.sType == ItemConst.USEITEM_TYPE_PET_UNLOCK_ABILITY then
			showUseItemError(errorCode, errorArgs)

			return
		end

		if ied.sType == ItemConst.USEITEM_TYPE_SPAWN_ENVOBJ then
			showUseItemError(errorCode, errorArgs)

			return
		end

		local fun = LuaMsgUtils[LuaMsgUtils.USE_ITEM_ERROR_CODE2FUNC_MAP[errorCode]]

		if fun then
			fun(itemId)
		else
			showUseItemError(errorCode, errorArgs)
		end

		return
	end

	local iedd = ItemEffectData[itemId]

	if iedd ~= nil and iedd.sType ~= nil and iedd.sType == ItemConst.USEITEM_TYPE_CAST_ABILITY then
		pg.me:postComponentMethod("OnPetEat")
	end

	if res == true and not ItemUtils.isOpenUIType(itemId) then
		pg.global.showBubbleMessage(NoticeDef.ITEM_USE_SUCCEED)
	end

	if callback then
		callback()
	end
end

function LuaMsgUtils.showBubbleLimitExceed(itemId)
	local iedd = ItemEffectData[itemId]
	local limitConfigId = iedd.countLimit
	local cycleType = LimitData[limitConfigId].type

	pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("CYCLE_REMAIN_TIMES_OUT"), pg.getGameString(Const.LimitType2TextKeyMap[cycleType])))
end

return LuaMsgUtils
