#!/bin/bash -eux

# JDK and JRE are required for Jenkins
apt-get update

# make add-apt-repository available
apt-get install -y software-properties-common python-software-properties

## add java 8 repo
add-apt-repository -y ppa:webupd8team/java
apt-get update

# setting to automatically accept the licence to prevent the prompt
echo debconf shared/accepted-oracle-license-v1-1 select true | \
debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | \
debconf-set-selections

# install java 8 and set defaults
apt-get install -y oracle-java8-installer
apt-get install -y oracle-java8-set-default
apt-get install -y unzip dos2unix


wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list

apt-get update
apt-get install -y jenkins
apt-get -y upgrade

# copy premade configuration files
# jenkins default config, to set --prefix=jenkins
cp -f /tmp/jenkins-config/jenkins /etc/default
# fix dos newlines for Windows users
dos2unix /etc/default/jenkins
# install some extra plugins
/bin/bash /tmp/jenkins-config/install_jenkins_plugins.sh
# jenkins security and pipeline plugin config
cp -f /tmp/jenkins-config/config.xml /var/lib/jenkins
# set up username for vagrant
mkdir -p /var/lib/jenkins/users/vagrant
cp /tmp/jenkins-config/users/vagrant/config.xml /var/lib/jenkins/users/vagrant
# example job
mkdir -p /var/lib/jenkins/jobs
cd /var/lib/jenkins/jobs
tar zxvf /tmp/jenkins-config/example-job.tar.gz

# set permissions or else jenkins can't run jobs
chown -R jenkins:jenkins /var/lib/jenkins

# restart for jenkins to pick up the new configs
service jenkins restart