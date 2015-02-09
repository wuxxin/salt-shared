#!/usr/bin/perl

# desk1~user~desk 1~sunshine~CN=non-staff,OU=Groups,DC=worthing,DC=futures~
use strict;
use warnings;

use EBox;
use EBox::Users::User;

EBox::init();

my $parent = EBox::Users::User->defaultContainer();

open (my $USERS, 'users.csv');

while (my $line = <$USERS>) {
    chomp ($line);
    my ($username, $givenname, $surname, $password, $grp) = split('~', $line);
    EBox::Users::User->create(
    uid => $username,
        parent => $parent,
        givenname => $givenname,
        surname => $surname,
        password => $password
    );
        my $group = new EBox::Users::Group(dn => $grp);
        $group->addMember(EBox::Users::User->new(uid => $username));

}

close ($USERS);

1;
