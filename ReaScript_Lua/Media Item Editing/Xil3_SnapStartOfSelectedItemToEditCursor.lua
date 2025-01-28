--[[
 * ReaScript Name: Snap Start of Selected Item to Edit Cursor
 * About: This script will move all selected items as a block taking the first item of the top track as reference to nudge to edit cursor.
 * Instructions: Place Edit cursor on position you want selection of items to start. Select items to nudge. Run script.
 * Author: Xxil3
 * Repository: GitHub > Xxil3 > ReaScripts-REAPER-
 * Licence: GPL v3
 * REAPER: 6.61
 * Extensions: SWS
 * Version: 1.0
--]]
-- USER CONFIG AREA ----------------------------------------------------

Undo_Title = "Snap Start of Selected Items to Edit Cursor"

------------------------------------------------------------------------

--[[CHANGE LOG]]--
--[[
 * v 1.0
 * First Submit
------------------

-------------
--[[SETUP]]--
-------------

--Gets current Edit Cursor position in open project
CR_EditMarkerPos = reaper.GetCursorPosition()
IT_FirstMediaItem = reaper.GetSelectedMediaItem (0, 0)
IT_FirstItemStartPos = reaper.GetMediaItemInfo_Value (IT_FirstMediaItem, "D_POSITION")

-----------------
--[[FUNCTIONS]]--
-----------------

-- Calculates nudge value by checking the abs difference between start of first selected item and edit cursor
function GetNudgeValue()

    -- We use the abs value to nudge the items later on
    IT_NudgeValue = math.abs(IT_FirstItemStartPos - CR_EditMarkerPos)

    return IT_NudgeValue

end

-- Move all selected items by nudge value
function MoveSelectedItems(NudgeValue)

    local IT_TotalItemCount = reaper.CountSelectedMediaItems(0)
    local IT_MediaItemCounter = IT_TotalItemCount - 1
    local IT_LoopCounter = IT_TotalItemCount - 1

    --Check if edit cursor is earlier that start pos of first media item in selection to nudge left
    if IT_FirstItemStartPos > CR_EditMarkerPos then
        
        -- Loops through all selected items and nudges all of them left by nudge value
        for i=0, IT_TotalItemCount - 1 do
            local IT_NudgeMediaItem = reaper.GetSelectedMediaItem(0, i)
            local IT_NudgeMediaItemStartPos = reaper.GetMediaItemInfo_Value (IT_NudgeMediaItem, "D_POSITION")
            reaper.SetMediaItemPosition(IT_NudgeMediaItem, IT_NudgeMediaItemStartPos - NudgeValue, true)
        end
    
    --Else nudges right
    elseif IT_FirstItemStartPos < CR_EditMarkerPos then
        
        -- Loops through all selected items and nudges all of them right by nudge value
        for i=0, IT_TotalItemCount - 1 do
            local IT_NudgeMediaItem = reaper.GetSelectedMediaItem(0, IT_LoopCounter)
            IT_LoopCounter = IT_LoopCounter - 1
            local IT_NudgeMediaItemStartPos = reaper.GetMediaItemInfo_Value (IT_NudgeMediaItem, "D_POSITION")
            reaper.SetMediaItemPosition(IT_NudgeMediaItem, IT_NudgeMediaItemStartPos + NudgeValue, true)
        end
    end

end

------------
--[[MAIN]]--
------------

function Main()

    MoveSelectedItems(GetNudgeValue())

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
