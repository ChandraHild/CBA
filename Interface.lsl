list g_owners;
integer g_bLocked;

default
{
    touch_start(integer num_detected)
    {
        llResetTime();
    }

    touch_end(integer total_number)
    {
        if(g_bLocked)
        {
            key poker = llDetectedKey(0);
            if(poker == llGetOwner())
            {
                llOwnerSay("Silly bimbo, you'll have to find somebody else to tinker with your brain!");
                return;
            }
            else if (llGetListLength(g_owners) == 0 || ~llListFindList(g_owners, (list)poker))
            {
                if (llGetTime() < 1.0)
                {
                    llOwnerSay(llGetDisplayName(llDetectedKey(0))+ " tried to free your brain, but they didn't do it for long enough! Have them poke your forehead longer if you really want to release your mind.");
                }
                else
                {
                    llRegionSayTo(llDetectedKey(0), 0, "You freed the lock on " + llGetDisplayName(llGetOwner()) + "'s mind!");
                    llMessageLinked(LINK_ALL_CHILDREN, 17, "Regular", "");
                    g_bLocked = FALSE;
                }
            }
        }
        else
        {
            if (llDetectedKey(0) != llGetOwner())
            {
                llRegionSayTo(llDetectedKey(0), 0, "You locked " + llGetDisplayName(llGetOwner()) + " into their ditzy state of mind! Somebody will have to fiddle with their forehead for a second if they want to get freed again.");
            }
            llMessageLinked(LINK_ALL_CHILDREN, 17, "Bimbo", "");
            g_bLocked = TRUE;
        }

        llSleep(0.5);
    }
}
