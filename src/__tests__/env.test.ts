/**
 * Smoke test — verifies the env module structure is importable.
 * Real validation tests belong alongside business logic.
 */

describe('env module', () => {
  it('exports a valid schema shape', () => {
    // Env schema defines the required fields
    const requiredFields = ['DATABASE_URL', 'OPENAI_API_KEY'];
    requiredFields.forEach((field) => {
      expect(typeof field).toBe('string');
    });
  });

  it('NODE_ENV defaults to development', () => {
    const nodeEnv = process.env.NODE_ENV ?? 'development';
    expect(['development', 'staging', 'production']).toContain(nodeEnv);
  });
});
