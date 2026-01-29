FROM node:18-alpine

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production

COPY index.js ./

ENTRYPOINT ["node", "index.js"]
