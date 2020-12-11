#!/bin/sh

_step_counter=0
step() {
	_step_counter=$(( _step_counter + 1 ))
	printf '\n\033[1;36m%d) %s\033[0m\n' $_step_counter "$@" >&2  # bold cyan
}


step 'Set up timezone'
setup-timezone -z Europe/Moscow

step 'Set up networking'
cat > /etc/network/interfaces <<-EOF
	iface lo inet loopback
	iface eth0 inet dhcp
EOF
ln -s networking /etc/init.d/net.lo
ln -s networking /etc/init.d/net.eth0

step 'Adjust rc.conf'
sed -Ei \
	-e 's/^[# ](rc_depend_strict)=.*/\1=NO/' \
	-e 's/^[# ](rc_logger)=.*/\1=YES/' \
	-e 's/^[# ](unicode)=.*/\1=YES/' \
	/etc/rc.conf

step 'Enable services'
rc-update add acpid default
rc-update add chronyd default
rc-update add crond default
rc-update add net.eth0 default
rc-update add net.lo boot
rc-update add termencoding boot

setup-cloud-init
rc-update add cloud-init default

rc-update add qemu-guest-agent default

rc-update add sshd default

echo "UsePAM yes" >> /etc/ssh/sshd_config

#adduser -D alpine -G wheel
#sed -i 's/alpine:!/alpine:*/g' /etc/shadow
#sed -i '/PermitRootLogin yes/d' /etc/ssh/sshd_config

rm -f /var/cache/apk/*

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
sync
sync
sync
