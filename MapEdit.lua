Models = {}
Map = {}
Selected=1
View="TOP"
RendView=5

function UpdateModelsList()
    if not fs.exists("models/") then
        printError("[ERROR] No models/ path found!")
        error()
    end
    return fs.list("models/")
end
function LoadMap(path)
    if path == nil then
        print("Enter map file path:")
        local path = read()
    end
    if not fs.exists(path) then
        printError("[WARNING] Path not found!")
        return {}
    end
    local h=fs.open(path,"r")
    local mapData = {}
    print("Reading map file...")
    while true do
        sleep(0)
        local i = h.readLine()
        if i == nil then break end
        mapData[#mapData+1] = i
    end
    h.close()
    local brushes={}
    for i=2,#mapData do
        local mapLine = 0
        local XLine = 0
        local YLine = 0
        local ZLine = 0
        local isSolidLine = 0
        local sizeXLine = 0
        local sizeYLine = 0
        local sizeZLine = 0
        print("Compiling map data:",100*(i/#mapData).."%")
        sleep(0)
        for j=1,string.len(mapData[i]) do --Model
          sleep(0)
          if string.sub(mapData[i],j,j) == "|" then
            mapLine=j+1
            break
          end
        end
        for j=mapLine,string.len(mapData[i]) do --XCord
          sleep(0)
          if string.sub(mapData[i],j,j) == "|" then
            XLine=j+1
            break
          end
        end
        for j=XLine,string.len(mapData[i]) do --YCord
          sleep(0)
          if string.sub(mapData[i],j,j) == "|" then
            YLine=j+1
            break
          end
        end
        for j=YLine,string.len(mapData[i]) do --ZCord
          sleep(0)
          if string.sub(mapData[i],j,j) == "|" then
            ZLine=j+1
            break
          end
        end
        for j=ZLine,string.len(mapData[i]) do --IsSolid
          sleep(0)
          if string.sub(mapData[i],j,j) == "|" then
            isSolidLine=j+1
            break
          end
        end
        for j=isSolidLine,string.len(mapData[i]) do --sizeX
          sleep(0)
          if string.sub(mapData[i],j,j) == "|" then
            sizeXLine=j+1
            break
          end
        end
        for j=sizeXLine,string.len(mapData[i]) do --sizeY
          sleep(0)
          if string.sub(mapData[i],j,j) == "|" then
            sizeYLine=j+1
            break
          end
        end
        for j=sizeYLine,string.len(mapData[i]) do --sizeZ
          sleep(0)
          if string.sub(mapData[i],j,j) == "|" then
            sizeZLine=j+1
            break
          end
        end
        brushes[#brushes+1] = {string.sub(mapData[i],1,mapLine-2), --Name
        tonumber(string.sub(mapData[i],mapLine,XLine-2))+1, --XCord
        tonumber(string.sub(mapData[i],XLine,YLine-2))+1, --YCord
        tonumber(string.sub(mapData[i],YLine,ZLine-2))+1, --ZCord
        tonumber(string.sub(mapData[i],ZLine,isSolidLine-2)), --Solidity
        tonumber(string.sub(mapData[i],isSolidLine,sizeXLine-2)), --XSize
        tonumber(string.sub(mapData[i],sizeXLine,sizeYLine-2)), --YSize
        tonumber(string.sub(mapData[i],sizeYLine,string.len(mapData[i])-1)) --ZSize
      }
    end
    return brushes
end
function DrawMap(renderArea,viewMode,selected,WinX,WinY,Width)
    term.clear()
    for i = 1,#Map do
        sleep(0)
        local renX=0
        local renY=0
        if viewMode == "TOP" then
            renX=Map[i][2]+renderArea+WinX
            renY=Map[i][4]+renderArea+WinY
        elseif viewMode == "FRONT" then
            renX=Map[i][2]+renderArea+WinX
            renY=Map[i][3]+renderArea+WinY
        elseif viewMode == "LEFT" then
            renX=Map[i][4]+renderArea+WinX
            renY=Map[i][3]+renderArea+WinY
        end
        if not ((renX>WinX+Width) or (renX>WinX+Width)) then
            term.setCursorPos(renX,renY)
            if i == selected then
                term.setBackgroundColor(colors.orange)
            else
                term.setBackgroundColor(colors.blue)
            end
            printError(i)
            term.setBackgroundColor(colors.black)
        end
    end
    term.setCursorPos(1,18)
end
function AddModel(model,x,y,z,solidity,sizeX,sizeY,sizeZ)
    if fs.exists("models/"..model) then
        Map[#Map+1] = {model,x,y,z,solidity,sizeX,sizeY,sizeZ}
    else
        printError("[WARNING] model not found")
    end
end
function RemoveModel(id)
    local tempMap={}
    for i=1,#Map do
        sleep(0)
        if i ~= id then
            tempMap[#tempMap+1] = Map[i]
        end
    end
    Map = tempMap
end
function MoveModel(id,x,y,z)
    if id>#Map or id<1 then
        printError("[WARNING] model id not found")
    end
    Map[id][2]=x
    Map[id][3]=y
    Map[id][4]=z
end
function ModelInfo(id)
    if id>#Map or id<1 then
        printError("[WARNING] model id not found")
    end
    print("Model:",Map[id][1])
    print("XCord:",Map[id][2])
    print("YCord:",Map[id][3])
    print("ZCord:",Map[id][4])
    print("Solid:",Map[id][5])
    print("XSize:",Map[id][6])
    print("YSize:",Map[id][7])
    print("ZSize:",Map[id][8])
end
function Save(path)
    local h = fs.open(path,"w")
    h.writeLine("model|x|y|z|solidity|sizeX|sizeY|sizeZ|")
    for i=1,#Map do
        print("Saveing map",100*(i/#Map).."%")
        sleep(0)
        local line = Map[i][1].."|"..Map[i][2].."|"..Map[i][3].."|"..Map[i][4].."|"..Map[i][5].."|"..Map[i][6].."|"..Map[i][7].."|"..Map[i][8].."|"
        h.writeLine(line)
    end
    h.close()
end
Map = LoadMap("ENGTST.map")
while true do
    print("Command?")
    local command = read()
    if command == "exit" then
        break
    elseif command == "sel" then
        print("Select model 0-"..#Map)
        Selected = tonumber(read())
        if Selected == nil then Selected = 1 end
    elseif command == "add" then
        print("Model?")
        shell.run("ls models/")
        local mod=read()
        print("x?")
        local xc = tonumber(read())
        print("y?")
        local yc = tonumber(read())
        print("z?")
        local zc = tonumber(read())
        print("solidity?")
        local sol = tonumber(read())
        print("x size?")
        local xs = tonumber(read())
        print("y size? or C to cube")
        local ys = read()
        if string.upper(ys) == "C" then
            ys = xs
            zs = xs
        else
            ys = tonumber(ys)
        end
        print("z size?")
        zs = tonumber(read())
        Map[#Map+1] = {mod,xc,yc,zc,sol,xs,ys,zs}
    elseif command == "rem" then
        RemoveModel(Selected)
    elseif command == "mov" then
        print("x?")
        local sx=tonumber(read())
        print("y?")
        local sy=tonumber(read())
        print("z?")
        local sz=tonumber(read())
        MoveModel(Selected,sx,sy,sz)
    elseif command == "inf" then
        ModelInfo(Selected)
    elseif command == "FR" then
        View = "FRONT"
    elseif command == "TO" then
        View = "TOP"
    elseif command == "LE" then
        View = "LEFT"
    elseif command == "RV" then
        print("New render view?")
        RendView = tonumber(read())
    elseif command == "update" then
        UpdateModelsList()
    elseif command == "MERGE" then
        print("Map path?")
        local newMap=LoadMap(read())
        for i=1,#newMap do
            Map[#Map+1] = newMap[i]
        end
    elseif command == "LOAD" then
        print("Map path?")
        Map=LoadMap(read())
    elseif command == "SAVE" then
        print("File path?")
        Save(read())
    elseif command == "HELP" then
        print("exit - quit")
        print("sel - select model")
        print("add - add model")
        print("rem - remove model")
        print("mov - move model")
        print("inf - model info")
        print("FR - front view")
        print("TO - top view")
        print("LE - left view")
        print("RV - set render view")
        print("update - update models list")
        print("MERGE - merger with map")
        print("LOAD - load another map")
        print("SAVE - save map to file")
    end
    read()
    DrawMap(RendView,View,Selected,1,1,10)
    sleep(0.25)
end
