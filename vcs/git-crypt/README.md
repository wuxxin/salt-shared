usage
=====

# make a new git repository
mkdir t
cd t
git init
git-crypt init

# define which files to be encrypted
cat > .gitattributes << EOF
*secrets* filter=git-crypt diff=git-crypt
*secret* filter=git-crypt diff=git-crypt
*.sec filter=git-crypt diff=git-crypt
*.key filter=git-crypt diff=git-crypt
**/secret/** filter=git-crypt diff=git-crypt
**/secrets/** filter=git-crypt diff=git-crypt
EOF
git-crypt status
git add .
git commit

# add new colaborator

# add colaborator public key to gpg keychain
gpg --import whateveruser.text.gpgkey
# add colaborator to the git repository as crypt target
git-crypt add-gpg-user user.email@address.org

# add some new files (susi and sls will be plain text; key, sec will be encrypted) to repo
echo 1 > test.susi
echo 2 > test.sls
echo 3 > test.key
echo 4 > test.sec
mkdir -p test/secret
mkdir -p bli/bla/blu/secrets/peng
echo 1 > bli/bla/blu/secrets/peng/test
echo 2 > bli/bla/blu/test
echo 3 > testsecret.sls
git add .
git commit

# lock the repository
git-crypt lock

# look at the files
# unlock the repository
# git-crypt unlock
# look at the files

usage for pillars
-----------------

 * inside the sls (which does not contain sensitive information)

{% import_yaml "pillardirectory/pillar-file.secrets" as my_data %}
 what-ever-pillar-data-name inside a yaml structure: {{ my_data }}

 * workaround for inclusion in pillar without complaining:
{% if salt['cmd.run_stdout']('which git-crypt') != "" %}
{% endif %}
