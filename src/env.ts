/**
 * Environment variable validation — fails fast if required vars are missing.
 * Import this at your app entry point before any other imports.
 *
 * Install zod: npm install zod
 */
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(3000),
  HOST: z.string().default('localhost'),
  LOG_LEVEL: z.string().default('info'),

  // Required: app will throw on startup if these are missing
  DATABASE_URL: z.string().url('DATABASE_URL must be a valid connection URL'),
  OPENAI_API_KEY: z.string().min(1, 'OPENAI_API_KEY is required'),
});

export type Env = z.infer<typeof envSchema>;

const result = envSchema.safeParse(process.env);

if (!result.success) {
  console.error('❌ Invalid environment variables:');
  result.error.issues.forEach((issue) => {
    console.error(`  ${issue.path.join('.')}: ${issue.message}`);
  });
  process.exit(1);
}

export const env: Env = result.data;
