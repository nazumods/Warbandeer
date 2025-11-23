local _, ns = ...
local insert = table.insert
local ui = ns.ui
local Class, Frame, TableFrame, Texture, Label = ns.lua.Class, ui.Frame, ui.TableFrame, ui.Texture, ui.Label
local GetMajorFactionIDs = C_MajorFactions.GetMajorFactionIDs
local GetMajorFactionData, GetFactionDataByID = C_MajorFactions.GetMajorFactionData, C_Reputation.GetFactionDataByID
local GetRenownLevels, IsFactionParagon = C_MajorFactions.GetRenownLevels, C_Reputation.IsFactionParagon

local TransparentBackdrop = {color = ns.Colors.TransparentBlack}

-- table of current expansion reputations and their progress
local Factions = Class(TableFrame, function(self)
  self.data = {}
  local factions = GetMajorFactionIDs(GetServerExpansionLevel())
  for _, factionID in ipairs(factions) do
    local info = GetMajorFactionData(factionID)
    local levels = GetRenownLevels(factionID)
    local done = IsFactionParagon(factionID)
    self:addRow({backdrop = TransparentBackdrop})
    insert(self.data, {
      {
        text = info.name,
        color = info.factionFontColor and info.factionFontColor.color,
      },
      {
        text = done and "complete" or (info.renownLevel .. " / " .. levels[#levels].level),
        color = done and DIM_GREEN_FONT_COLOR or (info.factionFontColor and info.factionFontColor.color),
        justifyH = ui.justify.Right,
      },
    })

    -- add any sub-factions, if any
    if ns.data.minorFactions[factionID] then
      for _, subFactionID in ipairs(ns.data.minorFactions[factionID]) do
        local subInfo = GetFactionDataByID(subFactionID)
        local done = IsFactionParagon(subFactionID)
        self:addRow({backdrop = TransparentBackdrop})
        insert(self.data, {
          {
            text = "  " .. subInfo.name,
            color = info.factionFontColor and info.factionFontColor.color,
          },
          {
            text = done and "complete" or (subInfo.currentStanding .. " / " .. ns.data.minorFactionMaxStanding[factionID]),
            color = done and DIM_GREEN_FONT_COLOR or (info.factionFontColor and info.factionFontColor.color),
            justifyH = ui.justify.Right,
          },
        })
      end
    end
  end
end, {
  headerHeight = 0,
  headerWidth = 0,
  colInfo = {
    {width = 190, backdrop = TransparentBackdrop},
    {width = 90, backdrop = TransparentBackdrop},
  },
})

-- Table of top toon per class
local TopAlts = Class(TableFrame, function(self)
  -- autoadjust name width
  local w = 0
  for _,r in ipairs(self.cells) do
    if #r > 2 then
      w = max(w, r[2].label:Width())
    end
  end
  self.cols[2]:Width(w)
  self.rowArea:Width(self.rowArea:Width() + w)
  self:Width(self:Width() + w)
end, {
  headerHeight = 0,
  headerWidth = 0,
  colInfo = {
    {width = 20, backdrop = TransparentBackdrop},
    {width = 100, backdrop = TransparentBackdrop},
    {width = 30, backdrop = TransparentBackdrop},
  },
  GetData = function(self)
    local toons = ns.api.GetAllCharacters()
    toons = ns.lua.lists.filter(toons, function(t) return not t.IsLegionTimerunner end)
    local top = {}
    for _, toon in pairs(toons) do
      if not top[toon.classKey] or
        toon.basic.level > top[toon.classKey].basic.level or
        (toon.basic.level == top[toon.classKey].basic.level and toon.equipment.ilvl > top[toon.classKey].equipment.ilvl)
      then
        top[toon.classKey] = toon
      end
    end
    top = ns.lua.lists.values(top)
    table.sort(top, function (c1, c2)
      if c1.basic.level ~= c2.basic.level then return c1.basic.level > c2.basic.level end
      if c1.equipment.ilvl ~= c2.equipment.ilvl then return c1.equipment.ilvl > c2.equipment.ilvl end
      return c1.name < c2.name
    end)
    local data = {}
    for _, toon in ipairs(top) do
      self:addRow({backdrop = TransparentBackdrop})
      insert(data, {
        {
          text = toon.basic.level,
          color = NORMAL_FONT_COLOR,
        },
        {
          text = toon.name,
          color = ns.Colors[toon.classKey]
        },
        {
          text = ns.IlvlColor(toon.equipment.ilvl),
          justifyH = ui.justify.Right,
        },
      })
    end
    return data
  end,
})

local GreenCheck = {
  atlas = ns.icons.CheckGreen,
  atlasSize = false,
  position = {
    TopLeft = {3, -2},
    BottomRight = {-3, 2},
  },
}

local achievementIds = {20597, 40791, 20596, 40309, 40360, 41052, 40618, 41818, 41970, 41808, 61017}
local Achievements = Class(TableFrame, function(self)
  self.data = ns.lua.maps.map(
    achievementIds,
    function(achievementId)
      local _, name, _, completed = GetAchievementInfo(achievementId)
      if achievementId == 41818 then
         local _, _, _, completedH = GetAchievementInfo(41820)
         completed = completed or completedH
      end
      return {
        {
          text = name,
          color = completed and DIM_GREEN_FONT_COLOR or DIM_RED_FONT_COLOR,
          onClick = function()
            OpenAchievementFrameToAchievement(achievementId)
          end,
        },
      }
    end
  )
end, {
  headerHeight = 0,
  headerWidth = 0,
  colInfo = {
    {width = 155, backdrop = TransparentBackdrop},
  },
  rowInfo = ns.lua.maps.map(
    achievementIds,
    function() return {backdrop = TransparentBackdrop} end
  ),
})

-- Overview
local Overview = Class(Frame, function(self)
  self.topAlts = TopAlts:new{
    parent = self,
    position = {
      TopLeft = {5, -5},
    },
  }
  self.factions = Factions:new{
    parent = self,
    position = {
      TopLeft = {self.topAlts, ui.edge.TopRight, 20, 0},
    },
  }
  self.achievements = Achievements:new{
    parent = self,
    position = {
      TopLeft = {self.factions, ui.edge.TopRight, 20, 0},
    },
  }

  self:Height(20 + math.max(self.topAlts:Height(), self.factions:Height(), self.achievements:Height()))
  self:Width(10 + 40 + self.topAlts:Width() + self.factions:Width() + self.achievements:Width())
end, {
  name = "overview",
  _title = "Overview",
})
Overview.name = "overview"
ns.views.Overview = Overview
