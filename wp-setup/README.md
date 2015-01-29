#AWS GSN WP Setup v1.0.0

##admin instance
git clone https://github.com/cannontech/wp-server-setup.git

get pem file, put in /wp-server-setup

edit template (gsn-aws-template.js), find rdswordpress, fill in DBName and MasterUserPassword

log into aws

select n.california for region

run template (<git folder>/wp-server-setup/gsn-aws-template.js in services/cloudformation)

ssh into admin box (select instance and click connect - change n.california to ncalifornia)

sudo apt-get update

sudo apt-get install git

sudo git clone https://github.com/cannontech/wp-server-setup.git

cd wp-server-setup

sudo chmod +x *.sh

sudo ./gsn-server-setup.sh

sudo ./admin.sh

logout of ssh

*configure wp*
browse to admin IP
fill in form

##worker instance
ssh into worker box

sudo apt-get update

sudo apt-get install git

sudo git clone https://github.com/cannontech/wp-server-setup.git

cd wp-server-setup

sudo chmod +x *.sh

sudo ./gsn-server-setup.sh

sudo ./worker.sh

logout ssh
