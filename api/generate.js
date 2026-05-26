export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: { message: 'Method not allowed' } });

  const { prompt, apiKey } = req.body || {};

  if (!prompt) return res.status(400).json({ error: { message: 'No prompt provided' } });
  if (!apiKey) return res.status(400).json({ error: { message: 'No API key provided. Go to Admin Panel → Settings to add your Anthropic key.' } });
  if (!apiKey.startsWith('sk-ant')) return res.status(400).json({ error: { message: 'Invalid API key format. Should start with sk-ant-...' } });

  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-opus-4-5',
        max_tokens: 2000,
        messages: [{ role: 'user', content: prompt }]
      })
    });

    const data = await response.json();

    if (!response.ok) {
      return res.status(response.status).json({
        error: { message: data.error?.message || 'Anthropic API error: ' + response.status }
      });
    }

    return res.status(200).json(data);
  } catch (err) {
    return res.status(500).json({ error: { message: 'Server error: ' + (err.message || 'Unknown') } });
  }
}
