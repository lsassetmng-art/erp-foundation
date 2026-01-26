/// <reference lib="deno.unstable" />
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { PDFDocument, StandardFonts } from "https://esm.sh/pdf-lib@1.17.1";

function b64(bytes: Uint8Array): string {
  let s = "";
  for (const c of bytes) s += String.fromCharCode(c);
  return btoa(s);
}

Deno.serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const resendKey = Deno.env.get("RESEND_API_KEY")!;
    const fromEmail = Deno.env.get("INVOICE_FROM_EMAIL")!; // e.g. billing@example.com

    const { invoice_id } = await req.json();
    if (!invoice_id) return new Response("missing invoice_id", { status: 400 });

    const supabase = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false } });

    // invoice
    const invRes = await supabase.from("approval.billing_invoice")
      .select("invoice_id,customer_code,ym,amount_yen,status,created_at")
      .eq("invoice_id", invoice_id).maybeSingle();
    if (invRes.error || !invRes.data) return new Response("invoice not found", { status: 404 });

    const inv = invRes.data;

    // customer email
    const custRes = await supabase.from("approval.billing_customer")
      .select("email,display_name").eq("customer_code", inv.customer_code).maybeSingle();
    if (custRes.error || !custRes.data) return new Response("customer email not found", { status: 404 });

    const toEmail = custRes.data.email;

    // HTML invoice
    const html = `
      <h1>Invoice</h1>
      <p>Invoice ID: ${inv.invoice_id}</p>
      <p>Customer: ${inv.customer_code}</p>
      <p>Period: ${inv.ym}</p>
      <p>Amount: ¥${inv.amount_yen}</p>
      <p>Status: ${inv.status}</p>
    `;

    // PDF (simple)
    const pdfDoc = await PDFDocument.create();
    const page = pdfDoc.addPage([595.28, 841.89]);
    const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
    const lines = [
      "Invoice",
      `Invoice ID: ${inv.invoice_id}`,
      `Customer: ${inv.customer_code}`,
      `Period: ${inv.ym}`,
      `Amount: ¥${inv.amount_yen}`,
      `Status: ${inv.status}`,
    ];
    let y = 800;
    for (const ln of lines) {
      page.drawText(ln, { x: 50, y, size: 12, font });
      y -= 20;
    }
    const pdfBytes = await pdfDoc.save();

    // Send via Resend
    const sendRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${resendKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: fromEmail,
        to: [toEmail],
        subject: `Invoice ${inv.ym} (${inv.customer_code})`,
        html,
        attachments: [
          {
            filename: `invoice_${inv.invoice_id}.pdf`,
            content: b64(new Uint8Array(pdfBytes)),
            content_type: "application/pdf",
          },
        ],
      }),
    });

    if (!sendRes.ok) {
      const t = await sendRes.text();
      return new Response(`email failed: ${t}`, { status: 502 });
    }

    return new Response("sent", { status: 200 });
  } catch (e) {
    return new Response(String(e), { status: 500 });
  }
});
