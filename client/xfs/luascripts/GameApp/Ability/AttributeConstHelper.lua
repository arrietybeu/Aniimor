-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ability\\AttributeConstHelper.lua

local AttributeConst = require("Common.Const.AttributeConst")
local LoggerManager = require("Core.Log.LoggerManager")
local ClientUtils = require("Utils.ClientUtils")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AttributeConstHelper")
local AttributeConstHelper = {}

function AttributeConstHelper.tipAttributeLuaDiffByRpc()
	pg.me:serverMsg("RPC_CS_DebugCheckAttributeConstVersion", AttributeConst.HASH, AttributeConstHelper._onCheckAttributeConstVersionCb)
end

function AttributeConstHelper._onCheckAttributeConstVersionCb(isMatch)
	if isMatch == nil then
		return
	end

	if isMatch == false then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("AttributeConst version mismatch: clientHash=%s", AttributeConst.HASH)
		end

		ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), "AttributeConst.lua version different with server, please update", nil, true)
	end
end

return AttributeConstHelper
