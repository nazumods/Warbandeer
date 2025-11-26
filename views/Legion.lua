local _, ns = ...
local ui = ns.ui
local Class, Frame, TableFrame = ns.lua.Class, ui.Frame, ui.TableFrame
local Label = ui.Label

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
-- /run print(C_QuestLog.IsQuestFlaggedCompleted(44311), C_QuestLog.IsQuestFlaggedCompleted(44312))

-- completed class hall quest lines by class
-- /run local t={-288,-272,3,7,6,0,8,4,9,5,2,1}for i,id in pairs(t) do local _,_,c = GetAchievementCriteriaInfoByID(42565,108648+id)print((GetClassInfo(i)),c and"\124T136814:0\124t"or"\124T136813:0\124t")end

-- mage portal and sheep daily
-- have sheeped it: /run for k,v in pairs{Aszuna=43787,Stormheim=43789,ValSha=43790,Suramar=43791,HighMntn=43788} do print(k,C_QuestLog.IsQuestFlaggedCompleted(v)) end
-- /run f="\124cffffff00\124Hquest:%s:0\124h[%s]\124h\124r: \124cff%s\124r";for k,v in pairs({[44384]="Daily Portal Event Roll",[43828]="Sheep Summon Daily Roll"})do print(format(f,k,v,C_QuestLog.IsQuestFlaggedCompleted(k)and"00ff00Yes"or"ff0000No"))end

---@class Legion: Frame
---@field recolors TableFrame
local Legion = Class(Frame, function(self)
  local w = 0
  local t = ns.api.GetCharacterData()
  self.className = Label:new{
    parent = self,
    text = t.className,
    position = {
      TopLeft = {2, -2},
    },
  }
  w = w + self.className:Height() + 2

  self.hiddenTitle = Label:new{
    parent = self,
    text = "Hidden Appearance",
    position = {
      TopLeft = {self.className, ui.edge.BottomLeft, 0, -10},
    },
  }
  w = w + self.hiddenTitle:Height() + 10
  self.appearances = TableFrame:new{
    parent = self,
    position = {
      TopLeft = {self.hiddenTitle, ui.edge.BottomLeft, 0, -2},
    },
    autosize = true,
    padding = 4,
    headerHeight = 0,
    headerWidth = 0,
    colInfo = {
      {width = 100, backdrop = TransparentBackdrop},
      {width = 25, backdrop = TransparentBackdrop},
    },
    GetData = function()
      return t.artifacts and t.artifacts.hidden and maps.toList(t.artifacts.hidden, function(k, v)
        return {
          { text = k },
          { text = v and "Yes" or "No", color = v and DIM_GREEN_FONT_COLOR or DIM_RED_FONT_COLOR },
        }
      end) or {}
    end,
  }

  local recolorTitle = Label:new{
    parent = self,
    text = "Recolors",
    position = {
      TopLeft = { self.hiddenTitle, ui.edge.TopRight, 10, 0 },
    },
  }
  self.recolors = TableFrame:new{
    parent = self,
    position = {
      TopLeft = {recolorTitle, ui.edge.BottomLeft, 0, -2},
    },
    debug = true,
    autosize = true,
    padding = 4,
    headerHeight = 0,
    headerWidth = 0,
    colInfo = {
      {width = 100, backdrop = TransparentBackdrop},
      {width = 25, backdrop = TransparentBackdrop},
      {width = 25, backdrop = TransparentBackdrop},
    },
    GetData = function()
      return t.artifacts and t.artifacts.hidden and lists.map({"dungeon", "wq", "kills"}, function(n)
        return {
          { text = n },
          { text = t.artifacts.hiddenColors[n].progress, justifyH = ui.justify.Right },
          { text = t.artifacts.hiddenColors[n].goal, justifyH = ui.justify.Right },
        }
      end) or {}
    end,
  }
  w = w + math.max(self.appearances:Height(), self.recolors:Height()) + 2
  self:Height(w)
end, {
  name = "legion",
  _title = "Legion",
  onLoad = function(self)
    self:Width(self.hiddenTitle:Width() + self.recolors:Width() + 15)
  end,
})
Legion.name = "legion"
ns.views.Legion = Legion

function Legion:OnBeforeShow()
  local t = ns.api.GetCharacterData()
  -- update appearances
  -- update recolors
  self.recolors.data[1][2].text = t.artifacts.hiddenColors.dungeon.progress
  self.recolors.data[2][2].text = t.artifacts.hiddenColors.wq.progress
  self.recolors:update()

  -- if self.data then
  --   for i,t in pairs(self:GetCharacters()) do
  --     self.data[i] = self:GetRowData(t)
  --   end
  -- else
  --   self.data = self:GetData()
  -- end
  -- self:update()
end
