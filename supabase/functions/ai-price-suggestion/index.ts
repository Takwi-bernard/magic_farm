import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { askOpenAI, corsHeaders, languageInstruction } from "../shared/openai.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { product_name, category, language } = await req.json();

    if (!product_name || typeof product_name !== "string") {
      return new Response(
        JSON.stringify({ error: "product_name is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Same placeholder schema note as demand-forecast — adjust column
    // names once your real products table exists.
    const { data, error } = await supabase
      .from("products")
      .select("price")
      .ilike("name", `%${product_name}%`)
      .order("created_at", { ascending: false })
      .limit(30);

    if (error) throw error;

    const prices = (data ?? [])
      .map((d: any) => d.price)
      .filter((p: unknown) => typeof p === "number");

    const dataSummary =
      prices.length > 0
        ? `Recent prices for similar listings (FCFA): ${prices.join(", ")}`
        : `No recent price data found for "${product_name}" in category "${category || "unspecified"}".`;

    // Financial stakes are real here — this deliberately asks for a
    // reasoned range and explanation, not a single confident number,
    // matching the same caution used for financial info elsewhere.
    const systemPrompt =
      `You help farmers in Cameroon think through fair pricing. You are not a financial advisor. Present a reasoned price range based only on the real data given below, briefly explain your reasoning, and let the farmer make the final decision. Never invent a price not derivable from the data. If there's no data, say so clearly and suggest a cautious approach instead of naming a number. ${languageInstruction(language ?? "en")}`;

    const userPrompt =
      `Product: ${product_name}\nCategory: ${category || "unspecified"}\n${dataSummary}\n\nSuggest a fair price range and briefly explain why.`;

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