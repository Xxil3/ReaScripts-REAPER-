--[[
 * ReaScript Name: Batch Create Regions From Selected Tracks with Tail
 * About: This script batch creates regions for selected tracks. Purposed for sound design variations. When you have several variations of sounds composed of different layers.
 * Instructions: Select tracks containing media items. Run script. Works best with escalator/ladder edits. Input 0 on Region Tail for no tail.
 * Author: Xxil3
 * Repository: GitHub > Xxil3 > ReaScripts-REAPER-
 * Licence: GPL v3
 * REAPER: 6.61
 * Extensions: SWS
 * Version: 1.0
--]]

--[[CHANGE LOG]]--
--[[
 * v 1.0
 * First Submit
 * Known Issues: 
 * All Tracks must be populated with items in order to not break reaper.GetMediaItemInfo_Value()
 * Can not handle variation groups with different numbers of layers or in different track folders at the same time.
 ------------------

-------------
--[[SETUP]]--
-------------

Track_topTrackItemCount = reaper.CountTrackMediaItems(reaper.GetSelectedTrack(0, 0)) -- Gets the total number of items in the Top track
Track_totalSelectedCount =  reaper.CountSelectedTracks(0) -- Gets total number of tracks selected
Retval_name, Retvals_csv_name = reaper.GetUserInputs( "Set Region Name", 1, "Set Region Name", "" ) -- Stores user input for Region name
Retval_tail, Retvals_csv_tail = reaper.GetUserInputs( "Set Region Tail (seconds)", 1, "Set Region Tail (seconds)", "" ) -- Stores user input for Region tail


-----------------
--[[FUNCTIONS]]--
-----------------


function BatchAddRegions ()

    local track_TopTrackSelected = reaper.GetSelectedTrack(0, 0) -- Stores top most media track in selection
    local item_TopTrackItemCount = reaper.CountTrackMediaItems(track_TopTrackSelected) -- Locally stores Total top track item count to handle loop

    -- First loop iterates horizontally. So for every item in the top track...
    for i = 0, item_TopTrackItemCount - 1 do

        Rgn_StartPos, Rgn_EndPos = 0, 0 --Set Start and End positions to 0
        Rgn_IterationCount = i -- Stores i as counter for next loop
    
        -- Check if their is a valid selection, else breaks
        if Track_topTrackItemCount == 0 or Track_totalSelectedCount == 0 then 
            return
        end

        -- For each mesia item in the parent track (first loop) we start comparing item start/end positions by track. This loop iterates vertically.
        for j = 0, Track_totalSelectedCount - 1 do 

            local track_CurrentSelected = reaper.GetSelectedTrack(0, j) -- Gets selected track and jumps to following one every loop iteration
            local item_MediaItemRef = reaper.GetTrackMediaItem(track_CurrentSelected, Rgn_IterationCount) -- GEts MediaItem on currently selected track and at position dictated by first loop.
            local item_StartPos = reaper.GetMediaItemInfo_Value(item_MediaItemRef, "D_POSITION") -- Stores start position of media item
            local item_EndPos = reaper.GetMediaItemInfo_Value(item_MediaItemRef, "D_LENGTH") + item_StartPos -- Calculate and stores end position of item

            -- If first iteration, equal region start/end to item start/end
            if j == 0 then
                Rgn_StartPos = item_StartPos
                Rgn_EndPos = item_EndPos
            end
            -- For following iterations
            -- If Region start position is later than new items start position, set region start position to new item start
            if Rgn_StartPos > item_StartPos then
                Rgn_StartPos = item_StartPos
            end
            -- If Region end position is earlier than new items end position, set region end position to new item end
            if Rgn_EndPos < item_EndPos then
                Rgn_EndPos = item_EndPos
            end

        end

        reaper.GetSet_LoopTimeRange2(0, true, true, Rgn_StartPos , Rgn_EndPos + tonumber(Retvals_csv_tail), false) -- Set Time selection to region start/end
        reaper.AddProjectMarker2(0, true, Rgn_StartPos, Rgn_EndPos + tonumber(Retvals_csv_tail), Retvals_csv_name, i, 0) -- Create region at claculated pos + tail and sets user input name

    end
end


------------
--[[MAIN]]--
------------

function Main()
    BatchAddRegions()
end


------------
--[[INIT]]--
------------

reaper.Undo_BeginBlock()

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

Main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.Undo_EndBlock("Batch Create Regions From Selected Tracks", -1)

reaper.UpdateArrange() -- Update the arrangement (often needed)