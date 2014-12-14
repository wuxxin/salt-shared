# -*- coding: utf-8 -*-

import unittest
import struct
import salt.utils.network as nw
import salt.utils.validate.net as nw_validate


def __virtual__():
    return True


def _net_mask(combined):
    if "/" in combined:
        addr, netmask = combined.split('/', 1)
    else:
        addr, netmask = combined, "255.255.255.255"

    if not nw_validate.ipv4_addr(addr):
       raise TypeError('not a valid ipv4 address: {0}'.format(addr))
       addr = None
    else:
        if not nw_validate.netmask(netmask):
            netmask = nw.cidr_to_ipv4_netmask(netmask)
        if not nw_validate.netmask(netmask):
            raise TypeError('not a valid (neither 4x ".", nor CIDR) ipv4 netmask: {0}'.format(netmask))
            netmask = None

    return addr, netmask


def _ip_to_32bit(addr):
    addr_list = [int(n) for n in addr.split('.',3)]
    return struct.unpack('!I', struct.pack('!BBBB', *addr_list))[0]


def _32bit_to_ip(num):
    addr_list = struct.unpack('!BBBB', struct.pack('!I', num))
    return '.'.join([str(n) for n in addr_list])


def combine_net_mask(net, mask):
    addr, netmask = _net_mask(net + "/"+ mask)
    return addr+ "/"+ netmask


def cidr_from_net(combined):
    addr, netmask = _net_mask(combined)
    return str(nw.get_net_size(netmask))


def start_from_net(combined):
    addr, netmask = _net_mask(combined)
    return nw.get_net_start(addr, netmask)


def end_from_net(combined):
    # TODO: is hackish but works
    ipaddr_end = _ip_to_32bit(start_from_net(combined))+ size_from_net(combined) -1
    return _32bit_to_ip(ipaddr_end)


def netcidr_from_net(combined):
    addr, netmask = _net_mask(combined)
    return nw.calculate_subnet(addr, netmask)


def short_from_net(combined):
    addr, netmask = _net_mask(combined)
    addr_split = addr.split('.', 3)
    netmask_split = netmask.split('.', 3)
    return '.'.join([addr_split[a] for a in (0,1,2,3) if int(netmask_split[a]) != 0])


def reverse_from_net(combined):
    addr, netmask = _net_mask(combined)
    addr_split_reverse = addr.split('.', 3)
    addr_split_reverse.reverse()
    return '.'.join(addr_split_reverse)+ '.in-addr.arpa.'


def short_reverse_from_net(combined):
    addr, netmask = _net_mask(combined)
    addr_split_reverse = addr.split('.', 3)
    addr_split_reverse.reverse()
    netmask_split_reverse = netmask.split('.', 3)
    netmask_split_reverse.reverse()
    return '.'.join([addr_split_reverse[a] for a in (0,1,2,3) if int(netmask_split_reverse[a]) != 0])+ '.in-addr.arpa.'


def size_from_net(combined):
    return 2 ** (32- int(cidr_from_net(combined)))


def calc_ip_from_net(combined, offset):
    # if positive: adds offset to first ip, if negative: subtracts from broadcast ip
    if offset < 0:
        start_addr = end_from_net(combined)
    else:
        start_addr = start_from_net(combined)

    return _32bit_to_ip(_ip_to_32bit(start_addr)+ offset)


class TestSequenceFunctions(unittest.TestCase):

  def test_all(self):

    a = "10.9.0.0"
    b = "24"
    c = "255.255.255.0"
    d = combine_net_mask(a, b)
    e = combine_net_mask(a, c)

    self.assertEqual(d, '10.9.0.0/255.255.255.0')
    self.assertEqual(d, e)

    f = _ip_to_32bit(_net_mask(d)[0])
    g = _ip_to_32bit(_net_mask(e)[0])
    h = f +30
    i = g +30
    d_plus1 = combine_net_mask(_32bit_to_ip(h), b)
    e_plus1 = combine_net_mask(_32bit_to_ip(i), c)
    self.assertEqual(d_plus1, '10.9.0.30/255.255.255.0')
    self.assertEqual(d_plus1, e_plus1)

    f = cidr_from_net(d)
    g = cidr_from_net(e)
    self.assertEqual(f, '24')
    self.assertEqual(f, g)

    f = start_from_net(d_plus1)
    g = start_from_net(e_plus1)
    self.assertEqual(f, '10.9.0.0')
    self.assertEqual(f, g)

    f = end_from_net(d_plus1)
    g = end_from_net(e_plus1)
    self.assertEqual(f, '10.9.0.255')
    self.assertEqual(f, g)

    f = netcidr_from_net(d)
    g = netcidr_from_net(d_plus1)
    h = netcidr_from_net(e)
    i = netcidr_from_net(e_plus1)
    self.assertEqual(f, '10.9.0.0/24')
    self.assertTrue(f == g == h == i)

    f = short_from_net(d)
    g = short_from_net(e)
    h = short_from_net(d_plus1)
    i = short_from_net(e_plus1)
    self.assertEqual(f, '10.9.0')
    self.assertTrue(f == g == h == i)

    f = reverse_from_net(d)
    g = reverse_from_net(d_plus1)
    self.assertEqual(f, '0.0.9.10.in-addr.arpa.')
    self.assertEqual(g, '30.0.9.10.in-addr.arpa.')

    f = short_reverse_from_net(d)
    g = short_reverse_from_net(d_plus1)
    self.assertEqual(f, '0.9.10.in-addr.arpa.')
    self.assertEqual(f, '0.9.10.in-addr.arpa.')

    f = size_from_net(d)
    g = size_from_net(d_plus1)
    self.assertEqual(f, 256)
    self.assertEqual(f, g)

    f = combine_net_mask(calc_ip_from_net(d, 30), b)
    self.assertEqual(f, d_plus1)

    f = calc_ip_from_net(d, -1)
    self.assertEqual(f, '10.9.0.254')


if __name__ == '__main__':
    unittest.main()

