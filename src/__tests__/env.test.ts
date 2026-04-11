/**
 * Smoke tests for the env module.
 * Sets dummy required vars so the Zod schema parses successfully.
 */

beforeAll(() => {
  process.env.DATABASE_URL = 'postgresql://test:test@localhost:5432/testdb';
  process.env.OPENAI_API_KEY = 'sk-test-key';
  process.env.NODE_ENV = 'test';
});

describe('env module', () => {
  it('parses valid environment variables without throwing', () => {
    jest.isolateModules(() => {
      const { env } = require('../env');
      expect(env.DATABASE_URL).toBe('postgresql://test:test@localhost:5432/testdb');
      expect(env.OPENAI_API_KEY).toBe('sk-test-key');
      expect(env.NODE_ENV).toBe('test');
    });
  });

  it('exposes default PORT as 3000', () => {
    jest.isolateModules(() => {
      const { env } = require('../env');
      expect(env.PORT).toBe(3000);
    });
  });

  it('calls process.exit(1) when required env vars are missing', () => {
    const savedDB = process.env.DATABASE_URL;
    const savedKey = process.env.OPENAI_API_KEY;
    delete process.env.DATABASE_URL;
    delete process.env.OPENAI_API_KEY;

    const mockExit = jest.spyOn(process, 'exit').mockImplementationOnce(() => {
      throw new Error('process.exit(1) called');
    });

    jest.isolateModules(() => {
      expect(() => require('../env')).toThrow('process.exit(1) called');
    });

    process.env.DATABASE_URL = savedDB!;
    process.env.OPENAI_API_KEY = savedKey!;
    mockExit.mockRestore();
  });

  it('NODE_ENV is one of the accepted values', () => {
    const nodeEnv = process.env.NODE_ENV ?? 'development';
    expect(['development', 'staging', 'production', 'test']).toContain(nodeEnv);
  });
});
