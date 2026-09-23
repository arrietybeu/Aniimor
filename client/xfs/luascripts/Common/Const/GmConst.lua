-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\GmConst.lua

local GmConst = {
	RpcLogExclulde = {
		RPC_CS_SyncAIState = true,
		RPC_CS_EcsUploadState = true,
		RPC_CS_CharacterStateChange = true,
		RPC_SC_Heartbeat = true,
		RPC_CS_Heartbeat = true
	}
}

function GmConst.getName(name)
	if not _G_IsDebugMode then
		return nil
	end

	return GmConst[name]
end

function GmConst.setName(name, value)
	if not _G_IsDebugMode then
		return nil
	end

	GmConst[name] = value
end

return GmConst
