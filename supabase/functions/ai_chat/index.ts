import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, geminiUrl, languageInstruction } from "../shared/ai.ts";

const APP_HELP_CONTEXT = `
Facts about the Magic Farm app (use only these — never invent features):
- Magic Farm connects farmers and buyers in Cameroon directly, so farmers can know demand before harvesting instead of guessing.
- Farmers can create listings for their produce. Buyers can browse listings and message a farmer to arrange purchase and pickup.
- The app works offline for browsing already-loaded content. Posting, chat, and AI features need an internet connection.
- Sign-in is by email/password or Google. Once signed in, the app remembers you — no need to sign in every time.
- The app supports English and French.
If asked how to use the app, answer only using these facts. If unsure, say so honestly rather than guessing.
`;

const TOOLS = [
  {
    functionDeclarations: [
      {
        name: "search_products",
        description:
          "Search Magic Farm's real, currently active product listings by keyword. Use this whenever the user asks about buying, finding, or the price/availability of a specific crop or product — never guess or invent listings.",
        parameters: {
          type: "object",
          properties: {
            query: {
              type: "string",
              description:
                "Product name or keyword to search for, e.g. 'corn', 'tomatoes'",
            },
          },
          required: ["query"],
        },
      },
    ],
  },
];

async function searchProducts(supabase: any, query: string) {
  const { data, error } = await supabase
    .from("products")
    .select("title, price, status")
    .eq("status", "active")
    .ilike("title", `%${query}%`)
    .limit(5);

  if (error) return { error: error.message };
  if (!data || data.length === 0) {
    return { results: [], note: "No active listings matched this search." };
  }

  return {
    results: data.map((p: any) => ({ title: p.title, price: p.price })),
  };
}

async function callGemini(systemPrompt: string, contents: any[], tools?: any) {
  const res = await fetch(geminiUrl(), {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      system_instruction: { parts: [{ text: systemPrompt }] },
      contents,
      ...(tools ? { tools } : {}),
      generationConfig: { temperature: 0.6 },
    }),
  });

  if (!res.ok) throw new Error(`Gemini request failed: ${await res.text()}`);
  return res.json();
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { message, language } = await req.json();

    if (!message || typeof message !== "string") {
      return new Response(
        JSON.stringify({ error: "message is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const systemPrompt =
      `You are the Magic Farm assistant, helping farmers and buyers in Cameroon. Many users are using a smartphone app for the first time, so be warm, simple, and clear — short sentences, no jargon. When you use the search_products tool, base your answer only on the real results it returns — never add prices or listings it didn't give you. ${languageInstruction(language ?? "en")}\n\n${APP_HELP_CONTEXT}`;

    // Explicitly annotate as any[] to avoid deno-ts(2353) property inference errors
    const contents: any[] = [{ role: "user", parts: [{ text: message }] }];

    // Turn 1: Send user query to Gemini
    const first = await callGemini(systemPrompt, contents, TOOLS);
    const part = first.candidates?.[0]?.content?.parts?.[0];

    if (!part?.functionCall) {
      // Direct text response from Gemini
      const text = (part?.text ?? "").trim();
      return new Response(JSON.stringify({ text }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Function call requested: execute database query
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const args = part.functionCall.args ?? {};
    const result = await searchProducts(supabase, args.query ?? "");

    // Turn 2: Append function execution state to contents
    contents.push({
      role: "model",
      parts: [{ functionCall: part.functionCall }],
    });

    contents.push({
      role: "function",
      parts: [
        {
          functionResponse: {
            name: "search_products",
            response: {
              name: "search_products",
              content: result,
            },
          },
        },
      ],
    });

    // Send context back to Gemini to complete answer generation
    const second = await callGemini(systemPrompt, contents, TOOLS);
    const text = (second.candidates?.[0]?.content?.parts?.[0]?.text ?? "").trim();

    return new Response(JSON.stringify({ text }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});