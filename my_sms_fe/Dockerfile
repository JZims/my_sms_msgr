# syntax=docker/dockerfile:1
# Dockerfile for Angular frontend (my_sms_fe)

FROM node:lts-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN npm run build -- --output-path=dist

FROM node:lts-alpine AS dev
WORKDIR /app
COPY --from=build /app .
EXPOSE 4200
CMD ["npx", "ng", "serve", "--host", "0.0.0.0", "--port", "4200"]
