FROM node:17-alpine3.14

RUN mkdir /app
WORKDIR /app

COPY ./package.json /app

RUN npm install


COPY . /app

ARG DB_PORT
ARG BACKEND_PORT

EXPOSE ${DB_PORT}
EXPOSE ${BACKEND_PORT}

CMD ["sh","-c", "node ./seeds.js ; node ./server.js"]