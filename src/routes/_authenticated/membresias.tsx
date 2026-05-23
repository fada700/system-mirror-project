import { createFileRoute, Link } from "@tanstack/react-router";
import { useServerFn } from "@tanstack/react-start";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { getMe } from "@/lib/usuario.functions";
import { listarMembresias, comprarMembresia, type TipoMembresia } from "@/lib/membresias.functions";
import { formatMXN } from "@/lib/format";

export const Route = createFileRoute("/_authenticated/membresias")({
  component: MembresiasPage,
});

const LABEL: Record<TipoMembresia, string> = {
  basica: "Básica", gold: "Gold", zafiro: "Zafiro", esmeralda: "Esmeralda",
  diamond: "Diamond", ruby: "Ruby", ruby_plus: "Ruby+",
};

function MembresiasPage() {
  const qc = useQueryClient();
  const fetchMe = useServerFn(getMe);
  const fnList = useServerFn(listarMembresias);
  const fnComprar = useServerFn(comprarMembresia);

  const { data: me } = useQuery({ queryKey: ["me"], queryFn: () => fetchMe() });
  const { data: list } = useQuery({ queryKey: ["membresias"], queryFn: () => fnList() });

  if (!me || !list) return <div className="min-h-screen flex items-center justify-center text-muted-foreground">Cargando…</div>;

  const comprar = async (tipo: TipoMembresia, costo: number) => {
    if (!confirm(`¿Comprar membresía ${LABEL[tipo]} por ${formatMXN(costo)}?`)) return;
    try {
      await fnComprar({ data: { tipo } });
      toast.success(`Membresía ${LABEL[tipo]} activada`);
      qc.invalidateQueries({ queryKey: ["me"] });
    } catch (e) { toast.error((e as Error).message); }
  };

  return (
    <div className="min-h-screen pb-12">
      <header className="container-app pt-6 flex items-center justify-between">
        <h1 className="text-2xl font-bold">Membresías</h1>
        <Link to="/home" className="text-sm underline">Inicio</Link>
      </header>
      <p className="container-app mt-2 text-sm text-muted-foreground">
        Tu membresía actual: <b>{LABEL[me.membresia]}</b>
      </p>

      <div className="container-app mt-6 grid gap-3">
        {list.map((m) => {
          const actual = me.membresia === m.tipo;
          return (
            <div key={m.tipo} className="rounded-2xl border bg-card p-4">
              <div className="flex items-start justify-between">
                <div>
                  <div className="text-lg font-bold">{LABEL[m.tipo]}</div>
                  <div className="text-xs text-muted-foreground">Soporte: {m.nivel_soporte}</div>
                </div>
                <div className="text-right">
                  <div className="text-xl font-bold">{m.costo === 0 ? "Gratis" : formatMXN(m.costo)}</div>
                  <div className="text-xs text-muted-foreground">Impuesto {m.impuesto_pct}% / 6 días</div>
                </div>
              </div>
              <ul className="mt-3 text-sm space-y-1 text-foreground/80">
                <li>• Tx diarias: {m.tx_diarias < 0 ? "Ilimitadas" : m.tx_diarias}</li>
                <li>• Tx grandes/día: {m.tx_grandes_diarias} (≥ {formatMXN(m.monto_grande)})</li>
                <li>• Tope débito: {formatMXN(m.debito_max)} · Cartera: {formatMXN(m.cartera_max)}</li>
                {m.credito_max > 0 && <li>• Crédito hasta: {formatMXN(m.credito_max)}</li>}
                {m.seguridad_antihackeo_pct > 0 && <li>• Anti-hackeo: {m.seguridad_antihackeo_pct}%</li>}
                {m.seguro_dinero_pct > 0 && <li>• Seguro del dinero: {m.seguro_dinero_pct}%</li>}
              </ul>
              <button
                disabled={actual}
                onClick={() => comprar(m.tipo, m.costo)}
                className="mt-3 w-full rounded-lg bg-primary text-primary-foreground px-3 py-2 text-sm font-medium disabled:opacity-50"
              >
                {actual ? "Membresía actual" : m.costo === 0 ? "Cambiar a básica" : "Comprar"}
              </button>
            </div>
          );
        })}
      </div>
    </div>
  );
}
