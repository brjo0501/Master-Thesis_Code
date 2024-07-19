---- lua

sim = require 'sim'
simVision = require 'simVision'
RingBuffer = require("modelscripts/ring_buffer")

function sysCall_init()
    -- Prepare a floating view with the camera views:
    cam = sim.getObject('.')
    --view = sim.floatingViewAdd(0.9, 0.5, 0.2, 0.2, 0)
    --sim.adjustView(view, cam, 90)
    
    graph = sim.getObject('/Graph')

    events = sim.getObject('/Events')

    products = sim.getObject('/Products')

    buffer = RingBuffer:new(25)

    writeBuffer(buffer)

    assemblyCounter = 1
    
    customTable = {enabledCamera = true, part1PosX = 0,part1PosY = 0, part1SizeX = 0,part1SizeY = 0,
                                         part2PosX = 0,part2PosY = 0, part2SizeX = 0,part2SizeY = 0,
                                         part3PosX = 0,part3PosY = 0, part3SizeX = 0,part3SizeY = 0,
                                         part4PosX = 0,part4PosY = 0, part4SizeX = 0,part4SizeY = 0,
                                         tray1PosX = 0, tray1PosY =0, tray1SizeX = 0,tray1SizeY = 0,
                                         tray2PosX = 0, tray2PosY =0, tray2SizeX = 0,tray2SizeY = 0}
                                         --id = 0, detect = true, tray1 = 0, tray2 = 0} --correctCount = 0, wrongCount = 0,
    writeCustomInfo(customTable)
    
    partSizeX = sim.addGraphStream(graph, 'Part size X-Dir', 'mm', 0, {1, 0, 0})
    partSizeY = sim.addGraphStream(graph, 'Part size Y-Dir', 'mm', 0, {0, 1, 0})
    
    index = 1 
    trigger = true
    
end

function readCustomInfo()
    local data=sim.readCustomDataBlock(cam,'customData')
    if data then
        data=sim.unpackTable(data)
    end
    return data
end

function writeCustomInfo(data)
    if data then
        sim.writeCustomDataBlock(cam,'customData',sim.packTable(data))
    else
        sim.writeCustomDataBlock(cam,'customData','')
    end
end

function readBuffer()
    data = sim.readCustomDataBlock(cam,'buffer')
    if data then
        data=sim.unpackTable(data)
        data = RingBuffer:fromTable(data)
    end
    return data
end

function writeBuffer(data)
    if data then
        sim.writeCustomDataBlock(cam,'buffer',sim.packTable(data))
    else
        sim.writeCustomDataBlock(cam,'buffer','')
    end
end

function sysCall_cleanup()
    if sim.isHandle(cam) then
        --sim.floatingViewRemove(view)
    end
end

function sysCall_vision(inData)
    
    img, res = sim.getVisionSensorImg(cam)

    local camData = readCustomInfo()
    
    local retVal = {}
    retVal.trigger = false
    retVal.packedPackets = {}
    
    
    simVision.sensorImgToWorkImg(inData.handle)
    
    --simVision.colorSegmentationOnWorkImg(inData.handle, )
    
    simVision.edgeDetectionOnWorkImg(inData.handle, 0.3)
    

    local trig, packedPacket = simVision.blobDetectionOnWorkImg(inData.handle, 0.100000, 0.000000, true)

    if trig then
        retVal.trigger = true
    end

    if packedPacket then
        retVal.packedPackets[#retVal.packedPackets + 1] = packedPacket

        -- Unpack the packet to get blob data
        local blobData = sim.unpackFloatTable(packedPacket)
        
        --print(blobData)
        
        local blobCount = blobData[1]
        
        local correctCount = 0
        local wrongCount = 0
        local tray1 = 0
        local tray2 = 0
                
        local msg = ''
        --print(blobData)
        
        if blobCount > 1 and trigger then
            if blobData[12] > 0.49 and blobData[12] < 0.51 and blobData[11] > 0.49 and blobData[11] < 0.51 then  --tray inside scan area
                id = index
                imgName = sim.getStringParameter(sim.stringparam_scene_path)..'/Images/cam4/cam4_v2_'..index..'.png'
                --sim.saveImage(img,res,0,imgName,-1)
            
                camData['tray1PosX'] = blobData[11]
                camData['tray1PosY'] = blobData[12]
                camData['tray1SizeX'] = blobData[13]
                camData['tray1SizeY'] = blobData[14]
                
                camData['tray2PosX'] = blobData[17]
                camData['tray2PosY'] = blobData[18]
                camData['tray2SizeX'] = blobData[19]
                camData['tray2SizeY'] = blobData[20]
                
                camData['part1PosX'] = blobData[23]
                camData['part1PosY'] = blobData[24]
                camData['part1SizeX'] = blobData[25]
                camData['part1SizeY'] = blobData[26]
                
                camData['part2PosX'] = blobData[29]
                camData['part2PosY'] = blobData[30]
                camData['part2SizeX'] = blobData[31]
                camData['part2SizeY'] = blobData[32]
                
                camData['part3PosX'] = blobData[35]
                camData['part3PosY'] = blobData[36]
                camData['part3SizeX'] = blobData[37]
                camData['part3SizeY'] = blobData[38]
                
                camData['part4PosX'] = blobData[41]
                camData['part4PosY'] = blobData[42]
                camData['part4SizeX'] = blobData[43]
                camData['part4SizeY'] = blobData[44]

                buffer = readBuffer()

                buffer:push({id,camData['tray1SizeX'],camData['tray1SizeY'],camData['tray2SizeX'],camData['tray2SizeY'],
                                camData['part1SizeX'],camData['part1SizeY'],camData['part2SizeX'],camData['part2SizeY'],
                                camData['part3SizeX'],camData['part3SizeY'],camData['part4SizeX'],camData['part4SizeY']})

                writeBuffer(buffer)

                --if  blobCount > 3 then
                                
                --     if blobData[13] < 0.83359375 and blobData[13] > 0.68203125 and blobData[14] < 0.83359375 and blobData[14] > 0.68203125 then -- [180,220]
                --         tray1 = 1
                --     end
                    
                --     if blobData[19] < 0.69609375 and blobData[19] > 0.56953125 and blobData[20] < 0.69609375  and blobData[20] > 0.56953125 then -- [144,176]
                --         tray2 = 1
                --     end
                    
                --     local startX = 25
                --     local startY = 26
                    
                --     for i=1,blobCount-3,1 do
                --         if blobData[startX] < 0.2320315 and blobData[startX] > 0.18984375 and blobData[startY] < 0.2320315 and blobData[startY] > 0.18984375 then -- [45,55]
                --             correctCount = correctCount +1
                --         else --if blobData[startX] < 0.18 and blobData[startX] > 0.16 and blobData[startY] < 0.18 and blobData[startY] > 0.16 then
                --             wrongCount = wrongCount + 1
                --         end
                --         startX = startX + 6
                --         startY = startY + 6
                --     end
                --     msg = 'EoL: '..correctCount..' correct and '..wrongCount..' defect'
                    
                -- elseif blobCount == 3 then
                --     if blobData[13] < 0.83359375 and blobData[13] > 0.68203125 and blobData[14] < 0.83359375 and blobData[14] > 0.68203125 then -- [180,220]
                --         tray1 = 1
                --     end
                --     if blobData[19] < 0.69609375 and blobData[19] > 0.56953125 and blobData[20] < 0.69609375  and blobData[20] > 0.56953125 then -- [144,176]
                --         tray2 = 1
                --     end
                --     msg = 'EoL: no parts' 
                    
                -- elseif  blobCount == 2 then
                --     if blobData[13] < 0.83359375 and blobData[13] > 0.68203125 and blobData[14] < 0.83359375 and blobData[14] > 0.68203125 then
                --         tray1 = 1
                --     end
                --     msg = 'EoL: no blue tray' 
                -- end
    
                index = index + 1
                
                -- camData['wrongCount'] = wrongCount
                -- camData['tray1'] = tray1
                -- camData['tray2'] = tray2
                
                --print(camData)
                --print(camData['id'], msg)
                trigger = false
                --print('cam 4 - '..sim.getSimulationTime())
                local event = sim.readCustomDataBlock(events,'customData')
                
                local eventList = sim.unpackTable(event)
                local eventInput = {['cam EoL']=sim.getSimulationTime(),['assembly'] = assemblyCounter}
                local newEntry = #(eventList) + 1
                eventList[newEntry] = eventInput
                sim.writeCustomDataBlock(events,'customData',sim.packTable(eventList))

                productsData = sim.unpackTable(sim.readCustomDataBlock(products,'customData'))
                productsData['newProduct'] = {true}
                sim.writeCustomDataBlock(products,'customData',sim.packTable(productsData))
                assemblyCounter = assemblyCounter + 1
            end
        elseif blobCount > 1 and blobData[12] > 0.48 and blobData[12] < 0.52 then
            trigger = true
        end
        
        writeCustomInfo(camData)
        
        --sim.setGraphStreamValue(graph, partSizeX, itemSizeX)
        --sim.setGraphStreamValue(graph, partSizeY, itemSizeY)
        
    end
    --simVision.workImgToSensorImg(inData.handle)
    return retVal
end
