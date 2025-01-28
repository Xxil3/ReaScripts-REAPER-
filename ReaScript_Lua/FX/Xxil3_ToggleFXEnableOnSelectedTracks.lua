--[[
 * ReaScript Name: Toggle FX Enable On Selected Tracks
 * About: This script Toggle FX Enable/Disable for all selected tracks.
 * Instructions: Select Tracks you want to toggle master FX bypass on. Run scripts. Each track is handled seperately so if one track is enabled and another disabled expect these parameters to flip. Won't enable/disable all
 * Author: Xxil3
 * Repository: GitHub > Xxil3 > ReaScripts-REAPER-
 * Licence: GPL v3
 * REAPER: 6.61
 * Extensions: SWS
 * Version: 1.0
--]]
-- USER CONFIG AREA ----------------------------------------------------

Undo_Title = "Toggle FX Enable On Selected Tracks"

------------------------------------------------------------------------

--[[CHANGE LOG]]--
--[[
 * v 1.0
 * First Submit
------------------

-------------
--[[SETUP]]--
-------------

-----------------
--[[FUNCTIONS]]--
-----------------

function GetSetTrackFXStatus()

    TR_SelectedCount = reaper.CountSelectedTracks2(0, true)

    for i = 0, TR_SelectedCount - 1 do
        TR_CurrentTrack = reaper.GetSelectedTrack2( 0, i, true)
        TR_CurrentFXState = reaper.GetMediaTrackInfo_Value(TR_CurrentTrack, "I_FXEN")
        if TR_CurrentFXState == 1 then
            reaper.SetMediaTrackInfo_Value(TR_CurrentTrack, "I_FXEN", 0)
        elseif TR_CurrentFXState == 0 then
            reaper.SetMediaTrackInfo_Value(TR_CurrentTrack, "I_FXEN", 1)
        end
    end
end

------------
--[[MAIN]]--
------------

function Main()
    GetSetTrackFXStatus()
end

------------
--[[INIT]]--
------------

reaper.Undo_BeginBlock()

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

Main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.Undo_EndBlock(Undo_Title, -1)

reaper.UpdateArrange() -- Update the arrangement (often needed)