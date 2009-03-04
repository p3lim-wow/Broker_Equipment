local locale = GetLocale()
local dummy = CreateFrame('Frame', 'Broker_EquipmentDummy', UIParent, 'UIDropDownMenuTemplate')
local broker = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject('Broker_Equipment', {
	type = 'data source',
	text = 'Equipment',
	icon = 'Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle',
	iconCoords = {0.065, 0.935, 0.065, 0.935}
})

local CHANGESET
if(locale == 'frFR') then
	CHANGESET = 'Click here to change your set' -- todo
elseif(locale == 'deDE') then
	CHANGESET = 'Klicke hier um das set zu wechsein'
elseif(locale == 'koKR') then
	CHANGESET = 'Click here to change your set' -- todo
elseif(locale == 'zhCN') then
	CHANGESET = 'Click here to change your set' -- todo
elseif(locale == 'zhTW') then
	CHANGESET = 'Click here to change your set' -- todo
elseif(locale == 'ruRU') then
	CHANGESET = 'Click here to change your set' -- todo
elseif(locale == 'esES') then
	CHANGESET = 'Click here to change your set' -- todo
elseif(locale == 'esMX') then
	CHANGESET = 'Click here to change your set' -- todo
else
	CHANGESET = 'Click here to change your set'
end

function broker.OnClick(self, button)
	local menu = {}
	for index = 1, GetNumEquipmentSets() do
		local name, texture = GetEquipmentSetInfo(index)
		table.insert(menu, {
			tooltipTitle = name,
			index = index,
			text = name,
			icon = texture,
			func = function()
				EquipmentManager_EquipSet(name)
				broker.text = name
				broker.icon = texture
			end
		})
	end

	table.sort(menu, function(a,b) return a.index < b.index end)
	EasyMenu(menu, dummy, self, 20, 0, 'MENU')

	if(GameTooltip:GetOwner() == self) then GameTooltip:Hide() end
end

function broker.OnTooltipShow(self)
	self:AddLine('|cff0090ffBroker Equipment|r')
	self:AddLine(CHANGESET)
end

dummy:RegisterEvent('PLAYER_LOGIN')
dummy:SetScript('OnEvent', function()
	SetCVar('equipmentManager', 1)
	GearManagerToggleButton:Show()

	-- Todo: Set the name of the set that you are wearing on load
end)