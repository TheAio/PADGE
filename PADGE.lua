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
        if configData[1] ~= "ENG_VER = ".._G.VERSION then
            error("PADGE: incompatible config file, expected ".."ENG_VER = ".._G.VERSION.." got "..configData[1])
        end
        ModelsPath = string.sub(configData[2],9,string.len(configData[2]))
        MapPath = string.sub(configData[3],6,string.len(configData[3]))
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

-- initialize our own camera and update the frame camera
local camera = {
  x = 0,
  y = 0,
  z = 0,
  rotX = 0,
  rotY = 0,
  rotZ = 0,
}
ThreeDFrame:setCamera(camera)

local objects = {
}

local function addModel(model,x,y,z,rx,ry,rz)
    objects[#objects+1] = ThreeDFrame:newObject(ModelsPath..model, x, y, z, rx, ry, rz)
end

local function addMap()
    local rawMapData = readFile(MapPath)
    camera = {x = tonumber(rawMapData[2]),y = tonumber(rawMapData[3]),z = tonumber(rawMapData[4]),
    rotX = 0,rotY = 0,rotZ = 0}
    local models = {}
    local mapLine = 0
    for i=6,#rawMapData do
        local j = rawMapData[i]
        mapLine = i
        if j == "Map:" then break end
        models[#models+1] = rawMapData[i]
    end
    local counter=mapLine+1
    while true do
        if counter == #rawMapData+5 or counter == #rawMapData+1 then
            print(counter,"break")
            break 
        end
        local toAdd = {models[tonumber(rawMapData[counter])],rawMapData[counter+1],rawMapData[counter+2],rawMapData[counter+3],
        rawMapData[counter+4],rawMapData[counter+5],rawMapData[counter+6]}
        print(counter,toAdd[1],tonumber(toAdd[2]),tonumber(toAdd[3]),tonumber(toAdd[4]),tonumber(toAdd[5]),tonumber(toAdd[6]),tonumber(toAdd[7]))
        addModel(toAdd[1],tonumber(toAdd[2]),tonumber(toAdd[3]),tonumber(toAdd[4]),tonumber(toAdd[5]),tonumber(toAdd[6]),tonumber(toAdd[7]))
        counter=counter+7
    end
end
addMap()
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
  if keysDown[keys.space] then
    dy = speed + dy
  end
  if keysDown[keys.leftShift] then
    dy = -speed + dy
  end

  -- update the camera position by adding the offset
  camera.x = camera.x + dx * dt
  camera.y = camera.y + dy * dt
  camera.z = camera.z + dz * dt

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