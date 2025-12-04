#!/bin/bash
# Stage8MotorBridge full setup and run script
# Run from project root
# This version ensures PyCRC + pyvesc work correctly with Julia PyCall

echo "🚀 Starting full Stage8MotorBridge setup..."

# --- Step 1: Python virtual environment ---
VENV_DIR="fprime-venv-py311"
PYTHON_BIN="$PWD/$VENV_DIR/bin/python"

if [ ! -d "$VENV_DIR" ]; then
    echo "🐍 Creating Python 3.11 venv..."
    python3.11 -m venv "$VENV_DIR"
else
    echo "🐍 Python venv already exists."
fi

echo "Activating Python venv..."
source "$VENV_DIR/bin/activate"

# --- Step 2: Upgrade pip/setuptools/wheel ---
echo "🔧 Upgrading pip, setuptools, wheel..."
pip install --upgrade pip setuptools wheel

# --- Step 3: Install Python dependencies ---
if [ -f requirements.txt ]; then
    echo "📦 Installing Python packages (excluding local pyvesc)..."
    grep -v "pyvesc" requirements.txt | xargs -n 1 pip install
else
    echo "⚠️ requirements.txt not found, skipping Python package installation."
fi

# --- Step 4: Ensure correct PyCRC and pyvesc ---
echo "🧩 Installing PyCRC (correct casing) and pyvesc..."
pip uninstall -y pycrc PyCRC pyvesc
pip install git+https://github.com/alexbutirskiy/PyCRC.git@master
pip install pyvesc==1.0.5

# --- Step 5: Test Python imports ---
echo "🧪 Testing Python imports..."
python -c "from PyCRC.CRCCCITT import CRCCCITT; import pyvesc; print('Python OK ✅')"

# --- Step 6: Julia environment ---
echo "📦 Setting up Julia packages..."
julia -e '
using Pkg
Pkg.activate(".")
Pkg.instantiate()
'

# --- Step 7: Configure PyCall to use Python venv ---
echo "🔗 Configuring PyCall to use Python venv..."
julia -e '
ENV["PYTHON"] = "'$PYTHON_BIN'"
using Pkg
Pkg.build("PyCall")
using PyCall
pyimport("pyvesc")
println("PyCall + pyvesc OK ✅")
'

# --- Step 8: Start MotorBridgeServer in background ---
echo "🚦 Starting Julia MotorBridgeServer..."
julia MotorBridgeServer.jl &

# Give server a few seconds to start
sleep 2

# --- Step 9: Launch Python motor client ---
echo "🚗 Starting Python motor client..."
python3 "$PWD/motor_client.py"

# --- Done ---
echo "✅ Stage8MotorBridge setup and run complete!"
echo "Use Ctrl+C in the server terminal to stop the MotorBridgeServer."
