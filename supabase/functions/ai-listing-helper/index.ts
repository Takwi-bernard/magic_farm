import { askOpenAI, corsHeaders, languageInstruction } from "../shared/openai.ts";

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
      `You write short, honest, appealing marketplace listings for a farm-to-buyer app in Cameroon. Never invent facts the farmer didn't mention — no fake quantities, certifications, or origin claims. Output a short title line, then a 2-3 sentence description. ${languageInstruction(language ?? "en")}`;

    const userPrompt =
      `Category: ${category || "unspecified"}\nFarmer's rough description: ${description}\n\nWrite a clean listing title and description from this.`;

    const text = await askOpenAI(systemPrompt, userPrompt);

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