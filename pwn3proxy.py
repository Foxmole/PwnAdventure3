# -*- coding: utf-8 -*-
"""
Name: pwn3proxy.py
Version: v1.0.0 (23/06/2017)
Date: 23/06/2017
Created By: Antonin Beaujeant
Description: Pwn3Proxy is a custom asynchronous proxy for Pwn Adventure 3 based on https://gist.github.com/majek/1662475. More info: https://blog.keyidentity.com/2017/06/27/pwnadventure3-asynchronous-proxy-in-python/

Example:
    $ python pwn3proxy.py 192.168.1.10

"""

import argparse
import asyncore
import socket
import struct
import time
import re


def parse(p_out):

    """Contains all modifications to apply on the communication between the client and the server

    newspawn: Force the new spawn location to arbitrary values
    getme: Activate/Pick up an item
    loc: Fake player's location
    chat: Build a chat packet
    dialog: Send a dialog packet (to interact with NPC)
    event: Print text on the screen (locally)
    more: New inventory item (locally)
    rem: Remove an element on the map (locally)
    createel: Create an element on the map (locally)
    createan: Create an enemy on the map with "run" state (locally)
    kill: Kill an enemy (locally)

    ======

    Locations:

     - GreatBallsOfFire:    -43655.0,   -55820.0,    319.0
     - BearChest:            -7894.0,    64482.0,   2663.0
     - CowChest:            252920.0,  -245380.0,   1170.0
     - LavaChest:            50876.0,    -5243.0,   1523.0
     - BlockyChest:          -3055.0,    23005.0,   2275.0
     - GunShopOwner:        -37463.0,   -18050.0,   2416.0
     - JustinTolerant:      -41084.0,   -16256.0,   2270.0
     - Farmer:               21553.0,    41232.0,   2133.0
     - GoldenEgg1:          -25045.0,    18085.0,    260.0
     - GoldenEgg2:          -51570.0,   -61215.0,   5020.0
     - GoldenEgg3:           24512.0,    69682.0,   2659.0
     - GoldenEgg4:           60453.0,   -17409.0,   2939.0
     - GoldenEgg5:            1522.0 ,   14966.0,   7022.0
     - GoldenEgg6:           11604.0,   -13131.0,    411.0
     - GoldenEgg7:          -72667.0,   -53567.0,   1645.0
     - GoldenEgg8:           48404.0,    28117.0,    704.0
     - GoldenEgg9:           65225.0,    -5740.0,   4928.0
     - BallmerPeakEgg:       -2778.0,   -11035.0,  10504.0
     - MichaeAngelo:        260255.0,  -248555.0,   1415.0
     - BallmerPeakPoster:    -6101.0,   -10956.0,  10636.0

    """

    p_in = ""
    p_next =""

    def newspawn(opcode, x, y, z):
        return opcode + struct.pack("=HfffHHH", 0, x, y, z, 0, 0, 0)

    def newachievement(achievement):
        return 'pu' + struct.pack("H", len(achievement)) + achievement + "\x00"

    def getme(item):
        return "ee" + struct.pack("I", item)

    def loc(x, y, z):
        return "mv" + struct.pack("fffHHHBB", x, y, z, 0, 0, 0, 0, 0)

    def chat(msg):
        return "#*" + struct.pack("H", len(msg)) + msg

    def dialog(msg):
        return "#>" + struct.pack("H", len(msg)) + msg

    def event(msg_top, msg_bottom):
        return "ev" + struct.pack("H", len(msg_top)) + msg_top + struct.pack("H", len(msg_bottom)) + msg_bottom

    def more(item, qt):
        return "cp" + struct.pack("H", len(item)) + item + struct.pack("I", qt)

    def rem(item):
        return 'xx' + struct.pack("I", item)

    def createel(elid, item, x, y, z):
        packet = 'mk'
        packet += struct.pack("I", elid)
        packet += "\x00\x00\x00\x00\x00"
        packet += struct.pack("H", len(item)) + item
        packet += struct.pack("fffHHHBBBB", x, y, z, 0, 0, 0, 100, 0, 0, 0)
        return packet

    def createan(anid, item, x, y, z):
        # Create animal
        packet = 'mk'
        packet += struct.pack("I", anid)
        packet += "\x00\x00\x00\x00\x01"
        packet += struct.pack("H", len(item)) + item
        packet += struct.pack("IIIHHHBBBB", x, y, z, 0, 0, 0, 125, 0, 0, 0)
        # Change animal state
        st = "Run"
        packet += 'st'
        packet += struct.pack("I", anid)
        packet += struct.pack("H", len(st)) + st
        packet += "\x00"
        return packet

    def kill(anid):
        dead = 'Dead'
        packet = '++'
        packet += struct.pack("I", anid)
        packet += struct.pack("i", -10)
        packet += 'tr'
        packet += struct.pack("I", anid)
        packet += struct.pack("H", len(dead)) + dead
        packet += struct.pack("I", 0)
        return packet



    # Print health of enemy in console
    if "++" in p_out:
        posi = p_out.index("++")
        actor,health = struct.unpack("ii", p_out[posi+2 : posi+10])
        print "HEALTH: " + str(actor) + " - " + str(health) + "hp"


    # Set spawn location to arbitrary location
    if len(p_out) == 22 and p_out[2:4] == "\x00\x00" and p_out[16:] == "\x00\x00\x00\x00\x00\x00":

        # GreatBallsOfFire
        #x, y, z = -43655.0, -56210.625, 471.536132812

        # Meet the Famer
        #x, y, z = 21162.375, 41232.0, 2255.0703125

        # Meet MichaelAngelo
        #x, y, z = 260255.0, -249336.25, 1476.03515625

        # Go to Town
        #x, y, z = -39130.5,  -20279.3300781, 2528.47998047

        # Bear Chest bottom
        #x, y, z = -7894.0  64482.0, 2418.859375

        # Bear Chest top
        #x, y, z = -7894.0, 64482.0,  6112.8125

        # Ballmer Peak Poster
        #x, y, z = -6101.0, -10956.0, 24419.25

        # Balmer Egg
        #x, y, z = -2778.0, -11035.0, 11480.5625

        # Lava Cave
        #x, y, z = 50876.0, -5243.0, 1645.0703125

        # Blocky Cave
        #x, y, z = -18450.0, -4360.0, 2225.0

        #p_out = newspawn(p_out[:2], x, y, z)

        pass


    # Create a chest in town
    if chat("CreateChest") in p_out:
        x, y, z = -39602.8, -18288.0, 2400.28
        p_in += createel(1337, "BearChest", x, y, z)


    # Print "Much skills" and "Such hacker!" on the screen
    if chat("Banner") in p_out:
        p_in += event("Much skills", "Such hacker!")


    # Add new item in inventory (locally)
    if chat("GetLoot") in p_out:
        p_in += more("BearSkin", 100)
        p_in += more("Coin", 100)
        p_in += more("CowboyCoder", 1)
        p_in += more("ZeroCool", 1)


    # Get the Great Balls of Fire
    if chat("gbof") in p_out:
        p_out += loc(-43655.0, -55820.0, 322.0)
        p_out += getme(1)


    # Unlock bear chest
    if chat("unlock") in p_out:
        p_out += loc(3321278464, 1199301120, 1160980583)
        p_out += getme(3)


    # Activate the "Until the Cows Come Home" quest
    if chat("cow") in p_out:
        p_out += loc(1185440256-200000, 1193349120, 1157976064+500000)
        p_out += getme(9)
        p_out += dialog("Quest")
        p_out += dialog("$END")


    # Pick up Eggs
    if chat("egg1") in p_out:
        p_out += loc(-25045.0, 18085.0, 260.0)
        p_out += getme(11)
    if chat("egg2") in p_out:
        p_out += loc(-51570.0, -61215.0, 5020.0)
        p_out += getme(12)
    if chat("egg3") in p_out:
        p_out += loc(24512.0, 69682.0, 2659.0)
        p_out += getme(13)
    if chat("egg4") in p_out:
        p_out += loc(60453.0, -17409.0, 2939.0)
        p_out += getme(14)
    if chat("egg5") in p_out:
        p_out += loc(1522.0, 14966.0, 7022.0)
        p_out += getme(15)
    if chat("egg6") in p_out:
        p_out += loc(11604.0, -13130.9023438, 411.0)
        p_out += getme(16)
    if chat("egg7") in p_out:
        p_out += loc(-72667.0, -53567.0, 1645.0)
        p_out += getme(17)
    if chat("egg8") in p_out:
        p_out += loc(48404.0, 28117.0, 704.0)
        p_out += getme(18)
    if chat("egg9") in p_out:
        p_out += loc(65225.0, -5740.0, 4928.0)
        p_out += getme(19)
    if chat("BallmerPeakEgg") in p_out:
        p_out += loc(-2778.0, -11035.0, 10504.0)
        p_out += getme(20)



    return (p_in, p_out, p_next)



# ------------------------------------------------
# ------------------------------------------------


class FixedDispatcher(asyncore.dispatcher):
    """https://docs.python.org/2/library/asyncore.html#asyncore.dispatcher"""

    def handle_error(self):
        print "What happened?"
        raise




class Sock(FixedDispatcher):

    write_buffer = ''


    def readable(self):
        return not self.other.write_buffer


    def handle_read(self):
        self.other.write_buffer += self.recv(4096*4)


    def handle_write(self):
        if self.write_buffer:
            (p_in, p_out, p_next)  = parse(self.write_buffer)
            self.other.write_buffer += p_in
            sent = self.send(p_out)
            self.write_buffer = self.write_buffer[sent:]
            self.write_buffer = p_next


    def handle_close(self):
        print ' [-] %i -> %i (closed)' % \
                     (self.getsockname()[1], self.getpeername()[1])
        self.close()
        if self.other.other:
            self.other.close()
            self.other = None




class ProxServer(FixedDispatcher):

    def __init__(self, src_port, dst_host, dst_port):
        self.src_port = src_port
        self.dst_host = dst_host
        self.dst_port = dst_port
        self.client = None
        self.server = None
        asyncore.dispatcher.__init__(self)
        self.create_socket(socket.AF_INET, socket.SOCK_STREAM)
        self.set_reuse_addr()
        self.bind(('0.0.0.0', src_port))
        print ' [*] Listening on port %i' % src_port
        self.listen(5)


    def handle_accept(self):
        pair = self.accept()
        if not pair:
            return
        left, addr = pair
        try:
            right = socket.create_connection((self.dst_host, self.dst_port))
        except socket.error, e:
            if e.errno is not errno.ECONNREFUSED: raise
            print ' [!] Connection refused (%s:%i)' % \
                  (self.dst_host, self.dst_port)
            left.close()
        else:
            print ' [+] %i:%i > %i:%i' % \
                  (addr[1], self.src_port,
                  right.getsockname()[1], self.dst_port)

            self.client = Sock(left)
            self.server = Sock(right)

            self.client.other = self.server
            self.server.other = self.client


    def close(self):
        print ' [*] Closed %i ==> %i' % \
                     (self.src_port, self.dst_port)
        self.client.close()
        self.server.close()
        asyncore.dispatcher.close(self)




if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Custom asynchronous proxy for Pwn Adventure 3')
    parser.add_argument('-h', "--host", required=True, help='Pwn Adventure 3 master server IP/hostname')
    args = parser.parse_args()

    while True:

        master = ProxServer(3333, args.host, 3333)
        game = ProxServer(3000, args.host, 3000)
        game2 = ProxServer(3001, args.host, 3001)
        print "Proxy ready..."

        try:
            asyncore.loop()
        except Exception as e:
            print e

        master.close()
        game.close()
        game2.close()

        time.sleep(0.5)
