import { createFileRoute } from "@tanstack/react-router";
import { supabaseAdmin } from "@/integrations/supabase/client.server";

// Cron endpoint: cobra impuestos cada 6 días (la función SQL ya filtra por intervalo).
// pg_cron debe llamarlo al menos 1 vez por día. Auth: header `apikey` con anon key.
export const Route = createFileRoute("/api/public/cron-impuestos")({
  server: {
    handlers: {
      POST: async ({ request }) => {
        const apikey = request.headers.get("apikey");
        const expected = process.env.SUPABASE_PUBLISHABLE_KEY ?? process.env.SUPABASE_ANON_KEY;
        if (!expected || apikey !== expected) {
          return new Response("Unauthorized", { status: 401 });
        }
        const { data, error } = await supabaseAdmin.rpc("cobrar_impuestos_tick");
        if (error) return Response.json({ ok: false, error: error.message }, { status: 500 });
        return Response.json({ ok: true, result: data });
      },
    },
  },
});
