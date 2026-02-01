# Use a lightweight Python version
FROM python:3.9-slim

# Set working directory inside the container
WORKDIR /app

# Copy requirements first to leverage Docker caching
COPY requirements.txt .

# Install dependencies
# --no-cache-dir keeps the image small
RUN pip install --no-cache-dir -r requirements.txt

# Copy the actual Python code
COPY app.py .

# Expose the port Flask runs on
EXPOSE 5000

# Command to run the application
CMD ["python", "MealBridgeMLModel.py"]