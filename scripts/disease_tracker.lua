--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--
---	This function rounds to the specified number of decimals
--	luacheck: globals round
function round(number, decimals)
	local n = 10 ^ (decimals or 0)
	number = number * n
	if number >= 0 then
		number = math.floor(number + 0.5)
	else
		number = math.ceil(number - 0.5)
	end
	return number / n
end

function onInit()
	LibraryData.setRecordTypeInfo('disease', {
		bExport = true,
		aDataMap = { 'disease', 'reference.diseases' },
		sRecordDisplayClass = 'referencedisease',
		aGMListButtons = { 'button_feat_type' },
		aPlayerListButtons = { 'button_feat_type' },
		aCustomFilters = { ['Type'] = { sField = 'type' } },
	})
end
