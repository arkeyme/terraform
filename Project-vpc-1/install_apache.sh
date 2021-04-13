#! /bin/bash
sudo apt-get update
sudo apt install net-tools
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
echo $(hostname) | sudo tee -a /var/www/html/index.html