--lua

sim=require'sim'
simUI=require'simUI'

function sysCall_afterSimulation()
    local data = sim.readCustomDataBlock(model,'customData')
    data = sim.unpackTable(data)
    --print(data)
    local customTable = {}
    sim.writeCustomDataBlock(model,'customData',sim.packTable(customTable))
end

function sysCall_beforeSimulation()
    local data = sim.readCustomDataBlock(model,'customData')
    data = sim.unpackTable(data)
    local customTable = {}
    sim.writeCustomDataBlock(model,'customData',sim.packTable(customTable))
end

function sysCall_init()
    model=sim.getObject('.')
    local customTable = {}
    sim.writeCustomDataBlock(model,'customData',sim.packTable(customTable))
end




