FROM node:18.16.0-alpine AS base
RUN apk update && apk add --no-cache libc6-compat
RUN npm i -g pnpm

FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY package.json pnpm-lock.yaml ./
COPY . .
RUN pnpm run build

FROM nginx:1.31.7-alpine-slim@sha256:ebd058041a732a2b2dc0b606e34572dd8e0034de6a4aa4d50d8c13a240ac6005 AS runtime
COPY ./.nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80