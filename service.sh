#!/system/bin/sh
MODDIR=${0%/*}

# ---------------------------------------------------------
# KERNELSU NEXT LOGGING
# ---------------------------------------------------------
if [ "$KSU" = "true" ]; then
    echo "Snapdragon Touch Overdrive executed via KSU Next ($KSU_VER)" > /cache/ksu_touch_overdrive.log
else
    echo "Snapdragon Touch Overdrive executed via Standard Root" > /cache/ksu_touch_overdrive.log
fi

# Wait for the system boot sequence to parse vendor properties completely
while [ "$(getprop vendor.post_boot.parsed)" != "1" ]; do
    sleep 1s
done
sleep 5s

# ------------------------------------------------------------------------------
# 1. HARDWARE GYROSCOPE 960Hz RUNTIME FIX
# ------------------------------------------------------------------------------
TARGET_CONFIG="/odm/etc/sensors/config/sm8735_lsm6dsv_0.json"
MODIFIED_CONFIG="$MODDIR/sm8735_lsm6dsv_0.json"

if [ -f "$MODIFIED_CONFIG" ]; then
    chmod 644 "$MODIFIED_CONFIG"
    chown root:root "$MODIFIED_CONFIG"
    mount --bind "$MODIFIED_CONFIG" "$TARGET_CONFIG"
fi

# ------------------------------------------------------------------------------
# 2. CPU CORE & ADRENO GPU UNCHAINING
# ------------------------------------------------------------------------------
echo "0-7" > /dev/cpuset/top-app/cpus
echo "4-7" > /dev/cpuset/foreground/boost/cpus
echo "0-3,4-7" > /dev/cpuset/foreground/cpus

if [ -f /sys/module/adreno_idler/parameters/adreno_idler_active ]; then
    echo "0" > /sys/module/adreno_idler/parameters/adreno_idler_active
fi

# ------------------------------------------------------------------------------
# 3. KERNEL TOUCH BOOST 
# (Framework precision tweaks are natively handled by system.prop)
# ------------------------------------------------------------------------------
if [ -f /sys/module/msm_performance/parameters/touchboost ]; then
    echo '1' > /sys/module/msm_performance/parameters/touchboost
fi
if [ -f /sys/power/pnpmgr/touch_boost ]; then
    echo '1' > /sys/power/pnpmgr/touch_boost
fi

# ------------------------------------------------------------------------------
# 4. VIRTUAL MEMORY (VM) & CACHE OPTIMIZATION
# ------------------------------------------------------------------------------
echo '5' > /proc/sys/vm/swappiness
echo '80' > /proc/sys/vm/vfs_cache_pressure
echo '0' > /proc/sys/vm/extra_free_kbytes
echo '4096' > /proc/sys/vm/min_free_kbytes
echo '0' > /proc/sys/vm/oom_kill_allocating_task

for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    if [ -d "/sys/block/ram$i" ]; then
        echo '1024' > "/sys/block/ram$i/queue/read_ahead_kb"
    fi
done

if [ -d /sys/block/vnswap0 ]; then
    echo '1024' > /sys/block/vnswap0/queue/read_ahead_kb
fi

# ------------------------------------------------------------------------------
# 5. BACKGROUND CLEANUP
# ------------------------------------------------------------------------------
stop logd

exit 0
