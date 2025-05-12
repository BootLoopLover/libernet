#!/bin/bash

# Pastikan dijalankan sebagai root
if [ "$(id -u)" != "0" ]; then
  echo "Skrip ini harus dijalankan sebagai root."
  exit 1
fi

# Install bash & curl
opkg update && opkg install bash curl

# Jalankan installer Libernet resmi
bash -c "$(curl -fsSL 'https://raw.githubusercontent.com/BootLoopLover/libernet/main/install.sh')"

# Tambahkan menu Luci
cat <<'EOF' > /usr/lib/lua/luci/controller/libernet.lua
module("luci.controller.libernet", package.seeall)
function index()
entry({"admin","services","libernet"}, template("libernet"), _("Libernet"), 55).leaf=true
end
EOF

cat <<'EOF' > /usr/lib/lua/luci/view/libernet.htm
<%+header%>
<div class="cbi-map">
<iframe id="libernet" style="width: 100%; min-height: 650px; border: none; border-radius: 2px;"></iframe>
</div>
<script type="text/javascript">
document.getElementById("libernet").src = "http://" + window.location.hostname + "/libernet";
</script>
<%+footer%>
EOF

# Hapus baris autentikasi dari file PHP Libernet
for file in index.php config.php about.php speedtest.php system.php; do
  target="/www/libernet/$file"
  if [ -f "$target" ]; then
    echo "[✔] Membersihkan $file ..."
    sed -i '/include[[:space:]]*(["'"'"']auth.php["'"'"'])[[:space:]]*;/d' "$target"
    sed -i '/check_session[[:space:]]*(.*)[[:space:]]*;/d' "$target"
  else
    echo "[⚠️] File tidak ditemukan: $target"
  fi
done

echo -e "\n✅ Libernet telah dipasang dan dibersihkan dari login. Silakan akses melalui LuCI → Services → Libernet atau buka http://<IP-Router>/libernet"

