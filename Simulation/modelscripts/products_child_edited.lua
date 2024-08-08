-- lua

sim = require 'sim'
simVision = require 'simVision'
RingBuffer = require("modelscripts/ring_buffer")

function sysCall_init()

    products = sim.getObject('.')

    camera1 = sim.getObject("/camera_1/camera")
    camera2 = sim.getObject("/camera_2/camera")
    camera3= sim.getObject("/camera_3/camera")

    cameraEoL = sim.getObject("/camera_EoL/camera")

    conveyor1 = sim.getObject("/genericConveyorTypeA[0]")
    conveyor2 = sim.getObject("/genericConveyorTypeA[2]")
    conveyor3 = sim.getObject("/genericConveyorTypeA[1]")

    rob1 = sim.getObject("/Ragnar[0]")
    rob2 = sim.getObject("/Ragnar[1]")

    productsData = {newProduct = {false}}
    writeCustomInfo(productsData)

    data ={}
    partsCount = 0
    productData = {}

end

function vacuumCheck(list)
    if list then
        for i = 1, #list do if list[i] ~= 0 then return true end end
    end
    return false
end

function sysCall_actuation()

    productsData = readCustomInfo()

    if productsData['newProduct'][1] then

        partsCount = partsCount + 1
        cam1Buffer = readBuffer(camera1,'buffer')
        cam2Buffer = readBuffer(camera2,'buffer')
        cam3Buffer = readBuffer(camera3,'buffer')

        camEoLBuffer = readBuffer(cameraEoL,'buffer')

        con1Buffer = readBuffer(conveyor1,'buffer')
        con2Buffer = readBuffer(conveyor2,'buffer')
        con3Buffer = readBuffer(conveyor3,'buffer')

        rob1_1Buffer = readBuffer(rob1,'buffer1')
        rob1_2Buffer = readBuffer(rob1,'buffer2')
        rob1_3Buffer = readBuffer(rob1,'buffer3')
        rob1_4Buffer = readBuffer(rob1,'buffer4')

        rob1_SupplyBuffer = readBuffer(rob1,'buffer5')
        rob1_VacuumBuffer = readBuffer(rob1,'buffer6')
        rob1_MaxVelBuffer = readBuffer(rob1,'buffer7')

        rob2_1Buffer = readBuffer(rob2,'buffer1')
        rob2_2Buffer = readBuffer(rob2,'buffer2')
        rob2_3Buffer = readBuffer(rob2,'buffer3')
        rob2_4Buffer = readBuffer(rob2,'buffer4')

        rob2_SupplyBuffer = readBuffer(rob2,'buffer5')
        rob2_VacuumBuffer = readBuffer(rob2,'buffer6')
        rob2_MaxVelBuffer = readBuffer(rob2,'buffer7')

        camEoLData = camEoLBuffer:pop()
        writeBuffer(cameraEoL,'buffer',camEoLBuffer)
        productData['EoL_1_X'] = {camEoLData[2]}
        productData['EoL_1_Y'] = {camEoLData[3]}
        productData['EoL_2_X'] = {camEoLData[4]}
        productData['EoL_2_Y'] = {camEoLData[5]}
        productData['EoL_3_X'] = {camEoLData[6]}
        productData['EoL_3_Y'] = {camEoLData[7]}
        productData['EoL_4_X'] = {camEoLData[8]}
        productData['EoL_4_Y'] = {camEoLData[9]}
        productData['EoL_5_X'] = {camEoLData[10]}
        productData['EoL_5_Y'] = {camEoLData[11]}
        productData['EoL_6_X'] = {camEoLData[12]}
        productData['EoL_6_Y'] = {camEoLData[13]}

        for i = 1, 4 do
            cam1Data = cam1Buffer:pop()
            writeBuffer(camera1,'buffer',cam1Buffer)
            productData['cam_1_X'..i] = {cam1Data[2]}
            productData['cam_1_Y.'..i] = {cam1Data[3]}

            rob2_SupplyData = rob2_SupplyBuffer:pop()
            writeBuffer(rob2,'buffer5',rob2_SupplyBuffer)
            productData['rob_2_supply.'..i] = rob2_SupplyData

            rob2_VacuumData = rob2_VacuumBuffer:pop()
            writeBuffer(rob2,'buffer6',rob2_VacuumBuffer)
            productData['rob_2_vacuum.'..1] = rob2_VacuumData

            rob2_MaxVelData = rob2_MaxVelBuffer:pop()
            writeBuffer(rob2,'buffer7',rob2_MaxVelBuffer)
            productData['rob_2_maxVel.'..i] = rob2_MaxVelData

            con1_Data = con1Buffer:pop()
            writeBuffer(conveyor1,'buffer',con1Buffer)
            productData['con_1.'..i] = con1_Data
            

            if  (camEoLData[2*i+4] and camEoLData[2*i+5]) or not vacuumCheck(rob2_VacuumData) then
                rob2_1Data = rob2_1Buffer:pop()
                writeBuffer(rob2,'buffer1',rob2_1Buffer)
                productData['rob_2_1.'..i] = rob2_1Data

                rob2_2Data = rob2_2Buffer:pop()
                writeBuffer(rob2,'buffer2',rob2_2Buffer)
                productData['rob_2_2.'..i] = rob2_2Data

                rob2_3Data = rob2_3Buffer:pop()
                writeBuffer(rob2,'buffer3',rob2_3Buffer)
                productData['rob_2_3.'..i] = rob2_3Data

                rob2_4Data = rob2_4Buffer:pop()
                writeBuffer(rob2,'buffer4',rob2_4Buffer)
                productData['rob_2_4.'..i] = rob2_4Data
                
            end
        end

        rob1_VacuumData = rob1_VacuumBuffer:pop()
        writeBuffer(rob1,'buffer6',rob1_VacuumBuffer)
        rob1_VacuumBuffer = readBuffer(rob1,'buffer6')
        productData['rob_1_vacuum'] = rob1_VacuumData

        rob1_SupplyData = rob1_SupplyBuffer:pop()
        writeBuffer(rob1,'buffer5',rob1_SupplyBuffer)
        productData['rob_1_supply'] = rob1_SupplyData

        rob1_MaxVelData = rob1_MaxVelBuffer:pop()
        writeBuffer(rob1,'buffer7',rob1_MaxVelBuffer)
        productData['rob_1_maxVel'] = rob1_MaxVelData

        con2_Data = con2Buffer:pop()
        writeBuffer(conveyor2,'buffer',con2Buffer)
        productData['con_2'] = con2_Data

        con3_Data = con3Buffer:pop()
        writeBuffer(conveyor3,'buffer',con3Buffer)
        productData['con_3'] = con3_Data

        if (camEoLData[4] and camEoLData[5]) or not vacuumCheck(rob1_VacuumData) then

            rob1_1Data = rob1_1Buffer:pop()
            writeBuffer(rob1,'buffer1',rob1_1Buffer)
            productData['rob_1_1'] = rob1_1Data
            rob1_2Data = rob1_2Buffer:pop()
            writeBuffer(rob1,'buffer2',rob1_2Buffer)
            productData['rob_1_2'] = rob1_2Data
            rob1_3Data = rob1_3Buffer:pop()
            writeBuffer(rob1,'buffer3',rob1_3Buffer)
            productData['rob_1_3'] = rob1_3Data
            rob1_4Data = rob1_4Buffer:pop()
            writeBuffer(rob1,'buffer4',rob1_4Buffer)
            productData['rob_1_4'] = rob1_4Data
        end

        cam2Data = cam2Buffer:pop()
        writeBuffer(camera2,'buffer',cam2Buffer)
        productData['cam_2_X'] = {cam2Data[2]}
        productData['cam_2_Y'] = {cam2Data[3]}

        cam3Data = cam3Buffer:pop()
        writeBuffer(camera3,'buffer',cam3Buffer)
        productData['cam_3_X'] = {cam2Data[2]}
        productData['cam_3_Y'] = {cam2Data[3]}

        productsData['ID'..partsCount] = productData
        
        productData = {}

        productsData['newProduct'] = {false}

        writeCustomInfo(productsData)
    end
end

function readCustomInfo()
    local data=sim.readCustomDataBlock(products,'customData')
    if data then
        data=sim.unpackTable(data)
    end
    return data
end

function writeCustomInfo(data)

    if data then
        sim.writeCustomDataBlock(products,'customData',sim.packTable(data))
    else
        sim.writeCustomDataBlock(products,'customData','')
    end
end

function readBuffer(obj,buffer)
    local data = sim.readCustomDataBlock(obj,buffer)
    if data then
        data=sim.unpackTable(data)
        data = RingBuffer:fromTable(data)
    end
    return data
end

function writeBuffer(obj,buffer,data)
    if data then
        sim.writeCustomDataBlock(obj,buffer,sim.packTable(data))
    else
        sim.writeCustomDataBlock(obj,buffer,'')
    end
end

