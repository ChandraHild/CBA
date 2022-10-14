/*
Copyright (c) 2016 Flickrstar Timeless


Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

// Config variables
//    These will get set by notecard
integer renamer_on;
integer listener_on;
integer bimbo_talk_on;
integer ditzy_on;
string renamer_name;
string renamer_prefix;
string renamer_full;
integer ditzy_chance;
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
integer bimbo_limit_long_say;
integer bimbo_long_word_size=7;
integer bimbo_long_word_count=1;
integer num_bimbo_random;
integer num_ditzy_end;
integer num_ditzy_text;
integer num_ditzy_try;

// Global variables
key g_kNotecardQueryId;
key say_key;
key bimbo_random_key;
key ditzy_end_key;
key ditzy_text_key;
key ditzy_try_key;
key rating_check_key;
integer g_iConfigLine;
integer g_iGL;
integer g_iGL2;
integer g_iChan;
integer g_public_chat;
integer g_bIsDitzy;
integer outsideRLV=0; // 1 for gag, 2 for whisper
integer foundRLV=0; // 1 for gag, 2 for whisper
integer is_safe_sim;
integer phrases_allowed = TRUE;

integer istrue(string data)
{
   if (llToLower(data)=="y" || (integer)data==1)
   {
       return TRUE;
    }
    return FALSE;  
}

apply_config()
{
    string g_sWearer = llGetDisplayName(llGetOwner());
    rating_check_key = llRequestSimulatorData(llGetRegionName(), DATA_SIM_RATING);

    pick_random_message_time();

    llListenControl(g_public_chat, listener_on);

    if (bimbo_talk_on || renamer_on)
    {
        renamer_full = "";
        if (renamer_prefix)
        {
            renamer_full += renamer_prefix + " ";
        }
        if (renamer_name)
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

    if(renamer_on)
    {
        llSetObjectName(renamer_full);
    }
    else
    {
        llSetObjectName(g_sWearer);
    }
}

pick_random_message_time()
{
    integer timediff = bimbo_random_max - bimbo_random_min;
    llSetTimerEvent(llFrand((float)timediff) + (float)bimbo_random_min);
}

apply_ditzy()
{
    string clear = "@clear,notify:"+(string)(g_iChan+1)+";chat=add,notify:"+(string)(g_iChan+1)+";clear=add";
    if (!(outsideRLV & 1))
    {
        clear += ",redirchat:"+(string)g_iChan+"=add,rediremote:"+(string)g_iChan+"=add";
    }
    if (listener_on)
    {
        clear += ",recvchat=n,recvemote=n";
    }

    llOwnerSay(clear);

    if (g_bIsDitzy)
    {
        llOwnerSay("@" + llDumpList2String(ditzy_rlv, "=n,") + "=n");
    }
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

talker_say(string message)
{
    if (outsideRLV & 2)
    {
        llWhisper(0, message);
    }
    else
    {
        llSay(0, message);
    }
}

default
{
    state_entry()
    {
        if (llGetInventoryType("Config") != INVENTORY_NOTECARD)
        {
            llOwnerSay("Missing configuration notecard: Config");
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
        g_kNotecardQueryId = llGetNotecardLine("Config", g_iConfigLine);
    }

    dataserver(key request_id, string data)
    {
        if(request_id == g_kNotecardQueryId)
        {
            if (data == EOF)
            {
                state off;
            }

            if (data)
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
                        else if (name == "listener_on")
                        {
                            listener_on = istrue(value);
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
                        else if (name == "bimbo_long_word_size")
                        {
                            bimbo_long_word_size = (integer)value;
                        }
                        else if (name == "bimbo_long_word_count")
                        {
                            bimbo_long_word_count = (integer)value;
                        }
                        else if (name == "bimbo_limit_long_say")
                        {
                            bimbo_limit_long_say = istrue(value);
                        }
                    }
                }
            }
            g_kNotecardQueryId = llGetNotecardLine("Config", ++g_iConfigLine);
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
}

state off
{
    state_entry()
    {
        llOwnerSay("Your brain feels perfectly clear. You can think properly!");
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        if (num == 17)
        {
            if (str == "Bimbo")
            {
                state on;
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
            llResetScript();
        }
    }
}

state on
{
    link_message(integer sender_num, integer num, string str, key id)
    {
        if (num == 17)
        {
            if (str == "Bimbo")
            {
                phrases_allowed = TRUE;
            }
            else if (str == "Display")
            {
                phrases_allowed = FALSE;
            }
            else
            {
                state off;
            }
        }
    }

    on_rez(integer start_param)
    {
        apply_config();
    }

    state_entry()
    {
        llOwnerSay("Your brain feels like it's been filled with cotton candy. The ditzy haze is bliss and you can't remember ever feeling any other way. You are a bimbo!");
        g_iChan = (integer)llFrand(499) + 20000;
        g_iGL = llListen(g_iChan, "", llGetOwner(), "");
        llListen(g_iChan+1, "", llGetOwner(), "");
        g_iGL2 = llListen(g_iChan+2, "", llGetOwner(), "");
        g_public_chat = llListen(0, "", NULL_KEY, "");
        llListenControl(g_iGL, FALSE);
        llListenControl(g_iGL2, FALSE);
        apply_config();
    }

    state_exit()
    {
        llOwnerSay("@clear");
        llSetTimerEvent(0);
    }

    listen(integer channel, string name, key id, string message)
    {
        if (channel == 0)
        {
            key owner = llGetOwnerKey(id);
            if (owner == llGetOwner())
            {
                return;
            }

            string old_name = llGetObjectName();
            llSetObjectName(" ");

            if (owner == id)
            {
                name = llGetDisplayName(id);
            }

            if (llGetSubString(message, 0, 2) == "/me")
            {
                llOwnerSay(name + " " + llGetSubString(message, 4, -1));
            }
            else
            {
                list mid = llParseStringKeepNulls(message, [], [" ", ".", ",", "?", "!", ":", ";"]);
                message = "";
                integer x;
                integer long_words;
                integer listlen = llGetListLength(mid);
                for (; x < listlen; ++x)
                {
                    string y = llList2String(mid, x);
                    integer wordlen = llStringLength(y);
                    if (wordlen >= bimbo_long_word_size)
                    {
                        ++long_words;
                        if (long_words > bimbo_long_word_count)
                        {
                            string sortedword;
                            sortedword += llGetSubString(y, 0, 0);
                            y = llDeleteSubString(y, 0, 0);
                            while (wordlen > 0)
                            {
                                integer randpos = (integer)llFrand((float)wordlen);
                                sortedword += llGetSubString(y, randpos, randpos);
                                y = llDeleteSubString(y, randpos, randpos);
                                --wordlen;
                            }
                            y = sortedword;
                        }
                    }
                    message += y;
                }
                llOwnerSay(name + ": " + message);
            }
            llSetObjectName(old_name);
        }
        else if (channel == g_iChan)
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
                return;
            }

            if (bimbo_talk_on)
            {
                if (llGetSubString(message, 0, 2) == "/me")
                {
                    // Emote processing
                    if ((100-bimbo_emote_post_chance) <= (integer)llFrand(100))
                    {
                        integer length = llStringLength(message);
                        string posttext = list_random(bimbo_emote_post);
                        if (!is_punctuation(llGetSubString(posttext, 0, 0)))
                        {
                            posttext = " " + posttext;
                        }

                        if(is_punctuation(llGetSubString(message, -1,-1)))
                        {
                            message = llInsertString(message, length-1, posttext);
                        }
                        else
                        {
                            message += posttext;
                        }
                    }
                }
                else
                {
                    // Say processing
                    // First, check to see if ditzy triggers . . .
                    if ((100-ditzy_chance) <= (integer)llFrand(100))
                    {
                        // Space out time!
                        llSetTimerEvent(0);
                        g_bIsDitzy = TRUE;
                        apply_ditzy();
                        integer timediff = ditzy_max_time - ditzy_min_time;
                        llSetTimerEvent(llFrand((float)timediff) + (float)ditzy_min_time);
                        if (num_ditzy_text > 0)
                        {
                            say_key = llGetNotecardLine("ditzy-text", (integer)llFrand((float)num_ditzy_text));
                        }
                        llOwnerSay("You are spacing out for a bit!");
                        return;
                    }

                    list mid = llParseStringKeepNulls(message, [], [" ", ".", ",", "?", "!", ":", ";"]);
                    message = "";
                    if ((100-bimbo_say_pre_chance) <= (integer)llFrand(100))
                    {
                        message = list_random(bimbo_say_pre) + " ";
                        string firstword = llList2String(mid, 0);
                        if (firstword != "I")
                        {
                            string firstletter = llToLower(llGetSubString(firstword, 0, 0));
                            mid = llListReplaceList(mid, [llInsertString(llDeleteSubString(firstword, 0, 0), 0, firstletter)], 0, 0);
                        }
                    }

                    integer bimbo_distance = 0;
                    integer x = 0;
                    integer long_words = 0;
                    integer listlen = llGetListLength(mid);
                    integer blistlen = llGetListLength(bimbo_say_replace);
                    for (; x < listlen; ++x)
                    {
                        string y = llList2String(mid, x);
                        if (bimbo_limit_long_say)
                        {
                            if (llStringLength(y) >= bimbo_long_word_size)
                            {
                                ++long_words;
                                if (long_words > bimbo_long_word_count)
                                {
                                    y = "stuff";
                                }
                            }
                        }
                        integer z;
                        for (; z < blistlen; ++z)
                        {
                            list replace = llParseStringKeepNulls(llList2String(bimbo_say_replace, z), ["|"], []);
                            if (y == llList2String(replace, 0))
                            {
                                y = llList2String(replace, 1);
                            }
                        }
                        message += y;
                        if (!is_punctuation(y) && y != "")
                        {
                            if (bimbo_distance > 0) --bimbo_distance;
                            if (bimbo_distance == 0 && (100-bimbo_say_mid_chance) <= (integer)llFrand(100))
                            {
                                string midtext = list_random(bimbo_say_mid);
                                if (!is_punctuation(llGetSubString(midtext, 0, 0)))
                                {
                                    message += " ";
                                }
                                message += midtext;
                                bimbo_distance = bimbo_say_skip;
                            }
                        }
                    }

                    if ((100-bimbo_say_post_chance) <= (integer)llFrand(100))
                    {
                        integer length = llStringLength(message);
                        string posttext = list_random(bimbo_say_post);
                        if (!is_punctuation(llGetSubString(posttext, 0, 0)))
                        {
                            posttext = " " + posttext;
                        }

                        if (is_punctuation(llGetSubString(message, -1,-1)))
                        {
                            message = llInsertString(message, length-1, posttext);
                        }
                        else
                        {
                            message += posttext;
                        }
                    }
                }
            }
            if (message)
            {
                talker_say(message);
            }
        }
        else if (channel == g_iChan+1)
        {
            if (llGetSubString(message, 0, 6) == "/notify")
            {
                return;
            }
            llListenControl(g_iGL2, TRUE);
            foundRLV=0;
            llOwnerSay("@getstatusall:chat="+(string)(g_iChan+2));
        }
        else if (channel == g_iChan+2)
        {
            list messages = llParseString2List(message, ["/"], []);
            integer curmess = 0;
            integer totmess = llGetListLength(messages);
            for (; curmess < totmess; ++curmess)
            {
                string rlvcmd = llList2String(messages, curmess);
                if (rlvcmd == "sendchat" || (llGetSubString(rlvcmd, 0, 8) == "redirchat" && rlvcmd != "redirchat:"+(string)(g_iChan)))
                {
                    foundRLV = foundRLV | 1;
                }
                else if (rlvcmd == "chatnormal")
                {
                    foundRLV = foundRLV | 2;
                }
            }

            llListenControl(g_iGL2, FALSE);
            if (foundRLV != outsideRLV)
            {
                outsideRLV = foundRLV;
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
            llResetScript();
        }

        if (change & CHANGED_TELEPORT)
        {
            rating_check_key = llRequestSimulatorData(llGetRegionName(), DATA_SIM_RATING);
            apply_ditzy();
        }
    }

    timer()
    {
        llSetTimerEvent(0);
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
        else if (!(outsideRLV & 1) && is_safe_sim && phrases_allowed)
        {
            if (bimbo_talk_on && num_bimbo_random > 0)
            {
                say_key = llGetNotecardLine("bimbo-random", (integer)llFrand((float)num_bimbo_random));
            }
        }
        pick_random_message_time();
    }

    dataserver(key request_id, string data)
    {
        if (request_id == say_key)
        {
            talker_say(data);
        }
        else if (request_id == rating_check_key)
        {
            if (data == "PG")
            {
                is_safe_sim = FALSE;
            }
            else
            {
                is_safe_sim = TRUE;
            }
        }
    }
}