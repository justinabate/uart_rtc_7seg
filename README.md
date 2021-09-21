# uart_rtc_7seg
- Implements UART receiver and 7-segment driver on [iCEstick](https://www.latticesemi.com/icestick) (iCE40-HX1K)<br/>

## Dependencies
[Lattice iCEcube2](https://www.latticesemi.com/iCEcube2)<br/>
[YosysHQ icestorm](https://github.com/YosysHQ/icestorm)<br/>
```make```<br/>

## Usage
(1) Adjust the starting lines of the makefile for the path of your iCEcube2 installation<br/>
(2) ```git clone https://github.com/justinabate/uart_rtc_7seg.git```<br/>
(3) ```cd ice_flow; make fpga``` (synthesize, implement, and program), or ```make help``` for an individual process

## Remarks 
Couldn't get on-board FTDI UART to work as in "IrDA Functionality and Demo" of icestick user's guide