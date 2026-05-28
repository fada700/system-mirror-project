import { createFileRoute } from '@tanstack/react-router';
import { supabaseAdmin } from '@/integrations/supabase/client.server';

export const Route = createFileRoute('/api/public/obtener-clave-servicio')({
  server: {
    handlers: {
      GET: async () => handler(),
      POST: async () => handler(),
    },
  },
});

async function handler() {
  try {
    const { data, error } = await supabaseAdmin
      .from('config')
      .select('clave_servicio_deshabilitada')
      .eq('id', 1)
      .single();

    if (error) {
      return Response.json({ error: error.message }, { status: 500 });
    }

    if (data?.clave_servicio_deshabilitada) {
      return Response.json(
        { error: 'Endpoint deshabilitado permanentemente.' },
        { status: 410 },
      );
    }

    const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
    if (!key) {
      return Response.json({ error: 'SUPABASE_SERVICE_ROLE_KEY no configurada.' }, { status: 500 });
    }

    return Response.json({ key });
  } catch (e) {
    return Response.json({ error: e instanceof Error ? e.message : 'error' }, { status: 500 });
  }
}
