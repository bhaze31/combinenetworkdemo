FROM node:14-alpine3.13

RUN apk update

WORKDIR /combinedemo

COPY package*.json ./

COPY index.js index.js

RUN npm install

EXPOSE 8888

CMD ["npm", "start"]
