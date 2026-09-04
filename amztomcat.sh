cat << 'EOF' > install_tomcat.sh
#!/bin/bash
set -e

echo "=== 1. Updating system and installing Amazon Corretto 21 & Git ==="
if command -v dnf &> /dev/null; then
    sudo dnf update -y
    sudo dnf install java-21-amazon-corretto git -y
else
    sudo yum update -y
    sudo yum install java-21-amazon-corretto git -y
fi

echo "=== 2. Downloading Apache Tomcat 9.0.121 ==="
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.121/bin/apache-tomcat-9.0.121.tar.gz
tar -zxvf apache-tomcat-9.0.121.tar.gz

echo "=== 3. Configuring JAVA_HOME inside Tomcat ==="
JAVA_PATH=$(readlink -f $(which java) | sed "s:/bin/java::")
echo "export JAVA_HOME=$JAVA_PATH" > apache-tomcat-9.0.121/bin/setenv.sh
chmod +x apache-tomcat-9.0.121/bin/setenv.sh

echo "=== 4. Removing Remote IP Restrictions (Fixes 403 Access Denied) ==="
sed -i 's/<Valve /<!-- <Valve /g' apache-tomcat-9.0.121/webapps/manager/META-INF/context.xml
sed -i 's/\/>/ \/> -->/g' apache-tomcat-9.0.121/webapps/manager/META-INF/context.xml
sed -i 's/<Valve /<!-- <Valve /g' apache-tomcat-9.0.121/webapps/host-manager/META-INF/context.xml
sed -i 's/\/>/ \/> -->/g' apache-tomcat-9.0.121/webapps/host-manager/META-INF/context.xml

echo "=== 5. Setting Up Clean Manager Credentials ==="
cat << 'CREDENTIALS' > apache-tomcat-9.0.121/conf/tomcat-users.xml
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <role rolename="manager-jmx"/>
  <role rolename="manager-status"/>
  <user username="tomcat" password="admin@123" roles="manager-gui,manager-script"/>
</tomcat-users>
CREDENTIALS

echo "=== 6. Starting Apache Tomcat ==="
sh apache-tomcat-9.0.121/bin/startup.sh

echo "=== Tomcat Installation Completed Successfully! ==="
EOF

chmod +x install_tomcat.sh
./install_tomcat.sh
