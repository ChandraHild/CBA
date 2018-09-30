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
integer ditzy_time=60;
list ditzy_text;
list ditzy_end;
list ditzy_try;
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
list bimbo_random;

// Global variables
string g_sConfigNotecard="Config";
key g_kNotecardQueryId;
integer g_iConfigLine=0;
integer g_iGL;
integer g_iChan;
key g_kWearer;
string g_sWearer;
integer g_bGoodConfig=FALSE;
integer g_bIsDitzy=FALSE;
integer g_bLocked=TRUE;

integer istrue(string data)
{
   if(llToLower(data)=="y" || (integer)data==1)
   {
       return TRUE;
    }
    else
    {
        return FALSE;
    }
    
}
load_config() {
    llSetTimerEvent(0.0);
    llOwnerSay("As you put on the mysteriously labeled CBA you feel a tingle in your head, and strange thoughts start filling your mind.");
    if(llGetInventoryType(g_sConfigNotecard) != INVENTORY_NOTECARD){
        llOwnerSay("Missing configuration notecard: " + g_sConfigNotecard);
        llOwnerSay("@detach=y");
        return;
    }
    g_iConfigLine=0;
    g_kNotecardQueryId = llGetNotecardLine(g_sConfigNotecard, g_iConfigLine);
}

apply_config() {
    if(!g_bGoodConfig) {
        llOwnerSay("Bad configuration detected, resetting script . . .");
        llResetScript();
        return;
    }
    pick_random_message_time();
    
    if(bimbo_talk_on || renamer_on) {
        renamer_full = "";
        if (renamer_prefix != "") renamer_full += renamer_prefix + " ";
        if (renamer_name != "") {
            renamer_full += renamer_name;
        } else {
            renamer_full += g_sWearer;
        }

        llListenControl(g_iGL, TRUE);
        clear_ditzy();
    } else {
        llListenControl(g_iGL, FALSE);
    }
    llOwnerSay("Your brain feels like it's been filled with cotton candy. The ditzy haze is bliss and you can't remember ever feeling any other way. You are a bimbo!");
    if (g_bLocked)
    {
        llOwnerSay("@detach=n");
    } else {
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
    llOwnerSay("@" + llDumpList2String(ditzy_rlv, "=n,") + "=n");
}

clear_ditzy()
{
    integer count = 0;
    for(; count < llGetListLength(ditzy_rlv); count++)
    {
        llOwnerSay("@clear=" + llList2String(ditzy_rlv, count));
    }
    llOwnerSay("@clear=rediremote");
    llOwnerSay("@clear=redirchat");
    llOwnerSay("@rediremote:"+(string)g_iChan+"=add,redirchat:"+(string)g_iChan+"=add");
}

process_config(string data) {
    if(data == EOF)
    {
        g_bGoodConfig=TRUE;
        apply_config();
        return;
    }
    
    if(data != "")
    {
        if(llSubStringIndex(data, "#") != 0)
        {
            integer i = llSubStringIndex(data, "=");
            if(i != -1)
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
                if (name == "renamer_on") {
                    if(istrue(value)) {
                        renamer_on=TRUE;
                    } else {
                        renamer_on=FALSE;
                    }
                } else if (name == "bimbo_talk_on") {
                    if (istrue(value)) {
                        bimbo_talk_on=TRUE;
                    } else {
                        bimbo_talk_on=FALSE;
                    }
                } else if (name == "ditzy_on") {
                    if (istrue(value)) {
                        ditzy_on=TRUE;
                    } else {
                        ditzy_on=FALSE;
                    }
                } else if (name == "renamer_name") {
                    renamer_name = value;
                } else if (name == "renamer_prefix") {
                    renamer_prefix = value;
                } else if (name == "ditzy_chance") {
                    ditzy_chance = (integer)value;
                } else if (name == "ditzy_time") {
                    ditzy_time = (integer)value;
                } else if (name == "ditzy_rlv") {
                    ditzy_rlv = llParseString2List(value, ["|", ","], []);
                } else if (name == "ditzy_text") {
                    ditzy_text += value;
                } else if (name == "ditzy_try") {
                    ditzy_try += value;
                } else if (name == "ditzy_end") {
                    ditzy_end += value;
                } else if (name == "bimbo_say_skip") {
                    bimbo_say_skip = (integer)value;
                } else if (name == "bimbo_say_mid_chance") {
                    bimbo_say_mid_chance = (integer)value;
                } else if (name == "bimbo_say_mid") {
                    bimbo_say_mid += value;
                } else if (name == "bimbo_say_pre_chance") {
                    bimbo_say_pre_chance = (integer)value;
                } else if (name == "bimbo_say_pre_chance") {
                    bimbo_say_pre_chance = (integer)value;
                } else if (name == "bimbo_say_pre") {
                    bimbo_say_pre += value;
                } else if (name == "bimbo_say_post_chance") {
                    bimbo_say_post_chance = (integer)value;
                } else if (name == "bimbo_say_post") {
                    bimbo_say_post += value;
                } else if (name == "bimbo_say_replace") {
                    bimbo_say_replace += value;
                } else if (name == "bimbo_emote_post_chance") {
                    bimbo_emote_post_chance = (integer)value;
                } else if (name == "bimbo_emote_post") {
                    bimbo_emote_post += value;
                } else if (name == "bimbo_random_min") {
                    bimbo_random_min = (integer)value;
                } else if (name == "bimbo_random_max") {
                    bimbo_random_max = (integer)value;
                } else if (name == "bimbo_random") {
                    bimbo_random += value;
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
    } else {
        return FALSE;
    }
}

string strReplace(string str, string search, string replace) {
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

string bimbo_replace(string word)
{
    integer z = 0;
    for(; z < llGetListLength(bimbo_say_replace); z++)
    {
        list replace = llParseStringKeepNulls(llList2String(bimbo_say_replace, z), ["|"], []);
        if(word == llList2String(replace, 0)) return llList2String(replace, 1);
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
    for(; x < llGetListLength(mid); x++)
    {
        string y = bimbo_replace(llList2String(mid, x));
        output += y;
        if(!is_punctuation(y) && y != "")
        {
            if (bimbo_distance > 0) bimbo_distance--;
            if (bimbo_distance == 0 && (100-bimbo_say_mid_chance) <= (integer)llFrand(100.0))
            {
                string midtext = list_random(bimbo_say_mid);
                if (!is_punctuation(llGetSubString(midtext, 0, 0))) output += " ";
                output += midtext;
                bimbo_distance = bimbo_say_skip;
            }
        }
    }

    if ((100-bimbo_say_post_chance) <= (integer)llFrand(100.0))
    {
        integer length = llStringLength(output);
        string posttext = list_random(bimbo_say_post);
        if (!is_punctuation(llGetSubString(posttext, 0, 0))) posttext = " " + posttext;

        if(is_punctuation(llGetSubString(output, -1,-1)))
        {
            output = llInsertString(output, length-1, posttext);
        } else {
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
        if (!is_punctuation(llGetSubString(posttext, 0, 0))) posttext = " " + posttext;

        if(is_punctuation(llGetSubString(output, -1,-1)))
        {
            output = llInsertString(output, length-1, posttext);
        } else {
            output += posttext;
        }
    }
    return output;
}

talker_say(string message)
{
    string sOldName = llGetObjectName();
    if(renamer_on) {
        llSetObjectName(renamer_full);
    } else {
        llSetObjectName(g_sWearer);
    }
    llSay(0, message);
    llSetObjectName(sOldName);
}

default
{
    on_rez(integer start_param)
    {
        key kWearer = llGetOwner();
        if (kWearer != g_kWearer)
        {
            llResetScript();
            return;
        }
        g_kWearer = kWearer;
        g_sWearer = llGetDisplayName(g_kWearer);
        apply_config();
    }

    state_entry()
    {
        llOwnerSay("@detach=n");
        g_kWearer = llGetOwner();
        g_sWearer = llGetDisplayName(g_kWearer);
        g_iChan = llRound(llFrand(499) + 2000);
        g_iGL = llListen(g_iChan, "", g_kWearer, "");
        llListenControl(g_iGL, FALSE);
        load_config();
    }
    listen(integer channel, string name, key id, string message)
    {
        if (channel == g_iChan) {
            if(g_bIsDitzy)
            {
                talker_say(list_random(ditzy_try));
            } else {
                string sOut;
                if(llGetSubString(message, 0, 2) == "/me")
                {
                    // Emote processing
                    sOut = process_emote(message);
                } else {
                    // Say processing
                    // First, check to see if ditzy triggers . . .
                    if ((100-ditzy_chance) <= (integer)llFrand(100.0))
                    {
                        // Space out time!
                        llSetTimerEvent(0.0);
                        g_bIsDitzy = TRUE;
                        apply_ditzy();
                        llSetTimerEvent((float)ditzy_time);
                        talker_say(list_random(ditzy_text));
                        llOwnerSay("You are spacing out for " + (string)ditzy_time + " seconds!");
                    } else
                    {
                        sOut = process_say(message);
                    }
                }
                talker_say(sOut);
            }
        }
    }

    changed(integer change)
    {
        if(change & (CHANGED_INVENTORY))
            llResetScript();
    }

    timer()
    {
        llSetTimerEvent(0.0);
        if (g_bIsDitzy)
        {
            g_bIsDitzy=FALSE;
            clear_ditzy();
            talker_say(list_random(ditzy_end));
            llOwnerSay("You no longer are spacing out.");
        } else {
            integer end = llGetListLength(bimbo_random);
            talker_say(llList2String(bimbo_random, (integer)llFrand((float)end)));
        }
        pick_random_message_time();
    }

    dataserver(key request_id, string data)
    {
        if(request_id == g_kNotecardQueryId) process_config(data);
    }

    touch_start(integer num_detected)
    {
        llResetTime();
    }

    touch_end(integer total_number)
    {
        if(g_bLocked)
        {
            if(llDetectedKey(0) == llGetOwner())
            {
                llOwnerSay("Silly bimbo, you'll have to find somebody else to tinker with your brain!");
                return;
            } else if (llGetTime() < 1.0)
            {
                llOwnerSay(llGetDisplayName(llDetectedKey(0))+ " tried to free your brain, but they didn't do it for long enough! Have them poke your forehead longer if you really want to release your mind.");
            } else {
                llRegionSayTo(llDetectedKey(0), 0, "You freed the lock on " + llGetDisplayName(llGetOwner()) + "'s mind!");
                g_bLocked = FALSE;
                llOwnerSay("@detach=y");
                llOwnerSay("The cotton candy in your brain lifts just enough that you could clear your head . . . if you really wanted to. You're no longer locked into being a ditzy bimbo.");
            }
        } else
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
