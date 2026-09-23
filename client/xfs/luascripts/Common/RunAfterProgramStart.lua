-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\RunAfterProgramStart.lua

local RunAfterProgramStart = {}

function RunAfterProgramStart.run(isReload)
	if pg.component == "game" then
		local CheckServerData = require("CheckServerData")

		CheckServerData:checkData()
	end

	local OpDef = require("Common.OpDef")

	OpDef.initOpReverseMap()

	local NoticeDef = require("Common.NoticeDef")

	NoticeDef.initReverseMap()

	local HomeCampTenantUtils = require("Common.Utils.HomeCampTenantUtils")

	HomeCampTenantUtils.init()

	if pg.component == "game" then
		local ServerUtils = require("GameServer.ServerUtils")

		ServerUtils.regiterCustomTypesMethod(isReload)

		local MonitorServiceHelper = require("GameServer.MonitorServiceHelper")

		MonitorServiceHelper.init()
	elseif pg.component == "client" then
		-- block empty
	end
end

return RunAfterProgramStart
