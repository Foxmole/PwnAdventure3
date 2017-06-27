# -*- coding: utf-8 -*-
"""
Name: asyncproxy.py
Version: v1.0.0 (23/06/2017)
Date: 23/06/2017
Created By: Antonin Beaujeant
Description: AsyncProxy is a custom asynchronous proxy skeleton based on https://gist.github.com/majek/1662475. More info: https://blog.keyidentity.com/2017/06/27/pwnadventure3-asynchronous-proxy-in-python/

Example:
    $ python asyncproxy.py 192.168.1.10

"""

import argparse
import asyncore
import socket
import struct
import time
import re


def parse(p_out):

    """Contains all modifications to apply on the communication between the client and the server
    """

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

    parser = argparse.ArgumentParser(description='Asynchronous proxy')
    parser.add_argument('-h', "--host", required=True, help='Target server IP/hostname')
    args = parser.parse_args()

    while True:
        # Change port here
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
