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


        -- Fire
        if (opcode == 0x2a69) then

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


        -- Update mana
        elseif (opcode == 0x6d61) then

            local branch = subtree:add (buffer(offset-2, 6), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            branch:append_text (", Mana: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.mana, buffer(offset, 4))
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
