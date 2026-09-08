// Renew only known synthetic fixture sessions; never print their tokens.
const fs = require('node:fs');
async function main() {
  const path = '/tmp/vips-ui-config.json';
  const config = JSON.parse(fs.readFileSync(path, 'utf8'));
  const merchant = process.argv.includes('--merchant');
  const role = merchant ? 'merchant' : 'customer';
  if (!['127.0.0.1', 'localhost'].includes(new URL(config.API_BASE_URL).hostname)) {
    throw new Error('UI verification requires a loopback API');
  }
  const response = await fetch(`${config.API_BASE_URL}/auth/login`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: `${role}@vips.test`, password: 'UiTest123!' }),
  });
  const result = await response.json();
  if (!response.ok || !result.data?.token) throw new Error(`Synthetic ${role} sign-in failed`);
  config.QA_TOKEN = result.data.token;
  config.QA_ROUTES = process.argv.slice(2).find(arg => arg.startsWith('/')) || '';
  fs.writeFileSync(merchant ? '/tmp/vips-merchant-ui-config.json' : path,
    JSON.stringify(config), { mode: 0o600 });
  console.log(`Synthetic ${role} session renewed; local UI configuration updated.`);
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
