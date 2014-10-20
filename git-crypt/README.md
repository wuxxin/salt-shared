# usage:

# make a new git repository
mkdir t
cd t
git init
git-crypt init

# define which files to be encrypted
cat > .gitattributes << EOF
*.sls filter=git-crypt diff=git-crypt
*.sec filter=git-crypt diff=git-crypt
*.key filter=git-crypt diff=git-crypt
EOF
git-crypt status
git add .
git commit

# add new colaborator
git-crypt add-gpg-user felix@erkinger.at

# add some new files (susi will be plain text, sls, key will be encrypted) to repo
echo 1 > test.susi
echo 2 > test.sls
echo 3 > test.key
git add test.*
git commit

# lock the repository
git-crypt lock
