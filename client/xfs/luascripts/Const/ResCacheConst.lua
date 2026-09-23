-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Const\\ResCacheConst.lua

local ResCacheConst = {}

ResCacheConst.CACHE_TYPE = {
	PARTICLE = 3,
	UI = 2,
	DEFAULT = 1
}
ResCacheConst.RES_POLICY = {
	["$Eff_Hit_Dark_Slash.prefab"] = {
		minReserve = 6,
		maxIdle = 16,
		cacheType = 3
	},
	["$Eff_Hit_ShakeCamera_01.prefab"] = {
		minReserve = 4,
		maxIdle = 12,
		cacheType = 3
	}
}

function ResCacheConst.applyAll()
	local resMgr = appFacade and appFacade.resManager

	if resMgr == nil then
		return
	end

	if resMgr.ClearResCachePolicies == nil or resMgr.SetResCachePolicyByLua == nil then
		return
	end

	resMgr:ClearResCachePolicies()

	for resId, policy in pairs(ResCacheConst.RES_POLICY) do
		resMgr:SetResCachePolicyByLua(resId, policy.cacheType or ResCacheConst.CACHE_TYPE.PARTICLE, policy.maxIdle or 0, policy.minReserve or 0)
	end
end

return ResCacheConst
