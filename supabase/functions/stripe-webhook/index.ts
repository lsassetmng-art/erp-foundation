/// <reference lib="deno.unstable" />
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let out = 0;
  for (let i = 0; i < a.length; i++) out |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return out === 0;
}

async function hmacSHA256Hex(secret: string, msg: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(msg));
  const bytes = new Uint8Array(sig);
  return Array.from(bytes).map((x) => x.toString(16).padStart(2, "0")).join("");
}

// Stripe-Signature: t=...,v1=...,v1=...
function verifyStripeSignature(sigHeader: string | null, payload: string, secret: string): Promise<boolean> {
  if (!sigHeader) return Promise.resolve(false);
  const parts = sigHeader.split(",").map((s) => s.trim());
  const tPart = parts.find((p) => p.startsWith("t="));
  const v1Parts = parts.filter((p) => p.startsWith("v1="));
  if (!tPart || v1Parts.length === 0) return Promise.resolve(false);
  const t = tPart.slice(2);
  const signedPayload = `${t}.${payload}`;
  return hmacSHA256Hex(secret, signedPayload).then((expected) => {
    return v1Parts.some((p) => timingSafeEqual(p.slice(3), expected));
  });
}

Deno.serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const stripeSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;

    const raw = await req.text();
    const ok = await verifyStripeSignature(req.headers.get("Stripe-Signature"), raw, stripeSecret);
    if (!ok) return new Response("bad signature", { status: 400 });

    const evt = JSON.parse(raw);
    const eventId = evt?.id ?? null;
    const eventType = evt?.type ?? "unknown";

    // 要件：Stripe側で metadata.invoice_id (UUID) を入れる運用
    const obj = evt?.data?.object ?? {};
    const invoiceId = obj?.metadata?.invoice_id ?? null;
    const providerRef = obj?.id ?? null;

    // amount: Stripeは最小通貨単位（JPYは円なのでそのままの想定、環境で調整）
    const amountYen = (obj?.amount_received ?? obj?.amount_total ?? obj?.amount ?? 0);

    // succeeded/failed の統一
    let status = "pending";
    if (eventType.includes("succeeded") || obj?.status === "succeeded" || obj?.paid === true) status = "succeeded";
    if (eventType.includes("failed") || obj?.status === "failed") status = "failed";

    // 監査テーブルへ raw 保存（event_idがあれば冪等）
    const supabase = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false } });
    if (eventId) {
      await supabase.from("approval.stripe_webhook_event").upsert({
        event_id: eventId,
        event_type: eventType,
        raw_payload: evt,
        process_status: "received",
      });
    }

    // invoice_id が無ければ “ignored”
    if (!invoiceId) {
      if (eventId) {
        await supabase.from("approval.stripe_webhook_event").update({
          process_status: "ignored",
          processed_at: new Date().toISOString(),
          last_error: "missing metadata.invoice_id",
        }).eq("event_id", eventId);
      }
      return new Response("ignored (no invoice_id)", { status: 200 });
    }

    // DB正本に反映（RPC）
    const { error } = await supabase.rpc("apply_payment_event", {
      p_provider: "stripe",
      p_event_id: eventId ?? crypto.randomUUID(),
      p_invoice_id: invoiceId,
      p_provider_ref: providerRef ?? "unknown",
      p_amount_yen: amountYen,
      p_status: status,
    });

    if (error) {
      if (eventId) {
        await supabase.from("approval.stripe_webhook_event").update({
          process_status: "failed",
          processed_at: new Date().toISOString(),
          last_error: String(error.message ?? error),
        }).eq("event_id", eventId);
      }
      return new Response("rpc failed", { status: 500 });
    }

    if (eventId) {
      await supabase.from("approval.stripe_webhook_event").update({
        process_status: "processed",
        processed_at: new Date().toISOString(),
      }).eq("event_id", eventId);
    }

    return new Response("ok", { status: 200 });
  } catch (e) {
    return new Response(String(e), { status: 500 });
  }
});
