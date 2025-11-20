#!/bin/bash

# Quantum Scanner Backend Setup Script

echo "🚀 Setting up Quantum Scanner Backend..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.8 or later."
    exit 1
fi

echo "✅ Python 3 found"

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install requirements
echo "📥 Installing requirements..."
pip install -r requirements.txt

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from .env.sample..."
    cp .env.sample .env
    echo "📝 Please edit .env file with your database credentials"
fi

echo "🎯 Setup complete!"
echo ""
echo "To start the server:"
echo "  1. Edit .env file with your database settings"
echo "  2. Run: source venv/bin/activate"
echo "  3. Run: python app.py"
echo ""
echo "📱 Don't forget to update the mobile app config with your server IP address!"