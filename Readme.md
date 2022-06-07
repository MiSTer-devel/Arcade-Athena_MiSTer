# SNK Athena (Beta):
Follow any core updates and news on my Twitter acount [@RndMnkIII](https://twitter.com/RndMnkIII). this project is a hobby but it requires investing in arcade game boards and specific tools, so any donation is welcome: [https://ko-fi.com/rndmnkiii](https://ko-fi.com/rndmnkiii).

## About
This core as beta release will be published as independet core. Finally will be unified with the SNK Triple Z80 Core. For a list of games intended to work with the SNK Triple Z80 Core see:
[https://github.com/mamedev/mame/blob/master/src/mame/drivers/snk.cpp](https://github.com/mamedev/mame/blob/master/src/mame/drivers/snk.cpp).  

## Third party cores
* Daniel Wallner T80 core [jesus@opencores.org](https://opencores.org/projects/t80).
* JTOPL FPGA Clone of Yamaha OPL hardware by Jose Tejada, @topapate [(https://github.com/jotego/jtopl)](https://github.com/jotego/jtopl).
* Based on Tim Rudy 7400 TTL library [https://github.com/TimRudy/ice-chips-verilog](https://github.com/TimRudy/ice-chips-verilog).

## Instructions:
This game is multiplayer, where two players can play taking turns with their own controllers. You have two action buttons for jump and attack and the 8-way joystick. As in the rest of the SNK Triple Z80 cores you have buttons for service and pause.

## Manual installation
Rename the Arcade-Athena_XXXXXXXX.rbf file to Athena_XXXXXXXX.rbf and copy to the SD Card to the folder  /media/fat/_Arcade/cores and the .MRA files to /media/fat/_Arcade.

The required ROM files follow the MAME naming conventions (check inside MRA for this). Is the user responsability to be installed in the following folder:
/media/fat/_Arcade/mame/<mame rom>.zip

## Acknowledgments
* __@caiusarcade__ for their assistance in using files and converting PLD files.
* __@topapate__ for general advice with the JTOPL core.
* __@FCochise__ for helping with the rom settings of MRA files.
* __@alanswx__ for helping me with some technical aspects related to the use of the MiSTer framework.
* Ko-fi supporters: @bdlou, Matteo
* And all those who with their comments and shows of support have encouraged me to continue with this project.


