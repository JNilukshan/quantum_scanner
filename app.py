# app.py
import os
from datetime import datetime
from dotenv import load_dotenv
from flask import Flask, request, jsonify, render_template_string
from flask_cors import CORS
from flask_socketio import SocketIO, emit, disconnect
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

# Load .env (ensure .env is not in version control)
load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_NAME = os.getenv("DB_NAME")
API_KEY = os.getenv("API_KEY")  # optional simple API key for scanning devices

if not (DB_USER and DB_PASS and DB_HOST and DB_NAME):
    raise RuntimeError("Missing database environment variables. See README/.env.sample")

# SQLAlchemy connection string (MySQL example using PyMySQL driver)
DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}?charset=utf8mb4"

# Create engine with a connection pool (tune pool_size for expected load)
engine = create_engine(
    DATABASE_URL,
    pool_size=int(os.getenv("DB_POOL_SIZE", 5)),
    max_overflow=int(os.getenv("DB_MAX_OVERFLOW", 10)),
    pool_pre_ping=True,
    future=True,
)

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-change-in-production')
CORS(app, origins=os.getenv("CORS_ORIGINS", "*"))  # restrict CORS_ORIGINS in production

# Initialize Socket.IO
socketio = SocketIO(app, cors_allowed_origins=os.getenv("CORS_ORIGINS", "*"))

# Store active web connections
active_web_clients = set()

@socketio.on('connect')
def handle_connect():
    print(f'Web client connected: {request.sid}')
    active_web_clients.add(request.sid)
    emit('status', {'message': 'Connected to Quantum Scanner server'})

@socketio.on('disconnect')
def handle_disconnect():
    print(f'Web client disconnected: {request.sid}')
    active_web_clients.discard(request.sid)

@socketio.on('join_room')
def handle_join_room(data):
    room = data.get('room', 'default')
    print(f'Client {request.sid} joining room: {room}')
    # For simplicity, we'll broadcast to all connected clients

@app.route("/api/mobile-scan", methods=["POST"])
def mobile_scan():
    """Handle QR scan data from mobile app and broadcast to web clients"""
    # Basic API key check (can be replaced by mTLS/JWT/etc)
    header_api_key = request.headers.get("X-API-KEY")
    if API_KEY:
        if not header_api_key or header_api_key != API_KEY:
            return jsonify({"success": False, "error": "Unauthorized"}), 401

    data = request.get_json(silent=True) or {}
    qr_data = data.get("qr_data")
    device_id = data.get("device_id", "unknown")
    scan_timestamp = datetime.utcnow().isoformat() + "Z"

    if not qr_data:
        return jsonify({"success": False, "error": "Missing qr_data"}), 400

    # Create scan result object
    scan_result = {
        "qr_data": qr_data,
        "device_id": device_id,
        "timestamp": scan_timestamp,
        "data_type": _detect_data_type(qr_data)
    }

    # If the QR data looks like an employee hash, try to fetch employee data
    employee_data = None
    if len(qr_data) >= 5 and qr_data.replace('-', '').replace('_', '').isalnum():
        employee_data = _get_employee_data(qr_data)
    
    if employee_data:
        scan_result["employee"] = employee_data

    # Broadcast to all connected web clients
    if active_web_clients:
        socketio.emit('qr_scanned', scan_result, broadcast=True)
        print(f'Broadcasted scan result to {len(active_web_clients)} web clients')

    return jsonify({"success": True, "scan_result": scan_result}), 200

def _detect_data_type(data):
    """Detect the type of QR code data"""
    if data.startswith(('http://', 'https://', 'www.')):
        return 'URL'
    elif '@' in data and '.' in data:
        return 'Email'
    elif data.replace('+', '').replace('-', '').replace(' ', '').replace('(', '').replace(')', '').isdigit():
        return 'Phone'
    else:
        return 'Text'

def _get_employee_data(emp_hash):
    """Get employee data from database"""
    try:
        with engine.connect() as conn:
            sql = text("""
                SELECT emp_no, emp_hash, name, department, location,
                       participant_type, is_bm, is_hod, attendance, image_url
                FROM employees
                WHERE emp_hash = :h
                LIMIT 1
            """)
            result = conn.execute(sql, {"h": emp_hash})
            row = result.fetchone()

            if row:
                return {
                    "emp_no": row["emp_no"],
                    "emp_hash": row["emp_hash"],
                    "name": row["name"],
                    "department": row["department"],
                    "location": row["location"],
                    "participant_type": row["participant_type"],
                    "is_bm": bool(row["is_bm"]),
                    "is_hod": bool(row["is_hod"]),
                    "attendance": row["attendance"],
                    "image_url": row.get("image_url"),
                }
    except SQLAlchemyError as e:
        print(f"Database error: {e}")
    return None

@app.route("/")
def dashboard():
    """Serve the dashboard page"""
    with open('index.html', 'r', encoding='utf-8') as f:
        return f.read()

@app.route("/api/scan", methods=["POST"])
def scan():
    # Basic API key check (can be replaced by mTLS/JWT/etc)
    header_api_key = request.headers.get("X-API-KEY")
    if API_KEY:
        if not header_api_key or header_api_key != API_KEY:
            return jsonify({"success": False, "error": "Unauthorized"}), 401

    data = request.get_json(silent=True) or {}
    emp_hash = data.get("emp_hash") or request.form.get("emp_hash")

    if not emp_hash or not isinstance(emp_hash, str) or len(emp_hash) < 5:
        return jsonify({"success": False, "error": "Invalid or missing emp_hash"}), 400

    try:
        with engine.connect() as conn:
            # Parameterized query - list the columns you need
            sql = text("""
                SELECT emp_no, emp_hash, name, department, location,
                       participant_type, is_bm, is_hod, attendance, image_url
                FROM employees
                WHERE emp_hash = :h
                LIMIT 1
            """)
            result = conn.execute(sql, {"h": emp_hash})
            row = result.fetchone()

            if not row:
                return jsonify({"success": False, "error": "User not recognized"}), 404

            # Convert row to dict
            employee = {
                "emp_no": row["emp_no"],
                "emp_hash": row["emp_hash"],
                "name": row["name"],
                "department": row["department"],
                "location": row["location"],
                "participant_type": row["participant_type"],
                "is_bm": bool(row["is_bm"]),
                "is_hod": bool(row["is_hod"]),
                "attendance": row["attendance"],  # e.g. "Checked in" or "Not checked in"
                "image_url": row.get("image_url"),
                "checked_at": datetime.utcnow().isoformat() + "Z"
            }

            # Optionally: update attendance timestamp (uncomment if you want DB update)
            # update_sql = text("UPDATE employees SET attendance = 'Checked in', last_checked = NOW() WHERE emp_hash = :h")
            # conn.execute(update_sql, {"h": emp_hash})
            # conn.commit()

            return jsonify({"success": True, "employee": employee}), 200

    except SQLAlchemyError as e:
        app.logger.exception("DB error during scan")
        return jsonify({"success": False, "error": "Internal server error"}), 500


if __name__ == "__main__":
    # For production run via a WSGI server (gunicorn/uvicorn + wrapper). For local dev:
    socketio.run(app, host="0.0.0.0", port=int(os.getenv("FLASK_PORT", 5000)), debug=os.getenv("FLASK_DEBUG", "false").lower() == "true")
