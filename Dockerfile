FROM node:26.5.0-bookworm-slim AS base

RUN npm install --global npm@12.0.2
RUN test "$(node --version)" = "v26.5.0" && test "$(npm --version)" = "12.0.2"

WORKDIR /repro

FROM base AS reported
COPY reported/package.json ./
RUN npm install

FROM base AS conflict
COPY conflict/package.json ./
RUN npm install

FROM base AS aligned
COPY aligned/package.json ./
RUN npm install

FROM base AS upstream-fix
COPY upstream-fix/.npmrc upstream-fix/package.json ./
RUN npm install
