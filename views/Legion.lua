local _, ns = ...
local ui = ns.ui
local Class, Frame, TableFrame = ns.lua.Class, ui.Frame, ui.TableFrame
local Label = ui.Label

---@type WarbandeerAPI
local api = ns.api

---@type Lists
local lists = ns.lua.lists

---@type Maps
local maps = ns.lua.maps

local TransparentBackdrop = {color = ns.Colors.TransparentBlack}

-- balance of power
-- /run for _,i in ipairs({43496,40668,43517,43514,43518,43519,43520,43521,43522,43527,43523,40673,43525,40675,43524,40678,43526,40603,40608,40613,40672,40614,40615,43528,43898,43531,43530,43532,43533}) do print(i, C_QuestLog.IsQuestFlaggedCompleted(i)) end

-- hidden artifact appearance colors
-- /run local a,x,g,t=0,11152,GetAchievementCriteriaInfo;a=select(13,GetAchievementInfo(10460));print("Unlocked:",a);_,_,_,a,t=g(x,1);print("Dungeons:", a, "/", t);_,_,_,a,t=g(x+1,1);print("WQs:", a, "/", t);_,_,_,a,t=g(x+2,1);print("Kills:", a, "/", t)

-- Annals of Light and Shadow
-- /run for k,v in ipairs({44339,44340,44341,44342,44343,44344,44345,44346,44347,44348,44349,44350}) do print(format("%s: %s",k,C_QuestLog.IsQuestFlaggedCompleted(v) and "\124cff00ff00Yes\124r" or "\124cffff0000No\124r")) end

-- https://www.wowhead.com/item=139552/feather-of-the-moonspirit#comments
-- /run for q,i in pairs({Event=44326,FeralasActive=44327,FeralasTouched=44331,HinterlandsActive=44328,HinterlandsTouched=44332,DuskwoodActive=44329,DuskwoodTouched=44330}) do print(i,C_QuestLog.IsQuestFlaggedCompleted(i),q) end

-- prot warrior event eligible
-- /run for k,v in pairs{Prot_Eligible=44311,Prot_Denied=44312} do print(k,C_QuestLog.IsQuestFlaggedCompleted(v)and"\124cff00ff00Yes\124r"or"\124cffff0000No\124r") end

-- completed class hall quest lines by class
-- /run local t={-288,-272,3,7,6,0,8,4,9,5,2,1}for i,id in pairs(t) do local _,_,c = GetAchievementCriteriaInfoByID(42565,108648+id)print((GetClassInfo(i)),c and"\124T136814:0\124t"or"\124T136813:0\124t")end

-- mage portal and sheep daily
-- have sheeped it: /run for k,v in pairs{Aszuna=43787,Stormheim=43789,ValSha=43790,Suramar=43791,HighMntn=43788} do print(k,C_QuestLog.IsQuestFlaggedCompleted(v)) end
-- /run f="\124cffffff00\124Hquest:%s:0\124h[%s]\124h\124r: \124cff%s\124r";for k,v in pairs({[44384]="Daily Portal Event Roll",[43828]="Sheep Summon Daily Roll"})do print(format(f,k,v,C_QuestLog.IsQuestFlaggedCompleted(k)and"00ff00Yes"or"ff0000No"))end

-- unholy DK army of the dead
-- /dump C_QuestLog.IsQuestFlaggedCompleted(44188)

local instructions = {
  DeathKnight = {
    Unholy = "Use Army of the Dead",
    Blood = "Withered Army Training",
  },
  Druid = {
    Feral = "Dreamgrove entrance, check for portal emote",
  },
  Mage = {
    Frost = "Order Hall stairs, look for emote",
    Arcane = "Portal into Order Hall, look for sheep emote",
  },
  Monk = {
    Brewmaster = "Tap " .. DARKYELLOW_FONT_COLOR:WrapTextInColorCode("Bubbling Keg") .. " in " .. DARKYELLOW_FONT_COLOR:WrapTextInColorCode("Brewhouse") .. " in Order Hall",
    Mistweaver = "Kill ".. DARKYELLOW_FONT_COLOR:WrapTextInColorCode("Dragons of Nightmare") .. " in " .. DARKYELLOW_FONT_COLOR:WrapTextInColorCode("Emerald Nightmare") .. " raid",
    Windwalker = "Withered Army Training",
  },
  Paladin = {
    Protection = "Withered Army Training",
  },
  Warlock = {
    Affliction = "Collect skulls from " .. DARKYELLOW_FONT_COLOR:WrapTextInColorCode("Danger") .. " World Quests",
  },
  Warrior = {
    Fury = "Valarjar exalted, then skulls from Shar'thos and Nith'ogg, and haft from Skovald",
    Protection = "Path of Huln",
  },
}

local Appearances = Class(TableFrame, function(self)
end, {
  autosize = true,
  padding = 4,
  colBackdrop = TransparentBackdrop,
  colInfo = {
    {},
    {},
    {},
    {},
    {},
    { name = "Dungeon" },
    { name = "WQ" },
    { name = "Kills" },
  },
})

function Appearances:GetData()
  local data, bc = {}, {}
  local toons = api.GetAllCharacters()
  for _,t in ipairs(toons) do
    if t.artifacts and t.artifacts.hidden and t.artifacts.hiddenColors then
      if bc[t.classKey] == nil then bc[t.classKey] = { specs = {}, wq = 0, dungeon = 0, kills = 0 } end
      local c = bc[t.classKey]
      for k,v in pairs(t.artifacts.hidden) do
        if c.specs[k] == nil then c.specs[k] = false end
        c.specs[k] = c.specs[k] or v
      end
      c.wq = t.artifacts.hiddenColors.wq.progress
      c.dungeon = t.artifacts.hiddenColors.dungeon.progress
      c.kills = t.artifacts.hiddenColors.kills.progress
    end
  end
  for _,c in ipairs({'DeathKnight', 'DemonHunter', 'Druid', 'Hunter', 'Mage', 'Monk', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior'}) do
    if bc[c] ~= nil then
      local s = {{text = c}}
      for k,v in pairs(bc[c].specs) do
        local t = {
          text = k,
          color = v and DIM_GREEN_FONT_COLOR or DIM_RED_FONT_COLOR,
        }
        if (not v) and instructions[c] and instructions[c][k] then
          t.onEnter = function(self)
            GameTooltip:SetOwner(self._widget, "ANCHOR_BOTTOMRIGHT", -10, 10)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(instructions[c][k], 1, 1, 1)
            GameTooltip:Show()
          end
          t.onLeave = function() GameTooltip:Hide() end
        end
        table.insert(s, t)
      end
      if #s < 5 then table.insert(s, { text = "" }) end
      if #s < 5 then table.insert(s, { text = "" }) end
      table.insert(s, { text = (30 - bc[c].dungeon) .. " left", justifyH = ui.justify.Right })
      table.insert(s, { text = (200 - bc[c].wq) .. " left", justifyH = ui.justify.Right })
      table.insert(s, { text = (1000 - bc[c].kills) .. " left", justifyH = ui.justify.Right })
      table.insert(data, s)
    end
  end
  return data
end

local achievementIds = {10459, 11160, 11163}

-- Achievements Table
local Achievements = Class(TableFrame, function()
end, {
  colBackdrop = TransparentBackdrop,
  autosize = true,
  headerHeight = 0,
  headerWidth = 0,
  GetData = function(self)
    return ns.lua.maps.map(
      ns.lua.lists.fold(achievementIds, 3),
      function(ids)
        return ns.lua.lists.map(ids, function(achievementId)
          local _, name, _, completed = GetAchievementInfo(achievementId)
          return {
            text = name,
            color = completed and DIM_GREEN_FONT_COLOR or DIM_RED_FONT_COLOR,
            onClick = function()
              OpenAchievementFrameToAchievement(achievementId)
            end,
          }
        end)
      end
    )
  end,
})


---@class Legion: Frame
---@field collected TableFrame
---@field achievements TableFrame
local Legion = Class(Frame, function(self)
  local h = 2

  self.collected = Appearances:new{
    parent = self,
    position = {
      TopLeft = {2, -h},
    },
  }
  h = h + self.collected:Height()

  self.achievements = Achievements:new{
    parent = self,
    position = {
      TopLeft = {self.collected, ui.edge.BottomLeft, 0, -10},
    },
  }
  h = h + self.achievements:Height() + 10

  self:Height(h + 2)
end, {
  name = "legion",
  _title = "Legion",
  onLoad = function(self)
    self:Width(self.collected:Width() + 4)
  end,
})
Legion.name = "legion"
ns.views.Legion = Legion

function Legion:OnBeforeShow()
  self.collected.data = self.collected:GetData()
  self.collected:update()
end
