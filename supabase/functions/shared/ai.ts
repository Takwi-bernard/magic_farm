// Shared by all 4 AI edge functions.

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const LANGUAGE_NAMES: Record<string, string> = {
  en: "English",
  fr: "French",
};

export function languageInstruction(languageCode: string): string {
  const name = LANGUAGE_NAMES[languageCode] ?? "English";
  return `Respond only in ${name}. Do not mix languages, even if the input is written in a different language.`;
}

// Was "gemini-2.5-flash" — Google retired that model for new users
// (confirmed via the actual error this project hit: "This model
// models/gemini-2.5-flash is no longer available to new users").
// gemini-3.5-flash is the current free-tier model as of August 2026.
// If this ever breaks again the same way, the fix is always just
// this one line — everything else in this file, and all 4 functions
// that use it, stay the same.
const MODEL = "gemini-3.5-flash";
const BASE_URL =
  `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`;

function apiKey(): string {
  const key = Deno.env.get("GEMINI_API_KEY");
  if (!key) {
    throw new Error("GEMINI_API_KEY is not configured on this function.");
  }
  return key;
}

export async function askAI(
  systemPrompt: string,
  userPrompt: string,
  opts?: { jsonMode?: boolean },
): Promise<string> {
  const body: Record<string, unknown> = {
    system_instruction: { parts: [{ text: systemPrompt }] },
    contents: [{ role: "user", parts: [{ text: userPrompt }] }],
    generationConfig: {
      temperature: 0.6,
      ...(opts?.jsonMode ? { responseMimeType: "application/json" } : {}),
    },
  };

  const res = await fetch(`${BASE_URL}?key=${apiKey()}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    throw new Error(`Gemini request failed: ${await res.text()}`);
  }

  const data = await res.json();
  const text = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
  return text.trim();
}

export function geminiUrl(): string {
  return `${BASE_URL}?key=${apiKey()}`;
}