-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Chat\\MailContentRequestHelper.lua

local MailContentRequestHelper = {}
local DEFAULT_BATCH_SIZE = 10
local DEFAULT_BATCH_INTERVAL = 1

local function normalizeMailId(mailId)
	if mailId == nil then
		return nil
	end

	local normalizedMailId = tostring(mailId)

	if string.isNilOrEmpty(normalizedMailId) then
		return nil
	end

	return normalizedMailId
end

local function getTimer()
	return pg and pg.global and type(pg.global.timer) == "table" and type(pg.global.timer.delayCall) == "function" and pg.global.timer or nil
end

local function ensureState(owner)
	if type(owner.mailContentPending) ~= "table" then
		owner.mailContentPending = {}
	end

	if type(owner.mailContentQueue) ~= "table" then
		owner.mailContentQueue = {}
	end

	return owner.mailContentPending, owner.mailContentQueue
end

local function scheduleDrain(owner)
	if owner.mailContentDrainScheduled then
		return
	end

	local timer = getTimer()

	if not timer then
		MailContentRequestHelper.drain(owner)

		return
	end

	owner.mailContentDrainScheduled = true

	timer:delayCall(DEFAULT_BATCH_INTERVAL, function()
		MailContentRequestHelper.drain(owner)
	end)
end

function MailContentRequestHelper.request(owner, mailId, options)
	mailId = normalizeMailId(mailId)

	if not owner or string.isNilOrEmpty(mailId) then
		return false
	end

	owner.mailContent = owner.mailContent or {}

	if owner.mailContent[mailId] ~= nil then
		return false
	end

	local pending, queue = ensureState(owner)

	if pending[mailId] then
		if options and options.highPriority then
			for index = 1, #queue do
				if queue[index] == mailId then
					table.remove(queue, index)
					table.insert(queue, 1, mailId)

					break
				end
			end
		end

		return false
	end

	pending[mailId] = true

	if options and options.highPriority then
		table.insert(queue, 1, mailId)
	else
		queue[#queue + 1] = mailId
	end

	scheduleDrain(owner)

	return true
end

function MailContentRequestHelper.complete(owner, mailId)
	mailId = normalizeMailId(mailId)

	if not owner or string.isNilOrEmpty(mailId) then
		return false
	end

	if type(owner.mailContentPending) == "table" then
		owner.mailContentPending[mailId] = nil
	end

	return true
end

function MailContentRequestHelper.remove(owner, mailId)
	return MailContentRequestHelper.complete(owner, mailId)
end

function MailContentRequestHelper.drain(owner)
	if not owner then
		return false
	end

	owner.mailContentDrainScheduled = false

	local pending, queue = ensureState(owner)
	local hasBatchApi = pg.me and type(pg.me.getMailContents) == "function"
	local batch = {}

	while #batch < DEFAULT_BATCH_SIZE and #queue > 0 do
		local mailId = table.remove(queue, 1)

		if not pending[mailId] then
			-- block empty
		elseif owner.mailContent and owner.mailContent[mailId] ~= nil then
			pending[mailId] = nil
		elseif hasBatchApi then
			batch[#batch + 1] = mailId
		elseif pg.me and type(pg.me.getMailContent) == "function" then
			pg.me:getMailContent(mailId)

			batch[#batch + 1] = mailId
		else
			pending[mailId] = nil
		end
	end

	if hasBatchApi and #batch > 0 then
		pg.me:getMailContents(batch)
	end

	if #queue > 0 then
		scheduleDrain(owner)
	end

	return true
end

return MailContentRequestHelper
