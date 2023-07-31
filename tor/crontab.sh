if ! crontab -u admin -l | grep checkHiddenService; then
  cronjob="0,15,30,45 * * * * /home/admin/checkHiddenService"
  (
    crontab -u admin -l
    echo "$cronjob"
  ) | crontab -u admin -
fi
echo "# The crontab for admin now is:"
crontab -u admin -l
echo
