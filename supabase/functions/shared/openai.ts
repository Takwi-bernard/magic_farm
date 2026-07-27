// Shared by all 4 AI edge functions. Supabase deploys everything
// under supabase/functions/ — files in _shared/ aren't deployed as
// their own function, they're just imported by the real ones.

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const LANGUAGE_NAMES: Record<string, string> = {
  en: "English",
  fr: "French",
};

// This is the actual fix for "a French-speaking user got an English
// answer" — every function's system prompt includes this line, built
// from whatever language code the app sends.
export function languageInstruction(languageCode: string): string {
  const name = LANGUAGE_NAMES[languageCode] ?? "English";
  return `Respond only in ${name}. Do not mix languages, even if the input is written in a different language.`;
}

export async function askOpenAI(
  systemPrompt: string,
  userPrompt: string,
): Promise<string> {
  const apiKey = Deno.env.get("OPENAI_API_KEY");

  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is not configured on this function.");
  }

  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      // gpt-4o-mini: deliberately the cheaper/faster tier. These are
      // short, well-grounded requests, not deep reasoning tasks — no
      // need to pay for a heavier model here. Revisit only if
      // response quality genuinely isn't good enough.
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt },
      ],
      temperature: 0.6,
    }),
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`OpenAI request failed: ${errText}`);
  }

  const data = await res.json();
  return (data.choices?.[0]?.message?.content ?? "").trim();
}