# ---- Stage 1: Build ----
FROM node:20-alpine AS builder
ENV NEXT_TELEMETRY_DISABLED=1
WORKDIR /app

# Copy manifests and install (reproducible if lock is in sync)
COPY package*.json ./
RUN npm ci || (echo "Lockfile out of sync, falling back to npm install" && npm install)

# Copy source
COPY . .

# Build-time public env (do not pass secrets here)
ARG NEXT_PUBLIC_SANITY_DATASET
ARG NEXT_PUBLIC_SANITY_PROJECT_ID
ENV NEXT_PUBLIC_SANITY_DATASET=$NEXT_PUBLIC_SANITY_DATASET \
    NEXT_PUBLIC_SANITY_PROJECT_ID=$NEXT_PUBLIC_SANITY_PROJECT_ID 

# Build Next.js
RUN npm run build

# Prune dev deps to keep runtime small
RUN npm prune --omit=dev

# ---- Stage 2: Runtime ----
FROM node:20-alpine AS runner
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1
WORKDIR /app

# Non-root user
RUN addgroup -S nodejs && adduser -S nextjs -G nodejs

# Copy production node_modules, package.json & Next artifacts
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/next.config.js ./next.config.js
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next

EXPOSE 3000
USER nextjs

# Use Next's production server
CMD ["npm", "start"]


