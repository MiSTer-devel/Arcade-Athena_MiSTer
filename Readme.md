# SNK Athena (Beta):
![SNK logo](/docs/snk_corp_logo.png)
![Game Flyer](/docs/Athena_flyer.png)
Athena, also known as Athena's Wonder Land, is a platform arcade game produced and published in 1986 by SNK.
Follow any core updates and news on my Twitter acount [@RndMnkIII](https://twitter.com/RndMnkIII). This project is a hobby but it requires investing in arcade game boards and specific tools, so **any donation is welcome: [https://ko-fi.com/rndmnkiii](https://ko-fi.com/rndmnkiii).**

## About
This core as beta release will be published as independet core. Finally will be unified with the SNK Triple Z80 Core. For a list of games intended to work with the SNK Triple Z80 Core see:
[https://github.com/mamedev/mame/blob/master/src/mame/drivers/snk.cpp](https://github.com/mamedev/mame/blob/master/src/mame/drivers/snk.cpp).  

## Third party cores
* Daniel Wallner T80 core [jesus@opencores.org](https://opencores.org/projects/t80).
* JTOPL FPGA Clone of Yamaha OPL hardware by Jose Tejada, @topapate [(https://github.com/jotego/jtopl)](https://github.com/jotego/jtopl).
* Based on Tim Rudy 7400 TTL library [https://github.com/TimRudy/ice-chips-verilog](https://github.com/TimRudy/ice-chips-verilog).

## Instructions:
Athena is multiplayer, where two players can play taking turns with their own controllers. You have two action buttons for jump and attack and the 8-way joystick. As in the rest of the SNK Triple Z80 cores you have buttons for service and pause. Recomended gamepad button assignments:
![gamepad buttons](/docs/Athena_btn_map.jpg)


For Country Club golf game, the trackball controls (one or up to two trackballs can be used simultaneously) are emulated using a gamepad with two analog sticks (tested with the Nintendo Switch Pro Controller with USB cable):
![analog controls](/docs/Country_Club_controls.png)

Apart from the standard MiSTer game controller support there is also there is SNAC support (for non-trackball) games for:
* DB15 arcade controls (tested with the Splitter for official MiSTer by Antonio Villena. See: https://www.antoniovillena.es/store/product/splitter-for-official-mister/).

## Flip Screen settings:
Athena does not include in the DIP settings an option to flip the screen (although it does include a Cocktail mode). Due to the fact that the default position of the screen in a screen appears inverted
Now you have two options to fix this:
* **Using the non-patched Athena MRA (Athena.MRA) with core hardware settings options:**
	* **For HDMI or/and VGA with scaler activated users (uses MiSTer framework support):** `Athena Core OSD options: other settings > Flip: Off, On`. Save settings and reload (not merely apply a reset) the Core.
	* **For CRT users (raw core video ouput without MiSTer framework support):** `Athena Core OSD options: HACKS (Only for Upright cabinet) > Core Screen Flip: Off, On`. Save settings.
	Note: you can have both video outputs active at the same time, then you could need to activate both depending on the characteristics of your screen.

* **Using the JunoMan's patched MRA (_alternatives/_Athena/Athena_Screen_Flip_Fix_ROM_Patch.mra):**
Simply load the core using said MRA file and do not touch any of the core OSD options related to flipping the screen or disable them if they were previously active. Important saving the settings after any change or reloading the core will not apply.

**Note:** Do not activate screen flip settings or patch in Cocktail mode as it will not be displayed correctly.

## Manual installation
Rename the Arcade-Athena_XXXXXXXX.rbf file to Athena_XXXXXXXX.rbf and copy to the SD Card to the folder  /media/fat/_Arcade/cores and the .MRA files to /media/fat/_Arcade.

The required ROM files follow the MAME naming conventions (check inside MRA for this). Is the user responsability to be installed in the following folder:
/media/fat/_Arcade/mame/<mame rom>.zip

## Acknowledgments
* To all Ko-fi contributors for supporting this project: __@bdlou__, __Peter Bray__, __Nat__, __Funkycochise__, __David__, __Kevin Coleman__, __Denymetanol__, __Schermobianco__, __TontonKaloun__, __Wark91__, __Dan__, __Beaps__, __Todd Gill__, __John Stringer__, __Moi__, __Olivier Krumm__, __Raymond Bielun__.
* __@caiusarcade__ for their assistance in using files and converting PLD files.
* __@topapate__ for general advice with the JTOPL core.
* __@FCochise__ for helping with the rom settings of MRA files.
* __@alanswx__ for helping me with some technical aspects related to the use of the MiSTer framework.
* And all those who with their comments and shows of support have encouraged me to continue with this project.


