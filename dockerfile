FROM node:16-alpine

WORKDIR /app

COPY ./package.json /app

RUN npm install

COPY . /app

ARG BACKEND_PORT=3000

EXPOSE ${BACKEND_PORT}

CMD ["sh","-c", "node ./seeds.js ; node ./server.js"]