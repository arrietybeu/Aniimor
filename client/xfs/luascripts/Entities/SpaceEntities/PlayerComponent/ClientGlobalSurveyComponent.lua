-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientGlobalSurveyComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local ClientGlobalSurveyComponent = class.Component("ClientGlobalSurveyComponent")

function ClientGlobalSurveyComponent:ctor()
	return
end

function ClientGlobalSurveyComponent:init(avtDict)
	if pg.global.ui.Survey and pg.global.ui.Survey.model then
		pg.global.ui.Survey.model:parseDataServer({})
	end

	return true
end

function ClientGlobalSurveyComponent:destroy()
	return
end

function ClientGlobalSurveyComponent:RPC_SC_StartSurvey(surveyMap)
	local isEmpty = Utils.tableIsEmptyOrNil(surveyMap)

	if pg.global.ui.Survey and pg.global.ui.Survey.model then
		pg.global.ui.Survey.model:parseDataServer(surveyMap)
	end

	facade:sendMsgToUI(MessageName.SURVEY_MAP_CHANGE, {
		isEmpty = not isEmpty
	})
end

function ClientGlobalSurveyComponent:finishSurvey(surveyId)
	self:serverMsg("RPC_CS_FinishedSurvey", surveyId)
end

function ClientGlobalSurveyComponent:finishFirstDisplaySurvey(surveyId)
	self:serverMsg("RPC_CS_FinishedFirstDisplaySurvey", surveyId)
end

return ClientGlobalSurveyComponent
