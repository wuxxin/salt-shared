#!/usr/bin/perl

use strict;
use warnings;

use EBox;
use EBox::Global;

EBox::init();

my $sambamodule = EBox::Global->modInstance('samba');

foreach my $user (@{$sambamodule->realUsers()}) {
    my $uid;
    my $sam;
    my $firstname;
    my $lastname;
    $uid = $user->get('uidNumber');
    $sam = $user->get('samAccountName');
    $firstname = $user->get('givenName');
    $lastname = $user->get('sn');
    say "$sam";
}


1;
