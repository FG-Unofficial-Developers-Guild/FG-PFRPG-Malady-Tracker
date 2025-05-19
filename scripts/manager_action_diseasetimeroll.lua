---
--- Initialization
---
--	luacheck: globals getRoll
function getRoll(_, tDice, nFixedInt, sField)
	local rRoll = {}

	rRoll.sType = 'diseasetimeroll'
	rRoll.aDice = tDice
	rRoll.nMod = nFixedInt
	rRoll.sDesc = sField

	return rRoll
end

-- Start the action process
--	luacheck: globals performRoll
function performRoll(draginfo, nodeDisease, rActor, tDice, nFixedInt, sField)
	local rRoll = getRoll(rActor, tDice, nFixedInt, sField)
	rRoll.nodeDisease = DB.getPath(nodeDisease)

	ActionsManager.performAction(draginfo, rActor, rRoll)
end

--	luacheck: globals onRoll
function onRoll(rSource, _, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll)
	Comm.deliverChatMessage(rMessage)

	local nodeDisease = {}
	if rRoll.nodeDisease then
		nodeDisease = DB.findNode(rRoll.nodeDisease)
	end
	if nodeDisease then
		rRoll.nTotal = ActionsManager.total(rRoll)

		if rRoll.sDesc == 'Onset' then
			DB.setValue(nodeDisease, 'onset_interval', 'number', rRoll.nTotal)
		elseif rRoll.sDesc == 'Frequency' then
			DB.setValue(nodeDisease, 'freq_interval', 'number', rRoll.nTotal)
		elseif rRoll.sDesc == 'Duration' then
			DB.setValue(nodeDisease, 'duration_interval', 'number', rRoll.nTotal)
		end
	end
end

function onInit()
	GameSystem.actions['diseasetimeroll'] = { bUseModStack = false }
	ActionsManager.registerResultHandler('diseasetimeroll', onRoll)
end
