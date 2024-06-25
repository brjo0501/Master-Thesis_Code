-- Basic Lua code for testing funtions
local x = {value=0}
local y = {value=0}
for i = 1, 400, 1 do
    x[i] = 2*math.log(1/math.random())^.5*math.cos(2*math.pi*math.random())*2.5+50
    y[i] = 2*math.log(1/math.random())^1*math.cos(2*math.pi*math.random())*0.5+50
end

print(table.unpack(x))

print(math.max(table.unpack(x)),math.min(table.unpack(x)))
print(math.max(table.unpack(y)),math.min(table.unpack(y)))

-- -----------------------------------------------------------

-- function simSwitchThread()
--     sim.switchThread()
-- end

-- function planAndExecutePickAndPlaceTogether()
--     local retVal=false
--     -- 1. Get all parts in tracking window (ordered from most downstream to most upstream):
--     local allTrackedParts=ragnar_getAllTrackedParts()

--     -- 1b. Loop through parts and pick the one that satisfies us:
--     local part=nil
--     for i=1,#allTrackedParts,1 do
--         local thePart=allTrackedParts[i]
--         -- 'thePart' contains following information:
--         --    thePart['pickPos']
--         --    thePart['hasLabel']
--         --    thePart['mass']
--         --    thePart['partName']
--         --    thePart['destinationName']
--         --    thePart['velocityVect']
--         --    thePart['normalVect']
--         if true then -- if thePart['hasLabel'] then
--             local n=thePart['normalVect']
--             local angle=math.acos(n[3])
--             if angle<10*math.pi/180 then -- The normal vector of the part surface should be within this tolerance
--                 part=thePart
--                 break
--             end
--         end
--     end

--     if part then
--         -- Ok, we have a part with following destination:
--         local destinationName=part['destinationName']
--         -- Get info about a possible FIXED drop position:
--         local fixedDropLocations=ragnar_getDropLocationInfo(destinationName)
--         if #fixedDropLocations>0 then
--             -- Ok, we have at least one valid FIXED drop position
--             -- Move to the part and attach it to the gripper:
--             ragnar_startPickTime()
--             ragnar_moveToPickLocation(part,true,0)
--             ragnar_endPickTime(part['auxWin'])
--             -- Remove the part from the tracking list:
--             ragnar_stopTrackingPart(part)
--             -- We pick the first drop position:
--             local dropLocation=fixedDropLocations[1]
--             -- 'dropLocation' contains following information:
--             --    dropLocation['pos']
--             --    dropLocation['isBucket']

--             -- Move to the FIXED drop position and detach the part:
--             ragnar_startPlaceTime()
--             ragnar_moveToDropLocation(dropLocation,true)
--             ragnar_endPlaceTime(true)
--             retVal=true
--         else
--             -- None of the FIXED drop locations worked. Do we have a moving drop location?
--             -- Get all moving targets in tracking window (ordered from most downstream to most upstream):
--             local movingDropLocations=ragnar_getTrackingLocationInfo(destinationName,0)
--             if #movingDropLocations>0 then
--                 -- Ok, we have at least one valid tracking location (for placing)
--                 -- We pick the first one (most downstream):
--                 local trackingLocation=movingDropLocations[1]
--                 -- 'trackingLocation' contains:
--                 -- trackingLocation['dummyHandle']: is the handle of the dummy to follow
--                 -- trackingLocation['partHandle']: is the handle of the associated part
--                 -- trackingLocation['pos']: is the current location relative to the ragnar frame
--                 -- trackingLocation['velocityVect']: is the velocity vector relative to the ragnar frame

--                 -- Mark the target as 'processed' (i.e. a processingStage value will be incremented):
--                 ragnar_incrementTrackedLocationProcessingStage(trackingLocation)
--                 -- Move to the part and attach it to the gripper:
--                 ragnar_startPickTime()
--                 ragnar_moveToPickLocation(part,true,0)
--                 ragnar_endPickTime(part['auxWin'])
--                 -- Remove the part from the tracking list:
--                 ragnar_stopTrackingPart(part)
--                 -- Move to the tracking location and detach the part:
--                 ragnar_startPlaceTime()
--                 ragnar_moveToTrackingLocation(trackingLocation,true,ragnar_getAttachToTarget())
--                 ragnar_endPlaceTime(false)
--                 retVal=true
--             end
--         end
--     end
--     return retVal
-- end

-- function planAndExecutePickAndPlaceIndividually(theStacking,theStackingShift)
--     local retVal=false
--     local donePicking=false
--     local destinationName=''

--     -- Do the picking first:
--     local pickCnt=0
--     while pickCnt<theStacking do
--         -- Get all parts in tracking window (ordered from most downstream to most upstream):
--         local allTrackedParts=ragnar_getAllTrackedParts()

--         -- Loop through parts and pick the one that satisfies us:
--         local part=nil
--         for i=1,#allTrackedParts,1 do
--             local thePart=allTrackedParts[i]
--             -- 'thePart' contains following information:
--             --    thePart['pickPos']
--             --    thePart['hasLabel']
--             --    thePart['mass']
--             --    thePart['partName']
--             --    thePart['destinationName']
--             --    thePart['velocityVect']
--             --    thePart['normalVect']
--             if true then -- if thePart['hasLabel'] then
--                 local n=thePart['normalVect']
--                 local angle=math.acos(n[3])
--                 if angle<10*math.pi/180 then -- The normal vector of the part surface should be within this tolerance
--                     part=thePart
--                     break
--                 end
--             end
--         end

--         if part then
--             -- Ok, we have a part with following destination:
--             if pickCnt==0 then
--                 destinationName=part['destinationName']
--             end

--             -- Move to the part and attach it to the gripper:
--             ragnar_startPickTime()
--             ragnar_moveToPickLocation(part,true,theStackingShift)
--             ragnar_endPickTime(part['auxWin'])
--             -- Remove the part from the tracking list:
--             ragnar_stopTrackingPart(part)
--             pickCnt=pickCnt+1
--             donePicking=(pickCnt==theStacking)
--         else
--             if pickCnt==0 then
--                 break
--             else
--                 simSwitchThread()
--             end
--         end
--     end

--     -- Now place the part(s):
--     if donePicking then
--         while not retVal do
--             -- Get info about a possible FIXED drop position:
--             local fixedDropLocations=ragnar_getDropLocationInfo(destinationName)
--             if #fixedDropLocations>0 then
--                 -- Ok, we have at least one valid FIXED drop position
--                 -- We chose the first drop position:
--                 local dropLocation=fixedDropLocations[1]
--                 -- 'dropLocation' contains following information:
--                 --    dropLocation['pos']
--                 --    dropLocation['isBucket']

--                 -- Move to the FIXED drop position and detach the part:
--                 ragnar_startPlaceTime()
--                 ragnar_moveToDropLocation(dropLocation,true)
--                 ragnar_endPlaceTime(true)
--                 retVal=true
--             else
--                 -- None of the FIXED drop locations worked. Do we have a moving drop location?
--                 -- Get all moving targets in tracking window (ordered from most downstream to most upstream):
--                 local movingDropLocations=ragnar_getTrackingLocationInfo(destinationName,0)
--                 if #movingDropLocations>0 then
--                     -- Ok, we have at least one valid tracking location (for placing)
--                     -- We chose the first one (most downstream):
--                     local trackingLocation=movingDropLocations[1]
--                     -- 'trackingLocation' contains:
--                     -- trackingLocation['dummyHandle']: is the handle of the dummy to follow
--                     -- trackingLocation['partHandle']: is the handle of the associated part
--                     -- trackingLocation['pos']: is the current location relative to the ragnar frame
--                     -- trackingLocation['velocityVect']: is the velocity vector relative to the ragnar frame

--                     -- Mark the target as 'processed' (i.e. a processingStage value will be incremented):
--                     ragnar_incrementTrackedLocationProcessingStage(trackingLocation)
--                     -- Move to the tracking location and detach the part:
--                     ragnar_startPlaceTime()
--                     ragnar_moveToTrackingLocation(trackingLocation,true,ragnar_getAttachToTarget())
--                     ragnar_endPlaceTime(false)
--                     retVal=true
--                 end
--             end
--             if not retVal then
--                 simSwitchThread()
--             end
--         end
--     end
--     return retVal
-- end

-- function doOneCycle()
--     local retVal=false
--     local theStacking,theStackingShift=ragnar_getStacking()
--     ragnar_startCycleTime()
--     if ragnar_getPickWithoutTarget() or theStacking>1 then
-- --        if theStacking<=1 then
-- --            retVal=planAndExecutePickAndPlaceTogether() -- We still try to plan and execute the pick and place together
-- --        end
--         if theStacking>1 or (not retVal) then 
--             retVal=planAndExecutePickAndPlaceIndividually(theStacking,theStackingShift)
--         end
--     else
--         retVal=planAndExecutePickAndPlaceTogether()
--     end
--     ragnar_endCycleTime(retVal)
--     return retVal
-- end

-- while true do
--     if ragnar_getEnabled() then
--         updateMotionParameters()
--         if not doOneCycle() then -- i.e. 1+ pick(s) and 1 place
--             simSwitchThread()
--         end
--     else
--         simSwitchThread()
--     end
-- end


-- -- if  blobCount > 3 then
                
-- --     if blobData[13] < 0.83359375 and blobData[13] > 0.68203125 and blobData[14] < 0.83359375 and blobData[14] > 0.68203125 then -- [180,220]
-- --         tray1 = 1
-- --     end
    
-- --     if blobData[19] < 0.69609375 and blobData[19] > 0.56953125 and blobData[20] < 0.69609375  and blobData[20] > 0.56953125 then -- [144,176]
-- --         tray2 = 1
-- --     end
    
-- --     local startX = 25
-- --     local startY = 26
    
-- --     for i=1,blobCount-3,1 do
-- --         if blobData[startX] < 0.2320315 and blobData[startX] > 0.18984375 and blobData[startY] < 0.2320315 and blobData[startY] > 0.18984375 then -- [45,55]
-- --             correctCount = correctCount +1
-- --         else --if blobData[startX] < 0.18 and blobData[startX] > 0.16 and blobData[startY] < 0.18 and blobData[startY] > 0.16 then
-- --             wrongCount = wrongCount + 1
-- --         end
-- --         startX = startX + 6
-- --         startY = startY + 6
-- --     end
-- --     msg = 'EoL: '..correctCount..' correct and '..wrongCount..' defect'
    
-- -- elseif blobCount == 3 then
-- --     if blobData[13] < 0.83359375 and blobData[13] > 0.68203125 and blobData[14] < 0.83359375 and blobData[14] > 0.68203125 then -- [180,220]
-- --         tray1 = 1
-- --     end
-- --     if blobData[19] < 0.69609375 and blobData[19] > 0.56953125 and blobData[20] < 0.69609375  and blobData[20] > 0.56953125 then -- [144,176]
-- --         tray2 = 1
-- --     end
-- --     msg = 'EoL: no parts' 
    
-- -- elseif  blobCount == 2 then
-- --     if blobData[13] < 0.83359375 and blobData[13] > 0.68203125 and blobData[14] < 0.83359375 and blobData[14] > 0.68203125 then
-- --         tray1 = 1
-- --     end
-- --     msg = 'EoL: no blue tray' 
-- -- end


-- -- camData['id'] = id
-- -- camData['correctCount'] = correctCount
-- -- if correctCount == 3 then
-- --     sim.pauseSimulation()
-- -- end
-- -- camData['wrongCount'] = wrongCount
-- -- camData['tray1'] = tray1
-- -- camData['tray2'] = tray2