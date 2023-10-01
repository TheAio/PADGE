local args={...}
_G.VERSION = "DEV_1"


local function readFile(path)
    if fs.exists(path) then
        local h=fs.open(path,"r")
        local returnData = {}
        while true do
            local i = h.readLine()
            if i == nil then break end
            returnData[#returnData+1] = i
        end
        h.close()
        return returnData
    else
        return {}
    end
end

if #args == 0 then
    error("Usage: PADGE <config>")
else
    if fs.exists(args[1]) then
        local configData = readFile(args[1])
        ModelsPath = string.sub(configData[1],9,string.len(configData[1]))
        MapPath = string.sub(configData[2],6,string.len(configData[2]))
    else
        error("PADGE: main config file not found")
    end
end

local Pine3D = require("Pine3D")

-- movement and turn speed of the camera
local speed = 2 -- units per second
local turnSpeed = 180 -- degrees per second

-- create a new frame
local ThreeDFrame = Pine3D.newFrame()

local objects = {
}
local objectInfo={

}

local function addModel(model,x,y,z,rx,ry,rz,isSolid,sizeX,sizeY,sizeZ)
  objects[#objects+1] = ThreeDFrame:newObject(ModelsPath..model, x, y, z, rx, ry, rz)
  objectInfo[#objectInfo+1] = {isSolid,sizeX,sizeY,sizeZ}
end

local function LoadMap()
  local rawMapData = readFile(MapPath)
  local brushes = {}
  if #rawMapData > 19999 then
    printError("WARNING: map contains",(#rawMapData/1000).."k lines!")
    print("This is will cause bad preformance!")
    print("To continue enter 'ok' and press enter")
    if read() ~= "ok" then
      return false
    end
  end
  for i=2,#rawMapData do
    local mapLine = 0
    local XLine = 0
    local YLine = 0
    local ZLine = 0
    local isSolidLine = 0
    local sizeXLine = 0
    local sizeYLine = 0
    local sizeZLine = 0
    print("Compiling map data:",100*(i/#rawMapData).."%")
    sleep(0)
    for j=1,string.len(rawMapData[i]) do --Model
      sleep(0)
      if string.sub(rawMapData[i],j,j) == "|" then
        mapLine=j+1
        break
      end
    end
    for j=mapLine,string.len(rawMapData[i]) do --XCord
      sleep(0)
      if string.sub(rawMapData[i],j,j) == "|" then
        XLine=j+1
        break
      end
    end
    for j=XLine,string.len(rawMapData[i]) do --YCord
      sleep(0)
      if string.sub(rawMapData[i],j,j) == "|" then
        YLine=j+1
        break
      end
    end
    for j=YLine,string.len(rawMapData[i]) do --ZCord
      sleep(0)
      if string.sub(rawMapData[i],j,j) == "|" then
        ZLine=j+1
        break
      end
    end
    for j=ZLine,string.len(rawMapData[i]) do --IsSolid
      sleep(0)
      if string.sub(rawMapData[i],j,j) == "|" then
        isSolidLine=j+1
        break
      end
    end
    for j=isSolidLine,string.len(rawMapData[i]) do --sizeX
      sleep(0)
      if string.sub(rawMapData[i],j,j) == "|" then
        sizeXLine=j+1
        break
      end
    end
    for j=sizeXLine,string.len(rawMapData[i]) do --sizeY
      sleep(0)
      if string.sub(rawMapData[i],j,j) == "|" then
        sizeYLine=j+1
        break
      end
    end
    for j=sizeYLine,string.len(rawMapData[i]) do --sizeZ
      sleep(0)
      if string.sub(rawMapData[i],j,j) == "|" then
        sizeZLine=j+1
        break
      end
    end
    brushes[#brushes+1] = {string.sub(rawMapData[i],1,mapLine-2),
    tonumber(string.sub(rawMapData[i],mapLine,XLine-2)),
    tonumber(string.sub(rawMapData[i],XLine,YLine-2)),
    tonumber(string.sub(rawMapData[i],YLine,ZLine-2)),
    tonumber(string.sub(rawMapData[i],ZLine,isSolidLine-2)),
    tonumber(string.sub(rawMapData[i],isSolidLine,sizeXLine-2)),
    tonumber(string.sub(rawMapData[i],sizeXLine,sizeYLine-2)),
    tonumber(string.sub(rawMapData[i],sizeYLine,string.len(rawMapData[i])-1))
  }
  end
  for i=1,#brushes do
    print("Building map:",100*(i/#brushes).."%")
    --print(brushes[i][1],brushes[i][2],brushes[i][3],brushes[i][4],0,0,0,brushes[i][5])
    sleep(0)
    addModel(brushes[i][1],brushes[i][2],brushes[i][3],brushes[i][4],0,0,0,brushes[i][5],brushes[i][6],brushes[i][7],brushes[i][8])
  end
end
LoadMap()

----Advanced physics----
function IsAreaFree(x,y,z)
  if Debug_ShowCords then
    term.setCursorPos(1,1)
    print("X:"..x,"Y:"..y,"Z:"..z)
  end
  if Cheat_NoClip then
    return {true,true,true}
  end
  for i=1,#objects do
    local ox = objects[i][1]
    local oy = objects[i][2]
    local oz = objects[i][3]
    local sizeX = objectInfo[i][2]
    local sizeY = objectInfo[i][3]
    local sizeZ = objectInfo[i][4]
    local isXFree=true
    local isYFree=true
    local isZFree=true
    if (not ((x>ox+sizeX or x<ox-sizeX) or (y>oy+sizeY or y<oy-sizeY) or (z>oz+sizeZ or z<oz-sizeZ))) and objectInfo[i][1] == 1 then
      if not (x>ox+sizeX or x<ox-sizeX) then
        isXFree = false
      end
      if not (y>oy+sizeY or y<oy-sizeY) then
        isYFree = false
      end
      if not (z>oz+sizeZ or z<oz-sizeZ) then
        isZFree = false
      end
      return {isXFree,isYFree,isZFree}
    end
  end
  return {true,true,true}
end

----Modifiers----
Cheat_NoClip=false
Debug_ShowCords=false

-- initialize our own camera or update the frame camera
local camera = {
  x = 0,
  y = 0,
  z = 0,
  rotX = 0,
  rotY = 0,
  rotZ = 0,
}
ThreeDFrame:setCamera(camera)

-- handle all keypresses and store in a lookup table
-- to check later if a key is being pressed
local keysDown = {}
local function keyInput()
  while true do
    -- wait for an event
    local event, key, x, y = os.pullEvent()

    if event == "key" then -- if a key is pressed, mark it as being pressed down
      keysDown[key] = true
    elseif event == "key_up" then -- if a key is released, reset its value
      keysDown[key] = nil
    end
  end
end

-- update the camera position based on the keys being pressed
-- and the time passed since the last step
JumpCounter=0
local function handleCameraMovement(dt)
  local dx, dy, dz = 0, 0, 0 -- will represent the movement per second

  -- handle arrow keys for camera rotation
  if keysDown[keys.left] then
    camera.rotY = (camera.rotY - turnSpeed * dt) % 360
  end
  if keysDown[keys.right] then
    camera.rotY = (camera.rotY + turnSpeed * dt) % 360
  end
  if keysDown[keys.down] then
    camera.rotZ = math.max(-80, camera.rotZ - turnSpeed * dt)
  end
  if keysDown[keys.up] then
    camera.rotZ = math.min(80, camera.rotZ + turnSpeed * dt)
  end
  if keysDown[keys.f1] then
    keysDown={}
    if Cheat_NoClip then
      Cheat_NoClip=false
    else
      Cheat_NoClip=true
    end
    sleep(0.5)
  end

  -- handle wasd keys for camera movement
  if keysDown[keys.w] then
    dx = speed * math.cos(math.rad(camera.rotY)) + dx
    dz = speed * math.sin(math.rad(camera.rotY)) + dz
  end
  if keysDown[keys.s] then
    dx = -speed * math.cos(math.rad(camera.rotY)) + dx
    dz = -speed * math.sin(math.rad(camera.rotY)) + dz
  end
  if keysDown[keys.a] then
    dx = speed * math.cos(math.rad(camera.rotY - 90)) + dx
    dz = speed * math.sin(math.rad(camera.rotY - 90)) + dz
  end
  if keysDown[keys.d] then
    dx = speed * math.cos(math.rad(camera.rotY + 90)) + dx
    dz = speed * math.sin(math.rad(camera.rotY + 90)) + dz
  end

  -- space and left shift key for moving the camera up and down
  local isJumping=false
  if keysDown[keys.space] then
    if JumpCounter < 0.2 then
      isJumping = true
      JumpCounter = JumpCounter + dt
      dy = (speed*2) + dy
    end
  elseif JumpCounter > 0 then
    JumpCounter = JumpCounter - dt
  end
  if keysDown[keys.leftShift] and Cheat_NoClip then
    dy = -speed + dy
  end

  -- update the camera position by adding the offset
  local nextX = camera.x + dx * dt
  local nextY = camera.y + dy * dt
  local nextZ = camera.z + dz * dt
  local allow = IsAreaFree(nextX,nextY,nextZ)
  local gravTest = IsAreaFree(nextX,nextY-1,nextZ)
  if isJumping then
    nextY = nextY + speed*dt
  else
    if gravTest[2] and not Cheat_NoClip then
      nextY = nextY - speed*dt
    end
  end
  if allow[1] then
    camera.x = nextX
  end
  if allow[2] then
    camera.y = nextY
  end
  if allow[3] then
    camera.z = nextZ
  end
  ThreeDFrame:setCamera(camera)
end

-- handle the game logic and camera movement in steps
local function gameLoop()
  local lastTime = os.clock()

  while true do
    -- compute the time passed since last step
    local currentTime = os.clock()
    local dt = currentTime - lastTime
    lastTime = currentTime

    -- run all functions that need to be run
    handleCameraMovement(dt)

    -- use a fake event to yield the coroutine
    os.queueEvent("gameLoop")
    os.pullEventRaw("gameLoop")
  end
end

-- render the objects
local function rendering()
  while true do
    -- load all objects onto the buffer and draw the buffer
    ThreeDFrame:drawObjects(objects)
    ThreeDFrame:drawBuffer()

    -- use a fake event to yield the coroutine
    os.queueEvent("rendering")
    os.pullEventRaw("rendering")
  end
end

-- start the functions to run in parallel
parallel.waitForAny(keyInput, gameLoop, rendering)
