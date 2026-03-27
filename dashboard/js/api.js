const API = '/api';

async function api(path, options = {}) {
  const url = path.startsWith('http') ? path : `${API}${path}`;
  const config = { headers: { 'Content-Type': 'application/json' }, ...options };
  if (config.body && typeof config.body === 'object') {
    config.body = JSON.stringify(config.body);
  }
  const res = await fetch(url, config);
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || 'Request failed');
  return data;
}

async function apiGet(path) { return api(path); }
async function apiPost(path, body) { return api(path, { method: 'POST', body }); }
async function apiPut(path, body) { return api(path, { method: 'PUT', body }); }
async function apiDelete(path) { return api(path, { method: 'DELETE' }); }
