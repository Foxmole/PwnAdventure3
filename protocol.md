Pwn Adventure 3 - Network Protocol
==================================

General format
--------------

The first two bytes of each packet is an identifier number. Basically, it tells the server the format and the content of the packet. For instance, if the first two bytes are 0x6d 0x76, it’s the packet to update the character location.

All values are represented in little-endian.

Whenever the packet contains one or more values with variable length (e.g. the name of the item you have looted), the variable is delimited by its length, which is given just before the variable start.

Multiple packets can be concatenated. For instance, when shooting, it is possible to have the packet "Fire" concatenated with the packet "Update location" Or for instance multiple "New element" in one packet.


Authentication
--------------

This packet seems to authenticate the user to the Game server by sending its session id.

```
[II II] [?? ??] [LL LL] [WW WW ...]
```

* I:Identification number = 0x02 0x00 or 0x05 0x00
* ?: Unknown
* L: Length of the session id (typically 0x20)
* W: Session id


Spawn position
--------------

```
[II II] [?? ??] [XX XX XX XX] [YY YY YY YY] [ZZ ZZ ZZ ZZ] [RR RR] [YY YY] [PP PP]
```

* I: Identification number = 0x16 0x00 or 0x17 0x00 or 0x30 0x03 or 0x32 0x06 or 0x41 0x03
* ?: Unknown
* X: My position on the xaxis on the map
* Y: My position on the yaxis on the map
* Z: My position on the zaxis on the map
* R: The direction where I look on the rollaxis
* Y: The direction where I look on the yawaxis
* P: The direction where I look on the pitchaxis


Send message (#*)
-----------------

```
[II II] [LL LL] [WW WW ...]
```

* I: Identification number = 0x23 0x2a
* L: Length of the message
* W: Message


Fire (*i)
---------

```
[II II] [LL LL] [WW WW ...] [XX XX YY YY ZZ ZZ]
```

* I: Identification number = 0x2a 0x69
* L: Length of the weapon’s name
* W: Weapon’s name
* X,Y, Z: Data related to the direction where the weapon shoot

For instance, when I shoot with the Great Balls Of Fire, I have the following packet sent:

```
[2a 69] [10 00] [47 72 65 61 74 42 61 6c 6c 73 4f 66 46 69 72 65] [00 00 11 11 22 22]
```


Update health (++)
------------------

```
[II II] [NN NN NN NN] [HH HH HH HH]
```

* I: Identification number = 0x2b 0x2b
* N: Player or enemy identifier
* H: Current health level


Remove quest (^d)
-----------------

```
[II II] [LL LL] [WW WW ...]
```

* I: Identification number = 0x5e 0x64
* L: Length of the quest name
* W: Quest name


Change location (ch)
--------------------

```
[II II] [LL LL] [WW WW ...]
```

* I: Identification number = 0x63 0x68
* L: Length of the new location’s name
* W: Location’s name


New inventory item (cp)
-----------------------

```
[II II] [LL LL] [WW WW ...] [QQ QQ QQ QQ]
```

* I: Identification number = 0x63 0x70
* L: Length of the item name
* W: Item name
* Q: Quantity


Pick up item (ee)
-----------------

```
[II II] [NN NN NN NN]
```

* I: Identification number = 0x65 0x65
* N: Item identifier


Fast travel (ft)
----------------

```
[II II] [LL LL] [WW WW ...] [MM MM] [NN NN ...]
```

* I: Identification number = 0x66 0x74
* L: Length of the location name where the user is currently located
* W: Location name
* M: Length of the destination name
* N: Destination name


Jump (jp)
---------

```
[II II] [??]
```

* I: Identification number = 0x6a 0x70
* ?: Unknown (always = 0x00)


Update mana (ma)
----------------

```
[II II] [MM MM MM MM]
```

* I: Identification number = 0x6d 0x61
* M: Current mana level


New element (mk)
----------------

Element could be an enemy, an item, an attack or a NPJ.

```
[II II] [NN NN NN NN] [?? ?? ?? ?? ??] [LL LL] [WW WW ...] [XX XX XX XX] [YY YY YY YY] [ZZ ZZ ZZ ZZ] [RR RR] [YY YY] [PP PP] [?? ?? ?? ??] [00 00]
```

* I: Identification number = 0x6d 0x6b
* N: Element identifier
* ?: Unknown
* L: Length of the element’s name
* W: Element’s name
* X: Element position on the xaxis on the map
* Y: Element position on the yaxis on the map
* Z: Element position on the zaxis on the map
* R: Element orientation – roll
* Y: Element orientation – yaw
* P: Element orientation – pitch
* ?: Unknown


Update location (mv)
--------------------

```
[II II] [XX XX XX XX] [YY YY YY YY] [ZZ ZZ ZZ ZZ] [RR RR] [YY YY] [PP PP] [FF] [SS] [[ ?? ?? ]]
```

* I: Identification number = 0x6d 0x76
* X: My position on the xaxis on the map
* Y: My position on the yaxis on the map
* Z: My position on the zaxis on the map
* R: The direction where I look on the rollaxis
* Y: The direction where I look on the yawaxis
* P: The direction where I look on the pitchaxis
* F: The direction where I go (forward or backward)
* S: The direction where I strafe (left or right)
* [?]: Unknown value that appears whenever F = 0xc0 or 0x08


New quest (nq)
--------------

```
[II II] [LL LL] [WW WW ...]
```

* I: Identification number = 0x6e 0x71
* L: Length of the quest name
* W: Quest name


Enemy position (ps)
-------------------

```
[II II] [NN NN NN NN] [XX XX XX XX] [YY YY YY YY] [ZZ ZZ ZZ ZZ] [RR RR] [YY YY] [PP PP] [?? ?? ?? ?? ?? ??]
```

* I: Identification number = 0x70 0x73
* N: Enemy identifier
* X: Enemy position on the xaxis on the map
* Y: Enemy position on the yaxis on the map
* Z: Enemy position on the zaxis on the map
* R: Enemy orientation – roll
* Y: Enemy orientation – yaw
* P: Enemy orientation – pitch
* ?: Unknown


New achievement (pu)
--------------------

```
[II II] [LL LL] [WW WW ...]
```

* I: Identification number = 0x70 0x75
* L: Length of the achievement name
* W: Achievement name


Change PvP state (pv)
---------------------

```
[II II] [TT]
```

* I: Identification number = 0x70 0x76
* T: Toggle value (i.e. 0x01 = enable, 0x00 = disable)


Quest finished (q>)
-------------------

```
[II II] [LL LL] [WW WW ...] [MM MM] [QQ QQ ...]
```

* I: Identification number = 0x71 0x3e
* L: Length of the location
* W: Location name
* M: Length of the quest’s name
* Q: Quest name


Run (rn)
--------

```
[II II] [TT]
```

* I: Identification number = 0x6a 0x70
* T: Toggle value (i.e. 0x01 = run, 0x00 = walk)


Set current quest (q=)
----------------------

```
[II II] [LL LL] [QQ QQ ...]
```

* I: Identification number = 0x71 0x3d
* L: Length of the quest’s name
* Q: Quest name


Change player state (st)
------------------------

```
[II II] [NN NN NN NN] [LL LL] [WW WW ...]
```

* I: Identification number = 0x73 0x74
* N: Player or enemy identifier
* L: Length of the state’s name
* W: State’s name


Change attack state (tr)
------------------------

```
[II II] [NN NN NN NN] [LL LL] [WW WW ...] [TT TT]
```

* I: Identification number = 0x74 0x72
* N: Player or enemy identifier
* L: Length of the state’s name
* W: State’s name
* T: Target identifier


Remove element (xx)
-------------------

```
[II II] [NN NN NN NN]
```

* I: Identification number = 0x78 0x78
* N: Element identifier
* Missing packet


The list is not exhaustive, however, we have here all the information needed for the next blog posts. Feel free to reverse more packets. There are a few more related to PvP that I have not listed here for instance.
