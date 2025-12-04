# Stage8MotorBridge — Julia / pyvesc VESC Motor Bridge

This repository provides a hardware control bridge using Julia and pyvesc to control a VESC-driven motor. It supports serial communication over `/dev/ttyACM1`, safe duty-cycle control via Python packets, and can be extended into a TCP or F´-integrated bridge.

---

## 🧰 Requirements

- Python 3.11 (or compatible)  
- `pyvesc` and `pyserial` installed in a virtual environment  
- Julia 1.10 (or newer) + `PyCall` package  
- A VESC connected via USB (e.g. `/dev/ttyACM1`), with appropriate permissions  

---

## ⚙️ Full Setup and Run (Recommended)

We provide a setup script to avoid common issues with `PyCRC` / `pyvesc` and PyCall.

```bash
# Make the setup script executable
chmod +x setup_and_run.sh

# Run full setup: Python venv, dependencies, Julia PyCall, server, and client
./setup_and_run.sh
This script will:

Create a Python 3.11 virtual environment (fprime-venv-py311).

Upgrade pip, setuptools, and wheel.

Install Python dependencies (PyCRC, pyvesc, pyserial, crccheck).

Set up Julia environment and configure PyCall to use the correct Python venv.

Start the Julia MotorBridgeServer.

Launch the Python motor client.

✅ Everything is pre-configured to avoid ModuleNotFoundError for PyCRC or pyvesc.
🧪 Quick Manual Test (Direct Julia Control)
using PyCall
include("src/MotorBridgeServer.jl")   # or test/vesc_test.jl

# Example: spin motor at 20%
set_duty(0.2)
sleep(2)
set_duty(0.0)  # stop
🏗 Run Full Server (for TCP / network control)
julia src/MotorBridgeServer.jl
Then send commands over TCP or extend with your own control logic.
Troubleshooting

Python module errors
Make sure you are using the Python venv created by the script:
source fprime-venv-py311/bin/activate


PyCall errors in Julia
If Julia fails to import pyvesc, rebuild PyCall explicitly:

ENV["PYTHON"] = "$(pwd)/fprime-venv-py311/bin/python"
using Pkg
Pkg.build("PyCall")
PyCRC import issues
Ensure you installed the correct Git version of PyCRC:
pip uninstall -y pycrc PyCRC
pip install git+https://github.com/alexbutirskiy/PyCRC.git@master
Server not connecting to client
Make sure MotorBridgeServer.jl is running before launching motor_client.py.
📦 Repository Layout
Stage8MotorBridge/
├── src/                # main Julia code
│   └── MotorBridgeServer.jl
├── test/               # small test scripts
│   └── vesc_test.jl
├── requirements.txt
├── setup_and_run.sh    # full setup + run script
├── README.md
├── .gitignore

