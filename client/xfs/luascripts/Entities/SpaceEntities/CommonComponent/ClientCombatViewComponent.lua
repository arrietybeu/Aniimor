-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientCombatViewComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local EBTRootState = BaseEnum.EBTRootState
local AIUtils = require("Common.Utils.AIUtils")
local ClientCombatViewComponent = class.Component("ClientCombatViewComponent")

function ClientCombatViewComponent:start()
	return
end

function ClientCombatViewComponent:on_isInGoHome_changed(oldv, newv)
	AIUtils.onSetGoHome(self, newv)
end

return ClientCombatViewComponent
