-- EmoteBar 1.8.0 – minimalistische Emote-Leiste für WoW Forever (Interface 16001)
-- Autor: neXter
local ADDON = ...

local AUTHOR = "neXter"

-- Lokalisierung: Sprache folgt der Client-Sprache (deDE = Deutsch, sonst Englisch)
local IS_DE = GetLocale() == "deDE"
local EN = {
  BY = "by",
  TIP_CONFIG = "Right-click: settings",
  TIP_MOVE = "Shift+drag: move bar",
  SLOT = "Slot %d: %s",
  SLOT_SEL = "Slot %d: |cffffffff%s|r",
  SLOT_HINT = "Click to select, then click an emote below",
  COUNT = "Buttons",
  SCALE = "Scale",
  ORIENTATION = "Orientation",
  ROWS = "Rows",
  COLUMNS = "Columns",
  HORIZONTAL = "Horizontal",
  DEFAULT = "Default",
  LOCK = "Lock bar",
  VERTICAL = "Vertical",
  ICON = "Icon",
  ICON_TITLE = "Custom icon",
  ICON_HELP = "Type an icon name (e.g. Spell_Nature_Lightning) and press Enter.\nEmpty + Enter = the emote's default icon.",
  TOTAL = "%d emotes  ·  Click: assign to slot  ·  Shift-click: try it",
  UNKNOWN = "%s is not a known emote – trying anyway.",
  LOCKED = "Bar locked.",
  UNLOCKED = "Bar unlocked – drag the background or Shift+drag a button.",
  RESET = "Reset to defaults.",
  HELP = "%s %s – /eb opens the settings. More commands:",
  SETTINGS_DESC = "Right-click a button on the bar or type /eb to open the settings.",
  OPEN = "Open settings",
}
local DE = {
  BY = "von",
  TIP_CONFIG = "Rechtsklick: Konfiguration",
  TIP_MOVE = "Shift+Ziehen: Leiste verschieben",
  SLOT = "Slot %d: %s",
  SLOT_SEL = "Slot %d: |cffffffff%s|r",
  SLOT_HINT = "Klick: auswählen, dann Emote unten anklicken",
  COUNT = "Anzahl",
  SCALE = "Skalierung",
  ORIENTATION = "Ausrichtung",
  ROWS = "Zeilen",
  COLUMNS = "Spalten",
  HORIZONTAL = "Horizontal",
  DEFAULT = "Standard",
  LOCK = "Leiste sperren",
  VERTICAL = "Vertikal",
  ICON = "Icon",
  ICON_TITLE = "Eigenes Icon",
  ICON_HELP = "Icon-Name eingeben (z.B. Spell_Nature_Lightning), Enter.\nLeer + Enter = Standard-Icon des Emotes.",
  TOTAL = "%d Emotes  ·  Klick: auf Slot legen  ·  Shift-Klick: ausprobieren",
  UNKNOWN = "%s ist kein bekanntes Emote – wird trotzdem versucht.",
  LOCKED = "Leiste gesperrt.",
  UNLOCKED = "Leiste entsperrt – Hintergrund oder Shift+Button ziehen.",
  RESET = "Zurückgesetzt.",
  HELP = "%s %s – /eb öffnet die Konfiguration. Weitere Befehle:",
  SETTINGS_DESC = "Rechtsklick auf einen Button der Leiste oder /eb öffnet die Konfiguration.",
  OPEN = "Konfiguration öffnen",
}
local L = IS_DE and setmetatable(DE, { __index = EN }) or EN
local MAX_SLOTS = 20
local PAD, GAP = 3, 2
local ICON_PATH = "Interface\\Icons\\"
local CUSTOM = "Interface\\AddOns\\" .. ADDON .. "\\Icons\\" -- eigene Icons im Addon-Ordner

-- Icon-Name -> Texturpfad; Namen mit Pfad (eigene Icons) bleiben unverändert
local function IconPath(name)
  if name:find("\\") then return name end
  return ICON_PATH .. name
end

-- Setzt Textur; Blizzard-Icons werden leicht beschnitten (Rand), eigene Icons nicht
local function SetIcon(tex, path)
  tex:SetTexture(path)
  if path:find("AddOns", 1, true) then
    tex:SetTexCoord(0, 1, 0, 1)
  else
    tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  end
end
local DEFAULT_ICON = "INV_Misc_Note_01"

-- Empfohlene Emotes mit eigenem Icon (erscheinen im Katalog zuerst): { Token, Deutsch, English, Icon }
local CURATED = {
  { "HELLO", "Hallo", "Hello", CUSTOM .. "hello" },
  { "WAVE", "Winken", "Wave", CUSTOM .. "wave" },
  { "GREET", "Grüßen", "Greet", CUSTOM .. "greet" },
  { "WELCOME", "Willkommen", "Welcome", CUSTOM .. "welcome" },
  { "BYE", "Tschüss", "Bye", CUSTOM .. "bye" },
  { "BOW", "Verbeugen", "Bow", CUSTOM .. "bow" },
  { "SALUTE", "Salutieren", "Salute", CUSTOM .. "salute" },
  { "THANK", "Danke", "Thank you", CUSTOM .. "thank" },
  { "CHEER", "Jubeln", "Cheer", CUSTOM .. "cheer" },
  { "APPLAUD", "Applaudieren", "Applaud", CUSTOM .. "applaud" },
  { "CONGRATULATE", "Gratulieren", "Congratulate", CUSTOM .. "congratulate" },
  { "HUG", "Umarmen", "Hug", CUSTOM .. "hug" },
  { "SMILE", "Lächeln", "Smile", CUSTOM .. "smile" },
  { "WINK", "Zwinkern", "Wink", CUSTOM .. "wink" },
  { "KISS", "Kuss", "Kiss", CUSTOM .. "kiss" },
  { "NOD", "Ja (nicken)", "Yes (nod)", CUSTOM .. "yes" },
  { "NO", "Nein", "No", CUSTOM .. "no" },
  { "LAUGH", "Lachen", "Laugh", CUSTOM .. "laugh" },
  { "ROFL", "Am Boden lachen", "ROFL", CUSTOM .. "rofl" },
  { "DANCE", "Tanzen", "Dance", CUSTOM .. "dance" },
  { "CHICKEN", "Huhn", "Chicken", CUSTOM .. "chicken" },
  { "TRAIN", "Zug", "Train", CUSTOM .. "train" },
  { "FLEX", "Muskeln zeigen", "Flex", CUSTOM .. "flex" },
  { "ROAR", "Brüllen", "Roar", CUSTOM .. "roar" },
  { "SILLY", "Albern", "Silly", CUSTOM .. "silly" },
  { "MOON", "Mond zeigen", "Moon", CUSTOM .. "moon" },
  { "CRY", "Weinen", "Cry", CUSTOM .. "cry" },
  { "SIGH", "Seufzen", "Sigh", CUSTOM .. "sigh" },
  { "SHRUG", "Schulterzucken", "Shrug", CUSTOM .. "shrug" },
  { "CONFUSED", "Verwirrt", "Confused", CUSTOM .. "confused" },
  { "SURPRISED", "Überrascht", "Surprised", CUSTOM .. "surprised" },
  { "FACEPALM", "Facepalm", "Facepalm", CUSTOM .. "facepalm" },
  { "BORED", "Gelangweilt", "Bored", CUSTOM .. "bored" },
  { "SLEEP", "Schlafen", "Sleep", CUSTOM .. "sleep" },
  { "ANGRY", "Wütend", "Angry", CUSTOM .. "angry" },
  { "SHY", "Schüchtern", "Shy", CUSTOM .. "shy" },
  { "READY", "Bereit", "Ready", CUSTOM .. "ready" },
  { "CHARGE", "Angriff!", "Charge!", CUSTOM .. "charge" },
  { "INCOMING", "Feinde kommen", "Incoming", CUSTOM .. "incoming" },
  { "OPENFIRE", "Feuer frei", "Open fire", CUSTOM .. "openfire" },
  { "FOLLOW", "Folgen", "Follow", CUSTOM .. "follow" },
  { "WAIT", "Warten", "Wait", CUSTOM .. "wait" },
  { "HELPME", "Hilfe!", "Help me!", CUSTOM .. "helpme" },
  { "HEALME", "Heilung!", "Heal me!", CUSTOM .. "healme" },
  { "OOM", "Kein Mana", "Out of mana", CUSTOM .. "oom" },
  { "SIT", "Sitzen", "Sit", CUSTOM .. "sit" },
  { "KNEEL", "Knien", "Kneel", CUSTOM .. "kneel" },
  { "PRAY", "Beten", "Pray", CUSTOM .. "pray" },
  { "POINT", "Zeigen", "Point", CUSTOM .. "point" },
  { "BEG", "Betteln", "Beg", CUSTOM .. "beg" },
  { "TALK", "Reden", "Talk", CUSTOM .. "talk" },
}

local DEFAULT_SLOTS = { "HELLO", "BYE", "THANK", "BOW", "CHEER", "APPLAUD", "LAUGH", "DANCE", "CHICKEN", "TRAIN" }
local DEFAULTS = { count = 10, lines = 1, scale = 1, size = 30, locked = false, vertical = false, hidden = false,
                   pos = { "CENTER", "CENTER", 0, -220 } }

local ALL, BY_TOKEN = {}, {}   -- Katalog: wird beim Laden aus den Client-Globals ergänzt
local db
local buttons = {}

local function Print(msg) print("|cff66ccffEmoteBar|r: " .. msg) end

local function Copy(v)
  if type(v) ~= "table" then return v end
  local t = {}
  for k, x in pairs(v) do t[k] = Copy(x) end
  return t
end

local function AddEntry(token, label, icon, cmd, fav)
  if BY_TOKEN[token] then return end
  local e = { token = token, label = label, icon = icon or DEFAULT_ICON, cmd = cmd, fav = fav }
  e.search = (token .. " " .. label .. " " .. (cmd or "")):lower()
  BY_TOKEN[token] = e
  ALL[#ALL + 1] = e
end

-- Alle Emotes des Clients einlesen (EMOTE<n>_TOKEN / EMOTE<n>_CMD1 aus den GlobalStrings)
local function BuildCatalog()
  local cmds = {}
  for i = 1, 1500 do
    local token = _G["EMOTE" .. i .. "_TOKEN"]
    if type(token) == "string" and not cmds[token] then
      cmds[token] = _G["EMOTE" .. i .. "_CMD1"] or ("/" .. token:lower())
    end
  end
  for _, c in ipairs(CURATED) do AddEntry(c[1], IS_DE and c[2] or c[3], c[4], cmds[c[1]], true) end
  local rest = {}
  for token, cmd in pairs(cmds) do
    if not BY_TOKEN[token] then rest[#rest + 1] = { token = token, cmd = cmd } end
  end
  table.sort(rest, function(a, b) return a.cmd < b.cmd end)
  for _, r in ipairs(rest) do
    local name = r.cmd:gsub("^/", "")
    AddEntry(r.token, name:sub(1, 1):upper() .. name:sub(2), nil, r.cmd, false)
  end
end

local function Info(token)
  return BY_TOKEN[token] or { token = token, label = (token or "?"):lower(), icon = DEFAULT_ICON }
end

local function SlotIcon(i)
  return IconPath(db.icons[i] or Info(db.slots[i]).icon)
end

-- Leiste ------------------------------------------------------------------
local bar = CreateFrame("Frame", "EmoteBarFrame", UIParent)
bar:SetFrameStrata("MEDIUM")
bar:SetClampedToScreen(true)
bar:SetMovable(true)
bar:EnableMouse(true)
bar:RegisterForDrag("LeftButton")
if bar.SetDontSavePosition then bar:SetDontSavePosition(true) end

local barBg = bar:CreateTexture(nil, "BACKGROUND")
barBg:SetAllPoints()
barBg:SetColorTexture(0, 0, 0, 0.35)

local function StartMove()
  if db.locked then return end
  bar.isMoving = true
  bar:StartMoving()
end

local function StopMove()
  if not bar.isMoving then return end
  bar.isMoving = false
  bar:StopMovingOrSizing()
  local point, _, relPoint, x, y = bar:GetPoint(1)
  db.pos = { point, relPoint, x, y }
end

bar:SetScript("OnDragStart", StartMove)
bar:SetScript("OnDragStop", StopMove)

local function ApplyPosition()
  local p = db.pos
  bar:ClearAllPoints()
  bar:SetPoint(p[1], UIParent, p[2], p[3], p[4])
end

local Layout, OpenConfig, RefreshConfig

local function OnClick(self, mouse)
  if mouse == "RightButton" then OpenConfig(self.index) return end
  if IsShiftKeyDown() then return end
  local token = db.slots[self.index]
  if token then DoEmote(token) end -- ohne Ziel-Argument: aktuelles Ziel, sonst ungezielt
end

local function OnEnter(self)
  local token = db.slots[self.index]
  GameTooltip:SetOwner(self, "ANCHOR_TOP")
  GameTooltip:SetText(Info(token).label)
  GameTooltip:AddLine(Info(token).cmd or token, 0.6, 0.6, 0.6)
  GameTooltip:AddLine(L.TIP_CONFIG, 0.5, 0.8, 1)
  if not db.locked then GameTooltip:AddLine(L.TIP_MOVE, 0.5, 0.8, 1) end
  GameTooltip:Show()
end

local function CreateBarButton(i)
  local b = CreateFrame("Button", nil, bar)
  b.index = i
  b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  b:RegisterForDrag("LeftButton")

  local slotBg = b:CreateTexture(nil, "BACKGROUND")
  slotBg:SetAllPoints()
  slotBg:SetColorTexture(0, 0, 0, 0.6)

  b.icon = b:CreateTexture(nil, "ARTWORK")
  b.icon:SetAllPoints()
  b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

  b:SetScript("OnClick", OnClick)
  b:SetScript("OnEnter", OnEnter)
  b:SetScript("OnLeave", function() GameTooltip:Hide() end)
  b:SetScript("OnMouseDown", function(self) self.icon:SetVertexColor(0.6, 0.6, 0.6) end)
  b:SetScript("OnMouseUp", function(self) self.icon:SetVertexColor(1, 1, 1) end)
  b:SetScript("OnDragStart", function() if IsShiftKeyDown() then StartMove() end end)
  b:SetScript("OnDragStop", StopMove)

  buttons[i] = b
  return b
end

-- Raster: "lines" = Zeilen (horizontal) bzw. Spalten (vertikal)
local function Grid()
  local n = db.count
  local lines = math.max(1, math.min(db.lines or 1, n))
  local per = math.ceil(n / lines)          -- Buttons pro Zeile/Spalte
  local used = math.ceil(n / per)           -- tatsächlich belegte Zeilen/Spalten
  if db.vertical then return per, used, per else return used, per, per end -- rows, cols, per
end

-- Nächste Zeilenzahl, die das Raster tatsächlich verändert (z.B. 10 Buttons: 1, 2, 3, 4, 5, 10)
local function StepLines(dir)
  local n = db.count
  local function used(l) local per = math.ceil(n / l); return math.ceil(n / per) end
  local cur = used(math.max(1, math.min(db.lines or 1, n)))
  local l = cur + dir
  while l >= 1 and l <= n do
    if used(l) ~= cur then db.lines = used(l) return end
    l = l + dir
  end
end

Layout = function()
  local n, size = db.count, db.size
  local rows, cols, per = Grid()
  local step = size + GAP
  for i = 1, math.max(n, #buttons) do
    local b = buttons[i]
    if i <= n then
      b = b or CreateBarButton(i)
      if not db.slots[i] then db.slots[i] = DEFAULT_SLOTS[i] or "WAVE" end
      local line, pos = math.floor((i - 1) / per), (i - 1) % per
      local col, row = pos, line
      if db.vertical then col, row = line, pos end
      b:SetSize(size, size)
      b:ClearAllPoints()
      b:SetPoint("TOPLEFT", bar, "TOPLEFT", PAD + col * step, -(PAD + row * step))
      SetIcon(b.icon, SlotIcon(i))
      b:Show()
    elseif b then
      b:Hide()
    end
  end
  bar:SetSize(PAD * 2 + cols * step - GAP, PAD * 2 + rows * step - GAP)
  bar:SetScale(db.scale)
end

local function Changed()
  Layout()
  if RefreshConfig then RefreshConfig() end
end

-- Konfigurationsfenster ---------------------------------------------------
local cfg
local selected = 1
local ROWS, ROW_H = 14, 22
local filtered, offset = {}, 0

local function Text(parent, text, font)
  local fs = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
  fs:SetText(text or "")
  return fs
end

local function SmallButton(parent, text, w, onClick)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(w, 20)
  b:SetText(text)
  b:SetScript("OnClick", onClick)
  return b
end

local function Check(parent, label, onClick)
  local c = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  c:SetSize(22, 22)
  c:SetScript("OnClick", function(self) onClick(self:GetChecked() and true or false) end)
  local t = Text(parent, label)
  t:SetPoint("LEFT", c, "RIGHT", 2, 0)
  return c
end

local function RefreshRows()
  if not cfg then return end
  local current = db.slots[selected]
  for r = 1, ROWS do
    local row, e = cfg.rows[r], filtered[offset + r]
    if e then
      row.e = e
      SetIcon(row.icon, IconPath(e.icon))
      row.name:SetText(e.label)
      row.name:SetTextColor(e.fav and 1 or 0.8, e.fav and 0.82 or 0.8, e.fav and 0 or 0.8)
      row.cmd:SetText(e.cmd or e.token)
      row.sel:SetShown(e.token == current)
      row:Show()
    else
      row:Hide()
    end
  end
end

local function RefreshList()
  wipe(filtered)
  local q = (cfg.search:GetText() or ""):lower()
  for _, e in ipairs(ALL) do
    if q == "" or e.search:find(q, 1, true) then filtered[#filtered + 1] = e end
  end
  local maxOff = math.max(0, #filtered - ROWS)
  offset = math.min(offset, maxOff)
  cfg.scroll:SetMinMaxValues(0, maxOff)
  cfg.scroll:SetValue(offset)
  cfg.scroll:SetShown(maxOff > 0)
  cfg.total:SetText(L.TOTAL:format(#filtered))
  RefreshRows()
end

RefreshConfig = function()
  if not (cfg and cfg:IsShown()) then return end
  selected = math.min(selected, db.count)
  for i, b in ipairs(cfg.slots) do
    if i <= db.count then
      SetIcon(b.icon, SlotIcon(i))
      b.sel:SetShown(i == selected)
      b:Show()
    else
      b:Hide()
    end
  end
  cfg.countText:SetText(db.count)
  local pct = math.floor(db.scale * 100 + 0.5)
  cfg.updating = true
  cfg.scaleSlider:SetValue(pct)
  cfg.updating = false
  cfg.scaleText:SetText(pct .. "%")
  cfg.lock:SetChecked(db.locked)
  local rows, cols = Grid()
  db.lines = math.max(1, math.min(db.lines or 1, db.count))
  cfg.linesLabel:SetText(db.vertical and L.COLUMNS or L.ROWS)
  cfg.linesText:SetText(db.vertical and cols or rows)
  cfg.gridText:SetText(("%d × %d"):format(rows, cols))
  if db.vertical then
    cfg.vertB:LockHighlight(); cfg.horiz:UnlockHighlight()
  else
    cfg.horiz:LockHighlight(); cfg.vertB:UnlockHighlight()
  end
  local token = db.slots[selected]
  cfg.selText:SetText(L.SLOT_SEL:format(selected, Info(token).label))
  if not cfg.iconBox:HasFocus() then cfg.iconBox:SetText(db.icons[selected] or "") end
  RefreshRows()
end

local function CreateConfig()
  cfg = CreateFrame("Frame", "EmoteBarConfig", UIParent, "BackdropTemplate")
  cfg:SetSize(384, 622)
  cfg:SetPoint("CENTER")
  cfg:SetFrameStrata("DIALOG")
  cfg:SetClampedToScreen(true)
  cfg:SetMovable(true)
  cfg:EnableMouse(true)
  cfg:RegisterForDrag("LeftButton")
  cfg:SetScript("OnDragStart", cfg.StartMoving)
  cfg:SetScript("OnDragStop", cfg.StopMovingOrSizing)
  cfg:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 14, insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  cfg:SetBackdropColor(0.05, 0.05, 0.07, 0.95)
  tinsert(UISpecialFrames, "EmoteBarConfig") -- ESC schliesst

  local title = Text(cfg, "EmoteBar  |cff999999" .. L.BY .. " " .. AUTHOR .. "|r", "GameFontNormal")
  title:SetPoint("TOPLEFT", 16, -12)
  local close = CreateFrame("Button", nil, cfg, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -2, -2)

  -- Slots der Leiste (2 Reihen à 10)
  cfg.slots = {}
  for i = 1, MAX_SLOTS do
    local b = CreateFrame("Button", nil, cfg)
    b:SetSize(30, 30)
    b:SetPoint("TOPLEFT", 16 + ((i - 1) % 10) * 35, -36 - math.floor((i - 1) / 10) * 35)
    b.sel = b:CreateTexture(nil, "BACKGROUND")
    b.sel:SetPoint("TOPLEFT", -2, 2)
    b.sel:SetPoint("BOTTOMRIGHT", 2, -2)
    b.sel:SetColorTexture(1, 0.82, 0, 1)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetAllPoints()
    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    b:SetScript("OnClick", function() selected = i; RefreshConfig() end)
    b:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_TOP")
      GameTooltip:SetText(L.SLOT:format(i, Info(db.slots[i]).label))
      GameTooltip:AddLine(L.SLOT_HINT, 0.5, 0.8, 1)
      GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    cfg.slots[i] = b
  end

  -- Optionen ------------------------------------------------------------
  local COL = 100
  local y = -112

  -- Skalierung: Regler 50–150 %
  local ls = Text(cfg, L.SCALE); ls:SetPoint("TOPLEFT", 16, y - 4)
  local sl = CreateFrame("Slider", nil, cfg)
  sl:SetOrientation("HORIZONTAL")
  sl:SetSize(200, 16)
  sl:SetPoint("TOPLEFT", COL, y - 2)
  sl:SetHitRectInsets(0, 0, -4, -4)
  local tr = sl:CreateTexture(nil, "BACKGROUND")
  tr:SetHeight(4)
  tr:SetPoint("LEFT"); tr:SetPoint("RIGHT")
  tr:SetColorTexture(1, 1, 1, 0.15)
  local th = sl:CreateTexture(nil, "OVERLAY")
  th:SetSize(10, 16)
  th:SetColorTexture(1, 0.82, 0, 0.9)
  sl:SetThumbTexture(th)
  sl:SetMinMaxValues(50, 150)
  sl:SetValueStep(5)
  sl:SetObeyStepOnDrag(true)
  cfg.scaleText = Text(cfg, "", "GameFontHighlight")
  cfg.scaleText:SetPoint("LEFT", sl, "RIGHT", 10, 0)
  local function SetScalePct(v)
    v = math.max(50, math.min(150, math.floor(v / 5 + 0.5) * 5))
    cfg.scaleText:SetText(v .. "%")
    if not cfg.updating and math.abs(db.scale * 100 - v) > 0.1 then
      db.scale = v / 100
      Layout()
    end
  end
  sl:SetScript("OnValueChanged", function(_, v) SetScalePct(v) end)
  sl:EnableMouseWheel(true)
  sl:SetScript("OnMouseWheel", function(self, delta) self:SetValue(self:GetValue() + delta * 5) end)
  sl:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(L.SCALE .. ": 50–150%")
    GameTooltip:Show()
  end)
  sl:SetScript("OnLeave", function() GameTooltip:Hide() end)
  cfg.scaleSlider = sl

  -- Ausrichtung: Horizontal / Vertikal
  y = y - 28
  local lo = Text(cfg, L.ORIENTATION); lo:SetPoint("TOPLEFT", 16, y - 4)
  cfg.horiz = SmallButton(cfg, L.HORIZONTAL, 98, function() db.vertical = false; Changed() end)
  cfg.horiz:SetPoint("TOPLEFT", COL, y)
  cfg.vertB = SmallButton(cfg, L.VERTICAL, 98, function() db.vertical = true; Changed() end)
  cfg.vertB:SetPoint("LEFT", cfg.horiz, "RIGHT", 6, 0)

  -- Zeilen bzw. Spalten
  y = y - 28
  cfg.linesLabel = Text(cfg, L.ROWS); cfg.linesLabel:SetPoint("TOPLEFT", 16, y - 4)
  local lMinus = SmallButton(cfg, "-", 22, function() StepLines(-1); Changed() end)
  lMinus:SetPoint("TOPLEFT", COL, y)
  cfg.linesText = Text(cfg, "", "GameFontHighlight"); cfg.linesText:SetPoint("LEFT", lMinus, "RIGHT", 6, 0)
  local lPlus = SmallButton(cfg, "+", 22, function() StepLines(1); Changed() end)
  lPlus:SetPoint("TOPLEFT", COL + 46, y)
  cfg.gridText = Text(cfg, "", "GameFontDisableSmall"); cfg.gridText:SetPoint("LEFT", lPlus, "RIGHT", 10, 0)

  -- Anzahl, Sperre, Standard
  y = y - 28
  local l1 = Text(cfg, L.COUNT); l1:SetPoint("TOPLEFT", 16, y - 4)
  local minus = SmallButton(cfg, "-", 22, function() db.count = math.max(1, db.count - 1); Changed() end)
  minus:SetPoint("TOPLEFT", COL, y)
  cfg.countText = Text(cfg, "", "GameFontHighlight"); cfg.countText:SetPoint("LEFT", minus, "RIGHT", 6, 0)
  local plus = SmallButton(cfg, "+", 22, function() db.count = math.min(MAX_SLOTS, db.count + 1); Changed() end)
  plus:SetPoint("TOPLEFT", COL + 46, y)
  cfg.lock = Check(cfg, L.LOCK, function(v) db.locked = v end)
  cfg.lock:SetPoint("TOPLEFT", COL + 80, y + 1)
  local reset = SmallButton(cfg, L.DEFAULT, 70, function()
    db.slots, db.icons, db.count = Copy(DEFAULT_SLOTS), {}, 10
    Changed()
  end)
  reset:SetPoint("TOPRIGHT", -14, y)

  -- Ausgewählter Slot + eigenes Icon
  y = y - 30
  cfg.selText = Text(cfg, "", "GameFontNormal")
  cfg.selText:SetPoint("TOPLEFT", 16, y - 3)
  cfg.iconBox = CreateFrame("EditBox", nil, cfg, "InputBoxTemplate")
  cfg.iconBox:SetSize(130, 20)
  cfg.iconBox:SetPoint("TOPRIGHT", -16, y)
  cfg.iconBox:SetAutoFocus(false)
  cfg.iconBox:SetScript("OnEnterPressed", function(self)
    local t = (self:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
    t = t:gsub("^[Ii]nterface\\[Ii]cons\\", "")
    db.icons[selected] = (t ~= "") and t or nil
    self:ClearFocus()
    Changed()
  end)
  cfg.iconBox:SetScript("OnEscapePressed", function(self) self:ClearFocus(); RefreshConfig() end)
  local iconLabel = Text(cfg, L.ICON)
  iconLabel:SetPoint("RIGHT", cfg.iconBox, "LEFT", -8, 0)
  cfg.iconBox:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(L.ICON_TITLE)
    GameTooltip:AddLine(L.ICON_HELP, 1, 1, 1, true)
    GameTooltip:Show()
  end)
  cfg.iconBox:SetScript("OnLeave", function() GameTooltip:Hide() end)

  -- Suche
  y = y - 30
  cfg.search = CreateFrame("EditBox", nil, cfg, "SearchBoxTemplate")
  cfg.search:SetSize(352, 20)
  cfg.search:SetPoint("TOPLEFT", 20, y)
  cfg.search:SetAutoFocus(false)
  cfg.search:HookScript("OnTextChanged", function() offset = 0; RefreshList() end)

  -- Katalog-Liste (virtuell: 14 Zeilen + Scrollbalken)
  y = y - 28
  cfg.rows = {}
  for r = 1, ROWS do
    local row = CreateFrame("Button", nil, cfg)
    row:SetSize(338, ROW_H)
    row:SetPoint("TOPLEFT", 16, y - (r - 1) * ROW_H)
    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.08)
    row.sel = row:CreateTexture(nil, "BACKGROUND")
    row.sel:SetAllPoints()
    row.sel:SetColorTexture(1, 0.82, 0, 0.18)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(18, 18)
    row.icon:SetPoint("LEFT", 2, 0)
    row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    row.name = Text(row, "", "GameFontHighlight")
    row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
    row.cmd = Text(row, "", "GameFontDisableSmall")
    row.cmd:SetPoint("RIGHT", -6, 0)
    row:SetScript("OnClick", function(self)
      local e = self.e
      if not e then return end
      if IsShiftKeyDown() then DoEmote(e.token) return end
      db.slots[selected], db.icons[selected] = e.token, nil
      Changed()
    end)
    cfg.rows[r] = row
  end

  local listH = ROWS * ROW_H
  cfg.scroll = CreateFrame("Slider", nil, cfg)
  cfg.scroll:SetOrientation("VERTICAL")
  cfg.scroll:SetSize(8, listH)
  cfg.scroll:SetPoint("TOPRIGHT", -14, y)
  local track = cfg.scroll:CreateTexture(nil, "BACKGROUND")
  track:SetAllPoints()
  track:SetColorTexture(1, 1, 1, 0.06)
  local thumb = cfg.scroll:CreateTexture(nil, "OVERLAY")
  thumb:SetSize(8, 32)
  thumb:SetColorTexture(1, 0.82, 0, 0.6)
  cfg.scroll:SetThumbTexture(thumb)
  cfg.scroll:SetValueStep(1)
  cfg.scroll:SetObeyStepOnDrag(true)
  cfg.scroll:SetScript("OnValueChanged", function(_, v)
    v = math.floor(v + 0.5)
    if v ~= offset then offset = v; RefreshRows() end
  end)

  cfg:EnableMouseWheel(true)
  cfg:SetScript("OnMouseWheel", function(_, delta)
    local lo, hi = cfg.scroll:GetMinMaxValues()
    cfg.scroll:SetValue(math.max(lo, math.min(hi, offset - delta * 3)))
  end)

  cfg.total = Text(cfg, "", "GameFontDisableSmall")
  cfg.total:SetPoint("TOPLEFT", 16, y - listH - 8)

  cfg:SetScript("OnShow", function() RefreshList(); RefreshConfig() end)
  cfg:Hide()
end

OpenConfig = function(slot)
  if not cfg then CreateConfig() end
  if slot then selected = slot end
  if cfg:IsShown() then RefreshConfig() else cfg:Show() end
end

local function ToggleConfig()
  if cfg and cfg:IsShown() then cfg:Hide() else OpenConfig() end
end

-- Slash-Befehle -----------------------------------------------------------
local function Help()
  Print(L.HELP:format(L.BY, AUTHOR))
  print("  /eb set <slot> <EMOTE>  ·  /eb icon <slot> <Icon>  ·  /eb count <1-" .. MAX_SLOTS .. ">")
  print("  /eb rows <n>  –  Zeilen/Spalten (rows/columns)")
  print("  /eb scale <50-150>  ·  /eb horizontal  ·  /eb vertical  ·  /eb lock  ·  /eb unlock")
  print("  /eb show  ·  /eb hide  ·  /eb reset")
end

SLASH_EMOTEBAR1, SLASH_EMOTEBAR2 = "/emotebar", "/eb"
SlashCmdList.EMOTEBAR = function(msg)
  local cmd, a, b = (msg or ""):match("^(%S*)%s*(%S*)%s*(%S*)")
  cmd = cmd:lower()
  local slot = tonumber(a)

  if cmd == "" or cmd == "config" then
    ToggleConfig()
  elseif cmd == "set" and slot and slot >= 1 and slot <= MAX_SLOTS and b ~= "" then
    local token = b:upper()
    db.slots[slot], db.icons[slot] = token, nil
    if slot > db.count then db.count = slot end
    if not BY_TOKEN[token] then Print(L.UNKNOWN:format(token)) end
    Changed()
  elseif cmd == "icon" and slot and slot >= 1 and slot <= MAX_SLOTS and b ~= "" then
    db.icons[slot] = b; Changed()
  elseif cmd == "count" and slot then
    db.count = math.max(1, math.min(MAX_SLOTS, math.floor(slot))); Changed()
  elseif cmd == "scale" and tonumber(a) then
    local v = tonumber(a)
    if v <= 3 then v = v * 100 end -- 0.8 oder 80 erlaubt
    db.scale = math.max(50, math.min(150, v)) / 100; Changed()
  elseif cmd == "vertical" then
    db.vertical = true; Changed()
  elseif (cmd == "rows" or cmd == "lines") and slot then
    db.lines = math.max(1, math.min(db.count, math.floor(slot))); Changed()
  elseif cmd == "horizontal" then
    db.vertical = false; Changed()
  elseif cmd == "lock" then
    db.locked = true; Changed(); Print(L.LOCKED)
  elseif cmd == "unlock" then
    db.locked = false; Changed(); Print(L.UNLOCKED)
  elseif cmd == "show" then
    db.hidden = false; bar:Show()
  elseif cmd == "hide" then
    db.hidden = true; bar:Hide()
  elseif cmd == "reset" then
    local hidden = db.hidden
    for k in pairs(db) do db[k] = nil end
    for k, v in pairs(DEFAULTS) do db[k] = Copy(v) end
    db.slots, db.icons, db.hidden = Copy(DEFAULT_SLOTS), {}, hidden
    ApplyPosition(); Changed()
    Print(L.RESET)
  else
    Help()
  end
end

-- Eintrag unter Optionen > AddOns (falls die Settings-API vorhanden ist)
local function RegisterSettings()
  if not (Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) then return end
  local panel = CreateFrame("Frame")
  local t = Text(panel, "EmoteBar", "GameFontNormalLarge")
  t:SetPoint("TOPLEFT", 16, -16)
  local a = Text(panel, L.BY .. " " .. AUTHOR, "GameFontDisableSmall")
  a:SetPoint("LEFT", t, "RIGHT", 8, -1)
  local d = Text(panel, L.SETTINGS_DESC)
  d:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -8)
  local b = SmallButton(panel, L.OPEN, 180, function() OpenConfig() end)
  b:SetPoint("TOPLEFT", d, "BOTTOMLEFT", 0, -12)
  pcall(function()
    local cat = Settings.RegisterCanvasLayoutCategory(panel, "EmoteBar")
    Settings.RegisterAddOnCategory(cat)
  end)
end

-- Init --------------------------------------------------------------------
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, name)
  if name ~= ADDON then return end
  self:UnregisterEvent("ADDON_LOADED")

  EmoteBarDB = EmoteBarDB or {}
  db = EmoteBarDB
  for k, v in pairs(DEFAULTS) do
    if db[k] == nil then db[k] = Copy(v) end
  end
  db.slots = db.slots or Copy(DEFAULT_SLOTS)
  db.icons = db.icons or {}
  db.scale = math.max(0.5, math.min(1.5, tonumber(db.scale) or 1))

  BuildCatalog()
  ApplyPosition()
  Layout()
  if db.hidden then bar:Hide() end
  RegisterSettings()
end)
