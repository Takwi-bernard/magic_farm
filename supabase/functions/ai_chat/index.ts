import { askOpenAI, corsHeaders, languageInstruction } from "../shared/openai.ts";

// Real facts about the app, so the assistant can help someone
// actually use Magic Farm — not just talk about farming in the
// abstract. Keep this updated as real features ship; the instruction
// below tells the model not to invent anything beyond this list.
const APP_HELP_CONTEXT = `
Facts about the Magic Farm app (use only these — never invent features):
- Magic Farm connects farmers and buyers in Cameroon directly, so farmers can know demand before harvesting instead of guessing.
- Farmers can create listings for their produce. Buyers can browse listings and message a farmer to arrange purchase and pickup.
- The app works offline for browsing already-loaded content. Posting, chat, and AI features need an internet connection.
- Sign-in is by email/password or Google. Once signed in, the app remembers you — no need to sign in every time.
- The app supports English and French.
If asked how to use the app, answer only using these facts. If unsure, say so honestly rather than guessing.
`;

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
      `You are the Magic Farm assistant, helping farmers and buyers in Cameroon. Many users are using a smartphone app for the first time, so be warm, simple, and clear — short sentences, no jargon. ${languageInstruction(language ?? "en")}\n\n${APP_HELP_CONTEXT}`;

    const text = await askOpenAI(systemPrompt, message);

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