#! /usr/bin/env zsh

NONINTERACTIVE=1 brew install rust
NONINTERACTIVE=1 brew install gh 

cargo install git-stack
cargo install git-branch-stash-cli

installDir=${SCRIPT_DIR:-$HOME/bin}
mkdir -p $installDir
# copy the scripts in this repo into the installDir
cp git-* $installDir

# append export PATH="$PATH:$HOME/.cargo/bin" to ~/.zshrc
echo '#envoy-git-stack' >> ~/.zshrc
echo 'export PATH="$PATH:$HOME/.cargo/bin"' >> ~/.zshrc

# read from the environment variable $SCRIPT_DIR or default to $HOME/bin
# append installDir to the PATH in ~/.zshrc
echo 'export PATH="$PATH:'$installDir'"' >> ~/.zshrc
echo '#envoy-git-stack' >> ~/.zshrc

source ~/.zshrc

# validate installation
git stack help
if [ $? -ne 0 ]; then
    echo "git stack not installed correctly"
fi

git top
if [ $? -ne 0 ]; then
    echo "git top not installed correctly"
fi

git bottom
if [ $? -ne 0 ]; then
    echo "git bottom not installed correctly"
fi
