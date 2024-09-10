--lua

sim=require'sim'
simUI=require'simUI'
simBWF=require'simBWF'

function action1(ui,id, newVal)

    local enableWindow = sim.readCustomDataBlock(detectionWindow1,'customData')
    local enableCam = sim.readCustomDataBlock(camera1,'customData')

    local newTable1 = sim.unpackTable(enableWindow)
    local newTable2 = sim.unpackTable(enableCam)
    if newVal ~= 2 then
        newTable1['enabledDetection'] = true
        newTable2['enabledCamera'] = true

    else
        newTable1['enabledDetection'] = false
        newTable2['enabledCamera'] = false
    end

    sim.writeCustomDataBlock(detectionWindow1,'customData',sim.packTable(newTable1))
    sim.writeCustomDataBlock(camera1,'customData',sim.packTable(newTable2))

    simUI.setCheckboxValue(ui,id,simBWF.getCheckboxValFromBool(newTable1['enabledDetection']==false and newTable2['enabledCamera']==false ),true)
    print(sim.unpackTable(sim.readCustomDataBlock(detectionWindow1,'customData')))
    print(sim.unpackTable(sim.readCustomDataBlock(camera1,'customData')))
    showDlg()

end

function action2(ui,id, newVal)

    local enableWindow = sim.readCustomDataBlock(detectionWindow2,'customData')
    local enableCam = sim.readCustomDataBlock(camera2,'customData')

    local newTable1 = sim.unpackTable(enableWindow)
    local newTable2 = sim.unpackTable(enableCam)
    if newVal ~= 2 then
        newTable1['enabledDetection'] = true
        newTable2['enabledCamera'] = true

    else
        newTable1['enabledDetection'] = false
        newTable2['enabledCamera'] = false
    end

    sim.writeCustomDataBlock(detectionWindow2,'customData',sim.packTable(newTable1))
    sim.writeCustomDataBlock(camera2,'customData',sim.packTable(newTable2))

    simUI.setCheckboxValue(ui,id,simBWF.getCheckboxValFromBool(newTable1['enabledDetection']==false and newTable2['enabledCamera']==false ),true)
    print(sim.unpackTable(sim.readCustomDataBlock(detectionWindow2,'customData')))
    print(sim.unpackTable(sim.readCustomDataBlock(camera2,'customData')))
    showDlg()

end

function action3(ui,id, newVal)

    local enableWindow = sim.readCustomDataBlock(detectionWindow3,'customData')
    local enableCam = sim.readCustomDataBlock(camera3,'customData')

    local newTable1 = sim.unpackTable(enableWindow)
    local newTable2 = sim.unpackTable(enableCam)
    if newVal ~= 2 then
        newTable1['enabledDetection'] = true
        newTable2['enabledCamera'] = true

    else
        newTable1['enabledDetection'] = false
        newTable2['enabledCamera'] = false
    end

    sim.writeCustomDataBlock(detectionWindow3,'customData',sim.packTable(newTable1))
    sim.writeCustomDataBlock(camera3,'customData',sim.packTable(newTable2))

    simUI.setCheckboxValue(ui,id,simBWF.getCheckboxValFromBool(newTable1['enabledDetection']==false and newTable2['enabledCamera']==false ),true)
    print(sim.unpackTable(sim.readCustomDataBlock(detectionWindow3,'customData')))
    print(sim.unpackTable(sim.readCustomDataBlock(camera3,'customData')))
    showDlg()

end

function action10(ui,id)

    local conveyor = sim.readCustomDataBlock(conveyor1, 'customData')

    local newTable = sim.unpackTable(conveyor)

    local speed = tonumber((simUI.getSliderValue(ui,id)))
    newTable['speed'] = speed
    sim.writeCustomDataBlock(conveyor1,'customData',sim.packTable(newTable))
    simUI.setLabelText(ui,12,tostring(simUI.getSliderValue(ui,id)))
    showDlg()
end

function action20(ui,id)

    local conveyor = sim.readCustomDataBlock(conveyor2, 'customData')

    local newTable = sim.unpackTable(conveyor)

    local speed = tonumber((simUI.getSliderValue(ui,id)))

    newTable['speed'] = speed
    sim.writeCustomDataBlock(conveyor2,'customData',sim.packTable(newTable))
    simUI.setLabelText(ui,22,tostring(simUI.getSliderValue(ui,id)))
    showDlg()
end

function action30(ui,id)

    local conveyor = sim.readCustomDataBlock(conveyor3, 'customData')

    local newTable = sim.unpackTable(conveyor)

    local speed = tonumber((simUI.getSliderValue(ui,id)))

    newTable['speed'] = speed
    sim.writeCustomDataBlock(conveyor3,'customData',sim.packTable(newTable))
    simUI.setLabelText(ui,32,tostring(simUI.getSliderValue(ui,id)))
    showDlg()
end

function action40(ui,id,newVal)

    local feederData = sim.readCustomDataBlock(feeder1, simBWF.modelTags.PARTFEEDER)

    print(feederData)

    local newTable = sim.unpackTable(feederData)

    if newVal ~= 2 then
        newTable['nonIsoSizeScalingDistribution'] = [[{1,{(2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*0.5+50)/50,(2*math.log(1/math.random())^.5*math.sin(2*math.pi*math.random())*0.5+50)/50,1}}]]
        newTable['weightDistribution'] = [[{1,2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*0.001+0.10}]]
    else
        newTable['nonIsoSizeScalingDistribution'] = [[{1,{(2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*5+50)/50,(2*math.log(1/math.random())^.5*math.sin(2*math.pi*math.random())*5+50)/50,1}}]]
        newTable['weightDistribution'] = [[{1,2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*0.01+0.10}]]
    end
    sim.writeCustomDataBlock(feeder1,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    simUI.setCheckboxValue(ui,id,simBWF.getCheckboxValFromBool(newTable['nonIsoSizeScalingDistribution']==[[{1,{(2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*5+50)/50,(2*math.log(1/math.random())^.5*math.sin(2*math.pi*math.random())*5+50)/50,1}}]],true)) --{1,'CUBE_1'}
    print(sim.unpackTable(sim.readCustomDataBlock(feeder1,simBWF.modelTags.PARTFEEDER)))
    showDlg()
end

function interSize1()

    local feederData = sim.readCustomDataBlock(feeder1, simBWF.modelTags.PARTFEEDER)

    local newTable = sim.unpackTable(feederData)

    newTable['nonIsoSizeScalingDistribution'] = [[{1,{(2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*0.5+50)*40/(50*50),(2*math.log(1/math.random())^.5*math.sin(2*math.pi*math.random())*0.5+50)*40/(50*50),1}}]]
    newTable['weightDistribution'] = [[{1,(2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*0.001+0.10)*(40/50)}]]

    sim.writeCustomDataBlock(feeder1,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    sim.writeCustomDataBlock(feeder4,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    sim.writeCustomDataBlock(feeder5,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    sim.writeCustomDataBlock(feeder6,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))

    print('Intervention: size 1 has been modified')

end

function resetSize1()

    local feederData = sim.readCustomDataBlock(feeder1, simBWF.modelTags.PARTFEEDER)

    local newTable = sim.unpackTable(feederData)

    newTable['nonIsoSizeScalingDistribution'] = [[{1,{(2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*0.5+50)/50,(2*math.log(1/math.random())^.5*math.sin(2*math.pi*math.random())*0.5+50)/50,1}}]]
    newTable['weightDistribution'] = [[{1,(2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*0.001+0.10)}]]

    sim.writeCustomDataBlock(feeder1,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    sim.writeCustomDataBlock(feeder4,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    sim.writeCustomDataBlock(feeder5,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    sim.writeCustomDataBlock(feeder6,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    print('Intervention: size 1 has been reset')

end


function action50(ui,id,newVal)
    local feederData = sim.readCustomDataBlock(feeder2, simBWF.modelTags.PARTFEEDER)

    local newTable = sim.unpackTable(feederData)

    if newVal ~= 2 then
        newTable['frequency'] = 0
        newTable['nonIsoSizeScalingDistribution'] = [[{1,{(2*math.log(1/math.random())^.5*math.sin(2*math.pi*math.random())*2+200)/200,(2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*2+200)/200,1}}]]
        newTable['weightDistribution'] = [[{1,2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*0.004+0.40}]]
    else
        newTable['frequency'] = 0.125
        newTable['nonIsoSizeScalingDistribution'] = [[{1,{(2*math.log(1/math.random())^.5*math.sin(2*math.pi*math.random())*20+200)/200,(2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*20+200)/200,1}}]]
        newTable['weightDistribution'] = [[{1,2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*0.004+0.40}]]
    end
    sim.writeCustomDataBlock(feeder2,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    simUI.setCheckboxValue(ui,id,simBWF.getCheckboxValFromBool(newTable['nonIsoSizeScalingDistribution']==[[{1,{(2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*20+200)/200,(2*math.log(1/math.random())^.5*math.sin(2*math.pi*math.random())*20+200)/200,1}}]],true)) --{1,'CUBE_1'}
    print(sim.unpackTable(sim.readCustomDataBlock(feeder2,simBWF.modelTags.PARTFEEDER)))
    showDlg()

end

function action60(ui,id,newVal)
    local feederData = sim.readCustomDataBlock(feeder3, simBWF.modelTags.PARTFEEDER)

    local newTable = sim.unpackTable(feederData)

    if newVal ~= 2 then
        newTable['nonIsoSizeScalingDistribution'] = [[{1,{(2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*1.6+160)/160,(2*math.log(1/math.random())^.5*math.sin(2*math.pi*math.random())*1.6+160)/160,1}}]]
        newTable['weightDistribution'] = [[{1,2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*0.0036+0.36}]]
        --newTable['frequency'] = 0
    else
        newTable['nonIsoSizeScalingDistribution'] = [[{1,{(2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*16+160)/160,(2*math.log(1/math.random())^.5*math.sin(2*math.pi*math.random())*16+160)/160,1}}]]
        newTable['weightDistribution'] = [[{1,2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*0.036+0.36}]]
        --newTable['frequency'] = 0.125
    end
    sim.writeCustomDataBlock(feeder3,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    simUI.setCheckboxValue(ui,id,simBWF.getCheckboxValFromBool(newTable['nonIsoSizeScalingDistribution']==[[{1,{(2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*16+160)/160,(2*math.log(1/math.random())^.5*math.sin(2*math.pi*math.random())*16+160)/160,1}}]],true)) --{1,'CUBE_1'}
    print(sim.unpackTable(sim.readCustomDataBlock(feeder3,simBWF.modelTags.PARTFEEDER)))
    showDlg()
end

function interFeeder1()

    local feederData1 = sim.readCustomDataBlock(feeder1, simBWF.modelTags.PARTFEEDER)
    local feederData4=sim.readCustomDataBlock(feeder4,simBWF.modelTags.PARTFEEDER)
    local feederData5=sim.readCustomDataBlock(feeder5,simBWF.modelTags.PARTFEEDER)
    local feederData6=sim.readCustomDataBlock(feeder6,simBWF.modelTags.PARTFEEDER)

    local newTable1 = sim.unpackTable(feederData1)
    local newTable4 = sim.unpackTable(feederData4)
    local newTable5 = sim.unpackTable(feederData5)
    local newTable6 = sim.unpackTable(feederData6)

    newTable1['frequency'] = 0
    newTable4['frequency'] = 0
    newTable5['frequency'] = 0
    newTable6['frequency'] = 0


    sim.writeCustomDataBlock(feeder1,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable1))
    sim.writeCustomDataBlock(feeder4,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable4))
    sim.writeCustomDataBlock(feeder5,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable5))
    sim.writeCustomDataBlock(feeder6,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable6))
    print('Intervention: feeder 1,4,5,6 has been disabled')
end

function resetFeeder1()

    local feederData1 = sim.readCustomDataBlock(feeder1, simBWF.modelTags.PARTFEEDER)
    local feederData4=sim.readCustomDataBlock(feeder4,simBWF.modelTags.PARTFEEDER)
    local feederData5=sim.readCustomDataBlock(feeder5,simBWF.modelTags.PARTFEEDER)
    local feederData6=sim.readCustomDataBlock(feeder6,simBWF.modelTags.PARTFEEDER)

    local newTable1 = sim.unpackTable(feederData1)
    local newTable4 = sim.unpackTable(feederData4)
    local newTable5 = sim.unpackTable(feederData5)
    local newTable6 = sim.unpackTable(feederData6)

    newTable1['frequency'] = 0.125
    newTable4['frequency'] = 0.125
    newTable5['frequency'] = 0.125
    newTable6['frequency'] = 0.125

    sim.writeCustomDataBlock(feeder1,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable1))
    sim.writeCustomDataBlock(feeder4,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable4))
    sim.writeCustomDataBlock(feeder5,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable5))
    sim.writeCustomDataBlock(feeder6,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable6))
    print('Intervention: feeder 1,4,5,6 has been reset')

end

function interFeeder2()


    local feederData = sim.readCustomDataBlock(feeder2, simBWF.modelTags.PARTFEEDER)

    local newTable = sim.unpackTable(feederData)
    newTable['frequency'] = 0

    sim.writeCustomDataBlock(feeder2,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    print('Intervention: feeder 2 has been disabled')
end

function resetFeeder2()

    local feederData = sim.readCustomDataBlock(feeder2, simBWF.modelTags.PARTFEEDER)

    local newTable = sim.unpackTable(feederData)

    newTable['frequency'] = 0.125
    sim.writeCustomDataBlock(feeder2,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    print('Intervention: feeder 2 has been reset')

end


function interFeeder3()


    local feederData = sim.readCustomDataBlock(feeder3, simBWF.modelTags.PARTFEEDER)

    local newTable = sim.unpackTable(feederData)

    newTable['frequency'] = 0

    sim.writeCustomDataBlock(feeder3,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    print('Intervention: feeder 3 has been disabled')
end

function resetFeeder3()

    local feederData = sim.readCustomDataBlock(feeder3, simBWF.modelTags.PARTFEEDER)

    local newTable = sim.unpackTable(feederData)
    newTable['frequency'] = 0.125
    sim.writeCustomDataBlock(feeder3,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable))
    print('Intervention: feeder 3 has been reset')

end

function interFeederAll()

    local feederData1=sim.readCustomDataBlock(feeder1,simBWF.modelTags.PARTFEEDER)
    local feederData2=sim.readCustomDataBlock(feeder2,simBWF.modelTags.PARTFEEDER)
    local feederData3=sim.readCustomDataBlock(feeder3,simBWF.modelTags.PARTFEEDER)
    local feederData4=sim.readCustomDataBlock(feeder4,simBWF.modelTags.PARTFEEDER)
    local feederData5=sim.readCustomDataBlock(feeder5,simBWF.modelTags.PARTFEEDER)
    local feederData6=sim.readCustomDataBlock(feeder6,simBWF.modelTags.PARTFEEDER)

    local newTable1 = sim.unpackTable(feederData1)
    local newTable2 = sim.unpackTable(feederData2)
    local newTable3 = sim.unpackTable(feederData3)
    local newTable4 = sim.unpackTable(feederData4)
    local newTable5 = sim.unpackTable(feederData5)
    local newTable6 = sim.unpackTable(feederData6)

    newTable1['bitCoded'] = 10
    newTable2['bitCoded'] = 10
    newTable3['bitCoded'] = 10
    newTable4['bitCoded'] = 10
    newTable5['bitCoded'] = 10
    newTable6['bitCoded'] = 10

    sim.writeCustomDataBlock(feeder1,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable1))
    sim.writeCustomDataBlock(feeder2,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable2))
    sim.writeCustomDataBlock(feeder3,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable3))
    sim.writeCustomDataBlock(feeder4,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable4))
    sim.writeCustomDataBlock(feeder5,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable5))
    sim.writeCustomDataBlock(feeder6,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable6))

end

function resetFeederAll()

    local feederData1=sim.readCustomDataBlock(feeder1,simBWF.modelTags.PARTFEEDER)
    local feederData2=sim.readCustomDataBlock(feeder2,simBWF.modelTags.PARTFEEDER)
    local feederData3=sim.readCustomDataBlock(feeder3,simBWF.modelTags.PARTFEEDER)
    local feederData4=sim.readCustomDataBlock(feeder4,simBWF.modelTags.PARTFEEDER)
    local feederData5=sim.readCustomDataBlock(feeder5,simBWF.modelTags.PARTFEEDER)
    local feederData6=sim.readCustomDataBlock(feeder6,simBWF.modelTags.PARTFEEDER)

    local newTable1 = sim.unpackTable(feederData1)
    local newTable2 = sim.unpackTable(feederData2)
    local newTable3 = sim.unpackTable(feederData3)
    local newTable4 = sim.unpackTable(feederData4)
    local newTable5 = sim.unpackTable(feederData5)
    local newTable6 = sim.unpackTable(feederData6)

    newTable1['bitCoded'] = 2
    newTable2['bitCoded'] = 2
    newTable3['bitCoded'] = 2
    newTable4['bitCoded'] = 2
    newTable5['bitCoded'] = 2
    newTable6['bitCoded'] = 2

    sim.writeCustomDataBlock(feeder1,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable1))
    sim.writeCustomDataBlock(feeder2,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable2))
    sim.writeCustomDataBlock(feeder3,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable3))
    sim.writeCustomDataBlock(feeder4,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable4))
    sim.writeCustomDataBlock(feeder5,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable5))
    sim.writeCustomDataBlock(feeder6,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable6))

end

function action70(ui,id)

    local robot = sim.readCustomDataBlock(ragnar1,'customData')

    local newTable = sim.unpackTable(robot)

    local power = tonumber(simUI.getSliderValue(ui,id))

    newTable['gripperSupply'] = power
    sim.writeCustomDataBlock(ragnar1,'customData',sim.packTable(newTable))
    simUI.setLabelText(ui,72,tostring(simUI.getSliderValue(ui,id)))
    showDlg()
end


function action90(ui,id)

    local robot = sim.readCustomDataBlock(ragnar1,simBWF.modelTags.RAGNAR)

    local newTable = sim.unpackTable(robot)

    local newVel = tonumber(simUI.getSliderValue(ui,id))

    newTable['maxVel'] = newVel
    sim.writeCustomDataBlock(ragnar1,simBWF.modelTags.RAGNAR,sim.packTable(newTable))
    simUI.setLabelText(ui,92,tostring(simUI.getSliderValue(ui,id)))
    showDlg()
end

function interVeloRob1()

    local robot = sim.readCustomDataBlock(ragnar1,simBWF.modelTags.RAGNAR)
    local robot_custom = sim.readCustomDataBlock(ragnar1,'customData')

    local newTable1 = sim.unpackTable(robot)
    local newTable2 = sim.unpackTable(robot_custom)

    newTable1['maxVel'] = 0.7
    newTable2['maxVel'] = 0.7
    sim.writeCustomDataBlock(ragnar1,simBWF.modelTags.RAGNAR,sim.packTable(newTable1))
    sim.writeCustomDataBlock(ragnar1,'customData',sim.packTable(newTable2))
    print('Intervention: robot 1 speed has been modified')

end

function resetVeloRob1()
    local robot = sim.readCustomDataBlock(ragnar1,simBWF.modelTags.RAGNAR)
    local robot_custom = sim.readCustomDataBlock(ragnar1,'customData')

    local newTable1 = sim.unpackTable(robot)
    local newTable2 = sim.unpackTable(robot_custom)

    newTable1['maxVel'] = 2
    newTable2['maxVel'] = 2
    sim.writeCustomDataBlock(ragnar1,simBWF.modelTags.RAGNAR,sim.packTable(newTable1))
    sim.writeCustomDataBlock(ragnar1,'customData',sim.packTable(newTable2))
    print('Intervention: robot 1 speed has been reset')

end

function interGripper1()

    local robot = sim.readCustomDataBlock(ragnar1,'customData')

    local newTable = sim.unpackTable(robot)

    local power = 30

    newTable['gripperSupply'] = power
    sim.writeCustomDataBlock(ragnar1,'customData',sim.packTable(newTable))
    print('Intervention: gripper 1 has been disabled')
end

function resetGripper1()

    local robot = sim.readCustomDataBlock(ragnar1,'customData')

    local newTable = sim.unpackTable(robot)

    local power = 100

    newTable['gripperSupply'] = power
    sim.writeCustomDataBlock(ragnar1,'customData',sim.packTable(newTable))
    print('Intervention: gripper 1 has been reset')
end

function action80(ui,id)

    local robot = sim.readCustomDataBlock(ragnar2,'customData')

    local newTable = sim.unpackTable(robot)

    local power = tonumber(simUI.getSliderValue(ui,id))

    newTable['gripperSupply'] = power
    sim.writeCustomDataBlock(ragnar2,'customData',sim.packTable(newTable))
    simUI.setLabelText(ui,82,tostring(simUI.getSliderValue(ui,id)))
    showDlg()
end

function action100(ui,id)

    local robot = sim.readCustomDataBlock(ragnar2,simBWF.modelTags.RAGNAR)

    local newTable = sim.unpackTable(robot)

    local newVel = tonumber(simUI.getSliderValue(ui,id))

    newTable['maxVel'] = newVel
    sim.writeCustomDataBlock(ragnar2,simBWF.modelTags.RAGNAR,sim.packTable(newTable))
    simUI.setLabelText(ui,102,tostring(simUI.getSliderValue(ui,id)))
    showDlg()
end

function interVeloRob2()

    local robot = sim.readCustomDataBlock(ragnar2,simBWF.modelTags.RAGNAR)
    local robot_custom = sim.readCustomDataBlock(ragnar2,'customData')

    local newTable1 = sim.unpackTable(robot)
    local newTable2 = sim.unpackTable(robot_custom)

    newTable1['maxVel'] = 0.7
    newTable2['maxVel'] = 0.7
    sim.writeCustomDataBlock(ragnar2,simBWF.modelTags.RAGNAR,sim.packTable(newTable1))
    sim.writeCustomDataBlock(ragnar2,'customData',sim.packTable(newTable2))
    print('Intervention: robot 2 speed has been modified')

end

function resetVeloRob2()
    local robot = sim.readCustomDataBlock(ragnar2,simBWF.modelTags.RAGNAR)
    local robot_custom = sim.readCustomDataBlock(ragnar2,'customData')

    local newTable1 = sim.unpackTable(robot)
    local newTable2 = sim.unpackTable(robot_custom)

    newTable1['maxVel'] = 2
    newTable2['maxVel'] = 2
    sim.writeCustomDataBlock(ragnar2,simBWF.modelTags.RAGNAR,sim.packTable(newTable1))
    sim.writeCustomDataBlock(ragnar2,'customData',sim.packTable(newTable2))
    print('Intervention: robot 2 speed has been reset')

end

function interGripper2()

    local robot = sim.readCustomDataBlock(ragnar2,'customData')

    local newTable = sim.unpackTable(robot)

    local power = 30
    newTable['gripperSupply'] = power
    sim.writeCustomDataBlock(ragnar2,'customData',sim.packTable(newTable))
    print('Intervention: gripper 2 has been disabled')
end

function resetGripper2()

    local robot = sim.readCustomDataBlock(ragnar2,'customData')

    local newTable = sim.unpackTable(robot)

    local power = 100

    newTable['gripperSupply'] = power
    sim.writeCustomDataBlock(ragnar2,'customData',sim.packTable(newTable))
    print('Intervention: gripper 2 has been reset')
end

function interCamera1()

    local enableWindow = sim.readCustomDataBlock(detectionWindow1,'customData')
    local enableCam = sim.readCustomDataBlock(camera1,'customData')

    local newTable1 = sim.unpackTable(enableWindow)
    local newTable2 = sim.unpackTable(enableCam)

    newTable1['enabledDetection'] = false
    newTable2['enabledCamera'] = false

    sim.writeCustomDataBlock(detectionWindow1,'customData',sim.packTable(newTable1))
    sim.writeCustomDataBlock(camera1,'customData',sim.packTable(newTable2))

    print('Intervention: camera 1 has been disabled')
end

function resetCamera1()

    local enableWindow = sim.readCustomDataBlock(detectionWindow1,'customData')
    local enableCam = sim.readCustomDataBlock(camera1,'customData')

    local newTable1 = sim.unpackTable(enableWindow)
    local newTable2 = sim.unpackTable(enableCam)

    newTable1['enabledDetection'] = true
    newTable2['enabledCamera'] = true

    sim.writeCustomDataBlock(detectionWindow1,'customData',sim.packTable(newTable1))
    sim.writeCustomDataBlock(camera1,'customData',sim.packTable(newTable2))

    print('Intervention: camera 1 has been reset')
end

function interCamera2()

    local enableWindow = sim.readCustomDataBlock(detectionWindow2,'customData')
    local enableCam = sim.readCustomDataBlock(camera2,'customData')

    local newTable1 = sim.unpackTable(enableWindow)
    local newTable2 = sim.unpackTable(enableCam)

    newTable1['enabledDetection'] = false
    newTable2['enabledCamera'] = false

    sim.writeCustomDataBlock(detectionWindow2,'customData',sim.packTable(newTable1))
    sim.writeCustomDataBlock(camera2,'customData',sim.packTable(newTable2))

    print('Intervention: camera 2 has been disabled')
end

function resetCamera2()

    local enableWindow = sim.readCustomDataBlock(detectionWindow2,'customData')
    local enableCam = sim.readCustomDataBlock(camera2,'customData')

    local newTable1 = sim.unpackTable(enableWindow)
    local newTable2 = sim.unpackTable(enableCam)

    newTable1['enabledDetection'] = true
    newTable2['enabledCamera'] = true

    sim.writeCustomDataBlock(detectionWindow2,'customData',sim.packTable(newTable1))
    sim.writeCustomDataBlock(camera2,'customData',sim.packTable(newTable2))

    print('Intervention: camera 2 has been reset')
end

function interCamera3()

    local enableWindow = sim.readCustomDataBlock(detectionWindow3,'customData')
    local enableCam = sim.readCustomDataBlock(camera3,'customData')

    local newTable1 = sim.unpackTable(enableWindow)
    local newTable2 = sim.unpackTable(enableCam)

    newTable1['enabledDetection'] = false
    newTable2['enabledCamera'] = false

    sim.writeCustomDataBlock(detectionWindow3,'customData',sim.packTable(newTable1))
    sim.writeCustomDataBlock(camera3,'customData',sim.packTable(newTable2))

    print('Intervention: camera 3 has been disabled')
end

function resetCamera3()

    local enableWindow = sim.readCustomDataBlock(detectionWindow3,'customData')
    local enableCam = sim.readCustomDataBlock(camera3,'customData')

    local newTable1 = sim.unpackTable(enableWindow)
    local newTable2 = sim.unpackTable(enableCam)

    newTable1['enabledDetection'] = true
    newTable2['enabledCamera'] = true

    sim.writeCustomDataBlock(detectionWindow3,'customData',sim.packTable(newTable1))
    sim.writeCustomDataBlock(camera3,'customData',sim.packTable(newTable2))

    print('Intervention: camera 3 has been reset')
end

function interConveyor1()

    local conveyor = sim.readCustomDataBlock(conveyor1, 'customData')

    local feederData1 = sim.readCustomDataBlock(feeder1, simBWF.modelTags.PARTFEEDER)
    local feederData4 = sim.readCustomDataBlock(feeder4, simBWF.modelTags.PARTFEEDER)
    local feederData5 = sim.readCustomDataBlock(feeder5, simBWF.modelTags.PARTFEEDER)
    local feederData6 = sim.readCustomDataBlock(feeder6, simBWF.modelTags.PARTFEEDER)

    local newTable1 = sim.unpackTable(feederData1)
    local newTable4 = sim.unpackTable(feederData4)
    local newTable5 = sim.unpackTable(feederData5)
    local newTable6 = sim.unpackTable(feederData6)

    local newTable2 = sim.unpackTable(conveyor)

    local speed = 0

    newTable1['frequency'] = 0
    newTable4['frequency'] = 0
    newTable5['frequency'] = 0
    newTable6['frequency'] = 0

    newTable2['speed'] = speed

    sim.writeCustomDataBlock(feeder1,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable1))
    sim.writeCustomDataBlock(feeder4,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable4))
    sim.writeCustomDataBlock(feeder5,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable5))
    sim.writeCustomDataBlock(feeder6,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable6))
    sim.writeCustomDataBlock(conveyor1,'customData',sim.packTable(newTable2))
    print('Intervention: conveyor 1 has been disabled')
end

function resetConveyor1()

    local conveyor = sim.readCustomDataBlock(conveyor1, 'customData')

    local feederData1 = sim.readCustomDataBlock(feeder1, simBWF.modelTags.PARTFEEDER)
    local feederData4 = sim.readCustomDataBlock(feeder4, simBWF.modelTags.PARTFEEDER)
    local feederData5 = sim.readCustomDataBlock(feeder5, simBWF.modelTags.PARTFEEDER)
    local feederData6 = sim.readCustomDataBlock(feeder6, simBWF.modelTags.PARTFEEDER)

    local newTable1 = sim.unpackTable(feederData1)
    local newTable4 = sim.unpackTable(feederData4)
    local newTable5 = sim.unpackTable(feederData5)
    local newTable6 = sim.unpackTable(feederData6)

    local newTable2 = sim.unpackTable(conveyor)

    local speed = 75

    newTable1['frequency'] = 0.125
    newTable4['frequency'] = 0.125
    newTable5['frequency'] = 0.125
    newTable6['frequency'] = 0.125

    newTable2['speed'] = speed

    sim.writeCustomDataBlock(feeder1,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable1))
    sim.writeCustomDataBlock(feeder4,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable4))
    sim.writeCustomDataBlock(feeder5,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable5))
    sim.writeCustomDataBlock(feeder6,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable6))
    sim.writeCustomDataBlock(conveyor1,'customData',sim.packTable(newTable2))
    print('Intervention: conveyor 1 has been reset')

end

function interConveyor2()

    local conveyor = sim.readCustomDataBlock(conveyor2, 'customData')

    local feederData = sim.readCustomDataBlock(feeder2, simBWF.modelTags.PARTFEEDER)

    local newTable1 = sim.unpackTable(feederData)

    local newTable2 = sim.unpackTable(conveyor)

    local speed = 0
    newTable1['frequency'] = 0
    newTable2['speed'] = speed
    sim.writeCustomDataBlock(feeder2,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable1))
    sim.writeCustomDataBlock(conveyor2,'customData',sim.packTable(newTable2))
    print('Intervention: conveyor 1 has been disabled')
end

function resetConveyor2()

    local conveyor = sim.readCustomDataBlock(conveyor2, 'customData')

    local feederData = sim.readCustomDataBlock(feeder2, simBWF.modelTags.PARTFEEDER)

    local newTable1 = sim.unpackTable(feederData)

    local newTable2 = sim.unpackTable(conveyor)

    local speed = 75
    newTable1['frequency'] = 0.125
    newTable2['speed'] = speed
    sim.writeCustomDataBlock(feeder2,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable1))
    sim.writeCustomDataBlock(conveyor2,'customData',sim.packTable(newTable2))
    print('Intervention: conveyor 2 has been reset')

end

function interConveyor3()

    local conveyor = sim.readCustomDataBlock(conveyor3, 'customData')

    local feederData = sim.readCustomDataBlock(feeder3, simBWF.modelTags.PARTFEEDER)

    local newTable1 = sim.unpackTable(feederData)

    local newTable2 = sim.unpackTable(conveyor)

    local speed = 0
    newTable1['frequency'] = 0
    newTable2['speed'] = speed
    sim.writeCustomDataBlock(feeder3,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable1))
    sim.writeCustomDataBlock(conveyor3,'customData',sim.packTable(newTable2))
    print('Intervention: conveyor 3 has been disabled')
end

function resetConveyor3()

    local conveyor = sim.readCustomDataBlock(conveyor3, 'customData')

    local feederData = sim.readCustomDataBlock(feeder3, simBWF.modelTags.PARTFEEDER)

    local newTable1 = sim.unpackTable(feederData)

    local newTable2 = sim.unpackTable(conveyor)

    local speed = 75
    newTable1['frequency'] = 0.125
    newTable2['speed'] = speed
    sim.writeCustomDataBlock(feeder3,simBWF.modelTags.PARTFEEDER,sim.packTable(newTable1))
    sim.writeCustomDataBlock(conveyor3,'customData',sim.packTable(newTable2))
    print('Intervention: conveyor 3 has been reset')

end

function normal()
    sysCall_afterSimulation()
end

function sysCall_afterSimulation()
    resetGripper1()
    resetGripper2()
    resetCamera1()
    resetCamera2()
    resetCamera3()
    resetConveyor1()
    resetConveyor2()
    resetConveyor3()
    resetSize1()
    resetFeeder3()
    resetVeloRob2()
    resetVeloRob1()
    resetFeederAll()
end



function sysCall_init()
    model=sim.getObject('.')

    sim.writeCustomDataBlock(model,'customData',sim.packTable({interDetection = false}))

    feeder1 = sim.getObject("/genericFeeder[1]")
    feeder2 = sim.getObject("/genericFeeder[0]")
    feeder3 = sim.getObject("/genericFeeder[2]")
    feeder4 = sim.getObject("/genericFeeder[3]")
    feeder5 = sim.getObject("/genericFeeder[4]")
    feeder6 = sim.getObject("/genericFeeder[5]")

    detectionWindow1 = sim.getObject("/genericDetectionWindow[2]")
    detectionWindow2 = sim.getObject("/genericDetectionWindow[1]")
    detectionWindow3 = sim.getObject("/genericDetectionWindow[3]")
    detectionWindow4 = sim.getObject("/genericDetectionWindow[0]")

    camera1 = sim.getObject("/camera_1/camera")
    camera2 = sim.getObject("/camera_2/camera")
    camera3= sim.getObject("/camera_3/camera")

    conveyor1 = sim.getObject("/genericConveyorTypeA[0]")
    conveyor2 = sim.getObject("/genericConveyorTypeA[2]")
    conveyor3 = sim.getObject("/genericConveyorTypeA[1]")

    ragnar1 = sim.getObject("/Ragnar[0]")
    ragnar2 = sim.getObject("/Ragnar[1]")

    showDlg()
end

function showDlg()

    local conveyorData1 = sim.unpackTable(sim.readCustomDataBlock(conveyor1, simBWF.modelTags.CONVEYOR))

    local speed1 = tostring(math.floor(conveyorData1['velocity']*1000))

    local conveyorData2 = sim.unpackTable(sim.readCustomDataBlock(conveyor2, simBWF.modelTags.CONVEYOR))

    local speed2 = tostring(math.floor(conveyorData2['velocity']*1000))

    local conveyorData3 = sim.unpackTable(sim.readCustomDataBlock(conveyor3, simBWF.modelTags.CONVEYOR))

    local speed3 = tostring(math.floor(conveyorData3['velocity']*1000))

    local robotCustomData1 = sim.unpackTable(sim.readCustomDataBlock(ragnar1, 'customData'))

    local gripperPower1 = tostring(math.floor(robotCustomData1['gripperSupply']))

    local robotCustomData2 = sim.unpackTable(sim.readCustomDataBlock(ragnar2, 'customData'))

    local gripperPower2 = tostring(math.floor(robotCustomData2['gripperSupply']))

    local robotData1= sim.unpackTable(sim.readCustomDataBlock(ragnar1, simBWF.modelTags.RAGNAR))

    local maxVel1 = tostring(math.floor(robotData1['maxVel']))

    local robotData2= sim.unpackTable(sim.readCustomDataBlock(ragnar2, simBWF.modelTags.RAGNAR))

    local maxVel2 = tostring(math.floor(robotData2['maxVel']))


    if not ui then
        local pos = 'position="-50,50" placement="relative"'
        if uiPos then
            pos = 'position="'..uiPos[1]..','..uiPos[2]..'" placement="absolute"'
        end

        local xml = '<ui title="Interventions" activate="false" closeable="true" on-close="close_callback" layout="vbox" '..pos..' >'

        xml = xml..'<checkbox text="Camera 1" on-change="action1" id="1" />'

        xml = xml..'<checkbox text="Camera 2" on-change="action2" id="2" />'

        xml = xml..'<checkbox text="Camera 3" on-change="action3" id="3" />'

        xml = xml..'<checkbox text="Size - Part" on-change="action40" id="41" />'

        xml = xml..'<checkbox text="Size - Tray" on-change="action50" id="51" />'

        xml = xml..'<checkbox text="Size - Ins" on-change="action60" id="61" />'

        xml = xml..'<label text="Conveyor Speed 1 (mm/s):" style="* {min-width: 300px; min-height: 30px;}" id ="11"/>'
        xml = xml..'<label text="'..speed1..'"style="* {min-width: 300px; min-height: 30px;}" id ="12"/>'
        xml = xml..'<hslider value="'..speed1..'" minimum="0" maximum="75" on-change="action10" id="13" style="* {min-width: 300px;}" />'

        xml = xml..'<label text="Conveyor Speed 2 (mm/s):" style="* {min-width: 300px; min-height: 30px;}" id ="21"/>'
        xml = xml..'<label text="'..speed2..'"style="* {min-width: 300px; min-height: 30px;}" id ="22"/>'
        xml = xml..'<hslider value="'..speed2..'" minimum="0" maximum="75" on-change="action20" id="23" style="* {min-width: 300px;}" />'

        xml = xml..'<label text="Conveyor Speed 3 (mm/s):" style="* {min-width: 300px; min-height: 30px;}" id ="31"/>'
        xml = xml..'<label text="'..speed3..'"style="* {min-width: 300px; min-height: 30px;}" id ="32"/>'
        xml = xml..'<hslider value="'..speed3..'" minimum="0" maximum="75" on-change="action30" id="33" style="* {min-width: 300px;}" />'

        xml = xml..'<label text="Gripper Power 1 (%):" style="* {min-width: 300px; min-height: 30px;}" id ="71"/>'
        xml = xml..'<label text="'..gripperPower1..'"style="* {min-width: 300px; min-height: 30px;}" id ="72"/>'
        xml = xml..'<hslider value="'..gripperPower1..'" minimum="0" maximum="100" on-change="action70" id="73" style="* {min-width: 300px;}" />'

        xml = xml..'<label text="Gripper Power 2 (%):" style="* {min-width: 300px; min-height: 30px;}" id ="81"/>'
        xml = xml..'<label text="'..gripperPower2..'"style="* {min-width: 300px; min-height: 30px;}" id ="82"/>'
        xml = xml..'<hslider value="'..gripperPower2..'" minimum="0" maximum="100" on-change="action80" id="83" style="* {min-width: 300px;}" />'

        xml = xml..'<label text="Robot Speed 1 (m/s):" style="* {min-width: 300px; min-height: 30px;}" id ="91"/>'
        xml = xml..'<label text="'..maxVel1..'"style="* {min-width: 300px; min-height: 30px;}" id ="92"/>'
        xml = xml..'<hslider value="'..maxVel1..'" minimum="1" maximum="5" on-change="action90" id="93" style="* {min-width: 300px;}" />'

        xml = xml..'<label text="Robot Speed 2 (m/s):" style="* {min-width: 300px; min-height: 30px;}" id ="101"/>'
        xml = xml..'<label text="'..maxVel2..'"style="* {min-width: 300px; min-height: 30px;}" id ="102"/>'
        xml = xml..'<hslider value="'..maxVel2..'" minimum="1" maximum="5" on-change="action100" id="103" style="* {min-width: 300px;}" />'

        xml = xml..'</ui>'

        ui = simUI.create(xml)
    end
end


function hideDlg()
    if ui then
        uiPos={}
        uiPos[1],uiPos[2]=simUI.getPosition(ui)
        simUI.destroy(ui)
        ui=nil
    end
    selectedObjects={}
end

function sysCall_cleanup()
    hideDlg()
end

function sysCall_beforeInstanceSwitch()
    hideDlg()
end
function sysCall_beforeSimulation()
    --showDlg()
end

function close_callback()
    hideDlg()
end

function sysCall_userConfig()
    showDlg()
end



