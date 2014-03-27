gpg --gen-key --batch <<EOF
Key-Type: RSA
Key-Length: ${2}
Subkey-Type: RSA
Subkey-Length: ${2}
Name-Real: ${3}
Name-Email: ${5}
Expire-Date: 0
Passphrase: ${4}
%pubring foo${1}.pub
%secring foo${1}.sec
# Do a commit here, so that we can later print "done" :-)
%commit
EOF
