echo "installing go"
VERSION=1.14.2
OS=linux
ARCH=amd64
wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz
tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
export PATH=$PATH:/usr/local/go/bin
#rm go$VERSION.$OS-$ARCH.tar.gz
