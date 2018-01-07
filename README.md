# iLOreset

Reset the password on a DL360 and similar iLO account and set networking to DHCP

## Why

I wrote this up because I get a lot of decommissioned machines that
don't come with the iLO password available, or with a hardcoded IP
that isn't appropriate for the network it is on- i.e. a production
IP when the iLO is now on the CORP network.

This simple script uses the well documented hponcfg tool to set the
password of an existing user (preferably an administrator) and then
set the iLO network interface into DHCP mode.

## How is this possible

This is _not_ a "hack" or an "exploit". HP assumes that if you have root
privileges on the operating system, it is appropriate that you should
be able to reconfigure the iLO. I don't necessarily disagree.

## What will this work on

This was tested on a DL360 G7 and a DL360 G8. It might work on DL380 as
well as other generations of DL360. It must be at least an HP ProLiant.

## How does it work

There is a device driver that exposes a device file to the Linux OS. This
device file, when opened by root, can be issued ioctl() commands to do things
like read and write the configuration of the iLO board. It is relatively simple.
HP wrote the tool, presumably using their own documentation. There is no need
to do anything silly like reverse or study their `ioctl` command set.

## Errors you might encounter

Error about invalid user - make sure you specified an existing user as
this script does not create a new user, it only resets the password of
an existing one. It will be kind and enumerate the users for you though.

Error about permission - make sure you are root

Error about libraries not found or SELinux enforcing things - this means
you somehow unset the LD_LIBRARY_PATH, which I set in the script. Please
don't muck with that, or copy the library files to /lib64.

Any other errors are probably all your fault, and if you can't solve them,
you shouldn't be using this tool.

## Final warning(s)

DO NOT USE THIS ON PRODUCTION SYSTEMS OR SYSTEMS YOU DO NOT OWN AND EXPECT ME TO SAVE YOU !!

RESETTING THE PASSWORD WILL EFFECTIVELY LOCK THE ADMINISTRATOR OUT !!

SETTING DHCP MODE WILL ESSENTIALLY MAKE THE iLO DISAPPEAR TO THE ADMINISTRATOR !!
