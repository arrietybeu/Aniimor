-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\CTRPool.lua

local TablePool = require("Common.Container.TablePool")
local CTRConst = require("Common.AICt.CTRConst")
local rawset = rawset
local _isFromCTRPool = "_isFromCTRPool"
local CTRPool = {}

CTRPool.paramsPool = {
	[CTRConst.ParamType.TickTriggerParams] = {},
	[CTRConst.ParamType.TickLodTriggerParams] = {},
	[CTRConst.ParamType.MessageTriggerParams] = {},
	[CTRConst.ParamType.EventTriggerParams] = {}
}
CTRPool.contextPool = {}

function CTRPool.getContext()
	local context = TablePool.getTable(3)

	rawset(context, _isFromCTRPool, true)

	return context
end

function CTRPool.tryReturnContext(context)
	if not context then
		return
	end

	if rawget(context, _isFromCTRPool) then
		TablePool.returnTable(context, 3)
	end
end

return CTRPool
