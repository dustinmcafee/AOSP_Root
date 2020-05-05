### Install required packages
sudo apt-get install python2.7 brotli android-tools-fsutils

### Download and install Android image to ext4 img converter
wget https://raw.githubusercontent.com/xpirt/sdat2img/master/sdat2img.py
sudo chmod a+x ./sdat2img.py

### If the image is compressed, uncompress it (only if it has the '.br' file extension)
brotli -d system.new.dat.br
brotli -d vendor.new.dat.br

### Convert the Android image to raw EXT4 format
./sdat2img.py system.transfer.list system.new.dat system_raw.img
./sdat2img.py vendor.transfer.list vendor.new.dat vendor_raw.img

### Convert the raw image to a sparse image
img2simg system_raw.img system.img
img2simg vendor_raw.img vendor.img

### Flash the image to the Android device: 2.0 for Android 7.1.2, 3.0 for Android 8.1 using the corresponding flash script.
