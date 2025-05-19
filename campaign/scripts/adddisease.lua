--
-- Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
--- Allow dragging and dropping madnesses between players
--	luacheck: globals addDisease onDrop handleDrop
function addDisease(nodeChar, sClass, sRecord, nodeTargetList)
	if not nodeChar or not sClass or not sRecord or not nodeTargetList then
		return false
	end

	if sClass == 'referencedisease' then
		local nodeSource = DB.findNode(sRecord)
		if not nodeSource then
			return
		end

		local rActor = ActorManager.resolveActor(nodeChar)

		local nodeEntry = DB.createChild(nodeTargetList)
		DB.copyNode(nodeSource, nodeEntry)

		if DB.getChild(nodeSource, '....') and DB.getName(nodeSource, '....') ~= 'charsheet' then
			if DB.getValue(nodeSource, 'onset_dice') then
				ActionDiseaseTimeRoll.performRoll(
					nil,
					nodeEntry,
					rActor,
					DB.getValue(nodeSource, 'onset_dice'),
					DB.getValue(nodeSource, 'onset_interval'),
					'Onset'
				)
			end
			if DB.getValue(nodeSource, 'freq_dice') then
				ActionDiseaseTimeRoll.performRoll(
					nil,
					nodeEntry,
					rActor,
					DB.getValue(nodeSource, 'freq_dice'),
					DB.getValue(nodeSource, 'freq_interval'),
					'Frequency'
				)
			end
			if DB.getValue(nodeSource, 'duration_dice') then
				ActionDiseaseTimeRoll.performRoll(
					nil,
					nodeEntry,
					rActor,
					DB.getValue(nodeSource, 'duration_dice'),
					DB.getValue(nodeSource, 'duration_interval'),
					'Duration'
				)
			end
		end
		if DB.getValue(nodeEntry, 'dc_notifier') == 1 then
			ChatManager.SystemMessage(Interface.getString('disease_msg_dcnotifier'))
		end
	else
		return false
	end

	return true
end

function onDrop(_, _, draginfo)
	return handleDrop(draginfo, nil)
end

function handleDrop(draginfo, nodeTargetList)
	if draginfo.isType('shortcut') then
		local sClass, sRecord = draginfo.getShortcutData()
		if StringManager.contains({ 'referencedisease' }, sClass) then
			addDisease(getDatabaseNode(), sClass, sRecord, nodeTargetList)
			return true
		end
	end
end
