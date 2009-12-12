KITA_TYPE="gnome"
DEPEND="ORBit2 libxml2 gtk+ polkit"
BUILD=""
config_src()
{
./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libexecdir=/usr/lib/GConf \
            --mandir=/usr/share/man #--disable-defaults-service
}
post_install()
{
mkdir -p /etc/gconf/gconf.xml.system/
}
""
