-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomelandComponent\\ClientHomelandWarehouseComponent.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ItemConst = require("Common.Const.ItemConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local MessageName = require("Const.MessageName")
local ClientHomelandWarehouseComponent = Class.Component("ClientHomelandWarehouseComponent")

function ClientHomelandWarehouseComponent:ctor()
	return
end

function ClientHomelandWarehouseComponent:reqStoreHomelandItems(items)
	pg.me:serverMsg("RPC_CS_ReqStoreHomelandItems", items, CallbackHandler(self, "onReqStoreHomelandItemsCallback"))
end

function ClientHomelandWarehouseComponent:onReqStoreHomelandItemsCallback(code, items)
	local isSucc = code == Const.HOMELAND_WAREHOUSE_OP_RETURN_CODE.SUCCESS

	if isSucc then
		facade:sendMsgToUI(MessageName.HOMELAND_STORE_ITEMS_SUCC, {})
	end
end

function ClientHomelandWarehouseComponent:reqTakeHomelandItems(items)
	pg.me:serverMsg("RPC_CS_ReqTakeHomelandItems", items, CallbackHandler(self, "onReqTakeHomelandItemsCallback"))
end

function ClientHomelandWarehouseComponent:onReqTakeHomelandItemsCallback(code, items)
	local isSucc = code == Const.HOMELAND_WAREHOUSE_OP_RETURN_CODE.SUCCESS

	if isSucc then
		facade:sendMsgToUI(MessageName.HOMELAND_TAKE_ITEMS_SUCC, {})
	end
end

function ClientHomelandWarehouseComponent:on_itemMap_changed(ov, nv, itemId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_itemMap_changed itemId = %s, old=%s, new=%s", itemId, ov, nv)
	end

	facade:sendMsgToUI(MessageName.HOMELAND_ITEM_MAP_CHANGED, {
		genId = itemId,
		oldNum = ov,
		newNum = nv,
		changeType = ItemConst.INV_GEN_CHANGE
	})
end

function ClientHomelandWarehouseComponent:on_itemMap_entryAdd(itemId, v)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_itemMap_entryAdd itemId = %s, v =%s", itemId, v)
	end

	facade:sendMsgToUI(MessageName.HOMELAND_ITEM_MAP_CHANGED, {
		genId = itemId,
		newNum = v,
		changeType = ItemConst.INV_GEN_ADD
	})
end

function ClientHomelandWarehouseComponent:on_itemMap_entryDeleted(itemId, v)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_itemMap_entryDeleted itemId = %s, v =%s", itemId, v)
	end

	facade:sendMsgToUI(MessageName.HOMELAND_ITEM_MAP_CHANGED, {
		genId = itemId,
		newNum = v,
		changeType = ItemConst.INV_GEN_DEL
	})
end

return ClientHomelandWarehouseComponent
