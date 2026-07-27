import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { askOpenAI, corsHeaders, languageInstruction } from "../shared/openai.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { product_name, language } = await req.json();

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
      // Service role key — this function runs server-side only, never
      // exposed to the app, so it's safe to use here (unlike the
      // anon key, this bypasses RLS, which is fine for read-only
      // aggregation like this).
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // NOTE: placeholder query against a "products" table with
    // name/price/created_at columns — adjust once your real
    // Home/Market schema exists. The point stands regardless of exact
    // column names: pull real history, never let the model guess.
    const { data, error } = await supabase
      .from("products")
      .select("price, created_at")
      .ilike("name", `%${product_name}%`)
      .order("created_at", { ascending: false })
      .limit(20);

    if (error) throw error;

    const dataSummary =
      data && data.length > 0
        ? `Found ${data.length} recent listings for "${product_name}". Prices ranged from ${Math.min(...data.map((d: any) => d.price))} to ${Math.max(...data.map((d: any) => d.price))} FCFA.`
        : `No recent listing history found for "${product_name}" yet.`;

    const systemPrompt =
      `You are an agricultural demand assistant for farmers in Cameroon. You are given real recent marketplace data below — use only this data, never invent numbers or trends not shown here. If there isn't enough data, say so honestly rather than guessing, and suggest checking back once more listings exist. Be concise and practical. ${languageInstruction(language ?? "en")}`;

    const userPrompt =
      `Product: ${product_name}\nData: ${dataSummary}\n\nGive the farmer a short, practical read on demand for this product.`;

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