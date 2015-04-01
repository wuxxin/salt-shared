#!/usr/bin/perl
# Copyright (C) 2014 Zentyal S.L.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

use strict;
use warnings;

use EBox;
use EBox::Global;

EBox::init();

my $global = EBox::Global->getInstance(1);
my $users = $global->modInstance('samba');

$users->_loadSchemas();

foreach my $user (@{$users->users()}) {
    my $username = $user->name();
    my @sids = split('-', $user->sid());
    my $sid = $sids[$#sids];
    my $uidNumber = $user->unixId($sid);
    $user->set('uidNumber', $uidNumber);
    $user->save();
    print "$username $sid $uidNumber\n";
}

my $prov = new EBox::Samba::Provision();
$prov->mapAccounts();
