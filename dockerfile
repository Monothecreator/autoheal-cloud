# ---- Stage 1: Build ----
# Full Node image here (has npm, build tools) - this stage never ships.
FROM node:20-alpine AS build

WORKDIR /app

# Copy only manifests first so Docker caches the npm install layer
# and doesn't reinstall on every source change.
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Now copy source and build
COPY . .
RUN npm run build


# ---- Stage 2: Runtime ----
# Distroless: no shell, no package manager, no OS utilities.
# Drastically smaller attack surface than even alpine - if an attacker
# gets code execution, there's no `sh`, `curl`, or `apt` for them to use.
FROM gcr.io/distroless/nodejs20-debian12 AS runtime

WORKDIR /app

# Copy only what's needed to run - not the source, not devDependencies,
# not build tools. Ownership set to the distroless "nonroot" user (UID 65532).
COPY --from=build --chown=nonroot:nonroot /app/dist ./dist
COPY --from=build --chown=nonroot:nonroot /app/node_modules ./node_modules
COPY --from=build --chown=nonroot:nonroot /app/package.json ./package.json

# Distroless nodejs images already default to a non-root "nonroot" user,
# but being explicit is good practice and self-documenting.
USER nonroot

# Pin the exposed port explicitly - documents intent, doesn't affect security
# by itself but pairs with a NetworkPolicy / Service definition later.
EXPOSE 3000

# Distroless nodejs images use the node binary as ENTRYPOINT already,
# so CMD just supplies the arguments (the entry file).
CMD ["dist/server.js"]
