local dummy = CreateFrame('Frame', 'Broker_EquipmentDummy', UIParent, 'UIDropDownMenuTemplate')
local broker = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject('Broker_Equipment', {
	type = 'data source',
	text = 'Equipment',
	icon = 'Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle',
	iconCoords = {0.065, 0.935, 0.065, 0.935}
})

function broker.OnClick(self, button)
	local menu = {}
	for i = 1, GetNumEquipmentSets() do
		local name, texture = GetEquipmentSetInfo(i)
		table.insert(menu, {
			tooltipTitle = name,
			text = name,
			func = function()
				EquipmentManager_EquipSet(name)
				broker.text = name
				broker.icon = texture
			end
		})
	end

	table.sort(menu, function(a,b) return a.text > b.text end)
	EasyMenu(menu, dummy, self, 20, 0, 'MENU')

	if(GameTooltip:GetOwner() == self) then GameTooltip:Hide() end
end

function broker.OnTooltipShow(self)
	self:AddLine('|cff0090ffBroker Equipment|r')
	self:AddLine('Click here to change your set')
end

dummy:RegisterEvent('PLAYER_LOGIN')
dummy:SetScript('OnEvent', function()
	-- force the equipmanager to enable
	SetCVar('equipmentManager', 1)
	GearManagerToggleButton:Show()

	-- Todo: Set the name of the set that you are wearing on load
end)