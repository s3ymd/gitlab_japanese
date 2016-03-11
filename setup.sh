GITLAB_DEB=${GITLAB_DEB:-gitlab-ce_7.13.5-ce.0_amd64.deb}
PATCH_VER=${PATCH_VER:-v7.13.5}
SWAP_SIZE=${SWAP_SIZE:-4G}

# # # # # # # # # # # # # # # # # # # #

export DEBIAN_FRONTEND=noninteractive

fallocate -l ${SWAP_SIZE} /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile   none    swap    sw    0   0' >> /etc/fstab
sysctl vm.swappiness=10
echo 'vm.swappiness=10' >> /etc/sysctl.conf

apt-get update -y 
apt-get install -y curl openssh-server ca-certificates postfix git
curl -LJO https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/trusty/${GITLAB_DEB}/download
dpkg -i ${GITLAB_DEB}
gitlab-ctl reconfigure


git clone https://github.com/ksoichiro/gitlab-i18n-patch.git ~/gitlab-i18n-patch
cd /opt/gitlab/embedded/service/gitlab-rails
patch -p1 < ~/gitlab-i18n-patch/patches/${PATCH_VER}/app_ja.patch

cd /opt/gitlab/embedded/service/gitlab-rails
rm -rf public/assets
export PATH=/opt/gitlab/embedded/bin:$PATH
bundle exec rake assets:precompile RAILS_ENV=production

gitlab-ctl restart
