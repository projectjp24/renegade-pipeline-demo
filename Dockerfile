# Base image
FROM python:3.11-slim

# Working dir
WORKDIR /app

# Dependencies
COPY requirement.txt .
RUN pip install --no-cache-dir -r requirement.txt

# App code
COPY app.py .

#Port expose
EXPOSE 5000

# Run app
CMD ["python", "app.py"]
