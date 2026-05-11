import Anthropic from '@anthropic-ai/sdk';

const apiKey = process.env.EXPO_PUBLIC_ANTHROPIC_API_KEY;

let client: Anthropic | null = null;

function getClient() {
  if (!apiKey) return null;
  if (!client) {
    client = new Anthropic({
      apiKey,
      // RN environments don't have the browser warning helper; opt-in.
      dangerouslyAllowBrowser: true,
    });
  }
  return client;
}

export interface ChatMessage {
  role: 'user' | 'assistant';
  content: string;
}

export interface SendOpts {
  system: string;
  messages: ChatMessage[];
  maxTokens?: number;
}

export async function sendMessage({ system, messages, maxTokens = 600 }: SendOpts): Promise<string> {
  const c = getClient();
  if (!c) {
    return mockResponse(messages);
  }
  const res = await c.messages.create({
    model: 'claude-sonnet-4-6',
    max_tokens: maxTokens,
    system,
    messages: messages.map((m) => ({ role: m.role, content: m.content })),
  });
  const text = res.content
    .map((block) => (block.type === 'text' ? block.text : ''))
    .join('')
    .trim();
  return text || "Hmm — let's try that again.";
}

function mockResponse(messages: ChatMessage[]): string {
  const last = messages[messages.length - 1]?.content.toLowerCase() ?? '';
  if (last.includes('salary') || last.includes('offer') || last.includes('pay')) {
    return "Thanks for sharing that offer. Based on market data for similar roles, the range tends to be $X–$Y. What number were you thinking of countering with, and what's your reasoning?";
  }
  if (last.includes('benefit') || last.includes('401k') || last.includes('health')) {
    return "Great question. Beyond base salary, the real value of a comp package is in benefits — 401(k) match, equity vesting schedules, healthcare premiums, PTO. Which of these would you like to break down first?";
  }
  if (last.includes('start') || last === '' || last.length < 5) {
    return "Hi! I'm your Money Moves coach. Let's role-play your first salary negotiation. Tell me about the offer you got — role, company, base salary?";
  }
  return "That's a strong opening. Now think about anchoring — what's the highest reasonable number you can justify, and what's your walk-away? Try drafting your counter in one sentence.";
}

export const isAIConnected = () => Boolean(apiKey);
