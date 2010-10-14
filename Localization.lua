--[[
	Localization submitted through CurseForge
	http://wow.curseforge.com/addons/broker_equipment/localization/
--]]

local _, ns = ...
ns.L = GetLocale() == 'deDE' and {
	'Links-Klick um Set zu wechseln',
	'Rechts-Klocl um den Ausrüstungsmanager zu öffnen',
	'Shift + Links-Klick um Set zu aktualisieren',
	'Strg + Links-Klick um Set zu löschen',
} or GetLocale() == 'frFR' and {
	'Clic gauche pour changer d\'équipement',
	'Clic droit pour ouvrir le gestionnaire d\'équipement',
	'Maj-clic pour mettre à jour le set',
	'Ctrl-clic pour supprimer le set',
} or GetLocale() == 'zhCN' and {
	'左键点击切换套装',
	'右键打开套装管理器',
	'Shift点击覆盖套装',
	'Ctrl点击删除套装',
} or GetLocale() == 'zhTW' and {
	'左鍵點擊切換套裝',
	'右鍵點擊打開套裝管理器',
	'Shift點擊覆蓋套裝',
	'Ctrl點擊刪除套裝',
} or GetLocale() == 'koKR' and {
	'좌-클릭 세트 변경',
	'우-클릭 장비 관리창 열기',
	'Shift-클릭 하면 세트 업데이트',
	'Ctrl-클릭 하면 세트 삭제',
} or GetLocale() == 'esES' and {
	'Click izquierdo para cambiar tu set',
	'Click derecho para abrir el Administrador de Equipo',
	'Shift-click para modificar set',
	'Ctrl-click para eliminar set',
} or GetLocale() == 'esMX' and {
	'Click izquierdo para cambiar tu set',
	'Click derecho para abrir el Administrador de Equipo',
	'Shift-click para modificar set',
	'Ctrl-click para eliminar set',
} or GetLocale() == 'ruRU' and {
	'Левый клик, чтобы изменить комплект',
	'Правый клик, чтобы открыть менеджер экипировки',
	'Shift-клик, чтобы обновить комплект',
	'Ctrl-клик, чтобы удалить комплект',
} or {
	'Left-click to change your set',
	'Right-click to open GearManager',
	'Shift-click to update set',
	'Ctrl-click to delete set',
}
