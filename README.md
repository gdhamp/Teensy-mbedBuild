# Test Project for Teensy with mbed
It is a USBAudio test program but the big thing in here is the Makefile which
allows an mbed project to be built using a locally installed mbed build

Everything below is relevent.

To use the JLink SWD connection modes need to be made to the Teensy to allow
the SWD to be connected. Look
[here](http://mcuoneclipse.com/2014/08/09/hacking-the-teensy-v3-1-for-swd-debugging).

## Build Tools (tested on Linux and OSX)

###Flashing the Board

The binary that runs on the board is HeadsUp.hex in this repo. To flash it to the board do the following

goto [https://www.segger.com/jlink-software.html](https://www.segger.com/jlink-software.html) and download the appropriate distro of the "Software and Documentation Pack"

Go to the repo directory and

In Linux

/opt/SEGGER/JLink/JLinkExe FlashCommands.jlink

In Windows

JLink.exe FlashCommands.jlink

This will connect to the board through SWD, erase the flash and program it with HeadsUp.hex


###gcc for arm

Download the appropriate platform of *gcc-arm-none-eabi-4_9-2015q1*
from https://launchpad.net/gcc-arm-embedded/4.9/4.9-2015-q1-update

expand it and install it in /opt

In Linux and OSX: expand it in ~/tmp then sudo mv ~/tmp/gcc-arm-none-eabi-4_9-2015q1 /opt 

### mbed
Get the mbed with the mods for HeadsUp by clone out repo

mkdir ~/tmp

cd ~/tmp

git clone https://github.com/gdhamp/mbed.git

sudo cp -rp mbed /opt/mbed

sudo cp -rp mbed /opt/mbed-debug


cd /opt/mbed

./build_rel.sh

cd /opt/mbed-debug

./build_debug.sh


### Debug Tools

goto [https://www.segger.com/jlink-software.html](https://www.segger.com/jlink-software.html) and download the appropriate distro of the "Software and Documentation Pack"

This should create */opt/SEGGER/JLink* which contains the program *JLinkGDBServer* which provides a gdb interface to the debugger.

To run this server, create a shell script (maybe store it in ~/bin):

```shell
#!/bin/bash
if [[ $OSTYPE = linux* ]]; then
	SEGGERPATH=/opt
elif [[ $OSTYPE = darwin* ]]; then
	SEGGERPATH=/Applications
fi
$SEGGERPATH/SEGGER/JLink/JLinkGDBServer -device MKL26Z128xxx4 -if swd -speed 1000
```

Run this script before starting a gdb client.

Use a gdb client to connect to it. I prefer DDD. The root dir of this repo  has a .gdbinit that works well and has a few macros ("mm" being the most useful as it resets the processor and reloads the binary)

Add the folowwing line to ~/.gdbinit:

*set auto-load safe-path /*

