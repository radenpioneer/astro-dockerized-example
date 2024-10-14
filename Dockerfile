FROM node:20.18.0-alpine@sha256:c13b26e7e602ef2f1074aef304ce6e9b7dd284c419b35d89fcf3cc8e44a8def9 AS base
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

FROM nginx:1.24.0-alpine-slim AS runtime
COPY ./.nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80