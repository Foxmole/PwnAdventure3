# -*- coding: utf-8 -*-
"""
Name: BinPatcher.py
Version: v1.0.0 (23/06/2017)
Date: 23/06/2017
Created By: Antonin Beaujeant
Description: BinPatcher is a Python script that allows you to patch a binary (one instruction only) at a given offset. More info: https://blog.keyidentity.com/2017/07/18/pwnadventure3-patching-binary/

Example:
    $ python binpatcher.py -f libGameLogic.so -o 0x15ea64 -m 64 -i "movabs rax, 0x9"
"""

import argparse
import sys, os
from capstone import *
from keystone import *


def get_first_instruction_size( binary, offset ):
    """Get the data size of the first instruction of a given binary.

    Retrieve the all the assembly instructions for a given binary blob (maximum)
    64 bytes thanks to the Capstone framework. Takes the first instruction and
    calculate the data size of it.
    The size is important since we need to know if we have enough place to
    overwrite the initial instruction with the new one(s).

    Args:
        binary: The binary to patch.
        offset: The offset where the instruction to replace is located.

    Returns:
        The data size (int) of the first instruction located at the given offset.
    """

    cpt = 0
    size = 0

    md = Cs( cs_arch, cs_mode )

    # The longest instruction in x64 is 64 bytes
    # We therefore need to take at least 64 bytes
    # in order to find the size of the selected
    # instruction

    if args.verbose:
        print ( "#######################"   )
        print ( "#    ASSEMBLY CODE    #"   )
        print ( "#######################\n" )

    for i in md.disasm( binary[ offset : offset+64 ], offset ):

        if not cpt:
            if args.verbose:
                print( "> 0x%x:\t%s\t%s\t" % (i.address, i.mnemonic, i.op_str) )
            size = len(i.bytes)
        else:
            if args.verbose:
                print( "  0x%x:\t%s\t%s" % (i.address, i.mnemonic, i.op_str) )
            pass

        cpt += 1

    return size




def assemble( binins ):
    """Assemble instruction in binary format.

    Assemble the given instruction(s) in assembly format to a binary format thanks
    to the Keystone framework.

    Args:
        binins: Instruction in assembly format.

    Returns:
        The assembled (bin) instruction(s).
    """

    if args.verbose:
        print ( "\n#######################"   )
        print (   "#   NEW INSTRUCTION   #"   )
        print (   "#######################\n" )

    try:
        ks = Ks( ks_arch, ks_mode )
        encoding, count = ks.asm( binins )
        if args.verbose:
            print( "%s = %s" % (binins, encoding) )
            print( "Size: %i" % len( encoding ) )
    except KsError as e:
        print( "ERROR: %s" % e )

    return encoding




def main( fpath, offset, mode, ins ):
    """Patch a binary file with a given set of instruction(s)

    Replacing one instruction at a given offset by one or several instruction.

    Args:
        fpath: Path the binary to patch
        offset: Offset where the instruction to replace is located
        mode: 32bit or 64bit
        ins: Instruction to replace with

    Returns:
        Save the patched binary. Return nothing.
    """

    with open( fpath, 'rb' ) as f:
        binary = f.read()

    size = get_first_instruction_size( binary, offset )

    if args.verbose:
        print ( "\nSize: %i" % (size) )

    if size:

        binins = assemble( ins )

        if len( binins ) <= size:

            if args.verbose:
                print ( "Enough space to fit the new instruction\n" )

            # Padding with NOPs
            binins = binins + [0x90]*( size - len(binins) )
            # Overwritting the instruction
            binary = binary[ : offset ] + ''.join( chr(c) for c in binins ) + binary[ offset+size : ]

            # Saving the new patched file
            if args.verbose:
                print ( "Saving the patched file: %s" % (fpath + "_patched") )

            with open( fpath + "_patched", 'wb' ) as f:
                f.write( binary )

        else:
            print( "ERROR: Not enough space to fit the new instruction" )

    else:
        print( "ERROR: Couln't find instructions" )




if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Patch a binary (one instruction only) at a given offset')
    parser.add_argument('-f', "--file",         required=True,              help='binary file to patch')
    parser.add_argument('-o', '--offset',       required=True,              help='the offset where the instruction to overwrite is located (e.g. 0x15ea64)')
    parser.add_argument('-m', '--mode',         required=True, type=int,    help='processor mode: 32,64')
    parser.add_argument('-i', '--instruction',  required=True,              help='the new instruction to write')
    parser.add_argument('-v', "--verbose",      help='debug mode',          action="store_true")
    args = parser.parse_args()

    if not os.path.isfile( args.file ):
        print( "ERROR: The file does not exist" )
        sys.exit()

    if args.offset[:2] == "0x":
        offset = int( args.offset, 16 )
    else:
        print( "ERROR: Offset value should be hexadecimal, e.g. 0x1234" )
        sys.exit()

    if args.mode != 32 and  args.mode != 64:
        print( "ERROR: Mode should be either 32 or 64" )
        sys.exit()

    if args.mode == 64:
        cs_mode = CS_MODE_64
        cs_arch = CS_ARCH_X86
        ks_mode = KS_MODE_64
        ks_arch = KS_ARCH_X86
    else:
        cs_mode = CS_MODE_32
        cs_arch = CS_ARCH_X86
        ks_mode = KS_MODE_32
        ks_arch = KS_ARCH_X86

    main( args.file, offset, int( args.mode ), args.instruction )
