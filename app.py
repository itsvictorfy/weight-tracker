# Flask web application
from flask import Flask, render_template, request, jsonify
import psycopg2

app = Flask(__name__)

db_host = 'weightTracker-database-vm'
db_port = '5432'
db_name = 'weightdb'
db_user = 'postgres'
db_password = 'admin'

def storeData(name, weight, date):
    try:
        # Establish a connection to the PostgreSQL database
        connection = psycopg2.connect(
            host=db_host,
            database=db_name,
            user=db_user,
            password=db_password
        )

        cursor = connection.cursor()
        insert_query = "INSERT INTO weight (name, weight, date) VALUES (%s, %s, %s);"
        cursor.execute(insert_query, (name, weight, date))
        connection.commit()
        cursor.close()
        connection.close()
        print("Entry inserted successfully!")
        response = {
            'status': 'success',
            'name': name,
            'age_value': weight,
            'time': date,
            'database_status': 'Data inserted successfully'
        }
        return jsonify(response)


    except (Exception, psycopg2.Error) as error:
        response = {
            'status': 'error',
            'message': 'Database error',
            'error_details': str(error)
        }
        return jsonify(response), 500

@app.route('/data/<name>', methods=['GET'])
def retrieve_data(name):
    try:
        # Establish a connection to the PostgreSQL database
        connection = psycopg2.connect(
            host=db_host,
            database=db_name,
            user=db_user,
            password=db_password
        )

        cursor = connection.cursor()
        select_query = "SELECT * FROM weight WHERE name = %s;"
        cursor.execute(select_query, (name,))
        result = cursor.fetchone()

        if result:
            # Retrieve the relevant information from the database
            name = result[0]
            age_value = result[1]
            time = result[2]

            response = {
                'status': 'success',
                'name': name,
                'age_value': age_value,
                'time': time
            }
        else:
            response = {
                'status': 'error',
                'message': 'name not found in the database'
            }

        return jsonify(response)
    except (Exception, psycopg2.Error) as error:
        print("Error while getting data:", error)
        response = {
                'status': 'error',
                'message': 'error connecting to db'
            }
        return jsonify(response)

@app.route('/')
def home():
    return render_template("page.html")

@app.route('/submitWeight', methods={'POST'})
def getData():
    name = request.form['name']
    weight = request.form['weight']
    date = request.form['date']
    return storeData(name, weight, date)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
