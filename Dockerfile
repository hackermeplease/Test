FROM node:lts-buster-slim

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

COPY package*.json ./

# Use --omit=dev (modern equivalent of --production)
RUN npm install --omit=dev

COPY . .

ENV NODE_ENV=production
ENV PORT=7860

EXPOSE 7860

CMD ["npm", "start"]
