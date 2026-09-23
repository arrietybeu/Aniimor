-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerBadgeCollectionComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("ClientPlayerBadgeCollectionComponent")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MessageName = require("Const.MessageName")
local BadgeCollectionConst = require("Common.Const.BadgeCollectionConst")
local ClientConst = require("Const.ClientConst")
local TaskData = require("Data.badge_task_data")
local UIConst = require("Const.UIConst")
local SysConfigData = require("Data.sys_config_data")
local schoolGuideData = require("Data.college_guide_page_data")
local SchoolGuideConst = require("Common.Const.SchoolGuideConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CommonSwitch = require("Common.CommonSwitch")
local ClientPlayerBadgeCollectionComponent = class.Component("ClientPlayerBadgeCollectionComponent")

function ClientPlayerBadgeCollectionComponent:reqUpQualityAll()
	if not self._isBadgeSwitchOpen() then
		return
	end

	pg.me:serverMsg("RPC_CS_UpQualityAll")
end

function ClientPlayerBadgeCollectionComponent:reqUpQualityById(badgeId)
	if not self._isBadgeSwitchOpen() then
		return
	end

	pg.me:serverMsg("RPC_CS_UpQualityById", badgeId)
end

function ClientPlayerBadgeCollectionComponent:reqOpenBadgeRewards(badgeId)
	if not self._isBadgeSwitchOpen() then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("殊途同归开奖-%d", badgeId)
	end

	pg.me:serverMsg("RPC_CS_BadgeRewards", badgeId)
end

function ClientPlayerBadgeCollectionComponent:onBadgeCollectionMoney_changed(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("殊途同归徽章数量 %d->%d", ov, nv)
	end
end

function ClientPlayerBadgeCollectionComponent:onBadgeCollection_changed(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("殊途同归 Map变化")
	end
end

function ClientPlayerBadgeCollectionComponent:onIsAwaitingOpenReward_changed(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("殊途同归 是否开奖变化")
	end
end

function ClientPlayerBadgeCollectionComponent:onBadgeCollectionPeriod_changed(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("殊途同归 新一期开始")
	end
end

function ClientPlayerBadgeCollectionComponent:RPC_SC_UpQuality(upResult)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		for k, v in pairs(upResult) do
			logger:info("殊途同归 提升回包 %d  %s", k, v)
		end
	end
end

function ClientPlayerBadgeCollectionComponent:RPC_SC_TaskComplete(data)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		for k, v in pairs(data) do
			logger:info("殊途同归 任务阶段完成回包 %d  %d", k, v)
		end
	end
end

function ClientPlayerBadgeCollectionComponent:sendBadgeTips(data)
	if not self._isBadgeSwitchOpen() then
		return
	end

	local badgeData = schoolGuideData[SchoolGuideConst.EventType.BadgeCollection]
	local tipsBigIcon = SysConfigData.TIPS_SIDE_ICON_BIG and SysConfigData.TIPS_SIDE_ICON_BIG[1]

	for k, v in pairs(data) do
		local curTaskData = TaskData[k]

		if curTaskData then
			facade:sendMsgToUI(MessageName.ON_BADGE_TASK_CHANGED, {
				fromCommon = true,
				processMax = 6,
				name = pg.getGameString("COLLECT_BADGE_COMPLETE_QUEST"),
				desc = pg.getLocalizationText(curTaskData.conditionDesc),
				bigIcon = tipsBigIcon,
				smallIcon = curTaskData.icon,
				processIndex = v,
				clickFunc = function()
					if self._isBadgeSwitchOpen() and (LuaUIUtils._checkConfigCondition(badgeData.conditions) == true or LuaUIUtils._checkConfigCondition(badgeData.alwaysShow) == true) then
						pg.global.ui:open(UIConst.UI_ID_BADGE_DETAIL, {
							tabIndex = 1
						})
					end
				end
			})
		end
	end
end

function ClientPlayerBadgeCollectionComponent._isBadgeSwitchOpen()
	return CommonSwitch.SCHOOLGUIDE_MEDAL
end

return ClientPlayerBadgeCollectionComponent
