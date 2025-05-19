--
-- Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
-- luacheck: globals update setReadOnly setVisible onValueChanged getValue isVisible isReadOnly nohide
function onInit()
	if super and super.onInit then
		super.onInit()
	end

	if isReadOnly() then
		self.update(true)
	else
		local node = getDatabaseNode()
		if not node or node.isReadOnly() then
			self.update(true)
		end
	end
end

function update(bReadOnly, bForceHide, sLabelName, sVisibilityTarget)
	local bLocalShow
	if bForceHide then
		bLocalShow = false
	else
		bLocalShow = true
		if bReadOnly and not nohide and getValue() == 0 then
			bLocalShow = false
		end
	end

	if sVisibilityTarget then
		bLocalShow = sVisibilityTarget.isVisible()
	end

	setReadOnly(bReadOnly)
	setVisible(bLocalShow)

	local sLabel = sLabelName
	if window[sLabel] then
		window[sLabel].setVisible(bLocalShow)
	end

	if self.onUpdate then
		self.onUpdate(bLocalShow)
	end

	return bLocalShow
end

function onValueChanged()
	if isVisible() then
		if window.VisDataCleared then
			if getValue() == 0 then
				window.VisDataCleared()
			end
		end
	else
		if window.InvisDataAdded then
			if getValue() ~= 0 then
				window.InvisDataAdded()
			end
		end
	end

	if DB.getName(window.getDatabaseNode(), '..') == 'diseases' then
		local nodeDisease = window.getDatabaseNode()
		local nConsecutiveSaves = DB.getValue(nodeDisease, 'savecount_consec', 0)
		local nSavesReq = DB.getValue(nodeDisease, 'savesreq', 0)
		local nDiseaseRollActive = DB.getValue(nodeDisease, '..diseaserollactive', 1)
		if nDiseaseRollActive ~= 1 and nSavesReq ~= 0 and nConsecutiveSaves >= nSavesReq then
			DB.setValue(nodeDisease, 'starttime', 'number', nil)
			DB.setValue(nodeDisease, 'starttimestring', 'string', nil)
			DB.setValue(nodeDisease, 'savecount', 'number', nil)
			local sDiseaseName = DB.getValue(nodeDisease, 'name', 'disease')
			DB.setValue(nodeDisease, 'name', 'string', '[CURED] ' .. sDiseaseName)
			local sCharName = DB.getValue(nodeDisease, '...name', 'A character')
			ChatManager.SystemMessage(Interface.getString('disease_overcome'):format(sCharName, sDiseaseName))
		end
	end
end
