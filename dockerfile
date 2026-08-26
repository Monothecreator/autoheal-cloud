# ---- Stage 1: Build ----
FROM node:20-alpine AS build

WORKDIR /app

# Copy manifests
COPY package.json ./
RUN npm install --omit=dev && npm cache clean --force

# ---- Stage 2: Runtime ----
FROM gcr.io/distroless/nodejs20-debian12:nonroot

WORKDIR /app

# Copy runtime dependencies and app
COPY --from=build --chown=nonroot:nonroot /app/node_modules ./node_modules
COPY --from=build --chown=nonroot:nonroot /app/package.json ./package.json
COPY --chown=nonroot:nonroot src ./src

USER nonroot
EXPOSE 3000
CMD ["src/server.js"]
