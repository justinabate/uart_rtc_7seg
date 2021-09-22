# uart_rtc_7seg
Implements UART receiver, [ZipCPU Real Time Clock](https://github.com/ZipCPU/rtcclock/blob/master/rtl/rtcbare.v), and 7-segment driver on [iCEstick](https://www.latticesemi.com/icestick) (iCE40-1KHX)<br/>

## Dependencies
[Lattice iCEcube2](https://www.latticesemi.com/iCEcube2)<br/>
[YosysHQ icestorm](https://github.com/YosysHQ/icestorm)<br/>
```make```<br/>

## Usage
(1) Wire icestick outputs to the 7-segment display as noted in the [pin constraints](https://github.com/justinabate/uart_rtc_7seg/blob/main/phys/icestick_pin_constraints.pcf).<br/>
(2) Adjust the starting lines of the makefile for the path of your iCEcube2 installation<br/>
(3) ```git clone https://github.com/justinabate/uart_rtc_7seg.git```<br/>
(4) ```cd ice_flow; make fpga``` (synthesize, implement, and program), or ```make help``` for an individual process<br/>
(5) Place a [USB-UART 3.3V adapter](https://www.amazon.com/gp/product/B00IJXZQ7C) at the Pmod header. Ensure the TxD pin of the adapter connects to pin 10 of the Pmod header (highlighted blue in the capture below). <br/>
<p align="center"><img src="https://user-images.githubusercontent.com/18313961/134378601-07e87138-584e-4be9-9b36-e35603c3192f.png?raw=true" alt="Pmod pin 10"/></p>
(6) Open a serial session with the USB-UART adapter. <br/>
(7) Enter current time in the format HHMMSS (for example, 7:30PM = 193000).  <br/> 
(8) 7-segment display updates with the value of MMSS. <br/> 

## Remarks 
Couldn't get on-board FTDI UART to work as in "IrDA Functionality and Demo" of icestick user's guide