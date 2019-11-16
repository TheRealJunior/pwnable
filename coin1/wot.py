#!/usr/bin/env python3

from math import floor
import socket
# from logzero import logger

class WhereDaBitch:
    def __init__(self, n, c, on_complete_handler):
        self.lower_bound = 0
        self.upper_bound = n - 1
        self.on_complete_handler = on_complete_handler
        self.chances = c

    def guess(self, handler):
        # logger.debug('lower_bound=%d, upper_bound=%d' % (self.lower_bound, self.upper_bound))
        bottom_search_beg = self.lower_bound
        bottom_search_end = self.lower_bound  + \
            floor((self.upper_bound - self.lower_bound) / 2)

        top_search_beg = bottom_search_end + 1
        top_search_end = self.upper_bound



        if bottom_search_beg == bottom_search_end and self.chances == 1:
            if handler(bottom_search_beg, bottom_search_end):
                self.on_complete_handler(bottom_search_beg)
            else:
                self.on_complete_handler(bottom_search_beg + 1)

            return True

        assert self.chances > 0, "ran out of chances"
        self.chances -= 1

        if handler(bottom_search_beg, bottom_search_end):
            self.upper_bound = bottom_search_end
        else:
            self.lower_bound = top_search_beg


        return False


class ClgSocket:
    def __init__(self):
        self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.s.connect(('localhost', 9007))
        self.s.recv(2000)
        # logger.debug('got hello from server')

        self.get_params()

    def socket_handler(self, lower_guess, upper_guess):
        # logger.info('got lower=%d, upper=%d' % (lower_guess,upper_guess))
        guess_string = ''
        for i in range(lower_guess, upper_guess + 1):
            guess_string += str(i)
            guess_string += ' '

        guess_string += '\n'

        self.s.sendall(bytes(guess_string, 'utf-8'))
        scale_res = self.s.recv(10)
        has_fake = (int(scale_res, 10) % 10) != 0

        # logger.debug('has_fake -> %d' % has_fake)
        return has_fake

    def on_complete(self, res):
        # logger.debug('result=%d' % res)
        self.s.sendall(bytes(str(res), 'utf-8') + b'\n')

        resp_from_serv = self.s.recv(40)
        print(resp_from_serv)

        assert b'Correct' in resp_from_serv
        self.get_params()

    def get_params(self):
        p_line = self.s.recv(30)
        # logger.debug('got %s' % p_line)
        
        self.num_coins = int(p_line.split(b'N=')[1].split(b' ')[0])
        self.chances = int(p_line.split(b'C=')[1].strip(), 10)
        # logger.info('parsed self.num_coins=%d' % self.num_coins)


sock = ClgSocket()
wdb = WhereDaBitch(sock.num_coins, sock.chances, sock.on_complete)

for i in range(0, 100):
    while not wdb.guess(sock.socket_handler):
        pass

    wdb = WhereDaBitch(sock.num_coins, sock.chances, sock.on_complete)

# logger.debug(sock.s.recv(1024))
print(sock.s.recv(1024))