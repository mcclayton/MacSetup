#Ensure user-installed binaries take precedence
export PATH=/usr/local/bin:$PATH

#Load .bashrc if it exists
test -f ~/.bashrc && source ~/.bashrc
