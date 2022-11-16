## Install CLORE.AI hosting

##### System requirements:
* Minimum 32 GB disk
* 4 GB RAM
* NVIDIA GPU (if multiple per system, they all need to be the same model)
* Ubuntu Server 22.04

##### Talk about the workloads:
On clore.ai marketplace users will be able to rent your system for various workloads, some workloads like 3D rendering or ai training will most of the time benefit from faster CPU and more RAM, it is not required by us, but if you will equip your system with more RAM and faster CPU you can ask higher price for it. Also you need to make sure that your system will be able to reach great stability, becouse unnecessary system downtime can cause issue to your customers.

### 1. Install Ubuntu Server 22.04 on your system
We also recommend to install openssh-server, so you can then connect to the system remotely

### 2. Install NVIDIA drivers
Now you need to install NVIDIA GPU drivers, so connect with ssh to your machine and run command

`ubuntu-drivers list`

Possible output:
```
nvidia-driver-515
nvidia-driver-510-server
nvidia-driver-390
nvidia-driver-520
nvidia-driver-515-server
nvidia-driver-470-server
nvidia-driver-470
nvidia-driver-510
nvidia-driver-450-server
nvidia-driver-418-server
```
You need to install latest non server driver, so with this output we will for example do
`sudo apt install nvidia-driver-520`

### 3. After finish, reboot machine
`sudo reboot`

### 4. Install clore.ai hosting server

We recommend to switch to root user to do this action
`sudo -i`
Then you can clone hosting repository and run the installer
```
git clone https://gitlab.com/cloreai-public/hosting
cd hosting
./install.sh
```
When everything goes smoothly you will be show INSTALLATION COMPLETE message any you will be prompted to run
`/opt/clore-hosting/clore.sh --init-token <token>`
you will get then token from clore.ai when you create server

### 5. Reboot
After you succesfully connect your machine to clore.ai, you will do one final reboot and the machine should appear in your dashboard as running, you can set the price for what you will rent the machine and change it's availability

##### Final note
Don't turn off your machine when it is rented, it is computing service for someone else, you yourself whould not be happy if you will be for example training some ai model on some remote server and it just went offline, so please if you want to turn off your machine to move it somewhere else or to make maintainance, please firstly set it's availability to not available in settings and wait until the machine will not be rented.
On the same note we recommend to enable power on on AC power loss in bios, so when the power will be down and then gets back up the system will automatically start up reducing downtime
