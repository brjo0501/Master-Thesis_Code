---- lua

sim = require 'sim'
simVision = require 'simVision'
RingBuffer = require("modelscripts/ring_buffer")

function sysCall_init()
    -- Prepare a floating view with the camera views:
    cam = sim.getObject('.')
    --view = sim.floatingViewAdd(0.1, 0.9, 0.2, 0.2, 0)
    --sim.adjustView(view, cam, 90)

    graph = sim.getObject('/Graph')
    events = sim.getObject('/Events')
    buffer = RingBuffer:new(7)
    writeBuffer(buffer)

    assemblyCounter = 1

    customTable = {enabledCamera = true, id = 0, sizeX = 0, sizeY = 0, posX = 0, posY = 0}

    writeCustomInfo(customTable)

    partSizeX = sim.addGraphStream(graph, 'Part size X-Dir', 'mm', 0, {1, 0, 0})
    partSizeY = sim.addGraphStream(graph, 'Part size Y-Dir', 'mm', 0, {0, 1, 0})

    itemSizeX = 160
    itemSizeY = 160

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

        --camData['posX'] = blobData[11]
        --camData['posY'] = blobData[12]
        --camData['sizeX'] = blobData[13]
        --camData['sizeY'] = blobData[14]



        scalingFactorX = 160/0.7734375
        scalingFactorY = 160/0.7734375

        local camData = readCustomInfo()

        --local enableWindow = sim.readCustomDataBlock(detect4,'customData')
        --local newTable1 = sim.unpackTable(enableWindow)


        if (blobData[13] ~= nil or blobData[14] ~=nil) and camData['enabledCamera'] and trigger then
            if blobData[11]> 0.45 and blobData[11] < 0.55 and blobData[12]> 0.45 and blobData[12] < 0.55 then -- inside camera area

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

                --print(itemSizeX,itemSizeY)

                --imgName = sim.getStringParameter(sim.stringparam_scene_path)..'/Images/cam3/cam3_v2_'..index..'.png'
                --sim.saveImage(img,res,0,imgName,-1)

                --if (itemSizeX < 52 and itemSizeY < 52) and (itemSizeX > 48 and itemSizeY > 48) then
                detect = true
                --   id = index
                --elseif (itemSizeX < 42 and itemSizeY < 42) and (itemSizeX > 38 and itemSizeY > 38) then
                --    detect = false
                --    id = index
                --end

                index = index + 1
                camData['id'] = id
                camData['detect'] = detect

                --print(camData)
                writeCustomInfo(camData)
                trigger = false
                local event = sim.readCustomDataBlock(events,'customData')
                local eventList = sim.unpackTable(event)
                local eventInput = {['cam 3']=sim.getSimulationTime(),['assembly'] = assemblyCounter}
                local newEntry = #(eventList) + 1
                eventList[newEntry] = eventInput
                sim.writeCustomDataBlock(events,'customData',sim.packTable(eventList))
                assemblyCounter = assemblyCounter + 1
                --print(itemSizeX,itemSizeY)
                --print('cam 3 - '..sim.getSimulationTime())
            end
        elseif blobCount <2 or blobCount > 2 then
            trigger = true
        end

        --sim.setGraphStreamValue(graph, partSizeX, itemSizeX)
        --sim.setGraphStreamValue(graph, partSizeY, itemSizeY)

    end
    --simVision.workImgToSensorImg(inData.handle)
    return retVal
end
