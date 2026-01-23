#!/bin/bash
echo "=== FRESH SETUP ==="

# 1. Go to directory
cd /home/ubuntu/singing
echo "1. Directory: $(pwd)"

# 2. Remove old venv
echo "2. Removing old venv..."
rm -rf venv

# 3. Create new venv
echo "3. Creating new venv..."
python3 -m venv venv

# 4. Activate
echo "4. Activating venv..."
source venv/bin/activate

# 5. Check Python
echo "5. Python: $(python --version 2>&1)"

# 6. Upgrade pip
echo "6. Upgrading pip..."
pip install --upgrade pip

# 7. Install streamlit
echo "7. Installing streamlit..."
pip install streamlit pillow requests pandas numpy

# 8. Install from requirements.txt
if [ -f "requirements.txt" ]; then
    echo "8. Installing requirements.txt..."
    pip install -r requirements.txt
fi

# 9. Kill old processes
echo "9. Killing old processes..."
pkill -f streamlit 2>/dev/null || true
pkill -f "python.*app" 2>/dev/null || true

# 10. Start streamlit
echo "10. Starting streamlit..."
nohup streamlit run app.py --server.port 8000 --server.address 0.0.0.0 --server.headless true > streamlit.log 2>&1 &

# 11. Wait
echo "11. Waiting 15 seconds..."
sleep 15

# 12. Check
echo "12. Checking..."
ps aux | grep "streamlit.*8000" | grep -v grep
if [ $? -eq 0 ]; then
    echo "✅ Streamlit is running"
else
    echo "❌ Streamlit failed to start"
    echo "Logs:"
    tail -30 streamlit.log
fi

# 13. Test
echo "13. Testing..."
echo -n "Local access: "
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000 || echo "FAILED"
