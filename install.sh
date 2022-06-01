#!/usr/bin/sh

# Install library
echo 'install necessary library'
apt update -y && apt install -y pkg-config libssl-dev openssl


# Download binary
echo 'download official dotoracle binary'
wget https://github.com/dotoracle/Validators-Release/raw/main/mpc/gg18_keygen_client
wget https://github.com/dotoracle/Validators-Release/raw/main/mpc/gg18_sign_client

echo 'install dotoracle binary'
chmod +x gg18_keygen_client
chmod +x gg18_sign_client
mv gg18_keygen_client /usr/local/bin/
mv gg18_sign_client /usr/local/bin/

echo 'setup environments'
mkdir /dotoracle
echo '{"parties":"11", "threshold":"7"}' >> /dotoracle/params.json
sudo tee /dotoracle/dotoracle.sh <<EOF
#!/usr/bin/env bash
cd /dotoracle && gg18_keygen_client http://195.201.174.142:10000 /dotoracle/keys.store
EOF

chmod +x /dotoracle/dotoracle.sh

echo 'init service'
sudo tee /etc/systemd/system/dotoracleValidator.service <<EOF
[Unit]
Description=DotOracle Validator
After=network-online.target
Requires=network-online.target

[Service]
ExecStart=/dotoracle/dotoracle.sh
LimitAS=infinity
LimitRSS=infinity
LimitCORE=infinity
LimitNOFILE=6553600
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo 'start service'
sudo systemctl enable dotoracleValidator.service && sudo systemctl start dotoracleValidator.service
