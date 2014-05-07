include:
  - .gitlab-hq

      - cmd: gitlab-hq-config

{% from 'roles/gitlab/config.sls' import gitlab_config with context %}

if [ "$1" == "gitlab:backup:restore" ]; then
# user needs to select the backup to restore
nBackups=$(ls tmp/backups/*_gitlab_backup.tar | wc -l)
if [ $nBackups -eq 0 ]; then
echo "No backup present. Cannot continue restore process.".
return 1
fi

for b in `ls tmp/backups/ | sort -r`
do
echo " ├ $b"
done
read -p "Select a backup to restore: " file

if [ ! -f "tmp/backups/${file}" ]; then
echo "Specified backup does not exist. Aborting..."
return 1
fi

timestamp=$(echo $file | cut -d'_' -f1)
sudo -u git -H bundle exec rake gitlab:backup:restore BACKUP=$timestamp RAILS_ENV=production
else
sudo -u git -H bundle exec rake $@ RAILS_ENV=production
fi
