# Stiebel-Eltron heat pump monitor and control
For WPM, WPM2 and compatible devices. Note - WPM3 does not have optical port anymore. Connection directly to the CAN bus is required, which is not supported in this project.
Connects to WPM2 (and compatible) control unit over optical interface and COM port to the computer.
Windows 32-bit executable. Runs on every machine from XP to Win 11.

## Infrared cable
Short instructions how to build the cable is in the folder "IR_cable_documentation".

## Communication protocol
There was a lot of research done by different people. They mostly focused on connecting directly to the CAN bus that links together all the components of the heat pump. I didn't want to be that intrusive. Optical port allows for all functions that are required without any fear of interference.

Short summary of the protocol can be found in the folder "IR_cable_documentation".

Further details (on CAN bus which is very similar) are collected in the folder "Protocol_documentation". Note - this is just a dump of all internet resources on this topic.

All registers used in this project are either collected by sniffing the traffic of the ComfortSoft software or by experimentation. Some registers may not be completely accurate, especially the binary signals (pumps) are experimental.

If somebody would like to obtain the original ComfortSoft package, I have a local copy. Note this is from the Win XP era and requires caution and special tricks during installation on a recent Win 10/11 machine. But it works.

## Screenshot
![Screenshot](/Screenshots/HP_WPM2_readout_2.PNG)
