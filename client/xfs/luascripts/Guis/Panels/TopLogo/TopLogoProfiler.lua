-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\TopLogoProfiler.lua

local TopLogoConst = require("Const.TopLogoConst")
local Time = require("Core.Common.Time")
local TopLogoProfiler = {}

if TopLogoConst.OPEN_TOPLOGO_PROFILE then
	local File = require("Core.Common.File")
	local _enabled = false
	local _records = {}
	local _agg = {}
	local _pending = {}
	local _timelines = {}
	local _trackedTopLogoEntities = setmetatable({}, {
		__mode = "k"
	})
	local _sessionGeneration = 0
	local _lazyItemStats = {}
	local _activeShellCountByActorId = {}
	local _sessionOutput
	local _sessionStartNs = 0
	local _sessionStartFrame = 0
	local _sampleIdx = 0
	local _getNs = phonestcore.getNanosecondUTC
	local _nsPerUs = 1000
	local _nsPerMs = 1000000
	local _strongDemandReasons = {
		pet_ai_tracking = true,
		rob_egg = true,
		type_switch = true,
		player_hub = true,
		ensure_component = true,
		active_component_wake = true,
		explicit_show = true,
		lod_visible = true,
		focus = true,
		photo = true,
		weak = true,
		alert = true,
		pvp2 = true,
		gm_dialogue = true,
		home_car_liked = true,
		pet_chat = true,
		dialogue = true,
		bubble = true
	}
	local _itemCreatedReasons = {
		pet_ai_tracking = true,
		rob_egg = true,
		type_switch = true,
		player_hub = true,
		ensure_component = true,
		active_component_wake = true,
		explicit_show = true,
		lod_visible = true,
		ui_reopen_eager = true,
		start_eager = true,
		focus = true,
		photo = true,
		weak = true,
		alert = true,
		pvp2 = true,
		gm_dialogue = true,
		home_car_liked = true,
		pet_chat = true,
		dialogue = true,
		bubble = true
	}

	local function _newLazyItemStats()
		return {
			maxEnsureComponentCreatedPerFrame = 0,
			maxEnsureComponentPerFrame = 0,
			ensureComponentCreatedCount = 0,
			ensureComponentCallCount = 0,
			maxPrefabRequestPerFrame = 0,
			maxItemCreatedPerFrame = 0,
			prefabReleasedCount = 0,
			prefabCancelledCount = 0,
			prefabFailedCount = 0,
			peakNonWhitelistItemCount = 0,
			currentNonWhitelistItemCount = 0,
			peakWhitelistItemCount = 0,
			currentWhitelistItemCount = 0,
			peakReadyPrefabCount = 0,
			currentReadyPrefabCount = 0,
			peakLoadingPrefabCount = 0,
			currentLoadingPrefabCount = 0,
			peakShellCount = 0,
			currentShellCount = 0,
			peakItemCount = 0,
			currentItemCount = 0,
			invalidLifecycleTransitionCount = 0,
			unknownReasonCount = 0,
			destroyResidualShellCount = 0,
			destroyResidualItemCount = 0,
			staleItemCallbackCount = 0,
			duplicateShellActorIdCount = 0,
			uiReopenNonPrewarmCreateCount = 0,
			queryTriggeredItemCount = 0,
			itemCreatedCount = 0,
			neverDemandDestroyCount = 0,
			liveCensoredCount = 0,
			destroyedEligibleCount = 0,
			eligibleEntityCount = 0,
			itemCreatedByReason = {},
			strongDemandByReason = {},
			ensureComponentPerFrame = {},
			ensureComponentCreatedPerFrame = {},
			ensureComponentAgg = {},
			itemCreatedPerFrame = {},
			prefabRequestPerFrame = {},
			demandToRequestMs = {},
			demandToRequestFrames = {},
			demandToReadyMs = {},
			demandToReadyFrames = {}
		}
	end

	_lazyItemStats = _newLazyItemStats()

	local function _currentFrame()
		return (Time.frameCount or _sessionStartFrame) - _sessionStartFrame
	end

	local function _scalarId(value)
		local valueType = type(value)

		if valueType == "number" or valueType == "string" then
			return value
		end

		if value == nil then
			return nil
		end

		return tostring(value)
	end

	local function _resolveEntity(source)
		if source == nil then
			return nil
		end

		return source.entity or source
	end

	local function _refreshStateIds(state, entity)
		state.actorId = _scalarId(entity.actorId)
		state.topLogoType = _scalarId(entity.topLogoType)
		state.isMainPlayer = entity._isMainPlayer == true
	end

	local function _isApprovedWhitelistEntity(entity, state)
		if state.isMainPlayer or state.playerHubDemand then
			return true
		end

		if entity._isPvp2Scene ~= true then
			return false
		end

		if entity._isPvp2FriendlyOwnedEntity == true then
			return true
		end

		return entity._isPvp2EnemyTargetBase == true and entity.isPvp2RevealActive ~= nil and entity:isPvp2RevealActive() == true
	end

	local function _captureActualResidency(entity, state)
		local item = entity.topLogoItem

		state.hasItem = item ~= nil
		state.hasShell = entity.topLogoShell ~= nil
		state.prefabLoading = item ~= nil and item.objectInfo == nil and item.taskId ~= nil and item.taskId ~= 0 and item._profileSettledLoadVersion ~= item._loadVersion
		state.prefabReady = item ~= nil and item.objectInfo ~= nil

		if state.prefabLoading or state.prefabReady then
			state.prefabRequestItemId = item._profileItemId
			state.prefabRequestVersion = item._loadVersion
		else
			state.prefabRequestItemId = nil
			state.prefabRequestVersion = nil
		end
	end

	local function _initializeSessionFields(state)
		state.sessionGeneration = _sessionGeneration
		state.firstDemandNs = nil
		state.firstDemandFrame = nil
		state.firstDemandReason = nil
		state.firstRequestNs = nil
		state.firstRequestFrame = nil
		state.firstReadyNs = nil
		state.firstReadyFrame = nil
		state.demandToRequestRecorded = false
		state.demandToReadyRecorded = false
	end

	local function _updatePeak(currentField, peakField)
		local current = _lazyItemStats[currentField]

		if current > _lazyItemStats[peakField] then
			_lazyItemStats[peakField] = current
		end
	end

	local function _incrementCurrent(currentField, peakField)
		_lazyItemStats[currentField] = _lazyItemStats[currentField] + 1

		_updatePeak(currentField, peakField)
	end

	local function _decrementCurrent(currentField)
		if _lazyItemStats[currentField] > 0 then
			_lazyItemStats[currentField] = _lazyItemStats[currentField] - 1
		end
	end

	local function _incrementShellActorId(actorId)
		if actorId == nil then
			return
		end

		local activeCount = _activeShellCountByActorId[actorId] or 0

		if activeCount > 0 then
			_lazyItemStats.duplicateShellActorIdCount = _lazyItemStats.duplicateShellActorIdCount + 1
		end

		_activeShellCountByActorId[actorId] = activeCount + 1
	end

	local function _decrementShellActorId(actorId)
		if actorId == nil then
			return
		end

		local activeCount = _activeShellCountByActorId[actorId] or 0

		if activeCount <= 1 then
			_activeShellCountByActorId[actorId] = nil
		else
			_activeShellCountByActorId[actorId] = activeCount - 1
		end
	end

	local function _addResidentItem(state)
		_incrementCurrent("currentItemCount", "peakItemCount")

		if state.isPrewarmWhitelist then
			_incrementCurrent("currentWhitelistItemCount", "peakWhitelistItemCount")
		else
			_incrementCurrent("currentNonWhitelistItemCount", "peakNonWhitelistItemCount")
		end
	end

	local function _removeResidentItem(state)
		_decrementCurrent("currentItemCount")

		if state.isPrewarmWhitelist then
			_decrementCurrent("currentWhitelistItemCount")
		else
			_decrementCurrent("currentNonWhitelistItemCount")
		end
	end

	local function _includeTrackedEntity(entity, state)
		_refreshStateIds(state, entity)

		if _isApprovedWhitelistEntity(entity, state) then
			state.isPrewarmWhitelist = true
		end

		_captureActualResidency(entity, state)
		_initializeSessionFields(state)

		_lazyItemStats.eligibleEntityCount = _lazyItemStats.eligibleEntityCount + 1

		if state.hasItem then
			_addResidentItem(state)
		end

		if state.hasShell then
			_incrementCurrent("currentShellCount", "peakShellCount")
			_incrementShellActorId(state.actorId)
		end

		if state.prefabLoading then
			_incrementCurrent("currentLoadingPrefabCount", "peakLoadingPrefabCount")
		elseif state.prefabReady then
			_incrementCurrent("currentReadyPrefabCount", "peakReadyPrefabCount")
		end
	end

	local function _computeLiveCensoredCount()
		local count = 0

		for _, state in pairs(_trackedTopLogoEntities) do
			if state.sessionGeneration == _sessionGeneration then
				count = count + 1
			end
		end

		_lazyItemStats.liveCensoredCount = count
	end

	function TopLogoProfiler.start(outputPath, autoStopSec)
		_enabled = true
		_records = {}
		_agg = {}
		_pending = {}
		_timelines = {}
		_sessionGeneration = _sessionGeneration + 1
		_lazyItemStats = _newLazyItemStats()
		_activeShellCountByActorId = {}
		_sessionOutput = outputPath or "toplogo_profile.log"
		_sessionStartNs = _getNs()
		_sessionStartFrame = Time.frameCount or 0
		_sampleIdx = 0

		for entity, state in pairs(_trackedTopLogoEntities) do
			_includeTrackedEntity(entity, state)
		end

		if autoStopSec then
			local TimerManager = require("Core.Timer.TimerManager")
			local autoStopGeneration = _sessionGeneration

			TimerManager.addTimer(autoStopSec, function()
				if _enabled and _sessionGeneration == autoStopGeneration then
					TopLogoProfiler.stop()
				end
			end)
		end

		return "TopLogoProfiler session started: " .. _sessionOutput
	end

	function TopLogoProfiler.stop()
		if not _enabled then
			return
		end

		_computeLiveCensoredCount()

		_enabled = false

		TopLogoProfiler.flush()

		_pending = {}
	end

	function TopLogoProfiler.isEnabled()
		return _enabled
	end

	function TopLogoProfiler.tickFrame()
		return
	end

	function TopLogoProfiler.beginSample(name)
		if not _enabled then
			return
		end

		local stack = _pending[name]

		if not stack then
			stack = {}
			_pending[name] = stack
		end

		stack[#stack + 1] = _getNs()
	end

	function TopLogoProfiler.endSample(name, extra)
		if not _enabled then
			return
		end

		local stack = _pending[name]

		if not stack or #stack == 0 then
			return
		end

		local startNs = stack[#stack]

		stack[#stack] = nil

		local durationUs = (_getNs() - startNs) / _nsPerUs

		_sampleIdx = _sampleIdx + 1
		_records[#_records + 1] = {
			name = name,
			durUs = durationUs,
			extra = extra,
			frame = _currentFrame(),
			idx = _sampleIdx
		}

		local a = _agg[name]

		if not a then
			a = {
				totalUs = 0,
				count = 0,
				maxUs = 0,
				minUs = math.huge
			}
			_agg[name] = a
		end

		a.count = a.count + 1
		a.totalUs = a.totalUs + durationUs

		if durationUs < a.minUs then
			a.minUs = durationUs
		end

		if durationUs > a.maxUs then
			a.maxUs = durationUs
		end
	end

	function TopLogoProfiler.markEvent(name, extra)
		if not _enabled then
			return
		end

		_sampleIdx = _sampleIdx + 1
		_records[#_records + 1] = {
			event = true,
			durUs = 0,
			name = name,
			extra = extra,
			frame = _currentFrame(),
			idx = _sampleIdx,
			tsUs = (_getNs() - _sessionStartNs) / _nsPerUs
		}
	end

	local function _getCurrentSessionState(source)
		local entity = _resolveEntity(source)
		local state = entity and _trackedTopLogoEntities[entity]

		if state and state.sessionGeneration == _sessionGeneration then
			_refreshStateIds(state, entity)

			return entity, state
		end

		return entity, nil
	end

	local function _eventExtra(state, reason)
		return {
			actorId = state and state.actorId or nil,
			topLogoType = state and state.topLogoType or nil,
			reason = type(reason) == "string" and reason or nil,
			sessionGeneration = _sessionGeneration
		}
	end

	local function _markInvalidTransition(name, state)
		_lazyItemStats.invalidLifecycleTransitionCount = _lazyItemStats.invalidLifecycleTransitionCount + 1

		TopLogoProfiler.markEvent("invalidLifecycle:" .. name, _eventExtra(state))
	end

	local function _markUnknownReason(state, reason)
		_lazyItemStats.unknownReasonCount = _lazyItemStats.unknownReasonCount + 1

		TopLogoProfiler.markEvent("unknownReason", _eventExtra(state, reason))
	end

	local function _incrementReason(reasonMap, reason)
		reasonMap[reason] = (reasonMap[reason] or 0) + 1
	end

	local function _upgradeWhitelist(state)
		if state.isPrewarmWhitelist then
			return
		end

		state.isPrewarmWhitelist = true

		if _enabled and state.sessionGeneration == _sessionGeneration and state.hasItem then
			_decrementCurrent("currentNonWhitelistItemCount")
			_incrementCurrent("currentWhitelistItemCount", "peakWhitelistItemCount")
		end
	end

	local function _recordPerFrame(frameCounts, peakField)
		local frame = _currentFrame()
		local count = (frameCounts[frame] or 0) + 1

		frameCounts[frame] = count

		if count > _lazyItemStats[peakField] then
			_lazyItemStats[peakField] = count
		end
	end

	function TopLogoProfiler.recordEnsureTopLogoComponent(source, componentName, outcome, reason)
		if not _enabled then
			return
		end

		local entity = _resolveEntity(source)
		local topLogoType = entity and _scalarId(entity.topLogoType) or "nil"
		local normalizedComponentName = _scalarId(componentName) or "nil"
		local normalizedOutcome = _scalarId(outcome) or "unknown"
		local normalizedReason = _scalarId(reason) or "none"
		local stats = _lazyItemStats
		local key = table.concat({
			tostring(topLogoType),
			tostring(normalizedComponentName),
			tostring(normalizedOutcome),
			tostring(normalizedReason)
		}, "|")
		local agg = stats.ensureComponentAgg

		agg[key] = (agg[key] or 0) + 1
		stats.ensureComponentCallCount = stats.ensureComponentCallCount + 1

		local frame = _currentFrame()

		stats.ensureComponentPerFrame[frame] = (stats.ensureComponentPerFrame[frame] or 0) + 1

		if stats.ensureComponentPerFrame[frame] > stats.maxEnsureComponentPerFrame then
			stats.maxEnsureComponentPerFrame = stats.ensureComponentPerFrame[frame]
		end

		if normalizedOutcome == "created" then
			stats.ensureComponentCreatedCount = stats.ensureComponentCreatedCount + 1
			stats.ensureComponentCreatedPerFrame[frame] = (stats.ensureComponentCreatedPerFrame[frame] or 0) + 1

			if stats.ensureComponentCreatedPerFrame[frame] > stats.maxEnsureComponentCreatedPerFrame then
				stats.maxEnsureComponentCreatedPerFrame = stats.ensureComponentCreatedPerFrame[frame]
			end
		end
	end

	local function _formatEnsureComponentAgg(agg)
		local entries = {}

		for key, count in pairs(agg) do
			entries[#entries + 1] = {
				key = key,
				count = count
			}
		end

		table.sort(entries, function(a, b)
			return a.count > b.count
		end)

		local parts = {}

		for _, entry in ipairs(entries) do
			parts[#parts + 1] = entry.key .. "=" .. tostring(entry.count)
		end

		return "{" .. table.concat(parts, ", ") .. "}"
	end

	local function _recordPerFrame(frameCounts, peakField)
		local frame = _currentFrame()
		local count = (frameCounts[frame] or 0) + 1

		frameCounts[frame] = count

		if count > _lazyItemStats[peakField] then
			_lazyItemStats[peakField] = count
		end
	end

	local function _recordDemandToRequest(state, requestNs, requestFrame)
		if state.firstDemandNs == nil or state.demandToRequestRecorded then
			return
		end

		state.demandToRequestRecorded = true

		local ms = (requestNs - state.firstDemandNs) / _nsPerMs
		local frames = requestFrame - state.firstDemandFrame

		_lazyItemStats.demandToRequestMs[#_lazyItemStats.demandToRequestMs + 1] = ms
		_lazyItemStats.demandToRequestFrames[#_lazyItemStats.demandToRequestFrames + 1] = frames
	end

	local function _recordDemandToReady(state, readyNs, readyFrame)
		if state.firstDemandNs == nil or state.demandToReadyRecorded then
			return
		end

		state.demandToReadyRecorded = true

		local ms = (readyNs - state.firstDemandNs) / _nsPerMs
		local frames = readyFrame - state.firstDemandFrame

		_lazyItemStats.demandToReadyMs[#_lazyItemStats.demandToReadyMs + 1] = ms
		_lazyItemStats.demandToReadyFrames[#_lazyItemStats.demandToReadyFrames + 1] = frames
	end

	local function _nearestRankPercentile(samples, percentile)
		local sampleCount = #samples

		if sampleCount == 0 then
			return nil
		end

		local sortedSamples = {}

		for index = 1, sampleCount do
			sortedSamples[index] = samples[index]
		end

		table.sort(sortedSamples)

		local rank = math.max(1, math.ceil(percentile * sampleCount))

		return sortedSamples[rank]
	end

	local function _formatPercentile(samples, percentile, format)
		local value = _nearestRankPercentile(samples, percentile)

		if value == nil then
			return "n/a"
		end

		return string.format(format, value)
	end

	local function _formatReasonMap(reasonMap)
		local sortedReasons = {}

		for reason, _ in pairs(reasonMap) do
			sortedReasons[#sortedReasons + 1] = reason
		end

		table.sort(sortedReasons)

		if #sortedReasons == 0 then
			return "{}"
		end

		local parts = {}

		for _, reason in ipairs(sortedReasons) do
			parts[#parts + 1] = tostring(reason) .. "=" .. tostring(reasonMap[reason])
		end

		return "{" .. table.concat(parts, ", ") .. "}"
	end

	local function _collectDurationSamplesByName()
		local samplesByName = {}

		for _, record in ipairs(_records) do
			if not record.event and record.durUs ~= nil then
				local samples = samplesByName[record.name]

				if samples == nil then
					samples = {}
					samplesByName[record.name] = samples
				end

				samples[#samples + 1] = record.durUs
			end
		end

		return samplesByName
	end

	function TopLogoProfiler.registerTopLogoEntity(source)
		local entity = _resolveEntity(source)

		if entity == nil then
			return
		end

		local state = _trackedTopLogoEntities[entity]

		if state == nil then
			state = {
				playerHubDemand = false,
				everStrongDemand = false,
				prefabReady = false,
				isPrewarmWhitelist = false,
				isMainPlayer = false,
				prefabLoading = false,
				hasShell = false,
				hasItem = false,
				sessionGeneration = 0
			}
			_trackedTopLogoEntities[entity] = state
		end

		_refreshStateIds(state, entity)

		if _isApprovedWhitelistEntity(entity, state) then
			state.isPrewarmWhitelist = true
		end

		if _enabled and state.sessionGeneration ~= _sessionGeneration then
			_includeTrackedEntity(entity, state)
			TopLogoProfiler.markEvent("registerTopLogoEntity", _eventExtra(state))
		end
	end

	function TopLogoProfiler.unregisterTopLogoEntity(source, actualHasItem, actualHasShell)
		local entity = _resolveEntity(source)
		local state = entity and _trackedTopLogoEntities[entity]

		if state == nil then
			if _enabled then
				_markInvalidTransition("unregisterTopLogoEntity", nil)
			end

			return
		end

		if _enabled and state.sessionGeneration == _sessionGeneration then
			_lazyItemStats.destroyedEligibleCount = _lazyItemStats.destroyedEligibleCount + 1

			if not state.everStrongDemand then
				_lazyItemStats.neverDemandDestroyCount = _lazyItemStats.neverDemandDestroyCount + 1
			end

			if actualHasItem == true then
				_lazyItemStats.destroyResidualItemCount = _lazyItemStats.destroyResidualItemCount + 1
			end

			if actualHasShell == true then
				_lazyItemStats.destroyResidualShellCount = _lazyItemStats.destroyResidualShellCount + 1
			end

			if state.hasItem then
				_removeResidentItem(state)
			end

			if state.hasShell then
				_decrementCurrent("currentShellCount")
				_decrementShellActorId(state.actorId)
			end

			if state.prefabLoading then
				_decrementCurrent("currentLoadingPrefabCount")
			end

			if state.prefabReady then
				_decrementCurrent("currentReadyPrefabCount")
			end

			TopLogoProfiler.markEvent("unregisterTopLogoEntity", _eventExtra(state))
		end

		_trackedTopLogoEntities[entity] = nil
	end

	function TopLogoProfiler.markTopLogoPlayerHubDemand(source)
		local entity = _resolveEntity(source)
		local state = entity and _trackedTopLogoEntities[entity]

		if state == nil then
			if _enabled then
				_markInvalidTransition("markTopLogoPlayerHubDemand", nil)
			end

			return
		end

		if state.playerHubDemand then
			return
		end

		state.playerHubDemand = true

		_upgradeWhitelist(state)

		if _enabled and state.sessionGeneration == _sessionGeneration then
			TopLogoProfiler.markEvent("markTopLogoPlayerHubDemand", _eventExtra(state, "player_hub"))
		end
	end

	function TopLogoProfiler.markTopLogoStrongDemand(source, reason)
		local entity = _resolveEntity(source)
		local state = entity and _trackedTopLogoEntities[entity]

		if state == nil then
			if _enabled then
				_markInvalidTransition("markTopLogoStrongDemand", nil)
			end

			return
		end

		state.everStrongDemand = true

		if reason == "player_hub" then
			state.playerHubDemand = true

			_upgradeWhitelist(state)
		end

		if not _enabled or state.sessionGeneration ~= _sessionGeneration then
			return
		end

		if not _strongDemandReasons[reason] then
			_markUnknownReason(state, reason)
		end

		if state.firstDemandNs ~= nil then
			return
		end

		state.firstDemandNs = _getNs()
		state.firstDemandFrame = _currentFrame()
		state.firstDemandReason = _strongDemandReasons[reason] and reason or "unknown"

		if _strongDemandReasons[reason] then
			_incrementReason(_lazyItemStats.strongDemandByReason, reason)
		end

		TopLogoProfiler.markEvent("markTopLogoStrongDemand", _eventExtra(state, state.firstDemandReason))
	end

	function TopLogoProfiler.markTopLogoPrewarmWhitelist(source)
		local entity = _resolveEntity(source)
		local state = entity and _trackedTopLogoEntities[entity]

		if state == nil then
			if _enabled then
				_markInvalidTransition("markTopLogoPrewarmWhitelist", nil)
			end

			return
		end

		_refreshStateIds(state, entity)

		if _isApprovedWhitelistEntity(entity, state) and not state.isPrewarmWhitelist then
			_upgradeWhitelist(state)

			if _enabled and state.sessionGeneration == _sessionGeneration then
				TopLogoProfiler.markEvent("markTopLogoPrewarmWhitelist", _eventExtra(state))
			end
		end
	end

	function TopLogoProfiler.markTopLogoItemCreated(source, reason)
		if not _enabled then
			return
		end

		local _, state = _getCurrentSessionState(source)

		if state == nil or state.hasItem then
			_markInvalidTransition("markTopLogoItemCreated", state)

			return
		end

		state.hasItem = true
		_lazyItemStats.itemCreatedCount = _lazyItemStats.itemCreatedCount + 1

		_addResidentItem(state)
		_recordPerFrame(_lazyItemStats.itemCreatedPerFrame, "maxItemCreatedPerFrame")

		if _itemCreatedReasons[reason] then
			_incrementReason(_lazyItemStats.itemCreatedByReason, reason)
		else
			_markUnknownReason(state, reason)
		end

		if reason == "ui_reopen_eager" and not state.isPrewarmWhitelist then
			_lazyItemStats.uiReopenNonPrewarmCreateCount = _lazyItemStats.uiReopenNonPrewarmCreateCount + 1
		end

		TopLogoProfiler.markEvent("markTopLogoItemCreated", _eventExtra(state, reason))
	end

	function TopLogoProfiler.markTopLogoItemDestroyed(source)
		if not _enabled then
			return
		end

		local _, state = _getCurrentSessionState(source)

		if state == nil or not state.hasItem then
			_markInvalidTransition("markTopLogoItemDestroyed", state)

			return
		end

		state.hasItem = false

		_removeResidentItem(state)
		TopLogoProfiler.markEvent("markTopLogoItemDestroyed", _eventExtra(state))
	end

	function TopLogoProfiler.markTopLogoShellCreated(source)
		if not _enabled then
			return
		end

		local _, state = _getCurrentSessionState(source)

		if state == nil or state.hasShell then
			_markInvalidTransition("markTopLogoShellCreated", state)

			return
		end

		state.hasShell = true

		_incrementCurrent("currentShellCount", "peakShellCount")
		_incrementShellActorId(state.actorId)
		TopLogoProfiler.markEvent("markTopLogoShellCreated", _eventExtra(state))
	end

	function TopLogoProfiler.markTopLogoShellDestroyed(source)
		if not _enabled then
			return
		end

		local _, state = _getCurrentSessionState(source)

		if state == nil or not state.hasShell then
			_markInvalidTransition("markTopLogoShellDestroyed", state)

			return
		end

		state.hasShell = false

		_decrementCurrent("currentShellCount")
		_decrementShellActorId(state.actorId)
		TopLogoProfiler.markEvent("markTopLogoShellDestroyed", _eventExtra(state))
	end

	local function _matchesPrefabRequest(state, itemId, requestVersion)
		return state.prefabRequestItemId == itemId and state.prefabRequestVersion == requestVersion
	end

	local function _clearPrefabRequestIdentity(state)
		state.prefabRequestItemId = nil
		state.prefabRequestVersion = nil
	end

	function TopLogoProfiler.markTopLogoPrefabRequest(source, itemId, requestVersion)
		if not _enabled then
			return
		end

		local _, state = _getCurrentSessionState(source)

		if state == nil or not state.hasItem or state.prefabLoading or state.prefabReady or itemId == nil or requestVersion == nil then
			_markInvalidTransition("markTopLogoPrefabRequest", state)

			return
		end

		state.prefabLoading = true
		state.prefabRequestItemId = itemId
		state.prefabRequestVersion = requestVersion

		_incrementCurrent("currentLoadingPrefabCount", "peakLoadingPrefabCount")
		_recordPerFrame(_lazyItemStats.prefabRequestPerFrame, "maxPrefabRequestPerFrame")

		if state.firstRequestNs == nil then
			state.firstRequestNs = _getNs()
			state.firstRequestFrame = _currentFrame()

			_recordDemandToRequest(state, state.firstRequestNs, state.firstRequestFrame)
		end

		TopLogoProfiler.markEvent("markTopLogoPrefabRequest", _eventExtra(state))
	end

	function TopLogoProfiler.markTopLogoPrefabReady(source, itemId, requestVersion)
		if not _enabled then
			return
		end

		local _, state = _getCurrentSessionState(source)

		if state == nil or not state.prefabLoading or state.prefabReady or not _matchesPrefabRequest(state, itemId, requestVersion) then
			_markInvalidTransition("markTopLogoPrefabReady", state)

			return
		end

		state.prefabLoading = false
		state.prefabReady = true

		_decrementCurrent("currentLoadingPrefabCount")
		_incrementCurrent("currentReadyPrefabCount", "peakReadyPrefabCount")

		if state.firstReadyNs == nil then
			state.firstReadyNs = _getNs()
			state.firstReadyFrame = _currentFrame()

			_recordDemandToReady(state, state.firstReadyNs, state.firstReadyFrame)
		end

		TopLogoProfiler.markEvent("markTopLogoPrefabReady", _eventExtra(state))
	end

	function TopLogoProfiler.markTopLogoPrefabFailed(source, itemId, requestVersion)
		if not _enabled then
			return
		end

		local _, state = _getCurrentSessionState(source)

		if state == nil or not state.prefabLoading or not _matchesPrefabRequest(state, itemId, requestVersion) then
			_markInvalidTransition("markTopLogoPrefabFailed", state)

			return
		end

		state.prefabLoading = false

		_clearPrefabRequestIdentity(state)
		_decrementCurrent("currentLoadingPrefabCount")

		_lazyItemStats.prefabFailedCount = _lazyItemStats.prefabFailedCount + 1

		TopLogoProfiler.markEvent("markTopLogoPrefabFailed", _eventExtra(state))
	end

	function TopLogoProfiler.markTopLogoPrefabCancelled(source, itemId, requestVersion)
		if not _enabled then
			return
		end

		local _, state = _getCurrentSessionState(source)

		if state == nil or not state.prefabLoading or not _matchesPrefabRequest(state, itemId, requestVersion) then
			_markInvalidTransition("markTopLogoPrefabCancelled", state)

			return
		end

		state.prefabLoading = false

		_clearPrefabRequestIdentity(state)
		_decrementCurrent("currentLoadingPrefabCount")

		_lazyItemStats.prefabCancelledCount = _lazyItemStats.prefabCancelledCount + 1

		TopLogoProfiler.markEvent("markTopLogoPrefabCancelled", _eventExtra(state))
	end

	function TopLogoProfiler.markTopLogoPrefabReleased(source, itemId, requestVersion)
		if not _enabled then
			return
		end

		local _, state = _getCurrentSessionState(source)

		if state == nil or not state.prefabReady or not _matchesPrefabRequest(state, itemId, requestVersion) then
			_markInvalidTransition("markTopLogoPrefabReleased", state)

			return
		end

		state.prefabReady = false

		_clearPrefabRequestIdentity(state)
		_decrementCurrent("currentReadyPrefabCount")

		_lazyItemStats.prefabReleasedCount = _lazyItemStats.prefabReleasedCount + 1

		TopLogoProfiler.markEvent("markTopLogoPrefabReleased", _eventExtra(state))
	end

	function TopLogoProfiler.markTopLogoStaleItemCallback(source, itemId, requestVersion)
		if not _enabled then
			return
		end

		local _, state = _getCurrentSessionState(source)

		_lazyItemStats.staleItemCallbackCount = _lazyItemStats.staleItemCallbackCount + 1

		if state and state.prefabLoading and _matchesPrefabRequest(state, itemId, requestVersion) then
			state.prefabLoading = false

			_clearPrefabRequestIdentity(state)
			_decrementCurrent("currentLoadingPrefabCount")
		end

		TopLogoProfiler.markEvent("markTopLogoStaleItemCallback", _eventExtra(state))
	end

	function TopLogoProfiler.markTopLogoQueryTriggeredItem(source)
		if not _enabled then
			return
		end

		local _, state = _getCurrentSessionState(source)

		_lazyItemStats.queryTriggeredItemCount = _lazyItemStats.queryTriggeredItemCount + 1

		TopLogoProfiler.markEvent("markTopLogoQueryTriggeredItem", _eventExtra(state))
	end

	function TopLogoProfiler.timelineStart(key, extra)
		if not _enabled then
			return
		end

		_timelines[key] = {
			startNs = _getNs(),
			extra = extra
		}
	end

	function TopLogoProfiler.timelineEnd(key, endExtra)
		if not _enabled then
			return
		end

		local t = _timelines[key]

		if not t then
			return
		end

		local elapsedUs = (_getNs() - t.startNs) / _nsPerUs

		_timelines[key] = nil
		_sampleIdx = _sampleIdx + 1
		_records[#_records + 1] = {
			name = "timeline:" .. tostring(key),
			durUs = elapsedUs,
			extra = endExtra or t.extra,
			frame = _currentFrame(),
			idx = _sampleIdx
		}

		local aggName = "timeline:" .. tostring(key)
		local a = _agg[aggName]

		if not a then
			a = {
				totalUs = 0,
				count = 0,
				maxUs = 0,
				minUs = math.huge
			}
			_agg[aggName] = a
		end

		a.count = a.count + 1
		a.totalUs = a.totalUs + elapsedUs

		if elapsedUs < a.minUs then
			a.minUs = elapsedUs
		end

		if elapsedUs > a.maxUs then
			a.maxUs = elapsedUs
		end
	end

	function TopLogoProfiler.flush()
		if not _sessionOutput then
			return
		end

		local lines = {}

		lines[#lines + 1] = "===== TopLogo Profile Session ====="
		lines[#lines + 1] = string.format("Total samples: %d, Total frames: %d", _sampleIdx, _currentFrame())
		lines[#lines + 1] = ""
		lines[#lines + 1] = "--- Aggregated (name / count / total us / avg us / min us / max us / P50 us / P95 us / P99 us) ---"

		local durationSamplesByName = _collectDurationSamplesByName()
		local sortedNames = {}

		for name, _ in pairs(_agg) do
			sortedNames[#sortedNames + 1] = name
		end

		table.sort(sortedNames, function(a, b)
			return _agg[a].totalUs > _agg[b].totalUs
		end)

		for _, name in ipairs(sortedNames) do
			local a = _agg[name]
			local avg = a.count > 0 and a.totalUs / a.count or 0
			local durationSamples = durationSamplesByName[name] or {}
			local p50 = _formatPercentile(durationSamples, 0.5, "%.3f")
			local p95 = _formatPercentile(durationSamples, 0.95, "%.3f")
			local p99 = _formatPercentile(durationSamples, 0.99, "%.3f")

			lines[#lines + 1] = string.format("%-45s %6d  total=%10.2f  avg=%8.3f  min=%7.3f  max=%9.3f  P50=%9s  P95=%9s  P99=%9s", name, a.count, a.totalUs, avg, a.minUs, a.maxUs, p50, p95, p99)
		end

		lines[#lines + 1] = ""

		local stats = _lazyItemStats
		local neverDemandRatio = "n/a"

		if stats.destroyedEligibleCount > 0 then
			neverDemandRatio = string.format("%.6f", stats.neverDemandDestroyCount / stats.destroyedEligibleCount)
		end

		local itemCreatedByReason = _formatReasonMap(stats.itemCreatedByReason)
		local strongDemandByReason = _formatReasonMap(stats.strongDemandByReason)
		local demandToRequestP50Ms = _formatPercentile(stats.demandToRequestMs, 0.5, "%.3f")
		local demandToRequestP95Ms = _formatPercentile(stats.demandToRequestMs, 0.95, "%.3f")
		local demandToRequestP99Ms = _formatPercentile(stats.demandToRequestMs, 0.99, "%.3f")
		local demandToRequestP50Frames = _formatPercentile(stats.demandToRequestFrames, 0.5, "%d")
		local demandToRequestP95Frames = _formatPercentile(stats.demandToRequestFrames, 0.95, "%d")
		local demandToRequestP99Frames = _formatPercentile(stats.demandToRequestFrames, 0.99, "%d")
		local demandToReadyP50Ms = _formatPercentile(stats.demandToReadyMs, 0.5, "%.3f")
		local demandToReadyP95Ms = _formatPercentile(stats.demandToReadyMs, 0.95, "%.3f")
		local demandToReadyP99Ms = _formatPercentile(stats.demandToReadyMs, 0.99, "%.3f")
		local demandToReadyP50Frames = _formatPercentile(stats.demandToReadyFrames, 0.5, "%d")
		local demandToReadyP95Frames = _formatPercentile(stats.demandToReadyFrames, 0.95, "%d")
		local demandToReadyP99Frames = _formatPercentile(stats.demandToReadyFrames, 0.99, "%d")

		lines[#lines + 1] = "--- Lazy Item Baseline ---"
		lines[#lines + 1] = string.format("eligibleEntityCount=%d", stats.eligibleEntityCount)
		lines[#lines + 1] = string.format("destroyedEligibleCount=%d", stats.destroyedEligibleCount)
		lines[#lines + 1] = string.format("liveCensoredCount=%d", stats.liveCensoredCount)
		lines[#lines + 1] = string.format("neverDemandDestroyCount=%d", stats.neverDemandDestroyCount)
		lines[#lines + 1] = "neverDemandRatio=" .. neverDemandRatio
		lines[#lines + 1] = string.format("itemCreatedCount=%d", stats.itemCreatedCount)
		lines[#lines + 1] = "itemCreatedByReason=" .. itemCreatedByReason
		lines[#lines + 1] = "strongDemandByReason=" .. strongDemandByReason
		lines[#lines + 1] = string.format("queryTriggeredItemCount=%d", stats.queryTriggeredItemCount)
		lines[#lines + 1] = string.format("uiReopenNonPrewarmCreateCount=%d", stats.uiReopenNonPrewarmCreateCount)
		lines[#lines + 1] = string.format("duplicateShellActorIdCount=%d", stats.duplicateShellActorIdCount)
		lines[#lines + 1] = string.format("staleItemCallbackCount=%d", stats.staleItemCallbackCount)
		lines[#lines + 1] = string.format("destroyResidualItemCount=%d", stats.destroyResidualItemCount)
		lines[#lines + 1] = string.format("destroyResidualShellCount=%d", stats.destroyResidualShellCount)
		lines[#lines + 1] = string.format("unknownReasonCount=%d", stats.unknownReasonCount)
		lines[#lines + 1] = string.format("invalidLifecycleTransitionCount=%d", stats.invalidLifecycleTransitionCount)
		lines[#lines + 1] = string.format("currentItemCount=%d", stats.currentItemCount)
		lines[#lines + 1] = string.format("peakItemCount=%d", stats.peakItemCount)
		lines[#lines + 1] = string.format("currentShellCount=%d", stats.currentShellCount)
		lines[#lines + 1] = string.format("peakShellCount=%d", stats.peakShellCount)
		lines[#lines + 1] = string.format("currentLoadingPrefabCount=%d", stats.currentLoadingPrefabCount)
		lines[#lines + 1] = string.format("peakLoadingPrefabCount=%d", stats.peakLoadingPrefabCount)
		lines[#lines + 1] = string.format("currentReadyPrefabCount=%d", stats.currentReadyPrefabCount)
		lines[#lines + 1] = string.format("peakReadyPrefabCount=%d", stats.peakReadyPrefabCount)
		lines[#lines + 1] = string.format("currentWhitelistItemCount=%d", stats.currentWhitelistItemCount)
		lines[#lines + 1] = string.format("peakWhitelistItemCount=%d", stats.peakWhitelistItemCount)
		lines[#lines + 1] = string.format("currentNonWhitelistItemCount=%d", stats.currentNonWhitelistItemCount)
		lines[#lines + 1] = string.format("peakNonWhitelistItemCount=%d", stats.peakNonWhitelistItemCount)
		lines[#lines + 1] = string.format("prefabFailedCount=%d", stats.prefabFailedCount)
		lines[#lines + 1] = string.format("prefabCancelledCount=%d", stats.prefabCancelledCount)
		lines[#lines + 1] = string.format("prefabReleasedCount=%d", stats.prefabReleasedCount)
		lines[#lines + 1] = string.format("maxItemCreatedPerFrame=%d", stats.maxItemCreatedPerFrame)
		lines[#lines + 1] = string.format("maxPrefabRequestPerFrame=%d", stats.maxPrefabRequestPerFrame)
		lines[#lines + 1] = string.format("ensureComponentCallCount=%d", stats.ensureComponentCallCount)
		lines[#lines + 1] = string.format("ensureComponentCreatedCount=%d", stats.ensureComponentCreatedCount)
		lines[#lines + 1] = string.format("ensureComponentCreatedRatio=%.6f", stats.ensureComponentCallCount > 0 and stats.ensureComponentCreatedCount / stats.ensureComponentCallCount or 0)
		lines[#lines + 1] = string.format("maxEnsureComponentPerFrame=%d", stats.maxEnsureComponentPerFrame)
		lines[#lines + 1] = string.format("maxEnsureComponentCreatedPerFrame=%d", stats.maxEnsureComponentCreatedPerFrame)
		lines[#lines + 1] = "ensureComponentAgg=" .. _formatEnsureComponentAgg(stats.ensureComponentAgg)
		lines[#lines + 1] = "demandToRequestP50Ms=" .. demandToRequestP50Ms
		lines[#lines + 1] = "demandToRequestP95Ms=" .. demandToRequestP95Ms
		lines[#lines + 1] = "demandToRequestP99Ms=" .. demandToRequestP99Ms
		lines[#lines + 1] = "demandToRequestP50Frames=" .. demandToRequestP50Frames
		lines[#lines + 1] = "demandToRequestP95Frames=" .. demandToRequestP95Frames
		lines[#lines + 1] = "demandToRequestP99Frames=" .. demandToRequestP99Frames
		lines[#lines + 1] = "demandToReadyP50Ms=" .. demandToReadyP50Ms
		lines[#lines + 1] = "demandToReadyP95Ms=" .. demandToReadyP95Ms
		lines[#lines + 1] = "demandToReadyP99Ms=" .. demandToReadyP99Ms
		lines[#lines + 1] = "demandToReadyP50Frames=" .. demandToReadyP50Frames
		lines[#lines + 1] = "demandToReadyP95Frames=" .. demandToReadyP95Frames
		lines[#lines + 1] = "demandToReadyP99Frames=" .. demandToReadyP99Frames
		lines[#lines + 1] = ""
		lines[#lines + 1] = "--- Raw records (idx / frame / name / durUs / extra) ---"

		for _, r in ipairs(_records) do
			local extraStr = ""

			if r.extra then
				local parts = {}

				for k, v in pairs(r.extra) do
					parts[#parts + 1] = tostring(k) .. "=" .. tostring(v)
				end

				extraStr = table.concat(parts, ",")
			end

			if r.event then
				lines[#lines + 1] = string.format("[%06d][F%05d] EVENT  %-40s tsUs=%.2f  %s", r.idx, r.frame, r.name, r.tsUs or 0, extraStr)
			else
				lines[#lines + 1] = string.format("[%06d][F%05d]        %-40s durUs=%10.2f  %s", r.idx, r.frame, r.name, r.durUs, extraStr)
			end
		end

		lines[#lines + 1] = ""

		File.writePath(_sessionOutput, table.concat(lines, "\n"))
	end
else
	function TopLogoProfiler.start(outputPath, autoStopSec)
		return "TopLogoProfiler disabled (set TopLogoConst.OPEN_TOPLOGO_PROFILE=true and restart)"
	end

	function TopLogoProfiler.stop()
		return
	end

	function TopLogoProfiler.isEnabled()
		return false
	end

	function TopLogoProfiler.tickFrame()
		return
	end

	function TopLogoProfiler.beginSample()
		return
	end

	function TopLogoProfiler.endSample()
		return
	end

	function TopLogoProfiler.markEvent()
		return
	end

	function TopLogoProfiler.recordEnsureTopLogoComponent()
		return
	end

	function TopLogoProfiler.timelineStart()
		return
	end

	function TopLogoProfiler.timelineEnd()
		return
	end

	function TopLogoProfiler.flush()
		return
	end

	function TopLogoProfiler.registerTopLogoEntity()
		return
	end

	function TopLogoProfiler.unregisterTopLogoEntity()
		return
	end

	function TopLogoProfiler.markTopLogoStrongDemand()
		return
	end

	function TopLogoProfiler.markTopLogoPlayerHubDemand()
		return
	end

	function TopLogoProfiler.markTopLogoPrewarmWhitelist()
		return
	end

	function TopLogoProfiler.markTopLogoItemCreated()
		return
	end

	function TopLogoProfiler.markTopLogoItemDestroyed()
		return
	end

	function TopLogoProfiler.markTopLogoShellCreated()
		return
	end

	function TopLogoProfiler.markTopLogoShellDestroyed()
		return
	end

	function TopLogoProfiler.markTopLogoPrefabRequest()
		return
	end

	function TopLogoProfiler.markTopLogoPrefabReady()
		return
	end

	function TopLogoProfiler.markTopLogoPrefabFailed()
		return
	end

	function TopLogoProfiler.markTopLogoPrefabCancelled()
		return
	end

	function TopLogoProfiler.markTopLogoPrefabReleased()
		return
	end

	function TopLogoProfiler.markTopLogoStaleItemCallback()
		return
	end

	function TopLogoProfiler.markTopLogoQueryTriggeredItem()
		return
	end
end

return TopLogoProfiler
