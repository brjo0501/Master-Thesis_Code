-- Basic Lua code for testing funtions

local x = {value=0}
for i = 1, 400, 1 do
    x[i] = (2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*0.5+50)/50
end

--print(table.unpack(x))

print(math.max(table.unpack(x)),math.min(table.unpack(x)))


