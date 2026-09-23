-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Profiler\\UnityObjectRef.lua

local config = {
	m_bComparedMemoryRefFileAddTime = false,
	m_bSingleMemoryRefFileAddTime = false,
	m_bAllMemoryRefFileAddTime = false
}

local function FormatDateTimeNow()
	local cDateTime = os.date("*t")
	local strDateTime = string.format("%04d%02d%02d-%02d%02d%02d", tostring(cDateTime.year), tostring(cDateTime.month), tostring(cDateTime.day), tostring(cDateTime.hour), tostring(cDateTime.min), tostring(cDateTime.sec))

	return strDateTime
end

local function GetOriginalToStringResult(cObject)
	if not cObject then
		return ""
	end

	local cMt = getmetatable(cObject)

	if not cMt then
		return tostring(cObject)
	end

	local strName = ""
	local cToString = rawget(cMt, "__tostring")

	if cToString then
		rawset(cMt, "__tostring", nil)

		strName = tostring(cObject)

		rawset(cMt, "__tostring", cToString)
	else
		strName = tostring(cObject)
	end

	return strName
end

local function GetUnityInstanceIDMethod(cObject)
	return cObject.GetInstanceID
end

local function GetUnityDestroyed(cObject)
	return cObject.destroyed
end

local function TryGetUnityInstanceID(cObject)
	if not cObject then
		return false, nil
	end

	local bGetMethodOk, cGetInstanceID = pcall(GetUnityInstanceIDMethod, cObject)

	if not bGetMethodOk or type(cGetInstanceID) ~= "function" then
		return false, nil
	end

	local bCallOk, nInstanceID = pcall(cGetInstanceID, cObject)

	if not bCallOk then
		return false, nil
	end

	return true, nInstanceID
end

local function ReversePath(strPath)
	if not strPath or strPath == "" then
		return strPath or ""
	end

	local cTokens = {}
	local nLen = #strPath
	local nStart = 1
	local nDepth = 0

	for i = 1, nLen do
		local c = string.sub(strPath, i, i)

		if c == "[" then
			nDepth = nDepth + 1
		elseif c == "]" then
			if nDepth > 0 then
				nDepth = nDepth - 1
			end
		elseif c == "." and nDepth == 0 then
			cTokens[#cTokens + 1] = string.sub(strPath, nStart, i - 1)
			nStart = i + 1
		end
	end

	cTokens[#cTokens + 1] = string.sub(strPath, nStart, nLen)

	local cRev = {}

	for j = #cTokens, 1, -1 do
		cRev[#cRev + 1] = cTokens[j]
	end

	return table.concat(cRev, ".")
end

local function CreateObjectReferenceInfoContainer()
	local cContainer = {}
	local cObjectReferenceCount = {}

	setmetatable(cObjectReferenceCount, {
		__mode = "k"
	})

	local cObjectAddressToName = {}

	setmetatable(cObjectAddressToName, {
		__mode = "k"
	})

	cContainer.m_cObjectReferenceCount = cObjectReferenceCount
	cContainer.m_cObjectAddressToName = cObjectAddressToName
	cContainer.m_nStackLevel = -1
	cContainer.m_strShortSrc = "None"
	cContainer.m_nCurrentLine = -1

	return cContainer
end

local function CreateObjectReferenceInfoContainerFromFile(strFilePath)
	local cContainer = CreateObjectReferenceInfoContainer()

	cContainer.m_strShortSrc = strFilePath

	local cRefInfo = cContainer.m_cObjectReferenceCount
	local cNameInfo = cContainer.m_cObjectAddressToName
	local cInstanceIDInfo = {}

	cContainer.m_cObjectInstanceID = cInstanceIDInfo

	local cFile = assert(io.open(strFilePath, "rb"))

	for strLine in cFile:lines() do
		local strHeader = string.sub(strLine, 1, 2)

		if strHeader ~= "--" then
			local _, _, strAddr, strRefCount, strInstanceID, strTypeName, strObjName, strName = string.find(strLine, "(.+)\t(%d+)\t([^\t]+)\t([^\t]*)\t([^\t]*)\t(.*)")

			if strAddr then
				cRefInfo[strAddr] = strRefCount
				cNameInfo[strAddr] = strName
				cInstanceIDInfo[strAddr] = {
					id = strInstanceID,
					typeName = strTypeName or "",
					objName = strObjName or ""
				}
			end
		end
	end

	io.close(cFile)

	cFile = nil

	return cContainer
end

local CLASS_NAME_KEYS = {
	"__cname",
	"_className",
	"className",
	"typeName",
	"class"
}

local function probeClassName(tbl)
	if type(tbl) ~= "table" then
		return nil
	end

	for i = 1, #CLASS_NAME_KEYS do
		local v = rawget(tbl, CLASS_NAME_KEYS[i])

		if type(v) == "string" and v ~= "" then
			return v
		end
	end

	return nil
end

local function GetTableName(strName, cObject)
	if type(cObject) ~= "table" then
		return strName
	end

	local strClass = probeClassName(cObject)

	if not strClass then
		local visited = {
			[cObject] = true
		}
		local node = getmetatable(cObject)
		local nDepth = 0

		while type(node) == "table" and not visited[node] and nDepth < 8 do
			visited[node] = true
			nDepth = nDepth + 1
			strClass = probeClassName(node)

			if strClass then
				break
			end

			local idx = rawget(node, "__index")

			if type(idx) ~= "table" or visited[idx] then
				break
			end

			visited[idx] = true
			strClass = probeClassName(idx)

			if strClass then
				break
			end

			node = getmetatable(idx)

			if false then
				break
			end
		end
	end

	if strClass then
		strName = strName .. "[class:" .. strClass .. "]"
	end

	return strName
end

local function CollectObjectReferenceInMemory(strName, cObject, cDumpInfoContainer)
	if not cObject then
		return
	end

	if strName == "BddDataMgr" then
		return
	end

	strName = strName or ""
	cDumpInfoContainer = cDumpInfoContainer or CreateObjectReferenceInfoContainer()

	if not cDumpInfoContainer.m_bIncludeRegistry and (strName == "registry.1" or strName == "registry.2" or strName == "registry.3") then
		return
	end

	if cDumpInfoContainer.m_nStackLevel > 0 then
		local cStackInfo = debug.getinfo(cDumpInfoContainer.m_nStackLevel, "Sl")

		if cStackInfo then
			cDumpInfoContainer.m_strShortSrc = cStackInfo.short_src
			cDumpInfoContainer.m_nCurrentLine = cStackInfo.currentline
		end

		cDumpInfoContainer.m_nStackLevel = -1
	end

	local cRefInfoContainer = cDumpInfoContainer.m_cObjectReferenceCount
	local cNameInfoContainer = cDumpInfoContainer.m_cObjectAddressToName
	local strType = type(cObject)

	if strType == "table" then
		strName = GetTableName(strName, cObject)

		if cObject == _G then
			strName = strName .. "[_G]"
		end

		local bWeakK = false
		local bWeakV = false
		local cMt = getmetatable(cObject)

		if cMt then
			if type(cMt) == "table" then
				local strMode = rawget(cMt, "__mode")

				if strMode then
					if string.find(strMode, "k") then
						bWeakK = true
					end

					if string.find(strMode, "v") then
						bWeakV = true
					end
				end
			elseif type(cMt) == "string" then
				cMt = nil

				return
			end
		end

		cRefInfoContainer[cObject] = cRefInfoContainer[cObject] and cRefInfoContainer[cObject] + 1 or 1

		if cNameInfoContainer[cObject] then
			return
		end

		cNameInfoContainer[cObject] = strName

		if rawget(cObject, "_properties") then
			return
		end

		for k, v in pairs(cObject) do
			local strKeyType = type(k)

			if strKeyType == "table" then
				if not bWeakK then
					CollectObjectReferenceInMemory(strName .. ".[table:key.table]", k, cDumpInfoContainer)
				end

				if not bWeakV then
					CollectObjectReferenceInMemory(strName .. ".[table:value]", v, cDumpInfoContainer)
				end
			elseif strKeyType == "function" then
				if not bWeakK then
					CollectObjectReferenceInMemory(strName .. ".[table:key.function]", k, cDumpInfoContainer)
				end

				if not bWeakV then
					CollectObjectReferenceInMemory(strName .. ".[table:value]", v, cDumpInfoContainer)
				end
			elseif strKeyType == "thread" then
				if not bWeakK then
					CollectObjectReferenceInMemory(strName .. ".[table:key.thread]", k, cDumpInfoContainer)
				end

				if not bWeakV then
					CollectObjectReferenceInMemory(strName .. ".[table:value]", v, cDumpInfoContainer)
				end
			elseif strKeyType == "userdata" then
				if not bWeakK then
					CollectObjectReferenceInMemory(strName .. ".[table:key.userdata]", k, cDumpInfoContainer)
				end

				if not bWeakV then
					CollectObjectReferenceInMemory(strName .. ".[table:value]", v, cDumpInfoContainer)
				end
			else
				CollectObjectReferenceInMemory(strName .. "." .. k, v, cDumpInfoContainer)
			end
		end

		if cMt then
			CollectObjectReferenceInMemory(strName .. ".[metatable]", cMt, cDumpInfoContainer)
		end
	elseif strType == "function" then
		local cDInfo = debug.getinfo(cObject, "Sun") or {}

		cRefInfoContainer[cObject] = cRefInfoContainer[cObject] and cRefInfoContainer[cObject] + 1 or 1

		if cNameInfoContainer[cObject] then
			return
		end

		local nLineStart = cDInfo.linedefined or -1
		local nLineEnd = cDInfo.lastlinedefined or nLineStart
		local strSrc = cDInfo.short_src or "?"
		local strFnName = cDInfo.name

		if not strFnName or strFnName == "" then
			strFnName = "?"
		end

		local strRange

		if nLineEnd and nLineStart < nLineEnd then
			strRange = tostring(nLineStart) .. "-" .. tostring(nLineEnd)
		else
			strRange = tostring(nLineStart)
		end

		strName = strName .. "[func:" .. strFnName .. "@file:" .. strSrc .. ":" .. strRange .. "]"
		cNameInfoContainer[cObject] = strName

		local nUpsNum = cDInfo.nups or 0

		for i = 1, nUpsNum do
			local strUpName, cUpValue = debug.getupvalue(cObject, i)
			local strUpValueType = type(cUpValue)

			if strUpValueType == "table" then
				CollectObjectReferenceInMemory(strName .. ".[ups:table:" .. GetTableName(strUpName, cUpValue) .. "]", cUpValue, cDumpInfoContainer)
			elseif strUpValueType == "function" then
				CollectObjectReferenceInMemory(strName .. ".[ups:function:" .. strUpName .. "]", cUpValue, cDumpInfoContainer)
			elseif strUpValueType == "thread" then
				CollectObjectReferenceInMemory(strName .. ".[ups:thread:" .. strUpName .. "]", cUpValue, cDumpInfoContainer)
			elseif strUpValueType == "userdata" then
				CollectObjectReferenceInMemory(strName .. ".[ups:userdata:" .. strUpName .. "]", cUpValue, cDumpInfoContainer)
			end
		end

		local getfenv = debug.getfenv

		if getfenv then
			local cEnv = getfenv(cObject)

			if cEnv then
				CollectObjectReferenceInMemory(strName .. ".[function:environment]", cEnv, cDumpInfoContainer)
			end
		end
	elseif strType == "thread" then
		cRefInfoContainer[cObject] = cRefInfoContainer[cObject] and cRefInfoContainer[cObject] + 1 or 1

		if cNameInfoContainer[cObject] then
			return
		end

		cNameInfoContainer[cObject] = strName

		local getfenv = debug.getfenv

		if getfenv then
			local cEnv = getfenv(cObject)

			if cEnv then
				CollectObjectReferenceInMemory(strName .. ".[thread:environment]", cEnv, cDumpInfoContainer)
			end
		end

		local cMt = getmetatable(cObject)

		if cMt then
			CollectObjectReferenceInMemory(strName .. ".[thread:metatable]", cMt, cDumpInfoContainer)
		end
	elseif strType == "userdata" then
		cRefInfoContainer[cObject] = cRefInfoContainer[cObject] and cRefInfoContainer[cObject] + 1 or 1

		if cNameInfoContainer[cObject] then
			return
		end

		cNameInfoContainer[cObject] = strName

		local getfenv = debug.getfenv

		if getfenv then
			local cEnv = getfenv(cObject)

			if cEnv then
				CollectObjectReferenceInMemory(strName .. ".[userdata:environment]", cEnv, cDumpInfoContainer)
			end
		end

		local cMt = getmetatable(cObject)

		if cMt then
			CollectObjectReferenceInMemory(strName .. ".[userdata:metatable]", cMt, cDumpInfoContainer)
		end
	elseif strType == "string" then
		cRefInfoContainer[cObject] = cRefInfoContainer[cObject] and cRefInfoContainer[cObject] + 1 or 1

		if cNameInfoContainer[cObject] then
			return
		end

		cNameInfoContainer[cObject] = strName .. "[" .. strType .. "]"
	end
end

local function OutputUnityObjectSnapshot(strSavePath, fileName, nMaxRescords, strRootObjectName, cRootObject, cDumpInfoResultsBase, cDumpInfoResults, bOnlyNull)
	if not cDumpInfoResults then
		return
	end

	local strDateTime = FormatDateTimeNow()
	local cRefInfoBase = cDumpInfoResultsBase and cDumpInfoResultsBase.m_cObjectReferenceCount or nil
	local cNameInfoBase = cDumpInfoResultsBase and cDumpInfoResultsBase.m_cObjectAddressToName or nil
	local cRefInfo = cDumpInfoResults.m_cObjectReferenceCount
	local cNameInfo = cDumpInfoResults.m_cObjectAddressToName
	local cRes = {}
	local nIdx = 0

	for k in pairs(cRefInfo) do
		nIdx = nIdx + 1
		cRes[nIdx] = k
	end

	table.sort(cRes, function(l, r)
		return cRefInfo[l] > cRefInfo[r]
	end)

	local bOutputFile = fileName
	local cOutputHandle
	local cOutputEntry = print

	if bOutputFile then
		local strFileName = fileName
		local cFile = assert(io.open(strSavePath .. strFileName, "w"))

		cOutputHandle = cFile
		cOutputEntry = cFile.write
	end

	local function cOutputer(strContent)
		if cOutputHandle then
			cOutputEntry(cOutputHandle, strContent)
		else
			cOutputEntry(strContent)
		end
	end

	if cDumpInfoResultsBase then
		cOutputer("--------------------------------------------------------\n")
		cOutputer("-- This is compared Unity object reference information.\n")
		cOutputer("--------------------------------------------------------\n")
		cOutputer("-- Collect base memory reference at line:" .. tostring(cDumpInfoResultsBase.m_nCurrentLine) .. "@file:" .. cDumpInfoResultsBase.m_strShortSrc .. "\n")
		cOutputer("-- Collect compared memory reference at line:" .. tostring(cDumpInfoResults.m_nCurrentLine) .. "@file:" .. cDumpInfoResults.m_strShortSrc .. "\n")
	else
		cOutputer("--------------------------------------------------------\n")
		cOutputer("-- Collect Unity object reference at line:" .. tostring(cDumpInfoResults.m_nCurrentLine) .. "@file:" .. cDumpInfoResults.m_strShortSrc .. "\n")
	end

	cOutputer("--------------------------------------------------------\n")
	cOutputer("-- [Unity Object Address]\t[Reference Count]\t[InstanceID]\t[Type]\t[Name]\t[Reference Path]\n")
	cOutputer("--------------------------------------------------------\n")

	if strRootObjectName and cRootObject then
		if type(cRootObject) == "string" then
			cOutputer("-- From Root Object: \"" .. tostring(cRootObject) .. "\" (" .. strRootObjectName .. ")\n")
		else
			cOutputer("-- From Root Object: " .. GetOriginalToStringResult(cRootObject) .. " (" .. strRootObjectName .. ")\n")
		end
	end

	local nOutputCount = 0

	for i, v in ipairs(cRes) do
		if not cDumpInfoResultsBase or not cRefInfoBase[v] then
			if type(v) == "string" then
				local cInstanceIDInfo = cDumpInfoResults.m_cObjectInstanceID

				if cInstanceIDInfo and cInstanceIDInfo[v] and (nMaxRescords <= 0 or nOutputCount < nMaxRescords) then
					local cEntry = cInstanceIDInfo[v]

					if not bOnlyNull or cEntry.id == "leak" or cEntry.id == "destroyed" then
						cOutputer(tostring(v) .. "\t" .. tostring(cRefInfo[v]) .. "\t" .. tostring(cEntry.id) .. "\t" .. tostring(cEntry.typeName) .. "\t" .. tostring(cEntry.objName) .. "\t" .. ReversePath(cNameInfo[v]) .. "\n")

						nOutputCount = nOutputCount + 1
					end
				end
			elseif type(v) == "userdata" then
				local strLeakTag

				if xlua.isNullObject(v) then
					strLeakTag = "leak"
				else
					local bDOk, bDestroyed = pcall(GetUnityDestroyed, v)

					if bDOk and bDestroyed == true then
						strLeakTag = "destroyed"
					end
				end

				if not strLeakTag then
					local bOk, nInstanceID = TryGetUnityInstanceID(v)

					if bOk then
						if not bOnlyNull and (nMaxRescords <= 0 or nOutputCount < nMaxRescords) then
							local strTypeName = ""
							local strObjName = ""
							local cMt = getmetatable(v)

							if cMt then
								local cToStr = rawget(cMt, "__tostring")

								if cToStr then
									local bDescOk, strDesc = pcall(cToStr, v)

									if bDescOk and strDesc then
										local strN, strT = string.match(strDesc, "^(.+)%s+%((.+)%)$")

										if strN and strT then
											strObjName = strN
											strTypeName = strT
										else
											strTypeName = strDesc
										end
									end
								end
							end

							cOutputer(GetOriginalToStringResult(v) .. "\t" .. tostring(cRefInfo[v]) .. "\t" .. tostring(nInstanceID) .. "\t" .. strTypeName .. "\t" .. strObjName .. "\t" .. ReversePath(cNameInfo[v]) .. "\n")

							nOutputCount = nOutputCount + 1
						end
					elseif not bOnlyNull then
						local strTypeName = ""
						local strObjName = ""
						local cMt = getmetatable(v)

						if cMt then
							local cToStr = rawget(cMt, "__tostring")

							if cToStr then
								local bDescOk, strDesc = pcall(cToStr, v)

								if bDescOk and strDesc then
									local strN, strT = string.match(strDesc, "^(.+)%s+%((.+)%)$")

									if strN and strT then
										strObjName = strN
										strTypeName = strT
									else
										strTypeName = strDesc
									end
								end

								cOutputer(GetOriginalToStringResult(v) .. "\t" .. tostring(cRefInfo[v]) .. "\t" .. "noId" .. "\t" .. strTypeName .. "\t" .. strObjName .. "\t" .. ReversePath(cNameInfo[v]) .. "\n")

								nOutputCount = nOutputCount + 1
							end
						end
					end
				else
					local strTypeName = ""
					local strObjName = ""
					local cMt = getmetatable(v)

					if cMt then
						local cToStr = rawget(cMt, "__tostring")

						if cToStr then
							local bDescOk, strDesc = pcall(cToStr, v)

							if bDescOk and strDesc then
								local strN, strT = string.match(strDesc, "^(.+)%s+%((.+)%)$")

								if strN and strT then
									strObjName = strN
									strTypeName = strT
								else
									strTypeName = strDesc
								end
							end

							if not cMt._BddData_ then
								cOutputer(GetOriginalToStringResult(v) .. "\t" .. tostring(cRefInfo[v]) .. "\t" .. strLeakTag .. "\t" .. strTypeName .. "\t" .. strObjName .. "\t" .. ReversePath(cNameInfo[v]) .. "\n")

								nOutputCount = nOutputCount + 1
							end
						end
					end
				end
			end
		end
	end

	if bOutputFile then
		io.close(cOutputHandle)

		cOutputHandle = nil
	end
end

local function DumpMemorySnapshot(strSavePath, strExtraFileName, nMaxRescords, strRootObjectName, cRootObject, bIncludeRegistry, bOnlyNull)
	local strDateTime = FormatDateTimeNow()

	if cRootObject then
		if not strRootObjectName or string.len(strRootObjectName) == 0 then
			strRootObjectName = tostring(cRootObject)
		end
	else
		cRootObject = debug.getregistry()
		strRootObjectName = "registry"
	end

	local cDumpInfoContainer = CreateObjectReferenceInfoContainer()

	cDumpInfoContainer.m_bIncludeRegistry = bIncludeRegistry and true or false

	local cStackInfo = debug.getinfo(2, "Sl")

	if cStackInfo then
		cDumpInfoContainer.m_strShortSrc = cStackInfo.short_src
		cDumpInfoContainer.m_nCurrentLine = cStackInfo.currentline
	end

	CollectObjectReferenceInMemory(strRootObjectName, cRootObject, cDumpInfoContainer)
	OutputUnityObjectSnapshot(strSavePath, strExtraFileName, nMaxRescords, strRootObjectName, cRootObject, nil, cDumpInfoContainer, bOnlyNull)
end

local function DumpMemorySnapshotCompared(strSavePath, strExtraFileName, nMaxRescords, cResultBefore, cResultAfter)
	OutputUnityObjectSnapshot(strSavePath, strExtraFileName, nMaxRescords, nil, nil, cResultBefore, cResultAfter)
end

local function DumpMemorySnapshotComparedFile(strSavePath, strExtraFileName, nMaxRescords, strResultFilePathBefore, strResultFilePathAfter)
	local cResultBefore = CreateObjectReferenceInfoContainerFromFile(strResultFilePathBefore)
	local cResultAfter = CreateObjectReferenceInfoContainerFromFile(strResultFilePathAfter)

	OutputUnityObjectSnapshot(strSavePath, strExtraFileName, nMaxRescords, nil, nil, cResultBefore, cResultAfter)
end

local cFunctionTagCache = setmetatable({}, {
	__mode = "k"
})

local function GetDelegateClock()
	return os.clock()
end

local function FormatDelegateSeconds(nSeconds)
	return string.format("%.4f", nSeconds or 0)
end

local function GetFunctionTag(cFunction)
	local strCached = cFunctionTagCache[cFunction]

	if strCached then
		return strCached
	end

	local cDInfo = debug.getinfo(cFunction, "Sun") or {}
	local nLineStart = cDInfo.linedefined or -1
	local nLineEnd = cDInfo.lastlinedefined or nLineStart
	local strRange

	if nLineEnd and nLineStart < nLineEnd then
		strRange = tostring(nLineStart) .. "-" .. tostring(nLineEnd)
	else
		strRange = tostring(nLineStart)
	end

	local strFnName = cDInfo.name

	if not strFnName or strFnName == "" then
		strFnName = "?"
	end

	local strTag = "[func:" .. strFnName .. "@file:" .. tostring(cDInfo.short_src or "?") .. ":" .. strRange .. "]"

	cFunctionTagCache[cFunction] = strTag

	return strTag
end

local function GetUnityUserdataInfo(cObject, bOnlyNull)
	if type(cObject) ~= "userdata" then
		return nil
	end

	local strLeakTag

	if xlua and xlua.isNullObject and xlua.isNullObject(cObject) then
		strLeakTag = "leak"
	else
		local bDestroyedOk, bDestroyed = pcall(GetUnityDestroyed, cObject)

		if bDestroyedOk and bDestroyed == true then
			strLeakTag = "destroyed"
		end
	end

	if bOnlyNull and not strLeakTag then
		return nil
	end

	local bIdOk, nInstanceID = TryGetUnityInstanceID(cObject)

	if not bIdOk and not strLeakTag then
		return nil
	end

	local strTypeName = ""
	local strObjName = ""
	local cMt = getmetatable(cObject)

	if cMt then
		local cToStr = rawget(cMt, "__tostring")

		if cToStr then
			local bDescOk, strDesc = pcall(cToStr, cObject)

			if bDescOk and strDesc then
				local strN, strT = string.match(strDesc, "^(.+)%s+%((.+)%)$")

				if strN and strT then
					strObjName = strN
					strTypeName = strT
				else
					strTypeName = strDesc
				end
			end
		end
	end

	return {
		address = GetOriginalToStringResult(cObject),
		instanceID = bIdOk and tostring(nInstanceID) or "noId",
		typeName = strTypeName,
		objName = strObjName,
		leakTag = strLeakTag or ""
	}
end

local function GetDelegateDefaultOptions(bOnlyNull, bIncludeEnv)
	return {
		maxDepth = 32,
		includeGlobalObjects = false,
		includeRegistryPools = false,
		includeWeak = false,
		includeMetatable = false,
		onlyNull = bOnlyNull ~= false,
		includeEnv = bIncludeEnv and true or false
	}
end

local function NormalizeDelegateOptions(cOptions, bOnlyNull, bIncludeEnv)
	local cDefault = GetDelegateDefaultOptions(bOnlyNull, bIncludeEnv)

	if type(cOptions) ~= "table" then
		return cDefault
	end

	if cOptions.onlyNull ~= nil then
		cDefault.onlyNull = cOptions.onlyNull and true or false
	end

	if cOptions.includeEnv ~= nil then
		cDefault.includeEnv = cOptions.includeEnv and true or false
	end

	if cOptions.includeMetatable ~= nil then
		cDefault.includeMetatable = cOptions.includeMetatable and true or false
	end

	if cOptions.includeWeak ~= nil then
		cDefault.includeWeak = cOptions.includeWeak and true or false
	end

	if cOptions.includeRegistryPools ~= nil then
		cDefault.includeRegistryPools = cOptions.includeRegistryPools and true or false
	end

	if cOptions.includeGlobalObjects ~= nil then
		cDefault.includeGlobalObjects = cOptions.includeGlobalObjects and true or false
	end

	if type(cOptions.maxDepth) == "number" and cOptions.maxDepth >= 0 then
		cDefault.maxDepth = cOptions.maxDepth
	end

	return cDefault
end

local function CreateDelegateStats()
	return {
		cacheHit = 0,
		tablePairs = 0,
		threads = 0,
		userdatas = 0,
		functions = 0,
		tables = 0,
		nodes = 0,
		iterError = 0,
		maxDepthHit = 0,
		globalSkipped = 0,
		registryPoolSkipped = 0,
		weakSkipped = 0,
		metatableWalked = 0,
		metatableSkipped = 0,
		envWalked = 0,
		envSkipped = 0,
		cacheUnsafe = 0,
		cacheBusyHit = 0,
		cacheBypassCycle = 0,
		cacheMiss = 0
	}
end

local function CreateDelegateVisitState()
	return {
		unsafe = false,
		state = {}
	}
end

local function AddDelegateGlobalObject(cObjects, cObject)
	local strType = type(cObject)

	if strType == "table" or strType == "function" then
		cObjects[cObject] = true
	end
end

local function AddDelegateTableObject(cObjects, cObject)
	if type(cObject) == "table" then
		cObjects[cObject] = true
	end
end

local function AddDelegateGlobalTableMembers(cObjects, cObject)
	if type(cObject) ~= "table" then
		return
	end

	for _, v in next, cObject do
		AddDelegateGlobalObject(cObjects, v)
	end
end

local function CreateDelegateGlobalObjects()
	local cObjects = {}

	AddDelegateGlobalObject(cObjects, _G)

	if type(_G) == "table" then
		for _, v in next, _G do
			AddDelegateGlobalObject(cObjects, v)
		end
	end

	if type(package) == "table" and type(package.loaded) == "table" then
		AddDelegateGlobalObject(cObjects, package.loaded)

		for _, v in next, package.loaded do
			AddDelegateGlobalObject(cObjects, v)
			AddDelegateGlobalTableMembers(cObjects, v)
		end
	end

	return cObjects
end

local function ShouldSkipDelegateRegistryPool(cOptions, cObject)
	if type(cObject) ~= "table" then
		return false
	end

	return cOptions.registryPools and cOptions.registryPools[cObject] == true
end

local function ShouldSkipDelegateGlobalObject(cOptions, cObject, nDepth)
	if cOptions.includeGlobalObjects or nDepth <= 0 then
		return false
	end

	return cOptions.globalObjects and cOptions.globalObjects[cObject] == true
end

local function IgnoreDelegateUnityRefsIterError()
	return nil
end

local CollectDelegateUnityRefs, CollectDelegateUnityRefsNoCache

local function CollectDelegateUnityRefsTablePairs(cCtx)
	local strPath = cCtx.path
	local cObject = cCtx.object
	local cResult = cCtx.result
	local cVisitState = cCtx.visitState
	local nDepth = cCtx.depth
	local cOptions = cCtx.options
	local cStats = cCtx.stats
	local bWeakK = cCtx.weakK
	local bWeakV = cCtx.weakV

	for k, v in pairs(cObject) do
		cStats.tablePairs = cStats.tablePairs + 1

		local strKeyType = type(k)

		if strKeyType == "table" then
			if not bWeakK or cOptions.includeWeak then
				CollectDelegateUnityRefs(strPath .. ".[table:key.table]", k, cResult, cVisitState, nDepth + 1, cOptions, cStats)
			else
				cStats.weakSkipped = cStats.weakSkipped + 1
			end

			if not bWeakV or cOptions.includeWeak then
				CollectDelegateUnityRefs(strPath .. ".[table:value]", v, cResult, cVisitState, nDepth + 1, cOptions, cStats)
			else
				cStats.weakSkipped = cStats.weakSkipped + 1
			end
		elseif strKeyType == "function" then
			if not bWeakK or cOptions.includeWeak then
				CollectDelegateUnityRefs(strPath .. ".[table:key.function]", k, cResult, cVisitState, nDepth + 1, cOptions, cStats)
			else
				cStats.weakSkipped = cStats.weakSkipped + 1
			end

			if not bWeakV or cOptions.includeWeak then
				CollectDelegateUnityRefs(strPath .. ".[table:value]", v, cResult, cVisitState, nDepth + 1, cOptions, cStats)
			else
				cStats.weakSkipped = cStats.weakSkipped + 1
			end
		elseif strKeyType == "thread" then
			if not bWeakK or cOptions.includeWeak then
				CollectDelegateUnityRefs(strPath .. ".[table:key.thread]", k, cResult, cVisitState, nDepth + 1, cOptions, cStats)
			else
				cStats.weakSkipped = cStats.weakSkipped + 1
			end

			if not bWeakV or cOptions.includeWeak then
				CollectDelegateUnityRefs(strPath .. ".[table:value]", v, cResult, cVisitState, nDepth + 1, cOptions, cStats)
			else
				cStats.weakSkipped = cStats.weakSkipped + 1
			end
		elseif strKeyType == "userdata" then
			if not bWeakK or cOptions.includeWeak then
				CollectDelegateUnityRefs(strPath .. ".[table:key.userdata]", k, cResult, cVisitState, nDepth + 1, cOptions, cStats)
			else
				cStats.weakSkipped = cStats.weakSkipped + 1
			end

			if not bWeakV or cOptions.includeWeak then
				CollectDelegateUnityRefs(strPath .. ".[table:value]", v, cResult, cVisitState, nDepth + 1, cOptions, cStats)
			else
				cStats.weakSkipped = cStats.weakSkipped + 1
			end
		elseif not bWeakV or cOptions.includeWeak then
			CollectDelegateUnityRefs(strPath .. "." .. tostring(k), v, cResult, cVisitState, nDepth + 1, cOptions, cStats)
		else
			cStats.weakSkipped = cStats.weakSkipped + 1
		end
	end
end

local function AppendCachedDelegateResults(strPath, cCached, cResult)
	for i = 1, #cCached do
		local cEntry = cCached[i]

		cResult[#cResult + 1] = {
			info = cEntry.info,
			path = strPath .. cEntry.relPath
		}
	end
end

local function MakeDelegateCacheRelativeResults(strBasePath, cResult, nResultStart)
	local cCached = {}
	local nBaseLen = #strBasePath

	for i = nResultStart, #cResult do
		local cEntry = cResult[i]
		local strPath = cEntry.path or ""
		local strRelPath = ""

		if string.sub(strPath, 1, nBaseLen) == strBasePath then
			strRelPath = string.sub(strPath, nBaseLen + 1)
		else
			strRelPath = strPath
		end

		cCached[#cCached + 1] = {
			info = cEntry.info,
			relPath = strRelPath
		}
	end

	return cCached
end

function CollectDelegateUnityRefs(strPath, cObject, cResult, cVisitState, nDepth, cOptions, cStats)
	if not cObject then
		return
	end

	if nDepth > cOptions.maxDepth then
		cStats.maxDepthHit = cStats.maxDepthHit + 1
		cVisitState.unsafe = true

		return
	end

	local strType = type(cObject)

	if strType == "table" or strType == "function" or strType == "userdata" or strType == "thread" then
		local cVisited = cVisitState.state
		local cVisitInfo = cVisited[cObject]

		if cVisitInfo then
			if cVisitInfo == "busy" then
				cStats.cacheBypassCycle = cStats.cacheBypassCycle + 1
				cVisitState.unsafe = true
			end

			return
		end

		local nRemainingDepth = cOptions.maxDepth - nDepth
		local cObjectCache = cOptions.cache[cObject]
		local cCached = cObjectCache and cObjectCache[nRemainingDepth]

		if cCached then
			if cCached == "busy" then
				cStats.cacheBusyHit = cStats.cacheBusyHit + 1
				cVisitState.unsafe = true

				return
			end

			cStats.cacheHit = cStats.cacheHit + 1

			AppendCachedDelegateResults(strPath, cCached, cResult)

			return
		end

		cStats.cacheMiss = cStats.cacheMiss + 1
		cVisited[cObject] = "busy"

		if not cObjectCache then
			cObjectCache = {}
			cOptions.cache[cObject] = cObjectCache
		end

		cObjectCache[nRemainingDepth] = "busy"

		local nResultStart = #cResult + 1
		local bUnsafeBefore = cVisitState.unsafe

		cVisitState.unsafe = false

		CollectDelegateUnityRefsNoCache(strPath, cObject, cResult, cVisitState, nDepth, cOptions, cStats, strType)

		if cVisitState.unsafe then
			cObjectCache[nRemainingDepth] = nil
			cStats.cacheUnsafe = cStats.cacheUnsafe + 1
		else
			cObjectCache[nRemainingDepth] = MakeDelegateCacheRelativeResults(strPath, cResult, nResultStart)
		end

		cVisitState.unsafe = bUnsafeBefore or cVisitState.unsafe
		cVisited[cObject] = nil

		return
	end

	CollectDelegateUnityRefsNoCache(strPath, cObject, cResult, cVisitState, nDepth, cOptions, cStats, strType)
end

function CollectDelegateUnityRefsNoCache(strPath, cObject, cResult, cVisitState, nDepth, cOptions, cStats, strType)
	cStats.nodes = cStats.nodes + 1

	if strType == "userdata" then
		cStats.userdatas = cStats.userdatas + 1

		local cInfo = GetUnityUserdataInfo(cObject, cOptions.onlyNull)

		if cInfo and (not cOptions.onlyNull or cInfo.leakTag == "leak" or cInfo.leakTag == "destroyed") then
			cResult[#cResult + 1] = {
				info = cInfo,
				path = strPath
			}
		end

		local getfenv = debug.getfenv

		if cOptions.includeEnv and getfenv then
			cStats.envWalked = cStats.envWalked + 1

			local cEnv = getfenv(cObject)

			if cEnv then
				CollectDelegateUnityRefs(strPath .. ".[userdata:environment]", cEnv, cResult, cVisitState, nDepth + 1, cOptions, cStats)
			end
		elseif getfenv then
			cStats.envSkipped = cStats.envSkipped + 1
		end

		return
	end

	if strType == "table" then
		cStats.tables = cStats.tables + 1

		if not cOptions.includeRegistryPools and ShouldSkipDelegateRegistryPool(cOptions, cObject) then
			cStats.registryPoolSkipped = cStats.registryPoolSkipped + 1

			return
		end

		if ShouldSkipDelegateGlobalObject(cOptions, cObject, nDepth) then
			cStats.globalSkipped = cStats.globalSkipped + 1

			return
		end

		local bWeakK = false
		local bWeakV = false
		local cMt = getmetatable(cObject)

		if type(cMt) == "table" then
			local strMode = rawget(cMt, "__mode")

			if strMode then
				bWeakK = string.find(strMode, "k") ~= nil
				bWeakV = string.find(strMode, "v") ~= nil
			end
		end

		local cIterCtx = {
			path = strPath,
			object = cObject,
			result = cResult,
			visitState = cVisitState,
			depth = nDepth,
			options = cOptions,
			stats = cStats,
			weakK = bWeakK,
			weakV = bWeakV
		}
		local bIterOk = xpcall(CollectDelegateUnityRefsTablePairs, IgnoreDelegateUnityRefsIterError, cIterCtx)

		if not bIterOk then
			cStats.iterError = cStats.iterError + 1
			cVisitState.unsafe = true

			return
		end

		if cMt then
			if cOptions.includeMetatable then
				cStats.metatableWalked = cStats.metatableWalked + 1

				CollectDelegateUnityRefs(strPath .. ".[metatable]", cMt, cResult, cVisitState, nDepth + 1, cOptions, cStats)
			else
				cStats.metatableSkipped = cStats.metatableSkipped + 1
			end
		end

		return
	end

	if strType == "function" then
		cStats.functions = cStats.functions + 1

		if ShouldSkipDelegateGlobalObject(cOptions, cObject, nDepth) then
			cStats.globalSkipped = cStats.globalSkipped + 1

			return
		end

		local strFuncPath = strPath .. GetFunctionTag(cObject)
		local cDInfo = debug.getinfo(cObject, "u") or {}
		local nUpsNum = cDInfo.nups or 0

		for i = 1, nUpsNum do
			local strUpName, cUpValue = debug.getupvalue(cObject, i)

			if strUpName ~= "_ENV" or cOptions.includeEnv then
				CollectDelegateUnityRefs(strFuncPath .. ".[ups:" .. tostring(strUpName) .. "]", cUpValue, cResult, cVisitState, nDepth + 1, cOptions, cStats)
			else
				cStats.envSkipped = cStats.envSkipped + 1
			end
		end

		local getfenv = debug.getfenv

		if cOptions.includeEnv and getfenv then
			cStats.envWalked = cStats.envWalked + 1

			local cEnv = getfenv(cObject)

			if cEnv then
				CollectDelegateUnityRefs(strFuncPath .. ".[function:environment]", cEnv, cResult, cVisitState, nDepth + 1, cOptions, cStats)
			end
		elseif getfenv then
			cStats.envSkipped = cStats.envSkipped + 1
		end

		return
	end

	if strType == "thread" then
		cStats.threads = cStats.threads + 1

		local getfenv = debug.getfenv

		if cOptions.includeEnv and getfenv then
			cStats.envWalked = cStats.envWalked + 1

			local cEnv = getfenv(cObject)

			if cEnv then
				CollectDelegateUnityRefs(strPath .. ".[thread:environment]", cEnv, cResult, cVisitState, nDepth + 1, cOptions, cStats)
			end
		elseif getfenv then
			cStats.envSkipped = cStats.envSkipped + 1
		end
	end
end

local function DumpDelegateUnityRefs(strSavePath, strExtraFileName, nMaxRescords, bOnlyNull, bIncludeEnv, cOptions)
	local nTotalBegin = GetDelegateClock()
	local cRegistry = debug.getregistry()
	local cRows = {}
	local nDelegateCount = 0
	local cScanOptions = NormalizeDelegateOptions(cOptions, bOnlyNull, bIncludeEnv)

	cScanOptions.cache = {}
	cScanOptions.registryPools = {}

	AddDelegateTableObject(cScanOptions.registryPools, cRegistry[1])
	AddDelegateTableObject(cScanOptions.registryPools, cRegistry[2])
	AddDelegateTableObject(cScanOptions.registryPools, cRegistry[3])

	cScanOptions.globalObjects = CreateDelegateGlobalObjects()

	local cStats = CreateDelegateStats()
	local nScanBegin = GetDelegateClock()

	for k, v in pairs(cRegistry) do
		if type(k) == "number" and type(v) == "function" and rawget(cRegistry, v) == k then
			nDelegateCount = nDelegateCount + 1

			local cResult = {}
			local strRootPath = "registry." .. tostring(k)

			CollectDelegateUnityRefs(strRootPath, v, cResult, CreateDelegateVisitState(), 0, cScanOptions, cStats)

			for i = 1, #cResult do
				local cInfo = cResult[i].info

				cRows[#cRows + 1] = {
					ref = k,
					func = GetFunctionTag(v),
					info = cInfo,
					path = cResult[i].path
				}
			end
		end
	end

	local nScanCost = GetDelegateClock() - nScanBegin
	local nSortBegin = GetDelegateClock()

	table.sort(cRows, function(l, r)
		if l.ref == r.ref then
			return l.path < r.path
		end

		return l.ref < r.ref
	end)

	local nSortCost = GetDelegateClock() - nSortBegin
	local bOutputFile = strExtraFileName
	local cOutputHandle
	local cOutputEntry = print

	if bOutputFile then
		local cFile = assert(io.open(strSavePath .. strExtraFileName, "w"))

		cOutputHandle = cFile
		cOutputEntry = cFile.write
	end

	local function cOutputer(strContent)
		if cOutputHandle then
			cOutputEntry(cOutputHandle, strContent)
		else
			cOutputEntry(strContent)
		end
	end

	local nWriteBegin = GetDelegateClock()

	cOutputer("--------------------------------------------------------\n")
	cOutputer("-- Collect xLua delegate closure Unity object references.\n")
	cOutputer("-- Delegate registry pattern: registry[ref] = function and registry[function] = ref.\n")
	cOutputer("-- DelegateCount=" .. tostring(nDelegateCount) .. ", Rows=" .. tostring(#cRows) .. ", OnlyNull=" .. tostring(cScanOptions.onlyNull) .. ", IncludeEnv=" .. tostring(cScanOptions.includeEnv) .. ", IncludeMetatable=" .. tostring(cScanOptions.includeMetatable) .. ", IncludeWeak=" .. tostring(cScanOptions.includeWeak) .. ", IncludeRegistryPools=" .. tostring(cScanOptions.includeRegistryPools) .. ", IncludeGlobalObjects=" .. tostring(cScanOptions.includeGlobalObjects) .. ", MaxDepth=" .. tostring(cScanOptions.maxDepth) .. "\n")
	cOutputer("-- Stats: Nodes=" .. tostring(cStats.nodes) .. ", Tables=" .. tostring(cStats.tables) .. ", Functions=" .. tostring(cStats.functions) .. ", Userdatas=" .. tostring(cStats.userdatas) .. ", Threads=" .. tostring(cStats.threads) .. ", TablePairs=" .. tostring(cStats.tablePairs) .. ", CacheHit=" .. tostring(cStats.cacheHit) .. ", CacheMiss=" .. tostring(cStats.cacheMiss) .. ", CacheBypassCycle=" .. tostring(cStats.cacheBypassCycle) .. ", CacheBusyHit=" .. tostring(cStats.cacheBusyHit) .. ", CacheUnsafe=" .. tostring(cStats.cacheUnsafe) .. ", EnvSkipped=" .. tostring(cStats.envSkipped) .. ", EnvWalked=" .. tostring(cStats.envWalked) .. ", MetatableSkipped=" .. tostring(cStats.metatableSkipped) .. ", MetatableWalked=" .. tostring(cStats.metatableWalked) .. ", WeakSkipped=" .. tostring(cStats.weakSkipped) .. ", RegistryPoolSkipped=" .. tostring(cStats.registryPoolSkipped) .. ", GlobalSkipped=" .. tostring(cStats.globalSkipped) .. ", MaxDepthHit=" .. tostring(cStats.maxDepthHit) .. ", IterError=" .. tostring(cStats.iterError) .. "\n")
	cOutputer("--------------------------------------------------------\n")
	cOutputer("-- [DelegateRef]\t[DelegateFunction]\t[Unity Object Address]\t[InstanceID]\t[LeakTag]\t[Type]\t[Name]\t[Reference Path]\n")
	cOutputer("--------------------------------------------------------\n")

	local nOutputCount = 0

	for i = 1, #cRows do
		if nMaxRescords <= 0 or nOutputCount < nMaxRescords then
			local cRow = cRows[i]
			local cInfo = cRow.info

			cOutputer(tostring(cRow.ref) .. "\t" .. tostring(cRow.func) .. "\t" .. tostring(cInfo.address) .. "\t" .. tostring(cInfo.instanceID) .. "\t" .. tostring(cInfo.leakTag) .. "\t" .. tostring(cInfo.typeName) .. "\t" .. tostring(cInfo.objName) .. "\t" .. tostring(cRow.path) .. "\n")

			nOutputCount = nOutputCount + 1
		end
	end

	if bOutputFile then
		local nWriteBeforeFooterCost = GetDelegateClock() - nWriteBegin
		local nTotalBeforeFooterCost = GetDelegateClock() - nTotalBegin

		cOutputer("--------------------------------------------------------\n")
		cOutputer("-- Timing: Scan=" .. FormatDelegateSeconds(nScanCost) .. ", Sort=" .. FormatDelegateSeconds(nSortCost) .. ", WriteBeforeFooter=" .. FormatDelegateSeconds(nWriteBeforeFooterCost) .. ", TotalBeforeFooter=" .. FormatDelegateSeconds(nTotalBeforeFooterCost) .. "\n")
		io.close(cOutputHandle)

		cOutputHandle = nil
	end
end

local UnityObjectRef = {
	m_cMethods = {},
	m_cHelpers = {},
	m_cBases = {}
}

UnityObjectRef.m_cConfig = config
UnityObjectRef.m_cMethods.DumpMemorySnapshot = DumpMemorySnapshot
UnityObjectRef.m_cMethods.DumpMemorySnapshotCompared = DumpMemorySnapshotCompared
UnityObjectRef.m_cMethods.DumpMemorySnapshotComparedFile = DumpMemorySnapshotComparedFile
UnityObjectRef.m_cMethods.DumpDelegateUnityRefs = DumpDelegateUnityRefs
UnityObjectRef.m_cHelpers.FormatDateTimeNow = FormatDateTimeNow
UnityObjectRef.m_cHelpers.GetOriginalToStringResult = GetOriginalToStringResult
UnityObjectRef.m_cBases.CreateObjectReferenceInfoContainer = CreateObjectReferenceInfoContainer
UnityObjectRef.m_cBases.CreateObjectReferenceInfoContainerFromFile = CreateObjectReferenceInfoContainerFromFile
UnityObjectRef.m_cBases.CollectObjectReferenceInMemory = CollectObjectReferenceInMemory
UnityObjectRef.m_cBases.OutputUnityObjectSnapshot = OutputUnityObjectSnapshot

local function MakeTaggedFileName(strFileName, strTag)
	if not strFileName or strFileName == "" then
		return strFileName
	end

	local strBase, strExt = string.match(strFileName, "^(.*)%.([^%.]*)$")

	if strBase then
		return strBase .. strTag .. "." .. strExt
	end

	return strFileName .. strTag
end

local function MakeRegisterFileName(strFileName)
	return MakeTaggedFileName(strFileName, "_register")
end

local function MakeDelegateFileName(strFileName)
	return MakeTaggedFileName(strFileName, "_delegate")
end

local function DumpAllUnityObjectRefs(strRoot, strFileName, includeRegistry, onlyNull, delegateOptions)
	UnityObjectRef.m_cMethods.DumpMemorySnapshot(strRoot, strFileName, -1, nil, nil, includeRegistry, onlyNull)

	local strRegName = MakeRegisterFileName(strFileName)

	if strRegName and strRegName ~= strFileName then
		UnityObjectRef.m_cMethods.DumpMemorySnapshot(strRoot, strRegName, -1, nil, nil, true, onlyNull)
	end

	if delegateOptions then
		local strDelegateName = MakeDelegateFileName(strFileName)

		if strDelegateName and strDelegateName ~= strFileName then
			if type(delegateOptions) == "table" then
				UnityObjectRef.m_cMethods.DumpDelegateUnityRefs(strRoot, strDelegateName, -1, onlyNull, nil, delegateOptions)
			else
				UnityObjectRef.m_cMethods.DumpDelegateUnityRefs(strRoot, strDelegateName, -1, onlyNull, true)
			end
		end
	end
end

function UnityObjectRef.DumpFile(filename, includeRegistry, onlyNull, delegateOptions)
	collectgarbage("collect")
	collectgarbage("collect")
	DumpAllUnityObjectRefs("./", filename, includeRegistry, onlyNull, delegateOptions)
end

function UnityObjectRef.DumpFileFormat(filenameformat, includeRegistry, onlyNull, delegateOptions)
	local now = FormatDateTimeNow()

	collectgarbage("collect")
	collectgarbage("collect")

	local root

	root = UNITY_EDITOR and "./Logs/" or Application.persistentDataPath

	local strFileName = string.format(filenameformat, now)

	DumpAllUnityObjectRefs(root, strFileName, includeRegistry, onlyNull, delegateOptions)
end

function UnityObjectRef.DumpDelegateUnityRefs(filename, onlyNull, includeEnv, options)
	collectgarbage("collect")
	collectgarbage("collect")

	if type(onlyNull) == "table" then
		UnityObjectRef.m_cMethods.DumpDelegateUnityRefs("./", filename, -1, nil, nil, onlyNull)
	else
		UnityObjectRef.m_cMethods.DumpDelegateUnityRefs("./", filename, -1, onlyNull, includeEnv, options)
	end
end

function UnityObjectRef.DumpDelegateUnityRefsFormat(filenameformat, onlyNull, includeEnv, options)
	local now = FormatDateTimeNow()

	collectgarbage("collect")
	collectgarbage("collect")

	local root

	root = UNITY_EDITOR and "./Logs/" or Application.persistentDataPath

	local strFileName = string.format(filenameformat, now)

	if type(onlyNull) == "table" then
		UnityObjectRef.m_cMethods.DumpDelegateUnityRefs(root, strFileName, -1, nil, nil, onlyNull)
	else
		UnityObjectRef.m_cMethods.DumpDelegateUnityRefs(root, strFileName, -1, onlyNull, includeEnv, options)
	end
end

function UnityObjectRef.Dump(filename, includeRegistry, onlyNull, delegateOptions)
	collectgarbage("collect")
	collectgarbage("collect")
	DumpAllUnityObjectRefs("./", filename, includeRegistry, onlyNull, delegateOptions)

	package.loaded["Core.Profiler.UnityObjectRef"] = nil

	collectgarbage("collect")
end

function UnityObjectRef.CmpFile(filename1, filename2, output)
	collectgarbage("collect")
	collectgarbage("collect")
	UnityObjectRef.m_cMethods.DumpMemorySnapshotComparedFile("./", output or "unity_obj_ref_cmp.txt", -1, filename1, filename2)

	package.loaded["Core.Profiler.UnityObjectRef"] = nil

	collectgarbage("collect")
	collectgarbage("collect")
end

UnityObjectRef.Cmp = UnityObjectRef.CmpFile

return UnityObjectRef
