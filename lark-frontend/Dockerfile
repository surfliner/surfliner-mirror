# build stage
FROM node:10-alpine as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# production stage
FROM nginx:1.19-alpine as production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
