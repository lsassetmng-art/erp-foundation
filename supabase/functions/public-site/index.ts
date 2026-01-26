/// <reference lib="deno.unstable" />
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

function escapeHtml(s: string): string {
  return s.replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;");
}

Deno.serve(async (req) => {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const supabase = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false } });

  const url = new URL(req.url);
  const lang = (url.searchParams.get("lang") === "en") ? "en" : "ja";

  const i18nRes = await supabase.from("approval.public_i18n").select("key,value").eq("lang", lang);
  const pricingRes = await supabase.from("approval.public_pricing").select("*");

  const i18n: Record<string,string> = {};
  (i18nRes.data ?? []).forEach((r: any) => i18n[r.key] = r.value);

  const title = i18n["lp_title"] ?? "AI Approval SaaS";
  const subtitle = i18n["lp_subtitle"] ?? "";
  const pricingLabel = i18n["pricing"] ?? "Pricing";
  const contactLabel = i18n["contact"] ?? "Contact";

  const rows = (pricingRes.data ?? []).map((p: any) => `
    <tr>
      <td>${escapeHtml(String(p.plan_name))}</td>
      <td>¥${escapeHtml(String(p.monthly_yen))}/mo</td>
      <td>${escapeHtml(String(p.description))}</td>
      <td>${escapeHtml(String(p.features))}</td>
    </tr>
  `).join("");

  const html = `<!doctype html>
  <html><head><meta charset="utf-8"><title>${escapeHtml(title)}</title></head>
  <body>
    <h1>${escapeHtml(title)}</h1>
    <p>${escapeHtml(subtitle)}</p>
    <h2>${escapeHtml(pricingLabel)}</h2>
    <table border="1" cellpadding="6" cellspacing="0">
      <tr><th>Plan</th><th>Price</th><th>Description</th><th>Features</th></tr>
      ${rows}
    </table>
    <h2>${escapeHtml(contactLabel)}</h2>
    <p>sales@example.com</p>
  </body></html>`;

  return new Response(html, { headers: { "Content-Type": "text/html; charset=utf-8" } });
});
