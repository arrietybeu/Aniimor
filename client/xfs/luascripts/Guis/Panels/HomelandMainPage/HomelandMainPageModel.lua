-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandMainPage\\HomelandMainPageModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandMainPageModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomelandMainPageModel = Class.LightClass("HomelandMainPageModel", UIModel)
local OpDef = require("Common.OpDef")
local NoticeDef = require("Common.NoticeDef")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")

function HomelandMainPageModel:changeHomelandName(newName, callback)
	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_ChangeName, {
		name = newName
	}, function(noticeId, noticeArg)
		if noticeId == NoticeDef.SUCCESS then
			callback()
		else
			ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArg))
		end
	end)
end

return HomelandMainPageModel
