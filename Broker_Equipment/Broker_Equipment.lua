local dummy = CreateFrame('Frame', 'Broker_EquipmentDummy', UIParent, 'UIDropDownMenuTemplate')
local addon = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject('Broker_Equipment', {
	type = 'data source',
	text = 'Equipment',
	icon = 'Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle',
})

function addon.OnClick(self, button)
	local menu = {}
	for i = 1, GetNumEquipmentSets() do
		local name = GetEquipmentSetInfo(i)
		table.insert(menu, {
			tooltipTitle = name,
			text = name,
			func = function()
				EquipmentManager_EquipSet(name)
			end
		})
	end

	table.sort(menu, function(a,b) return a.text > b.text end)
	EasyMenu(menu, dummy, self, 20, 0, 'MENU')

	if(GameTooltip:GetOwner() == self) then GameTooltip:Hide() end
end

function addon.OnTooltipShow(self)
	self:AddLine('Broker Equipment')
	self:AddLine('Click here to change your set')
end

-- force the equipmanager to enable
SetCVar('equipmentManager', 1)
GearManagerToggleButton:Show()