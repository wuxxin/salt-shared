#!/usr/bin/perl

use strict;
use warnings;

use EBox;
use EBox::Users::User;

EBox::init();

my $parent = EBox::Users::User->defaultContainer();

open (my $USERS, '<-');

while (my $line = <$USERS>) {
    chomp ($line);
    my ($username, $givenname, $surname, $password) = split(',', $line);
    EBox::Users::User->create(
        uid => $username,
        parent => $parent,
        givenname => $givenname,
        surname => $surname,
        password => $password
    );
}
close ($USERS);

1;
