-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\SyncStrategy\\SyncStrategyMgr.lua

local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("SyncStrategyMgr")
local SyncStrategyMgr = {
	running = false
}
local onClientSyncFunc = {}
local syncClientFunc = {}
local syncCache = {}

function SyncStrategyMgr.registerSyncMode(syncMode, syncFunc, onSyncFunc)
	syncClientFunc[syncMode] = syncFunc
	onClientSyncFunc[syncMode] = onSyncFunc
end

function SyncStrategyMgr.run(runner, syncMode, processName)
	if SyncStrategyMgr.running then
		error(string.format("SyncStrategyMgr run process %s failed: already in process %s with syncMode %s", processName, SyncStrategyMgr.processName, PropertyTypes.SYNC_MODE_DESC[SyncStrategyMgr.syncMode]))
	end

	SyncStrategyMgr.running = true
	SyncStrategyMgr.runner = runner
	SyncStrategyMgr.syncMode = syncMode
	SyncStrategyMgr.processName = processName
end

function SyncStrategyMgr.exit()
	SyncStrategyMgr.running = false
	SyncStrategyMgr.runner = nil
	SyncStrategyMgr.syncMode = nil
	SyncStrategyMgr.processName = nil
end

local function checkAndPrepare(owner)
	assert(SyncStrategyMgr.running)

	if SyncStrategyMgr.runner and SyncStrategyMgr.runner ~= owner then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("property sync process %s modify more than one targets", SyncStrategyMgr.processName or "unknown")
		end

		return false
	end

	if syncCache[owner] == nil then
		syncCache[owner] = {}
	end

	return true
end

local function cacheRootChanged(ownercache, rootname, aoiscope)
	local rootcache = ownercache[rootname]

	if rootcache ~= nil then
		if rootcache.all == nil then
			rootcache.all = aoiscope
			rootcache.ops = nil
			rootcache.cks = nil
			rootcache.wraps = nil
		end
	else
		ownercache[rootname] = {
			all = aoiscope
		}
	end
end

local function cacheSubRootChanged(ownercache, root, subname, subvalue, aoiscope)
	local rootname = root._name
	local rootcache = ownercache[rootname]

	if rootcache == nil then
		ownercache[rootname] = {
			ops = {
				{
					aoiscope,
					PropertyTypes.OP_CHANGE,
					subname,
					subvalue
				}
			},
			cks = {
				[subname] = 1
			}
		}
	elseif rootcache.all == nil then
		if rootcache.cks[subname] == nil then
			table.insert(rootcache.ops, {
				aoiscope,
				PropertyTypes.OP_CHANGE,
				subname,
				subvalue
			})

			rootcache.cks[subname] = #rootcache.ops

			if rootcache.wraps then
				rootcache.wraps[subname] = nil
			end
		else
			local idx = rootcache.cks[subname]

			assert(rootcache.ops[idx][3] == subname)

			rootcache.ops[idx][4] = subvalue
		end
	else
		return
	end
end

local function cacheSubRootDeleted(ownercache, root, subname, aoiscope)
	local rootname = root._name
	local rootcache = ownercache[rootname]
	local isRootCustomDict = root:isCustomDict()
	local optype

	if isRootCustomDict then
		optype = PropertyTypes.OP_DEL
	else
		optype = PropertyTypes.OP_REMOVE
	end

	if rootcache == nil then
		ownercache[rootname] = {
			ops = {
				{
					aoiscope,
					optype,
					subname
				}
			},
			cks = {}
		}
	elseif rootcache.all == nil then
		table.insert(rootcache.ops, {
			aoiscope,
			optype,
			subname
		})

		if isRootCustomDict then
			rootcache.cks[subname] = nil
		else
			rootcache.cks = {}
		end
	else
		return
	end
end

local function cacheSubRootCreated(ownercache, root, subname, subvalue, aoiscope)
	local rootname = root._name
	local rootcache = ownercache[rootname]
	local isRootCustomDict = root:isCustomDict()
	local optype

	if isRootCustomDict then
		optype = PropertyTypes.OP_ADD
	else
		optype = PropertyTypes.OP_INSERT
	end

	if rootcache == nil then
		ownercache[rootname] = {
			ops = {
				{
					aoiscope,
					optype,
					subname,
					subvalue
				}
			},
			cks = {
				[subname] = 1
			}
		}
	elseif rootcache.all == nil then
		table.insert(rootcache.ops, {
			aoiscope,
			optype,
			subname,
			subvalue
		})

		if isRootCustomDict then
			rootcache.cks[subname] = #rootcache.ops
		else
			rootcache.cks = {
				[subname] = #rootcache.ops
			}
		end
	else
		return
	end
end

local function cacheSubWrapperChanged(ownercache, rootname, wrapper, subname, subvalue, aoiscope)
	local rootcache = ownercache[rootname]
	local wrappername = wrapper._name

	if rootcache == nil then
		ownercache[rootname] = {
			ops = {},
			cks = {},
			wraps = {
				[wrappername] = {
					ops = {
						{
							aoiscope,
							PropertyTypes.OP_CHANGE,
							subname,
							subvalue
						}
					},
					cks = {
						[subname] = 1
					}
				}
			}
		}
	elseif rootcache.all == nil then
		if rootcache.cks[wrappername] == nil then
			local wrapcache = rootcache.wraps

			if wrapcache == nil then
				rootcache.wraps = {
					[wrappername] = {
						ops = {
							{
								aoiscope,
								PropertyTypes.OP_CHANGE,
								subname,
								subvalue
							}
						},
						cks = {
							[subname] = 1
						}
					}
				}
			elseif wrapcache[wrappername] == nil then
				wrapcache[wrappername] = {
					ops = {
						{
							aoiscope,
							PropertyTypes.OP_CHANGE,
							subname,
							subvalue
						}
					},
					cks = {
						[subname] = 1
					}
				}
			elseif wrapcache[wrappername].cks[subname] == nil then
				table.insert(wrapcache[wrappername].ops, {
					aoiscope,
					PropertyTypes.OP_CHANGE,
					subname,
					subvalue
				})

				wrapcache[wrappername].cks[subname] = #wrapcache[wrappername].ops
			else
				local idx = wrapcache[wrappername].cks[subname]

				assert(wrapcache[wrappername].ops[idx][3] == subname)

				wrapcache[wrappername].ops[idx][4] = subvalue
			end
		else
			return
		end
	else
		return
	end
end

local function cacheSubWrapperDeleted(ownercache, rootname, wrapper, subname, aoiscope)
	local rootcache = ownercache[rootname]
	local wrappername = wrapper._name
	local isWrapperCustomDict = wrapper:isCustomDict()
	local optype

	if isWrapperCustomDict then
		optype = PropertyTypes.OP_DEL
	else
		optype = PropertyTypes.OP_REMOVE
	end

	if rootcache == nil then
		ownercache[rootname] = {
			ops = {},
			cks = {},
			wraps = {
				[wrappername] = {
					ops = {
						{
							aoiscope,
							optype,
							subname
						}
					},
					cks = {}
				}
			}
		}
	elseif rootcache.all == nil then
		if rootcache.cks[wrappername] == nil then
			local wrapcache = rootcache.wraps

			if wrapcache == nil then
				rootcache.wraps = {
					[wrappername] = {
						ops = {
							{
								aoiscope,
								optype,
								subname
							}
						},
						cks = {}
					}
				}
			elseif wrapcache[wrappername] == nil then
				wrapcache[wrappername] = {
					ops = {
						{
							aoiscope,
							optype,
							subname
						}
					},
					cks = {}
				}
			else
				table.insert(wrapcache[wrappername].ops, {
					aoiscope,
					optype,
					subname
				})

				if isWrapperCustomDict then
					wrapcache[wrappername].cks[subname] = nil
				else
					wrapcache[wrappername].cks = {}
				end
			end
		else
			return
		end
	else
		return
	end
end

local function cacheSubWrapperCreated(ownercache, rootname, wrapper, subname, subvalue, aoiscope)
	local rootcache = ownercache[rootname]
	local wrappername = wrapper._name
	local isWrapperCustomDict = wrapper:isCustomDict()
	local optype

	if isWrapperCustomDict then
		optype = PropertyTypes.OP_ADD
	else
		optype = PropertyTypes.OP_INSERT
	end

	if rootcache == nil then
		ownercache[rootname] = {
			ops = {},
			cks = {},
			wraps = {
				[wrappername] = {
					ops = {
						{
							aoiscope,
							optype,
							subname,
							subvalue
						}
					},
					cks = {
						[subname] = 1
					}
				}
			}
		}
	elseif rootcache.all == nil then
		if rootcache.cks[wrappername] == nil then
			local wrapcache = rootcache.wraps

			if wrapcache == nil then
				rootcache.wraps = {
					[wrappername] = {
						ops = {
							{
								aoiscope,
								optype,
								subname,
								subvalue
							}
						},
						cks = {
							[subname] = 1
						}
					}
				}
			elseif wrapcache[wrappername] == nil then
				wrapcache[wrappername] = {
					ops = {
						{
							aoiscope,
							optype,
							subname,
							subvalue
						}
					},
					cks = {
						[subname] = 1
					}
				}
			else
				table.insert(wrapcache[wrappername].ops, {
					aoiscope,
					optype,
					subname,
					subvalue
				})

				if isWrapperCustomDict then
					wrapcache[wrappername].cks[subname] = #wrapcache[wrappername].ops
				else
					wrapcache[wrappername].cks = {
						[subname] = #wrapcache[wrappername].ops
					}
				end
			end
		else
			return
		end
	else
		return
	end
end

local function raiseChange2PackPoint(ownercache, customObj, subname, subvalue)
	local root = customObj._root

	while customObj._parent ~= root do
		subname = customObj._name
		subvalue = customObj
		customObj = customObj._parent
	end

	if customObj:_isWrapper() then
		local aoiscope

		if type(subvalue) == "table" then
			aoiscope = subvalue:_getAoiscope()
		else
			local propDeclares = customObj.__ClassType.__Name2PropertyDeclare__
			local _declare = propDeclares[subname]

			if _declare == nil then
				_declare = customObj.__ClassType.__ValueTypeDeclare__
			end

			aoiscope = math.min(customObj:_getAoiscope(), _declare.aoiscope)
		end

		cacheSubWrapperChanged(ownercache, root._name, customObj, subname, subvalue, aoiscope)
	else
		cacheSubRootChanged(ownercache, root, customObj._name, customObj, customObj:_getAoiscope())
	end
end

function SyncStrategyMgr.onRootPropertyChangedInRuntime(owner, declare, name, value)
	if not checkAndPrepare(owner) then
		return
	end

	local aoiscope = declare.aoiscope

	if aoiscope > PropertyTypes.AOI_SERVER_ONLY then
		cacheRootChanged(syncCache[owner], name, aoiscope)
	end
end

function SyncStrategyMgr.onSubPropertyChangedInRuntime(owner, customObj, declare, name, value)
	if not checkAndPrepare(owner) then
		return
	end

	local aoiscope = math.min(customObj:_getAoiscope(), declare.aoiscope)

	if aoiscope > PropertyTypes.AOI_SERVER_ONLY then
		if customObj:_isRoot() then
			cacheSubRootChanged(syncCache[owner], customObj, name, value, aoiscope)
		else
			raiseChange2PackPoint(syncCache[owner], customObj, name, value)
		end
	end
end

function SyncStrategyMgr.onSubPropertyDeletedInRuntime(owner, customObj, declare, name, value)
	if not checkAndPrepare(owner) then
		return
	end

	local aoiscope = customObj:_getAoiscope()

	if aoiscope > PropertyTypes.AOI_SERVER_ONLY then
		if customObj:_isRoot() then
			cacheSubRootDeleted(syncCache[owner], customObj, name, aoiscope)
		elseif customObj:_isWrapper() then
			assert(customObj._root == customObj._parent)
			cacheSubWrapperDeleted(syncCache[owner], customObj._root._name, customObj, name, aoiscope)
		else
			raiseChange2PackPoint(syncCache[owner], customObj, name, value)
		end
	end
end

function SyncStrategyMgr.onSubPropertCreatedInRuntime(owner, customObj, declare, name, value)
	if not checkAndPrepare(owner) then
		return
	end

	local aoiscope = customObj:_getAoiscope()

	if aoiscope > PropertyTypes.AOI_SERVER_ONLY then
		if customObj:_isRoot() then
			cacheSubRootCreated(syncCache[owner], customObj, name, value, aoiscope)
		elseif customObj:_isWrapper() then
			assert(customObj._root == customObj._parent)
			cacheSubWrapperCreated(syncCache[owner], customObj._root._name, customObj, name, value, aoiscope)
		else
			raiseChange2PackPoint(syncCache[owner], customObj, name, value)
		end
	end
end

local function recordData(syncdata, aoiscope, propertyid, optype, name, value)
	local ownval, allval

	if aoiscope >= PropertyTypes.AOI_OWN_CLIENT then
		if type(value) == "table" then
			ownval = value:getOwnClientValue()
		else
			ownval = value
		end

		local temp = syncdata.own[propertyid]

		if temp == nil then
			syncdata.own[propertyid] = {
				optype,
				name,
				ownval
			}
		else
			table.insert(temp, optype)
			table.insert(temp, name)
			table.insert(temp, ownval)
		end
	end

	if aoiscope == PropertyTypes.AOI_ALL_CLIENTS then
		if type(value) == "table" then
			allval = value:getAllClientsValue()
		else
			allval = value
		end

		local temp = syncdata.all[propertyid]

		if temp == nil then
			syncdata.all[propertyid] = {
				optype,
				name,
				allval
			}
		else
			table.insert(temp, optype)
			table.insert(temp, name)
			table.insert(temp, allval)
		end
	end
end

local function collect(owner, ownercache, syncdata)
	for rootname, rootcache in pairs(ownercache) do
		local root = owner[rootname]

		if rootcache.all ~= nil then
			local aoiscope = rootcache.all

			recordData(syncdata, aoiscope, -1, PropertyTypes.OP_CHANGE, rootname, root)
		else
			if next(rootcache.ops) ~= nil then
				for _, op in ipairs(rootcache.ops) do
					local aoiscope, optype, subname, subvalue = unpack(op)

					recordData(syncdata, aoiscope, root._id, optype, subname, subvalue)
				end
			end

			local wraps = rootcache.wraps

			if wraps and next(wraps) ~= nil then
				for name, wrapcache in pairs(wraps) do
					local wrapper = root[name]

					if next(wrapcache.ops) ~= nil then
						for _, op in ipairs(wrapcache.ops) do
							local aoiscope, optype, subname, subvalue = unpack(op)

							recordData(syncdata, aoiscope, wrapper._id, optype, subname, subvalue)
						end
					end
				end
			end
		end
	end
end

function SyncStrategyMgr.syncProperty2Client(owner)
	local syncFunc = syncClientFunc[SyncStrategyMgr.syncMode]

	if syncFunc == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("syncStrategy %s has no sync client func registered", PropertyTypes.SYNC_MODE_DESC[SyncStrategyMgr.syncMode])
		end

		return
	end

	if owner ~= nil then
		local ownercache = syncCache[owner]

		if ownercache and next(ownercache) ~= nil then
			local syncdata = {
				own = {},
				all = {}
			}

			collect(owner, ownercache, syncdata)
			syncFunc(owner, syncdata)

			syncCache[owner] = nil
		end
	else
		for owner, ownercache in pairs(syncCache) do
			local syncdata = {
				own = {},
				all = {}
			}

			collect(owner, ownercache, syncdata)
			syncFunc(owner, syncdata)
		end

		syncCache = {}
	end
end

function SyncStrategyMgr.onClientSyncProperty(syncMode, owner, syncdata)
	local func = onClientSyncFunc[syncMode]

	if func ~= nil then
		func(owner, syncdata)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("onClientSyncProperty with unknown syncMode %s", syncMode)
	end
end

function SyncStrategyMgr.clear(owner)
	if owner ~= nil then
		syncCache[owner] = nil
	else
		syncCache = {}
	end
end

return SyncStrategyMgr
