# Use official Ubuntu base image
FROM ubuntu:22.04

# Set environment variables
ENV APP_HOME=/app
WORKDIR $APP_HOME

# Install curl and Node.js LTS via Nodesource
RUN apt-get update && \
    apt-get install -y curl sudo gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && \
    apt-get install -y nodejs && \
    node -v && \
    npm -v

# Copy only necessary files to install dependencies
COPY package*.json ./

# Install production dependencies
RUN npm install --production

# Copy application code (excluding terraform and unnecessary files via .dockerignore)
COPY . .

# Expose the port your app listens on
EXPOSE 3000

# Run the app
CMD ["node", "app.js"]
