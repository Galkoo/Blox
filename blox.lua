-- blox fruits ladder farm // FIX 86 // real swan gate: TalkTrevor 1→2 + equip 1m+ fruit + TalkTrevor 1
-- built by olivia — https://discord.gg/ojailbreaks

local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local CoreGui=game:GetService("CoreGui")
local TweenService=game:GetService("TweenService")
local LP=Players.LocalPlayer

pcall(function() if _G.BF_STOP and type(_G.BF_STOP)=="function" then _G.BF_STOP() end end)
for _,n in ipairs({"BF_StopGui","BF_StatusGui"}) do
	pcall(function() local g=CoreGui:FindFirstChild(n); if g then g:Destroy() end end)
	pcall(function() local pg=LP:FindFirstChild("PlayerGui"); if pg then local g=pg:FindFirstChild(n); if g then g:Destroy() end end end)
end
_G.BF_RUN=false
task.wait(0.1)

local CFG={
	DEBUG=true,
	SEA2_ALREADY_UNLOCKED=false,
	SEA3_ALREADY_UNLOCKED=false,
	STATE_FOLDER="bf_seas",
	TRAVEL_SPEED=180,TRAVEL_STEP=0.04,ARRIVE_RADIUS=5,TRAVEL_TIMEOUT=60,
	GATE_TRAVEL_SPEED=400,GATE_TRAVEL_TIMEOUT=180,GATE_JUMP_DIST=1000,GATE_MAX_WAIT=15,GATE_SETTLE=1.0,LEAVE_GATE_WAIT=2.0,
	MOB_APPROACH_SPEED=500,MOB_APPROACH_STEP=0.015,MOB_APPROACH_ARRIVE=8,MOB_APPROACH_TIMEOUT=3.5,MOB_APPROACH_Y_PAD=2,MOB_LEAD_SECONDS=0.25,
	HOVER_HEIGHT=24,HOVER_LOOK=true,HIT_INTERVAL=0.12,MAX_RANGE=5000,CHARGE=1.0,COMBO_MAX=5,MOB_TIMEOUT=120,COMPLETION_GRACE=2.0,BOSS_CHECK_EVERY=2.0,TP_DELAY=0.05,
	HOVER_TWEEN_SPEED=500,HOVER_SNAP_RADIUS=6,RETRY_WINDOW=1.5,MAX_RETRIES=4,FIRST_HIT_WARMUP=0.05,STAY_IN_SKY=true,
	AUTO_BUSO=false,BUSO_CHECK_EVERY=0.4,BUSO_OFF_STREAK=1,BUSO_POST_FIRE_WAIT=0.3,BUSO_SPAWN_DELAY=0.5,HAKI_BUY_COOLDOWN=3.0,
	SHARK_CLEAN_EVERY=0.05,SHARK_CLEAN_RANGE=1000,STAT_CHUNK=500,BUY_COOLDOWN=3.0,
	BUY_LEGENDARY_SWORDS=true,TARGET_LEGENDARY_MASTERY=300,LEGENDARY_SCAN_EVERY=8.0,LEGENDARY_BUY_COOLDOWN=2.5,
	LEGENDARY_APPROACH_SPEED=220,LEGENDARY_APPROACH_STEP=0.03,LEGENDARY_APPROACH_ARRIVE=6,
	CURSED_SWORD_ENABLED=true,CURSED_SWORD_NAME="Midnight Blade",CURSED_SWORD_INDEX=3,CURSED_SWORD_COST=100,CURSED_ATTEMPT_COOLDOWN=3.0,
	EQUIP_COOLDOWN=8.0,
	SHIP_EXIT_LEVEL=1350,SHIP_EXIT_PORTAL=Vector3.new(919.6,125.1,32844.3),SHIP_EXIT_REQUEST_POS=Vector3.new(-6508.558,89.035,-132.84),
	SHIP_EXIT_PARK_HOLDS=25,SHIP_EXIT_WAIT_PER_TRY=3.0,SHIP_EXIT_MAX_TRIES=5,SHIP_Z_MIN=30000,SHIP_Z_MAX=35000,
	SHIP_EXIT_TRAVEL_SPEED=70,
	ICE_LEVEL=700,ICE_KEY_SPOT=Vector3.new(1297.3,23.6,-1353.5),ICE_MOB_NAME="Ice Admiral",ICE_WAIT=5,ICE_HOVER=50,
	DON_SWAN_LEVEL=1500,DON_SWAN_MOB_NAME="Don Swan",DON_SWAN_HOVER=50,
	DON_SWAN_ARENA_POS=Vector3.new(2288.7,15.2,863.7),
	DON_SWAN_ARENA_WAIT=1.5,DON_SWAN_TREVOR_WAITS=3,DON_SWAN_TREVOR_STEP=0.4,
	DON_SWAN_RESET_WAIT=5.0,
	Z_QUEST_WAIT=5.0,
	Z_QUEST_TP_WATCH=12.0,
	Z_QUEST_TP_THRESHOLD=100,
	RIP_INDRA_NAMES={"rip_indra","Rip_Indra","Rip Indra","RipIndra"},
	RIP_INDRA_HOVER=50,
	RIP_INDRA_CUTSCENE_WAIT=15.0,
	TRUE_TRIPLE_KATANA_NAME="True Triple Katana",
	PIRATE_TEAM_SETTLE_BOOT=2.0,PIRATE_TEAM_SETTLE_SEA=1.5,
}

local SHARK_HINTS={"shark","projectile","skill","hitbox","waterblade","water","wave","aura","aoe"}

local function userKey()
	local n=(LP.Name or "unknown"):lower():gsub("[^%w_]","_")
	return n
end
local function ensureStateFolder()
	if type(makefolder)~="function" then return end
	if type(isfolder)=="function" then
		local ok,exists=pcall(function() return isfolder(CFG.STATE_FOLDER) end)
		if ok and exists then return end
	end
	pcall(function() makefolder(CFG.STATE_FOLDER) end)
end
local function statePath()
	return CFG.STATE_FOLDER.."/bf_sea_state_"..userKey()..".txt"
end

local function loadSeaState()
	if type(isfile)~="function" or type(readfile)~="function" then return nil,nil end
	local path=statePath()
	local ok,exists=pcall(function() return isfile(path) end)
	if not ok or not exists then return nil,nil end
	local ok2,content=pcall(function() return readfile(path) end)
	if not ok2 or not content then return nil,nil end
	local s2=content:match("s2=(%a+)")
	local s3=content:match("s3=(%a+)")
	return s2=="true", s3=="true"
end

local function saveSeaState(s2,s3)
	if type(writefile)~="function" then return end
	ensureStateFolder()
	pcall(function() writefile(statePath(),("s2=%s\ns3=%s\n"):format(tostring(s2 and true or false),tostring(s3 and true or false))) end)
end

ensureStateFolder()

local function readSeaNumber()
	local d=LP:FindFirstChild("Data")
	if not d then return nil end
	local s=d:FindFirstChild("Sea")
	if not s or s.Value==nil then return nil end
	local n=tonumber(s.Value); if n then return n end
	if type(s.Value)=="string" then
		local z=s.Value:lower()
		if z:find("sea3",1,true) or z:find("zou",1,true) or z:find("third",1,true) then return 3 end
		if z:find("sea2",1,true) or z:find("dressrosa",1,true) or z:find("second",1,true) then return 2 end
		if z:find("sea1",1,true) or z:find("first",1,true) or z:find("starter",1,true) then return 1 end
	end
	return nil
end

local function inSecondSea()
	local n=readSeaNumber(); if n then return n==2 end
	local m=Workspace:FindFirstChild("Map")
	if m and (m:FindFirstChild("Dressrosa") or m:FindFirstChild("Kingdom Of Rose") or m:FindFirstChild("KingdomOfRose")) then return true end
	local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if h then local z=h.Position.Z; if z>CFG.SHIP_Z_MIN and z<CFG.SHIP_Z_MAX then return true end end
	return false
end

local function inThirdSea()
	local n=readSeaNumber(); if n then return n==3 end
	local m=Workspace:FindFirstChild("Map")
	if m and (m:FindFirstChild("Zou") or m:FindFirstChild("Haven") or m:FindFirstChild("Great Tree") or m:FindFirstChild("GreatTree") or m:FindFirstChild("HydraIsland") or m:FindFirstChild("Hydra Island")) then return true end
	return false
end

local BOOT_IN_SEA2=inSecondSea()
local BOOT_IN_SEA3=inThirdSea()
local LOADED_S2,LOADED_S3=loadSeaState()

local SEA2_UNLOCKED=CFG.SEA2_ALREADY_UNLOCKED or BOOT_IN_SEA2 or BOOT_IN_SEA3 or (LOADED_S2==true)
local SEA3_UNLOCKED=CFG.SEA3_ALREADY_UNLOCKED or BOOT_IN_SEA3 or (LOADED_S3==true)
saveSeaState(SEA2_UNLOCKED,SEA3_UNLOCKED)

local ISLANDS={
	{name="Starter Island (Bandits)",questGiver=Vector3.new(1052.2,14.7,1554.7),farmSpot=Vector3.new(1174.2,14.5,1616.1),questName="BanditQuest1",questTier=1,questMobs={"Bandit"},levelMin=1,levelMax=9},
	{name="Jungle (Monkeys)",questGiver=Vector3.new(-1685.4,50.1,173.8),farmSpot=Vector3.new(-1704.2,50.1,181.2),questName="JungleQuest",questTier=1,questMobs={"Monkey"},levelMin=10,levelMax=14},
	{name="Jungle (Gorillas)",questGiver=Vector3.new(-1685.4,50.1,173.8),farmSpot=Vector3.new(-1282.6,31.7,-601.7),questName="JungleQuest",questTier=2,questMobs={"Gorilla"},levelMin=15,levelMax=29},
	{name="Pirate Village (Pirates)",questGiver=Vector3.new(-1152.1,17.3,3859.0),farmSpot=Vector3.new(-1221.6,17.3,3962.1),questName="BuggyQuest1",questTier=1,questMobs={"Pirate"},levelMin=30,levelMax=39},
	{name="Pirate Village (Brutes)",questGiver=Vector3.new(-1152.1,17.3,3859.0),farmSpot=Vector3.new(-1233.8,34.0,4367.8),questName="BuggyQuest1",questTier=2,questMobs={"Brute"},levelMin=40,levelMax=59},
	{name="Desert (Desert Bandits)",questGiver=Vector3.new(918.2,5.9,4203.0),farmSpot=Vector3.new(925.8,5.9,4516.4),questName="DesertQuest",questTier=1,questMobs={"Desert Bandit"},levelMin=60,levelMax=74},
	{name="Desert (Desert Officers)",questGiver=Vector3.new(918.2,5.9,4203.0),farmSpot=Vector3.new(1526.6,13.8,4176.2),questName="DesertQuest",questTier=2,questMobs={"Desert Officer"},levelMin=75,levelMax=89},
	{name="Frozen Village (Snow Bandits)",questGiver=Vector3.new(1396.6,78.0,-1309.8),farmSpot=Vector3.new(1401.8,78.0,-1413.8),questName="SnowQuest",questTier=1,questMobs={"Snow Bandit"},levelMin=90,levelMax=99},
	{name="Frozen Village (Snowmen)",questGiver=Vector3.new(1396.6,78.0,-1309.8),farmSpot=Vector3.new(1200.3,97.8,-1509.0),questName="SnowQuest",questTier=2,questMobs={"Snowman"},levelMin=100,levelMax=119},
	{name="Marine Fortress (Chief Petty Officers)",questGiver=Vector3.new(-4697.9,5.9,4221.5),farmSpot=Vector3.new(-4779.5,14.2,4239.9),questName="MarineQuest2",questTier=1,questMobs={"Chief Petty Officer"},levelMin=120,levelMax=129},
	{name="Marine Fortress (Vice Admiral BOSS)",questGiver=Vector3.new(-4697.9,5.9,4221.5),farmSpot=Vector3.new(-4916.7,14.2,4329.4),questName="MarineQuest2",questTier=2,questMobs={"Vice Admiral"},levelMin=130,levelMax=149,bossMode=true,hoverOffset=50,farmDrop=50,respawnMarker="VICE ADMIRAL Respawn Marker",fallbackQuestName="MarineQuest2",fallbackQuestTier=1,fallbackMobs={"Chief Petty Officer"},fallbackFarmSpot=Vector3.new(-4779.5,14.2,4239.9)},
	{name="Skylands (Sky Bandits)",questGiver=Vector3.new(-5401.9,410.7,-698.0),farmSpot=Vector3.new(-5104.1,279.2,-968.7),questName="SkyQuest",questTier=1,questMobs={"Sky Bandit"},levelMin=150,levelMax=174},
	{name="Skylands (Dark Masters)",questGiver=Vector3.new(-5401.9,410.7,-698.0),farmSpot=Vector3.new(-5319.5,501.5,-397.7),questName="SkyQuest",questTier=2,questMobs={"Dark Master"},levelMin=175,levelMax=199},
	{name="Prison (Prisoners)",questGiver=Vector3.new(5200.6,19.6,736.2),farmSpot=Vector3.new(5283.8,10.4,461.0),questName="PrisonerQuest",questTier=1,questMobs={"Prisoner"},levelMin=200,levelMax=224},
	{name="Impel Down (Ruthless Prisoners)",questGiver=Vector3.new(5200.6,19.6,736.2),farmSpot=Vector3.new(5325.0,19.9,732.3),questName="ImpelQuest",questTier=1,questMobs={"Ruthless Prisoner"},levelMin=225,levelMax=249},
	{name="Colosseum (Toga Warriors)",questGiver=Vector3.new(-1344.6,12.5,-2924.9),farmSpot=Vector3.new(-1697.9,12.2,-2731.4),questName="ColosseumQuest",questTier=1,questMobs={"Toga Warrior"},levelMin=250,levelMax=299},
	{name="Magma Village (Military Soldiers)",questGiver=Vector3.new(-5312.3,18.5,8482.0),farmSpot=Vector3.new(-5403.2,16.1,8407.4),questName="MagmaQuest",questTier=1,questMobs={"Military Soldier"},levelMin=300,levelMax=324},
	{name="Magma Village (Military Spies)",questGiver=Vector3.new(-5312.3,18.5,8482.0),farmSpot=Vector3.new(-5848.7,77.3,8781.0),questName="MagmaQuest",questTier=2,questMobs={"Military Spy"},levelMin=325,levelMax=349,revisitOnEmpty=true},
	{name="Magma Village (Magma Admiral BOSS)",questGiver=Vector3.new(-5312.3,18.5,8482.0),farmSpot=Vector3.new(-5687.1,57.8,8720.0),questName="MagmaQuest",questTier=3,questMobs={"Magma Admiral"},levelMin=350,levelMax=374,bossMode=true,hoverOffset=50,farmDrop=50,respawnMarker="MAGMA ADMIRAL Respawn Marker",fallbackQuestName="MagmaQuest",fallbackQuestTier=1,fallbackMobs={"Military Soldier"},fallbackFarmSpot=Vector3.new(-5403.2,16.1,8407.4)},
	{name="Fishman Island (Fishman Warriors)",preTravel=Vector3.new(4041.4,-4.0,-1828.4),questGiver=Vector3.new(61403.1,24.9,1630.2),farmSpot=Vector3.new(60846.0,24.9,1424.0),questName="FishmanQuest",questTier=1,questMobs={"Fishman Warrior"},levelMin=375,levelMax=399},
	{name="Fishman Island (Fishman Commandos)",preTravel=Vector3.new(4041.4,-4.0,-1828.4),questGiver=Vector3.new(61403.1,24.9,1630.2),farmSpot=Vector3.new(61918.6,24.9,1351.9),questName="FishmanQuest",questTier=2,questMobs={"Fishman Commando"},levelMin=400,levelMax=424},
	{name="Fishman Island (Fishman Lord BOSS)",preTravel=Vector3.new(4041.4,-4.0,-1828.4),questGiver=Vector3.new(61403.1,24.9,1630.2),farmSpot=Vector3.new(61354.9,65.2,1217.7),questName="FishmanQuest",questTier=3,questMobs={"Fishman Lord"},levelMin=425,levelMax=449,bossMode=true,hoverOffset=50,farmDrop=50,respawnMarker="FISHMAN LORD Respawn Marker",fallbackQuestName="FishmanQuest",fallbackQuestTier=2,fallbackMobs={"Fishman Commando"},fallbackFarmSpot=Vector3.new(61918.6,24.9,1351.9)},
	{name="Sky Experiment (God's Guards)",questGiver=Vector3.new(-4313.4,1087.1,-557.0),farmSpot=Vector3.new(-4267.4,1089.6,-423.2),questName="SkyExp1Quest",questTier=1,questMobs={"God's Guard"},levelMin=450,levelMax=474},
	{name="Sky Experiment (Shandas)",questGiver=Vector3.new(-5954.2,5469.2,2083.7),farmSpot=Vector3.new(-5944.2,5469.2,1871.7),questName="SkyExp1Quest",questTier=2,questMobs={"Shanda"},levelMin=475,levelMax=499},
	{name="Sky Experiment (Wysper BOSS)",questGiver=Vector3.new(-5954.2,5469.2,2083.7),farmSpot=Vector3.new(-6150.9,5469.2,1899.6),questName="SkyExp1Quest",questTier=3,questMobs={"Wysper"},levelMin=500,levelMax=524,bossMode=true,hoverOffset=50,farmDrop=50,respawnMarker="WYSPER Respawn Marker",fallbackQuestName="SkyExp1Quest",fallbackQuestTier=2,fallbackMobs={"Shanda"},fallbackFarmSpot=Vector3.new(-5944.2,5469.2,1871.7)},
	{name="Sky Experiment 2 (Royal Squad)",questGiver=Vector3.new(-7012.9,5591.9,1371.6),farmSpot=Vector3.new(-6827.4,5549.5,1211.0),questName="SkyExp2Quest",questTier=1,questMobs={"Royal Squad"},levelMin=525,levelMax=549},
	{name="Sky Experiment 2 (Royal Soldiers)",questGiver=Vector3.new(-7012.9,5591.9,1371.6),farmSpot=Vector3.new(-7036.4,5540.6,957.9),questName="SkyExp2Quest",questTier=2,questMobs={"Royal Soldier"},levelMin=550,levelMax=574},
	{name="Sky Experiment 2 (Thunder God BOSS)",questGiver=Vector3.new(-7012.9,5591.9,1371.6),farmSpot=Vector3.new(-7106.6,5593.6,281.5),questName="SkyExp2Quest",questTier=3,questMobs={"Thunder God"},levelMin=575,levelMax=624,bossMode=true,hoverOffset=50,farmDrop=50,respawnMarker="THUNDER GOD Respawn Marker",fallbackQuestName="SkyExp2Quest",fallbackQuestTier=2,fallbackMobs={"Royal Soldier"},fallbackFarmSpot=Vector3.new(-7036.4,5540.6,957.9)},
	{name="Fountain City (Galley Pirates)",questGiver=Vector3.new(5260.9,76.1,4086.0),farmSpot=Vector3.new(5528.7,71.1,3994.6),questName="FountainQuest",questTier=1,questMobs={"Galley Pirate"},levelMin=625,levelMax=649},
	{name="Fountain City (Galley Captains)",questGiver=Vector3.new(5260.9,76.1,4086.0),farmSpot=Vector3.new(5658.5,71.1,4825.0),questName="FountainQuest",questTier=2,questMobs={"Galley Captain"},levelMin=650,levelMax=674},
	{name="Fountain City (Cyborg BOSS)",questGiver=Vector3.new(5260.9,76.1,4086.0),farmSpot=Vector3.new(6199.3,22.2,4864.0),questName="FountainQuest",questTier=3,questMobs={"Cyborg"},levelMin=675,levelMax=699,bossMode=true,hoverOffset=50,farmDrop=50,respawnMarker="CYBORG Respawn Marker",fallbackQuestName="FountainQuest",fallbackQuestTier=2,fallbackMobs={"Galley Captain"},fallbackFarmSpot=Vector3.new(5658.5,71.1,4825.0)},
	{name="Area 1 (Raiders)",questGiver=Vector3.new(-422.0,73.0,1838.5),farmSpot=Vector3.new(-723.1,39.2,2372.9),questName="Area1Quest",questTier=1,questMobs={"Raider"},levelMin=700,levelMax=724,sea=2},
	{name="Area 1 (Mercenaries)",questGiver=Vector3.new(-422.0,73.0,1838.5),farmSpot=Vector3.new(-1037.6,73.0,1424.8),questName="Area1Quest",questTier=2,questMobs={"Mercenary"},levelMin=725,levelMax=749,sea=2},
	{name="Area 1 (Diamond BOSS)",questGiver=Vector3.new(-422.0,73.0,1838.5),farmSpot=Vector3.new(-1575.4,198.6,69.6),questName="Area1Quest",questTier=3,questMobs={"Diamond"},levelMin=750,levelMax=774,sea=2,bossMode=true,hoverOffset=50,farmDrop=50,respawnMarker="DIAMOND Respawn Marker",fallbackQuestName="Area1Quest",fallbackQuestTier=2,fallbackMobs={"Mercenary"},fallbackFarmSpot=Vector3.new(-1037.6,73.0,1424.8)},
	{name="Area 2 (Swan Pirates)",questGiver=Vector3.new(630.1,73.1,918.5),farmSpot=Vector3.new(1008.2,73.1,1245.3),questName="Area2Quest",questTier=1,questMobs={"Swan Pirate"},levelMin=775,levelMax=849,sea=2},
	{name="Area 2 (Jeremy BOSS)",questGiver=Vector3.new(630.1,73.1,918.5),farmSpot=Vector3.new(2134.1,449.0,753.1),questName="Area2Quest",questTier=3,questMobs={"Jeremy"},levelMin=850,levelMax=874,sea=2,bossMode=true,hoverOffset=50,farmDrop=50,respawnMarker="JEREMY Respawn Marker",fallbackQuestName="Area2Quest",fallbackQuestTier=1,fallbackMobs={"Swan Pirate"},fallbackFarmSpot=Vector3.new(1008.2,73.1,1245.3)},
	{name="Green Zone (Marine Lieutenants)",questGiver=Vector3.new(-2446.1,73.0,-3219.3),farmSpot=Vector3.new(-2803.4,73.0,-3004.3),questName="MarineQuest3",questTier=1,questMobs={"Marine Lieutenant"},levelMin=875,levelMax=899,sea=2},
	{name="Green Zone (Marine Captains)",questGiver=Vector3.new(-2446.1,73.0,-3219.3),farmSpot=Vector3.new(-1914.1,73.0,-3357.6),questName="MarineQuest3",questTier=2,questMobs={"Marine Captain"},levelMin=900,levelMax=924,sea=2},
	{name="Green Zone (Orbitus BOSS)",questGiver=Vector3.new(-2446.1,73.0,-3219.3),farmSpot=Vector3.new(-2197.3,73.0,-4142.5),questName="MarineQuest3",questTier=3,questMobs={"Orbitus"},levelMin=925,levelMax=949,sea=2,bossMode=true,hoverOffset=50,farmDrop=50,respawnMarker="ORBITUS Respawn Marker",fallbackQuestName="MarineQuest3",fallbackQuestTier=2,fallbackMobs={"Marine Captain"},fallbackFarmSpot=Vector3.new(-1914.1,73.0,-3357.6)},
	{name="Hot & Cold (Zombies)",questGiver=Vector3.new(-5491.5,48.5,-790.1),farmSpot=Vector3.new(-5735.3,48.5,-888.0),questName="ZombieQuest",questTier=1,questMobs={"Zombie"},levelMin=950,levelMax=974,sea=2},
	{name="Hot & Cold (Vampires)",questGiver=Vector3.new(-5491.5,48.5,-790.1),farmSpot=Vector3.new(-6023.2,6.4,-1296.6),questName="ZombieQuest",questTier=2,questMobs={"Vampire"},levelMin=975,levelMax=999,sea=2},
	{name="Snow Mountain (Snow Troopers)",questGiver=Vector3.new(603.2,401.5,-5369.6),farmSpot=Vector3.new(584.2,401.5,-5526.5),questName="SnowMountainQuest",questTier=1,questMobs={"SnowTrooper","Snow Trooper"},levelMin=1000,levelMax=1049,sea=2},
	{name="Snow Mountain (Winter Warriors)",questGiver=Vector3.new(603.2,401.5,-5369.6),farmSpot=Vector3.new(1148.5,429.5,-5274.2),questName="SnowMountainQuest",questTier=2,questMobs={"WinterWarrior","Winter Warrior"},levelMin=1050,levelMax=1099,sea=2},
	{name="Ice Side (Lab Subordinates)",questGiver=Vector3.new(-6225.4,81.9,-4855.6),farmSpot=Vector3.new(-5780.7,81.9,-4433.1),questName="IceSideQuest",questTier=1,questMobs={"LabSubordinate","Lab Subordinate"},levelMin=1100,levelMax=1124,sea=2},
	{name="Ice Side (Horned Warriors)",questGiver=Vector3.new(-6225.4,81.9,-4855.6),farmSpot=Vector3.new(-6426.5,29.2,-5726.0),questName="IceSideQuest",questTier=2,questMobs={"HornedWarrior","Horned Warrior"},levelMin=1125,levelMax=1149,sea=2},
	{name="Ice Side (Smoke Admiral BOSS)",questGiver=Vector3.new(-6225.4,81.9,-4855.6),farmSpot=Vector3.new(-4905.2,233.1,-5479.3),questName="IceSideQuest",questTier=3,questMobs={"SmokeAdmiral","Smoke Admiral"},levelMin=1150,levelMax=1174,sea=2,bossMode=true,hoverOffset=50,farmDrop=50,respawnMarker="SMOKE ADMIRAL Respawn Marker",fallbackQuestName="IceSideQuest",fallbackQuestTier=2,fallbackMobs={"HornedWarrior","Horned Warrior"},fallbackFarmSpot=Vector3.new(-6426.5,29.2,-5726.0)},
	{name="Fire Side (Magma Ninjas)",questGiver=Vector3.new(-5404.0,29.2,-5365.9),farmSpot=Vector3.new(-5733.0,29.2,-5523.5),questName="FireSideQuest",questTier=1,questMobs={"MagmaNinja","Magma Ninja"},levelMin=1175,levelMax=1199,sea=2},
	{name="Fire Side (Lava Pirates)",questGiver=Vector3.new(-5404.0,29.2,-5365.9),farmSpot=Vector3.new(-5118.9,29.2,-4971.9),questName="FireSideQuest",questTier=2,questMobs={"LavaPirate","Lava Pirate"},levelMin=1200,levelMax=1249,sea=2},
	{name="Ship (Deckhands)",preTravel=Vector3.new(-6496.9,89.0,-116.5),questGiver=Vector3.new(1028.9,125.1,32909.2),farmSpot=Vector3.new(1180.1,125.8,33022.7),questName="ShipQuest1",questTier=1,questMobs={"ShipDeckhand","Ship Deckhand","Deckhand"},levelMin=1250,levelMax=1274,sea=2},
	{name="Ship (Engineers)",preTravel=Vector3.new(-6496.9,89.0,-116.5),questGiver=Vector3.new(1028.9,125.1,32909.2),farmSpot=Vector3.new(921.8,40.1,32752.6),questName="ShipQuest1",questTier=2,questMobs={"ShipEngineer","Ship Engineer"},levelMin=1275,levelMax=1299,sea=2},
	{name="Ship (Stewards)",preTravel=Vector3.new(-6496.9,89.0,-116.5),questGiver=Vector3.new(972.4,125.1,33244.0),farmSpot=Vector3.new(921.3,129.6,33439.2),questName="ShipQuest2",questTier=1,questMobs={"ShipSteward","Ship Steward"},levelMin=1300,levelMax=1324,sea=2},
	{name="Ship (Officers)",preTravel=Vector3.new(-6496.9,89.0,-116.5),questGiver=Vector3.new(972.4,125.1,33244.0),farmSpot=Vector3.new(907.1,181.1,33335.1),questName="ShipQuest2",questTier=2,questMobs={"ShipOfficer","Ship Officer"},levelMin=1325,levelMax=1349,sea=2},
	{name="Frost (Arctic Warriors)",questGiver=Vector3.new(5668.9,28.2,-6478.7),farmSpot=Vector3.new(5994.0,28.4,-6245.3),questName="FrostQuest",questTier=1,questMobs={"ArcticWarrior","Arctic Warrior"},levelMin=1350,levelMax=1374,sea=2},
	{name="Frost (Snow Lurkers)",questGiver=Vector3.new(5668.9,28.2,-6478.7),farmSpot=Vector3.new(5569.1,28.2,-6775.2),questName="FrostQuest",questTier=2,questMobs={"SnowLurker","Snow Lurker"},levelMin=1375,levelMax=1399,sea=2},
	{name="Frost (Awakened Ice Admiral BOSS)",questGiver=Vector3.new(5668.9,28.2,-6478.7),farmSpot=Vector3.new(6407.7,296.7,-6898.9),questName="FrostQuest",questTier=3,questMobs={"AwakenedIceAdmiral","Awakened Ice Admiral"},levelMin=1400,levelMax=1424,sea=2,bossMode=true,hoverOffset=50,farmDrop=50,respawnMarker="AWAKENED ICE ADMIRAL Respawn Marker",fallbackQuestName="FrostQuest",fallbackQuestTier=2,fallbackMobs={"SnowLurker","Snow Lurker"},fallbackFarmSpot=Vector3.new(5569.1,28.2,-6775.2)},
	{name="Forgotten (Sea Soldiers)",questGiver=Vector3.new(-3049.9,239.7,-10142.9),farmSpot=Vector3.new(-3367.8,27.0,-9770.1),questName="ForgottenQuest",questTier=1,questMobs={"SeaSoldier","Sea Soldier"},levelMin=1425,levelMax=1449,sea=2},
	{name="Forgotten (Water Fighters)",questGiver=Vector3.new(-3049.9,239.7,-10142.9),farmSpot=Vector3.new(-3397.1,238.9,-10519.9),questName="ForgottenQuest",questTier=2,questMobs={"WaterFighter","Water Fighter"},levelMin=1450,levelMax=1474,sea=2},
	{name="Forgotten (Tide Keeper BOSS)",questGiver=Vector3.new(-3049.9,239.7,-10142.9),farmSpot=Vector3.new(-3691.0,77.3,-11403.9),questName="ForgottenQuest",questTier=3,questMobs={"TideKeeper","Tide Keeper"},levelMin=1475,levelMax=1499,sea=2,bossMode=true,hoverOffset=50,farmDrop=50,respawnMarker="TIDE KEEPER Respawn Marker",fallbackQuestName="ForgottenQuest",fallbackQuestTier=1,fallbackMobs={"SeaSoldier","Sea Soldier"},fallbackFarmSpot=Vector3.new(-3367.8,27.0,-9770.1)},
}

local iceQuestDone=SEA2_UNLOCKED
local shipExited,shipExiting=SEA3_UNLOCKED,false
local donSwanDone,donSwanBusy=SEA3_UNLOCKED,false
local zQuestBusy=false
local _ripIndraDone=SEA3_UNLOCKED
local trevorAccessGranted=SEA3_UNLOCKED

local MOB_SKIP={{pos=Vector3.new(5077.66,14.75,451.23),radius=20,mobs={Prisoner=true}}}
local function isInSkipZone(mob,part)
	if not mob or not part then return false end
	local nm=mob.Name; if not nm then return false end
	local p=part.Position
	for _,z in ipairs(MOB_SKIP) do if z.mobs[nm] and (p-z.pos).Magnitude<=z.radius then return true end end
	return false
end

local HAKI_SHOP={{ability="Buso",cost=25000},{ability="Geppo",cost=10000}}
local STAT_PLAN={{name="Sword",cap=2500},{name="Defense",cap=1000},{name="Melee",cap=1000}}
local SHOP={
	{name="Katana",cost=1000,level=1},{name="Iron Mace",cost=25000,level=25},
	{name="Dual Katana",cost=12000,level=125},{name="Bisento",cost=1000000,level=120},
	{name="Pipe",cost=100000,level=150},{name="Dual-Headed Blade",cost=400000,level=125},
	{name="Soul Cane",cost=750000,level=525},
}
local LEGENDARY_SWORDS={{name="Saddi",price=2000000},{name="Shisui",price=2000000},{name="Wando",price=2000000}}
local RANK_ORDER={
	"True Triple Katana","Saddi","Shisui","Wando",
	"Canvander","Midnight Blade","Buddy Sword","Dragon Trident","Soul Cane",
	"Pole (1st Form)","Dual-Headed Blade","Bisento","Jitte","Dual Katana",
	"Pipe","Triple Katana","Iron Mace","Saber","Katana","Cutlass","Combat",
}
local RANK={}
for i,n in ipairs(RANK_ORDER) do RANK[n]=(#RANK_ORDER-i+1)*10 end
local DEALER_NAMES={["Legendary Sword Dealer"]=true,LegendarySwordDealer=true}

local LADDER_MAX_LEVEL=0
for _,i in ipairs(ISLANDS) do if i.levelMax and i.levelMax>LADDER_MAX_LEVEL then LADDER_MAX_LEVEL=i.levelMax end end

_G.BF_RUN=true
local conns={}
local hoverConn,noClipConn,bossLockConn,playerPlatformConn
local travelling=false
local savedCollide={}
local playerPlatformOn=false
local lastEquipTime=0

local function isRun() return _G.BF_RUN==true end
local function trackConn(c) table.insert(conns,c); return c end
local function myChar() return LP.Character end
local function myHRP() local c=myChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function myHum() local c=myChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function amAlive() local h=myHum(); return h and h.Health>0 end

local function restoreCollide()
	local c=LP.Character; if not c then return end
	for part,val in pairs(savedCollide) do if part and part.Parent then pcall(function() part.CanCollide=val end) end end
	table.clear(savedCollide)
end

local function setPlayerPlatformStand(on)
	playerPlatformOn=on and true or false
	local h=myHum(); if not h then return end
	pcall(function() h.PlatformStand=playerPlatformOn end)
end

local statusLabels={}
local statusGui=nil
local activePulseDot=nil
local iceStageText,donSwanStageText,legendaryStageText=nil,nil,nil

local function fullStop()
	if not isRun() then return end
	_G.BF_RUN=false
	setPlayerPlatformStand(false)
	for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	table.clear(conns)
	for _,cn in ipairs({hoverConn,noClipConn,bossLockConn,playerPlatformConn}) do if cn then pcall(function() cn:Disconnect() end) end end
	hoverConn,noClipConn,bossLockConn,playerPlatformConn=nil,nil,nil,nil
	restoreCollide()
	local c=LP.Character
	if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide=true end) end end end
	for _,nm in ipairs({"BF_StopGui","BF_StatusGui"}) do
		pcall(function() local g=CoreGui:FindFirstChild(nm); if g then g:Destroy() end end)
		pcall(function() local pg=LP:FindFirstChild("PlayerGui"); if pg then local g=pg:FindFirstChild(nm); if g then g:Destroy() end end end)
	end
	print("[ladder] *** STOPPED ***")
end
_G.BF_STOP=fullStop

do
	local function corn(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o end
	local function strk(o,c,t,tr) local s=Instance.new("UIStroke"); s.Color=c or Color3.fromRGB(255,255,255); s.Thickness=t or 1; s.Transparency=tr or 0; s.Parent=o; return s end
	local function cap(l,mx,mn) local c=Instance.new("UITextSizeConstraint"); c.MaxTextSize=mx or 24; c.MinTextSize=mn or 10; c.Parent=l end
	local function pad(o,l,r,t,b) local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,l or 0); p.PaddingRight=UDim.new(0,r or 0); p.PaddingTop=UDim.new(0,t or 0); p.PaddingBottom=UDim.new(0,b or 0); p.Parent=o end
	local function card(parent,pos,size,txt,a,b)
		local c=Instance.new("Frame"); c.Size=size; c.Position=pos; c.BackgroundColor3=Color3.fromRGB(20,22,38); c.BorderSizePixel=0; c.ZIndex=4; c.Parent=parent
		corn(c,14)
		local g=Instance.new("UIGradient"); g.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(28,30,54)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,16,32))}; g.Rotation=120; g.Parent=c
		strk(c,a,1,0.5)
		local ac=Instance.new("Frame"); ac.Size=UDim2.new(0,4,1,-16); ac.Position=UDim2.new(0,8,0,8); ac.BackgroundColor3=a; ac.BorderSizePixel=0; ac.ZIndex=5; ac.Parent=c
		corn(ac,2)
		local ag=Instance.new("UIGradient"); ag.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,a),ColorSequenceKeypoint.new(1,b)}; ag.Rotation=90; ag.Parent=ac
		local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-28,0,0); lbl.AutomaticSize=Enum.AutomaticSize.Y; lbl.Position=UDim2.new(0,22,0,10); lbl.BackgroundTransparency=1
		lbl.Text=txt:upper(); lbl.TextColor3=a; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5; lbl.Parent=c
		local val=Instance.new("TextLabel"); val.Size=UDim2.new(1,-28,1,-36); val.Position=UDim2.new(0,22,0,26); val.BackgroundTransparency=1; val.Text="—"
		val.TextColor3=Color3.fromRGB(245,245,255); val.Font=Enum.Font.GothamSemibold; val.TextScaled=true
		val.TextXAlignment=Enum.TextXAlignment.Left; val.TextYAlignment=Enum.TextYAlignment.Center; val.TextWrapped=true; val.ZIndex=5; val.Parent=c
		cap(val,26,10); return val
	end
	local gui=Instance.new("ScreenGui"); gui.Name="BF_StatusGui"; gui.ResetOnSpawn=false; gui.DisplayOrder=999998; gui.IgnoreGuiInset=true
	if not pcall(function() gui.Parent=CoreGui end) then gui.Parent=LP:WaitForChild("PlayerGui") end
	statusGui=gui
	local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,1,0); f.Position=UDim2.new(0,0,0,0)
	f.BackgroundColor3=Color3.fromRGB(10,12,24); f.BorderSizePixel=0; f.ZIndex=2; f.Parent=gui
	local bg=Instance.new("UIGradient"); bg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(28,20,54)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(12,14,32)),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,8,18))}; bg.Rotation=135; bg.Parent=f
	local co=Instance.new("Frame"); co.Size=UDim2.new(1,0,1,0); co.BackgroundTransparency=1; co.ZIndex=3; co.Parent=f
	pad(co,24,24,20,20)
	local hd=Instance.new("Frame"); hd.Size=UDim2.new(1,0,0.10,0); hd.BackgroundTransparency=1; hd.ZIndex=4; hd.Parent=co
	local logo=Instance.new("Frame"); logo.Size=UDim2.new(0,0,1,-8); logo.Position=UDim2.new(0,0,0,4); logo.BackgroundColor3=Color3.fromRGB(255,70,110); logo.BorderSizePixel=0; logo.ZIndex=5; logo.Parent=hd
	local ar=Instance.new("UIAspectRatioConstraint"); ar.AspectRatio=1; ar.Parent=logo
	corn(logo,10); strk(logo,Color3.fromRGB(255,255,255),1,0.7)
	local lg=Instance.new("UIGradient"); lg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,120,180)),ColorSequenceKeypoint.new(1,Color3.fromRGB(140,60,255))}; lg.Rotation=135; lg.Parent=logo
	local lt=Instance.new("TextLabel"); lt.Size=UDim2.new(1,0,1,0); lt.BackgroundTransparency=1; lt.Text="BF"; lt.TextColor3=Color3.fromRGB(255,255,255); lt.Font=Enum.Font.GothamBlack; lt.TextScaled=true; lt.ZIndex=6; lt.Parent=logo
	cap(lt,32,10); pad(lt,4,4,4,4)
	local tt=Instance.new("TextLabel"); tt.Size=UDim2.new(0.5,0,1,0); tt.BackgroundTransparency=1; tt.Text="LADDER FARM"
	tt.TextColor3=Color3.fromRGB(255,255,255); tt.TextXAlignment=Enum.TextXAlignment.Left; tt.TextYAlignment=Enum.TextYAlignment.Center
	tt.Font=Enum.Font.GothamBlack; tt.TextScaled=true; tt.ZIndex=5; tt.Parent=hd
	cap(tt,38,14)
	local tg=Instance.new("UIGradient"); tg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,180,230)),ColorSequenceKeypoint.new(1,Color3.fromRGB(140,220,255))}; tg.Parent=tt
	local tp=Instance.new("UIPadding"); tp.PaddingLeft=UDim.new(0,60); tp.Parent=tt
	local chip=Instance.new("Frame"); chip.AnchorPoint=Vector2.new(1,0.5); chip.Size=UDim2.new(0,110,0,26); chip.Position=UDim2.new(1,0,0.5,0)
	chip.BackgroundColor3=Color3.fromRGB(30,40,30); chip.BorderSizePixel=0; chip.ZIndex=5; chip.Parent=hd
	corn(chip,13); strk(chip,Color3.fromRGB(80,220,120),1,0.3)
	local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,10,0,10); dot.Position=UDim2.new(0,10,0.5,-5)
	dot.BackgroundColor3=Color3.fromRGB(80,255,140); dot.BorderSizePixel=0; dot.ZIndex=6; dot.Parent=chip
	corn(dot,999); activePulseDot=dot
	local ct=Instance.new("TextLabel"); ct.Size=UDim2.new(1,-28,1,0); ct.Position=UDim2.new(0,26,0,0); ct.BackgroundTransparency=1; ct.Text="ACTIVE"
	ct.TextColor3=Color3.fromRGB(80,255,140); ct.Font=Enum.Font.GothamBold; ct.TextSize=12; ct.TextXAlignment=Enum.TextXAlignment.Left; ct.ZIndex=6; ct.Parent=chip
	local hero=Instance.new("Frame"); hero.Size=UDim2.new(0.56,-8,0.45,0); hero.Position=UDim2.new(0,0,0.12,0)
	hero.BackgroundColor3=Color3.fromRGB(16,18,36); hero.BorderSizePixel=0; hero.ZIndex=4; hero.Parent=co
	corn(hero,16)
	local hg=Instance.new("UIGradient"); hg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(40,24,70)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(20,20,44)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,12,28))}; hg.Rotation=135; hg.Parent=hero
	strk(hero,Color3.fromRGB(255,120,200),1,0.3)
	local lm=Instance.new("TextLabel"); lm.Size=UDim2.new(1,-40,0,16); lm.Position=UDim2.new(0,24,0,18); lm.BackgroundTransparency=1
	lm.Text="LEVEL"; lm.TextColor3=Color3.fromRGB(255,160,220); lm.Font=Enum.Font.GothamBold; lm.TextSize=13; lm.TextXAlignment=Enum.TextXAlignment.Left; lm.ZIndex=5; lm.Parent=hero
	local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-40,0.55,0); lb.Position=UDim2.new(0,24,0,30); lb.BackgroundTransparency=1; lb.Text="—"
	lb.TextColor3=Color3.fromRGB(255,255,255); lb.Font=Enum.Font.GothamBlack; lb.TextScaled=true
	lb.TextXAlignment=Enum.TextXAlignment.Left; lb.TextYAlignment=Enum.TextYAlignment.Center; lb.ZIndex=5; lb.Parent=hero
	cap(lb,120,24)
	local lg2=Instance.new("UIGradient"); lg2.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,200,240)),ColorSequenceKeypoint.new(1,Color3.fromRGB(140,200,255))}; lg2.Rotation=90; lg2.Parent=lb
	statusLabels.lvl=lb
	local im=Instance.new("TextLabel"); im.Size=UDim2.new(1,-40,0,14); im.Position=UDim2.new(0,24,0.72,0); im.BackgroundTransparency=1
	im.Text="ISLAND"; im.TextColor3=Color3.fromRGB(140,200,255); im.Font=Enum.Font.GothamBold; im.TextSize=11; im.TextXAlignment=Enum.TextXAlignment.Left; im.ZIndex=5; im.Parent=hero
	local ib=Instance.new("TextLabel"); ib.Size=UDim2.new(1,-48,0.2,0); ib.Position=UDim2.new(0,24,0.78,0); ib.BackgroundTransparency=1; ib.Text="—"
	ib.TextColor3=Color3.fromRGB(230,230,240); ib.Font=Enum.Font.GothamSemibold; ib.TextScaled=true
	ib.TextXAlignment=Enum.TextXAlignment.Left; ib.TextYAlignment=Enum.TextYAlignment.Top; ib.TextWrapped=true; ib.ZIndex=5; ib.Parent=hero
	cap(ib,24,10); statusLabels.island=ib
	statusLabels.mode=card(co,UDim2.new(0.58,0,0.12,0),UDim2.new(0.42,0,0.215,0),"Mode",Color3.fromRGB(255,100,150),Color3.fromRGB(200,60,180))
	statusLabels.range=card(co,UDim2.new(0.58,0,0.345,0),UDim2.new(0.42,0,0.215,0),"Range",Color3.fromRGB(120,200,255),Color3.fromRGB(80,140,220))
	statusLabels.quest=card(co,UDim2.new(0,0,0.59,0),UDim2.new(0.5,-6,0.17,0),"Quest",Color3.fromRGB(140,230,120),Color3.fromRGB(60,180,100))
	statusLabels.next_=card(co,UDim2.new(0.5,6,0.59,0),UDim2.new(0.5,-6,0.17,0),"Next",Color3.fromRGB(180,160,255),Color3.fromRGB(120,100,240))
	local lgF=Instance.new("Frame"); lgF.Size=UDim2.new(1,0,0.12,0); lgF.Position=UDim2.new(0,0,0.78,0)
	lgF.BackgroundColor3=Color3.fromRGB(22,20,40); lgF.BorderSizePixel=0; lgF.ZIndex=4; lgF.Parent=co
	corn(lgF,12); strk(lgF,Color3.fromRGB(255,220,90),1,0.5)
	local lgm=Instance.new("TextLabel"); lgm.Size=UDim2.new(0,70,1,0); lgm.Position=UDim2.new(0,16,0,0); lgm.BackgroundTransparency=1
	lgm.Text="LEGENDARY"; lgm.TextColor3=Color3.fromRGB(255,220,90); lgm.Font=Enum.Font.GothamBold; lgm.TextSize=11; lgm.TextXAlignment=Enum.TextXAlignment.Left; lgm.ZIndex=5; lgm.Parent=lgF
	local lgv=Instance.new("TextLabel"); lgv.Size=UDim2.new(1,-110,1,-8); lgv.Position=UDim2.new(0,96,0,4); lgv.BackgroundTransparency=1; lgv.Text="—"
	lgv.TextColor3=Color3.fromRGB(255,240,180); lgv.Font=Enum.Font.GothamSemibold; lgv.TextScaled=true
	lgv.TextXAlignment=Enum.TextXAlignment.Left; lgv.TextYAlignment=Enum.TextYAlignment.Center; lgv.ZIndex=5; lgv.Parent=lgF
	cap(lgv,18,9); statusLabels.legend=lgv
	local ft=Instance.new("Frame"); ft.Size=UDim2.new(1,0,0.08,0); ft.Position=UDim2.new(0,0,0.91,0); ft.BackgroundTransparency=1; ft.ZIndex=4; ft.Parent=co
	local br=Instance.new("TextLabel"); br.Size=UDim2.new(1,0,1,0); br.BackgroundTransparency=1
	br.Text="built by olivia  ·  discord.gg/ojailbreaks"
	br.TextColor3=Color3.fromRGB(160,150,200); br.Font=Enum.Font.GothamSemibold; br.TextScaled=true
	br.TextXAlignment=Enum.TextXAlignment.Center; br.ZIndex=5; br.Parent=ft
	cap(br,14,8)
end

task.spawn(function()
	local t0=os.clock()
	while task.wait(0.03) do
		if not isRun() then break end
		if activePulseDot and activePulseDot.Parent then
			local p=(math.sin((os.clock()-t0)*3.5)+1)*0.5
			pcall(function()
				activePulseDot.BackgroundTransparency=0.1+p*0.5
				activePulseDot.Size=UDim2.new(0,10+p*4,0,10+p*4)
				activePulseDot.Position=UDim2.new(0,10-p*2,0.5,-5-p*2)
			end)
		end
	end
end)

do
	local function corn(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o end
	local function strk(o,c,t,tr) local s=Instance.new("UIStroke"); s.Color=c; s.Thickness=t; s.Transparency=tr; s.Parent=o; return s end
	local function btn(parent,y,txt,a,b,hA,icon)
		local b1=Instance.new("TextButton"); b1.AutoButtonColor=false; b1.Size=UDim2.new(0,160,0,48); b1.Position=UDim2.new(1,-176,0,y)
		b1.BackgroundColor3=a; b1.BorderSizePixel=0; b1.Text=""; b1.Parent=parent
		corn(b1,12)
		local g=Instance.new("UIGradient"); g.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,a),ColorSequenceKeypoint.new(1,b)}; g.Rotation=135; g.Parent=b1
		local st=strk(b1,Color3.fromRGB(255,255,255),1,0.5)
		local ic=Instance.new("TextLabel"); ic.Size=UDim2.new(0,36,1,0); ic.Position=UDim2.new(0,10,0,0); ic.BackgroundTransparency=1
		ic.Text=icon; ic.TextColor3=Color3.fromRGB(255,255,255); ic.Font=Enum.Font.GothamBlack; ic.TextScaled=true; ic.Parent=b1
		local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-52,1,0); lbl.Position=UDim2.new(0,48,0,0); lbl.BackgroundTransparency=1
		lbl.Text=txt; lbl.TextColor3=Color3.fromRGB(255,255,255); lbl.Font=Enum.Font.GothamBold; lbl.TextSize=15; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=b1
		b1.MouseEnter:Connect(function() TweenService:Create(b1,TweenInfo.new(0.12),{BackgroundColor3=hA}):Play(); st.Transparency=0.2 end)
		b1.MouseLeave:Connect(function() TweenService:Create(b1,TweenInfo.new(0.15),{BackgroundColor3=a}):Play(); st.Transparency=0.5 end)
		return b1,lbl,g
	end
	local gui=Instance.new("ScreenGui"); gui.Name="BF_StopGui"; gui.ResetOnSpawn=false; gui.DisplayOrder=999999
	if not pcall(function() gui.Parent=CoreGui end) then gui.Parent=LP:WaitForChild("PlayerGui") end
	local sb=btn(gui,20,"STOP FARM",Color3.fromRGB(230,50,80),Color3.fromRGB(170,20,50),Color3.fromRGB(255,80,110),"x")
	sb.MouseButton1Click:Connect(fullStop); sb.TouchTap:Connect(fullStop)
	local hb,hl,hg=btn(gui,80,"HIDE STATUS",Color3.fromRGB(100,90,220),Color3.fromRGB(70,50,180),Color3.fromRGB(140,120,255),"o")
	local shown=true
	local function tog()
		shown=not shown
		if statusGui then pcall(function() statusGui.Enabled=shown end) end
		hl.Text=shown and "HIDE STATUS" or "SHOW STATUS"
		if shown then hg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(100,90,220)),ColorSequenceKeypoint.new(1,Color3.fromRGB(70,50,180))}
		else hg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(80,200,120)),ColorSequenceKeypoint.new(1,Color3.fromRGB(40,150,90))} end
	end
	hb.MouseButton1Click:Connect(tog); hb.TouchTap:Connect(tog)
end

trackConn(UIS.InputBegan:Connect(function(input)
	if input.KeyCode==Enum.KeyCode.F6 or input.KeyCode==Enum.KeyCode.F7 then fullStop() end
end))

local Net=RS:WaitForChild("Modules"):WaitForChild("Net")
local RE_Hit=Net:WaitForChild("RE/RegisterHit")
local RE_Atk=Net:WaitForChild("RE/RegisterAttack")
local CommF=RS:WaitForChild("Remotes"):WaitForChild("CommF_")

task.spawn(function()
	task.wait(0.3)
	local an=Net:FindFirstChild("RE/OnAnalyticsActivity")
	local cs=RS:WaitForChild("Remotes"):FindFirstChild("ChangeSetting")
	if an then pcall(function() an:FireServer("HUD/Button/Settings/ReduceMotion") end) end
	if cs then pcall(function() cs:FireServer("CameraShake",false) end) end
	if an then
		pcall(function() an:FireServer("HUD/Button/Settings/DisableAllyEffects") end)
		pcall(function() an:FireServer("HUD/Button/Settings/DisableAllyEffects") end)
		pcall(function() an:FireServer("HUD/Button/Mute") end)
	end
end)

local function hasTeamAlready()
	local d=LP:FindFirstChild("Data")
	if d then
		local t=d:FindFirstChild("Team")
		if t and t.Value~=nil then
			if type(t.Value)=="string" then return t.Value~="" end
			return t.Value~=nil
		end
	end
	for _,tn in ipairs({"Pirates","Marines"}) do
		local team=game:GetService("Teams") and game:GetService("Teams"):FindFirstChild(tn)
		if team then for _,pl in ipairs(team:GetPlayers()) do if pl==LP then return true end end end
	end
	if LP.Team~=nil then return true end
	return false
end

do
	local last=0
	local function pick()
		if hasTeamAlready() then return end
		if os.clock()-last<0.5 then return end
		last=os.clock()
		pcall(function() CommF:InvokeServer("SetTeam","Pirates") end)
		task.wait(0.25); pcall(function() CommF:InvokeServer("SetTeam","Pirate") end)
		task.wait(0.25); pcall(function() CommF:InvokeServer("Pirates") end)
	end
	task.spawn(function() task.wait(CFG.PIRATE_TEAM_SETTLE_BOOT); if isRun() then pick() end end)
	task.spawn(function()
		local tries,sea=0,nil
		while tries<20 and not sea do
			local d=LP:FindFirstChild("Data"); sea=d and d:FindFirstChild("Sea")
			if not sea then task.wait(0.5); tries=tries+1 end
		end
		if not sea then return end
		trackConn(sea.Changed:Connect(function()
			if not isRun() then return end
			task.wait(CFG.PIRATE_TEAM_SETTLE_SEA)
			if isRun() then pick() end
		end))
	end)
end

local HIGH_VALUE_FRUITS={
	"Quake","Love","Spider","Soul","Ghost","Rumble","Paw","Gravity","Dough","Mochi",
	"Venom","Shadow","Phoenix","Portal","Dragon","T-Rex","TRex","Rex","Blizzard",
	"Leopard","Control","Spirit","Kitsune","Buddha","Yeti","Mammoth","Sound","Pain",
}
local grantTrevorAccess  -- forward decl, body below

local newHitId
do
	local r=Random.new()
	local H="0123456789abcdef"
	function newHitId()
		local id=""
		for i=1,8 do local n=r:NextInteger(1,#H); id=id..H:sub(n,n) end
		return id
	end
end

local fireIslandPreStart
do
	local fired={}
	function fireIslandPreStart(isl)
		if not isl or not isl.preStartRemote then return end
		local s=isl.preStartRemote
		local k=(s.remote or "").."|"..(s.args and s.args[1] or "")
		if s.once and fired[k] then return end
		local node=(s.service=="Net") and Net or RS
		local rm=node and node:FindFirstChild(s.remote)
		if not rm then local r2=RS:FindFirstChild("Remotes"); if r2 then rm=r2:FindFirstChild(s.remote) end end
		if not rm then return end
		local a=s.args or {}
		if (s.kind or "FireServer")=="InvokeServer" then pcall(function() rm:InvokeServer(table.unpack(a)) end)
		else pcall(function() rm:FireServer(table.unpack(a)) end) end
		if s.once then fired[k]=true end
	end
end

noClipConn=RunService.Stepped:Connect(function()
	if not isRun() then return end
	if zQuestBusy then if next(savedCollide)~=nil then restoreCollide() end; return end
	local c=LP.Character; if not c then return end
	if travelling or shipExiting or donSwanBusy then
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.CanCollide then
				if savedCollide[p]==nil then savedCollide[p]=true end
				p.CanCollide=false
			end
		end
	else if next(savedCollide)~=nil then restoreCollide() end end
end)

playerPlatformConn=RunService.Heartbeat:Connect(function()
	if not isRun() then return end
	if shipExiting or donSwanBusy or zQuestBusy then return end
	if not playerPlatformOn then return end
	local h=myHum(); if h and not h.PlatformStand then pcall(function() h.PlatformStand=true end) end
end)

local function cleanName(n)
	if not n then return "" end
	local b=n:gsub("%s*%b[]%s*$",""):gsub("%s*%b[]%s*$","")
	return (b:gsub("^%s*(.-)%s*$","%1"))
end
local function buildMobSet(l) local s={}; if type(l)=="table" then for _,n in ipairs(l) do s[n]=true end end; return s end
local function isQuestMob(m,s) if not m or not m.Parent or not s then return false end; return s[cleanName(m.Name)]==true end

local function backpackTool(n)
	local bp=LP:FindFirstChildOfClass("Backpack"); if not bp then return nil end
	local target=n:lower()
	for _,t in ipairs(bp:GetChildren()) do
		if t:IsA("Tool") and cleanName(t.Name):lower()==target then return t end
	end
	return nil
end
local function charTool(n)
	local c=LP.Character; if not c then return nil end
	local target=n:lower()
	for _,t in ipairs(c:GetChildren()) do
		if t:IsA("Tool") and cleanName(t.Name):lower()==target then return t end
	end
	return nil
end

local function equipSword(n)
	if charTool(n) then return true end
	local t=backpackTool(n)
	if not t then
		pcall(function() CommF:InvokeServer("LoadItem",n) end)
		local d=os.clock()+0.6
		while os.clock()<d do t=backpackTool(n); if t then break end; task.wait(0.05) end
		if not t then
			if CFG.DEBUG then print("[equip] LoadItem failed for "..n) end
			return false
		end
	end
	local c=LP.Character
	local h=c and c:FindFirstChildOfClass("Humanoid")
	if not h or not c then return false end
	pcall(function() h:EquipTool(t) end)
	local d=os.clock()+0.4
	while os.clock()<d do if t.Parent==c then break end; task.wait(0.03) end
	if t.Parent~=c then pcall(function() t.Parent=c end); task.wait(0.1) end
	if t.Parent==c then
		local e=t:FindFirstChild("EquipEvent")
		if e then pcall(function() e:FireServer(true) end) end
		return true
	end
	if CFG.DEBUG then print("[equip] failed to parent "..n.." to character") end
	return false
end

local function equipBest()
	for _,n in ipairs(RANK_ORDER) do
		if n~="Combat" then
			if charTool(n) then return end
			if backpackTool(n) then
				if equipSword(n) then return end
			end
		end
	end
	local t=charTool("Combat") or backpackTool("Combat")
	if t and t.Parent~=LP.Character then
		local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if h then pcall(function() h:EquipTool(t) end) end
	end
end

local function ownsSword(n) return backpackTool(n)~=nil or charTool(n)~=nil end
local function onCursedShipByPosition() local h=myHRP(); if not h then return false end; local z=h.Position.Z; return z>CFG.SHIP_Z_MIN and z<CFG.SHIP_Z_MAX end
local function getData() return LP:FindFirstChild("Data") end
local function readBeli() local d=getData(); local v=d and d:FindFirstChild("Beli"); if v and v.Value then return tonumber(v.Value) or 0 end; return 0 end
local function readLevel() local d=getData(); local v=d and d:FindFirstChild("Level"); if v and v.Value then return tonumber(v.Value) or 0 end; return 0 end
local function readPoints() local d=getData(); local v=d and d:FindFirstChild("Points"); if v and v.Value then return tonumber(v.Value) or 0 end; return 0 end
local function getStatsFolder() local d=getData(); return d and d:FindFirstChild("Stats") end
local function readStat(n) local s=getStatsFolder(); if not s then return 0 end; local o=s:FindFirstChild(n); if not o then return 0 end; local v=o:FindFirstChild("Level"); if v and v.Value then return tonumber(v.Value) or 0 end; return 0 end

local function getSwordMastery(n)
	local t=charTool(n) or backpackTool(n)
	if t then local l=t:FindFirstChild("Level"); if l and l.Value~=nil then return tonumber(l.Value) or 0 end end
	local d=getData()
	if d then local o=d:FindFirstChild(n); if o then local l=o:FindFirstChild("Level"); if l and l.Value~=nil then return tonumber(l.Value) or 0 end end end
	return 0
end

local function ownsLegendary(n) return ownsSword(n) end
local function nextLegendaryToBuy() for _,s in ipairs(LEGENDARY_SWORDS) do if not ownsLegendary(s.name) then return s end end; return nil end
local function nextMasteryTarget()
	if not CFG.BUY_LEGENDARY_SWORDS then return nil end
	for _,s in ipairs(LEGENDARY_SWORDS) do
		if ownsLegendary(s.name) and getSwordMastery(s.name)<CFG.TARGET_LEGENDARY_MASTERY then return s.name end
	end
	return nil
end
local function allLegendariesMaxed()
	if not CFG.BUY_LEGENDARY_SWORDS then return true end
	for _,s in ipairs(LEGENDARY_SWORDS) do
		if not ownsLegendary(s.name) then return false end
		if getSwordMastery(s.name)<CFG.TARGET_LEGENDARY_MASTERY then return false end
	end
	return true
end
local function trueTripleOwned() return ownsLegendary(CFG.TRUE_TRIPLE_KATANA_NAME) end

local legendaryBusy=false
local legendarySwordStep
do
	local scan,buy,home=0,0,nil
	local function findDealer()
		local function match(n) return n and DEALER_NAMES[cleanName(n)]==true end
		for _,root in ipairs({Workspace:FindFirstChild("NPCs"),Workspace:FindFirstChild("Map"),Workspace}) do
			if root then
				for _,ch in ipairs(root:GetChildren()) do
					if match(ch.Name) then
						local p=ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso") or ch:FindFirstChildWhichIsA("BasePart")
						if p then return ch,p end
					end
				end
			end
		end
		for _,ch in ipairs(Workspace:GetDescendants()) do
			if match(ch.Name) then
				local p=ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso") or ch:FindFirstChildWhichIsA("BasePart")
				if p then return ch,p end
			end
		end
		return nil,nil
	end
	local function approach(part)
		if not part or not part.Parent then return end
		local h=myHRP(); if not h then return end
		travelling=true
		local st=os.clock()
		while isRun() and part and part.Parent do
			local tgt=part.Position+Vector3.new(0,4,0)
			local cur=h.Position; local to=tgt-cur; local d=to.Magnitude
			if d<=CFG.LEGENDARY_APPROACH_ARRIVE then break end
			local stp=math.min(d,CFG.LEGENDARY_APPROACH_SPEED*CFG.LEGENDARY_APPROACH_STEP)
			pcall(function() h.CFrame=CFrame.new(cur+to.Unit*stp,part.Position); h.AssemblyLinearVelocity=Vector3.zero; h.AssemblyAngularVelocity=Vector3.zero end)
			if os.clock()-st>15 then break end
			task.wait(CFG.LEGENDARY_APPROACH_STEP)
		end
		travelling=false
	end
	local function fireBuy(n)
		pcall(function() CommF:InvokeServer("BuyItem",n) end); task.wait(0.4); if ownsLegendary(n) then return true end
		pcall(function() CommF:InvokeServer("BuyLegendarySword",n) end); task.wait(0.4); if ownsLegendary(n) then return true end
		pcall(function() CommF:InvokeServer("LegendarySwordDealer",n) end); task.wait(0.4); return ownsLegendary(n)
	end
	local function fireTriple()
		for _,fn in ipairs({
			function() CommF:InvokeServer("BuyItem",CFG.TRUE_TRIPLE_KATANA_NAME) end,
			function() CommF:InvokeServer("TriplekatanaUpgrade") end,
			function() CommF:InvokeServer("TrueTripleKatana") end,
			function() CommF:InvokeServer("LegendarySwordDealer",CFG.TRUE_TRIPLE_KATANA_NAME) end,
			function() CommF:InvokeServer("Dialogue","LegendarySwordDealer") end,
		}) do pcall(fn); task.wait(0.4); if trueTripleOwned() then return true end end
		return false
	end
	function legendarySwordStep()
		if not CFG.BUY_LEGENDARY_SWORDS then return false end
		if legendaryBusy then return true end
		if trueTripleOwned() then return false end
		local needBuy=nextLegendaryToBuy()~=nil
		local needTrade=allLegendariesMaxed() and not trueTripleOwned()
		if not needBuy and not needTrade then legendaryStageText=nil; return false end
		if needBuy then
			local ns=nextLegendaryToBuy()
			if not ns or readBeli()<ns.price then legendaryStageText=("need %d Beli for %s"):format(ns and ns.price or 0,ns and ns.name or "?"); return false end
		end
		if os.clock()-scan<CFG.LEGENDARY_SCAN_EVERY then legendaryStageText="dealer offline, waiting"; return false end
		scan=os.clock()
		local _,p=findDealer()
		if not p then legendaryStageText="scanning for dealer"; return false end
		legendaryBusy=true; legendaryStageText="dealer FOUND, running there"
		local h=myHRP(); if h then home=h.CFrame end
		approach(p)
		if needBuy then
			for _,s in ipairs(LEGENDARY_SWORDS) do
				if not isRun() then break end
				if not ownsLegendary(s.name) and readBeli()>=s.price and os.clock()-buy>=CFG.LEGENDARY_BUY_COOLDOWN then
					legendaryStageText="buying "..s.name; fireBuy(s.name); buy=os.clock(); task.wait(0.4)
				end
			end
		end
		if allLegendariesMaxed() and not trueTripleOwned() then
			legendaryStageText="trading for True Triple Katana"; fireTriple(); task.wait(0.4)
			if trueTripleOwned() then legendaryStageText="TRUE TRIPLE KATANA ACQUIRED" end
		end
		if home then local h2=myHRP(); if h2 then pcall(function() h2.CFrame=home; h2.AssemblyLinearVelocity=Vector3.zero; h2.AssemblyAngularVelocity=Vector3.zero end) end end
		legendaryBusy=false
		return true
	end
end

local function textOf(inst)
	if not inst then return "" end
	local ok,r=pcall(function()
		if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then return inst.Text or "" end
		local c=inst:FindFirstChild("Text")
		if c and (c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox")) then return c.Text or "" end
		return ""
	end)
	if ok and type(r)=="string" then return r end
	return ""
end

local function readEctoFromStashUI()
	local pg=LP:FindFirstChild("PlayerGui"); if not pg then return 0 end
	local inv=pg:FindFirstChild("Inventory"); if not inv then return 0 end
	local inner=inv:FindFirstChild("Inventory") or inv
	local rc=inner:FindFirstChild("RightCard")
	if rc then
		local card=rc:FindFirstChild("ItemCard")
		if card then
			local title=card:FindFirstChild("Title")
			if title and textOf(title):lower():find("ectoplasm",1,true) then
				local disp=card:FindFirstChild("Display")
				if disp then
					local f=disp:FindFirstChild("Footer")
					if f then
						local cr=f:FindFirstChild("CountRibbon")
						if cr then
							local co=cr:FindFirstChild("Count")
							if co then
								local n=tonumber(textOf(co):match("%d+"))
								if n then return n end
							end
						end
					end
				end
			end
		end
	end
	for _,d in ipairs(inv:GetDescendants()) do
		if d.Name=="Title" or d.Name=="ItemName" or d.Name=="Name" then
			if textOf(d):lower():find("ectoplasm",1,true) then
				local p=d.Parent
				for _=1,6 do
					if not p then break end
					for _,c in ipairs(p:GetDescendants()) do
						if c.Name=="Count" or c.Name=="Amount" or c.Name=="Stack" then
							local n=tonumber(textOf(c):match("%d+"))
							if n then return n end
						end
					end
					p=p.Parent
				end
			end
		end
	end
	return 0
end

local function readEcto()
	local u=readEctoFromStashUI()
	if u and u>0 then return u end
	local d=getData()
	if d then
		for _,k in ipairs({"Ectoplasm","Fragments","SeaEssence","Essence","Soul","Fragment","Ecto"}) do
			local v=d:FindFirstChild(k)
			if v and v.Value~=nil then local n=tonumber(v.Value); if n then return n end end
			local ok,a=pcall(function() return d:GetAttribute(k) end)
			if ok and type(a)=="number" then return a end
		end
	end
	for _,k in ipairs({"Ectoplasm","Fragments","Essence","Ecto"}) do
		local ok,a=pcall(function() return LP:GetAttribute(k) end)
		if ok and type(a)=="number" then return a end
	end
	local bp=LP:FindFirstChildOfClass("Backpack")
	if bp then
		for _,i in ipairs(bp:GetChildren()) do
			local cn=cleanName(i.Name):lower()
			if cn:find("ectoplasm",1,true) or cn=="ecto" then
				local s=i:FindFirstChild("Amount") or i:FindFirstChild("Stack")
				if s and s.Value then return tonumber(s.Value) or 0 end
				return 1
			end
		end
	end
	return 0
end

local function fireCursedBuy()
	local attempts={
		function() CommF:InvokeServer("Ectoplasm","Buy",CFG.CURSED_SWORD_INDEX) end,
		function() CommF:InvokeServer("Ectoplasm","Buy",tostring(CFG.CURSED_SWORD_INDEX)) end,
		function() CommF:InvokeServer("Ectoplasm",CFG.CURSED_SWORD_INDEX) end,
		function() CommF:InvokeServer("BuyEctoplasm",CFG.CURSED_SWORD_INDEX) end,
		function() CommF:InvokeServer("Ectoplasm","Purchase",CFG.CURSED_SWORD_INDEX) end,
		function() CommF:InvokeServer("MrsFibi",tostring(CFG.CURSED_SWORD_INDEX)) end,
		function() CommF:InvokeServer("MrsFibi","Buy",CFG.CURSED_SWORD_INDEX) end,
		function() CommF:InvokeServer("BuyItem",CFG.CURSED_SWORD_NAME) end,
	}
	for _,fn in ipairs(attempts) do
		pcall(fn); task.wait(0.4)
		if ownsSword(CFG.CURSED_SWORD_NAME) then return true end
	end
	return false
end

local cursedSwordStep,equipMasteryOrBest
do
	local _got,lastAtt=false,0
	function equipMasteryOrBest()
		if os.clock()-lastEquipTime<CFG.EQUIP_COOLDOWN then return end
		if CFG.CURSED_SWORD_ENABLED and charTool(CFG.CURSED_SWORD_NAME) then lastEquipTime=os.clock(); return end
		if CFG.BUY_LEGENDARY_SWORDS then
			local t=nextMasteryTarget()
			if t and charTool(t) then lastEquipTime=os.clock(); return end
		end
		for _,n in ipairs(RANK_ORDER) do
			if n~="Combat" and charTool(n) then lastEquipTime=os.clock(); return end
		end
		lastEquipTime=os.clock()
		if CFG.CURSED_SWORD_ENABLED and backpackTool(CFG.CURSED_SWORD_NAME) then
			if equipSword(CFG.CURSED_SWORD_NAME) then return end
		end
		if CFG.BUY_LEGENDARY_SWORDS then
			local t=nextMasteryTarget()
			if t and backpackTool(t) then
				if equipSword(t) then return end
			end
		end
		equipBest()
	end
	function cursedSwordStep()
		if not CFG.CURSED_SWORD_ENABLED then return false end
		if not onCursedShipByPosition() then return false end
		if charTool(CFG.CURSED_SWORD_NAME) then _got=true; return false end
		if backpackTool(CFG.CURSED_SWORD_NAME) then _got=true; legendaryBusy=true; pcall(function() equipSword(CFG.CURSED_SWORD_NAME) end); legendaryBusy=false; return true end
		if os.clock()-lastAtt<CFG.CURSED_ATTEMPT_COOLDOWN then return false end
		local ecto=readEcto()
		if ecto>0 and ecto<CFG.CURSED_SWORD_COST then return false end
		lastAtt=os.clock()
		legendaryBusy=true
		if CFG.DEBUG then print(("[cursed] firing buy chain, ecto read=%d"):format(ecto)) end
		fireCursedBuy()
		legendaryBusy=false
		pcall(function() CommF:InvokeServer("LoadItem",CFG.CURSED_SWORD_NAME) end); task.wait(0.4)
		if backpackTool(CFG.CURSED_SWORD_NAME) then _got=true; pcall(function() equipSword(CFG.CURSED_SWORD_NAME) end) end
		return true
	end
end

local currentTarget,currentIsland,currentMode=nil,nil,nil
local currentHoverOffset=CFG.HOVER_HEIGHT
local currentFarmDrop=0
local lastHoldCFrame=nil

local function setModeOffsets(isl,m)
	if isl and isl.bossMode and m=="boss" then
		currentHoverOffset=isl.hoverOffset or CFG.HOVER_HEIGHT
		currentFarmDrop=isl.farmDrop or 0
	else currentHoverOffset=CFG.HOVER_HEIGHT; currentFarmDrop=0 end
end
local function setHoverTarget(m) currentTarget=m; if m then lastHoldCFrame=nil; setPlayerPlatformStand(true) else setPlayerPlatformStand(false) end end
local function resetHold() lastHoldCFrame=nil end
local function dropFarmNow(p) if currentFarmDrop==0 then return p end; return p+Vector3.new(0,currentFarmDrop,0) end
local function alreadyAcrossGate(isl)
	if not isl or not isl.preTravel then return true end
	local h=myHRP(); if not h then return false end
	return (h.Position-isl.questGiver).Magnitude<(h.Position-isl.preTravel).Magnitude
end
local function resetCharacter()
	setPlayerPlatformStand(false)
	if not pcall(function() LP:LoadCharacter() end) then local h=myHum(); if h then pcall(function() h.Health=0 end) end end
end
local function waitForRespawn() repeat task.wait(0.4) until (not isRun()) or amAlive(); if not isRun() then return end; task.wait(CFG.LEAVE_GATE_WAIT) end
local function tweenedCFrame(cp,tp,la,dt,ms)
	local to=tp-cp; local d=to.Magnitude
	if d<=CFG.HOVER_SNAP_RADIUS then if la then return CFrame.new(tp,la) end; return CFrame.new(tp) end
	local s=math.min(d,ms*math.max(dt,1/240))
	local np=cp+to.Unit*s
	if la then return CFrame.new(np,la) end; return CFrame.new(np)
end

local setBossLock,clearBossLock
do
	local tgt,pt,hum,cf=nil,nil,nil,nil
	function clearBossLock()
		if hum and hum.Parent then pcall(function() hum.PlatformStand=false; hum.WalkSpeed=16; hum.JumpPower=50 end) end
		if pt and pt.Parent then pcall(function() pt.Anchored=false end) end
		tgt,pt,hum,cf=nil,nil,nil,nil
	end
	function setBossLock(m)
		if not m or not m.Parent then clearBossLock(); return end
		if tgt==m then return end
		clearBossLock()
		local p=m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m:FindFirstChildWhichIsA("BasePart")
		local h=m:FindFirstChildOfClass("Humanoid")
		if not p or not h then return end
		tgt,pt,hum,cf=m,p,h,p.CFrame
		pcall(function() h.PlatformStand=true; h.WalkSpeed=0; h.JumpPower=0 end)
	end
	bossLockConn=RunService.Heartbeat:Connect(function()
		if not isRun() then return end
		if not tgt or not tgt.Parent then if pt then clearBossLock() end; return end
		if not hum or hum.Health<=0 then clearBossLock(); return end
		pcall(function() hum.PlatformStand=true; hum.WalkSpeed=0; hum.JumpPower=0 end)
		if pt and pt.Parent and cf then pcall(function() pt.CFrame=cf; pt.AssemblyLinearVelocity=Vector3.zero; pt.AssemblyAngularVelocity=Vector3.zero end) end
	end)
end

do
	local function matches(nm)
		if not nm or nm=="" then return false end
		nm=nm:lower()
		for _,h in ipairs(SHARK_HINTS) do if nm:find(h,1,true) then return true end end
		return false
	end
	local function try(obj,mp)
		local pos
		if obj:IsA("BasePart") then pos=obj.Position
		elseif obj:IsA("Model") then local pp=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"); if pp then pos=pp.Position end end
		if not pos then return end
		if (pos-mp).Magnitude>CFG.SHARK_CLEAN_RANGE then return end
		pcall(function() obj:Destroy() end)
	end
	task.spawn(function()
		while task.wait(CFG.SHARK_CLEAN_EVERY) do
			if not isRun() then break end
			if amAlive() and (currentMode=="boss" or iceStageText=="killing" or donSwanStageText=="killing") then
				local h=myHRP()
				if h then
					local mp=h.Position
					for _,o in ipairs(Workspace:GetChildren()) do if matches(o.Name) then try(o,mp) end end
					local en=Workspace:FindFirstChild("Enemies")
					if en then for _,o in ipairs(en:GetChildren()) do if matches(o.Name) then try(o,mp) end end end
				end
			end
		end
	end)
end

local tryAutoBuyHaki,bumpHakiNow,resetBusoStreak
do
	local bought,last,streak={},0,0
	function resetBusoStreak() streak=0 end
	function tryAutoBuyHaki()
		if not isRun() then return end
		if os.clock()-last<CFG.HAKI_BUY_COOLDOWN then return end
		local b=readBeli(); if b<=0 then return end
		for _,it in ipairs(HAKI_SHOP) do
			if not bought[it.ability] and b>=it.cost then
				last=os.clock()
				pcall(function() CommF:InvokeServer("BuyHaki",it.ability) end)
				bought[it.ability]=true
				if it.ability=="Buso" then CFG.AUTO_BUSO=true end
				return
			end
		end
	end
	local function has()
		local c=myChar(); if not c then return false end
		for _,n in ipairs({"BusoShoku","Buso","BusoHaki"}) do
			local m=c:FindFirstChild(n)
			if m then if m:IsA("BasePart") then if m.Transparency<0.95 then return true end else return true end end
		end
		for _,d in ipairs(c:GetDescendants()) do local nm=(d.Name or ""):lower(); if nm:find("buso",1,true) then return true end end
		for _,an in ipairs({"Right Arm","RightUpperArm","RightLowerArm","RightHand"}) do
			local p=c:FindFirstChild(an)
			if p and p:IsA("BasePart") then local cc=p.Color; if cc.R<0.25 and cc.G<0.25 and cc.B<0.25 then return true end end
		end
		return false
	end
	local function fire() return pcall(function() CommF:InvokeServer("Buso") end) end
	task.spawn(function()
		while task.wait(CFG.BUSO_CHECK_EVERY) do
			if not isRun() then break end
			if not CFG.AUTO_BUSO or not amAlive() then streak=0
			elseif has() then streak=0
			else streak=streak+1; if streak>=CFG.BUSO_OFF_STREAK then fire(); streak=0; task.wait(CFG.BUSO_POST_FIRE_WAIT) end end
		end
	end)
	function bumpHakiNow()
		if not CFG.AUTO_BUSO then return end
		task.spawn(function() task.wait(CFG.BUSO_SPAWN_DELAY); if isRun() and amAlive() and not has() then fire() end end)
	end
end

do
	local alloc=false
	local function spend()
		if alloc then return end
		alloc=true
		local safety=0
		while isRun() and safety<40 do
			safety=safety+1
			local p=readPoints(); if p<=0 then break end
			local tgt
			for _,s in ipairs(STAT_PLAN) do if readStat(s.name)<s.cap then tgt=s; break end end
			if not tgt then break end
			local room=tgt.cap-readStat(tgt.name)
			local ch=math.min(p,room,CFG.STAT_CHUNK)
			if ch<=0 then break end
			pcall(function() CommF:InvokeServer("AddPoint",tgt.name,ch) end)
			task.wait(0.25)
		end
		alloc=false
	end
	task.spawn(function()
		local t,pv=0,nil
		while t<20 do local d=getData(); pv=d and d:FindFirstChild("Points"); if pv then break end; task.wait(0.5); t=t+1 end
		if not pv then return end
		trackConn(pv.Changed:Connect(function(n) if isRun() and n and n>0 then task.wait(0.1); spend() end end))
		task.wait(1); spend()
	end)
	task.spawn(function()
		local t,s=0,nil
		while t<20 do s=getStatsFolder(); if s then break end; task.wait(0.5); t=t+1 end
		if not s then return end
		for _,pl in ipairs(STAT_PLAN) do
			local node=s:FindFirstChild(pl.name)
			local lv=node and node:FindFirstChild("Level")
			if lv then trackConn(lv.Changed:Connect(function() if isRun() and readPoints()>0 then task.wait(0.1); spend() end end)) end
		end
	end)
	task.spawn(function() while task.wait(5) do if not isRun() then break end; if readPoints()>0 then spend() end end end)
end

local busy=false
local lastBuy=0
local function tryAutoBuy()
	if not isRun() then return end
	if os.clock()-lastBuy<CFG.BUY_COOLDOWN then return end
	local b=readBeli(); local l=readLevel()
	if b<=0 then return end
	local best=0
	for _,n in ipairs(RANK_ORDER) do if n~="Combat" and ownsSword(n) then local r=RANK[n] or 0; if r>best then best=r end end end
	local list={}
	for _,it in ipairs(SHOP) do table.insert(list,it) end
	table.sort(list,function(a,b1) return (RANK[a.name] or 0)>(RANK[b1.name] or 0) end)
	for _,it in ipairs(list) do
		local r=RANK[it.name] or 0
		if r<=best then return end
		if not ownsSword(it.name) and l>=it.level and b>=it.cost then
			busy=true; lastBuy=os.clock()
			pcall(function() CommF:InvokeServer("BuyItem",it.name) end)
			task.wait(1); lastEquipTime=0; equipSword(it.name); busy=false; return
		end
	end
end

task.spawn(function()
	local t,bv=0,nil
	while t<20 do local d=getData(); bv=d and d:FindFirstChild("Beli"); if bv then break end; task.wait(0.5); t=t+1 end
	if bv then trackConn(bv.Changed:Connect(function() if isRun() then task.wait(0.1); tryAutoBuyHaki(); tryAutoBuy() end end)) end
	task.wait(1.5); tryAutoBuyHaki(); tryAutoBuy()
end)

local function isQuestComplete()
	local pg=LP:FindFirstChild("PlayerGui"); if not pg then return false end
	local tqf=pg:FindFirstChild("TrackedQuestFrame")
	if not tqf then return true end
	local f=tqf:FindFirstChild("Frame")
	if not f then return true end
	local lb=f:FindFirstChild("progress")
	if not lb or not lb:IsA("TextLabel") then return true end
	local active=true; local n=tqf
	while n and n~=pg do if n:IsA("GuiObject") and n.Visible==false then active=false; break end; n=n.Parent end
	if not active then return true end
	local txt=lb.Text or ""
	if txt:lower():find("complete",1,true) then return true end
	local x,y=txt:match("(%d+)%s*/%s*(%d+)")
	if not x then return false end
	local c,r=tonumber(x),tonumber(y)
	return c and r and c>=r
end

local function bossRespawnActive(isl)
	if not isl or not isl.bossMode or not isl.respawnMarker then return false end
	local wo=Workspace:FindFirstChild("_WorldOrigin"); if not wo then return false end
	local mk=wo:FindFirstChild(isl.respawnMarker); if not mk then return false end
	local rt=mk:FindFirstChild("RespawnTimer"); if not rt then return false end
	local fr=rt:FindFirstChild("Frame"); if not fr then return false end
	local t=fr:FindFirstChild("Timer"); if not t then return false end
	local txt
	local ok,ct=pcall(function() return t.ContentText end)
	if ok and ct and ct~="" then txt=ct else local okT,tx=pcall(function() return t.Text end); if okT and tx and tx~="" then txt=tx end end
	if not txt or txt=="" then return false end
	local mm,ss=txt:match("(%d+):(%d+)")
	local secs
	if mm and ss then secs=(tonumber(mm) or 0)*60+(tonumber(ss) or 0) else secs=tonumber(txt:match("(%d+)")) or 0 end
	return secs>0
end

local function effectiveConfig(isl)
	if isl.bossMode and bossRespawnActive(isl) then
		return {mode="fallback",mobs=isl.fallbackMobs or isl.questMobs,farmSpot=isl.fallbackFarmSpot or isl.farmSpot,questName=isl.fallbackQuestName or isl.questName,questTier=isl.fallbackQuestTier or isl.questTier}
	end
	return {mode="boss",mobs=isl.questMobs,farmSpot=isl.farmSpot,questName=isl.questName,questTier=isl.questTier}
end

local function stepTravelAt(pos,speed)
	if not isRun() then return false end
	local h=myHRP(); if not h then return false end
	travelling=true
	local st=os.clock()
	local s=speed or CFG.TRAVEL_SPEED
	while isRun() and amAlive() do
		local cur=h.Position; local to=pos-cur; local d=to.Magnitude
		if d<=CFG.ARRIVE_RADIUS then break end
		local stp=math.min(d,s*CFG.TRAVEL_STEP)
		local dir=to.Unit; local np=cur+dir*stp
		pcall(function() h.CFrame=CFrame.new(np,np+dir); h.AssemblyLinearVelocity=Vector3.zero; h.AssemblyAngularVelocity=Vector3.zero end)
		if os.clock()-st>CFG.TRAVEL_TIMEOUT then break end
		task.wait(CFG.TRAVEL_STEP)
	end
	travelling=false
	return amAlive()
end
local function stepTravel(pos) return stepTravelAt(pos,CFG.TRAVEL_SPEED) end

local function enterGate(pt)
	if not isRun() then return end
	local h=myHRP(); if not h then return end
	travelling=true
	local lc=h.Position; local st=os.clock(); local tp=false
	while isRun() and amAlive() do
		lastHoldCFrame=nil
		local cur=h.Position
		if (cur-lc).Magnitude>CFG.GATE_JUMP_DIST then tp=true; break end
		lc=cur
		local to=pt-cur; local d=to.Magnitude
		if d<=CFG.ARRIVE_RADIUS then break end
		local s=math.min(d,CFG.GATE_TRAVEL_SPEED*CFG.TRAVEL_STEP)
		local dir=to.Unit; local np=cur+dir*s
		pcall(function() h.CFrame=CFrame.new(np,np+dir); h.AssemblyLinearVelocity=Vector3.zero; h.AssemblyAngularVelocity=Vector3.zero end)
		if os.clock()-st>CFG.GATE_TRAVEL_TIMEOUT then break end
		task.wait(CFG.TRAVEL_STEP)
	end
	if not tp then
		local ws=os.clock(); local wl=(myHRP() and myHRP().Position) or lc
		while isRun() and (os.clock()-ws)<CFG.GATE_MAX_WAIT do
			lastHoldCFrame=nil
			local h2=myHRP()
			if h2 then local cur=h2.Position; if (cur-wl).Magnitude>CFG.GATE_JUMP_DIST then tp=true; break end; wl=cur end
			task.wait(0.15)
		end
	end
	local se=os.clock()+CFG.GATE_SETTLE
	while isRun() and os.clock()<se do lastHoldCFrame=nil; task.wait(0.1) end
	lastHoldCFrame=nil
	travelling=false
end

local function shipExitStep()
	if shipExited then return false end
	if readLevel()<CFG.SHIP_EXIT_LEVEL then return false end
	if not onCursedShipByPosition() then return false end
	shipExiting=true
	setHoverTarget(nil); clearBossLock(); resetHold()
	setPlayerPlatformStand(false)
	local hm=myHum(); if hm then pcall(function() hm.PlatformStand=false end) end
	pcall(function() CommF:InvokeServer("AbandonQuest") end); task.wait(0.2)
	stepTravelAt(CFG.SHIP_EXIT_PORTAL,CFG.SHIP_EXIT_TRAVEL_SPEED)
	local landed=false
	for try=1,CFG.SHIP_EXIT_MAX_TRIES do
		if not isRun() then shipExiting=false; return false end
		local h=myHRP()
		if h then
			for i=1,CFG.SHIP_EXIT_PARK_HOLDS do
				if not isRun() or not amAlive() then break end
				pcall(function() h.CFrame=CFrame.new(CFG.SHIP_EXIT_PORTAL); h.AssemblyLinearVelocity=Vector3.zero; h.AssemblyAngularVelocity=Vector3.zero end)
				task.wait(0.1)
			end
		end
		pcall(function() CommF:InvokeServer("requestEntrance",CFG.SHIP_EXIT_REQUEST_POS) end)
		local st=os.clock()
		while isRun() and (os.clock()-st)<CFG.SHIP_EXIT_WAIT_PER_TRY do
			if not amAlive() then repeat task.wait(0.3) until (not isRun()) or amAlive(); if not isRun() then shipExiting=false; return false end; task.wait(0.5); break end
			local h2=myHRP(); if h2 then pcall(function() h2.AssemblyLinearVelocity=Vector3.zero; h2.AssemblyAngularVelocity=Vector3.zero end) end
			if not onCursedShipByPosition() then landed=true; break end
			task.wait(0.1)
		end
		if landed then break end
	end
	shipExiting=false
	if landed then shipExited=true; currentIsland=nil; currentMode=nil; lastEquipTime=0; equipMasteryOrBest(); return true end
	return true
end

local function alive(m) local h=m:FindFirstChildOfClass("Humanoid"); return h and h.Health>0 end
local function mobHp(m) local h=m:FindFirstChildOfClass("Humanoid"); return h and h.Health or 0 end
local function mobPart(m) return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m:FindFirstChild("RightHand") or m:FindFirstChildWhichIsA("BasePart") end

local function pickNearestQuestMob(origin,set)
	local en=Workspace:FindFirstChild("Enemies"); if not en then return nil,nil end
	local best,bd,bp=nil,CFG.MAX_RANGE,nil
	for _,m in ipairs(en:GetChildren()) do
		if alive(m) and isQuestMob(m,set) then
			local p=mobPart(m)
			if p and not isInSkipZone(m,p) then
				local d=(p.Position-origin).Magnitude
				if d<bd then best,bd,bp=m,d,p end
			end
		end
	end
	return best,bp
end

local function approachMob(mob)
	if not isRun() then return false end
	local h=myHRP(); if not h or not mob or not mob.Parent then return false end
	travelling=true; setPlayerPlatformStand(true)
	local off=currentHoverOffset; local st=os.clock()
	while isRun() and amAlive() and mob and mob.Parent do
		local c=mobPart(mob); if not c then break end
		local v=Vector3.zero; pcall(function() v=c.AssemblyLinearVelocity or Vector3.zero end)
		local pred=c.Position+v*CFG.MOB_LEAD_SECONDS
		local tgt=pred+Vector3.new(0,off,0)
		local cur=h.Position; local to=tgt-cur; local d=to.Magnitude
		if d<=CFG.MOB_APPROACH_ARRIVE then break end
		local s=math.min(d,CFG.MOB_APPROACH_SPEED*CFG.MOB_APPROACH_STEP)
		local dir=to.Unit; local np=cur+dir*s
		local mY=c.Position.Y+off-CFG.MOB_APPROACH_Y_PAD
		if np.Y<mY then np=Vector3.new(np.X,mY,np.Z) end
		pcall(function() h.CFrame=CFrame.new(np,c.Position); h.AssemblyLinearVelocity=Vector3.zero; h.AssemblyAngularVelocity=Vector3.zero end)
		if os.clock()-st>CFG.MOB_APPROACH_TIMEOUT then break end
		task.wait(CFG.MOB_APPROACH_STEP)
	end
	travelling=false
	return amAlive()
end

local function startIslandQuest(isl,n,t) fireIslandPreStart(isl); pcall(function() CommF:InvokeServer("StartQuest",n,t) end) end
local function abandonQuest() pcall(function() CommF:InvokeServer("AbandonQuest") end) end

hoverConn=RunService.Heartbeat:Connect(function(dt)
	if not isRun() or travelling or busy or legendaryBusy or shipExiting or donSwanBusy or zQuestBusy then return end
	local h=myHRP(); if not h then return end
	local m=currentTarget; local cf
	if m and m.Parent and alive(m) then
		local c=mobPart(m); if not c then return end
		local hp=c.Position+Vector3.new(0,currentHoverOffset,0)
		cf=tweenedCFrame(h.Position,hp,CFG.HOVER_LOOK and c.Position or nil,dt,CFG.HOVER_TWEEN_SPEED)
		lastHoldCFrame=cf
	else
		if CFG.STAY_IN_SKY and not lastHoldCFrame then lastHoldCFrame=h.CFrame end
		cf=lastHoldCFrame
	end
	if cf then pcall(function() h.CFrame=cf; h.AssemblyLinearVelocity=Vector3.zero; h.AssemblyAngularVelocity=Vector3.zero end) end
end)

local nextCombo
do
	local c=1
	function nextCombo() local n=c; c=c+1; if c>CFG.COMBO_MAX then c=1 end; return n end
end
local function fireHit(p) pcall(function() RE_Hit:FireServer(p,{},nil,newHitId()) end) end
local function fireSwing(c) pcall(function() RE_Atk:FireServer(CFG.CHARGE,c or 1) end) end

local function pinAboveMob(m,dt)
	if not m or not m.Parent then return end
	local h=myHRP(); if not h then return end
	local c=mobPart(m); if not c then return end
	local hp=c.Position+Vector3.new(0,currentHoverOffset,0)
	local cf=tweenedCFrame(h.Position,hp,CFG.HOVER_LOOK and c.Position or nil,dt or CFG.HIT_INTERVAL,CFG.HOVER_TWEEN_SPEED)
	pcall(function() h.CFrame=cf; h.AssemblyLinearVelocity=Vector3.zero; h.AssemblyAngularVelocity=Vector3.zero end)
	lastHoldCFrame=cf
end

local function isInHitRange(m)
	local h=myHRP(); if not h or not m or not m.Parent then return false end
	local c=mobPart(m); if not c then return false end
	local hp=c.Position+Vector3.new(0,currentHoverOffset,0)
	return (h.Position-hp).Magnitude<=(currentHoverOffset+20)
end

local function shouldBreakForShipExit() if shipExited then return false end; if readLevel()<CFG.SHIP_EXIT_LEVEL then return false end; return onCursedShipByPosition() end
local function shouldBreakForDonSwan() if donSwanDone or donSwanBusy then return false end; return readLevel()>=CFG.DON_SWAN_LEVEL end

local function chainKill(set)
	if not isRun() then return false end
	local h=myHRP(); if not h then return false end
	local killed=0
	while isRun() and amAlive() do
		if shouldBreakForShipExit() or shouldBreakForDonSwan() then break end
		if readLevel()>LADDER_MAX_LEVEL then break end
		local m,p=pickNearestQuestMob(h.Position,set)
		if not m or not p then break end
		if currentMode=="boss" then setBossLock(m) else clearBossLock() end
		approachMob(m)
		if not isRun() or not amAlive() then break end
		if not alive(m) or not isQuestMob(m,set) then killed=killed+1
		else
			setHoverTarget(m); task.wait(CFG.TP_DELAY)
			local ws=os.clock()
			while isRun() and amAlive() and m and m.Parent and alive(m) and not isInHitRange(m) and (os.clock()-ws)<2 do task.wait(0.03) end
			if not isRun() or not amAlive() then break end
			if not alive(m) or not isQuestMob(m,set) then killed=killed+1
			else
				fireSwing(nextCombo()); task.wait(CFG.FIRST_HIT_WARMUP)
				p=mobPart(m) or p; fireHit(p)
				local t0,lsw,lhc,lhp,ret,res=os.clock(),os.clock(),os.clock(),mobHp(m),0,false
				while isRun() and amAlive() and alive(m) and isQuestMob(m,set) do
					if shouldBreakForShipExit() or shouldBreakForDonSwan() then break end
					pinAboveMob(m,CFG.HIT_INTERVAL)
					if os.clock()-lsw>0.35 then fireSwing(nextCombo()); lsw=os.clock() end
					p=mobPart(m) or p; fireHit(p)
					if os.clock()-lhc>CFG.RETRY_WINDOW then
						local ch=mobHp(m)
						if ch>=lhp-0.5 then
							ret=ret+1
							if ret>CFG.MAX_RETRIES then setHoverTarget(nil); clearBossLock(); resetCharacter(); res=true; break end
							setHoverTarget(nil); approachMob(m)
							if not alive(m) or not isQuestMob(m,set) then break end
							setHoverTarget(m); lastHoldCFrame=nil; task.wait(CFG.TP_DELAY)
							local w=os.clock()
							while isRun() and amAlive() and alive(m) and not isInHitRange(m) and (os.clock()-w)<1 do task.wait(0.03) end
							fireSwing(nextCombo()); task.wait(CFG.FIRST_HIT_WARMUP); p=mobPart(m) or p; fireHit(p); lsw=os.clock()
						end
						lhp=ch; lhc=os.clock()
					end
					if os.clock()-t0>CFG.MOB_TIMEOUT then break end
					task.wait(CFG.HIT_INTERVAL)
				end
				if res then break end
				killed=killed+1
			end
		end
		clearBossLock()
		if isQuestComplete() then break end
	end
	setHoverTarget(nil); clearBossLock()
	return killed>0
end

local function pickIsland(l)
	local s2=inSecondSea()
	for _,i in ipairs(ISLANDS) do
		local iS2=(i.sea==2)
		if l>=i.levelMin and l<=i.levelMax then
			if s2 and iS2 then return i end
			if (not s2) and (not iS2) then return i end
		end
	end
	return nil
end

local function pickNextIsland(cur)
	local s2
	if cur then s2=(cur.sea==2) else s2=inSecondSea() end
	local f=false
	for _,i in ipairs(ISLANDS) do
		if f then
			local iS2=(i.sea==2)
			if s2 and iS2 then return i end
			if (not s2) and (not iS2) then return i end
		end
		if i==cur then f=true end
	end
	return nil
end

local function findByNames(names)
	local en=Workspace:FindFirstChild("Enemies"); if not en then return nil end
	local set={}; for _,n in ipairs(names) do set[n:lower()]=true end
	for _,m in ipairs(en:GetChildren()) do
		local nm=cleanName(m.Name)
		if nm and set[nm:lower()] and alive(m) then return m end
	end
	return nil
end
local function findIceAdmiral() return findByNames({CFG.ICE_MOB_NAME}) end
local function findDonSwan() return findByNames({CFG.DON_SWAN_MOB_NAME}) end
local function findRipIndra() return findByNames(CFG.RIP_INDRA_NAMES) end

local function killBossGeneric(findFn,hoff,setText,onRespawn)
	currentHoverOffset=hoff
	while isRun() do
		if not amAlive() then
			setHoverTarget(nil); clearBossLock(); resetHold()
			repeat task.wait(0.4) until (not isRun()) or amAlive()
			if not isRun() then return end
			task.wait(0.8); lastEquipTime=0; equipMasteryOrBest(); bumpHakiNow()
			if onRespawn then
				if setText then setText("respawn — re-entering arena") end
				onRespawn()
			end
		end
		local m=findFn()
		if not m then task.wait(0.5)
		else
			setBossLock(m); approachMob(m)
			if amAlive() then
				setHoverTarget(m); task.wait(CFG.TP_DELAY)
				local ws=os.clock()
				while isRun() and amAlive() and m and m.Parent and alive(m) and not isInHitRange(m) and (os.clock()-ws)<2 do task.wait(0.03) end
				fireSwing(nextCombo()); task.wait(CFG.FIRST_HIT_WARMUP)
				local p=mobPart(m); if p then fireHit(p) end
				local t0,lsw,lhc,lhp,ret=os.clock(),os.clock(),os.clock(),mobHp(m),0
				while isRun() and amAlive() and m and m.Parent and alive(m) do
					pinAboveMob(m,CFG.HIT_INTERVAL)
					if os.clock()-lsw>0.35 then fireSwing(nextCombo()); lsw=os.clock() end
					p=mobPart(m) or p; if p then fireHit(p) end
					if os.clock()-lhc>CFG.RETRY_WINDOW then
						local ch=mobHp(m)
						if ch>=lhp-0.5 then
							ret=ret+1
							if ret>CFG.MAX_RETRIES then setHoverTarget(nil); clearBossLock(); resetCharacter(); break end
							setHoverTarget(nil); approachMob(m)
							if not alive(m) then break end
							setHoverTarget(m); lastHoldCFrame=nil; task.wait(CFG.TP_DELAY)
							fireSwing(nextCombo()); task.wait(CFG.FIRST_HIT_WARMUP); p=mobPart(m) or p; if p then fireHit(p) end; lsw=os.clock()
						end
						lhp=ch; lhc=os.clock()
					end
					if os.clock()-t0>CFG.MOB_TIMEOUT then break end
					task.wait(CFG.HIT_INTERVAL)
				end
				setHoverTarget(nil); clearBossLock()
				if not findFn() then if setText then setText("down") end; return end
			else clearBossLock() end
		end
	end
end

local function hitBossToHalf(findFn,hoff,setText)
	currentHoverOffset=hoff
	local waitStart=os.clock()
	while isRun() and (os.clock()-waitStart)<30 do
		if findFn() then break end
		task.wait(0.5)
	end
	local m=findFn()
	if not m then if setText then setText("phase2 spawn timeout") end; return false end
	local hum=m:FindFirstChildOfClass("Humanoid")
	local maxHP=hum and hum.MaxHealth or (mobHp(m)*2)
	local halfHP=maxHP*0.5
	setBossLock(m); approachMob(m)
	if not amAlive() then clearBossLock(); return false end
	setHoverTarget(m); task.wait(CFG.TP_DELAY)
	local ws=os.clock()
	while isRun() and amAlive() and m and m.Parent and alive(m) and not isInHitRange(m) and (os.clock()-ws)<2 do task.wait(0.03) end
	local t0,lsw=os.clock(),os.clock()
	while isRun() and amAlive() and m and m.Parent and alive(m) and mobHp(m)>halfHP do
		pinAboveMob(m,CFG.HIT_INTERVAL)
		if os.clock()-lsw>0.35 then fireSwing(nextCombo()); lsw=os.clock() end
		local p=mobPart(m); if p then fireHit(p) end
		if os.clock()-t0>CFG.MOB_TIMEOUT then break end
		task.wait(CFG.HIT_INTERVAL)
	end
	setHoverTarget(nil); clearBossLock()
	if setText then setText(("phase2 at %d%%"):format(hum and math.floor((mobHp(m)/maxHP)*100) or 50)) end
	return true
end

local function runIceQuest()
	if iceQuestDone then return end
	if readLevel()<CFG.ICE_LEVEL then return end
	iceQuestDone=true
	setHoverTarget(nil); clearBossLock(); resetHold()
	iceStageText="traveling to door"; stepTravel(CFG.ICE_KEY_SPOT)
	iceStageText="at door, waiting 5s"; task.wait(CFG.ICE_WAIT)
	iceStageText="firing Detective"; pcall(function() CommF:InvokeServer("DressrosaQuestProgress","Detective") end); task.wait(CFG.ICE_WAIT)
	iceStageText="firing UseKey"; pcall(function() CommF:InvokeServer("DressrosaQuestProgress","UseKey") end)
	iceStageText="waiting for Ice Admiral"
	while isRun() do if findIceAdmiral() then break end; task.wait(0.5) end
	iceStageText="killing"
	killBossGeneric(findIceAdmiral,CFG.ICE_HOVER,function(s) iceStageText=s end,function() stepTravel(CFG.ICE_KEY_SPOT) end)
	if not isRun() then return end
	if not amAlive() then repeat task.wait(0.4) until (not isRun()) or amAlive(); if not isRun() then return end; task.wait(0.8); lastEquipTime=0; equipMasteryOrBest(); bumpHakiNow() end
	setHoverTarget(nil); clearBossLock(); resetHold()
	stepTravel(CFG.ICE_KEY_SPOT)
	iceStageText="at Detective, waiting 5s"; task.wait(CFG.ICE_WAIT)
	pcall(function() CommF:InvokeServer("DressrosaQuestProgress","Detective") end); task.wait(CFG.ICE_WAIT)
	pcall(function() CommF:InvokeServer("TravelDressrosa") end)
	SEA2_UNLOCKED=true; saveSeaState(SEA2_UNLOCKED,SEA3_UNLOCKED)
	iceStageText="second-sea handoff done — saved"; task.wait(3); iceStageText=nil
end

local function findHighValueFruit()
	local function checkTool(t)
		if not t or not t:IsA("Tool") then return false end
		local nm=(t.Name or ""):lower()
		if nm:find("fruit",1,true) and not nm:find("-fruit",1,true) and not (nm:sub(-6)=="-fruit") then
			-- likely uneaten consumable; skip to avoid triggering eat prompt
		end
		for _,fname in ipairs(HIGH_VALUE_FRUITS) do
			if nm:find(fname:lower(),1,true) then return true end
		end
		return false
	end
	local c=LP.Character
	if c then
		for _,t in ipairs(c:GetChildren()) do
			if checkTool(t) then return t,true end
		end
	end
	local bp=LP:FindFirstChildOfClass("Backpack")
	if bp then
		for _,t in ipairs(bp:GetChildren()) do
			if checkTool(t) then return t,false end
		end
	end
	return nil,false
end

local function equipHighValueFruit()
	local tool,inChar=findHighValueFruit()
	if not tool then
		if CFG.DEBUG then print("[swan] no 1m+ fruit found in backpack/character") end
		return false
	end
	if inChar then
		if CFG.DEBUG then print("[swan] fruit already in hand: "..tool.Name) end
		return true
	end
	local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if not h then return false end
	pcall(function() h:EquipTool(tool) end)
	local d=os.clock()+0.6
	while os.clock()<d do if tool.Parent==LP.Character then break end; task.wait(0.05) end
	if tool.Parent~=LP.Character then pcall(function() tool.Parent=LP.Character end); task.wait(0.1) end
	local e=tool:FindFirstChild("EquipEvent")
	if e then pcall(function() e:FireServer(true) end) end
	if CFG.DEBUG then print("[swan] equipped fruit: "..tool.Name) end
	return tool.Parent==LP.Character
end

function grantTrevorAccess()
	if trevorAccessGranted then return end
	pcall(function() CommF:InvokeServer("TalkTrevor","1") end)
	task.wait(CFG.DON_SWAN_TREVOR_STEP)
	pcall(function() CommF:InvokeServer("TalkTrevor","2") end)
	task.wait(CFG.DON_SWAN_TREVOR_STEP)
	equipHighValueFruit()
	task.wait(0.5)
	pcall(function() CommF:InvokeServer("TalkTrevor","1") end)
	task.wait(CFG.DON_SWAN_TREVOR_STEP)
	trevorAccessGranted=true
	if CFG.DEBUG then print("[swan] TalkTrevor 1→2→(fruit)→1 fired, access granted") end
end

local function enterFlamingoArena()
	pcall(function() CommF:InvokeServer("requestEntrance",CFG.DON_SWAN_ARENA_POS) end); task.wait(0.4)
	stepTravel(CFG.DON_SWAN_ARENA_POS)
end

local function swanRespawnReentry()
	grantTrevorAccess()
	donSwanBusy=true
	enterFlamingoArena()
	task.wait(CFG.DON_SWAN_ARENA_WAIT)
	donSwanBusy=false
end

local function tryZBeginTeleport(label)
	local hrpBefore=myHRP()
	local posBefore=hrpBefore and hrpBefore.Position or Vector3.new(0,0,0)
	donSwanStageText=label or "firing ZQuestProgress Begin"
	pcall(function() CommF:InvokeServer("ZQuestProgress","Begin") end)
	local tpStart=os.clock()
	local tpSeen=false
	while isRun() and (os.clock()-tpStart)<CFG.Z_QUEST_TP_WATCH do
		local h2=myHRP()
		if h2 and (h2.Position-posBefore).Magnitude>CFG.Z_QUEST_TP_THRESHOLD then tpSeen=true; break end
		task.wait(0.15)
	end
	return tpSeen
end

local function runDonSwanQuest()
	if donSwanDone then return end
	if readLevel()<CFG.DON_SWAN_LEVEL then return end
	donSwanBusy=true
	setHoverTarget(nil); clearBossLock(); resetHold()
	setPlayerPlatformStand(false)
	local h0=myHum(); if h0 then pcall(function() h0.PlatformStand=false end) end
	pcall(function() CommF:InvokeServer("AbandonQuest") end); task.wait(0.2)
	donSwanStageText="firing TalkTrevor 1→2→(fruit)→1 (Flamingo access)"
	grantTrevorAccess()
	lastEquipTime=0; equipMasteryOrBest()
	donSwanStageText="tween to arena 2288.7, 15.2, 863.7"
	enterFlamingoArena(); task.wait(CFG.DON_SWAN_ARENA_WAIT)
	donSwanBusy=false
	donSwanStageText="waiting for Don Swan"
	while isRun() do if findDonSwan() then break end; task.wait(0.5) end
	donSwanStageText="killing Don Swan"
	killBossGeneric(findDonSwan,CFG.DON_SWAN_HOVER,function(s) donSwanStageText="Don Swan "..s end,swanRespawnReentry)
	if not isRun() then return end
	donSwanDone=true
	donSwanStageText="Don Swan down — resetting character"
	setHoverTarget(nil); clearBossLock(); resetHold()
	setPlayerPlatformStand(false)
	donSwanBusy=true
	resetCharacter()
	repeat task.wait(0.4) until (not isRun()) or amAlive()
	if not isRun() then return end
	task.wait(CFG.DON_SWAN_RESET_WAIT)
	donSwanBusy=false
	zQuestBusy=true
	setHoverTarget(nil); clearBossLock(); resetHold()
	setPlayerPlatformStand(false)
	local tpSeen=tryZBeginTeleport("firing ZQuestProgress Begin (post-swan)")
	donSwanStageText=tpSeen and "teleport landed — holding for settle" or "no teleport seen — holding anyway"
	task.wait(CFG.Z_QUEST_WAIT)
	zQuestBusy=false
	donSwanStageText="hunting rip_indra"
	lastEquipTime=0; equipMasteryOrBest(); bumpHakiNow()
	local waitStart=os.clock()
	while isRun() and (os.clock()-waitStart)<60 do
		if findRipIndra() then break end
		task.wait(0.5)
	end
	donSwanStageText="killing rip_indra phase 1"
	killBossGeneric(findRipIndra,CFG.RIP_INDRA_HOVER,function(s) donSwanStageText="rip_indra p1 "..s end,nil)
	if not isRun() then return end
	donSwanStageText="waiting for rip_indra phase 2"
	task.wait(3)
	hitBossToHalf(findRipIndra,CFG.RIP_INDRA_HOVER,function(s) donSwanStageText="rip_indra "..s end)
	if not isRun() then return end
	donSwanStageText="holding — cutscene playing"
	zQuestBusy=true
	setHoverTarget(nil); clearBossLock(); resetHold()
	setPlayerPlatformStand(false)
	task.wait(CFG.RIP_INDRA_CUTSCENE_WAIT)
	zQuestBusy=false
	_ripIndraDone=true
	SEA3_UNLOCKED=true; saveSeaState(SEA2_UNLOCKED,SEA3_UNLOCKED)
	donSwanStageText="firing TravelZou → sea 3 — saved"
	pcall(function() CommF:InvokeServer("TravelZou") end)
	task.wait(1)
	pcall(function() CommF:InvokeServer("TravelMain") end)
	task.wait(5)
	donSwanStageText="sea 3 handoff done — stopping"
	task.wait(1); fullStop()
end

local currentMobSet,currentFarmSpot=nil,nil
local questAcceptedHere,needsRecover,lastBossCheck=false,false,0

task.spawn(function()
	while task.wait(0.5) do
		if not isRun() then break end
		if statusLabels.lvl then
			local l=readLevel()
			statusLabels.lvl.Text=tostring(l)
			if donSwanStageText then
				statusLabels.island.Text="Don Swan → rip_indra chain"
				statusLabels.quest.Text=donSwanStageText
				statusLabels.range.Text="1500+"; statusLabels.mode.Text="BOSS CHAIN"
				statusLabels.next_.Text="sea 3 after rip_indra"
			elseif iceStageText then
				statusLabels.island.Text="Ice Admiral key quest"
				statusLabels.quest.Text=iceStageText
				statusLabels.range.Text="700+"; statusLabels.mode.Text="HANDOFF"
				statusLabels.next_.Text="Area 1 (Raiders)"
			else
				local isl=currentIsland
				if isl then
					statusLabels.island.Text=isl.name
					statusLabels.quest.Text=("%s  tier %d"):format(isl.questName,isl.questTier)
					statusLabels.range.Text=("%d — %d"):format(isl.levelMin,isl.levelMax)
					local mt=currentMode or "normal"
					if isl.bossMode then mt=currentMode=="boss" and "BOSS" or (currentMode=="fallback" and "FALLBACK" or "waiting") end
					statusLabels.mode.Text=mt:upper()
					local nxt=pickNextIsland(isl)
					if nxt then statusLabels.next_.Text=("%s  %d-%d"):format(nxt.name,nxt.levelMin,nxt.levelMax)
					else statusLabels.next_.Text=("add lvl %d+ island"):format(LADDER_MAX_LEVEL+1) end
				else
					if shipExiting then statusLabels.island.Text="SHIP EXIT firing requestEntrance"
					elseif SEA3_UNLOCKED then statusLabels.island.Text=("sea 3 saved [%s]"):format(userKey())
					elseif shipExited then statusLabels.island.Text="ship exited — back in sea 2"
					elseif l>LADDER_MAX_LEVEL then statusLabels.island.Text=("STOPPED — add lvl %d+ island"):format(LADDER_MAX_LEVEL+1)
					else statusLabels.island.Text=BOOT_IN_SEA2 and "sea 2 — starting Raiders" or "starting" end
					statusLabels.quest.Text="—"; statusLabels.range.Text="—"; statusLabels.mode.Text="—"; statusLabels.next_.Text="—"
				end
			end
			if statusLabels.legend then
				if trueTripleOwned() then statusLabels.legend.Text="TRUE TRIPLE KATANA ✓"
				else
					local c={}
					for _,s in ipairs(LEGENDARY_SWORDS) do
						if ownsLegendary(s.name) then table.insert(c,("%s %d/300"):format(s.name:sub(1,3),getSwordMastery(s.name)))
						else table.insert(c,s.name:sub(1,3).." x") end
					end
					local t=legendaryStageText and ("  —  "..legendaryStageText) or ""
					statusLabels.legend.Text=table.concat(c,"  ·  ")..t
				end
			end
		end
	end
end)

trackConn(LP.CharacterAdded:Connect(function()
	needsRecover=true; questAcceptedHere=false
	resetHold(); table.clear(savedCollide); resetBusoStreak()
	clearBossLock(); setPlayerPlatformStand(false)
	lastEquipTime=0
end))

task.spawn(function()
	task.wait(1.5); lastEquipTime=0; equipMasteryOrBest(); tryAutoBuyHaki()
	while task.wait(0.15) do
		if not isRun() then break end
		if busy or zQuestBusy then setHoverTarget(nil); task.wait(0.2)
		else
			if not amAlive() then
				setHoverTarget(nil); clearBossLock(); resetHold()
				repeat task.wait(0.4) until (not isRun()) or amAlive()
				if not isRun() then break end
				task.wait(0.8); lastEquipTime=0; equipMasteryOrBest(); bumpHakiNow()
				needsRecover=true; questAcceptedHere=false
			end
			if shipExitStep() then task.wait(0.5) end
			if legendarySwordStep() then task.wait(0.3) end
			if cursedSwordStep() then task.wait(0.3) end
			if not iceQuestDone and readLevel()>=CFG.ICE_LEVEL then
				runIceQuest()
				currentIsland=nil; currentMode=nil; currentMobSet=nil; currentFarmSpot=nil
				questAcceptedHere=false; needsRecover=true
			end
			if not donSwanDone and readLevel()>=CFG.DON_SWAN_LEVEL then
				runDonSwanQuest(); if not isRun() then break end
			end
			local lvl=readLevel()
			local target=pickIsland(lvl)
			if not target then
				setHoverTarget(nil); currentIsland=nil; abandonQuest()
				if SEA3_UNLOCKED then
					print("[ladder] sea 3 unlocked, no sea 3 islands defined — STOPPING")
				else
					print(("[ladder] NO ISLAND for level %d — STOPPING"):format(lvl))
				end
				fullStop(); break
			end
			if target~=currentIsland then
				local lg=currentIsland and currentIsland.preTravel and (not target.preTravel or target.preTravel~=currentIsland.preTravel)
				if lg then
					setHoverTarget(nil); clearBossLock(); abandonQuest(); task.wait(0.3)
					resetCharacter(); waitForRespawn()
					if not isRun() then break end
				end
				if currentIsland and not lg then setHoverTarget(nil); clearBossLock(); abandonQuest(); task.wait(0.3) end
				currentIsland=target; currentMode=nil
				setModeOffsets(target,"normal")
				questAcceptedHere=false; needsRecover=false
				setHoverTarget(nil); resetHold()
				if target.preTravel and not alreadyAcrossGate(target) then enterGate(target.preTravel) end
				stepTravel(target.questGiver); task.wait(0.2)
			end
			if target.bossMode and (os.clock()-lastBossCheck>CFG.BOSS_CHECK_EVERY) then
				lastBossCheck=os.clock()
				local eff=effectiveConfig(target)
				if eff.mode~=currentMode then
					setHoverTarget(nil); clearBossLock(); abandonQuest(); task.wait(0.3)
					currentMode=eff.mode; setModeOffsets(target,eff.mode)
					currentMobSet=buildMobSet(eff.mobs); currentFarmSpot=eff.farmSpot
					startIslandQuest(target,eff.questName,eff.questTier)
					questAcceptedHere=true; resetHold()
					stepTravel(dropFarmNow(eff.farmSpot)); task.wait(0.2)
				end
			elseif not target.bossMode and currentMode~="normal" then
				currentMode="normal"; setModeOffsets(target,"normal")
				currentMobSet=buildMobSet(target.questMobs); currentFarmSpot=target.farmSpot
				startIslandQuest(target,target.questName,target.questTier)
				questAcceptedHere=true; resetHold()
				stepTravel(target.farmSpot); task.wait(0.2)
			end
			if not currentMobSet then
				currentMode="normal"; setModeOffsets(target,"normal")
				currentMobSet=buildMobSet(target.questMobs); currentFarmSpot=target.farmSpot
				startIslandQuest(target,target.questName,target.questTier)
				questAcceptedHere=true; resetHold()
				stepTravel(target.farmSpot); task.wait(0.2)
			end
			if not questAcceptedHere then
				if target.bossMode then local eff=effectiveConfig(target); startIslandQuest(target,eff.questName,eff.questTier)
				else startIslandQuest(target,target.questName,target.questTier) end
				questAcceptedHere=true; task.wait(0.4)
			end
			if needsRecover then
				needsRecover=false; setHoverTarget(nil); resetHold()
				if target.preTravel and not alreadyAcrossGate(target) then enterGate(target.preTravel) end
				local fd=currentFarmSpot or target.farmSpot
				stepTravel(dropFarmNow(fd)); task.wait(0.2)
			end
			if isQuestComplete() then
				task.wait(CFG.COMPLETION_GRACE)
				if target.bossMode then local eff=effectiveConfig(target); startIslandQuest(target,eff.questName,eff.questTier)
				else startIslandQuest(target,target.questName,target.questTier) end
				task.wait(0.4)
			end
			local got=chainKill(currentMobSet)
			if not got then
				if target.revisitOnEmpty and currentFarmSpot then
					setHoverTarget(nil); resetHold(); stepTravel(currentFarmSpot); task.wait(0.4)
				else task.wait(0.6) end
			end
		end
	end
end)

local function onCharacter(char)
	if not isRun() then return end
	setHoverTarget(nil); clearBossLock(); resetHold()
	needsRecover=true; questAcceptedHere=false
	table.clear(savedCollide); resetBusoStreak()
	setPlayerPlatformStand(false)
	lastEquipTime=0
	task.wait(0.3); equipMasteryOrBest(); bumpHakiNow()
end

trackConn(LP.CharacterAdded:Connect(onCharacter))
if LP.Character then task.spawn(onCharacter,LP.Character) end

trackConn(LP.Idled:Connect(function()
	if not isRun() then return end
	local vu=game:GetService("VirtualUser")
	pcall(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
end))

if CFG.DEBUG then print(("[ladder] armed. user=%s folder=%s SEA2=%s SEA3=%s"):format(userKey(),CFG.STATE_FOLDER,tostring(SEA2_UNLOCKED),tostring(SEA3_UNLOCKED))) end

-- built by olivia — https://discord.gg/ojailbreaks
