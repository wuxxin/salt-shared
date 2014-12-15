# -*- coding: utf-8 -*-

import unittest
import struct
import salt.utils.network as nw
import salt.utils.validate.net as nw_validate


def __virtual__():
    return True

format_choice = ['net_addr', 'net_addr_mask', 'net_short', 'net_addr_cidr', 
    'net_broadcast', 'net_reverse', 'net_reverse_short', 
    'net_calc', 'interface_ip']


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


def net_interface_addr(combined):
    addr, netmask = _net_mask(combined)
    return addr
    

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


def start_and_mask_from_net(combined, prefix='', middle=': ', postfix=''):
    addr, netmask = _net_mask(combined)
    return prefix+ nw.get_net_start(addr, netmask)+ middle+ netmask


def netcidr_from_net(combined):
    addr, netmask = _net_mask(combined)
    return nw.calculate_subnet(addr, netmask)


def short_from_net(combined):
    addr, netmask = _net_mask(combined)
    addr_split = addr.split('.', 3)
    netmask_split = netmask.split('.', 3)
    return '.'.join([addr_split[a] for a in (0,1,2,3) if int(netmask_split[a]) != 0])


def reverse_from_net(combined, address_postfix= '.in-addr.arpa.', prefix_dot= False):
    addr, netmask = _net_mask(combined)
    addr_split_reverse = addr.split('.', 3)
    addr_split_reverse.reverse()
    r = '.' if prefix_dot else ''
    r = r+ '.'.join(addr_split_reverse)+ address_postfix
    return r


def short_reverse_from_net(combined, address_postfix= '.in-addr.arpa.', prefix_dot= False):
    addr, netmask = _net_mask(combined)
    addr_split_reverse = addr.split('.', 3)
    addr_split_reverse.reverse()
    netmask_split_reverse = netmask.split('.', 3)
    netmask_split_reverse.reverse()
    r = '.' if prefix_dot else ''
    r = r+ '.'.join([str(addr_split_reverse[a]) for a in (0,1,2,3) if int(netmask_split_reverse[a]) != 0])+ address_postfix
    return r


def size_from_net(combined):
    return 2 ** (32- int(cidr_from_net(combined)))


def calc_ip_from_net(combined, offset):
    # if positive: adds offset to first ip, if negative: subtracts from broadcast ip
    if offset < 0:
        start_addr = end_from_net(combined)
    else:
        start_addr = start_from_net(combined)

    return _32bit_to_ip(_ip_to_32bit(start_addr)+ offset)


def net_list(format, interface_list, interfaces, kwargs={}):
    if format not in format_choice:
        raise TypeError('not a valid format choice (not one of {0}): {1}'.format(format_choice, format))
    
    result = []

    for i in interface_list:
        if   format == 'net_addr':
            result.append(start_from_net(combine_net_mask(
                interfaces[i]['ipaddr'], interfaces[i]['netmask'])))
        elif format == 'net_addr_mask':
            result.append(start_and_mask_from_net(combine_net_mask(
                interfaces[i]['ipaddr'], interfaces[i]['netmask']), **kwargs))
        elif format == 'net_short':
            result.append(short_from_net(combine_net_mask(start_from_net(
                combine_net_mask(interfaces[i]['ipaddr'], interfaces[i]['netmask'])),
                interfaces[i]['netmask'])))
        elif format == 'net_addr_cidr':
            result.append(netcidr_from_net(combine_net_mask(
                interfaces[i]['ipaddr'], interfaces[i]['netmask'])))
        elif format == 'net_broadcast':
            result.append(end_from_net(combine_net_mask(
                interfaces[i]['ipaddr'], interfaces[i]['netmask'])))
        elif format == 'net_reverse':
            result.append(reverse_from_net(combine_net_mask(start_from_net(
                combine_net_mask(interfaces[i]['ipaddr'], interfaces[i]['netmask'])),
                interfaces[i]['netmask']), **kwargs))
        elif format == 'net_reverse_short':
            result.append(short_reverse_from_net(combine_net_mask(start_from_net(
                combine_net_mask(interfaces[i]['ipaddr'], interfaces[i]['netmask'])),
                interfaces[i]['netmask']), **kwargs))
        elif format == 'net_calc':
            result.append(calc_ip_from_net(combine_net_mask(start_from_net(
                combine_net_mask(interfaces[i]['ipaddr'], interfaces[i]['netmask'])),
                interfaces[i]['netmask']), **kwargs))
        elif format == 'interface_ip':
            result.append(net_interface_addr(combine_net_mask(
                interfaces[i]['ipaddr'], interfaces[i]['netmask'])))

    return result


class TestSequenceFunctions(unittest.TestCase):

  def test_single_functions(self):

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


  def test_list_function(self):

    interfaces= {'br0': {'ipaddr': '10.9.0.1', 'netmask': '255.255.255.0'},
        'virbr1': {'ipaddr': '10.10.0.1', 'netmask': '255.255.255.0'},
        'resbr0': {'ipaddr': '10.11.0.1', 'netmask': '255.255.255.0'},
        'hubr0':  {'ipaddr': '192.168.121.1', 'netmask': '255.255.255.0'},
        }

    interface_list= ['br0', 'virbr1', 'resbr0', 'hubr0']

    expected_result_list=[
['10.9.0.0', '10.10.0.0', '10.11.0.0', '192.168.121.0'],
['  10.9.0.0: 255.255.255.0', '  10.10.0.0: 255.255.255.0', '  10.11.0.0: 255.255.255.0', '  192.168.121.0: 255.255.255.0'],
['10.9.0', '10.10.0', '10.11.0', '192.168.121'],
['10.9.0.0/24', '10.10.0.0/24', '10.11.0.0/24', '192.168.121.0/24'],
['10.9.0.255', '10.10.0.255', '10.11.0.255', '192.168.121.255'],
['.0.0.9.10.in-addr.arpa', '.0.0.10.10.in-addr.arpa', '.0.0.11.10.in-addr.arpa', '.0.121.168.192.in-addr.arpa'],
['.0.9.10.in-addr.arpa', '.0.10.10.in-addr.arpa', '.0.11.10.in-addr.arpa', '.121.168.192.in-addr.arpa'],
['10.9.0.5', '10.10.0.5', '10.11.0.5', '192.168.121.5'],
['10.9.0.1', '10.10.0.1', '10.11.0.1', '192.168.121.1'],
]
    result_list=[]
    result_list.append(net_list('net_addr', interface_list, interfaces))
    result_list.append(net_list('net_addr_mask', interface_list, interfaces, kwargs={'prefix': '  '}))
    result_list.append(net_list('net_short', interface_list, interfaces))
    result_list.append(net_list('net_addr_cidr', interface_list, interfaces))
    result_list.append(net_list('net_broadcast', interface_list, interfaces))
    result_list.append(net_list('net_reverse', interface_list, interfaces, kwargs={'address_postfix': '.in-addr.arpa', 'prefix_dot': True}))
    result_list.append(net_list('net_reverse_short', interface_list, interfaces, kwargs={'address_postfix': '.in-addr.arpa', 'prefix_dot': True}))
    result_list.append(net_list('net_calc', interface_list, interfaces, kwargs={'offset': 5}))
    result_list.append(net_list('interface_ip', interface_list, interfaces))
    self.assertEqual(expected_result_list, result_list)

if __name__ == '__main__':
    unittest.main()

