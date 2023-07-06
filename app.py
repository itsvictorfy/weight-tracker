# Flask web application
from flask import Flask, render_template, request
import psycopg2

app = Flask(__name__)

db_host = 'weightTracker-database-vm'
db_port = '5432'
db_name = 'weighttracker'
db_user = 'postgres'
db_password = 'admin'

def storeData(name, weight, date):
    try:
        # Establish a connection to the PostgreSQL database
        connection = psycopg2.connect(
            host="your_host",
            database="your_database",
            user="your_user",
            password="your_password"
        )

        cursor = connection.cursor()
        insert_query = "INSERT INTO weight (name, weight, date) VALUES (%s, %s, %s);"
        cursor.execute(insert_query, (name, weight, date))
        connection.commit()
        cursor.close()
        connection.close()
        print("Entry inserted successfully!")
        return render_template("page.html")

    except (Exception, psycopg2.Error) as error:
        print("Error while inserting entry:", error)
        return render_template("page.html")


@app.route('/')
def home():
    return render_template("page.html")

@app.route('/submitWeight', methods={'POST'})
def getData():
    name = request.form['name']
    weight = request.form['weight']
    date = request.form['date']

    storeData(name, weight, date)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
