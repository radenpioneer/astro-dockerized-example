FROM node:18.16.0-alpine AS base
RUN wget -qO- https://get.pnpm.io/install.sh | sh -

FROM base AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN exec sh && pnpm install --frozen-lockfile
COPY . .
RUN exec sh && pnpm run build

FROM nginx:1.24.0-alpine AS runtime
COPY ./.nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist /usr/share/nginx/html