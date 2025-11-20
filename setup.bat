@echo off
REM Quantum Scanner Backend Setup Script for Windows

echo 🚀 Setting up Quantum Scanner Backend...

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python is not installed. Please install Python 3.8 or later.
    pause
    exit /b 1
)

echo ✅ Python found

REM Create virtual environment
if not exist "venv" (
    echo 📦 Creating virtual environment...
    python -m venv venv
)

echo 🔧 Activating virtual environment...
call venv\Scripts\activate.bat

REM Install requirements
echo 📥 Installing requirements...
pip install -r requirements.txt

REM Check if .env exists
if not exist ".env" (
    echo ⚠️  .env file not found. Creating from .env.sample...
    copy .env.sample .env
    echo 📝 Please edit .env file with your database credentials
)

echo 🎯 Setup complete!
echo.
echo To start the server:
echo   1. Edit .env file with your database settings
echo   2. Run: venv\Scripts\activate.bat
echo   3. Run: python app.py
echo.
echo 📱 Don't forget to update the mobile app config with your server IP address!
echo.
echo To find your IP address, run: ipconfig
echo Look for IPv4 Address under your network adapter
pause