/// <reference lib="deno.unstable" />
import Stripe from "https://esm.sh/stripe@14.25.0?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2?target=deno";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY")!;
const PUBLIC_BASE_URL = Deno.env.get("PUBLIC_BASE_URL") ?? "https://example.com";

const supabase = createClient(SUPABASE_URL, SERVICE_KEY, { auth: { persistSession: false } });
const stripe = new Stripe(STRIPE_SECRET_KEY, { apiVersion: "2023-10-16" });

function json(status: number, body: unknown) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}

Deno.serve(async (req) => {
  try {
    const { invoice_id } = await req.json().catch(() => ({}));
    if (!invoice_id) return json(400, { error: "invoice_id required" });

    // invoice read (billing.invoice)
    const { data: inv, error: invErr } = await supabase
      .from("billing.invoice")
      .select("invoice_id, company_id, customer_code, total_amount, currency, status")
      .eq("invoice_id", invoice_id)
      .maybeSingle();

    if (invErr || !inv) return json(404, { error: "invoice not found" });

    // create checkout_session record (DB正本)
    const { data: csRow, error: csErr } = await supabase
      .from("billing.checkout_session")
      .insert({
        invoice_id: inv.invoice_id,
        company_id: inv.company_id,
        customer_code: inv.customer_code,
        provider: "stripe",
        status: "created",
      })
      .select("checkout_id")
      .maybeSingle();

    if (csErr) return json(500, { error: "db insert failed", detail: String(csErr.message ?? csErr) });

    // Stripe: amount (JPYは最小通貨単位=円)
    const amount = Math.trunc(Number(inv.total_amount ?? 0));

    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      success_url: `${PUBLIC_BASE_URL}/payment/success?invoice_id=${inv.invoice_id}`,
      cancel_url: `${PUBLIC_BASE_URL}/payment/cancel?invoice_id=${inv.invoice_id}`,
      line_items: [
        {
          quantity: 1,
          price_data: {
            currency: String(inv.currency ?? "jpy").toLowerCase(),
            unit_amount: amount,
            product_data: { name: `Invoice ${inv.invoice_id}` },
          },
        },
      ],
      metadata: {
        invoice_id: String(inv.invoice_id), // ★ 自動注入（必須）
        company_id: String(inv.company_id),
      },
    });

    await supabase
      .from("billing.checkout_session")
      .update({
        status: "redirected",
        stripe_session_id: session.id,
        stripe_url: session.url,
      })
      .eq("checkout_id", csRow!.checkout_id);

    return json(200, { ok: true, invoice_id: inv.invoice_id, url: session.url });
  } catch (e) {
    return json(500, { error: "internal", detail: String(e) });
  }
});
