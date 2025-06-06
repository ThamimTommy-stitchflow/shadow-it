# 1. Install dependencies only when needed
FROM node:18-alpine AS deps
# Enable corepack for pnpm, yarn, etc.
RUN corepack enable
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
# Choose your package manager
RUN npm ci
# Or: RUN yarn install --frozen-lockfile
# Or: RUN pnpm install --frozen-lockfile

# 2. Rebuild the source code only when needed
FROM node:18-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED 1

# ARG for build-time substitution variables from Cloud Build
ARG _NEXT_PUBLIC_SUPABASE_URL
ARG _NEXT_PUBLIC_SUPABASE_ANON_KEY
ARG _SUPABASE_SERVICE_ROLE_KEY
ARG _LOOPS_API_KEY
ARG _NEW_APP_TEMPLATE_ID
ARG _NEW_USER_TEMPLATE_ID
ARG _NEW_USER_REVIEW_TEMPLATE_ID
ARG _ADMIN_KEY
ARG _CRON_SECRET
ARG _GOOGLE_CLIENT_ID
ARG _GOOGLE_CLIENT_SECRET
ARG _GOOGLE_REDIRECT_URI
ARG _NEXT_PUBLIC_MICROSOFT_CLIENT_ID
ARG _MICROSOFT_CLIENT_SECRET
ARG _NEXT_PUBLIC_MICROSOFT_REDIRECT_URI
ARG _MICROSOFT_TENANT_ID
ARG _LOOPS_TRANSACTIONAL_ID_FAILED_SIGNUP
ARG _LOOPS_TRANSACTIONAL_ID_SYNC_COMPLETED

RUN echo "Build-time _NEXT_PUBLIC_SUPABASE_URL: ${_NEXT_PUBLIC_SUPABASE_URL}"
RUN echo "Build-time _NEXT_PUBLIC_SUPABASE_ANON_KEY: ${_NEXT_PUBLIC_SUPABASE_ANON_KEY}"
RUN echo "Build-time _SUPABASE_SERVICE_ROLE_KEY: ${_SUPABASE_SERVICE_ROLE_KEY}"
RUN echo "Build-time _LOOPS_API_KEY: ${_LOOPS_API_KEY}"
RUN echo "Build-time _NEW_APP_TEMPLATE_ID: ${_NEW_APP_TEMPLATE_ID}"
RUN echo "Build-time _NEW_USER_TEMPLATE_ID: ${_NEW_USER_TEMPLATE_ID}"
RUN echo "Build-time _NEW_USER_REVIEW_TEMPLATE_ID: ${_NEW_USER_REVIEW_TEMPLATE_ID}"
RUN echo "Build-time _ADMIN_KEY: ${_ADMIN_KEY}"
RUN echo "Build-time _CRON_SECRET: ${_CRON_SECRET}"
RUN echo "Build-time _GOOGLE_CLIENT_ID: ${_GOOGLE_CLIENT_ID}"
RUN echo "Build-time _GOOGLE_CLIENT_SECRET: ${_GOOGLE_CLIENT_SECRET}"
RUN echo "Build-time _GOOGLE_REDIRECT_URI: ${_GOOGLE_REDIRECT_URI}"
RUN echo "Build-time _NEXT_PUBLIC_MICROSOFT_CLIENT_ID: ${_NEXT_PUBLIC_MICROSOFT_CLIENT_ID}"
RUN echo "Build-time _MICROSOFT_CLIENT_SECRET: ${_MICROSOFT_CLIENT_SECRET}"
RUN echo "Build-time _NEXT_PUBLIC_MICROSOFT_REDIRECT_URI: ${_NEXT_PUBLIC_MICROSOFT_REDIRECT_URI}"
RUN echo "Build-time _MICROSOFT_TENANT_ID: ${_MICROSOFT_TENANT_ID}"
RUN echo "Build-time _LOOPS_TRANSACTIONAL_ID_FAILED_SIGNUP: ${_LOOPS_TRANSACTIONAL_ID_FAILED_SIGNUP}"
RUN echo "Build-time _LOOPS_TRANSACTIONAL_ID_SYNC_COMPLETED: ${_LOOPS_TRANSACTIONAL_ID_SYNC_COMPLETED}"

# Set them as environment variables for the build process
ENV NEXT_PUBLIC_SUPABASE_URL=${_NEXT_PUBLIC_SUPABASE_URL}
ENV NEXT_PUBLIC_SUPABASE_ANON_KEY=${_NEXT_PUBLIC_SUPABASE_ANON_KEY}
ENV SUPABASE_SERVICE_ROLE_KEY=${_SUPABASE_SERVICE_ROLE_KEY}
ENV LOOPS_API_KEY=${_LOOPS_API_KEY}
ENV NEW_APP_TEMPLATE_ID=${_NEW_APP_TEMPLATE_ID}
ENV NEW_USER_TEMPLATE_ID=${_NEW_USER_TEMPLATE_ID}
ENV NEW_USER_REVIEW_TEMPLATE_ID=${_NEW_USER_REVIEW_TEMPLATE_ID}
ENV ADMIN_KEY=${_ADMIN_KEY}
ENV CRON_SECRET=${_CRON_SECRET}
ENV GOOGLE_CLIENT_ID=${_GOOGLE_CLIENT_ID}
ENV GOOGLE_CLIENT_SECRET=${_GOOGLE_CLIENT_SECRET}
ENV GOOGLE_REDIRECT_URI=${_GOOGLE_REDIRECT_URI}
ENV NEXT_PUBLIC_MICROSOFT_CLIENT_ID=${_NEXT_PUBLIC_MICROSOFT_CLIENT_ID}
ENV MICROSOFT_CLIENT_SECRET=${_MICROSOFT_CLIENT_SECRET}
ENV NEXT_PUBLIC_MICROSOFT_REDIRECT_URI=${_NEXT_PUBLIC_MICROSOFT_REDIRECT_URI}
ENV MICROSOFT_TENANT_ID=${_MICROSOFT_TENANT_ID}
ENV LOOPS_TRANSACTIONAL_ID_FAILED_SIGNUP=${_LOOPS_TRANSACTIONAL_ID_FAILED_SIGNUP}
ENV LOOPS_TRANSACTIONAL_ID_SYNC_COMPLETED=${_LOOPS_TRANSACTIONAL_ID_SYNC_COMPLETED}

# ENV NEXT_PUBLIC_SOME_VARIABLE=${NEXT_PUBLIC_SOME_VARIABLE}

# Add these lines for debugging:
RUN echo "Build-time NEXT_PUBLIC_SUPABASE_URL: ${NEXT_PUBLIC_SUPABASE_URL}"
RUN echo "Build-time NEXT_PUBLIC_SUPABASE_ANON_KEY: ${NEXT_PUBLIC_SUPABASE_ANON_KEY}"
RUN echo "Build-time SUPABASE_SERVICE_ROLE_KEY: ${SUPABASE_SERVICE_ROLE_KEY}"
RUN echo "Build-time LOOPS_API_KEY: ${LOOPS_API_KEY}"
RUN echo "Build-time NEW_APP_TEMPLATE_ID: ${NEW_APP_TEMPLATE_ID}"
RUN echo "Build-time NEW_USER_TEMPLATE_ID: ${NEW_USER_TEMPLATE_ID}"
RUN echo "Build-time NEW_USER_REVIEW_TEMPLATE_ID: ${NEW_USER_REVIEW_TEMPLATE_ID}"
RUN echo "Build-time ADMIN_KEY: ${ADMIN_KEY}"
RUN echo "Build-time CRON_SECRET: ${CRON_SECRET}"
RUN echo "Build-time GOOGLE_CLIENT_ID: ${GOOGLE_CLIENT_ID}"
RUN echo "Build-time GOOGLE_CLIENT_SECRET: ${GOOGLE_CLIENT_SECRET}"
RUN echo "Build-time GOOGLE_REDIRECT_URI: ${GOOGLE_REDIRECT_URI}"
RUN echo "Build-time NEXT_PUBLIC_MICROSOFT_CLIENT_ID: ${NEXT_PUBLIC_MICROSOFT_CLIENT_ID}"
RUN echo "Build-time MICROSOFT_CLIENT_SECRET: ${MICROSOFT_CLIENT_SECRET}"
RUN echo "Build-time NEXT_PUBLIC_MICROSOFT_REDIRECT_URI: ${NEXT_PUBLIC_MICROSOFT_REDIRECT_URI}"
RUN echo "Build-time MICROSOFT_TENANT_ID: ${MICROSOFT_TENANT_ID}"
RUN echo "Build-time LOOPS_TRANSACTIONAL_ID_FAILED_SIGNUP: ${LOOPS_TRANSACTIONAL_ID_FAILED_SIGNUP}"
RUN echo "Build-time LOOPS_TRANSACTIONAL_ID_SYNC_COMPLETED: ${LOOPS_TRANSACTIONAL_ID_SYNC_COMPLETED}"
# End of debug lines

RUN npm run build
# Or: yarn build
# Or: pnpm build

# 3. Production image, copy all the files and run next
FROM node:18-alpine AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

# server.js is created by standalone output
CMD ["node", "server.js"]