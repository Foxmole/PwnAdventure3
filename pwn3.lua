-- -----------------------------------------------------------
--
-- Name: Pwn Adventure 3 Wireshark Plugin
-- Version: v1.0.0 (01/05/2017)
-- Date: 20/06/2017
-- Created By: Antonin Beaujeant
-- Notes: For more information on this plugin visit https://blog.keyidentity.com/2017/06/20/pwnadventure3-building-a-wireshark-parser/
-- Feedback: If you have feedback on the plugin you can send it to pwn3<at>foxmole<dot>com
-- Protocol Documentation: https://blog.keyidentity.com/2017/06/13/pwnadventure3-network-protocol/
--
-- Release Notes:
-- 1.00 Initial Release.
--  - Authentication [missing info]
--  - Spawn position (1) [missing info]
--  - Spawn position (2) [missing info]
--  - Spawn position (3) [missing info]
--  - Send message
--  - Send answer
--  - Finish dialog
--  - Send dialog
--  - Purchase item
--  - Fire [missing info]
--  - Update health
--  - Spawn position (4) [missing info]
--  - Activate logic gate
--  - Spawn position (5) [missing info]
--  - Spawn position (6) [missing info]
--  - Remove quest
--  - Change location
--  - New inventory item
--  - Pick up item
--  - Event
--  - Fast travel
--  - Jump [missing info]
--  - Update mana
--  - New element [missing info]
--  - Update location [missing info]
--  - New quest
--  - Enemy position [missing info]
--  - New achievement
--  - Change PvP state
--  - Select quest
--  - Quest done
--  - Remove inventory item
--  - Run
--  - Respawn
--  - Teleport
--  - Change player state
--  - Change attack state
--  - Remove element
--
-- -----------------------------------------------------------


PWN3 = Proto ("pwn3", "Pwn Adventure 3 - Game server protocol")


-- FIELDS

local f = PWN3.fields

local opcodes = {
    [0x0200] = "Authentication",
    [0x1600] = "Spawn position [1]",
    [0x1700] = "Spawn position [2]",
    [0x2300] = "Spawn position [3]",
    [0x232a] = "Send message",
    [0x233e] = "Send answer",
    [0x2366] = "Finish dialog",
    [0x2373] = "Send dialog",
    [0x2462] = "Purchase item",
    [0x2a69] = "Fire",
    [0x2b2b] = "Update health",
    [0x3003] = "Spawn position [4]",
    [0x3031] = "Activate logic gate",
    [0x3206] = "Spawn position [5]",
    [0x4103] = "Spawn position [6]",
    [0x5e64] = "Remove quest",
    [0x6368] = "Change location",
    [0x6370] = "New inventory item",
    [0x6565] = "Pick up item",
    [0x6576] = "Event",
    [0x6674] = "Fast travel",
    [0x6a70] = "Jump",
    [0x6d61] = "Update mana",
    [0x6d6b] = "New element",
    [0x6d76] = "Update location",
    [0x6e71] = "New quest",
    [0x7073] = "Enemy position",
    [0x7075] = "New achievement",
    [0x7076] = "Change PvP state",
    [0x713d] = "Select quest",
    [0x713e] = "Quest done",
    [0x726d] = "Remove inventory item",
    [0x726e] = "Run",
    [0x7273] = "Respawn",
    [0x7274] = "Teleport",
    [0x7374] = "Change player state",
    [0x7472] = "Change attack state",
    [0x7878] = "Remove element"
}

local status = {
    [0x00] = "Disable",
    [0x01] = "Enable"
}

local speed = {
    [0x00] = "Walk",
    [0x01] = "Run"
}

local moves = {
    [0x00] = "Neutral",
    [0x7f] = "Forward",
    [0x81] = "Backward"
}

local strafes = {
    [0x00] = "Neutral",
    [0x7f] = "Right",
    [0x81] = "Left"
}

f.opcode = ProtoField.uint16 ("pwn3.opcode", "Action", base.HEX, opcodes)

f.posx = ProtoField.new ("X coordinate", "pwn3.posx", ftypes.FLOAT)
f.posy = ProtoField.new ("Y coordinate", "pwn3.posy", ftypes.FLOAT)
f.posz = ProtoField.new ("Z coordinate", "pwn3.posz", ftypes.FLOAT)

f.dirr = ProtoField.uint16 ("pwn3.dirr", "Direction roll", base.DEC)
f.diry = ProtoField.uint16 ("pwn3.diry", "Direction yaw", base.DEC)
f.dirp = ProtoField.uint16 ("pwn3.dirp", "Direction pitch", base.DEC)

f.vx = ProtoField.uint32 ("pwn3.vx", "Vector X", base.DEC)
f.vy = ProtoField.uint32 ("pwn3.vy", "Vector Y", base.DEC)
f.vz = ProtoField.uint32 ("pwn3.vz", "Vector Z", base.DEC)

f.mv = ProtoField.uint8 ("pwn3.mv", "Move", base.HEX, moves)
f.stf = ProtoField.uint8 ("pwn3.stf", "Strafe", base.HEX, strafes)

f.mana = ProtoField.uint32 ("pwn3.mana", "Mana", base.DEC)
f.health = ProtoField.uint32 ("pwn3.health", "Health", base.DEC)

f.gate = ProtoField.uint32 ("pwn3.gate", "Gate", base.DEC)

f.elid = ProtoField.uint16 ("pwn3.elid", "Element ID", base.DEC)
f.tid = ProtoField.uint16 ("pwn3.tid", "Target ID", base.DEC)

f.qt = ProtoField.uint16 ("pwn3.qt", "Quantity", base.DEC)

f.str = ProtoField.string ("pwn3.str", "String")

f.pvp = ProtoField.uint16 ("pwn3.pvp", "PvP status", base.HEX, status)

f.run = ProtoField.uint16 ("pwn3.run", "Speed", base.HEX, speed)

f.unknown = ProtoField.uint8 ("pwn3.unknown", "Unknown", base.HEX)



-- Create location node

function addLocation (location, offset, tree)

    local branch

    branch = tree:add (location(offset, 12), "Location")

    branch:add_le (f.posx, location(offset, 4))
    branch:add_le (f.posy, location(offset + 4, 4))
    branch:add_le (f.posz, location(offset + 8, 4))

end



-- Create direction node

function addDirection (direction, offset, tree)

    local branch

    branch = tree:add (direction(offset, 6), "Direction")

    branch:add_le (f.dirr, direction(offset, 2))
    branch:add_le (f.diry, direction(offset + 2, 2))
    branch:add_le (f.dirp, direction(offset + 4, 2))

end



-- Create vectors node

function addVectors (vectors, offset, tree)

    local branch

    branch = tree:add (vectors(offset, 12), "Vectors")

    branch:add_le (f.vx, vectors(offset, 4))
    branch:add_le (f.vy, vectors(offset + 4, 4))
    branch:add_le (f.vz, vectors(offset + 8, 4))

end



-- DISSECTOR

function PWN3.dissector (buffer, pinfo, tree)

    local subtree = tree:add (PWN3, buffer())

    local offset = 0

    while (offset < buffer:len()-1) do

        local opcode = buffer(offset, 2):uint()
        offset = offset + 2


        -- Authentication
        if (opcode == 0x0200 or opcode == 0x0500) then

            local length = buffer(offset+2, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 6+length), opcodes[opcode])

            -- Unknown
            branch:add (f.unknown, buffer(offset, 1))
            offset = offset + 1
            -- Unknown
            branch:add (f.unknown, buffer(offset, 1))
            offset = offset + 1

            -- String length
            offset = offset + 2

            branch:add (f.str, buffer(offset, length))
            offset = offset + length


        -- Spawn position
        elseif (opcode == 0x1600 or opcode == 0x1700 or opcode == 0x2300 or opcode == 0x3003 or opcode == 0x3206 or opcode == 0x4103) then

            local branch = subtree:add (buffer(offset-2, 22), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            -- Unknown
            branch:add (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add (f.unknown, buffer(offset, 1))
            offset = offset + 1

            addLocation (buffer, offset, branch)
            offset = offset + 12

            addDirection (buffer, offset, branch)
            offset = offset + 6


        -- Send message - Send answer
        elseif (opcode == 0x232a or opcode == 0x233e) then

            local length = buffer(offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 4+length), opcodes[opcode])

            -- String length
            offset = offset + 2

            branch:add (f.str, buffer(offset, length))
            offset = offset + length


        -- Finish dialog
        elseif (opcode == 0x2366) then

            local length = buffer(offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 2), opcodes[opcode])


        -- Send dialog
        elseif (opcode == 0x2373) then

            local length = buffer(offset+4, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 8+length), opcodes[opcode])

            -- Actor
            branch:append_text (", Actor: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.elid, buffer(offset, 4))
            offset = offset + 4

            -- String length
            offset = offset + 2

            branch:add (f.str, buffer(offset, length))
            offset = offset + length


        -- Purchase item
        elseif (opcode == 0x2462) then

            local length = buffer(offset+4, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 12+length), opcodes[opcode])

            -- Unknown
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1

            -- String length
            offset = offset + 2

            branch:append_text (", Item: " .. buffer(offset, length):string())
            branch:add (f.str, buffer(offset, length))
            offset = offset + length

            -- Quantity
            branch:append_text (", Quantity: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.qt, buffer(offset, 4))
            offset = offset + 4


        -- Fire
        elseif (opcode == 0x2a69) then

            local length = buffer(offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 16+length), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            -- String length
            offset = offset + 2

            branch:append_text (", Weapon: " .. buffer(offset, length):string())
            branch:add (f.str, buffer(offset, length))
            offset = offset + length

            addVectors (buffer, offset, branch)
            offset = offset + 12


        -- Update health
        elseif (opcode == 0x2b2b) then

            local branch = subtree:add (buffer(offset-2, 10), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            branch:append_text (", Actor: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.elid, buffer(offset, 4))
            offset = offset + 4

            branch:append_text (", HP: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.health, buffer(offset, 4))
            offset = offset + 4


        -- Activate logic gate
        elseif (opcode == 0x3031) then

            local length = buffer(offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 8+length), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            -- String length
            offset = offset + 2

            branch:append_text (", " .. buffer(offset, length):string())
            branch:add (f.str, buffer(offset, length))
            offset = offset + length

            branch:append_text (", Gate: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.gate, buffer(offset, 4))
            offset = offset + 4


        -- Remove quest
        elseif (opcode == 0x5e64) then

            local length = buffer(offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 4+length), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            -- String length
            offset = offset + 2

            branch:append_text (", Quest: " .. buffer(offset, length):string())
            branch:add (f.str, buffer(offset, length))
            offset = offset + length


        -- Change location
        elseif (opcode == 0x6368) then

            local length = buffer(offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 4+length), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            -- String length
            offset = offset + 2

            branch:append_text (", Location: " .. buffer(offset, length):string())
            branch:add (f.str, buffer(offset, length))
            offset = offset + length


        -- New inventory item
        elseif (opcode == 0x6370) then

            local length = buffer(offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 8+length), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            -- String length
            offset = offset + 2

            branch:append_text (", Item: " .. buffer(offset, length):string())
            branch:add (f.str, buffer(offset, length))
            offset = offset + length

            branch:append_text (", Quantity: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.qt, buffer(offset, 4))
            offset = offset + 4


        -- Pick up item
        elseif (opcode == 0x6565) then

            local branch = subtree:add (buffer(offset-2, 6), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            branch:append_text (", Element: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.elid, buffer(offset, 4))
            offset = offset + 4


        -- Event
        elseif (opcode == 0x6576) then

        local length_first = buffer(offset, 2):le_uint()
        local length_second = buffer(2+length_first+offset, 2):le_uint()
        local branch = subtree:add (buffer(offset-2, 6+length_first+length_second), opcodes[opcode])

        branch:add (f.opcode, buffer(offset-2, 2))

        -- String length
        offset = offset + 2

        branch:append_text (", Text: " .. buffer(offset, length_first):string())
        branch:add (f.str, buffer(offset, length_first))
        offset = offset + length_first

        -- String length
        offset = offset + 2

        branch:add (f.str, buffer(offset, length_second))
        offset = offset + length_second


        -- Fast travel
        elseif (opcode == 0x6674) then

            local length_from = buffer(offset, 2):le_uint()
            local length_to = buffer(2+length_from+offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 6+length_from+length_to), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            -- String length
            offset = offset + 2

            branch:append_text (", From: " .. buffer(offset, length_from):string())
            branch:add (f.str, buffer(offset, length_from))
            offset = offset + length_from

            -- String length
            offset = offset + 2

            branch:append_text (", To: " .. buffer(offset, length_to):string())
            branch:add (f.str, buffer(offset, length_to))
            offset = offset + length_to


        -- Jump
        elseif (opcode == 0x6a70) then

            local branch = subtree:add (buffer(offset-2, 3), opcodes[opcode])
            branch:add (f.opcode, buffer(offset-2, 2))

            -- Unknown
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1


        -- Update mana
        elseif (opcode == 0x6d61) then

            local branch = subtree:add (buffer(offset-2, 6), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            branch:append_text (", Mana: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.mana, buffer(offset, 4))
            offset = offset + 4


        -- New element
        elseif (opcode == 0x6d6b) then

            local length = buffer(offset + 9, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 35+length), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            branch:append_text (", ID: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.elid, buffer(offset, 4))
            offset = offset + 4

            -- Unknown
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1

            -- String length
            offset = offset + 2

            branch:append_text (", Element: " .. buffer(offset, length):string())
            branch:add (f.str, buffer(offset, length))
            offset = offset + length

            addLocation (buffer, offset, branch)
            offset = offset + 12

            addDirection (buffer, offset, branch)
            offset = offset + 6

            -- Unknown
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add_le (f.unknown, buffer(offset, 1))
            offset = offset + 1


        -- Update location
        elseif (opcode == 0x6d76) then

            local branch = subtree:add (buffer(offset-2, 22), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            addLocation (buffer, offset, branch)
            offset = offset + 12

            addDirection (buffer, offset, branch)
            offset = offset + 6

            local mv = buffer(offset, 1):uint()
            branch:add (f.mv, buffer(offset, 1))
            offset = offset + 1

            local stf = buffer(offset, 1):uint()
            branch:add (f.stf, buffer(offset, 1))
            offset = offset + 1

            if mv == 0xc0 or mx == 0x08 then

                -- Unknown
                branch:add (f.unknown, buffer(offset, 1))
                offset = offset + 1
                branch:add (f.unknown, buffer(offset, 1))
                offset = offset + 1

            end


        -- New quest
        elseif (opcode == 0x6e71) then

            local length = buffer(offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 4+length), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            -- String length
            offset = offset + 2

            branch:append_text (", Quest: " .. buffer(offset, length):string())
            branch:add (f.str, buffer(offset, length))
            offset = offset + length


        -- Enemy position
        elseif (opcode == 0x7073) then

            local branch = subtree:add (buffer(offset-2, 28), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            branch:append_text (", Actor: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.elid, buffer(offset, 4))
            offset = offset + 4

            addLocation (buffer, offset, branch)
            offset = offset + 12

            addDirection (buffer, offset, branch)
            offset = offset + 6

            -- Unknown
            branch:add (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add (f.unknown, buffer(offset, 1))
            offset = offset + 1
            branch:add (f.unknown, buffer(offset, 1))
            offset = offset + 1


        -- New achievement
        elseif (opcode == 0x7075) then

            local length = buffer(offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 4+length), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            -- String length
            offset = offset + 2

            branch:append_text (", Achievement: " .. buffer(offset, length):string())
            branch:add (f.str, buffer(offset, length))
            offset = offset + length


        -- Change PvP state
        elseif (opcode == 0x7076) then

            local branch = subtree:add (buffer(offset-2, 3), opcodes[opcode])
            branch:add (f.opcode, buffer(offset-2, 2))

            branch:append_text (", Status: " .. buffer(offset, 1))
            branch:add_le (f.pvp, buffer(offset, 1))
            offset = offset + 1


        -- Select quest
        elseif (opcode == 0x713d) then

            local length = buffer(offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 4+length), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            -- String length
            offset = offset + 2

            branch:append_text (", Quest: " .. buffer(offset, length))
            branch:add (f.str, buffer(offset, length))
            offset = offset + length


        -- Quest finished
        elseif (opcode == 0x713e) then

            local length_loc = buffer(offset, 2):le_uint()
            local length_quest = buffer(2+length_loc+offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 6+length_loc+length_quest), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            -- String length
            offset = offset + 2

            branch:add (f.str, buffer(offset, length_loc))
            offset = offset + length_loc

            -- String length
            offset = offset + 2

            branch:append_text (", Quest: " .. buffer(offset, length_quest):string())
            branch:add (f.str, buffer(offset, length_quest))
            offset = offset + length_quest


        -- Remove inventory item
        elseif (opcode == 0x726d) then

            local length = buffer(offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 8+length), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            -- String length
            offset = offset + 2

            branch:append_text (", Item: " .. buffer(offset, length):string())
            branch:add (f.str, buffer(offset, length))
            offset = offset + length

            -- Quantity
            branch:append_text (", Quantity: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.qt, buffer(offset, 4))
            offset = offset + 4


        -- Run
        elseif (opcode == 0x726e) then

            local branch = subtree:add (buffer(offset-2, 3), opcodes[opcode])
            branch:add (f.opcode, buffer(offset-2, 2))

            branch:append_text (", Status: " .. buffer(offset, 1))
            branch:add_le (f.run, buffer(offset, 1))
            offset = offset + 1


        -- Respawn
        elseif (opcode == 0x7273) then

            local branch = subtree:add (buffer(offset-2, 20), opcodes[opcode])
            branch:add (f.opcode, buffer(offset-2, 2))

            addLocation (buffer, offset, branch)
            offset = offset + 12

            addDirection (buffer, offset, branch)
            offset = offset + 6


        -- Change player state
        elseif (opcode == 0x7374) then

            local length = buffer(offset + 4, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 8+length), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            branch:append_text (", Actor: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.elid, buffer(offset, 4))
            offset = offset + 4

            -- String length
            offset = offset + 2

            branch:append_text (", State: " .. buffer(offset, length):string())
            branch:add (f.str, buffer(offset, length))
            offset = offset + length

            -- Unknown
            branch:add (f.unknown, buffer(offset, 1))
            offset = offset + 1


        -- Change attack state
        elseif (opcode == 0x7472) then

            local length = buffer(offset + 4, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 12+length), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            branch:append_text (", Actor: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.elid, buffer(offset, 4))
            offset = offset + 4

            -- String length
            offset = offset + 2

            branch:append_text (", State: " .. buffer(offset, length):string())
            branch:add (f.str, buffer(offset, length))
            offset = offset + length

            branch:append_text (", Target: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.tid, buffer(offset, 4))
            offset = offset + 4


        -- Remove element
        elseif (opcode == 0x7878) then

            local branch = subtree:add (buffer(offset-2, 3), opcodes[opcode])
            branch:add (f.opcode, buffer(offset-2, 2))

            branch:append_text (", Element: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.elid, buffer(offset, 4))
            offset = offset + 4


        -- Not found
        else

            local branch = subtree:add (f.unknown, buffer(offset-2, 1))
            offset = offset - 1

        end
    end
end


tcp_table = DissectorTable.get ("tcp.port")
tcp_table:add (3000, PWN3)
tcp_table:add (3001, PWN3)
tcp_table:add (3002, PWN3)
tcp_table:add (3003, PWN3)
