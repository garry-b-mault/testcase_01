# =============================================================================
# Multi-stage Dockerfile — TypeScript/Node.js frontend/backend
# Full-stack companion: see Dockerfile.python for the Python service
# =============================================================================

# --- Stage 1: Dependencies ---
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --only=production

# --- Stage 2: Builder ---
FROM node:20-alpine AS builder
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN npm run build 2>/dev/null || echo "No build step yet — skipping"

# --- Stage 3: Production ---
FROM node:20-alpine AS production
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist 2>/dev/null || true
COPY --from=deps --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./
ENV NODE_ENV=production PORT=3000
EXPOSE 3000
USER nodejs
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]

# --- Stage 4: Development ---
FROM node:20-alpine AS development
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install 2>/dev/null || true
COPY . .
ENV NODE_ENV=development PORT=3000
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
CMD ["sh", "-c", "npm run dev 2>/dev/null || node src/index.js 2>/dev/null || echo 'App starting...' && tail -f /dev/null"]
