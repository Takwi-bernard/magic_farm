import { askAI, corsHeaders, languageInstruction } from "../shared/ai.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { description, category, language } = await req.json();

    if (!description || typeof description !== "string") {
      return new Response(
        JSON.stringify({ error: "description is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const systemPrompt =
      `You write short, honest, appealing marketplace listings for a farm-to-buyer app in Cameroon. Never invent facts the farmer didn't mention — no fake quantities, certifications, or origin claims. Output ONLY a JSON object with exactly two keys: "title" (a short, appealing product title, under 8 words) and "description" (2-3 sentences). No markdown, no extra text, no keys other than those two. ${languageInstruction(language ?? "en")}`;

    const userPrompt =
      `Category: ${category || "unspecified"}\nFarmer's rough description: ${description}\n\nWrite the listing.`;

    const text = await askAI(systemPrompt, userPrompt, { jsonMode: true });

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