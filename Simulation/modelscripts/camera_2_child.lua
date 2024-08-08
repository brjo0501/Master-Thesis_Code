-- lua

sim = require 'sim'
simVision = require 'simVision'
RingBuffer = require("modelscripts/ring_buffer")

function sysCall_init()
    -- Prepare a floating view with the camera views:
    cam = sim.getObject('.')
    con2 = sim.getObject("/genericConveyorTypeA[2]")
    --view = sim.floatingViewAdd(0.1, 0.7, 0.2, 0.2, 0)
    --sim.adjustView(view, cam, 90)

    graph = sim.getObject('/Graph')
    events = sim.getObject('/Events')
    buffer = RingBuffer:new(7)
    writeBuffer(buffer)

    assemblyCounter = 1

    partSizeX = sim.addGraphStream(graph, 'Part size X-Dir', 'mm', 0, {1, 0, 0})
    partSizeY = sim.addGraphStream(graph, 'Part size Y-Dir', 'mm', 0, {0, 1, 0})

    itemSizeX = 200
    itemSizeY = 200

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
        print(retVal)
    end

    if packedPacket then
        retVal.packedPackets[#retVal.packedPackets + 1] = packedPacket

        -- Unpack the packet to get blob data
        local blobData = sim.unpackFloatTable(packedPacket)

        local blobCount = blobData[1]

        scalingFactorX = 200/0.7578125
        scalingFactorY = 200/0.7578125

        local camData = readCustomInfo()

        --local enableWindow2 = sim.readCustomDataBlock(detect2,'customData')
        --local enableWindow3 = sim.readCustomDataBlock(detect3,'customData')
        --local newTable2 = sim.unpackTable(enableWindow2)
        --local newTable3 = sim.unpackTable(enableWindow3)

        local camera_enabled = camData['enabledCamera']
        --print(camera_enabled)
        if (blobData[13] ~= nil or blobData[14] ~=nil) and camera_enabled and trigger then
            if blobData[11]> 0.45 and blobData[11] < 0.55 and blobData[12]> 0.45 and blobData[12] < 0.55 then -- inside camera area

                camData['posX'] = blobData[11]
                camData['posY'] = blobData[12]
                camData['sizeX'] = blobData[13]
                camData['sizeY'] = blobData[14]

                --print(blobData[13],blobData[14])

                itemSizeX = blobData[13]*scalingFactorX
                itemSizeY = blobData[14]*scalingFactorY
                id = index

                buffer = readBuffer()

                buffer:push({id,camData['sizeX'],camData['sizeY']})
                sim.writeCustomDataBlock(con2,'partTrigger-Cam2',sim.packTable({trigger = true}))

                writeBuffer(buffer)

                --imgName = sim.getStringParameter(sim.stringparam_scene_path)..'/Images/cam2/cam2_v2_'..index..'.png'
                --sim.saveImage(img,res,0,imgName,-1)

                if (itemSizeX < 220 and itemSizeY < 220) and (itemSizeX > 180 and itemSizeY > 180) then
                   detect = true
                   id = index
                else
                   detect = false
                   id = index
                end

                index = index + 1
                camData['id'] = id
                camData['detect'] = detect

                --print(camData)
                writeCustomInfo(camData)
                trigger = false
                local event = sim.readCustomDataBlock(events,'customData')
                local eventList = sim.unpackTable(event)
                local eventInput = {['cam 2']=sim.getSimulationTime(),['assembly'] = assemblyCounter}
                local newEntry = #(eventList) + 1
                eventList[newEntry] = eventInput
                sim.writeCustomDataBlock(events,'customData',sim.packTable(eventList))
                assemblyCounter = assemblyCounter + 1
                --print(itemSizeX,itemSizeY)
                --print('cam 2 - '..sim.getSimulationTime())
            end
        elseif blobCount <2 or blobCount > 2 then
            trigger = true
        end
        --sim.setGraphStreamValue(graph, partSizeX, itemSizeX)
       -- sim.setGraphStreamValue(graph, partSizeY, itemSizeY)
    end
    --simVision.workImgToSensorImg(inData.handle)
    return retVal
end
