# SpecNext_MiSTER_Board
(Not Working) An extension board to provide Spectrum Next functionality to MiSTER

This is my attempt to add components to MiSTER to allow better compatibility with the Spectrum Next core.

It adds
SRAM - up to 2 MB as per the next (using as7c34096a-10)
VGA out (using same resistor values from Next schematic)
Mic/Ear port
Audio out
Two DB9 joystick ports
NMI/Drive/Reset buttons
J13 header to add physical SD Card support

While the board works to a degree, the SRAM is not stable at the speeds required (assumption is that trying to cram so much onto a small board has compromised track length/vias and/or created noise/capacitance issues).

The core runs fine if forced down to 7mhz.  It mostly runs ok at 14mhz apart from DMA operations which cause corrupt data.  28mhz won't boot.

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/IMG_20210321_114441.jpg)

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/IMG_20210321_114337.jpg)

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/IMG_20210321_114353.jpg)

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/IMG_20210320_195406.jpg)

