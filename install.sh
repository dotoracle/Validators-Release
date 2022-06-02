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
echo '{"parties":"8", "threshold":"5"}' >> ${DIR}/params.json
sudo tee ${DIR}/generateKeyStore.sh <<EOF
#!/usr/bin/env bash
cd ${DIR} && gg18_keygen_client $1 ${DIR}/keys.store
EOF


chmod +x ${DIR}/generateKeyStore.sh
bash ${DIR}/generateKeyStore.sh


echo "Waiting other validator generate key... Your key will create when all validator run this script. It will store at ${DIR}/keys.store. You need backup this file"
exit

