local Broker_Equipment = CreateFrame('Frame')
Broker_Equipment:RegisterEvent('PLAYER_LOGIN')
Broker_Equipment:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
Broker_Equipment:Hide()

local BACKDROP = {
	bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
	insets = {top = 3, bottom = 3, left = 3, right = 3}
}

local LDB = LibStub('LibDataBroker-1.1'):NewDataObject('Broker_Equipment', {
	type = 'data source',
})

local Menu, pending

local function UpdateDisplay()
	if(InCombatLockdown() and pending) then
		LDB.text = '|cffffff00' .. pending
		LDB.icon = [[Interface\Icons\]] .. GetEquipmentSetInfoByName(pending)
	else
		for index = 1, GetNumEquipmentSets() do
			local name, icon, _, equipped = GetEquipmentSetInfo(index)
			if(equipped) then
				LDB.text = name
				LDB.icon = icon
				return
			end
		end

		LDB.text = UNKNOWN
		LDB.icon = [[Interface\Icons\INV_Misc_QuestionMark]]
	end
end

local function OnItemClick(self)
	if(IsShiftKeyDown() and not pending) then
		local dialog = StaticPopup_Show('CONFIRM_SAVE_EQUIPMENT_SET', self.name)
		dialog.data = self.name
	elseif(IsControlKeyDown() and not pending) then
		local dialog = StaticPopup_Show('CONFIRM_DELETE_EQUIPMENT_SET', self.name)
		dialog.data = self.name
	else
		if(InCombatLockdown()) then
			Broker_Equipment:RegisterEvent('PLAYER_REGEN_ENABLED')
			pending = self.name

			UpdateDisplay()
		else
			EquipmentManager_EquipSet(pending or self.name)
		end
	end

	Menu:Hide()
end

local function OnEnter()
	Menu.Fader:Stop()
end

local function OnLeave()
	Menu.Fader:Play()
end

local function OnItemEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:SetEquipmentSet(self.name)

	OnEnter()
end

local function UpdateMenu(parent)
	local maxWidth = 0

	local numEquipmentSets = GetNumEquipmentSets()
	for index = 1, numEquipmentSets do
		local Item = Menu.items[index]
		if(not Item) then
			Item = CreateFrame('Button', nil, Menu)
			Item:SetPoint('TOPLEFT', 11, -((index - 1) * 18) - UIDROPDOWNMENU_BORDER_HEIGHT)
			Item:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
			Item:GetHighlightTexture():SetBlendMode('ADD')
			Item:SetScript('OnClick', OnItemClick)
			Item:SetScript('OnEnter', OnItemEnter)
			Item:SetScript('OnLeave', GameTooltip_Hide)
			Item:HookScript('OnLeave', OnLeave)

			local Button = CreateFrame('CheckButton', nil, Item)
			Button:SetPoint('LEFT')
			Button:SetSize(16, 16)
			Button:SetNormalTexture([[Interface\Common\UI-DropDownRadioChecks]])
			Button:GetNormalTexture():SetTexCoord(0.5, 1, 0.5, 1)
			Button:SetCheckedTexture([[Interface\Common\UI-DropDownRadioChecks]])
			Button:GetCheckedTexture():SetTexCoord(0, 0.5, 0.5, 1)
			Button:EnableMouse(false)
			Item.Button = Button

			local Label = Item:CreateFontString(nil, nil, 'GameFontHighlightSmall')
			Label:SetPoint('LEFT', 20, 0)
			Item:SetFontString(Label)
			Item.Label = Label

			local Icon = Item:CreateTexture(nil, 'ARTWORK')
			Icon:SetPoint('RIGHT')
			Icon:SetSize(16, 16)
			Item.Icon = Icon

			Menu.items[index] = Item
		else
			Item:Show()
		end

		local name, icon, _, equipped, _, _, _, missing = GetEquipmentSetInfo(index)
		Item.Button:SetChecked(equipped)
		Item.Icon:SetTexture(icon)
		Item.name = name

		if(pending == name) then
			Item:SetFormattedText('|cffffff00%s|r', name)
		elseif(missing > 0) then
			Item:SetFormattedText('|cffff0000%s|r', name)
		else
			Item:SetText(name)
		end

		local width = Item.Label:GetWidth() + 50
		if(width > maxWidth) then
			maxWidth = width
		end
	end

	for index = numEquipmentSets + 1, #Menu.items do
		Menu.items[index]:Hide()
	end

	for _, Item in next, Menu.items do
		Item:SetSize(maxWidth, 18)
	end

	Menu:SetSize(maxWidth + 25, (numEquipmentSets * 18) + (UIDROPDOWNMENU_BORDER_HEIGHT * 2))
end

function LDB:OnTooltipShow()
	self:SetEquipmentSet(LDB.text)
end

local hooked = {}
function LDB:OnClick(button)
	if(GameTooltip:GetOwner() == self) then
		GameTooltip:Hide()
	end

	if(button ~= 'RightButton' and GetNumEquipmentSets() > 0) then
		if(not Menu) then
			Menu = CreateFrame('Frame', nil, UIParent)
			Menu:SetBackdrop(BACKDROP)
			Menu:SetBackdropColor(0, 0, 0)
			Menu:SetScript('OnEnter', OnEnter)
			Menu:SetScript('OnLeave', OnLeave)
			Menu:Hide()
			Menu.items = {}

			local Fader = Menu:CreateAnimationGroup()
			Fader:CreateAnimation():SetDuration(UIDROPDOWNMENU_SHOW_TIME)
			Fader:SetScript('OnFinished', function()
				Menu:Hide()
			end)
			Menu.Fader = Fader
		end

		if(Menu:IsShown()) then
			Menu:Hide()
		else
			UpdateMenu(self)
			Menu:ClearAllPoints()
			Menu:SetPoint('TOP', self, 'BOTTOM') -- temporary anchor

			local sideAnchor = ''
			if(Menu:GetRight() > GetScreenWidth()) then
				sideAnchor = 'RIGHT'
			elseif(Menu:GetLeft() <= 0) then
				sideAnchor = 'LEFT'
			end

			Menu:ClearAllPoints()
			if(Menu:GetBottom() <= 0) then
				Menu:SetPoint('BOTTOM' .. sideAnchor, self, 'TOP' .. sideAnchor)
			else
				Menu:SetPoint('TOP' .. sideAnchor, self, 'BOTTOM' .. sideAnchor)
			end

			Menu:Show()
		end

		PlaySound('igMainMenuOptionCheckBoxOn')

		if(not hooked[self]) then
			self:HookScript('OnEnter', OnEnter)
			self:HookScript('OnLeave', OnLeave)

			hooked[self] = true
		end
	else
		if(not PaperDollFrame:IsVisible()) then
			ToggleCharacter('PaperDollFrame')
		end

		if(not CharacterFrame.Expanded) then
			SetCVar('characterFrameCollapsed', '0')
			CharacterFrame_Expand()
		end

		if(not _G[PAPERDOLL_SIDEBARS[3].frame]:IsShown()) then
			Broker_Equipment:Show()
		end
	end
end

function Broker_Equipment:PLAYER_LOGIN()
	self:RegisterEvent('UNIT_INVENTORY_CHANGED')
	self:RegisterEvent('EQUIPMENT_SETS_CHANGED')
	self.EQUIPMENT_SETS_CHANGED = UpdateDisplay

	UpdateDisplay()
end

function Broker_Equipment:UNIT_INVENTORY_CHANGED(unit)
	if(unit == 'player') then
		UpdateDisplay()
	end
end

function Broker_Equipment:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')

	OnItemClick()
	pending = nil
end

Broker_Equipment:SetScript('OnUpdate', function(self)
	PaperDollFrame_SetSidebar(nil, 3)
	self:Hide()
end)
