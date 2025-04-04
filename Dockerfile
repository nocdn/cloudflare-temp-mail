# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
# --no-cache-dir reduces image size
# --trusted-host prevents SSL issues in some environments
RUN pip install --no-cache-dir --trusted-host pypi.python.org -r requirements.txt

# Copy the rest of the application code into the container
COPY app.py .
# Copy .env.example for reference
COPY .env.example .

# Make port 6020 available to the world outside this container
EXPOSE 6020

# Define environment variable for the port (can be overridden)
ENV FLASK_RUN_PORT=6020
# Recommended: Disable Flask development server debug mode in production image
ENV FLASK_DEBUG=false
# Set a default internal path for CSV if not mounted (won't persist container restarts)
ENV CSV_LOG_PATH=/app/generated_emails.csv

# Run app.py when the container launches using Gunicorn
# Use 0.0.0.0 to bind to all network interfaces
# Use app:app to specify the module and the Flask app instance
CMD ["gunicorn", "--bind", "0.0.0.0:6020", "--workers", "2", "app:app"]

# --- Notes on CSV Logging ---
# To make the CSV log persistent and accessible outside the container,
# you MUST mount a host directory to the path specified by CSV_LOG_PATH
# when running `docker run`.
# Example mount: -v /path/on/host/logs:/app/logs
# And set in .env: CSV_LOG_PATH=/app/logs/generated_emails.csv