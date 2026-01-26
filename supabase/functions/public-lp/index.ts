/// <reference lib="deno.unstable" />
import { createClient } from "https://esm.sh/@supabase/supabase-js@2?target=deno";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase = createClient(SUPABASE_URL, SERVICE_KEY, { auth: { persistSession: false } });

function esc(s: string): string {
  return s.replaceAll("&","&amp;").replaceAll("<","&lt;").replaceAll(">","&gt;");
}

Deno.serve(async (req) => {
  const url = new URL(req.url);
  const lang = (url.searchParams.get("lang") === "en") ? "en" : "ja";

  const { data: i18n } = await supabase
    .from("approval.public_i18n")
    .select("key,value")
    .eq("lang", lang);

  const dict: Record<string,string> = {};
  (i18n ?? []).forEach((r: any) => dict[r.key] = r.value);

  const { data: pricing } = await supabase
    .from("approval.public_pricing")
    .select("*");

  const rows = (pricing ?? []).map((p: any) => `
    <tr>
      <td>${esc(String(p.plan_name))}</td>
      <td>¥${esc(String(p.monthly_yen))}/mo</td>
      <td>${esc(String(p.description ?? ""))}</td>
      <td>${esc(String(p.features ?? ""))}</td>
    </tr>
  `).join("");

  const toggle = lang === "ja"
    ? `<a href="?lang=en">English</a>`
    : `<a href="?lang=ja">日本語</a>`;

  const html = `<!doctype html><html><head><meta charset="utf-8">
  <title>${esc(dict.lp_title ?? "AI Approval SaaS")}</title></head><body>
  <div style="display:flex;justify-content:space-between;align-items:center;">
    <h1>${esc(dict.lp_title ?? "")}</h1><div>${toggle}</div>
  </div>
  <p>${esc(dict.lp_subtitle ?? "")}</p>
  <h2>${esc(dict.pricing ?? "Pricing")}</h2>
  <table border="1" cellpadding="6" cellspacing="0">
    <tr><th>Plan</th><th>Price</th><th>Description</th><th>Features</th></tr>
    ${rows}
  </table>
  <p><b>${esc(dict.contact ?? "Contact")}</b>: sales@example.com</p>
  </body></html>`;

  return new Response(html, { headers: { "Content-Type": "text/html; charset=utf-8" } });
});
