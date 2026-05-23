import { createFileRoute, Link } from "@tanstack/react-router";
import { useServerFn } from "@tanstack/react-start";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { getMe } from "@/lib/usuario.functions";
import { getProximoSueldo, reclamarSueldo } from "@/lib/sueldos.functions";
import { misMultas, pagarMulta } from "@/lib/mdt.functions";
import { supabase } from "@/integrations/supabase/client";
import { formatMXN } from "@/lib/format";
import { useState } from "react";

export const Route = createFileRoute("/_authenticated/perfil")({
  component: PerfilPage,
});

const ROL_LABEL: Record<string, string> = {
  admin: "Administrador",
  trabajador: "Trabajador",
  policia: "Policía",
  usuario: "Cliente",
};

const MEMBRESIA_LABEL: Record<string, string> = {
  basica: "Básica", gold: "Gold", zafiro: "Zafiro", esmeralda: "Esmeralda",
  diamond: "Diamond", ruby: "Ruby", ruby_plus: "Ruby+",
};

function PerfilPage() {
  const qc = useQueryClient();
  const fetchMe = useServerFn(getMe);
  const fnSueldo = useServerFn(getProximoSueldo);
  const fnReclamar = useServerFn(reclamarSueldo);
  const fnMisMultas = useServerFn(misMultas);
  const fnPagar = useServerFn(pagarMulta);
  const { data, isLoading } = useQuery({ queryKey: ["me"], queryFn: () => fetchMe() });
  const { data: sueldo } = useQuery({
    queryKey: ["proximo-sueldo"],
    queryFn: () => fnSueldo(),
    refetchInterval: 60_000,
  });
  const { data: multas } = useQuery({ queryKey: ["mis-multas"], queryFn: () => fnMisMultas() });
  const [claiming, setClaiming] = useState(false);
  const [payingId, setPayingId] = useState<string | null>(null);

  const pagar = async (id: string) => {
    setPayingId(id);
    try {
      await fnPagar({ data: { multa_id: id } });
      toast.success("Multa pagada");
      qc.invalidateQueries({ queryKey: ["me"] });
      qc.invalidateQueries({ queryKey: ["mis-multas"] });
    } catch (e) { toast.error((e as Error).message); }
    setPayingId(null);
  };

  const logout = async () => {
    await supabase.auth.signOut();
    window.location.replace("/login");
  };

  const claim = async () => {
    setClaiming(true);
    try {
      const r = await fnReclamar();
      toast.success(`Cobraste ${formatMXN(r.monto)}`);
      qc.invalidateQueries({ queryKey: ["me"] });
      qc.invalidateQueries({ queryKey: ["proximo-sueldo"] });
    } catch (e) { toast.error((e as Error).message); }
    setClaiming(false);
  };

  if (isLoading || !data) {
    return <div className="min-h-screen flex items-center justify-center text-muted-foreground bmx-pulse">Cargando…</div>;
  }

  const rolPrincipal = data.roles.includes("admin")
    ? "admin"
    : data.roles.includes("policia")
    ? "policia"
    : data.roles.includes("trabajador")
    ? "trabajador"
    : "usuario";

  return (
    <div className="min-h-screen">
      <header className="container-app pt-6">
        <h1 className="text-2xl font-bold">Perfil</h1>
      </header>

      <section className="container-app mt-6 flex flex-col items-center text-center">
        {data.discord_avatar_url ? (
          <img src={data.discord_avatar_url} alt="" className="h-20 w-20 rounded-full border border-border" />
        ) : (
          <div className="h-20 w-20 rounded-full bg-surface" />
        )}
        <div className="mt-3 text-lg font-semibold">{data.nombre}</div>
        <div className="text-xs text-muted-foreground font-mono">{data.numero_cliente}</div>
      </section>

      <section className="container-app mt-6 rounded-2xl border border-border bg-surface divide-y divide-border">
        <Row k="Rol" v={ROL_LABEL[rolPrincipal]} />
        <Row k="Membresía" v={MEMBRESIA_LABEL[data.membresia]} />
        <Row k="Discord" v={"@" + data.discord_id} mono />
        <Row k="Saldo banco" v={formatMXN(data.saldo_banco)} mono />
        <Row k="Saldo cartera" v={formatMXN(data.saldo_cartera)} mono />
      </section>

      {sueldo && sueldo.role && (
        <section className="container-app mt-6 rounded-2xl border border-border bg-surface p-4">
          <div className="text-[10px] uppercase tracking-[0.3em] text-muted-foreground">Sueldo · {sueldo.role}</div>
          <div className="mt-1 flex items-center justify-between">
            <div className="text-xl font-bold">{formatMXN(sueldo.monto)}</div>
            <div className="text-xs text-muted-foreground">
              cada {sueldo.dias_periodo} días
            </div>
          </div>
          <button
            disabled={!sueldo.disponible || claiming}
            onClick={claim}
            className="mt-3 w-full rounded-lg bg-primary text-primary-foreground py-2 text-sm font-medium disabled:opacity-50"
          >
            {sueldo.disponible
              ? (claiming ? "Cobrando…" : "Reclamar sueldo")
              : `Disponible: ${sueldo.proximo ? new Date(sueldo.proximo).toLocaleString("es-MX") : "—"}`}
          </button>
        </section>
      )}

      {(data.impuestos_pendientes > 0 || data.multas_pendientes > 0) && (
        <section className="container-app mt-4 space-y-2 text-sm">
          {data.impuestos_pendientes > 0 && (
            <div className="rounded-xl border border-amber-500/40 bg-amber-500/10 px-3 py-2">
              🧾 Impuestos pendientes: <b>{formatMXN(data.impuestos_pendientes)}</b>
            </div>
          )}
          {data.multas_pendientes > 0 && (
            <Link to="/perfil" className="block rounded-xl border border-destructive/40 bg-destructive/10 px-3 py-2">
              🚨 {data.multas_pendientes} multa(s) pendiente(s) · {formatMXN(data.multas_pendientes_monto)}
            </Link>
          )}
        </section>
      )}

      {(data.roles.includes("admin") || data.roles.includes("trabajador")) && (
        <section className="container-app mt-6 space-y-2">
          <div className="text-[10px] uppercase tracking-[0.3em] text-muted-foreground px-1">Staff</div>
          {data.roles.includes("trabajador") && (
            <Link to="/trabajador-panel" className="bmx-tap block w-full rounded-2xl border border-border bg-surface py-4 text-sm font-semibold text-center">
              Panel trabajador
            </Link>
          )}
          {data.roles.includes("admin") && (
            <Link to="/admin" className="bmx-tap block w-full rounded-2xl border border-border bg-surface py-4 text-sm font-semibold text-center">
              Panel admin
            </Link>
          )}
          <p className="text-[10px] text-muted-foreground text-center px-2">
            Los paneles de staff no funcionan dentro de la app instalada.
          </p>
        </section>
      )}

      <section className="container-app mt-6">
        <button
          onClick={logout}
          className="bmx-tap w-full rounded-2xl border border-border py-4 text-sm font-medium text-destructive"
        >
          Cerrar sesión
        </button>
      </section>

      <div className="container-app mt-6 text-center text-[10px] uppercase tracking-[0.25em] text-muted-foreground">
        Banco De México · BMX
      </div>
    </div>
  );
}

function Row({ k, v, mono }: { k: string; v: string; mono?: boolean }) {
  return (
    <div className="flex items-center justify-between p-4 text-sm">
      <span className="text-muted-foreground">{k}</span>
      <span className={mono ? "font-mono" : "font-medium"}>{v}</span>
    </div>
  );
}
