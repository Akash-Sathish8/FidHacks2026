const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');

const config = getDefaultConfig(__dirname);

// @anthropic-ai/sdk eagerly imports node:fs / node:path for credential file caching,
// which doesn't exist in the React Native runtime. Stub the imports so Metro can bundle.
const NODE_STUB = path.resolve(__dirname, 'src/lib/empty.js');
const CREDS_STUB = path.resolve(__dirname, 'src/lib/anthropic-creds-stub.js');
const NODE_STUBBED = new Set(['node:fs', 'node:path', 'node:os', 'fs', 'path', 'os']);

const origResolver = config.resolver.resolveRequest;
config.resolver.resolveRequest = (context, moduleName, platform) => {
  if (NODE_STUBBED.has(moduleName)) {
    return { type: 'sourceFile', filePath: NODE_STUB };
  }
  // Stub the SDK's credential-chain modules — they pull in node:fs at module load
  // and we authenticate with a plain API key, not OAuth/credential files.
  if (moduleName.includes('@anthropic-ai/sdk/lib/credentials')) {
    return { type: 'sourceFile', filePath: CREDS_STUB };
  }
  if (typeof origResolver === 'function') {
    return origResolver(context, moduleName, platform);
  }
  return context.resolveRequest(context, moduleName, platform);
};

module.exports = config;
