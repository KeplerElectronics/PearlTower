--Names "Rustborne" "Rustblood" "Deeprust"

local webexport=false

local push = require "Libraries/push"
local cartographer = require "Libraries/cartographer"
local anim = require "Libraries/animation"
local bitser=nil

if webexport == false then
    bitser=require "Libraries/bitser"
end

local inputs=require "inputs"

love.graphics.setDefaultFilter("nearest", "nearest") --disable blurry scaling
local gameWidth, gameHeight = 320, 180 --fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()
--windowWidth, windowHeight = windowWidth*0.7, windowHeight*0.7

push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = true})

function lerp(a,b,t) 
    local dt=getDT()
    return (b+(a-b)*math.exp(-t*dt))
    --return (1-t)*a + t*b 
end

monogram=love.graphics.newFont("Fonts/monogram.ttf",16)
smoltxt=love.graphics.newFont("Fonts/tmhw.ttf",8)

ents={}
ptcs={}

cam={x=-20,y=-30}

mapright=0
mapleft=0
mapdown=0
mapup=0

local gamestate = "menu"

local playerct=1

local paused=false
local pausetimer=0
local pausing=false
local pausedelay=1
local pauseselect=1
local selecttimer=40
local pausemap=320
local pausemapstate=false
local exiting=320
local exitstate=false


local wipelen = 1
local wipestate = 0
local wipespeed = 500
local wipein=true
local newmap=nil
local wipedelay=0.2
local leveltransition=false

p={}

pstate={hasrun=false, hasfloat=false, hasdbljmp=false, hascrawl=false, hasswing=false, pearlcount=0}

function playeradd(x,y,animation)
    local player={  x=x,y=y,w=8,h=16,vx=0,vy=0,dir="right",canjump=0,maxhealth=1,health=6,
                    crouch=false,canfloat=false, float=0,candbljmp=false,doublejumped=false, 
                    swingtimer=0,swingdir=1, swinglen=28, swingdelay=0.5, swingx=10,swingy=10,swingw=20,swingh=20,anim=LoveAnimation.new(animation);}
    table.insert(p,player)
end

playeradd(-24*8,-12,'Sprites/PlayerAnim.lua')

local deathspr={love.graphics.newImage("Sprites/p1death.png")}

local lastx=0
local lasty=0

local swinganim = LoveAnimation.new('Sprites/SwingAnim.lua');
local rustslimeanim = LoveAnimation.new('Sprites/RustSlimeAnim.lua');

local rust2=LoveAnimation.new('Sprites/WalkerAnim.lua');
local rustballanim=LoveAnimation.new('Sprites/rustball.lua');

local pearlring=LoveAnimation.new('Sprites/PearlRing.lua');

local dropplat=love.graphics.newImage("Sprites/DropPlat.png")

local pearlspr=love.graphics.newImage("Sprites/Pearl.png")
local runpearl=love.graphics.newImage("Sprites/RunPearl.png")
local floatpearl=love.graphics.newImage("Sprites/FloatPearl.png")
local jumppearl=love.graphics.newImage("Sprites/JumpPearl.png")
local crawlpearl=love.graphics.newImage("Sprites/CrawlPearl.png")
local swordpearl=love.graphics.newImage("Sprites/SwordPearl.png")

--map
local menumap=love.graphics.newImage("Sprites/Map.png")

--menu
local title=love.graphics.newImage("BGs/Title.png")
local logo=love.graphics.newImage("BGs/Logo.png")
local victoryBG=love.graphics.newImage("BGs/Victory.png")

--transform images
local pretransform=love.graphics.newImage("Sprites/preTransform.png")
local posttransform=love.graphics.newImage("Sprites/postTransform.png")

--HUD
local heartbase=love.graphics.newImage("Sprites/Heartbase.png")
local heart=love.graphics.newImage("Sprites/Heart.png")

--particles
local sparkle1=love.graphics.newImage("Sprites/Sparkle1.png")
local ring1=love.graphics.newImage("Sprites/Ring1.png")
local pix=love.graphics.newImage("Sprites/Pix.png")
local rustfrag1=love.graphics.newImage("Sprites/rustfrag1.png")
local rustfrag2=love.graphics.newImage("Sprites/rustfrag2.png")


local mappath="Maps/BoxFort.lua"
local map = cartographer.load(mappath)
local terrain=map.layers.Sol
local bg=map.layers.BG
local fg=map.layers.FG
local entlayer=map.layers.Ents
local sfg=map.layers.SFG
local background=love.graphics.newImage("BGs/BG1.png")

--paused stuff
local ear=love.graphics.newImage("Sprites/earBase.png")
local earChain=love.graphics.newImage("Sprites/earChain.png")
local arm=love.graphics.newImage("Sprites/Handbase.png")

--bgsfx
local wind=love.audio.newSource('Audio/ESM_Wind_Loop_Underground_Cavern_Deep_Dark_Steady_3.wav',"stream")
local waves=love.audio.newSource('Audio/DS_SCD_fx_field_recording_one_shot_dock.wav',"stream")


--sfx
local pain1=love.audio.newSource('Audio/SFX/pain1.wav',"static")
local pain2=love.audio.newSource('Audio/SFX/pain2.wav',"static")
local pain3=love.audio.newSource('Audio/SFX/pain3.wav',"static")
local pain4=love.audio.newSource('Audio/SFX/pain4.wav',"static")
local painvol=0.5
pain1:setVolume(painvol)
pain2:setVolume(painvol)
pain3:setVolume(painvol)
pain4:setVolume(painvol)

local hit1=love.audio.newSource('Audio/SFX/hit1.wav',"static")
local hit2=love.audio.newSource('Audio/SFX/hit2.wav',"static")
local hit3=love.audio.newSource('Audio/SFX/hit3.wav',"static")
local hit4=love.audio.newSource('Audio/SFX/hit4.wav',"static")
local hit5=love.audio.newSource('Audio/SFX/hit5.wav',"static")
local hit6=love.audio.newSource('Audio/SFX/hit6.wav',"static")

local creak=love.audio.newSource('Audio/SFX/creak.wav',"static")
local fall=love.audio.newSource('Audio/SFX/fall.wav',"static")

local clam=love.audio.newSource('Audio/SFX/clam.wav',"static")

local flsfx=love.audio.newSource('Audio/SFX/float.wav',"static")

local jmp1=love.audio.newSource('Audio/SFX/dj_a.wav',"static")
local jmp2=love.audio.newSource('Audio/SFX/dj_cs.wav',"static")
local jmp3=love.audio.newSource('Audio/SFX/dj_ds.wav',"static")
local jmp4=love.audio.newSource('Audio/SFX/dj_e.wav',"static")
local jmp5=love.audio.newSource('Audio/SFX/dj_fs.wav',"static")
local jmp6=love.audio.newSource('Audio/SFX/dj_gs.wav',"static")
local jmp7=love.audio.newSource('Audio/SFX/dj_b.wav',"static")

local bns1=love.audio.newSource('Audio/SFX/bounce1.wav',"static")
local bns2=love.audio.newSource('Audio/SFX/bounce2.wav',"static")
local bns3=love.audio.newSource('Audio/SFX/bounce3.wav',"static")
local bns4=love.audio.newSource('Audio/SFX/bounce4.wav',"static")

local sw1=love.audio.newSource('Audio/SFX/swing1.wav',"static")
local sw2=love.audio.newSource('Audio/SFX/swing2.wav',"static")
local sw3=love.audio.newSource('Audio/SFX/swing3.wav',"static")

local earring=love.audio.newSource('Audio/SFX/earring.wav',"static")

local pearlsfx=love.audio.newSource('Audio/SFX/pearl.wav',"static")

--ost
local songs={   love.audio.newSource('Audio/OST_Title.wav',"stream"),
                love.audio.newSource('Audio/OST_Cargo.wav',"stream"),
                love.audio.newSource('Audio/OST_Water.wav',"stream"),
                love.audio.newSource('Audio/OST_Bridge.wav',"stream"),
                love.audio.newSource('Audio/OST_Vents.wav',"stream"),
                love.audio.newSource('Audio/OST_Climb.wav',"stream"),
                love.audio.newSource('Audio/OST_Gym.wav',"stream"),
                love.audio.newSource('Audio/OST_Hub.wav',"stream")}

local aud_transition=0
local transition_len=4
local current_track=1
local new_track=1

local mus_vol=0

--wind:play()
--waves:play()

local collectanim=false
local colstate=1
local headx=-200
local handx=300
local pearlx=300
local collected=runpearl
local handy=52
local pearly=handy
local bgy=0
local circrad=0
local texttimer=0
local colstr=""
local pearltx=-42
local pearlty=52
local mgtx=20
local mgty=180

local menupos=1
local menulockout=0.25
if love.filesystem.getInfo("saveFile")==nil then
    menupos=2
end


local maplinks={["Maps/BoxFort.lua"]={["one"]={name="Maps/SwordAntechamber.lua",x=38,y=-42},["two"]={name="Maps/WarehouseClam.lua",x=29,y=-40},["three"]={name="Maps/WareHouseStairs.lua",x=-6,y=-16}},
                ["Maps/WarehouseClam.lua"]={["one"]={name="Maps/BoxFort.lua",x=30,y=-8},["two"]={name="Maps/WareHouseStairs.lua",x=5,y=-4}},
                ["Maps/WareHouseStairs.lua"]={["one"]={name="Maps/WarehouseClam.lua",x=38,y=-42},["two"]={name="Maps/BoxFort.lua",x=30,y=-18},["three"]={name="Maps/WarehousePit.lua",x=0,y=-12}},
                ["Maps/WarehousePit.lua"]={["one"]={name="Maps/WareHouseStairs.lua",x=14,y=-16},["two"]={name="Maps/CargoYard.lua",x=-1,y=-9}},

                ["Maps/SwordAntechamber.lua"]={["one"]={name="Maps/SwordRoom.lua",x=38,y=-42},["two"]={name="Maps/BoxFort.lua",x=-31,y=-8}},
                ["Maps/SwordRoom.lua"]={["one"]={name="Maps/SwordAntechamber.lua",x=0,y=-57}},

                ["Maps/CargoYard.lua"]={["one"]={name="Maps/WarehousePit.lua",x=27,y=-12},["two"]={name="Maps/HubClamGreen.lua",x=29,y=-40},
                                        ["three"]={name="Maps/Forklift.lua",x=-13,y=-58},["four"]={name="Maps/Nest1.lua",x=38,y=-40}},
                
                ["Maps/Forklift.lua"]={["one"]={name="Maps/CargoYard.lua",x=89,y=-28}},
                ["Maps/Nest1.lua"]={["one"]={name="Maps/CargoYard.lua",x=-2,y=-23}},

                --green hub rooms

                ["Maps/HubClamGreen.lua"]={["one"]={name="Maps/CargoYard.lua",x=87,y=-9},["two"]={name="Maps/EntryHub.lua",x=-19,y=-40}},

                
                ["Maps/EntryHub.lua"]={["one"]={name="Maps/HubClamGreen.lua",x=38,y=-40},["two"]={name="Maps/BridgeEntry.lua",x=-2,y=-50},
                                        ["three"]={name="Maps/CoreShaft.lua",x=10,y=-58},["four"]={name="Maps/BarracksBed.lua",x=0,y=-40},
                                        ["five"]={name="Maps/HubGate.lua",x=37,y=-27}},

                ["Maps/HubGate.lua"]={["one"]={name="Maps/EntryHub.lua",x=4,y=-97},["two"]={name="Maps/DecayTop.lua",x=27,y=-10}},
                ["Maps/DecayTop.lua"]={["one"]={name="Maps/HubGate.lua",x=50,y=-74},["two"]={name="Maps/Victory.lua",x=34,y=-39},},
                ["Maps/BridgeEntry.lua"]={["one"]={name="Maps/EntryHub.lua",x=38,y=-40},["two"]={name="Maps/Bridge.lua",x=-29,y=-20}},


                --Bridge and Parking
                ["Maps/Bridge.lua"]={["one"]={name="Maps/BridgeEntry.lua",x=93,y=-49},["two"]={name="Maps/ParkingGarage.lua",x=-10,y=-12}},
                ["Maps/ParkingGarage.lua"]={["one"]={name="Maps/Bridge.lua",x=106,y=-20},["two"]={name="Maps/CarClamTeal.lua",x=29,y=-41}},


                --teal
                ["Maps/CarClamTeal.lua"]={["one"]={name="Maps/ParkingGarage.lua",x=102,y=-44},["two"]={name="Maps/Float1.lua",x=17,y=-16}},
                ["Maps/Float1.lua"]={["two"]={name="Maps/CarClamTeal.lua",x=38,y=-40},["four"]={name="Maps/FloatCollect.lua",x=50,y=-47},
                                    ["three"]={name="Maps/Test.lua",x=148,y=-32}},
                ["Maps/FloatCollect.lua"]={["one"]={name="Maps/Float2.lua",x=58,y=-30},["two"]={name="Maps/Float1.lua",x=60,y=-23}},
                ["Maps/Float2.lua"]={["one"]={name="Maps/Ocean-Float.lua",x=81,y=-71},["two"]={name="Maps/FloatCollect.lua",x=48,y=-11}},

                ["Maps/Ocean-Float.lua"]={["one"]={name="Maps/Test2.lua",x=129,y=-8},["two"]={name="Maps/Float2.lua",x=30,y=0}},

                ["Maps/Test.lua"]={["one"]={name="Maps/Gym.lua",x=56,y=-60},["two"]={name="Maps/Float1.lua",x=17,y=-35}},

                --ocean
                ["Maps/Test2.lua"]={["one"]={name="Maps/DoubleJumpPit.lua",x=51,y=-76},["two"]={name="Maps/UnderseaClam.lua",x=38,y=-40},
                                    ["three"]={name="Maps/Ocean-Float.lua",x=-20,y=-71},["four"]={name="Maps/ChairRoom.lua",x=13,y=-15}},
                ["Maps/ChairRoom.lua"]={["one"]={name="Maps/Test2.lua",x=123,y=-14}},
                ["Maps/DoubleJumpPit.lua"]={["two"]={name="Maps/Test2.lua",x=0,y=-1}},
                ["Maps/UnderseaClam.lua"]={["one"]={name="Maps/ZigZag1.lua",x=40,y=0},["two"]={name="Maps/Test2.lua",x=1,y=-50}},

                ["Maps/ZigZag1.lua"]={["one"]={name="Maps/Crawl-Jump.lua",x=120,y=-77},["two"]={name="Maps/UnderseaClam.lua",x=29,y=-40},
                                      ["three"]={name="Maps/OceanHovel.lua",x=-14,y=-57},["four"]={name="Maps/CoreShaft.lua",x=64,y=-6},
                                      ["five"]={name="Maps/UnderBasket.lua",x=35,y=-58}},

                ["Maps/OceanHovel.lua"]={["one"]={name="Maps/ZigZag1.lua",x=40,y=-17}},
                ["Maps/Crawl-Jump.lua"]={["one"]={name="Maps/Vents1.lua",x=57,y=-14},["two"]={name="Maps/ZigZag1.lua",x=2,y=0}},

                --Vents
                ["Maps/VentClam.lua"]={["one"]={name="Maps/Vents1.lua",x=58,y=-38},["two"]={name="Maps/CoreShaft.lua",x=12,y=-15}},

                ["Maps/Vents1.lua"]={["one"]={name="Maps/Vents2.lua",x=59,y=-53},["two"]={name="Maps/VentClam.lua",x=29,y=-40},
                                     ["three"]={name="Maps/Crawl-Jump.lua",x=28,y=-76},["four"]={name="Maps/FloatVent.lua",x=59,y=-53}},

                ["Maps/Vents2.lua"]={["one"]={name="Maps/CrawlRoom.lua",x=60,y=-39},["two"]={name="Maps/Vents1.lua",x=4,y=-14},
                                     ["three"]={name="Maps/CarHovel.lua",x=-14,y=-57}},
                ["Maps/CarHovel.lua"]={["one"]={name="Maps/Vents2.lua",x=70,y=-23}},
                ["Maps/CrawlRoom.lua"]={["one"]={name="Maps/Vents2.lua",x=16,y=-23}},
                ["Maps/FloatVent.lua"]={["one"]={name="Maps/CrawlRoom.lua",x=45,y=-79},["two"]={name="Maps/Vents1.lua",x=4,y=-23}},

                ["Maps/CoreShaft.lua"]={["one"]={name="Maps/VentClam.lua",x=38,y=-40},["two"]={name="Maps/EntryHub.lua",x=18,y=-22},
                                     ["three"]={name="Maps/ZigZag1.lua",x=1,y=-33},["four"]={name="Maps/UnderBasketball2.lua",x=21,y=-54}},

                ["Maps/UnderBasketball2.lua"]={ ["one"]={name="Maps/Basketball.lua",x=27,y=-1},["two"]={name="Maps/CoreShaft.lua",x=34,y=-65},
                                                ["three"]={name="Maps/UnderBasket.lua",x=35,y=-94}},
                ["Maps/UnderBasket.lua"]={ ["one"]={name="Maps/ZigZag1.lua",x=40,y=-33},["two"]={name="Maps/UnderBasketball2.lua",x=50,y=-54}},

                --Gym/Barracks
                ["Maps/Basketball.lua"]={["one"]={name="Maps/BarracksBed.lua",x=62,y=-40},["two"]={name="Maps/GymHovel.lua",x=-14,y=-57},
                                     ["three"]={name="Maps/UnderBasketball2.lua",x=28,y=-95},["four"]={name="Maps/Gym.lua",x=18,y=-46}},

                ["Maps/GymHovel.lua"]={["one"]={name="Maps/Basketball.lua",x=58,y=-36}},


                ["Maps/Gym.lua"]={["one"]={name="Maps/Basketball.lua",x=60,y=-49},["two"]={name="Maps/RunRoom.lua",x=48,y=-39},
                                     ["three"]={name="Maps/Test.lua",x=-13,y=-26},["four"]={name="Maps/EdgeClimb.lua",x=78,y=-42}},

                ["Maps/EdgeClimb.lua"]={["one"]={name="Maps/Gym.lua",x=57,y=-78}},


                ["Maps/RunRoom.lua"]={["one"]={name="Maps/GymClam.lua",x=38,y=-40},["two"]={name="Maps/Gym.lua",x=18,y=-73}},
                ["Maps/GymClam.lua"]={["one"]={name="Maps/BarracksBed.lua",x=62,y=-63},["two"]={name="Maps/RunRoom.lua",x=16,y=-39}},

                ["Maps/BarracksBed.lua"]={["one"]={name="Maps/EntryHub.lua",x=34,y=-79},["two"]={name="Maps/GymClam.lua",x=29,y=-40},
                                     ["three"]={name="Maps/Basketball.lua",x=0,y=-31},["four"]={name="Maps/Vent1.lua",x=49,y=-38}},
                ["Maps/Vent1.lua"]={["one"]={name="Maps/BarracksBed.lua",x=3,y=-58}}
            }   

local mapbgs={  ["Maps/Test2.lua"]="BGs/UBG.png",
                ["Maps/Ocean-Float.lua"]="BGs/UBG.png",

                ["Maps/Test2.lua"]="BGs/UBG.png",
                ["Maps/ChairRoom.lua"]="BGs/UBG.png",
                ["Maps/DoubleJumpPit.lua"]="BGs/UBG.png",
                ["Maps/UnderseaClam.lua"]="BGs/UBG.png",

                ["Maps/ZigZag1.lua"]="BGs/UBG.png",

                ["Maps/OceanHovel.lua"]="BGs/UBG.png",
                ["Maps/Crawl-Jump.lua"]="BGs/UBG.png"}

local mapOST={["Maps/BoxFort.lua"]=2,
                ["Maps/WarehouseClam.lua"]=2,
                ["Maps/WareHouseStairs.lua"]=2,
                ["Maps/WarehousePit.lua"]=2,

                ["Maps/SwordAntechamber.lua"]=2,
                ["Maps/SwordRoom.lua"]=2,

                ["Maps/CargoYard.lua"]=2,
                
                ["Maps/Forklift.lua"]=2,
                ["Maps/Nest1.lua"]=2,

                --green hub rooms

                ["Maps/HubClamGreen.lua"]=8,

                
                ["Maps/EntryHub.lua"]=8,

                ["Maps/HubGate.lua"]=8,
                ["Maps/DecayTop.lua"]=6,
                ["Maps/BridgeEntry.lua"]=8,

                ["Maps/Victory.lua"]=6,

                --Bridge and Parking
                ["Maps/Bridge.lua"]=4,
                ["Maps/ParkingGarage.lua"]=4,


                --teal
                ["Maps/CarClamTeal.lua"]=4,
                ["Maps/Float1.lua"]=4,
                ["Maps/FloatCollect.lua"]=4,
                ["Maps/Float2.lua"]=4,

                ["Maps/Ocean-Float.lua"]=4,

                ["Maps/Test.lua"]=4,

                --ocean
                ["Maps/Test2.lua"]=3,
                ["Maps/ChairRoom.lua"]=3,
                ["Maps/DoubleJumpPit.lua"]=3,
                ["Maps/UnderseaClam.lua"]=3,

                ["Maps/ZigZag1.lua"]=3,

                ["Maps/OceanHovel.lua"]=3,
                ["Maps/Crawl-Jump.lua"]=3,

                --Vents
                ["Maps/VentClam.lua"]=5,

                ["Maps/Vents1.lua"]=5,

                ["Maps/Vents2.lua"]=5,
                ["Maps/CarHovel.lua"]=5,
                ["Maps/CrawlRoom.lua"]=5,
                ["Maps/FloatVent.lua"]=5,

                ["Maps/CoreShaft.lua"]=5,

                ["Maps/UnderBasketball2.lua"]=5,
                ["Maps/UnderBasket.lua"]=5,

                --Gym/Barracks
                ["Maps/Basketball.lua"]=7,

                ["Maps/GymHovel.lua"]=7,


                ["Maps/Gym.lua"]=7,

                ["Maps/EdgeClimb.lua"]=7,


                ["Maps/RunRoom.lua"]=7,
                ["Maps/GymClam.lua"]=7,

                ["Maps/BarracksBed.lua"]=7,
                ["Maps/Vent1.lua"]=7
            }   

local pearlsfound={}

local svfl={map="Maps/Test.lua",px=10,py=-24,prls=pstate.pearlcount}

local pearlnum=26

if webexport==true then
    svfl.pstate=pstate
end

love.graphics.setLineStyle("rough")

function love.load()
    
    
    local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[2]
    
end

function getDT()
    local dt=love.timer.getDelta()
    if dt>0.3 then
        dt=0.3
    end
    return dt
end

function load()
    if webexport==false then
        svfl=bitser.loadLoveFile("SaveFile")
    end
    p[1].x=svfl.px
    p[1].y=svfl.py
    lastx=p[1].x
    lasty=p[1].y
    p[1].vx=0
    p[1].vy=0
    p[1].health=p[1].maxhealth
    print("loading: "..svfl.map)
    mappath=svfl.map
    pearlsfound=svfl.prls
    pstate = svfl.pstate

    cam.x=p[1].x-160
    cam.y=p[1].y-90

    if mapbgs[mappath]~= nil then
        background=love.graphics.newImage(mapbgs[mappath])
    else 
        background=love.graphics.newImage("BGs/BG1.png")
    end

    map = cartographer.load(mappath)
    terrain=map.layers.Sol
    bg=map.layers.BG
    fg=map.layers.FG
    sfg=map.layers.SFG
    entlayer=map.layers.Ents

    ents={}
    ptcs={}

    --spawn in ents in the dedicated ent layer
    checkents()
    camlims()
    p[1].anim:setState("sleepidle")
end

function save()
    svfl.px=p[1].x
    svfl.py=p[1].y
    p[1].health=p[1].maxhealth
    svfl.map=mappath
    svfl.prls=pearlsfound
    svfl.pstate = pstate
    if webexport==false then
        bitser.dumpLoveFile("SaveFile", svfl)
    end
    --print("saved")
end

function checkents()
    local sx,sy,fx,fy = entlayer:getGridBounds()
    for i=sx,fx do
        for j=sy,fy do
            local gid = entlayer:getTileAtGridPosition(i,j)
            if gid ~= nil and gid ~= false 
            and map:getTileProperty(gid, 'entity') ~= nil then

                local ty = map:getTileProperty(gid, 'entity')
                sp_ent(i*8,j*8,ty)
            end
        end
    end
end

function camlims()
    if cam.y>mapdown then 
        cam.y=mapdown
    end
    if cam.y<mapup then 
        cam.y=mapup
    end
    if cam.x<mapleft then
        cam.x=mapleft
    end
    if cam.x>mapright then
        cam.x=mapright
    end
end

function love.gamepadpressed(joystick, button)
    --check if joystick is in use
    for i=1,#p do
        if joystick == p[i].joystick then
            return
        end
    end

    --if joystick is not in use:
    
        for i=1,#p do
            if p[i].joystick==nil then
                p[i].joystick = joystick
                local name = joystick:getName()
                local index = joystick:getID()
                print(string.format("Changing player ",i," gamepad to #%d '%s'.", index, name))
                return
            end
        end
    if gamestate=="play" then
        --if player does not exist
        animation='Sprites/PlayerAnim2.lua'
        if #p==2 then
            animation='Sprites/PlayerAnim3.lua'
        elseif #p==3 then
            animation='Sprites/PlayerAnim4.lua'
        end
        playeradd(p[1].x-30,p[1].y,animation)
        p[#p].joystick=joystick
    end
end

function love.joystickaxis(joystick, button)
    --check if joystick is in use
    for i=1,#p do
        if joystick == p[i].joystick then
            return
        end
    end

    --if joystick is not in use:
    
        for i=1,#p do
            if p[i].joystick==nil then
                p[i].joystick = joystick
                local name = joystick:getName()
                local index = joystick:getID()
                print(string.format("Changing player ",i," gamepad to #%d '%s'.", index, name))
                return
            end
        end
    if gamestate=="play" then
        --if player does not exist
        animation='Sprites/PlayerAnim2.lua'
        if #p==2 then
            animation='Sprites/PlayerAnim3.lua'
        elseif #p==3 then
            animation='Sprites/PlayerAnim4.lua'
        end
        playeradd(p[1].x-30,p[1].y,animation)
        p[#p].joystick=joystick
    end
end


function love.update(dt)
    local dt=getDT()
    kep_audio()
    if gamestate=="play" then
        playupdate(dt)
    end
end

function playupdate(dt)
    --print(joystick:getName())
    --print(joystick:isGamepad())
    
    if leveltransition ~=true then
        if pausetimer>0 then pausetimer = pausetimer-dt end

        --pause logic
        if trigpause() and pausetimer<=0 and collectanim~=true then
            pausing = true
            pausetimer = pausedelay
        end

        if pausing == true and pausetimer<=0 and collectanim~=true then
            paused = not paused
            pausing = false
            exiting=320
            pausemap=320
        end

        --game logic
        if paused==false then

            

            for i=1,#p do
                if p[i].dead==nil then
                    input(i,dt)
                    pcollision(i,dt)
                    p[i].anim:update(dt)
                end
            end

            swinganim:update(dt)
            rustslimeanim:update(dt)
            rust2:update(dt)
            pearlring:update(dt)
            rustballanim:update(dt)

            if collectanim==true then
                p[1].vx=0
                p[1].vy=0
            end

            --cam.x=lerp(cam.x,p[1].x-160,10)
            --cam.y=lerp(cam.y,p[1].y-90,10)

            cam.x=p[1].x-160
            cam.y=p[1].y-90

            camlims()

            if p[1].y>90 then
                p[1].x=lastx
                p[1].y=lasty
                p[1].vx=0
                p[1].vy=0
                p[1].health=p[1].health-1
                ents={}
                hurtsfx()
                checkents()
            end
        end
    else
        if wipein==true then
            wipestate=wipestate-wipespeed*dt
            if wipestate<=0 then
                local ind=newmap

                for i=1,#p do
                    p[i].x=maplinks[mappath][ind].x*8
                    p[i].y=maplinks[mappath][ind].y*8

                    p[i].vx=0
                    p[i].vy=0
                end

                lastx=p[1].x
                lasty=p[1].y

                cam.x=p[1].x-160
                cam.y=p[1].y-90

                mappath=maplinks[mappath][ind].name
                map = cartographer.load(mappath)
                terrain=map.layers.Sol
                bg=map.layers.BG
                fg=map.layers.FG
                sfg=map.layers.SFG
                ents={}
                entlayer=map.layers.Ents
                checkents()

                if mapbgs[mappath]~= nil then
                    background=love.graphics.newImage(mapbgs[mappath])
                else 
                    background=love.graphics.newImage("BGs/BG1.png")
                end

                if mappath=="Maps/Victory.lua" then
                    victory=true
                end
                
                wipein = false
                wipestate=0
            end

        else
            cam.x=lerp(cam.x,p[1].x-160,10)
            cam.y=lerp(cam.y,p[1].y-90,10)
            camlims()
            wipedelay=wipedelay-dt
            if wipedelay<0 then
                wipestate=wipestate+wipespeed*dt
                if wipestate>255 then
                    leveltransition = false
                    wipein=true
                    wipedelay=0.2
                end
            end
        end
    end
end

function love.draw()
    push:start()
    local dt=getDT()

    if gamestate=="menu" then
        love.graphics.draw(title,0,0)
        love.graphics.draw(logo,0,-10)
        love.graphics.setColor(love.math.colorFromBytes(0,0,0))
            
            menulockout=menulockout+dt

            local minnum=1
            if love.filesystem.getInfo("saveFile")==nil then
                minnum=2
            end

            if up() and menulockout>0.25 and menupos>minnum then 
                menupos=menupos-1 
                menulockout=0
            elseif down() and menulockout>0.25 and menupos<3 then 
                menupos=menupos+1 
                menulockout=0
            end

            if menulockout>0.25 then
                if menupos==1 then
                    if leveltransition~=true then
                        if jump() or float() or run() or swing() then
                            leveltransition=true
                            wipestate=255
                        end
                    end
                elseif menupos==2 then
                    if leveltransition~=true then
                        if jump() or float() or run() or swing() then
                            leveltransition=true
                            wipestate=255
                            save()
                        end
                    end
                elseif menupos==3 then
                    if leveltransition~=true then
                        if jump() or float() or run() or swing() then
                            love.event.quit()
                        end
                    end
                end
            end

            love.graphics.printf(">",smoltxt,3,60+(menupos-1)*10,220)
            if love.filesystem.getInfo("saveFile")~=nil then
                outprint("Continue",15,60)
            end
            outprint("Begin Again",15,70)
            outprint("Exit",15,80)

        if leveltransition == true then    
            wipestate=wipestate-dt*200
            local step = 255-wipestate
            if step >0 and step<250 then
                love.graphics.setColor(love.math.colorFromBytes(0,0,0,step))
                love.graphics.rectangle("fill",0,0,320,180)
            elseif step>250 then
                love.graphics.setColor(love.math.colorFromBytes(0,0,0,255))
                love.graphics.rectangle("fill",0,0,320,180)
            elseif step<0 then
                love.graphics.setColor(love.math.colorFromBytes(0,0,0,255))
                love.graphics.rectangle("fill",0,0,320,180)
            end

            if wipestate<=0 then
                wipein = false
                wipestate=0
                gamestate="play"

                if webexport==false then
                    if love.filesystem.getInfo("saveFile")==nil then
                        print("No Save found")
                        save()

                    else
                        load()
                    end
                    --spawn in ents in the dedicated ent layer
                    checkents()
                    cam.x=p[1].x-160
                    cam.y=p[1].y-90

                    camlims()

                end
            end 
        end
        

    elseif gamestate=="play" then
        playdraw(dt)
    end
    --FPS is 120 steady on my mac mini
    --love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    push:finish()
end

function outprint(s,x,y)
    love.graphics.setColor(love.math.colorFromBytes(0,0,0))
    love.graphics.printf(s,smoltxt,x-1,y-1,220)
    love.graphics.printf(s,smoltxt,x,y-1,220)
    love.graphics.printf(s,smoltxt,x+1,y-1,220)

    love.graphics.printf(s,smoltxt,x-1,y,220)
    love.graphics.printf(s,smoltxt,x+1,y,220)

    love.graphics.printf(s,smoltxt,x-1,y+1,220)
    love.graphics.printf(s,smoltxt,x,y+1,220)
    love.graphics.printf(s,smoltxt,x+1,y+1,220)

    resdraw()

    love.graphics.printf(s,smoltxt,x,y,220)
end

function playdraw(dt)
    love.graphics.draw(background,0,0)

    love.graphics.translate(math.floor(-cam.x),math.floor(-cam.y))
    --map:draw()
    bg:draw()
    terrain:draw()
    fg:draw()

    --love.graphics.setColor(love.math.colorFromBytes(115,239,232))
    --love.graphics.rectangle("fill",p[1].swingx,p[1].swingy-p[1].swingh/2,p[1].swingw,p[1].swingh)

    love.graphics.setColor(love.math.colorFromBytes(255,255,255))

    for i=1,#p do
        if p[i].dead==nil then
            p[i].anim:setPosition(math.floor(p[i].x-p[i].w-8),math.floor(p[i].y-24))

            if p[i].iframes~=nil then
                love.graphics.setColor(love.math.colorFromBytes(200,100,100))
            end
            p[i].anim:draw()

            love.graphics.setColor(love.math.colorFromBytes(255,255,255))
            if p[i].swingtimer>0 then
                swinganim:setPosition(p[i].swingx+p[i].swingw/8,p[i].swingy-p[i].swingh/2)
                swinganim:draw()
            end
        end
    end

    entlgc()
    ptclgc()

    --draw super foreground layer that draws in front of entities and player
    sfg:draw()

    for i=1,#p do
        if p[i].frontbench==true then
            outprint("press up to save",math.floor(p[1].x-60),math.floor(p[1].y-30))
        end
    end

    love.graphics.origin()

    love.graphics.setColor(love.math.colorFromBytes(255,255,255))
    for plyr=1,#p do
        for i=1,p[plyr].maxhealth do
            love.graphics.draw(heartbase,-14+i*16,2)
        end
        for i=1,p[plyr].health do
            love.graphics.draw(heart,-14+i*16,2)
        end
    end

    if savedtimer~=nil then
        savedtimer=savedtimer-1
        if savedtimer<0 then savedtimer=nil end

        love.graphics.setColor(love.math.colorFromBytes(115,239,232))
        love.graphics.print("saved",monogram,280,140)
        love.graphics.setColor(love.math.colorFromBytes(20,18,29))
        love.graphics.print("saved",monogram,300+1,p[1].y-30+1)
    end


    local strings={ "Run: hold x key or right trigger to move faster",
                    "Double Jump: Jump again in the air",
                    "Float: Hold s key or left trigger to float for a while",
                    "Crawl: Press down to squeeze through tight spaces",
                    "Swing: Press 'a' key or x button to swing your sword"}

    if victory~=nil and wipestate>0 then
        love.graphics.draw(victoryBG,-2,-2)

        outprint("Collected",50,70)
        outprint(pstate.pearlcount .. " / " .. pearlnum .. " pearls",50,80)

        love.graphics.draw(earChain,-84,-18)

        if pstate.hasrun==true then
            love.graphics.draw(runpearl,10,63)
        end
        if pstate.hasdbljmp==true then
            love.graphics.draw(jumppearl,10,80)
        end
        if pstate.hasfloat==true then
            love.graphics.draw(floatpearl,10,97)
        end
        if pstate.hascrawl==true then
            love.graphics.draw(crawlpearl,10,114)
        end
        if pstate.hasswing==true then
            love.graphics.draw(swordpearl,10,131)
        end

        if jump() or float() or run() or swing() then
            
            menulockout=-0.5
            victory=nil
            gamestate="menu"

        end
    end

    if leveltransition == true then    
        local step = 255-wipestate
        if step >0 and step<250 then
            love.graphics.setColor(love.math.colorFromBytes(0,0,0,step))
            love.graphics.rectangle("fill",0,0,320,180)
        elseif step>250 then
            love.graphics.setColor(love.math.colorFromBytes(0,0,0,255))
            love.graphics.rectangle("fill",0,0,320,180)
        elseif step<0 then
            love.graphics.setColor(love.math.colorFromBytes(0,0,0,255))
            love.graphics.rectangle("fill",0,0,320,180)
        end
    end

    if pausing==true or paused == true then
        local pt=pausetimer*2*120

        if paused == true and pausing == true then 
            pt=2*pausedelay*120-pt
        end

        love.graphics.setColor(love.math.colorFromBytes(40,44,60))
        love.graphics.rectangle("fill",0,0,320,pausedelay*240-pt)
        resdraw()
        love.graphics.draw(ear,-70-pt,-30)
        if pstate.hasrun==true then
            love.graphics.draw(runpearl,45-pt,63)
        end
        if pstate.hasdbljmp==true then
            love.graphics.draw(jumppearl,45-pt,80)
        end
        if pstate.hasfloat==true then
            love.graphics.draw(floatpearl,45-pt,97)
        end
        if pstate.hascrawl==true then
            love.graphics.draw(crawlpearl,45-pt,114)
        end
        if pstate.hasswing==true then
            love.graphics.draw(swordpearl,45-pt,131)
        end

        if selecttimer<=0.25 then selecttimer=selecttimer+dt end

        if pauseselect>1 and up() and selecttimer >0.25 then 
            pauseselect=pauseselect-1
            selecttimer=0
        elseif pauseselect<5 and down() and selecttimer>0.25 then
            pauseselect=pauseselect+1
            selecttimer=0
        end

        love.graphics.printf(strings[pauseselect],smoltxt,100+pt,50,220)
        love.graphics.line(90+pt,54,70+pt,71+17*(pauseselect-1))
        love.graphics.line(90+pt,54,98+pt,54)
        love.graphics.line(62+pt,71+17*(pauseselect-1),70+pt,71+17*(pauseselect-1))

        resdraw()
        love.graphics.printf("<-Exit // Map ->",smoltxt,180+pt,5,220)

        --display number of pearls collected
        love.graphics.draw(pearlspr,300+pt,25)
        love.graphics.setColor(love.math.colorFromBytes(20,18,29))
        love.graphics.printf(pstate.pearlcount,smoltxt,300+pt,22,220)
        resdraw()
        love.graphics.printf(pstate.pearlcount,smoltxt,300+pt-1,21,220)


        if right() and pausemap>=320 and exiting>=320 and pausing==false then
            pausemap=319
            pausemapstate=true
        end
        if pausemap<320 and pausemap>0 and pausemapstate==true then
            pausemap=pausemap-dt*400
        end
        if pausemap<=0 and left() then
            pausemap=1
            pausemapstate=false
        end
        if pausemap<320 and pausemap>0 and pausemapstate==false then
            pausemap=pausemap+dt*400
        end

        --map
        love.graphics.setColor(love.math.colorFromBytes(40,44,60))
        love.graphics.rectangle("fill",pausemap,0,323,pausedelay*240-pt)
        resdraw()
        love.graphics.printf("<- Pearls",smoltxt,pausemap+20,5-pt,220)
        love.graphics.draw(menumap,pausemap,-pt)

        if left() and exiting>=320 and pausemap>=320 and pausing==false then
            exiting=319
            exitstate=true
        end
        if exiting<320 and exiting>0 and exitstate==true then
            exiting=exiting-dt*400
        end
        if exiting<=0 and swing() then
            love.event.quit()
        end
        if exiting<=0 and right() then
            exiting=1
            exitstate=false
        end
        if exiting<320 and exiting>0 and exitstate==false then
            exiting=exiting+dt*400
        end

        love.graphics.setColor(love.math.colorFromBytes(40,44,60))
        love.graphics.rectangle("fill",-exiting-4,0,324,pausedelay*240-pt)
        resdraw()
        love.graphics.printf("Press A (x) to leave",smoltxt,10-exiting,10-pt,220)
        love.graphics.printf("Pearls ->",smoltxt,-exiting+200,5-pt,220)
    end

    if collectanim==true then
        love.graphics.setColor(love.math.colorFromBytes(40,44,60))
        love.graphics.rectangle("fill",0,0,322,bgy)
        resdraw()

        if colstate==1 then
            bgy=bgy+dt*300
            if bgy>200 then
                colstate=2
            end
        elseif colstate==2 then
            headx=headx+dt*300
            if headx>=0 then
                colstate=3
                headx=0
            end
        elseif colstate==3 then
            handx=handx-dt*300
            pearlx=pearlx-dt*300
            if handx<=-39 then
                colstate=4
                handx=-42
                pearlx=pearltx
                pearly=pearlty
                earring:play()
            end
        elseif colstate==4 then
            circrad=circrad+dt*200
            handx=handx+dt*200
            handy=handy+dt*50
            if circrad>300 then colstate=5 end
        elseif colstate==5 then
            texttimer=texttimer+dt
            if texttimer>2 then
                if jump() or float() or run() or trigpause() or float() then
                    colstate=6
                end
            end
        elseif colstate==6 then
            headx=headx-dt*300
            pearlx=pearlx-dt*300
            
            if pstate.hasswing==true and pstate.hascrawl==true
            and pstate.hasfloat==true and pstate.hasrun==true
            and pstate.hasdbljmp==true then
                if headx<=-200 then
                    colstate=7
                end
            else
                
                bgy=bgy-dt*300
                if bgy<0 then
                    collectanim=false
                    colstate=1
                    headx=-200
                    handx=300
                    pearlx=300
                    collected=runpearl
                    handy=20
                    pearly=20
                    bgy=0
                    circrad=0
                    texttimer=0
                end
            end
        elseif colstate==7 then
            mgty=mgty-300*dt
            if mgty<=0 then
                colstate=8
                circrad=0
                earring:play()
            end
            love.graphics.draw(pretransform,mgtx,mgty)
            mgtx=mgtx+math.sin(os.time())*dt*10
        elseif colstate==8 then
            circrad=circrad+dt*200
            love.graphics.draw(posttransform,mgtx,mgty)
            mgtx=mgtx+math.cos(os.time())*dt*10
            mgty=mgty+math.sin(os.time())*dt*10
            outprint("climb the tower",-mgtx+40,-mgty+160)
            if circrad>300 then colstate=9 end
        elseif colstate==9 then
            mgtx=mgtx+math.cos(os.time())*dt*10
            mgty=mgty-dt*300
            bgy=bgy-dt*300
            love.graphics.draw(posttransform,mgtx,mgty)
            if bgy<0 then
                collectanim=false
                colstate=1
                headx=-200
                handx=300
                pearlx=300
                collected=runpearl
                handy=20
                pearly=20
                bgy=0
                circrad=0
                texttimer=0
            end

        end

        

        love.graphics.draw(ear,headx,-30)
        love.graphics.draw(arm,handx,handy)
        love.graphics.draw(collected,pearlx+157,pearly+79)

        if pstate.hasrun==true and collected~=runpearl then
            love.graphics.draw(runpearl,headx+115,63)
        end
        if pstate.hasdbljmp==true and collected~=jumppearl then
            love.graphics.draw(jumppearl,headx+115,80)
        end
        if pstate.hasfloat==true and collected~=floatpearl then
            love.graphics.draw(floatpearl,headx+115,97)
        end
        if pstate.hascrawl==true and collected~=crawlpearl then
            love.graphics.draw(crawlpearl,headx+115,114)
        end
        if pstate.hasswing==true and collected~=swordpearl then
            love.graphics.draw(swordpearl,headx+115,131)
        end

        if colstate==4 then
            for i=0,40,10 do
                if circrad-i>0 then
                    love.graphics.circle("line",pearlx+165,pearly+87,circrad-i)
                end
            end
        end
        if colstate==5 then
            love.graphics.printf(colstr,smoltxt,170,50,130)
            if texttimer>2 then
                love.graphics.printf("press any button",smoltxt,170,140,220)
            end
        end
    end
end

function pcollision(plyr,dt)
    local floor=math.floor
    local ceil=math.ceil
    --bonk
    if checkSolid((p[plyr].x),(p[plyr].y-p[plyr].h)) and p[plyr].vy<0 then
        p[plyr].y=ceil(p[plyr].y/8)*8
        p[plyr].vy=0
    end
    --land
    for i=0,p[plyr].vy*dt,8 do
        if checkSolid((p[plyr].x),(p[plyr].y+i)) and p[plyr].vy>0 then
            p[plyr].y=floor(p[plyr].y/8+i/8)*8
            landing(plyr)
            if checkSolid((p[plyr].x),(p[plyr].y-p[plyr].h/2)) then
                p[plyr].y=p[plyr].y-8
            end 
            break
        end
    end

    --right col
    if checkSolid((p[plyr].x+p[plyr].w/2+p[plyr].vx*dt),(p[plyr].y-p[plyr].h+4)) 
    or checkSolid((p[plyr].x+p[plyr].w/2+p[plyr].vx*dt),(p[plyr].y-4)) then
        p[plyr].x=ceil(p[plyr].x/8)*8-4
        p[plyr].vx=0
    end
    --left col
    if checkSolid((p[plyr].x-p[plyr].w/2+p[plyr].vx*dt),(p[plyr].y-p[plyr].h+4)) 
    or checkSolid((p[plyr].x-p[plyr].w/2+p[plyr].vx*dt),(p[plyr].y-4)) then
        p[plyr].x=floor(p[plyr].x/8)*8+4
        p[plyr].vx=0
    end

    if checkDeath((p[plyr].x-p[plyr].w/2+p[plyr].vx*dt),(p[plyr].y-p[plyr].h/2-2)) 
    or checkDeath((p[plyr].x+p[plyr].w/2+p[plyr].vx*dt),(p[plyr].y-p[plyr].h/2-2)) 
    or checkDeath((p[plyr].x-p[plyr].w/2+p[plyr].vx*dt),(p[plyr].y-p[plyr].h/2+6)) 
    or checkDeath((p[plyr].x+p[plyr].w/2+p[plyr].vx*dt),(p[plyr].y-p[plyr].h/2+6)) then
        p[plyr].x=lastx
        p[plyr].y=lasty
        p[plyr].vx=0
        p[plyr].vy=0
        p[plyr].health=p[plyr].health-1
        ents={}
        hurtsfx()
        checkents()
        
    end

    if checkBench((p[plyr].x-p[plyr].w/2+p[plyr].vx*dt),(p[plyr].y-p[plyr].h+2)) ~= nil then
        p[plyr].frontbench=true
        
        if up(plyr) then
            save()
            savedtimer=300
            clam:play()
        end
    else
        p[plyr].frontbench=nil
    end

    if checkDoor((p[plyr].x-p[plyr].w/2+p[plyr].vx*dt),(p[plyr].y-p[plyr].h+2)) ~= nil then
        if leveltransition~=true then
            wipestate=255
            leveltransition=true
            newmap=checkDoor((p[plyr].x-p[plyr].w/2+p[plyr].vx*dt),(p[plyr].y-p[plyr].h+2))
        end
    end

    if p[plyr].iframes~=nil then
        p[plyr].iframes=p[plyr].iframes-dt
        if p[plyr].iframes<=0 then p[plyr].iframes=nil end
    end

    if p[plyr].health<=0 then
        --load()
        sp_ptc(p[plyr].x,p[plyr].y,100,-200,30,deathspr[1],6,"death")
        p[plyr].dead=true
    end

end

function landing(plyr)
    local dt=getDT()
    p[plyr].canjump=0.05
    p[plyr].vy=0
    local offset = (1-3*dt)
    if not left(plyr) and not right(plyr) then
        offset = (1-5*dt)
    end 
    p[plyr].vx=p[plyr].vx*offset
    p[plyr].float=2
    p[plyr].canfloat=true
    p[plyr].doublejumped=false
    p[plyr].candbljmp=false
    p[plyr].jumped =nil
end

function input(plyr,dt)
    local floor=math.floor

    p[plyr].y=p[plyr].y+p[plyr].vy*dt
    p[plyr].x=p[plyr].x+p[plyr].vx*dt

    if down(plyr) and pstate.hascrawl==true then 
        p[plyr].crouch=true
    elseif checkSolid((p[plyr].x-p[plyr].w/2+2),(p[plyr].y-12))
        or checkSolid((p[plyr].x+p[plyr].w/2-2),(p[plyr].y-12)) 
        and pstate.hascrawl==true then
        p[plyr].crouch=true
    else
        p[plyr].crouch=false
    end

    if p[plyr].crouch==true then 
        p[plyr].h = 7
    else
        p[plyr].h = 16
    end

    local rate=480 --acceleration
    local scap=120

    if run() and pstate.hasrun == true then
        scap=scap*1.75
        rate=rate*1.5
    end

    if p[plyr].crouch == true 
    and checkSolid((p[plyr].x),(p[plyr].y)) then
        scap=scap*0.5
    end

    if left(plyr)
    and p[plyr].vx >-scap then
        p[plyr].swingdir=-1
        p[plyr].vx = p[plyr].vx - (rate)*dt
        if p[plyr].anim:getCurrentState()~='runLeft' 
        and p[plyr].crouch == false 
        and not up(plyr) then
            p[plyr].anim:setState('runLeft')
        elseif p[plyr].anim:getCurrentState()~='runLeftUp' 
        and p[plyr].crouch == false 
        and up(plyr) then
            p[plyr].anim:setState('runLeftUp')
        end
        p[plyr].dir="left"
    elseif right(plyr) 
    and p[plyr].vx < scap then
        p[plyr].swingdir=1
        p[plyr].vx = p[plyr].vx + (rate)*dt 
        if p[plyr].anim:getCurrentState()~='runRight' 
        and p[plyr].crouch == false 
        and not up(plyr) then
            p[plyr].anim:setState('runRight')
        elseif p[plyr].anim:getCurrentState()~='runRightUp' 
        and p[plyr].crouch == false 
        and up(plyr) then
            p[plyr].anim:setState('runRightUp')
        end
        p[plyr].dir="right"
    elseif p[plyr].crouch == true then
        p[plyr].vx=p[plyr].vx*(1-3*dt)
    else
        p[plyr].vx=p[plyr].vx*(1-3*dt)
    end

    if jump(plyr) and p[plyr].canjump>0 then  
        p[plyr].vy=-180
        p[plyr].canjump=p[plyr].canjump-dt*2
        p[plyr].jumped = true
    elseif jump(plyr) then
        p[plyr].vy=p[plyr].vy+500*dt
    elseif p[plyr].vy<0 then
        p[plyr].vy=p[plyr].vy+1200*dt
        p[plyr].canjump=0
    else 
        p[plyr].vy=p[plyr].vy+550*dt
    end

    if not jump(plyr) and p[plyr].jumped ~=nil 
    and pstate.hasdbljmp == true then
        p[plyr].candbljmp=true
    end

    if jump(plyr) 
    and p[plyr].canjump<=0 
    and p[plyr].candbljmp==true 
    and p[plyr].doublejumped==false then
        p[plyr].canjump=0.05
        sp_ptc(p[plyr].x-p[plyr].w/2,p[plyr].y,0,120,0.3,ring1)
        sp_ptc(p[plyr].x,p[plyr].y,-60,120,0.3,pix)
        sp_ptc(p[plyr].x,p[plyr].y,-40,120,0.3,pix)
        sp_ptc(p[plyr].x,p[plyr].y,40,120,0.3,pix)
        sp_ptc(p[plyr].x,p[plyr].y,60,120,0.3,pix)
        p[plyr].candbljmp=false
        p[plyr].doublejumped=true 
        
        local num=math.random(1,7)
        if num==1 then jmp1:play()
        elseif num==2 then jmp2:play()
        elseif num==3 then jmp3:play()
        elseif num==4 then jmp4:play() 
        elseif num==5 then jmp5:play()
        elseif num==6 then jmp6:play() 
        elseif num==7 then jmp7:play() end
    end 

    --float
    if float(plyr) 
    and pstate.hasfloat == true 
    and p[plyr].canfloat==true
    and p[plyr].float>0 then
        flsfx:play()
        p[plyr].float = p[plyr].float-dt
        p[plyr].vy=0
        p[plyr].trigfloat=0
    elseif p[plyr].trigfloat~=nil then
        p[plyr].float=0
        p[plyr].trigfloat=nil
    end

    if pstate.hasswing==true then
        if swing(plyr) and up(plyr) and p[plyr].swingtimer<=0 then
            p[plyr].swingtimer=p[plyr].swingdelay
            if swinganim:getCurrentState()~="up" then
                swinganim:setState("up")
            end
            local num=math.random(1,3)
            if num==1 then sw1:play()
            elseif num==2 then sw2:play()
            elseif num==3 then sw3:play() end

        elseif swing(plyr) and not up(plyr) and not down(plyr) and p[plyr].swingtimer<=0 then
            --Left/Right Swings
            p[plyr].swingtimer=p[plyr].swingdelay
            if p[plyr].swingdir>0 then
                if swinganim:getCurrentState()~="right" then
                    swinganim:setState("right")
                end
            else
                if swinganim:getCurrentState()~="left" then
                    swinganim:setState("left")
                end
            end
            local num=math.random(1,3)
            if num==1 then sw1:play()
            elseif num==2 then sw2:play()
            elseif num==3 then sw3:play() end
        end
    end

    --keep setting position as long as state is active
    if swinganim:getCurrentState()=="left" then
        p[plyr].swingx=p[plyr].x-6-p[plyr].swingw
        p[plyr].swingy=p[plyr].y-p[plyr].h/2
    elseif swinganim:getCurrentState()=="right" then
        p[plyr].swingx=p[plyr].x+4
        p[plyr].swingy=p[plyr].y-p[plyr].h/2
    else
        p[plyr].swingx=p[plyr].x-p[plyr].swingw/2
        p[plyr].swingy=p[plyr].y-p[plyr].h*1.5
    end

    if p[plyr].swingtimer>0 then p[plyr].swingtimer=p[plyr].swingtimer-dt end


    if p[plyr].frontbench==true then
        if p[plyr].anim:getCurrentState()~='sleep' 
        and p[plyr].anim:getCurrentState()~='sleepidle' then
            p[plyr].anim:setState("sleep")
        end
        p[plyr].anim:unpause()
    elseif p[plyr].crouch==true then
        if p[plyr].dir=="left" then
            if p[plyr].anim:getCurrentState()~='crouchLeft' then
                p[plyr].anim:setState('crouchLeft')
            end
        else
            if p[plyr].anim:getCurrentState()~='crouchRight' then
                p[plyr].anim:setState('crouchRight')
            end
        end

        if math.abs(p[plyr].vx)<4 then
            p[plyr].anim:pause()
        else
            p[plyr].anim:unpause()
        end
    elseif not checkSolid((p[plyr].x),(p[plyr].y+4)) then
        p[plyr].anim:unpause()
        if p[plyr].anim:getCurrentState()~='jumpRight' 
        and p[plyr].dir=="right" then
            p[plyr].anim:setState("jumpRight")
        elseif p[plyr].anim:getCurrentState()~='jumpLeft' 
        and p[plyr].dir=="left" then
            p[plyr].anim:setState("jumpLeft")
        end
    elseif not left(plyr) and not right(plyr) and not up(plyr) then
        p[plyr].anim:unpause()
        if p[plyr].anim:getCurrentState()~='idleRight' and p[plyr].dir=="right" then
            p[plyr].anim:setState('idleRight')
        elseif p[plyr].anim:getCurrentState()~='idleLeft' and p[plyr].dir=="left" then
            p[plyr].anim:setState('idleLeft')
        end
    elseif not left(plyr) and not right(plyr) and up(plyr) then
        p[plyr].anim:unpause()
        if p[plyr].anim:getCurrentState()~='idleRightUp' and p[plyr].dir=="right" then
            p[plyr].anim:setState('idleRightUp')
        elseif p[plyr].anim:getCurrentState()~='idleLeftUp' and p[plyr].dir=="left" then
            p[plyr].anim:setState('idleLeftUp')
        end
    end

end

function checkSolid(tx,ty)
    local gid = terrain:getTileAtGridPosition(math.floor(tx/8), math.floor(ty/8))
    -- check a tile property
    if gid==false or gid==nil then return end
    local sc = map:getTileProperty(gid, 'solid')
    return sc
end

function checkDeath(tx,ty)
    local gid = terrain:getTileAtGridPosition(math.floor(tx/8), math.floor(ty/8))
    -- check a tile property
    if gid==false or gid==nil then return end
    local dc = map:getTileProperty(gid, 'death')
    return dc
end

function checkDoor(tx,ty)
    local gid = entlayer:getTileAtGridPosition(math.floor(tx/8), math.floor(ty/8))
    -- check a tile property
    if gid==false or gid==nil then return end
    local dc = map:getTileProperty(gid, 'transition')
    return dc
end

function checkBench(tx,ty)
    local gid = terrain:getTileAtGridPosition(math.floor(tx/8), math.floor(ty/8))
    -- check a tile property
    if gid==false or gid==nil then return end
    local dc = map:getTileProperty(gid, 'savespot')
    return dc
end

--write a func to iterate over current room tile once and spawn ents

function sp_ptc(x,y,vx,vy,l,img,w,ty)
    if not ty then ty="no" end
    if not w then w=0 end
    local r=0
    ptc={
    x=x,y=y,vx=vx,vy=vy,
    l=l,img=img,w=w,r=r,ty=ty
    }

    table.insert(ptcs,ptc)
end

function ptclgc()
    local dt=getDT()
    for i,ptc in ipairs(ptcs) do

        local scl=1

        if ptc.ty=="death" then
            if ptc.scl==nil then
                ptc.scl=1
            end

            ptc.scl=ptc.scl+dt

            scl=ptc.scl
        end

        if ptc.wd==nil then
            ptc.wd,ptc.ht=ptc.img:getDimensions()
        end

        if ptc.vx ==0 and ptc.vy==0 then ptc.vy=30 end
        ptc.r=ptc.r+ptc.w*dt
        ptc.vy=ptc.vy+550*dt
        ptc.x = ptc.x + ptc.vx*dt
        ptc.y = ptc.y + ptc.vy*dt
        
        ptc.l=ptc.l-dt
        if ptc.l<0 then
            table.remove(ptcs,i)
        end

        love.graphics.draw(ptc.img,ptc.x,ptc.y,ptc.r,scl,scl,ptc.wd/2,ptc.ht/2)

    end
end

function sp_ent(x,y,ty,e)
    if not e then e=nil end
    local ent={x=x,y=y,ty=ty,e=e}
    table.insert(ents,ent)
end

function entlgc()
    for i,ent in ipairs(ents) do 
        local ty_l=ent.ty.."_l"
        entfuncs[ty_l](i)

    end
end

entfuncs={}

function entfuncs.test_l(id)
    ents[id].x=lerp(ents[id].x,p[1].x,0.01)

    love.graphics.rectangle("fill",ents[id].x,ents[id].y,5,5)
end

--ability gets
function entfuncs.dbljmp_l(id)
    if ents[id].ct==nil then
        ents[id].ct=0
        if pstate.hasdbljmp==true then
            table.remove(ents,id)
            return
        end
    end
    local dt=getDT()

    ents[id].ct=ents[id].ct+dt

    ents[id].y=ents[id].y-math.sin(ents[id].ct*2)*10*dt

    for plyr=1,#p do
        if hitbox(ents[id].x,ents[id].y,16,16,p[plyr].x,p[plyr].y-p[plyr].h/2) then
            pstate.hasdbljmp=true
            collectanim=true
            handy=52-17*3
            pearly=handy
            collected=jumppearl
            pearltx=-42
            pearlty=52-17*3
            colstr="Collected doublejump! You can now jump twice!"
            save()
            table.remove(ents,id)
            return
        end
    end

    love.graphics.draw(jumppearl,ents[id].x,ents[id].y)

end

function entfuncs.run_l(id)
    if ents[id].ct==nil then
        ents[id].ct=0
        if pstate.hasrun==true then
            table.remove(ents,id)
            return
        end
    end
    local dt=getDT()

    ents[id].ct=ents[id].ct+dt

    ents[id].y=ents[id].y-math.sin(ents[id].ct*2)*10*dt

    for plyr=1,#p do
        if hitbox(ents[id].x,ents[id].y,16,16,p[plyr].x,p[plyr].y-p[plyr].h/2) then
            pstate.hasrun=true
            collectanim=true
            handy=52-17*4
            pearly=handy
            collected=runpearl
            pearltx=-42
            pearlty=52-17*4
            colstr="Collected run! Hold x(Right Trigger) to run!"
            save()
            table.remove(ents,id)
            return
        end
    end

    love.graphics.draw(runpearl,ents[id].x,ents[id].y)

end

function entfuncs.float_l(id)
    if ents[id].ct==nil then
        ents[id].ct=0
        if pstate.hasfloat==true then
            table.remove(ents,id)
            return
        end
    end
    local dt=getDT()

    ents[id].ct=ents[id].ct+dt

    ents[id].y=ents[id].y-math.sin(ents[id].ct*2)*10*dt

    for plyr=1,#p do
        if hitbox(ents[id].x,ents[id].y,16,16,p[plyr].x,p[plyr].y-p[plyr].h/2) then
            pstate.hasfloat=true
            collectanim=true
            handy=52-17*2
            pearly=handy
            collected=floatpearl
            pearltx=-42
            pearlty=52-17*2
            colstr="Collected float! Hold S(Left Trigger) to float!"
            save()
            table.remove(ents,id)
            return
        end
    end

    love.graphics.draw(floatpearl,ents[id].x,ents[id].y)

end

function entfuncs.crawl_l(id)
    if ents[id].ct==nil then
        ents[id].ct=0
        if pstate.hascrawl==true then
            table.remove(ents,id)
            return
        end
    end
    local dt=getDT()

    ents[id].ct=ents[id].ct+dt

    ents[id].y=ents[id].y-math.sin(ents[id].ct*2)*10*dt

    for plyr=1,#p do
        if hitbox(ents[id].x,ents[id].y,16,16,p[plyr].x,p[plyr].y-p[plyr].h/2) then
            pstate.hascrawl=true
            collectanim=true
            handy=52-17
            pearly=handy
            collected=crawlpearl
            pearltx=-42
            pearlty=52-17
            colstr="Collected crawl! press down to squeeze through small gaps"
            save()
            table.remove(ents,id)
            return
        end
    end

    love.graphics.draw(crawlpearl,ents[id].x,ents[id].y)

end

function entfuncs.sword_l(id)
    if ents[id].ct==nil then
        ents[id].ct=0
        if pstate.hasswing==true then
            table.remove(ents,id)
            return
        end
    end
    local dt=getDT()

    ents[id].ct=ents[id].ct+dt

    ents[id].y=ents[id].y-math.sin(ents[id].ct*2)*10*dt

    for plyr=1,#p do
        if hitbox(ents[id].x,ents[id].y,16,16,p[plyr].x,p[plyr].y-p[plyr].h/2) then
            pstate.hasswing=true
            collectanim=true
            handy=52
            pearly=handy
            collected=swordpearl
            pearltx=-42
            pearlty=52
            colstr="Collected sword! Press A(x) to swing!"
            save()
            table.remove(ents,id)
            return
        end
    end

    love.graphics.draw(swordpearl,ents[id].x,ents[id].y)

end

function entfuncs.pearl_l(id)
    if ents[id].ct==nil then
        ents[id].ct=0
        if pearlsfound[mappath]~=nil then
            table.remove(ents,id)
            return
        end
    end
    local dt=getDT()

    ents[id].ct=ents[id].ct+dt

    ents[id].y=ents[id].y-math.sin(ents[id].ct*2)*10*dt

    for plyr=1,#p do
        if hitbox(ents[id].x,ents[id].y,16,16,p[plyr].x,p[plyr].y-p[plyr].h/2) then
            pearlsfound[mappath]=true
            print(pearlsfound[mappath])
            pstate.pearlcount=pstate.pearlcount+1
            pearlsfx:play()
            table.remove(ents,id)
            return
        end
    end

    love.graphics.draw(pearlspr,ents[id].x,ents[id].y)
end

function entfuncs.pearlRing_l(id)
    if ents[id].ct==nil then
        ents[id].ct=0
    end
    local dt=getDT()

    ents[id].ct=ents[id].ct+dt

    ents[id].y=ents[id].y-math.sin(ents[id].ct*2)*10*dt

    for plyr=1,#p do
        if hitbox(ents[id].x,ents[id].y,32,32,p[plyr].x,p[plyr].y-p[plyr].h/2) then
            if leveltransition~=true then
                wipestate=255
                leveltransition=true
                newmap="two"
                
            end
            table.remove(ents,id)
            return
        end
    end
    pearlring:setPosition(ents[id].x-32,ents[id].y-32)
    pearlring:draw()
    resdraw()
end


--platforms
function entfuncs.dropplat_l(id)
    if ents[id].ct==nil then
        ents[id].vx=0
        ents[id].vy=0
        ents[id].ct=0
        ents[id].trig=false
    end

    local dt=getDT()

    if platlogic(id) 
    and ents[id].trig==false then
        ents[id].trig = true
        ents[id].ct=0.7
        creak:play()
    end

    love.graphics.draw(dropplat,ents[id].x,ents[id].y-8)

    if ents[id].trig==true then
        ents[id].ct=ents[id].ct-dt
        if ents[id].ct<0 then
            --play a crunch sound
            sp_ptc(ents[id].x,ents[id].y,0,30,1,dropplat,6)
            fall:play()
            table.remove(ents,id)
            return
        end
    end
end

--enemiez
function entfuncs.rustball_l(id)
    if ents[id].ct==nil then
        ents[id].vx=0
        ents[id].vy=0
        ents[id].ct=0
        ents[id].trig=false
        ents[id].health=3
        rustball=love.graphics.newImage("Sprites/rustball.png")
    end
    if paused~=true and pausing~=true and collectanim~= true then
        local dt=getDT()

        if ents[id].iframes~=nil then
            ents[id].iframes=ents[id].iframes-dt
            if ents[id].iframes<=0 then ents[id].iframes=nil end
        end

        local nplyr=getNearestPlayer(id)

        local mag=dist(p[nplyr].x,p[nplyr].y,ents[id].x,ents[id].y)

        for plyr=1,#p do
            if p[plyr].swingtimer>0.4 and ents[id].iframes == nil then
                if hitbox(p[plyr].swingx,p[plyr].swingy,p[plyr].swingw,p[plyr].swingh,ents[id].x-8,ents[id].y-20) 
                or hitbox(p[plyr].swingx,p[plyr].swingy,p[plyr].swingw,p[plyr].swingh,ents[id].x-8,ents[id].y+4) 
                or hitbox(p[plyr].swingx,p[plyr].swingy,p[plyr].swingw,p[plyr].swingh,ents[id].x+8,ents[id].y-20) 
                or hitbox(p[plyr].swingx,p[plyr].swingy,p[plyr].swingw,p[plyr].swingh,ents[id].x+8,ents[id].y+8) then
                    ents[id].health=ents[id].health-1
                    ents[id].vx=100*(ents[id].x+8-p[plyr].x)/mag
                    ents[id].vy=100*(ents[id].y+8-p[plyr].y)/mag
                    ents[id].iframes=1
                    splat(ents[id].x,ents[id].y-8,rustfrag1,p[1].swingdir)
                    sp_ent(ents[id].x,ents[id].y,"rustgib")
                    hitsfx()
                end
            else
                if hitbox(ents[id].x-6,ents[id].y-8,12,12,p[plyr].x+4,p[plyr].y) 
                or hitbox(ents[id].x-6,ents[id].y-8,12,12,p[plyr].x+4,p[plyr].y-p[plyr].h) 
                or hitbox(ents[id].x-6,ents[id].y-8,12,12,p[plyr].x-4,p[plyr].y) 
                or hitbox(ents[id].x-6,ents[id].y-8,12,12,p[plyr].x-4,p[plyr].y-p[plyr].h) then
                    hurtplyr(id)
                end
            end
        end

        if ents[id].health<=0 then
            splat(ents[id].x,ents[id].y-8,rustfrag1,p[nplyr].swingdir)
            splat(ents[id].x,ents[id].y-8,rustfrag2,p[nplyr].swingdir)
            sp_ent(ents[id].x,ents[id].y,"rustgib")
            sp_ent(ents[id].x,ents[id].y,"rustgib")
            sp_ent(ents[id].x,ents[id].y,"rustgib")
            table.remove(ents,id)
            return  
        end

        if ents[id].iframes == nil then
            if mag<80 then
                ents[id].vx=-50*(ents[id].x+8-p[1].x)/mag
                ents[id].vy=-50*(ents[id].y-p[1].y)/mag
            else
                ents[id].vx=ents[id].vx*(1-3*dt)
                ents[id].vy=ents[id].vy*(1-3*dt)
            end
        else
            ents[id].vx=ents[id].vx*(1-3*dt)
            ents[id].vy=ents[id].vy*(1-3*dt)
        end
        


        test=entcollision(id,16,16)
        if test.land==true then
            ents[id].vy=0
        elseif test.bonk==true then
            ents[id].vy=0
        elseif test.left==true then
            ents[id].vx=0
        elseif test.right==true then
            ents[id].vx=0
        end

        ents[id].x=ents[id].x+ents[id].vx*dt
        ents[id].y=ents[id].y+ents[id].vy*dt

        if ents[id].iframes~=nil then
            love.graphics.setColor(love.math.colorFromBytes(200,100,100))
        end
    end

    rustballanim:setPosition(ents[id].x-8,ents[id].y-16)
    rustballanim:draw()
    resdraw()
end


function entfuncs.rustwalk_l(id)
    if ents[id].ct==nil then
        ents[id].vx=40
        ents[id].vy=0
        ents[id].ct=0
        ents[id].trig=false
        rustwalk=love.graphics.newImage("Sprites/RustWalk.png")
    end

    local dt=getDT()

    ents[id].x=ents[id].x+ents[id].vx*dt
    ents[id].y=ents[id].y+ents[id].vy*dt

    ents[id].vy=ents[id].vy+550*dt

    if hitbox(ents[id].x-4,ents[id].y-6,8,8,p[1].x,p[1].y) then
        hurtplyr(id)
    end

    local ret=entcollision(id,8,8)

    if ret.right==true then
        ents[id].vx=-40
    elseif ret.left==true then
        ents[id].vx=40
    end

    love.graphics.draw(rustwalk,ents[id].x-4,ents[id].y-8)
end

function getNearestPlayer(id)
    local nearest=1
    local ndist=dist(p[1].x,p[1].y,ents[id].x,ents[id].y)

    if #p>1 then
        for plyr=2,#p do
            if dist(p[plyr].x,p[plyr].y,ents[id].x,ents[id].y)>ndist then
                nearest=plyr
            end
        end
    end

    return nearest
end

function entfuncs.walker_l(id)
    local spd=50
    if ents[id].vx==nil then
        ents[id].vx=0
        ents[id].vy=0
        ents[id].ct=0
        ents[id].trig=false
        ents[id].health=3
    end
    local dt=getDT()

    ents[id].y=ents[id].y+ents[id].vy*dt
    ents[id].x=ents[id].x+ents[id].vx*dt

    ents[id].vy=ents[id].vy+550*dt

    test=entcollision(id,8,16)

    nplyr = getNearestPlayer(id)

    local mag=dist(p[nplyr].x,p[nplyr].y,ents[id].x,ents[id].y)

    if test.right==true and ents[id].vx>0 then
        ents[id].vx=0
        --ents[id].x=ents[id].x-1
    elseif test.left==true and ents[id].vx<0 then
        ents[id].vx=0
        --ents[id].x=ents[id].x+1
    elseif test.land==true then
        if mag<80 then
            if p[1].x>ents[id].x then ents[id].vx=lerp(ents[id].vx,spd,10)
            else ents[id].vx=lerp(ents[id].vx,-spd,10) end
        else
            ents[id].vx=lerp(ents[id].vx,0,10)
        end
    end

    ents[id].ct=ents[id].ct-1

    if ents[id].iframes~=nil then
        ents[id].iframes=ents[id].iframes-dt
        if ents[id].iframes<=0 then ents[id].iframes=nil end
    end

    for plyr=1,#p do
        if p[plyr].swingtimer>0.4 and ents[id].iframes ==nil then
            if hitbox(p[plyr].swingx,p[plyr].swingy,p[plyr].swingw,p[plyr].swingh,ents[id].x,ents[id].y-2) 
            or hitbox(p[plyr].swingx,p[plyr].swingy,p[plyr].swingw,p[plyr].swingh,ents[id].x,ents[id].y-12) then
                ents[id].health=ents[id].health-1
                ents[id].vx=100*(ents[id].x+8-p[plyr].x)/mag
                ents[id].vy=-120
                ents[id].iframes=0.5
                splat(ents[id].x,ents[id].y-8,rustfrag1,p[plyr].swingdir)
                sp_ent(ents[id].x,ents[id].y,"rustgib")
                hitsfx()
            end
        else
            if hitbox(ents[id].x-4,ents[id].y-16,8,18,p[plyr].x+4,p[plyr].y) 
            or hitbox(ents[id].x-4,ents[id].y-16,8,18,p[plyr].x+4,p[plyr].y-p[plyr].h) 
            or hitbox(ents[id].x-4,ents[id].y-16,8,18,p[plyr].x-4,p[plyr].y) 
            or hitbox(ents[id].x-4,ents[id].y-16,8,18,p[plyr].x-4,p[plyr].y-p[plyr].h)then
                hurtplyr(id)
            end
        end
    end

    if ents[id].health<=0 then
        splat(ents[id].x,ents[id].y-8,rustfrag1,p[nplyr].swingdir)
        splat(ents[id].x,ents[id].y-8,rustfrag2,p[nplyr].swingdir)
        sp_ent(ents[id].x,ents[id].y,"rustgib")
        sp_ent(ents[id].x,ents[id].y,"rustgib")
        table.remove(ents,id)
        return  
    end

    if ents[id].vx<-10 then
        if rust2:getCurrentState()~='walkLeft' then
            rust2:setState('walkLeft')
        end
    elseif ents[id].vx>10 then
        if rust2:getCurrentState()~='walkRight' then
            rust2:setState('walkRight')
        end
    end

    if ents[id].iframes~=nil then
        love.graphics.setColor(love.math.colorFromBytes(200,100,100))
    end
    rust2:setPosition(ents[id].x-8,ents[id].y-16)
    rust2:draw()
    resdraw()

end

function entfuncs.walker_trig_l(id)

    if pstate.hasswing==true then
        sp_ent(ents[id].x,ents[id].y,"walker")
    end

    table.remove(ents,id)
    return  
end

function entfuncs.upbounce_l(id)
    for plyr=1,#p do
        if hitbox(ents[id].x-4,ents[id].y+2,16,8,p[plyr].x,p[plyr].y) then
            p[plyr].vy=-400
            p[plyr].jumped=true
            p[plyr].doublejumped=false
            bouncesfx()
        end
    end
    rustslimeanim:setPosition(ents[id].x,ents[id].y)
    rustslimeanim:setRotation(0)
    rustslimeanim:draw()
end

function entfuncs.leftbounce_l(id)
    for plyr=1,#p do
        if hitbox(ents[id].x-4,ents[id].y+10,16,18,p[plyr].x,p[plyr].y) then
            p[plyr].vx=-300
            p[plyr].vy=-200
            p[plyr].jumped=true
            p[plyr].doublejumped=false
            bouncesfx()
        end
    end
    rustslimeanim:setPosition(ents[id].x,ents[id].y+8)
    rustslimeanim:setRotation(-math.pi/2)
    rustslimeanim:draw()
end

function entfuncs.rightbounce_l(id)
    for plyr=1,#p do
        if hitbox(ents[id].x-4,ents[id].y+10,16,20,p[plyr].x,p[plyr].y) then
            p[plyr].vx=300
            p[plyr].vy=-200
            p[plyr].jumped=true
            p[plyr].doublejumped=false
            bouncesfx()
        end
    end
    rustslimeanim:setPosition(ents[id].x+8,ents[id].y)
    rustslimeanim:setRotation(math.pi/2)
    rustslimeanim:draw()
end

function bouncesfx()
    local num=math.random(1,4)
    if num==1 then bns1:play()
    elseif num==2 then bns2:play()
    elseif num==3 then bns3:play()
    elseif num==4 then bns4:play() end
end

--entgibs
function entfuncs.rustgib_l(id)
    if ents[id].vx==nil then
        ents[id].vx=p[1].swingdir*200+math.random(-20,20)
        ents[id].vy=p[1].vy+math.random(-20,20)
        ents[id].ang=0
        if love.math.random(1,2)==1 then
            ents[id].img=rustfrag1
        else
            ents[id].img=rustfrag2
        end
    end
    
    local dt=getDT()
    ents[id].vy=ents[id].vy+550*dt

    ents[id].y=ents[id].y+ents[id].vy*dt
    ents[id].x=ents[id].x+ents[id].vx*dt

    test=entcollision(id,8,16)

    if test.right==true and ents[id].vx>0 then
        ents[id].vx=0
    elseif test.left==true and ents[id].vx<0 then
        ents[id].vx=0
    elseif test.land==true then
        ents[id].vy=0
        ents[id].vx=ents[id].vx*(1-6*dt)
        ents[id].ang=ents[id].ang+dt*ents[id].vx
    end

    love.graphics.draw(ents[id].img,ents[id].x-2,ents[id].y-2,ents[id].ang,1,1,2,2)
end

--camera manips
function entfuncs.cam_R_l(id)
    mapright=ents[id].x-320
end

function entfuncs.cam_L_l(id)
    mapleft=ents[id].x
end
function entfuncs.cam_U_l(id)
    mapup=ents[id].y
end

function entfuncs.cam_D_l(id)
    mapdown=ents[id].y-180
end

function entcollision(id,w,h)
    local floor=math.floor
    local ceil=math.ceil
    local ret={}
    local dt=getDT()
    --bonk
    if checkSolid((ents[id].x-w/2),(ents[id].y-h)) 
    or checkSolid((ents[id].x+w/2),(ents[id].y-h)) 
    or checkSolid((ents[id].x    ),(ents[id].y-h))then
        if ents[id].vy<0 then
            ents[id].y=ceil(ents[id].y/8)*8
            ents[id].vy=0
            ret.bonk=true
        end
    end
    --land
    if checkSolid((ents[id].x-w/2),(ents[id].y)) 
    or checkSolid((ents[id].x+w/2),(ents[id].y)) 
    or checkSolid((ents[id].x   ),(ents[id].y)) then
        if ents[id].vy>0 then
            ents[id].y=floor(ents[id].y/8)*8
            ents[id].vy=0
            ret.land=true
        end
    end

    --right col
    if checkSolid((ents[id].x+w/2+ents[id].vx*dt),(ents[id].y-h+2)) 
    or checkSolid((ents[id].x+w/2+ents[id].vx*dt),(ents[id].y-2)) 
    or checkSolid((ents[id].x+w/2+ents[id].vx*dt),(ents[id].y-h/2)) then
        ret.right=true
    end
    --left col
    if checkSolid((ents[id].x-w/2+ents[id].vx*dt),(ents[id].y-h+2)) 
    or checkSolid((ents[id].x-w/2+ents[id].vx*dt),(ents[id].y-2)) 
    or checkSolid((ents[id].x-w/2+ents[id].vx*dt),(ents[id].y-h/2)) then
        ret.left=true
    end

    if checkDeath((ents[id].x-w/2+ents[id].vx*dt),(ents[id].y-h+2)) 
    or checkDeath((ents[id].x-w/2+ents[id].vx*dt),(ents[id].y-2)) 
    or checkDeath((ents[id].x),(ents[id].y)) 
    or checkDeath((ents[id].x),(ents[id].y-h))then
        ret.dead=true
    end

    return ret
end

function hitbox(x,y,w,h,tx,ty)
    if tx>x and tx<x+w
    and ty>y and ty<y+h then
        return true
    end
end

function dist(x1,y1,x2,y2)
    return math.sqrt((x2-x1)^2+(y2-y1)^2)
end


--platforms 
function platlogic(id,left,right)
   
    if not left then
        left =0
    end
    if not right then
        right = 16
    end
    
    local dt=getDT()
    for plyr=1, #p do
        if (p[plyr].x+p[plyr].vx*dt+p[plyr].w/2) < ents[id].x+right
        and (p[plyr].x+p[plyr].vx*dt+p[plyr].w/2) > ents[id].x+left
        and p[plyr].y+8+p[plyr].vy*dt > ents[id].y 
        and p[plyr].y+p[plyr].vy*dt < ents[id].y
        and p[plyr].vy>0  then
            landing(plyr)

            p[plyr].x = p[plyr].x+ents[id].vx
            p[plyr].y = ents[id].y-7+ents[id].vy

            return true
        end   
    end                 
end

function death()
    load()
end

function splat(x,y,img,dir)
    local rnd=math.random
    sp_ptc(x,y,rnd(dir*3,dir)*60,rnd(-2,1)*60,1,img)
    sp_ptc(x,y,rnd(dir*3,dir)*60,rnd(-2,1)*60,1,img)
    sp_ptc(x,y,rnd(dir*3,dir)*60,rnd(-2,1)*60,1,img)
    sp_ptc(x,y,rnd(dir*3,dir)*60,rnd(-2,1)*60,1,img)

end

function resdraw()
    love.graphics.setColor(love.math.colorFromBytes(255,255,255))
end

function hurtplyr(id)
    for plyr=1,#p do
        if p[plyr].iframes==nil then
            p[plyr].health=p[plyr].health-1
            if p[plyr].x<ents[id].x then
                p[plyr].vx=ents[id].vx*4-200
            else
                p[plyr].vx=ents[id].vx*4+200
            end

            if p[plyr].y<ents[id].y then
                p[plyr].vy=ents[id].vy*4-100
            else
                p[plyr].vy=ents[id].vy*4+100
            end

            p[plyr].iframes=0.7
            hurtsfx()
        end
    end
end

function hurtsfx()
    local num=math.random(1,4)
    if num==1 then pain1:play()
    elseif num==2 then pain2:play()
    elseif num==3 then pain3:play()
    elseif num==4 then pain4:play() end

end


function hitsfx()
    local num=math.random(1,6)
    if num==1 then hit1:play()
    elseif num==2 then hit2:play()
    elseif num==3 then hit3:play()
    elseif num==4 then hit4:play() 
    elseif num==5 then hit5:play()
    elseif num==6 then hit6:play() end
end

function kep_audio()
    local dt=getDT()

    if not wind:isPlaying( ) then
        --love.audio.play(wind)
    end
    if not waves:isPlaying( ) then
        --love.audio.play(waves)
    end 
    if not songs[1]:isPlaying( ) then
        for i=1,#songs do
            songs[i]:play()
            if current_track~=i then
                songs[i]:setVolume(0)
            else
                songs[i]:setVolume(mus_vol)
            end
            songs[i]:setLooping(true)
        end
    end

    if mapOST[mappath]~=current_track and mapOST[mappath]~="" and aud_transition==0 and gamestate == "play" then
        new_track=mapOST[mappath]
        aud_transition=aud_transition+dt


    elseif aud_transition>0 and aud_transition<transition_len then 
        aud_transition=aud_transition+dt

        songs[current_track]:setVolume((1-aud_transition/4)*mus_vol)

        songs[mapOST[mappath]]:setVolume((aud_transition/4)*mus_vol)

    elseif aud_transition>=transition_len then

        aud_transition=0
        current_track=mapOST[mappath]
    end

    
end


