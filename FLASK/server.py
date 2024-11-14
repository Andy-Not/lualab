from flask import Flask, request, jsonify

app = Flask(__name__)
display_buffer = None  # Global variable to store the buffer

@app.route('/update_display', methods=['POST'])
def update_display():
    global display_buffer
    data = request.get_json()  # Parse JSON
    print("Received data:", data)  # Debugging line

    if not isinstance(data, dict) or not isinstance(data.get("displayBuffer"), list):
        print("Invalid data format")
        return jsonify({"status": "error", "message": "Invalid data format"}), 400

    display_buffer = data.get("displayBuffer")
    return jsonify({"status": "success"}), 200



@app.route('/get_display', methods=['GET'])
def get_display():
    """Endpoint for Tkinter app to retrieve the display buffer."""
    global display_buffer
    return jsonify({"displayBuffer": display_buffer}), 200

if __name__ == '__main__':
    app.run(debug=True)
