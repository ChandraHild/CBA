/*
Copyright (c) 2016 Flickrstar Timeless


Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

// Config variables
//    These will get set by notecard
integer renamer_on=FALSE;
integer bimbo_talk_on=FALSE;
integer ditzy_on=FALSE;
string renamer_name="";
string renamer_prefix="";
string renamer_full="";
integer ditzy_chance=0;
integer ditzy_min_time=30;
integer ditzy_max_time=120;
list ditzy_rlv;
integer bimbo_say_skip=4;
integer bimbo_say_mid_chance=10;
list bimbo_say_mid;
integer bimbo_say_pre_chance=10;
list bimbo_say_pre;
integer bimbo_say_post_chance=10;
list bimbo_say_post;
list bimbo_say_replace;
integer bimbo_emote_post_chance=100;
list bimbo_emote_post;
integer bimbo_random_min=120;
integer bimbo_random_max=480;
integer num_bimbo_random=0;
integer num_ditzy_end=0;
integer num_ditzy_text=0;
integer num_ditzy_try=0;

// Global variables
string g_sConfigNotecard="Config";
key g_kNotecardQueryId;
key say_key = NULL_KEY;
key bimbo_random_key = NULL_KEY;
key ditzy_end_key = NULL_KEY;
key ditzy_text_key = NULL_KEY;
key ditzy_try_key = NULL_KEY;
integer g_iConfigLine=0;
integer g_iGL;
integer g_iGL2;
integer g_iChan;
string g_sWearer;
integer g_bGoodConfig=FALSE;
integer g_bIsDitzy=FALSE;
integer g_bLocked=FALSE;
integer isGagged=FALSE;

integer istrue(string data)
{
   if (llToLower(data)=="y" || (integer)data==1)
   {
       return TRUE;
    }
    else
    {
        return FALSE;
    }
    
}
load_config()
{
    llSetTimerEvent(0.0);
    g_bGoodConfig = FALSE;
    llOwnerSay("As you put on the mysteriously labeled CBA you feel a tingle in your head, and strange thoughts start filling your mind.");
    if (llGetInventoryType(g_sConfigNotecard) != INVENTORY_NOTECARD)
    {
        llOwnerSay("Missing configuration notecard: " + g_sConfigNotecard);
        llOwnerSay("@clear");
        return;
    }
    if (llGetInventoryType("bimbo-random") == INVENTORY_NOTECARD)
    {
        bimbo_random_key = llGetNumberOfNotecardLines("bimbo-random");
    }
    else
    {
        num_bimbo_random = 0;
    }

    if (llGetInventoryType("ditzy-end") == INVENTORY_NOTECARD)
    {
        ditzy_end_key = llGetNumberOfNotecardLines("ditzy-end");
    }
    else
    {
        num_ditzy_end = 0;
    }

    if (llGetInventoryType("ditzy-text") == INVENTORY_NOTECARD)
    {
        ditzy_text_key = llGetNumberOfNotecardLines("ditzy-text");
    }
    else
    {
        num_ditzy_text = 0;
    }

    if (llGetInventoryType("ditzy-try") == INVENTORY_NOTECARD)
    {
        ditzy_try_key = llGetNumberOfNotecardLines("ditzy-try");
    }
    else
    {
        num_ditzy_try = 0;
    }
    g_iConfigLine=0;
    g_kNotecardQueryId = llGetNotecardLine(g_sConfigNotecard, g_iConfigLine);
}

apply_config()
{
    if (!g_bGoodConfig)
    {
        llOwnerSay("Bad configuration detected, resetting script . . .");
        llResetScript();
        return;
    }
    pick_random_message_time();
    
    if (bimbo_talk_on || renamer_on)
    {
        renamer_full = "";
        if (renamer_prefix != "")
        {
            renamer_full += renamer_prefix + " ";
        }
        if (renamer_name != "")
        {
            renamer_full += renamer_name;
        } else
        {
            renamer_full += g_sWearer;
        }

        llListenControl(g_iGL, TRUE);
        apply_ditzy();
    }
    else
    {
        llListenControl(g_iGL, FALSE);
    }
    llOwnerSay("Your brain feels like it's been filled with cotton candy. The ditzy haze is bliss and you can't remember ever feeling any other way. You are a bimbo!");
    if (g_bLocked)
    {
        llOwnerSay("@detach=n");
    }
    else
    {
        llOwnerSay("@detach=y");
        llOwnerSay("However the cotton candy in your brain has lifted just enough that you could clear your head . . . if you really wanted to.");
    }
}

pick_random_message_time()
{
    integer timediff = bimbo_random_max - bimbo_random_min;
    llSetTimerEvent(llFrand((float)timediff) + (float)bimbo_random_min);
}

apply_ditzy()
{
    string clear = "@clear,notify:"+(string)(g_iChan+1)+";sendchat=add,notify:"+(string)(g_iChan+1)+";clear=add";
    if (!isGagged)
    {
        clear += ",redirchat:"+(string)g_iChan+"=add,rediremote:"+(string)g_iChan+"=add";
    }
    if (g_bLocked)
    {
        clear += ",detach=n";
    }
    llOwnerSay(clear);

    if (g_bIsDitzy)
    {
        llOwnerSay("@" + llDumpList2String(ditzy_rlv, "=n,") + "=n");
    }
}

process_config(string data)
{
    if (data == EOF)
    {
        g_bGoodConfig=TRUE;
        apply_config();
        return;
    }
    
    if (data != "")
    {
        if (llSubStringIndex(data, "#") != 0)
        {
            integer i = llSubStringIndex(data, "=");
            if (i != -1)
            {  
            //  get name of name/value pair
                string name = llGetSubString(data, 0, i - 1);
 
            //  get value of name/value pair
                string value = llGetSubString(data, i + 1, -1);
 
            //  trim name
                list temp = llParseString2List(name, [" "], []);
                name = llDumpList2String(temp, " ");
 
            //  make name lowercase (case insensitive)
                name = llToLower(name);
 
            //  trim value
                temp = llParseString2List(value, [" "], []);
                value = llDumpList2String(temp, " ");
                if (name == "renamer_on")
                {
                    renamer_on = istrue(value);
                }
                else if (name == "bimbo_talk_on")
                {
                    bimbo_talk_on = istrue(value);
                }
                else if (name == "ditzy_on")
                {
                    ditzy_on = istrue(value);
                }
                else if (name == "renamer_name")
                {
                    renamer_name = value;
                }
                else if (name == "renamer_prefix")
                {
                    renamer_prefix = value;
                }
                else if (name == "ditzy_chance")
                {
                    ditzy_chance = (integer)value;
                }
                else if (name == "ditzy_min_time")
                {
                    ditzy_min_time = (integer)value;
                }
                else if (name == "ditzy_max_time")
                {
                    ditzy_max_time = (integer)value;
                }
                else if (name == "ditzy_rlv")
                {
                    ditzy_rlv = llParseString2List(value, ["|", ","], []);
                }
                else if (name == "bimbo_say_skip")
                {
                    bimbo_say_skip = (integer)value;
                } else if (name == "bimbo_say_mid_chance")
                {
                    bimbo_say_mid_chance = (integer)value;
                }
                else if (name == "bimbo_say_mid")
                {
                    bimbo_say_mid += value;
                }
                else if (name == "bimbo_say_pre_chance")
                {
                    bimbo_say_pre_chance = (integer)value;
                }
                else if (name == "bimbo_say_pre_chance")
                {
                    bimbo_say_pre_chance = (integer)value;
                }
                else if (name == "bimbo_say_pre")
                {
                    bimbo_say_pre += value;
                }
                else if (name == "bimbo_say_post_chance")
                {
                    bimbo_say_post_chance = (integer)value;
                }
                else if (name == "bimbo_say_post")
                {
                    bimbo_say_post += value;
                }
                else if (name == "bimbo_say_replace")
                {
                    bimbo_say_replace += value;
                } else if (name == "bimbo_emote_post_chance")
                {
                    bimbo_emote_post_chance = (integer)value;
                }
                else if (name == "bimbo_emote_post")
                {
                    bimbo_emote_post += value;
                }
                else if (name == "bimbo_random_min")
                {
                    bimbo_random_min = (integer)value;
                }
                else if (name == "bimbo_random_max")
                {
                    bimbo_random_max = (integer)value;
                }
            }
        }
    }
    g_kNotecardQueryId = llGetNotecardLine(g_sConfigNotecard, ++g_iConfigLine);
}

string list_random(list messages)
{
    integer end = llGetListLength(messages);
    return llList2String(messages, (integer)llFrand((float)end));
}

integer is_punctuation(string character)
{
    if(character == "." || character == "?" || character == "!" || character == "," || character == ":" || character == " " || character == ";")
    {
        return TRUE;
    }
    return FALSE;
}

string strReplace(string str, string search, string replace) {
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

string bimbo_replace(string word)
{
    integer z = 0;
    integer listlen = llGetListLength(bimbo_say_replace);
    for (; z < listlen; z++)
    {
        list replace = llParseStringKeepNulls(llList2String(bimbo_say_replace, z), ["|"], []);
        if (word == llList2String(replace, 0))
        {
            return llList2String(replace, 1);
        }
    }
    return word;
}

string process_say(string message)
{
    string output;
    list mid = llParseStringKeepNulls(message, [], [" ", ".", ",", "?", "!", ":", ";"]);
    if ((100-bimbo_say_pre_chance) <= (integer)llFrand(100.0))
    {
        output += list_random(bimbo_say_pre) + " ";
        string firstword = llList2String(mid, 0);
        if (firstword != "I")
        {
            string firstletter = llToLower(llGetSubString(firstword, 0, 0));
            mid = llListReplaceList(mid, [llInsertString(llDeleteSubString(firstword, 0, 0), 0, firstletter)], 0, 0);
        }
    }
    
    integer bimbo_distance = 0;
    integer x = 0;
    integer listlen = llGetListLength(mid);
    for (; x < listlen; x++)
    {
        string y = bimbo_replace(llList2String(mid, x));
        output += y;
        if (!is_punctuation(y) && y != "")
        {
            if (bimbo_distance > 0) bimbo_distance--;
            if (bimbo_distance == 0 && (100-bimbo_say_mid_chance) <= (integer)llFrand(100.0))
            {
                string midtext = list_random(bimbo_say_mid);
                if (!is_punctuation(llGetSubString(midtext, 0, 0)))
                {
                    output += " ";
                }
                output += midtext;
                bimbo_distance = bimbo_say_skip;
            }
        }
    }

    if ((100-bimbo_say_post_chance) <= (integer)llFrand(100.0))
    {
        integer length = llStringLength(output);
        string posttext = list_random(bimbo_say_post);
        if (!is_punctuation(llGetSubString(posttext, 0, 0)))
        {
            posttext = " " + posttext;
        }

        if (is_punctuation(llGetSubString(output, -1,-1)))
        {
            output = llInsertString(output, length-1, posttext);
        }
        else
        {
            output += posttext;
        }
    }
    return output;
}

string process_emote(string message)
{
    string output = message;
    if ((100-bimbo_emote_post_chance) <= (integer)llFrand(100.0))
    {
        integer length = llStringLength(output);
        string posttext = list_random(bimbo_emote_post);
        if (!is_punctuation(llGetSubString(posttext, 0, 0)))
        {
            posttext = " " + posttext;
        }

        if(is_punctuation(llGetSubString(output, -1,-1)))
        {
            output = llInsertString(output, length-1, posttext);
        }
        else
        {
            output += posttext;
        }
    }
    return output;
}

talker_say(string message)
{
    string sOldName = llGetObjectName();
    if(renamer_on)
    {
        llSetObjectName(renamer_full);
    }
    else
    {
        llSetObjectName(g_sWearer);
    }
    llSay(0, message);
    llSetObjectName(sOldName);
}

startup()
{
        llOwnerSay("@clear,detach=n");
        g_sWearer = llGetDisplayName(llGetOwner());
}

default
{
    on_rez(integer start_param)
    {
        startup();
        apply_config();
    }

    state_entry()
    {
        g_iChan = llRound(llFrand(499) + 2000);
        g_iGL = llListen(g_iChan, "", llGetOwner(), "");
        llListen(g_iChan+1, "", llGetOwner(), "");
        g_iGL2 = llListen(g_iChan+2, "", llGetOwner(), "");
        llListenControl(g_iGL, FALSE);
        llListenControl(g_iGL2, FALSE);
        startup();
        load_config();
    }
    listen(integer channel, string name, key id, string message)
    {
        if (channel == g_iChan)
        {
            if(g_bIsDitzy)
            {
                if (num_ditzy_try > 0)
                {
                    say_key = llGetNotecardLine("ditzy-try", (integer)llFrand((float)num_ditzy_try));
                }
                else
                {
                    talker_say("...");
                }
            }
            else
            {
                string sOut;
                if (llGetSubString(message, 0, 2) == "/me")
                {
                    // Emote processing
                    sOut = process_emote(message);
                }
                else
                {
                    // Say processing
                    // First, check to see if ditzy triggers . . .
                    if ((100-ditzy_chance) <= (integer)llFrand(100.0))
                    {
                        // Space out time!
                        llSetTimerEvent(0.0);
                        g_bIsDitzy = TRUE;
                        apply_ditzy();
                        integer timediff = ditzy_max_time - ditzy_min_time;
                        llSetTimerEvent(llFrand((float)timediff) + (float)ditzy_min_time);
                        if (num_ditzy_text > 0)
                        {
                            say_key = llGetNotecardLine("ditzy-text", (integer)llFrand((float)num_ditzy_text));
                        }
                        llOwnerSay("You are spacing out for a bit!");
                    }
                    else
                    {
                        sOut = process_say(message);
                    }
                }
                talker_say(sOut);
            }
        }
        if (channel == g_iChan+1)
        {
            if (llGetSubString(message, 0, 6) == "/notify")
            {
                return;
            }
            llListenControl(g_iGL2, TRUE);
            llOwnerSay("@getstatusall:sendchat="+(string)(g_iChan+2));
        }
        if (channel == g_iChan+2)
        {
            llListenControl(g_iGL2, FALSE);
            list messages = llParseString2List(message, ["/"], []);
            integer curmess = 0;
            integer totmess = llGetListLength(messages);
            integer statusrefresh = FALSE;
            integer sendchat = FALSE;
            integer foundgag = FALSE;
            for (; curmess < totmess; curmess++)
            {
                string rlvcmd = llList2String(messages, curmess);
                if (rlvcmd == "notify:"+(string)(g_iChan+1)+";sendchat")
                {
                    sendchat = TRUE;
                }
                else if (rlvcmd == "sendchat")
                {
                    foundgag = TRUE;
                }
            }
            if (sendchat && !foundgag && isGagged)
            {
                isGagged = FALSE;
                statusrefresh = TRUE;
            }
            if (sendchat && foundgag && !isGagged)
            {
                isGagged = TRUE;
                statusrefresh = TRUE;
            }
            if (statusrefresh)
            {
                apply_ditzy();
            }
        }
    }

    changed(integer change)
    {
        if (change & CHANGED_OWNER)
        {
            llResetScript();
        }

        if(change & CHANGED_INVENTORY)
        {
            startup();
            load_config();
        }
    }

    timer()
    {
        llSetTimerEvent(0.0);
        if (g_bIsDitzy)
        {
            g_bIsDitzy=FALSE;
            apply_ditzy();
            if (num_ditzy_end > 0)
            {
                say_key = llGetNotecardLine("ditzy-end", (integer)llFrand((float)num_ditzy_end));
            }
            llOwnerSay("You no longer are spacing out.");
        }
        else if (!isGagged)
        {
            if (num_bimbo_random > 0)
            {
                say_key = llGetNotecardLine("bimbo-random", (integer)llFrand((float)num_bimbo_random));
            }
        }
        pick_random_message_time();
    }

    dataserver(key request_id, string data)
    {
        if(request_id == g_kNotecardQueryId)
        {
            process_config(data);
        }
        else if (request_id == say_key)
        {
            talker_say(data);
        }
        else if (request_id == bimbo_random_key)
        {
            num_bimbo_random = (integer)data;
        }
        else if (request_id == ditzy_end_key)
        {
            num_ditzy_end = (integer)data;
        }
        else if (request_id == ditzy_text_key)
        {
            num_ditzy_text = (integer)data;
        }
        else if (request_id == ditzy_try_key)
        {
            num_ditzy_try = (integer)data;
        }
    }

    touch_start(integer num_detected)
    {
        llResetTime();
    }

    touch_end(integer total_number)
    {
        if (!g_bGoodConfig)
        {
            return;
        }

        if(g_bLocked)
        {
            if(llDetectedKey(0) == llGetOwner())
            {
                llOwnerSay("Silly bimbo, you'll have to find somebody else to tinker with your brain!");
                return;
            }
            else if (llGetTime() < 1.0)
            {
                llOwnerSay(llGetDisplayName(llDetectedKey(0))+ " tried to free your brain, but they didn't do it for long enough! Have them poke your forehead longer if you really want to release your mind.");
            }
            else
            {
                llRegionSayTo(llDetectedKey(0), 0, "You freed the lock on " + llGetDisplayName(llGetOwner()) + "'s mind!");
                g_bLocked = FALSE;
                llOwnerSay("@detach=y");
                llOwnerSay("The cotton candy in your brain lifts just enough that you could clear your head . . . if you really wanted to. You're no longer locked into being a ditzy bimbo.");
            }
        }
        else
        {
            if (llDetectedKey(0) != llGetOwner())
            {
                llRegionSayTo(llDetectedKey(0), 0, "You locked " + llGetDisplayName(llGetOwner()) + " into their ditzy state of mind! Somebody will have to fiddle with their forehead for a second if they want to get freed again.");
            }
            g_bLocked = TRUE;
            llOwnerSay("@detach=n");
            llOwnerSay("Your brain feels like it's been filled full of cotton candy! You're locked into being a ditzy bimbo!");
        }
        llSleep(0.5);
    }
}
