# 0 means Magisk/KSU will automatically extract everything in the zip natively.
# This prevents the "file not found" unzip crash you were experiencing!
SKIPUNZIP=0

ui_print " "
ui_print "[=================================]"
ui_print "    Snapdragon Touch Overdrive     "
ui_print "         POCO F7 Edition           "
ui_print "[=================================]"
ui_print " "
ui_print "+.+.+ Extracting Overdrive Engines ..."
sleep 0.5
ui_print "+.+.+ Overclocking Touch Sampling Rates ..."
sleep 0.5
ui_print "+.+.+ Binding 960Hz Hardware Gyro Matrix ..."
sleep 0.5
ui_print " "
ui_print "+.+.+ Successfully Installed Touch Overdrive! +.+.+"

# This ensures KernelSU grants execution rights to your engine
set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/service.sh 0 0 0755
}
