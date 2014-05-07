#shared-salt - useful Salt states

This is a collection of saltstates as a result of me learning to use saltstack.
It is already in a useful state if you target ubuntu 14.04, but it completely lacks documentation.

##What can you do with it:

 * Target Platform: Ubuntu 14.04
   * many states also work with older ubuntu and other debian based distros.
   * some states may work with other linux distros
 * Windows Platform: there is some support for windows and windows packages (using chocolatey as pkg manager)

 * documented Features:
   * imgbuilder: use packer on qemu/kvm and vagrant on libvirt/kvm to setup virtual machines from scratch on a KVM enabled kernel
   * developer desktop setup: look at roles/desktop/readme.md for details

##How to start:

 * look at salt-top.example and pillar-top.example for a start

 * without a saltmaster:
   * fork/download salt-setup-template and look there for more info

 * with a saltmaster:
   * include this repository as a salt directory and point salt master config to it


##directory layout:

 * /salt-top.example: Example states top file
 * /pillar-top.example: Example pillar data

 * /.*      : Low level salt states
 * /roles/* : High level salt states
 * /roles/desktop/*
            : High level salt states used for desktop setups 

 * /repo/*  : distribution specific repository setup
 * /win/*   : Windows specific salt states


