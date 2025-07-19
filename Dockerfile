FROM node:lts-buster-slim

# 1. Fix package sources first
RUN echo "deb http://archive.debian.org/debian buster main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list

# 2. Install dependencies with retry logic
RUN apt-get update -o Acquire::Retries=3 && \
    apt-get install -y --no-install-recommends \
    ffmpeg \
    imagemagick \
    webp \
    wget \
    gnupg \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY . .

ENV NODE_ENV=production
ENV PORT=7860
EXPOSE 7860

CMD ["node", "index.js"]
