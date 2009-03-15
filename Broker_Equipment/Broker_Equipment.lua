local L = {}
if(GetLocale() == 'deDE') then
	L.TOOLTIP = 'Klicke hier um das set zu wechsein'
	L.NOSET = 'Kein set'
elseif(GetLocale() == 'zhCN') then
	L.TOOLTIP = '点击选择套装'
	L.NOSET = '无套装'
elseif(GetLocale() == 'zhTW') then
	L.TOOLTIP = '點擊選擇套裝'
	L.NOSET = '無套裝'
else
	L.TOOLTIP = 'Click here to change your set'
	L.NOSET = 'No set'
end


local menuList = {}
local pendingName = nil
local pendingUpdate = true

local frame = CreateFrame('Frame', 'Broker_EquipmentDropDown', UIParent, 'UIDropDownMenuTemplate')
local broker = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject('Broker_Equipment', {
	type = 'data source',
	text = L.NOSET,
	icon = [=[Interface\PaperDollInfoFrame\UI-EquipmentManager-Toggle]=],
	iconCoords = {0.065, 0.935, 0.065, 0.935}
})


local function equipSet(name, icon)
	EquipmentManager_EquipSet(name)

	if(InCombatLockdown()) then
		pendingName = name
		broker.text = '|cffff0000'..name
	else
		broker.text = name
	end

	broker.icon = icon
	EquipmentDB.text = name
	EquipmentDB.icon = icon
end	

local function createDropDown()
	wipe(menuList)

	for index = 1, GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(index)
		local info = {}
		info.index = index
		info.text = name
		info.icon = icon
		info.func = function() equipSet(name, icon) end

		menuList[index] = info
	end

	table.sort(menuList, function(a,b) return a.index < b.index end)
	UIDropDownMenu_Initialize(frame, initDropDown, 'MENU')
	pendingUpdate = nil
end

local function initDropDown()
	for k,v in next, menuList do
		UIDropDownMenu_AddButton(v, level or 1)
	end
end


function frame:PLAYER_REGEN_ENABLED()
	if(pendingName) then
		broker.text = pendingName
		combatName = nil
	end
end

function frame:EQUIPMENT_SETS_CHANGED()
	pendingUpdate = true
end

function frame:ADDON_LOADED(event, addon)
	if(addon ~= 'Broker_Equipment') then return end

	EquipmentDB = EquipmentDB or {text = L.NOSET, icon = broker.icon}
	broker.text = EquipmentDB.text
	broker.icon = EquipmentDB.icon

	self:UnregisterEvent(event)
end


function broker:OnClick()
	if(GameTooltip:GetOwner() == self) then
		GameTooltip:Hide()
	end

	if(pendingUpdate) then
		createDropDown()
	end

	ToggleDropDownMenu(1, nil, frame, self, 0, 0)
end

function broker:OnTooltipShow()
	self:AddLine('|cff0090ffBroker Equipment|r')
	self:AddLine(L.TOOLTIP)
end


frame:RegisterEvent('ADDON_LOADED')
frame:RegisterEvent('PLAYER_REGEN_ENABLED')
frame:RegisterEvent('EQUIPMENT_SETS_CHANGED')
frame:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)