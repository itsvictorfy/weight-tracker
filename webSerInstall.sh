sudo apt-get install postgresql-client
sudo apt install net-tools
git clone https://github.com/itsvictorfy/flaskapp.git
cd flaskapp
sudo apt-get update
sudo apt install python3-pip
sudo apt install python3-virtualenv
virtualenv flask
cd flask
source bin/activate
pip install psycopg2
pip install flask
python3 ../app.py
