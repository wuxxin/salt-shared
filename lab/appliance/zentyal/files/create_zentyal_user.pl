#!/usr/bin/perl

use strict;
use warnings;

use EBox;
use EBox::Samba::User;

EBox::init();

my $parent = EBox::Samba::User->defaultContainer();

open (my $USERS, '<-');

while (my $line = <$USERS>) {
    chomp ($line);
    my ($username, $givenname, $surname, $password) = split(',', $line);
    EBox::Samba::User->create(
        samAccountName => $username,
        parent => $parent,
        givenName => $givenname,
        sn => $surname,
        password => $password
    );
}
close ($USERS);

1;
