// React Native stub for @anthropic-ai/sdk/lib/credentials/*.
// We authenticate with a plain API key passed to `new Anthropic({ apiKey })`,
// so none of the credential-file / OAuth / OIDC code paths are used.
// These named exports cover what client.mjs imports.

const noop = () => {};
const asyncNoop = async () => null;

// types.mjs exports
const OAUTH_API_BETA_HEADER = 'oauth-2025-04-20';
const FEDERATION_BETA_HEADER = 'oidc-federation-2026-04-01';
const GRANT_TYPE_JWT_BEARER = 'urn:ietf:params:oauth:grant-type:jwt-bearer';
const GRANT_TYPE_REFRESH_TOKEN = 'refresh_token';
const TOKEN_ENDPOINT = '/v1/oauth/token';
const ADVISORY_REFRESH_THRESHOLD_IN_SECONDS = 120;
const MANDATORY_REFRESH_THRESHOLD_IN_SECONDS = 30;
const ADVISORY_REFRESH_BACKOFF_IN_SECONDS = 5;
const requireSecureTokenEndpoint = noop;

// token-cache.mjs
class TokenCache {
  constructor() {}
  get() { return null; }
  set() {}
  clear() {}
}

// credential-chain.mjs
const defaultCredentials = null;
const resolveCredentialsFromConfig = asyncNoop;

module.exports = {
  __esModule: true,
  OAUTH_API_BETA_HEADER,
  FEDERATION_BETA_HEADER,
  GRANT_TYPE_JWT_BEARER,
  GRANT_TYPE_REFRESH_TOKEN,
  TOKEN_ENDPOINT,
  ADVISORY_REFRESH_THRESHOLD_IN_SECONDS,
  MANDATORY_REFRESH_THRESHOLD_IN_SECONDS,
  ADVISORY_REFRESH_BACKOFF_IN_SECONDS,
  requireSecureTokenEndpoint,
  TokenCache,
  defaultCredentials,
  resolveCredentialsFromConfig,
  default: {},
};
