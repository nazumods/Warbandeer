local _, ns = ...
local ui = ns.ui
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo -- luacheck: globals C_CurrencyInfo
local insert, filter = table.insert, ns.lua.lists.filter
local Colors, alpha = ns.Colors, ns.Colors.alpha
local Class, TableFrame, Texture, Label = ns.lua.Class, ui.TableFrame, ui.Texture, ui.Label

local SummaryView = Class(TableFrame, function(self)
  local RestoredCofferKey = GetCurrencyInfo(3028)
  self.cols[10].header.texture:Texture(RestoredCofferKey.iconFileID)
  self.cols[10].header.texture:Coords(0.1, 0.9, 0.1, 0.9)

  ns.SummaryColumnsDelayed(self)

  self.data = {}
  local n = 0
  local bags = 0
  local reagent = 0
  local toons = self:GetCharacters()
  for _,t in pairs(toons) do
    insert(self.data, self:GetRowData(t))
    if t.basic.level == 80 then n = n + 1 end
    if t.items and t.items.reagentBag and t.items.reagentBag.slots < 36 then
      reagent = reagent + 1
    end
    if t.items and t.items.bags then
      for i = 1, #t.items.bags-1 do -- skip reagent bag
        if t.items.bags[i].slots < 34 then
          bags = bags + 1
        end
      end
    end
  end
  self:update()

  local halfWhite = alpha(WHITE_FONT_COLOR, 0.5)
  local divider = Texture:new{
    parent = self,
    position = {
      TopLeft = {self.rows[n], ui.edge.BottomLeft, -20, 0},
      TopRight = {self.cells[n][3], ui.edge.BottomRight, 0, -1},
      Height = 1,
    },
    color = alpha(WHITE_FONT_COLOR, 0.5),
  }
  -- bump the next row down
  if self.rows[n + 1] then
    self.rows[n + 1]:TopLeft(self.rows[n], ui.edge.BottomLeft, 0, -1)
    self:Height(self:Height() + 1)
  end
  local counter = Label:new{
    parent = self,
    position = {
      BottomRight = {divider, ui.edge.TopLeft, 15, 1},
    },
    text = n,
    color = alpha(WHITE_FONT_COLOR, 0.5),
  }
  local subCounter = Label:new{
    parent = self,
    position = {
      TopRight = {divider, ui.edge.BottomLeft, 15, -1},
    },
    text = #toons - n,
    color = alpha(WHITE_FONT_COLOR, 0.5),
  }

  -- missing bag count
  local bagsLine = Texture:new{
    parent = self,
    position = {
      TopLeft = {self.cols[6], ui.edge.Bottom, 0, 0},
      Width = 1,
      Height = 10,
    },
    color = halfWhite,
  }
  Label:new{
    parent = self,
    position = {
      TopRight = {bagsLine, ui.edge.TopLeft, -1, -1},
    },
    color = halfWhite,
    text = bags,
  }
  Label:new{
    parent = self,
    position = {
      TopLeft = {bagsLine, ui.edge.TopRight, 1, -1},
    },
    color = halfWhite,
    text = reagent,
  }
end, {
  name = "summary",
  _title = "Summary",
  colInfo = ns.lua.lists.map(ns.SummaryColumns, function(c) return c.colInfo end),
})
SummaryView.name = "summary"
ns.views.SummaryView = SummaryView

function SummaryView:GetCharacters()
  local toons = ns.api.GetAllCharacters() -- returns a copy
  toons = filter(toons, function(t) return not t.IsLegionTimerunner end)
  -- sort by level, then ilvl, then name
  table.sort(toons, function(c1, c2)
    if c1.basic.level ~= c2.basic.level then return c1.basic.level > c2.basic.level end
    if c1.equipment.ilvl ~= c2.equipment.ilvl then return c1.equipment.ilvl > c2.equipment.ilvl end
    return c1.name < c2.name
  end)
  return toons
end

function SummaryView:GetRowData(toon)
  return ns.lua.lists.map(ns.SummaryColumns, function(c) return c.getData(toon) end)
end

function SummaryView:OnBeforeShow()
  for i,t in pairs(self:GetCharacters()) do
    self.data[i] = self:GetRowData(t)
  end
  self:update()
end
