--[[
  Game: Roblox-MemeSea
]]
local _wait = task.wait
repeat _wait() until game:IsLoaded()
local _env = getgenv and getgenv() or {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local rs_Monsters = ReplicatedStorage:WaitForChild("MonsterSpawn")
local Modules = ReplicatedStorage:WaitForChild("ModuleScript")
local OtherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local Monsters = workspace:WaitForChild("Monster")

local MQuestSettings = require(Modules:WaitForChild("Quest_Settings"))
local MSetting = require(Modules:WaitForChild("Setting"))

local NPCs = workspace:WaitForChild("NPCs")
local Raids = workspace:WaitForChild("Raids")
local Location = workspace:WaitForChild("Location")
local Region = workspace:WaitForChild("Region")
local Island = workspace:WaitForChild("Island")

local Quests_Npc = NPCs:WaitForChild("Quests_Npc")
local EnemyLocation = Location:WaitForChild("Enemy_Location")
local QuestLocation = Location:WaitForChild("QuestLocaion")

local Items = Player:WaitForChild("Items")
local QuestFolder = Player:WaitForChild("QuestFolder")
local Ability = Player:WaitForChild("Ability")
local PlayerData = Player:WaitForChild("PlayerData")
local PlayerLevel = PlayerData:WaitForChild("Level")

local sethiddenproperty = sethiddenproperty or (function()end)

local CFrame_Angles = CFrame.Angles
local CFrame_new = CFrame.new
local Vector3_new = Vector3.new

local _huge = math.huge

task.spawn(function()
  if not _env.LoadedHideUsername then
    _env.LoadedHideUsername = true
    local Label = Player.PlayerGui.MainGui.PlayerName
    
    local function Update()
      local Level = PlayerLevel.Value
      local IsMax = Level >= MSetting.Setting.MaxLevel
      Label.Text = ("%s • Lv. %i%s"):format("Anonymous", Level, IsMax and " (Max)" or "")
    end
    
    Label:GetPropertyChangedSignal("Text"):Connect(Update)Update()
  end
end)

local Loaded, Funcs, Folders = {}, {}, {} do
  Loaded.ItemsPrice = {
    Aura = function()
      return Funcs:GetMaterial("Meme Cube") > 0 and Funcs:GetData("Money") >= 10000000 -- 1x Meme Cube, $10.000.000
    end,
    FlashStep = function()
      return Funcs:GetData("Money") >= 100000 -- $100.000
    end,
    Instinct = function()
      return Funcs:GetData("Money") >= 2500000 -- $2.500.000
    end
  }
  Loaded.Shop = {
    {"Vũ Khí", {
        {"Mua Katana", "$5.000 Tiền", {"Người Bán Vũ Khí", "Doge"}},
        {"Mua Móc Treo", "$25.000 Tiền", {"Người Bán Vũ Khí", "Móc Treo"}},
        {"Mua Katana Lửa", "1x Cheems Cola và $50.000", {"Người Bán Vũ Khí", "Cheems"}},
        {"Mua Chuối", "1x Thức Ăn Mèo và $350.000", {"Người Bán Vũ Khí", "Mèo Cười"}},
        {"Mua Cái Búa", "5x Bao Tiền và $1.000.000", {"Người Bán Vũ Khí", "Meme Man"}},
        {"Mua Bí Ngô", "1x Nugget Man và $3.500.000", {"Người Bán Vũ Khí", "Bia Mộ"}},
        {"Mua Popcat", "10.000 Lần Nhấp Pop", {"Người Bán Vũ Khí", "Ohio Popcat"}}
      }},
      {"Kỹ Năng", {
        {"Mua Bước Chớp", "$100.000 Tiền", {"Người Dạy Kỹ Năng", "Giga Chad"}},
        {"Mua Bản Năng", "$2.500.000 Tiền", {"Người Dạy Kỹ Năng", "Nugget Man"}},
        {"Mua Aura", "1x Meme Cube và $10.000.000", {"Người Dạy Kỹ Năng", "Bậc Thầy Aura"}}
      }},
      {"Phong Cách Chiến Đấu", {
        {"Mua Chiến Đấu", "$0 Tiền", {"Người Dạy Phong Cách Chiến Đấu", "Maxwell"}},
        {"Mua Baller", "10x Bóng và $10.000.000", {"Người Dạy Phong Cách Chiến Đấu", "Baller"}}
      }}
    }
    Loaded.DanhSachVuKhi = { "Chiến Đấu", "Sức Mạnh", "Vũ Khí" }
    Loaded.DanhSachKeDich = {}
    Loaded.DiemSpawnCuaKeDich = {}
    Loaded.NhiemVuCuaKeDich = {}
    Loaded.Dao = {}
    Loaded.NhiemVu = {}  
  
  local function RedeemCode(Code)
    return OtherEvent.MainEvents.Code:InvokeServer(Code)
  end
  
  Funcs.RAllCodes = function(self)
    if Modules:FindFirstChild("CodeList") then
      local List = require(Modules.CodeList)
      for Code, Info in pairs(type(List) == "table" and List or {}) do
        if type(Code) == "string" and type(Info) == "table" and Info.Status then RedeemCode(Code) end
      end
    end
  end
  
  Funcs.GetPlayerLevel = function(self)
    return PlayerLevel.Value
  end
  
  Funcs.GetCurrentQuest = function(self)
    for _,Quest in pairs(Loaded.Quests) do
      if Quest.Level <= self:GetPlayerLevel() and not Quest.RaidBoss and not Quest.SpecialQuest then
        return Quest
      end
    end
  end
  
  Funcs.CheckQuest = function(self)
    for _,v in ipairs(QuestFolder:GetChildren()) do
      if v.Target.Value ~= "None" then
        return v
      end
    end
  end
  
  Funcs.VerifySword = function(self, SName)
    local Swords = Items.Weapon
    return Swords:FindFirstChild(SName) and Swords[SName].Value > 0
  end
  
  Funcs.VerifyAccessory = function(self, AName)
    local Accessories = Items.Accessory
    return Accessories:FindFirstChild(AName) and Accessories[AName].Value > 0
  end
  
  Funcs.GetMaterial = function(self, MName)
    local ItemStorage = Items.ItemStorage
    return ItemStorage:FindFirstChild(MName) and ItemStorage[MName].Value or 0
  end
  
  Funcs.AbilityUnlocked = function(self, Ablt)
    return Ability:FindFirstChild(Ablt) and Ability[Ablt].Value
  end
  
  Funcs.CanBuy = function(self, Item)
    if Loaded.ItemsPrice[Item] then
      return Loaded.ItemsPrice[Item]()
    end
    return false
  end
  
  Funcs.GetData = function(self, Data)
    return PlayerData:FindFirstChild(Data) and PlayerData[Data].Value or 0
  end
  
  for Npc,Quest in pairs(MQuestSettings) do
    if QuestLocation:FindFirstChild(Npc) then
      table.insert(Loaded.Quests, {
        RaidBoss = Quest.Raid_Boss,
        SpecialQuest = Quest.Special_Quest,
        QuestPos = QuestLocation[Npc].CFrame,
        EnemyPos = EnemyLocation[Quest.Target].CFrame,
        Level = Quest.LevelNeed,
        Enemy = Quest.Target,
        NpcName = Npc
      })
    end
  end
  
  table.sort(Loaded.Quests, function(a, b) return a.Level > b.Level end)
  for _,v in ipairs(Loaded.Quests) do
    table.insert(Loaded.EnemeiesList, v.Enemy)Loaded.EnemiesQuests[v.Enemy] = v.NpcName
  end
end

local Settings = Settings or {} do
  Settings.AutoStats_Points = 1
  Settings.BringMobs = true
  Settings.FarmDistance = 9
  Settings.ViewHitbox = false
  Settings.AntiAFK = true
  Settings.AutoHaki = true
  Settings.AutoClick = true
  Settings.ToolFarm = "Chiến Đấu" -- [[ "Chiến Đấu", "Sức Mạnh", "Vũ Khí" ]]
  Settings.FarmCFrame = CFrame_new(0, Settings.FarmDistance, 0) * CFrame_Angles(math.rad(-90), 0, 0)
end

local function PlayerClick()
  local Char = Player.Character
  if Char then
    if Settings.AutoClick then
      VirtualUser:CaptureController()
      VirtualUser:Button1Down(Vector2.new(1e4, 1e4))
    end
    if Settings.AutoHaki and Char:FindFirstChild("AuraColor_Folder") and Funcs:AbilityUnlocked("Aura") then
      if #Char.AuraColor_Folder:GetChildren() < 1 then
        OtherEvent.MainEvents.Ability:InvokeServer("Aura")
      end
    end
  end
end

local function IsAlive(Char)
  local Hum = Char and Char:FindFirstChild("Humanoid")
  return Hum and Hum.Health > 0
end

local function GetNextEnemie(EnemieName)
  for _,v in ipairs(Monsters:GetChildren()) do
    if (not EnemieName or v.Name == EnemieName) and IsAlive(v) then
      return v
    end
  end
  return false
end

local function GoTo(CFrame, Move)
  local Char = Player.Character
  if IsAlive(Char) then
    return Move and ( Char:MoveTo(CFrame.p) or true ) or Char:SetPrimaryPartCFrame(CFrame)
  end
end

local function EquipWeapon()
  local Backpack, Char = Player:FindFirstChild("Backpack"), Player.Character
  if IsAlive(Char) and Backpack then
    for _,v in ipairs(Backpack:GetChildren()) do
      if v:IsA("Tool") and v.ToolTip:find(Settings.ToolFarm) then
        Char.Humanoid:EquipTool(v)
      end
    end
  end
end

local function BringMobsTo(_Enemie, CFrame, SBring)
  for _,v in ipairs(Monsters:GetChildren()) do
    if (SBring or v.Name == _Enemie) and IsAlive(v) then
      local PP, Hum = v.PrimaryPart, v.Humanoid
      if PP and (PP.Position - CFrame.p).Magnitude < 500 then
        Hum.WalkSpeed = 0
        Hum:ChangeState(14)
        PP.CFrame = CFrame
        PP.CanCollide = false
        PP.Transparency = Settings.ViewHitbox and 0.8 or 1
        PP.Size = Vector3.new(50, 50, 50)
      end
    end
  end
  return pcall(sethiddenproperty, Player, "SimulationRadius", _huge)
end

local function KillMonster(_Enemie, SBring)
  local Enemy = typeof(_Enemie) == "Instance" and _Enemie or GetNextEnemie(_Enemie)
  if IsAlive(Enemy) and Enemy.PrimaryPart then
    GoTo(Enemy.PrimaryPart.CFrame * Settings.FarmCFrame)EquipWeapon()
    if not Enemy:FindFirstChild("Reverse_Mark") then PlayerClick() end
    if Settings.BringMobs then BringMobsTo(_Enemie, Enemy.PrimaryPart.CFrame, SBring) end
    return true
  end
end

local function TakeQuest(QuestName, CFrame, Wait)
  local QuestGiver = Quests_Npc:FindFirstChild(QuestName)
  if QuestGiver and Player:DistanceFromCharacter(QuestGiver.WorldPivot.p) < 5 then
    return fireproximityprompt(QuestGiver.Block.QuestPrompt), _wait(Wait or 0.1)
  end
  GoTo(CFrame or QuestLocation[QuestName].CFrame)
end

local function ClearQuests(Ignore)
  for _,v in ipairs(QuestFolder:GetChildren()) do
    if v.QuestGiver.Value ~= Ignore and v.Target.Value ~= "None" then
      OtherEvent.QuestEvents.Quest:FireServer("Abandon_Quest", { QuestSlot = v.Name })
    end
  end
end

local function GetRaidEnemies()
  for _,v in ipairs(Monsters:GetChildren()) do
    if v:GetAttribute("Raid_Enemy") and IsAlive(v) then
      return v
    end
  end
end

local function GetRaidMap()
  for _,v in ipairs(Raids:GetChildren()) do
    if v.Joiners:FindFirstChild(Player.Name) then
      return v
    end
  end
end

local function VerifyQuest(QName)
  local Quest = Funcs:CheckQuest()
  return Quest and Quest.QuestGiver.Value == QName
end

_env.FarmFuncs = {
    {"_Kiếm Floppa", (function()
      if not Funcs:VerifySword("Floppa") then
        if VerifyQuest("Nhiệm Vụ Floppa Ngầu") then
          GoTo(CFrame_new(794, -31, -440))
          fireproximityprompt(Island.FloppaIsland["Lava Floppa"].ClickPart.ProximityPrompt)
        else
          ClearQuests("Nhiệm Vụ Floppa Ngầu")
          TakeQuest("Nhiệm Vụ Floppa Ngầu", CFrame_new(758, -31, -424))
        end
        return true
      end
    end)},
    {"Quái Vật Meme", (function()
      local MemeBeast = Monsters:FindFirstChild("Quái Vật Meme") or rs_Monsters:FindFirstChild("Quái Vật Meme")
      if MemeBeast then
        GoTo(MemeBeast.WorldPivot)EquipWeapon()PlayerClick()
        return true
      end
    end)},
    {"Chúa Sus", (function()
      local LordSus = Monsters:FindFirstChild("Chúa Sus") or rs_Monsters:FindFirstChild("Chúa Sus")
      if LordSus then
        if not VerifyQuest("Nhiệm Vụ Floppa 32") and Funcs:GetPlayerLevel() >= 1550 then
          ClearQuests("Nhiệm Vụ Floppa 32")TakeQuest("Nhiệm Vụ Floppa 32", nil, 1)
        else
          KillMonster(LordSus)
        end
        return true
      elseif Funcs:GetMaterial("Quả Cầu Sus") > 0 then
        if Player:DistanceFromCharacter(Vector3_new(6644, -95, 4811)) < 5 then
          fireproximityprompt(Island.ForgottenIsland.Summon3.Summon.SummonPrompt)
        else GoTo(CFrame_new(6644, -95, 4811)) end
        return true
      end
    end)},
    {"Noob Ác", (function()
      local EvilNoob = Monsters:FindFirstChild("Noob Ác") or rs_Monsters:FindFirstChild("Noob Ác")
      if EvilNoob then
        if not VerifyQuest("Nhiệm Vụ Floppa 29") and Funcs:GetPlayerLevel() >= 1400 then
          ClearQuests("Nhiệm Vụ Floppa 29")TakeQuest("Nhiệm Vụ Floppa 29", nil, 1)
        else
          KillMonster(EvilNoob)
        end
        return true
      elseif Funcs:GetMaterial("Đầu Noob") > 0 then
        if Player:DistanceFromCharacter(Vector3_new(-2356, -81, 3180)) < 5 then
          fireproximityprompt(Island.MoaiIsland.Summon2.Summon.SummonPrompt)
        else GoTo(CFrame_new(-2356, -81, 3180)) end
        return true
      end
    end)},  
    _env.FarmFuncs = {
        {"Bí Ngô Khổng Lồ", (function()
          local Pumpkin = Monsters:FindFirstChild("Bí Ngô Khổng Lồ") or rs_Monsters:FindFirstChild("Bí Ngô Khổng Lồ")
          if Pumpkin then
            if not VerifyQuest("Nhiệm Vụ Floppa 23") and Funcs:GetPlayerLevel() >= 1100 then
              ClearQuests("Nhiệm Vụ Floppa 23")TakeQuest("Nhiệm Vụ Floppa 23", nil, 1)
            else
              KillMonster(Pumpkin)
            end
            return true
          elseif Funcs:GetMaterial("Quả Cầu Lửa") > 0 then
            if Player:DistanceFromCharacter(Vector3_new(-1180, -93, 1462)) < 5 then
              fireproximityprompt(Island.PumpkinIsland.Summon1.Summon.SummonPrompt)
            else GoTo(CFrame_new(-1180, -93, 1462)) end
            return true
          end
        end)},
        {"Quả Cầu Race V2", (function()
          if Funcs:GetPlayerLevel() >= 500 then
            local Quest, Enemy = "Nhiệm Vụ Chuối Nhảy Múa", "Sogga"
            if VerifyQuest(Quest) then
              if KillMonster(Enemy) then else GoTo(EnemyLocation[Enemy].CFrame) end
            else ClearQuests(Quest)TakeQuest(Quest, CFrame_new(-2620, -80, -2001)) end
            return true
          end
        end)},
        {"Cày Cấp Độ", (function()
          local Quest, QuestChecker = Funcs:GetCurrentQuest(), Funcs:CheckQuest()
          if Quest then
            if QuestChecker then
              local _QuestName = QuestChecker.QuestGiver.Value
              if _QuestName == Quest.NpcName then
                if KillMonster(Quest.Enemy) then else GoTo(Quest.EnemyPos) end
              else
                if KillMonster(QuestChecker.Target.Value) then else GoTo(QuestLocation[_QuestName].CFrame) end
              end
            else TakeQuest(Quest.NpcName) end
          end
          return true
        end)},
        {"Cày Raid", (function()
          if Funcs:GetPlayerLevel() >= 1000 then
            local RaidMap = GetRaidMap()
            if RaidMap then
              if RaidMap:GetAttribute("Starting") ~= 0 then
                OtherEvent.MiscEvents.StartRaid:FireServer("Bắt Đầu")_wait(1)
              else
                local Enemie = GetRaidEnemies()
                if Enemie then KillMonster(Enemie, true) else
                  local Spawn = RaidMap:FindFirstChild("Vị Trí Xuất Hiện")
                  if Spawn then GoTo(Spawn.CFrame) end
                end
              end
            else
              local Raid = Region:FindFirstChild("Khu Vực Raid")
              if Raid then GoTo(CFrame_new(Raid.Position)) end
            end
            return true
          end
        end)},
        {"Kẻ Thù FS", (function()
          local Enemy = _env.SelecetedEnemie
          local Quest = Loaded.EnemiesQuests[Enemy]
          if VerifyQuest(Quest) or not _env["FS Nhận Nhiệm Vụ"] then
            if KillMonster(Enemy) then else GoTo(EnemyLocation[Enemy].CFrame) end
          else ClearQuests(Quest)TakeQuest(Quest) end
          return true
        end)},
        {"Cày Gần Nhất", (function() return KillMonster(GetNextEnemie()) end)}
      }      
if not _env.LoadedFarm then
  _env.LoadedFarm = true
  task.spawn(function()
    while _wait() do
      for _,f in _env.FarmFuncs do
        if _env[f[1]] then local s,r=pcall(f[2])if s and r then break end;end
      end
    end
  end)
end

local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/sweet-yeuem/memesea/main/souce.lua"))()
local Window = redzlib:MakeWindow({ Title = "YTB : Sweet YT", SubTitle = "by sweetyt", SaveFolder = "sweetyt-MemeSea.json" })
Window:AddMinimizeButton({
  Button = { Image = "rbxassetid://18856351865", BackgroundTransparency = 0 },
  Corner = { CornerRadius = UDim.new(0, 6) }
})
local Tabs = {
    Discord = Window:MakeTab({"Discord", "Thông Tin"}),
    MainFarm = Window:MakeTab({"Cày", "Trang Chủ"}),
    Items = Window:MakeTab({"Vật Phẩm", "Kiếm"}),
    Stats = Window:MakeTab({"Thống Kê", "Tín Hiệu"}),
    Teleport = Window:MakeTab({"Dịch Chuyển", "Xác Định"}),
    Shop = Window:MakeTab({"Cửa Hàng", "Giỏ Hàng"}),
    Misc = Window:MakeTab({"Khác", "Cài Đặt"})
  }
  
  Window:SelectTab(Tabs.MainFarm)
  
  local function AddToggle(Tab, Settings, Flag)
    Settings.Description = type(Settings[2]) == "string" and Settings[2]
    Settings.Default = type(Settings[2]) ~= "string" and Settings[2]
    Settings.Flag = Settings.Flag or Flag
    Settings.Callback = function(Value) _env[Settings.Flag] = Value end
    Tab:AddToggle(Settings)
  end
  
  local _Discord = Tabs.Discord do
    _Discord:AddDiscordInvite({
      Name = "Stae Market",
      Description = "Tham gia discord",
      Logo = "rbxassetid://18856351865",
      Invite = "https://discord.gg/stae"
    })
  end
  
  local _MainFarm = Tabs.MainFarm do
    _MainFarm:AddDropdown({"Công Cụ Cày", Loaded.WeaponsList, Settings.ToolFarm, function(Value)
      Settings.ToolFarm = Value
    end, "Main/FarmTool"})
    _MainFarm:AddSection("Cày Cấp")
    AddToggle(_MainFarm, {"Tự Động Cày Cấp", ("Cấp Tối Đa: %i"):format(MSetting.Setting.MaxLevel)}, "Level Farm")
    AddToggle(_MainFarm, {"Tự Động Cày Gần Nhất"}, "Nearest Farm")
    _MainFarm:AddSection("Kẻ Thù")
    _MainFarm:AddDropdown({"Chọn Kẻ Thù", Loaded.EnemeiesList, {Loaded.EnemeiesList[1]}, function(Value)
      _env.SelecetedEnemie = Value
    end, "Main/SEnemy"})
    AddToggle(_MainFarm, {"Tự Động Cày Kẻ Thù Được Chọn"}, "FS Enemie")
    AddToggle(_MainFarm, {"Nhận Nhiệm Vụ [ Kẻ Thù Được Chọn ]", true}, "FS Take Quest")
    _MainFarm:AddSection("Cày Boss")
    AddToggle(_MainFarm, {"Tự Động Cày Meme Beast [ Xuất Hiện Mỗi 30 Phút ]", "Rơi: Cổng ( <25% ), Meme Cube ( <50% )"}, "Meme Beast")
    _MainFarm:AddSection("Raid")
    AddToggle(_MainFarm, {"Tự Động Cày Raid", "Yêu Cầu: Cấp 1000"}, "Raid Farm")
  end  
 local _Items = Tabs.Items do
    _Items:AddSection("Sức Mạnh")
    _Items:AddButton({"Reroll Sức Mạnh 10X [ 250k Tiền ]", function()
      OtherEvent.MainEvents.Modules:FireServer("Random_Power", {
        Type = "Decuple",
        NPCName = "Floppa Gacha",
        GachaType = "Money"
      })
    end})
    _Items:AddToggle({"Tự Động Lưu Sức Mạnh", false, function(Value)
      _env.AutoStorePowers = Value
      while _env.AutoStorePowers do _wait()
        for _,v in ipairs(Player.Backpack:GetChildren()) do
          if v:IsA("Tool") and v.ToolTip == "Power" and v:GetAttribute("Using") == nil then
            v.Parent = Player.Character
            OtherEvent.MainEvents.Modules:FireServer("Eatable_Power", { Action = "Store", Tool = v })
          end
        end
      end
    end, "AutoStore"})
    _Items:AddSection("Màu Aura")
    _Items:AddButton({"Reroll Màu Aura [ 10 Ngọc ]", function()
      OtherEvent.MainEvents.Modules:FireServer("Reroll_Color", "Halfed Sorcerer")
    end})
    _Items:AddSection("Boss")
    AddToggle(_Items, {"Tự Động Giant Pumpkin", "Rơi: Pumpkin Head ( <10% ), Nugget Man ( <25% )"}, "Giant Pumpkin")
    AddToggle(_Items, {"Tự Động Evil Noob", "Rơi: Yellow Blade ( <5% ), Noob Friend ( <10% )"}, "Evil Noob")
    AddToggle(_Items, {"Tự Động Lord Sus", "Rơi: Purple Sword ( <5% ), Sus Pals ( <10% )"}, "Lord Sus")
    _Items:AddSection("Race")
    AddToggle(_Items, {"Tự Động Awakening Orb", "Yêu Cầu: Cấp 500"}, "Race V2 Orb")
    _Items:AddSection("Vũ Khí")
    AddToggle(_Items, {"Tự Động Floppa [ Kiếm Đặc Biệt ]"}, "_Floppa Sword")
    _Items:AddSection("Popcat")
    _Items:AddToggle({"Tự Động Popcat", false, function(Value)
      _env.AutoPopcat = Value
      local ClickDetector = Island.FloppaIsland.Popcat_Clickable.Part.ClickDetector
      local Heartbeat = RunService.Heartbeat
      if Value then GoTo(CFrame_new(400, -37, -588)) end
      
      while _env.AutoPopcat do Heartbeat:Wait()
        fireclickdetector(ClickDetector)
      end
    end, "AutoPopcat"})
  end  
  local _Stats = Tabs.Stats do
    _Stats:AddSlider({"Chọn Điểm", 1, 100, Settings.AutoStats_Points, 1, function(Value)
      Settings.AutoStats_Points = Value
    end, "Stats/SelectPoints"})
    _Stats:AddToggle({"Tự Động Cập Nhật Thống Kê", false, function(Value)
      _env.AutoStats = Value
      local _Points = PlayerData.SkillPoint
      while _env.AutoStats do _wait(0.5)
        for _,Stats in pairs(SelectedStats) do
          local _p, _s = _Points.Value, PlayerData[StatsName[_]]
          if Stats and _p > 0 and _s.Value < MSetting.Setting.MaxLevel then
            OtherEvent.MainEvents.StatsFunction:InvokeServer({
              ["Target"] = StatsName[_],
              ["Action"] = "UpgradeStats",
              ["Amount"] = math.clamp(Settings.AutoStats_Points, 0, MSetting.Setting.MaxLevel - _s.Value)
            })
          end
        end
      end
    end})
    _Stats:AddSection("Chọn Thống Kê")
    for _,v in next, StatsName do
      _Stats:AddToggle({_, false, function(Value)
        SelectedStats[_] = Value
      end, "Stats_" .. _})
    end
  end
  
  local _Teleport = Tabs.Teleport do
    _Teleport:AddSection("Di Chuyển")
    _Teleport:AddDropdown({"Quần Đảo", Location:WaitForChild("SpawnLocations"):GetChildren(), {}, function(Value)
      GoTo(Location.SpawnLocations[Value].CFrame)
    end})
    _Teleport:AddDropdown({"Nhiệm Vụ", Location:WaitForChild("QuestLocaion"):GetChildren(), {}, function(Value)
      GoTo(Location.QuestLocaion[Value].CFrame)
    end})
  end
  
  local _Shop = Tabs.Shop do
    _Shop:AddSection("Tự Động Mua")
    _Shop:AddToggle({"Tự Động Mua Khả Năng", false, function(Value)
      _env.AutoBuyAbility = Value
      while _env.AutoBuyAbility do  _wait(1)
        if not Funcs:AbilityUnlocked("Instinct") and Funcs:CanBuy("Instinct") then
          OtherEvent.MainEvents.Modules:FireServer("Ability_Teacher", "Nugget Man")
        elseif not Funcs:AbilityUnlocked("FlashStep") and Funcs:CanBuy("FlashStep") then
          OtherEvent.MainEvents.Modules:FireServer("Ability_Teacher", "Giga Chad")
        elseif not Funcs:AbilityUnlocked("Aura") and Funcs:CanBuy("Aura") then
          OtherEvent.MainEvents.Modules:FireServer("Ability_Teacher", "Aura Master")
        else wait(3) end
      end
    end, "Tự Động Mua Khả Năng", Desc = "Aura, Instinct & Flash Step"})
    
    for _,s in next, Loaded.Shop do
      _Shop:AddSection({s[1]})
      for _,item in pairs(s[2]) do
        local buyfunc = item[3]
        if type(buyfunc) == "table" then
          buyfunc = function()
            OtherEvent.MainEvents.Modules:FireServer(unpack(item[3]))
          end
        end
        
        _Shop:AddButton({item[1], buyfunc, Desc = item[2]})
      end
    end
  end
  
  local _Misc = Tabs.Misc do
    _Misc:AddButton({"Nhận Tất Cả Mã", Funcs.RAllCodes})
    _Misc:AddSection("Cài Đặt")
    _Misc:AddSlider({"Khoảng Cách Farm", 5, 15, 1, 8, function(Value)
      Settings.FarmDistance = Value or 8
      Settings.FarmCFrame = CFrame_new(0, Value or 8, 0) * CFrame_Angles(math.rad(-90), 0, 0)
    end, "Farm Distance"})
    _Misc:AddToggle({"Tự Động Aura", Settings.AutoHaki, function(Value) Settings.AutoHaki = Value end, "Auto Haki"})
    _Misc:AddToggle({"Tự Động Tấn Công", Settings.AutoClick, function(Value) Settings.AutoClick = Value end, "Auto Attack"})
    _Misc:AddToggle({"Dẫn Mobs", Settings.BringMobs, function(Value) Settings.BringMobs = Value end, "Bring Mobs"})
    _Misc:AddToggle({"Chống AFK", Settings.AntiAFK, function(Value) Settings.AntiAFK = Value end, "Anti AFK"})
    _Misc:AddSection("Nhóm")
    _Misc:AddButton({"Tham Gia Nhóm Cheems", function()
      OtherEvent.MainEvents.Modules:FireServer("Change_Team", "Cheems Recruiter")
    end})
    _Misc:AddButton({"Tham Gia Nhóm Floppa", function()
      OtherEvent.MainEvents.Modules:FireServer("Change_Team", "Floppa Recruiter")
    end})
    _Misc:AddSection("Khác")
    _Misc:AddToggle({"Xóa Thông Báo", false, function(Value)
      Player.PlayerGui.AnnounceGui.Enabled = not Value
    end, "Remove Notifications"})
  end
  
  task.spawn(function()
    if not _env.AntiAfk then
      _env.AntiAfk = true
      
      while _wait(60*10) do
        if Settings.AntiAFK then
          VirtualUser:CaptureController()
          VirtualUser:ClickButton2(Vector2.new())
        end
      end
    end
  end)
  
