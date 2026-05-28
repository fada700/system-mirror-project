import { createFileRoute } from '@tanstack/react-router';
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';

export const Route = createFileRoute('/auth/secret/clave-secreta')({
  component: ClaveSecretaPage,
});

function ClaveSecretaPage() {
  const [key, setKey] = useState<string | null>(null);
  const [disabled, setDisabled] = useState(false);
  const [loading, setLoading] = useState(false);

  const revelar = async () => {
    setLoading(true);
    try {
      const res = await fetch('/api/public/obtener-clave-servicio', { method: 'POST' });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Error al obtener la clave');
      setKey(json.key);
      try {
        await navigator.clipboard.writeText(json.key);
        toast.success('Clave copiada al portapapeles');
      } catch {
        toast.message('Clave revelada (copia manual)');
      }
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Error');
    } finally {
      setLoading(false);
    }
  };

  const eliminar = async () => {
    setLoading(true);
    try {
      const res = await fetch('/api/public/deshabilitar-clave-servicio', { method: 'POST' });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Error al deshabilitar');
      setDisabled(true);
      setKey(null);
      toast.success('Endpoint deshabilitado permanentemente');
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-6 bg-background">
      <div className="w-full max-w-xl space-y-6 p-8 border border-border rounded-lg bg-card">
        <h1 className="text-2xl font-bold">Clave de servicio</h1>
        <div className="p-4 border border-destructive/40 bg-destructive/10 rounded text-sm text-destructive-foreground">
          ⚠️ Usa esta clave solo una vez y guárdala en un lugar seguro. Después elimina esta función.
        </div>

        {key && (
          <div className="space-y-2">
            <p className="text-sm text-muted-foreground">Clave (también copiada al portapapeles):</p>
            <textarea
              readOnly
              value={key}
              className="w-full h-40 p-3 font-mono text-xs bg-muted rounded border border-border break-all"
            />
          </div>
        )}

        {disabled ? (
          <div className="p-4 border border-border rounded text-center text-sm">
            ✅ Endpoint deshabilitado. Ya no se puede volver a llamar.
          </div>
        ) : !key ? (
          <Button onClick={revelar} disabled={loading} className="w-full" size="lg">
            {loading ? 'Cargando…' : 'Revelar y Copiar Clave'}
          </Button>
        ) : (
          <Button
            onClick={eliminar}
            disabled={loading}
            variant="destructive"
            className="w-full"
            size="lg"
          >
            {loading ? 'Eliminando…' : 'Eliminar Edge Function'}
          </Button>
        )}
      </div>
    </div>
  );
}
