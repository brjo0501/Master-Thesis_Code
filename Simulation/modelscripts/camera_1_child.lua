-- lua

sim = require 'sim'
simVision = require 'simVision'
RingBuffer = require("modelscripts/ring_buffer")

function sysCall_init()
    -- Prepare a floating view with the camera views:
    cam = sim.getObject('.')
    --view = sim.floatingViewAdd(0.1, 0.5, 0.2, 0.2, 0)
    --sim.adjustView(view, cam, 90)

    graph = sim.getObject('/Graph')
    events = sim.getObject('/Events')
    
    buffer = RingBuffer:new(25)

    writeBuffer(buffer)

    assemblyCounter = 1

    partSizeX = sim.addGraphStream(graph, 'Part size X-Dir', 'mm', 0, {1, 0, 0})
    partSizeY = sim.addGraphStream(graph, 'Part size Y-Dir', 'mm', 0, {0, 1, 0})

    itemSizeX = 50
    itemSizeY = 50

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

    local camera_enabled = camData['enabledCamera']
    --print(camera_enabled)

    local retVal = {}
    retVal.trigger = false
    retVal.packedPackets = {}


    simVision.sensorImgToWorkImg(inData.handle)

    --simVision.colorSegmentationOnWorkImg(inData.handle, )

    simVision.edgeDetectionOnWorkImg(inData.handle, 0.3)

    local trig, packedPacket = simVision.blobDetectionOnWorkImg(inData.handle, 0.100000, 0.000000, true)

    if trig then
        retVal.trigger = true
        print(retVal)
    end

    if packedPacket then
        retVal.packedPackets[#retVal.packedPackets + 1] = packedPacket

        -- Unpack the packet to get blob data
        local blobData = sim.unpackFloatTable(packedPacket)

        local blobCount = blobData[1]

        scalingFactorX = 50/0.6328125
        scalingFactorY = 50/0.6328125

        --local enableWindow = sim.readCustomDataBlock(detect1,'customData')
        --local newTable1 = sim.unpackTable(enableWindow)

        local camera_enabled = camData['enabledCamera']
        --print(camera_enabled)
        if (blobData[13] ~= nil or blobData[14] ~=nil) and camera_enabled and trigger then
            if blobData[11]> 0.47 and blobData[11] < 0.53 and blobData[12]> 0.47 and blobData[12] < 0.53 then -- inside camera area

                camData['posX'] = blobData[11]
                camData['posY'] = blobData[12]
                camData['sizeX'] = blobData[13]
                camData['sizeY'] = blobData[14]

                itemSizeX = blobData[13]*scalingFactorX
                itemSizeY = blobData[14]*scalingFactorY
                id = index

                buffer = readBuffer()

                buffer:push({id,camData['sizeX'],camData['sizeY']})

                writeBuffer(buffer)

                --imgName = sim.getStringParameter(sim.stringparam_scene_path)..'/Images/cam1/cam1_v2_'..index..'.png'
                --sim.saveImage(img,res,0,imgName,-1)

                if (itemSizeX < 55 and itemSizeY < 55) and (itemSizeX > 45 and itemSizeY > 45) then
                    detect = true
                else
                    detect = false
                    --print('not okay')
                end

                index = index + 1
                camData['id'] = id
                camData['detect'] = detect
                writeCustomInfo(camData)
                trigger = false
                --print(itemSizeX,itemSizeY,detect)
                --print('cam 1 - '..sim.getSimulationTime())

                local event = sim.readCustomDataBlock(events,'customData')
                local eventList = sim.unpackTable(event)
                local eventInput = {['cam 1']=sim.getSimulationTime(),['assembly'] = assemblyCounter}
                local newEntry = #(eventList) + 1
                eventList[newEntry] = eventInput
                sim.writeCustomDataBlock(events,'customData',sim.packTable(eventList))

                if id%4 == 0 then
                    assemblyCounter = assemblyCounter + 1
                end
            end
        elseif blobCount > 1 and blobData[12] > 0.45 and blobData[12] < 0.55 then
            trigger = true
        end
        
       -- sim.setGraphStreamValue(graph, partSizeX, itemSizeX)
        --sim.setGraphStreamValue(graph, partSizeY, itemSizeY)

    end
    --simVision.workImgToSensorImg(inData.handle)
    return retVal
end
