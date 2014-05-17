##salt-shared - useful Salt states

This is a collection of saltstates as a result of me learning how to use saltstack.
Both quality and style differ from state to state, some are quite up2date, others dont.
It is already in a useful state if you target ubuntu 14.04, but it completely lacks documentation.

###What can you do with it:

 * Target Platform: Ubuntu 14.04
   * many states also work with older ubuntu and other debian based distros.
   * some states may work with other linux distros
 * Windows Platform: there is some support for windows and windows packages (using chocolatey as pkg manager)

 * Features to look at:
   * roles.imgbuilder:
     * use packer on qemu/kvm and vagrant on libvirt/kvm to setup virtual machines from scratch on a KVM enabled kernel
     * deploy these easy to setup vagrant machines as production machines and control them via saltstack
   * roles.desktop:
     * everything needed from a desktop base installation for developing (ubuntu 14.04)
     * look at roles/desktop/readme.md for details

###How to start:

 * look at salt-top.example and pillar-top.example for a start

 * without a saltmaster:
   * fork/download salt-setup-template and look there for more info

 * with a saltmaster:
   * include this repository as a salt directory and point salt master config to it


###directory layout:

 * /salt-top.example: Example states top file
 * /pillar-top.example: Example pillar data

 * /.*      : Low level salt states
 * /roles/* : High level salt states
 * /roles/desktop/*
            : High level salt states used for desktop setups 

 * /repo/*  : distribution specific repository setup
 * /win/*   : Windows specific salt states



###Todo:
 * add partner and extra repositories (also needed for skype)
 * make pillar state install skype
 * add supported languages packages install (one click at languages)
 * apt-get install exfat-fuse exfat-utils
