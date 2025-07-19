# Use official Node.js LTS image
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
    ca-certificates \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-freefont-ttf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy package files (for better layer caching)
COPY package*.json ./

# Install npm dependencies
RUN npm install --production

# Copy app source
COPY . .

# Set environment variables (adjust as needed)
ENV NODE_ENV=production
ENV PORT=7860

# Expose port
EXPOSE 7860

# Start command (matches package.json)
CMD ["npm", "start"]
