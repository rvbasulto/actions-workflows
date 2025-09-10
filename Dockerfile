# ---- Stage 1: Build ----
FROM node:20-alpine AS builder
ENV NEXT_TELEMETRY_DISABLED=1
WORKDIR /app

# Copy manifests
COPY package*.json ./

# Prefer reproducible install; fallback if lockfile is out of sync
RUN npm ci || (echo "Lockfile out of sync, falling back to npm install" && npm install)

# Copy source code
COPY . .

# Public build-time env (do not pass secrets here)
ARG NEXT_PUBLIC_SANITY_DATASET
ARG NEXT_PUBLIC_SANITY_PROJECT_ID
ENV NEXT_PUBLIC_SANITY_DATASET=$NEXT_PUBLIC_SANITY_DATASET \
    NEXT_PUBLIC_SANITY_PROJECT_ID=$NEXT_PUBLIC_SANITY_PROJECT_ID

# Build Next.js (standalone output)
RUN npm run build

# ---- Stage 2: Runtime ----
FROM node:20-alpine AS runner
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1
WORKDIR /app

# Non-root user
RUN addgroup -S nodejs && adduser -S nextjs -G nodejs

# Copy minimal runtime
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 3000
USER nextjs
CMD ["node", "server.js"]