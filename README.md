# SpecNext_MiSTER_Board
(Not Working) An extension board to provide Spectrum Next functionality to MiSTER

This is my attempt to add components to MiSTER to allow better compatibility with the Spectrum Next core.

It adds
* SRAM - up to 2 MB as per the next using IS61WV20488BLL-10TI as of V2.0 (4 x as7c34096a-10 for V1.0)
* VGA out (using same resistor values from Next schematic)
* Mic/Ear port
* Audio out
* Two DB9 joystick ports
* NMI/Drive/Reset buttons
* J13 header to add physical SD Card support

Board V2.0 (Eagle files V8)
* Changed design to use a single 2mb SRAM chip to reduce trace count
* Manually routed board to ensure SRAM traces are a short as possible and use fewest vias
* STATUS - Awaiting board fabrication

Changelog

Board V1.0 (Eagle files V3)

While the board works to a degree, the SRAM is not stable at the speeds required (assumption is that trying to cram so much onto a small board has compromised track length/vias and/or created noise/capacitance issues).

The core runs fine if forced down to 7mhz.  It mostly runs ok at 14mhz apart from DMA operations which cause corrupt data.  28mhz won't boot.

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/M-N-SRAM-V3_Bare_Board.jpg)

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/M-N-SRAM-V3_Board_Top.jpg)

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/M-N-SRAM-V3_Board_Bottom.jpg)

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/M-N-SRAM-V3_Board_Attached.jpg)

![alt text](https://github.com/dave18/SpecNext_MiSTER_Board/blob/main/M-N-SRAM-V3_Board_Fully_populated.jpg)
