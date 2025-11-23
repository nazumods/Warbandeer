local _, ns = ...
local ui = ns.ui
local Class, Frame, TableFrame = ns.lua.Class, ui.Frame, ui.TableFrame
local Label = ui.Label

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

local Appearances = Class(TableFrame, function(self)
end, {
  padding = 4,
  autosize = true,
  -- headerHeight = 0,
  headerWidth = 80,
  colInfo = {
    {width = 100, backdrop = TransparentBackdrop, name = "Aquired"},
    {width = 100, backdrop = TransparentBackdrop, name = "Dungeons"},
    {width = 100, backdrop = TransparentBackdrop, name = "WQs"},
    {width = 100, backdrop = TransparentBackdrop, name = "Kills"},
  },
  rowInfo = {
    { name = "Hidden" },
  },
  GetData = function(self)
    local data = {}
    
    local _,_,_,_,_,_,_,_,_,_,_,_,hidden = GetAchievementInfo(10460)
    local _,_,_,dc,dt = GetAchievementCriteriaInfo(11152,1)
    local _,_,_,qc,qt = GetAchievementCriteriaInfo(11153,1)
    local _,_,_,kc,kt = GetAchievementCriteriaInfo(11154,1)
    table.insert(data, {
      { text = hidden and "Yes" or "No" },
      { text = dc == dt and "Complete" or (dc .. " / " .. dt) },
      { text = qc == qt and "Complete" or (qc .. " / " .. qt) },
      { text = kc == kt and "Complete" or (kc .. " / " .. kt) },
    })
    
    return data
  end,
})

local Legion = Class(Frame, function(self)
  local t = ns.api.GetCharacterData()
  local className = Label:new{
    parent = self,
    text = t.className,
    position = {
      TopLeft = {2, -2},
    },
  }

  local appearances = Appearances:new{
    parent = self,
    position = {
      TopLeft = {className, ui.edge.BottomLeft, 0, -10},
    },
  }

  self:Height(200)
  self:Width(400)
end, {
  name = "legion",
  _title = "Legion",
})
Legion.name = "legion"
ns.views.Legion = Legion
