#!/usr/bin/sh

# ENV
DIR=/dotoracle

if [ $# -eq 0 ]
  then
  echo "missing URL argument"
  exit
fi

# Install library
echo "install necessary library"
apt update -y && apt install -y pkg-config libssl-dev openssl


# Download binary
echo "download official dotoracle binary"
wget https://github.com/dotoracle/Validators-Release/raw/main/mpc/gg18_keygen_client
wget https://github.com/dotoracle/Validators-Release/raw/main/mpc/gg18_sign_client

echo "install dotoracle binary"
chmod +x gg18_keygen_client
chmod +x gg18_sign_client
mv gg18_keygen_client /usr/local/bin/
mv gg18_sign_client /usr/local/bin/

echo "setup environments"
mkdir ${DIR}
echo '{"parties":"11", "threshold":"7"}' >> ${DIR}/params.json
sudo tee ${DIR}/generateKeyStore.sh <<EOF
#!/usr/bin/env bash
cd ${DIR} && gg18_keygen_client ${DIR}/keys.store
EOF


chmod +x ${DIR}/generateKeyStore.sh

echo 'init service'
sudo tee /etc/systemd/system/dotoracleGenerateKeyStore.service <<EOF
[Unit]
Description=DotOracle Generate Key Store
After=network-online.target
Requires=network-online.target
[Service]
ExecStart=${DIR}/generateKeyStore.sh
LimitAS=infinity
LimitRSS=infinity
LimitCORE=infinity
LimitNOFILE=6553600
Restart=always
[Install]
WantedBy=multi-user.target
EOF

echo 'start service'
sudo systemctl enable dotoracleGenerateKeyStore.service && sudo systemctl start dotoracleGenerateKeyStore.service


echo "Waiting other validator generate key... Your key will create when all validator run this script. It will store at ${DIR}/keys.store. You need backup this file"
exit

