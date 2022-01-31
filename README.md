# SpecNext_MiSTER_Board
An extension board to provide Spectrum Next functionality to MiSTER

A MiSTer hat board MiSTER based on the offical schematics to (hopefully) allow better compatibility with the Spectrum Next core, including future updates.

It adds
* SRAM - up to 2 MB as per the next using 4 x as7c34096a-10 
* VGA out (using same resistor values from Next schematic)
* Mic/Ear port
* Audio out
* Two DB9 joystick ports
* NMI/Drive/Reset buttons
* J13 header to add physical SD Card support

Core code is based on the official MiSTer Spectrum Next Core with the following changes
* Direct VGA option - will bypass MiSTer framework and send direct video signal to VGA out (note - once this option is selected the OSD will no longer be visible over VGA until option is disabled (OSD is still visible through HDMI/DVI)
* Option to set each joystick to either MiSTer input or directly from the DSub 9 inputs
* Tape loading will automatically switch between virtual tape if loaded or from the Ear port if not
* SD Card interface will use virtual cards if loaded, else will use the J13 signals (useful if you have an Active Consult drive to plug in)

Changelog

Board V1.0 (Eagle files V3a)

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/M-N-SRAM-V3_Bare_Board.jpg)

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/M-N-SRAM-V3_Board_Top.jpg)

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/M-N-SRAM-V3_Board_Bottom.jpg)

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/M-N-SRAM-V3_Board_Fully_populated.jpg)

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/M-N-SRAM-V3_Board_Attached.jpg)


