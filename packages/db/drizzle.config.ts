import type { Config } from "drizzle-kit";

export default {
  dialect: "postgresql",
  schema: "./src/schema.ts",
  out: "./drizzle",
  dbCredentials: {
    url: "postgresql://default:L2puKFJZsxN6@ep-restless-queen-a4h7rxdn-pooler.us-east-1.aws.neon.tech/verceldb?sslmode=require"
  },
} satisfies Config;
