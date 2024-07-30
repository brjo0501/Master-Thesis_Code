simBWF=require('simBWF')
RingBuffer = require("modelscripts/ring_buffer")
function getTriggerType()
    if stopTriggerSensor~=-1 then
        local data=sim.readCustomDataBlock(stopTriggerSensor,'XYZ_BINARYSENSOR_INFO')
        if data then
            data=sim.unpackTable(data)
            local state=data['detectionState']
            if not lastStopTriggerState then
                lastStopTriggerState=state
            end
            if lastStopTriggerState~=state then
                lastStopTriggerState=state
                return -1 -- means stop
            end
        end
    end
    if startTriggerSensor~=-1 then
        local data=sim.readCustomDataBlock(startTriggerSensor,'XYZ_BINARYSENSOR_INFO')
        if data then
            data=sim.unpackTable(data)
            local state=data['detectionState']
            if not lastStartTriggerState then
                lastStartTriggerState=state
            end
            if lastStartTriggerState~=state then
                lastStartTriggerState=state
                return 1 -- means restart
            end
        end
    end
    return 0
end

function overrideMasterMotionIfApplicable(override)
    if masterConveyor>=0 then
        local data=sim.readCustomDataBlock(masterConveyor,simBWF.modelTags.CONVEYOR)
        if data then
            data=sim.unpackTable(data)
            local stopRequests=data['stopRequests']
            if override then
                stopRequests[model]=true
            else
                stopRequests[model]=nil
            end
            data['stopRequests']=stopRequests
            sim.writeCustomDataBlock(masterConveyor,simBWF.modelTags.CONVEYOR,sim.packTable(data))
        end
    end
end

function getMasterDeltaShiftIfApplicable()
    if masterConveyor>=0 then
        local data=sim.readCustomDataBlock(masterConveyor,simBWF.modelTags.CONVEYOR)
        if data then
            data=sim.unpackTable(data)
            local totalShift=data['encoderDistance']
            local retVal=totalShift
            if previousMasterTotalShift then
                retVal=totalShift-previousMasterTotalShift
            end
            previousMasterTotalShift=totalShift
            return retVal
        end
    end
end

function sysCall_init()
    model=sim.getObject('.')
    local data=sim.readCustomDataBlock(model,simBWF.modelTags.CONVEYOR)
    data=sim.unpackTable(data)
    stopTriggerSensor=simBWF.getReferencedObjectHandle(model,1)
    startTriggerSensor=simBWF.getReferencedObjectHandle(model,2)
    masterConveyor=simBWF.getReferencedObjectHandle(model,3)
    getTriggerType()
    length=data['length']
    height=data['height']
    local err=sim.getInt32Param(sim.intparam_error_report_mode)
    sim.setInt32Param(sim.intparam_error_report_mode,0) -- do not report errors
    textureB=sim.getObject('./genericConveyorTypeA_textureB')
    textureC=sim.getObject('./genericConveyorTypeA_textureC')
    jointB=sim.getObject('./genericConveyorTypeA_jointB')
    jointC=sim.getObject('./genericConveyorTypeA_jointC')
    sim.setInt32Param(sim.intparam_error_report_mode,err) -- report errors again
    textureA=sim.getObject('./genericConveyorTypeA_textureA')
    forwarderA=sim.getObject('./genericConveyorTypeA_forwarderA')
    lastT=sim.getSimulationTime()
    beltVelocity=0
    totShift=0
    local customData=sim.readCustomDataBlock(model,'customData')
    local customData = sim.unpackTable(customData)
    base_speed = customData['speed']
    speed_noise = 0
    phase_shift = math.random()*math.pi*2

    buffer = RingBuffer:new(7)
    writeBuffer(buffer,'buffer')

    bufferIndex = RingBuffer:new(7)
    writeBuffer(bufferIndex,'bufferIndex')
    
    rob1 = sim.getObject("/Ragnar[0]")

    sim.writeCustomDataBlock(model,'partTrigger',sim.packTable({trigger = false}))

    index3 = 0
    newIndex3 = 0
    oldIndex3 = 0
    step = 0
    speeds3 = RingBuffer:new(300)
    time3 = 0

end

function readBuffer(buffer)
    data = sim.readCustomDataBlock(model,buffer)
    if data then
        data=sim.unpackTable(data)
        data = RingBuffer:fromTable(data)
    end
    return data
end

function writeBuffer(data,buffer)
    if data then
        sim.writeCustomDataBlock(model,buffer,sim.packTable(data))
    else
        sim.writeCustomDataBlock(model,buffer,'')
    end
end

function average(data)
    local sum = 0
    for i = 1, #data do
        if data[i] then
            sum = sum + data[i]
        end
    end
    return sum / #data
end

function var(data, average)
    local sum_of_squares = 0
    for i = 1, #data do
        if data[i] then
            sum_of_squares = sum_of_squares + (data[i] - average) ^ 2
        end
    end
    return sum_of_squares / #data
end

function table_remove(t, num)
    for i = 1 , num-1 do
        table.remove(t,i)
    end
    return t
end

function subTable(t,index3)
    local subTable = {}
    for i=index3, #t do
        if t[i] then
            table.insert(subTable,t[i])
        end
    end
    return subTable
end

function sysCall_actuation()
    local data=sim.readCustomDataBlock(model,simBWF.modelTags.CONVEYOR)
    data=sim.unpackTable(data)

    local customData=sim.readCustomDataBlock(model,'customData')
    customData = sim.unpackTable(customData)

    local time = sim.getSimulationTime()
    math.randomseed(time,speed_noise)

    -- using Box_Muller method
    local noise = (((2*math.log(1/math.random()))^.5)*math.cos(2*math.pi*math.random())*0.10)
    if base_speed ~= 0 then
        speed_noise = base_speed + noise --2.5*math.sin(math.pi*2*sim.getSimulationTime()/20+phase_shift)
    else
        speed_noise = 0
    end

    trigger1 = sim.unpackTable(sim.readCustomDataBlock(model,'partTrigger'))
    if trigger1['trigger'] then
        sim.writeCustomDataBlock(model,'partTrigger',sim.packTable({trigger = false}))
        newIndex3 = {index3}
        bufferIndex:push(newIndex3)
    end    
    
    index3 = index3 + 1

    speeds3:push({speed_noise})

    if oldIndex3 ~= bufferIndex:peek()[1] and bufferIndex:peek()[1] ~= 0 then
        step = step + 1
        peekLength = 356.25/(base_speed*0.05)
        if step  == peekLength then
            newIndex3 = bufferIndex:pop()[1]
            speedData = {}
            speedData = speeds3:peekBuffer(peekLength)
        
            --sim.pauseSimulation()

            for i=1, (newIndex3-oldIndex3) do
                speeds3:pop()
            end
            
            step = 0
            buffer:push({#speedData,average(speedData),var(speedData,average(speedData))})
            --buffer:print()
            writeBuffer(buffer,'buffer')
            oldIndex3 = newIndex3
        end
    end



    
    
    -- if  #speeds3 == 356.25/(base_speed*0.05)+bufferIndex:peek()[1] and bufferIndex:peek()[1] > 0 then -- distance up to tracking window minus part width
    --     newIndex3 = bufferIndex:pop()[1]
    --     speedData = {}
    --     speedsTemp = {}

    --     for i=newIndex3, (#speeds3) do
    --         speedData[i-newIndex3+1] = speeds3[i]
    --         speedsTemp[i] = speeds3[i]
    --     end

    --     --speeds3 = speedsTemp

    --     buffer:push({#speedData,average(speedData),var(speedData,average(speedData))})
    --     --buffer:print()

    -- end

    -- index3 = index3 + 1

    -- speeds3[index3] = speed_noise

    customData['speed'] = speed_noise
    sim.writeCustomDataBlock(model,'customData',sim.packTable(customData))
    --print(customData)
    data['velocity'] = speed_noise/1000
    maxVel=data['velocity']
    accel=data['acceleration']
    enabled=(data['bitCoded']&64)>0
    if not enabled then
        maxVel=0
    end
    local stopRequests=data['stopRequests']
    local trigger=getTriggerType()
    if trigger>0 then
        stopRequests[model]=nil -- restart
    end
    if trigger<0 then
        stopRequests[model]=true -- stop
    end
    if next(stopRequests) then
        maxVel=0
        overrideMasterMotionIfApplicable(true)
    else
        overrideMasterMotionIfApplicable(false)
    end

    t=sim.getSimulationTime()
    dt=t-lastT
    lastT=t

    local masterDeltaShift=getMasterDeltaShiftIfApplicable()
    if masterDeltaShift then
        totShift=totShift+masterDeltaShift
        beltVelocity=masterDeltaShift/dt
    else
        local dv=maxVel-beltVelocity
        if math.abs(dv)>accel*dt then
            beltVelocity=beltVelocity+accel*dt*math.abs(dv)/dv
        else
            beltVelocity=maxVel
        end
        totShift=totShift+dt*beltVelocity
    end

    --sim.setObjectFloatParam(textureA,sim.shapefloatparam_texture_y,totShift)

    -- if textureB~=-1 then
    --     sim.setObjectFloatParam(textureB,sim.shapefloatparam_texture_y,length*0.5+0.041574*height/0.2+totShift)
    --     sim.setObjectFloatParam(textureC,sim.shapefloatparam_texture_y,-length*0.5-0.041574*height/0.2+totShift)
    --     local a=sim.getJointPosition(jointB)
    --     sim.setJointPosition(jointB,a-beltVelocity*dt*2/height)
    --     sim.setJointPosition(jointC,a-beltVelocity*dt*2/height)
    -- end

    relativeLinearVelocity={0,beltVelocity,0}

    sim.resetDynamicObject(forwarderA)
    m=sim.getObjectMatrix(forwarderA,-1)
    m[4]=0
    m[8]=0
    m[12]=0
    absoluteLinearVelocity=sim.multiplyVector(m,relativeLinearVelocity)
    sim.setObjectFloatParam(forwarderA,sim.shapefloatparam_init_velocity_x,absoluteLinearVelocity[1])
    sim.setObjectFloatParam(forwarderA,sim.shapefloatparam_init_velocity_y,absoluteLinearVelocity[2])
    sim.setObjectFloatParam(forwarderA,sim.shapefloatparam_init_velocity_z,absoluteLinearVelocity[3])
    data['encoderDistance']=totShift
    sim.writeCustomDataBlock(model,simBWF.modelTags.CONVEYOR,sim.packTable(data))
end