resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-"
  image_id      = "ami-00bb6a80f01f03502"  # Replace with your Amazon Linux 2 AMI ID
  instance_type = "t2.micro"

  # User data script for the EC2 instance
user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nginx

              # Create the Travel Guide HTML page
              echo "<!DOCTYPE html>
              <html lang=\"en\">
              <head>
                  <meta charset=\"UTF-8\">
                  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
                  <title>Travel Guide</title>
                  <style>
                      body {
                          font-family: Arial, sans-serif;
                          background-color: #e3f2fd;
                          color: #01579b;
                          display: flex;
                          flex-direction: column;
                          align-items: center;
                          padding: 30px;
                      }
                      h1 {
                          color: #0288d1;
                          font-size: 2.5rem;
                      }
                      p {
                          font-size: 1.2rem;
                          margin: 20px 0;
                          text-align: center;
                      }
                      .destination {
                          font-weight: bold;
                          font-size: 1.5rem;
                          color: #1976d2;
                      }
                      .image {
                          width: 80%;
                          max-width: 600px;
                          border-radius: 8px;
                      }
                      .button {
                          margin-top: 20px;
                      }
                      button {
                          background-color: #0288d1;
                          color: white;
                          padding: 10px 20px;
                          font-size: 1rem;
                          border: none;
                          border-radius: 5px;
                          cursor: pointer;
                          transition: background-color 0.3s;
                      }
                      button:hover {
                          background-color: #01579b;
                      }
                  </style>
              </head>
              <body>
                  <h1>Your Ultimate Travel Guide</h1>
                  <img class=\"image\" src=\"https://example.com/travel-image.jpg\" alt=\"Beautiful Destination\">
                  <p>Welcome to the Travel Guide! Here are some of the top destinations you should consider visiting:</p>
                  <div class=\"destination\">1. Paris, France</div>
                  <p>Known as the City of Lights, Paris is famous for its iconic landmarks like the Eiffel Tower, Notre-Dame Cathedral, and the Louvre Museum.</p>

                  <div class=\"destination\">2. Tokyo, Japan</div>
                  <p>Tokyo is a bustling metropolis blending modern technology with traditional culture. Don’t miss the Shibuya Crossing and the ancient temples!</p>

                  <div class=\"destination\">3. Rome, Italy</div>
                  <p>Rich in history, Rome offers attractions like the Colosseum, Roman Forum, and the Vatican City.</p>

                  <div class=\"button\">
                      <button onclick=\"alert('Happy travels and safe journey!')\">Start Your Journey</button>
                  </div>
              </body>
              </html>" > /var/www/html/index.html

              # Start and enable Nginx
              systemctl enable nginx
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
