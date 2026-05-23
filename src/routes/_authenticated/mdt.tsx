import { createFileRoute, Link } from "@tanstack/react-router";
import { useServerFn } from "@tanstack/react-start";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { toast } from "sonner";
import { getMe } from "@/lib/usuario.functions";
import {
  listarMultas, emitirMulta, cancelarMulta, recordarMulta, buscarUsuariosMdt,
} from "@/lib/mdt.functions";
import { formatMXN } from "@/lib/format";

export const Route = createFileRoute("/_authenticated/mdt")({
  component: MdtPage,
});

function MdtPage() {
  const qc = useQueryClient();
  const fetchMe = useServerFn(getMe);
  const fnMultas = useServerFn(listarMultas);
  const fnBuscar = useServerFn(buscarUsuariosMdt);
  const fnEmitir = useServerFn(emitirMulta);
  const fnCancelar = useServerFn(cancelarMulta);
  const fnRecordar = useServerFn(recordarMulta);

  const { data: me } = useQuery({ queryKey: ["me"], queryFn: () => fetchMe() });
  const ok = me?.roles?.includes("policia") || me?.roles?.includes("admin");

  const [tab, setTab] = useState<"pendiente" | "pagada" | "cancelada">("pendiente");
  const { data: multas } = useQuery({
    queryKey: ["mdt-multas", tab],
    queryFn: () => fnMultas({ data: { estado: tab } }),
    enabled: !!ok,
  });

  const [q, setQ] = useState("");
  const { data: users } = useQuery({
    queryKey: ["mdt-search", q],
    queryFn: () => fnBuscar({ data: { q } }),
    enabled: !!ok && q.length >= 1,
  });

  const [target, setTarget] = useState<{ id: string; nombre: string } | null>(null);
  const [monto, setMonto] = useState("");
  const [motivo, setMotivo] = useState("");

  if (!me) return <div className="min-h-screen flex items-center justify-center text-muted-foreground">Cargando…</div>;
  if (!ok) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center gap-4 p-6 text-center">
        <div className="text-2xl font-bold">MDT — Acceso restringido</div>
        <div className="text-muted-foreground">Solo Policía o Admin.</div>
        <Link to="/home" className="underline">Volver al inicio</Link>
      </div>
    );
  }

  const submit = async () => {
    if (!target) return toast.error("Selecciona un ciudadano");
    const m = Number(monto);
    if (!m || m <= 0) return toast.error("Monto inválido");
    if (motivo.trim().length < 3) return toast.error("Motivo muy corto");
    try {
      await fnEmitir({ data: { usuario_id: target.id, monto: m, motivo: motivo.trim() } });
      toast.success("Multa emitida");
      setMonto(""); setMotivo(""); setTarget(null); setQ("");
      qc.invalidateQueries({ queryKey: ["mdt-multas"] });
    } catch (e) { toast.error((e as Error).message); }
  };

  return (
    <div className="min-h-screen pb-12">
      <header className="container-app pt-6 flex items-center justify-between">
        <h1 className="text-2xl font-bold">MDT Policial</h1>
        <Link to="/home" className="text-sm underline">Inicio</Link>
      </header>

      <section className="container-app mt-6 rounded-2xl border bg-card p-4 space-y-3">
        <div className="font-semibold">Emitir multa</div>
        <input
          className="w-full rounded-lg border bg-background px-3 py-2 text-sm"
          placeholder="Buscar ciudadano (nombre, #cliente, discord)"
          value={q} onChange={(e) => { setQ(e.target.value); setTarget(null); }}
        />
        {target && (
          <div className="text-sm rounded-lg bg-primary/10 px-3 py-2">Seleccionado: <b>{target.nombre}</b></div>
        )}
        {!target && users && users.length > 0 && (
          <div className="max-h-48 overflow-auto rounded-lg border divide-y">
            {users.map((u: any) => (
              <button key={u.id} onClick={() => setTarget({ id: u.id, nombre: u.nombre })}
                className="w-full text-left px-3 py-2 hover:bg-muted text-sm">
                <div className="font-medium">{u.nombre}</div>
                <div className="text-xs text-muted-foreground">{u.numero_cliente} · {u.discord_username}</div>
              </button>
            ))}
          </div>
        )}
        <input
          type="number" className="w-full rounded-lg border bg-background px-3 py-2 text-sm"
          placeholder="Monto $" value={monto} onChange={(e) => setMonto(e.target.value)}
        />
        <textarea
          className="w-full rounded-lg border bg-background px-3 py-2 text-sm" rows={3}
          placeholder="Motivo de la multa" value={motivo} onChange={(e) => setMotivo(e.target.value)}
        />
        <button onClick={submit}
          className="w-full rounded-lg bg-primary text-primary-foreground px-3 py-2 text-sm font-medium">
          Emitir multa
        </button>
      </section>

      <section className="container-app mt-6">
        <div className="flex gap-2 text-sm mb-3">
          {(["pendiente", "pagada", "cancelada"] as const).map((s) => (
            <button key={s} onClick={() => setTab(s)}
              className={`rounded-full px-3 py-1 border ${tab === s ? "bg-primary text-primary-foreground" : "bg-card"}`}>
              {s}
            </button>
          ))}
        </div>
        <div className="space-y-2">
          {(multas ?? []).map((m) => (
            <div key={m.id} className="rounded-xl border bg-card p-3 text-sm">
              <div className="flex items-center justify-between">
                <div>
                  <div className="font-semibold">{m.usuario_nombre} <span className="text-muted-foreground">· {m.numero_cliente}</span></div>
                  <div className="text-muted-foreground text-xs">{new Date(m.fecha_emision).toLocaleString()}</div>
                </div>
                <div className="font-bold">{formatMXN(m.monto)}</div>
              </div>
              <div className="mt-1 text-foreground/80">{m.motivo}</div>
              {m.estado === "pendiente" && (
                <div className="mt-2 flex gap-2">
                  <button onClick={async () => {
                    try { await fnRecordar({ data: { multa_id: m.id } }); toast.success("Recordatorio enviado"); }
                    catch (e) { toast.error((e as Error).message); }
                  }} className="text-xs rounded-md border px-2 py-1">Recordar</button>
                  <button onClick={async () => {
                    if (!confirm("¿Cancelar multa?")) return;
                    try {
                      await fnCancelar({ data: { multa_id: m.id, motivo: "anulada" } });
                      toast.success("Cancelada");
                      qc.invalidateQueries({ queryKey: ["mdt-multas"] });
                    } catch (e) { toast.error((e as Error).message); }
                  }} className="text-xs rounded-md border px-2 py-1 text-destructive">Cancelar</button>
                </div>
              )}
            </div>
          ))}
          {multas && multas.length === 0 && (
            <div className="text-center text-sm text-muted-foreground py-8">Sin registros</div>
          )}
        </div>
      </section>
    </div>
  );
}
