# Use official Node.js LTS on Debian Buster
FROM node:lts-buster-slim

# Set working directory
WORKDIR /app

# Install system dependencies (fixed formatting and removed --allow-unauthenticated)
RUN echo "deb http://archive.debian.org/debian buster main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y \
    ffmpeg \
    imagemagick \
    webp \
    wget \
    gnupg \
    git \
    ca-certificates && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable \
    fonts-freefont-ttf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Only copy package files first for better layer caching
COPY package*.json ./

# For private repositories - choose either HTTPS or SSH method:

# OPTION 1: If using HTTPS (recommended for public repos)
RUN npm config set @your-org:registry=https://npm.pkg.github.com && \
    npm install

# OPTION 2: If using SSH (for private repos)
# ARG SSH_PRIVATE_KEY
# RUN mkdir -p ~/.ssh && \
#     echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa && \
#     chmod 600 ~/.ssh/id_rsa && \
#     ssh-keyscan github.com >> ~/.ssh/known_hosts && \
#     npm install

# Copy app source
COPY . .

# Expose port
EXPOSE 7860

# Run application
CMD ["npm", "start"]
