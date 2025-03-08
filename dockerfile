FROM node:alpine

# Install git and other dependencies required for Hexo
RUN apk add --no-cache git bash openssh

# Install Hexo CLI globally
RUN npm install -g hexo-cli

# Initialize a new Hexo project and install cactus theme
RUN hexo init hexo

RUN cd hexo && \
    npm install && \
    git clone https://github.com/probberechts/hexo-theme-cactus.git themes/cactus && \
    rm -rf themes/cactus/.git

WORKDIR /hexo

EXPOSE 4000
