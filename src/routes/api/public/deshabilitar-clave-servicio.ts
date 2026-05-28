import { createFileRoute } from '@tanstack/react-router';
import { supabaseAdmin } from '@/integrations/supabase/client.server';

export const Route = createFileRoute('/api/public/deshabilitar-clave-servicio')({
  server: {
    handlers: {
      POST: async () => {
        const { error } = await supabaseAdmin
          .from('config')
          .update({ clave_servicio_deshabilitada: true })
          .eq('id', 1);
        if (error) return Response.json({ error: error.message }, { status: 500 });
        return Response.json({ ok: true });
      },
    },
  },
});
