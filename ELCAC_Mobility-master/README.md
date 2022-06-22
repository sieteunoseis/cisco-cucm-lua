# CUCM Enhanced Locations CAC Mobility
Device Mobility, but for Locations.

---

### Problem
CUCM CAC will deduct bandwidth from the location that is applied to the SIP trunk when a call is sent over that trunk.
If the other end of the SIP trunk redirects the media to another location CUCM CAC is now possibly deducting the bandwidth from the wrong location.

Fortunatly CUCM 9+ gives us ELCAC which allows CUCM to be advised of the correct location for CAC purposes.

When a SIP trunk is configured in the shadow location, the trunk will accept the location name and bandwidth class in the call-info header of the SIP message:
```
Call-Info: <urn:x-cisco-remotecc:callinfo>;x-cisco-loc-id=<GUID>;x-cisco-loc-name=<LOCATION_NAME>;x-cisco;fateshare;id=<FATESHARE-ID>;x-cisco-video-traffic-class=desktop
```
By Populating the Call-Info header with the correct information we can ask CUCM to deduct bandwidth from the correct Location.

This relies on the remote endpoint adding this information into the SIP message. But what if the remote endpoint doesnt support this?

---

### Solution
How about Device Mobility, but for Locations.

To solve this problem, I have created a SIP Normalisation (LUA) script that does the following:
- Grabs the Media Address from the SDP.
- Looks this up in a table based on prefix/length and finds the associated location name
- Re-writes the call-info header to tell CUCM what location to deduct bandwidth from.
- Submits the modified SIP message to Call Manager.

---

### Using the script
To use the script you will need to perform some light modification. This is to add your locations.

Line 77:
```
    local LOC_COUNT = 7     -- Must match the amount of locations we have in our table below.
```
The value (7 here) must match the number of location entries in the next table.

Line 78:
```
    local LOCATIONS = {
        {["NAME"] = "LOC-TEST-2", ["PREFIX"]="192.168.101.0", ["LENGTH"]="24", ["PKID"]="106ab138-5a44-4a50-b7c4-3f8befd8f38c"},
        {["NAME"] = "LOC-TEST-2", ["PREFIX"]="192.168.102.0", ["LENGTH"]="24", ["PKID"]="106ab138-5a44-4a50-b7c4-3f8befd8f38c"},
        {["NAME"] = "LOC-TEST-2", ["PREFIX"]="192.168.103.0", ["LENGTH"]="24", ["PKID"]="106ab138-5a44-4a50-b7c4-3f8befd8f38c"},
        {["NAME"] = "LOC-TEST-2", ["PREFIX"]="192.168.104.0", ["LENGTH"]="24", ["PKID"]="106ab138-5a44-4a50-b7c4-3f8befd8f38c"},
        {["NAME"] = "LOC-TEST-2", ["PREFIX"]="192.168.105.0", ["LENGTH"]="24", ["PKID"]="106ab138-5a44-4a50-b7c4-3f8befd8f38c"},
        {["NAME"] = "LOC-TEST-2", ["PREFIX"]="192.168.105.0", ["LENGTH"]="24", ["PKID"]="106ab138-5a44-4a50-b7c4-3f8befd8f38c"},
        {["NAME"] = "LOC-TEST-3", ["PREFIX"]="192.168.0.0", ["LENGTH"]="16", ["PKID"]="3eed0571-38b7-4f09-9182-d1b8ad6b34cc"},
    }
```
This is your locations table, the fields should be pretty self explanitory:
- Name - This MUST match your CUCM Location name.
- Prefix - This is the subnet that belongs to this location.
- Length - The number of significant bits in the prefix.
- PKID - I dont know what this is used for (Please let me know if you do). My testing indicates duplicates are permitted.

---

### Development Notes:
During the development of this script several methods were tried and changed due to certain limitations. In the intrest of not re-inventing the wheel, these have been documented here.

#### Use CUCM lua math functions.
Wait a minute, Cisco didnt implement them....

#### Conversion using dec2bin function.
Convert the SDP media address to a binary padded string then loop over a table to compare it to a network address.

Due to CUCM's LuaInstructionThreshold of 10,000 the following limits exist:
- trace on: 4 networks.
- trace off: 9 networks.

#### Conversion using static table.
Created a static table mapping decimal values 0 to 255 to their binary equivalent. Convert IP to binary using this table then loop over the locations table to find a match.

Due to CUCM's LuaInstructionThreshold of 10,000 the following limits exist:
- trace on: 97 networks.
- trace off: 137 networks.

---

#### Random Links:
They may or may not work anymore, your mileage may vary...
[http://www.cisco.com/c/en/us/td/docs/voice_ip_comm/cucm/srnd/9x/uc9x/cac.html#wp1487804](http://www.cisco.com/c/en/us/td/docs/voice_ip_comm/cucm/srnd/9x/uc9x/cac.html#wp1487804)
[https://supportforums.cisco.com/discussion/11800741/vcs-cucm-sip-calls-dont-disconnect](https://supportforums.cisco.com/discussion/11800741/vcs-cucm-sip-calls-dont-disconnect)
[http://solutionpartnerdashboard.cisco.com/documents/385831/422301/SIP+Trunk+Messaging+Guide+(Extended)%20v9.1(1).pdf](http://solutionpartnerdashboard.cisco.com/documents/385831/422301/SIP+Trunk+Messaging+Guide+(Extended)%20v9.1(1).pdf)
