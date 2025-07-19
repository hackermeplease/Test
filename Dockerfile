FROM node:lts-buster-slim

# Set working directory
WORKDIR /app

# Install system dependencies
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

# Copy package files
COPY package*.json ./

# Solution 1: For public repositories (recommended)
# Force HTTPS and disable strict SSL if behind corporate proxy
RUN git config --global url."https://github.com/".insteadOf "ssh://git@github.com/" && \
    git config --global url."https://".insteadOf "git://" && \
    npm config set strict-ssl false && \
    npm install

# Solution 2: For private repositories requiring authentication
# RUN git config --global url."https://github.com/".insteadOf "ssh://git@github.com/" && \
#     git config --global url."https://${GITHUB_TOKEN}:x-oauth-basic@github.com/".insteadOf "https://github.com/" && \
#     npm install

# Copy app source
COPY . .

EXPOSE 7860
CMD ["npm", "start"]
