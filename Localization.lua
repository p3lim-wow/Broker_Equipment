--[[
	Localization submitted through CurseForge
	http://wow.curseforge.com/addons/broker_equipment/localization/
--]]

local locale = GetLocale()

select(2, ...).L = locale == 'ptBR' and {
	['Ctrl-click'] = 'Ctrl-click to delete set', -- Requires localization
	['Left-click'] = 'Left-click to change your set', -- Requires localization
	['Right-click'] = 'Right-click to open GearManager', -- Requires localization
	['Shift-click'] = 'Shift-click to update set', -- Requires localization
} or locale == 'frFR' and {
	['Ctrl-click'] = 'Ctrl-clic pour supprimer le set',
	['Left-click'] = 'Clic-gauche pour changer de set',
	['Right-click'] = 'Clic-droit pour ouvrir le gestionnaire d\'\195\169quipement',
	['Shift-click'] = 'Shift-clic pour mettre \195\160 jour le set',
} or locale == 'deDE' and {
	["Ctrl-click"] = "Ctrl-Klick um Set zu l\195\182schen", -- Needs review
	["Left-click"] = "Links-Klick um Set zu wechseln", -- Needs review
	["Right-click"] = "Rechtsklick \195\182ffnet den Ausr\195\188stungsmanager",
	["Shift-click"] = "Shift-Klick um Set zu aktualisieren", -- Needs review
} or locale == 'koKR' and {
	['Ctrl-click'] = 'Ctrl-\237\129\180\235\166\173 \236\132\184\237\138\184 \236\130\173\236\160\156',
	['Left-click'] = '\236\153\188\236\170\189-\237\129\180\235\166\173 \236\132\184\237\138\184 \235\179\128\234\178\189',
	['Right-click'] = '\236\152\164\235\165\184\236\170\189-\237\129\180\235\166\173\236\139\156 \236\186\144\235\166\173\237\132\176\236\176\189 \236\151\180\234\184\176',
	['Shift-click'] = 'Shift-\237\129\180\235\166\173 \236\132\184\237\138\184 \236\151\133\235\141\176\236\157\180\237\138\184',
} or locale == 'esMX' and {
	['Ctrl-click'] = 'Ctrl+clic para eliminar este equipamiento',
	['Left-click'] = 'Clic izquierdo para cambiar el equipamiento',
	['Right-click'] = 'Clic derecho para abrir el Gestor de equipamiento',
	['Shift-click'] = 'May\195\186s+clic para modificar este equipamiento',
} or locale == 'ruRU' and {
	['Ctrl-click'] = 'Ctrl-\208\186\208\187\208\184\208\186, \209\135\209\130\208\190\208\177\209\139 \209\131\208\180\208\176\208\187\208\184\209\130\209\140 \208\186\208\190\208\188\208\191\208\187\208\181\208\186\209\130', -- Needs review
	['Left-click'] = '\208\155\208\181\208\178\209\139\208\185 \208\186\208\187\208\184\208\186, \209\135\209\130\208\190\208\177\209\139 \208\184\208\183\208\188\208\181\208\189\208\184\209\130\209\140 \208\186\208\190\208\188\208\191\208\187\208\181\208\186\209\130', -- Needs review
	['Right-click'] = '\208\169\208\181\208\187\208\186\208\189\208\184\209\130\208\181 \208\191\209\128\208\176\208\178\208\190\208\185 \208\186\208\189\208\190\208\191\208\186\208\190\208\185 \208\188\209\139\209\136\208\184, \209\135\209\130\208\190\208\177\209\139 \208\190\209\130\208\186\209\128\209\139\209\130\209\140 \209\131\208\191\209\128\208\176\208\178\208\187\208\181\208\189\208\184\208\181 \209\141\208\186\208\184\208\191\208\184\209\128\208\190\208\178\208\186\208\190\208\185', -- Needs review
	['Shift-click'] = 'Shift-\208\186\208\187\208\184\208\186, \209\135\209\130\208\190\208\177\209\139 \208\190\208\177\208\189\208\190\208\178\208\184\209\130\209\140 \208\186\208\190\208\188\208\191\208\187\208\181\208\186\209\130', -- Needs review
} or locale == 'zhCN' and {
	['Ctrl-click'] = 'Ctrl\231\130\185\229\135\187\229\136\160\233\153\164\229\165\151\232\163\133',
	['Left-click'] = '\229\183\166\233\148\174\231\130\185\229\135\187\229\136\135\230\141\162\229\165\151\232\163\133',
	['Right-click'] = '\229\143\179\233\148\174\231\130\185\229\135\187\230\137\147\229\188\128\232\163\133\229\164\135\231\174\161\231\144\134\229\153\168',
	['Shift-click'] = 'Shift\231\130\185\229\135\187\230\155\180\230\150\176\229\165\151\232\163\133',
} or locale == 'esES' and {
	['Ctrl-click'] = 'Ctrl-click para eliminar el conjunto',
	['Left-click'] = 'Click izquierdo para cambiar tu conjunto',
	['Right-click'] = 'Click derecho para abrir el Gestor de equipamiento',
	['Shift-click'] = 'Shift-click para actualizar el conjunto',
} or locale == 'zhTW' and {
	['Ctrl-click'] = 'Ctrl\233\187\158\230\147\138\229\136\170\233\153\164\229\165\151\232\163\157',
	['Left-click'] = '\229\183\166\233\141\181\230\155\180\230\143\155\232\163\157\229\130\153',
	['Right-click'] = '\229\143\179\233\141\181\233\150\139\229\149\159\232\163\157\229\130\153\231\174\161\231\144\134\229\147\161',
	['Shift-click'] = 'Shift\233\187\158\230\147\138\230\155\180\230\150\176\229\165\151\232\163\157',
} or {
	['Ctrl-click'] = 'Ctrl-click to delete set',
	['Left-click'] = 'Left-click to change your set',
	['Right-click'] = 'Right-click to open GearManager',
	['Shift-click'] = 'Shift-click to update set',
}
