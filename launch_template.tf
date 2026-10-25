resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-"
  image_id      = "ami-0dd60a46ecc6eac16"  # Replace with your Amazon Linux 2 AMI ID
  instance_type = "t3.micro"

  # User data script for the EC2 instance

user_data = base64encode(<<-EOF
#!/bin/bash
set -euxo pipefail

exec > >(tee -a /var/log/user-data.log) 2>&1

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  python3 python3-venv python3-pip git nginx

# Clone the Django repository
mkdir -p /opt/django-app
git clone --depth 1 \
  https://github.com/shaikfirose/Django-Ecommerce-Website.git \
  /opt/django-app/repository

# Find Django's manage.py (the repository may contain a nested project)
MANAGE_FILE=$(find /opt/django-app/repository -name manage.py -type f -print -quit)
if [ -z "$MANAGE_FILE" ]; then
  echo "ERROR: manage.py not found in the repository"
  exit 1
fi

APP_DIR=$(dirname "$MANAGE_FILE")
cd "$APP_DIR"

# Create a virtual environment and install dependencies
python3 -m venv /opt/django-app/venv
/opt/django-app/venv/bin/pip install --upgrade pip
if [ -f requirements.txt ]; then
  /opt/django-app/venv/bin/pip install -r requirements.txt
fi
/opt/django-app/venv/bin/pip install gunicorn

# Find the Django WSGI application module
WSGI_FILE=$(find "$APP_DIR" -name wsgi.py -type f -print -quit)
if [ -z "$WSGI_FILE" ]; then
  echo "ERROR: Django wsgi.py not found"
  exit 1
fi

WSGI_MODULE=$(python3 -c \
  'import os,sys; print(os.path.relpath(sys.argv[1],sys.argv[2]).replace(os.sep,".")[:-3])' \
  "$WSGI_FILE" "$APP_DIR")

# Run database migrations
/opt/django-app/venv/bin/python "$MANAGE_FILE" migrate --noinput

# Collect static files; check logs if the project's settings require configuration
/opt/django-app/venv/bin/python "$MANAGE_FILE" collectstatic --noinput

# Create a systemd service for Django/Gunicorn
cat > /etc/systemd/system/django-app.service <<SERVICE
[Unit]
Description=Django Ecommerce Application
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=$APP_DIR
Environment="PATH=/opt/django-app/venv/bin"
ExecStart=/opt/django-app/venv/bin/gunicorn --workers 2 --bind 127.0.0.1:8000 $WSGI_MODULE
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

# Configure Nginx as a reverse proxy
cat > /etc/nginx/sites-available/django-app <<'NGINX'
server {
    listen 80 default_server;
    server_name _;

    location /static/ {
        alias /opt/django-app/static/;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
    }
}
NGINX

rm -f /etc/nginx/sites-enabled/default
ln -sfn /etc/nginx/sites-available/django-app /etc/nginx/sites-enabled/django-app

# Allow the service account to read application files
chmod -R a+rX /opt/django-app/repository
chmod -R a+rX /opt/django-app/venv

nginx -t
systemctl daemon-reload
systemctl enable --now django-app
systemctl enable --now nginx
systemctl restart nginx
EOF
)



  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id] # Ensure web_sg exists
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "WebAppInstance"
    }
  }
}
