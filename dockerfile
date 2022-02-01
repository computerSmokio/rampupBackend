FROM node:17-alpine3.14

WORKDIR /usr/src/app

COPY ./package.json /usr/src/app/

RUN npm install

COPY ./* /usr/src/app/

ARG DB_PORT
ARG BACKEND_PORT

EXPOSE ${DB_PORT}
EXPOSE ${BACKEND_PORT}

CMD ["sh","-c", "node ./seeds.js ; node ./server.js"]