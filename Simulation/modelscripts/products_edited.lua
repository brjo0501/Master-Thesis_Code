--lua

sim=require'sim'
simUI=require'simUI'

function sysCall_afterSimulation()
    local productsData = readCustomInfo()
    --print(productsData)
    local datetime = os.date('%Y-%m-%d_%H-%M-%S')
    local filename = sim.getStringParameter(sim.stringparam_scene_path)..'/Dataset_Product/Data_Product_'..datetime..'.csv'
    dataToCSV(productsData,filename)
end

function sysCall_init()
    model=sim.getObject('.')
end

function readCustomInfo()
    local data=sim.readCustomDataBlock(model,'customData')
    if data then
        data=sim.unpackTable(data)
    end
    return data
end

function writeCustomInfo(data)

    if data then
        sim.writeCustomDataBlock(model,'customData',sim.packTable(data))
    else
        sim.writeCustomDataBlock(model,'customData','')
    end
end

function fileExists(filename)
    local file = io.open(filename, 'r')
    if file then
        file:close()
        return true
    else
        return false
    end
end

function extractID(key)
    return key:match('%d+')
end

function dataToCSV(data, filename)
    data['newProduct'] = nil
    local headers = {}

    table.insert(headers, 'ID')

    for id,subData in pairs(data) do
        for header, _ in pairs(subData) do
            if not table_contains(headers, header) then
                table.insert(headers, header)
            end
        end
    end

    print(headers)

    file = io.open(filename, 'w+')
    file:write(table.concat(headers, ',') .. '\n')

    for id,subData in pairs(data) do
        local maxLength = 0
        for _, list in pairs(subData) do
            if #list > maxLength then
                maxLength = #list
            end
        end

        for i = 1, maxLength do
            local row = {extractID(id)}
            for col = 2, #headers do
                local subKey = headers[col]
                local value = subData[subKey] and subData[subKey][i] or ''
                table.insert(row, processData(value))
            end
            file:write(table.concat(row, ',') .. '\n')
        end
    end
    file:close()
end

function table_contains(tbl, x)
    found = false
    for _, v in pairs(tbl) do
        if v == x then 
            found = true 
        end
    end
    return found
end

function processData(value)
    if value == nil then
        return 0
    elseif value == true then
        return 1
    elseif value == false then
        return 0
    else
        return value
    end
end





