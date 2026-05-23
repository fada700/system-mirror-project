import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";
import { supabaseAdmin } from "@/integrations/supabase/client.server";
import { notify, formatMoney } from "./notifications.server";

async function assertPoliciaOrAdmin(authUserId: string): Promise<string> {
  const { data: u } = await supabaseAdmin
    .from("usuarios").select("id").eq("auth_user_id", authUserId).single();
  if (!u) throw new Error("No autorizado");
  const { data: roles } = await supabaseAdmin
    .from("roles_usuario").select("role").eq("usuario_id", u.id);
  const set = new Set((roles ?? []).map((r) => r.role));
  if (!set.has("admin") && !set.has("policia")) throw new Error("No autorizado (policía/admin)");
  return u.id;
}

export interface MultaRow {
  id: string;
  usuario_id: string;
  usuario_nombre: string;
  numero_cliente: string;
  monto: number;
  motivo: string;
  estado: "pendiente" | "pagada" | "cancelada";
  fecha_emision: string;
  ultimo_recordatorio: string | null;
  policia_nombre: string | null;
}

export const listarMultas = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .inputValidator((d: { estado?: "pendiente" | "pagada" | "cancelada" } | undefined) =>
    z.object({ estado: z.enum(["pendiente", "pagada", "cancelada"]).optional() }).parse(d ?? {}),
  )
  .handler(async ({ data, context }): Promise<MultaRow[]> => {
    await assertPoliciaOrAdmin(context.userId);
    let q = supabaseAdmin
      .from("multas")
      .select("id, usuario_id, policia_id, monto, motivo, estado, fecha_emision, ultimo_recordatorio")
      .order("fecha_emision", { ascending: false })
      .limit(200);
    if (data.estado) q = q.eq("estado", data.estado);
    const { data: rows, error } = await q;
    if (error) throw new Error(error.message);
    if (!rows?.length) return [];
    const userIds = [...new Set([...rows.map((r) => r.usuario_id), ...rows.map((r) => r.policia_id).filter(Boolean) as string[]])];
    const { data: users } = await supabaseAdmin
      .from("usuarios").select("id, nombre, numero_cliente").in("id", userIds);
    const byId = new Map((users ?? []).map((u) => [u.id, u]));
    return rows.map((r: any) => ({
      id: r.id,
      usuario_id: r.usuario_id,
      usuario_nombre: byId.get(r.usuario_id)?.nombre ?? "—",
      numero_cliente: byId.get(r.usuario_id)?.numero_cliente ?? "—",
      monto: Number(r.monto),
      motivo: r.motivo,
      estado: r.estado,
      fecha_emision: r.fecha_emision,
      ultimo_recordatorio: r.ultimo_recordatorio,
      policia_nombre: r.policia_id ? byId.get(r.policia_id)?.nombre ?? null : null,
    }));
  });

export const emitirMulta = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((d: { usuario_id: string; monto: number; motivo: string }) =>
    z.object({
      usuario_id: z.string().uuid(),
      monto: z.number().min(1).max(10_000_000),
      motivo: z.string().min(3).max(300),
    }).parse(d),
  )
  .handler(async ({ data, context }) => {
    await assertPoliciaOrAdmin(context.userId);
    const { data: mid, error } = await context.supabase.rpc("emitir_multa", {
      _usuario_id: data.usuario_id, _monto: data.monto, _motivo: data.motivo,
    });
    if (error) throw new Error(error.message);
    await notify({
      usuario_id: data.usuario_id,
      tipo: "transaccion",
      titulo: "🚨 Nueva multa emitida",
      descripcion: `Monto: **${formatMoney(data.monto)}**\nMotivo: ${data.motivo}`,
      color: 0xdc2626,
    });
    return { id: mid as string };
  });

export const pagarMulta = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((d: { multa_id: string }) => z.object({ multa_id: z.string().uuid() }).parse(d))
  .handler(async ({ data, context }) => {
    const { error } = await context.supabase.rpc("pagar_multa", { _multa_id: data.multa_id });
    if (error) throw new Error(error.message);
    return { ok: true };
  });

export interface MisMultasRow {
  id: string;
  monto: number;
  motivo: string;
  estado: "pendiente" | "pagada" | "cancelada";
  fecha_emision: string;
  fecha_pago: string | null;
  policia_nombre: string | null;
}

export const misMultas = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }): Promise<MisMultasRow[]> => {
    const { data: u } = await supabaseAdmin
      .from("usuarios").select("id").eq("auth_user_id", context.userId).single();
    if (!u) return [];
    const { data: rows, error } = await supabaseAdmin
      .from("multas")
      .select("id, policia_id, monto, motivo, estado, fecha_emision, fecha_pago")
      .eq("usuario_id", u.id)
      .order("fecha_emision", { ascending: false })
      .limit(50);
    if (error) throw new Error(error.message);
    if (!rows?.length) return [];
    const policiaIds = [...new Set(rows.map((r) => r.policia_id).filter(Boolean) as string[])];
    const { data: pols } = policiaIds.length
      ? await supabaseAdmin.from("usuarios").select("id, nombre").in("id", policiaIds)
      : { data: [] as { id: string; nombre: string }[] };
    const byId = new Map((pols ?? []).map((p) => [p.id, p.nombre]));
    return rows.map((r: any) => ({
      id: r.id,
      monto: Number(r.monto),
      motivo: r.motivo,
      estado: r.estado,
      fecha_emision: r.fecha_emision,
      fecha_pago: r.fecha_pago,
      policia_nombre: r.policia_id ? byId.get(r.policia_id) ?? null : null,
    }));
  });

export const cancelarMulta = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((d: { multa_id: string; motivo?: string }) =>
    z.object({ multa_id: z.string().uuid(), motivo: z.string().max(200).optional() }).parse(d),
  )
  .handler(async ({ data, context }) => {
    await assertPoliciaOrAdmin(context.userId);
    const { error } = await context.supabase.rpc("cancelar_multa", {
      _multa_id: data.multa_id, _motivo: data.motivo ?? "",
    });
    if (error) throw new Error(error.message);
    return { ok: true };
  });

export const recordarMulta = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((d: { multa_id: string }) => z.object({ multa_id: z.string().uuid() }).parse(d))
  .handler(async ({ data, context }) => {
    await assertPoliciaOrAdmin(context.userId);
    const { data: m } = await supabaseAdmin
      .from("multas").select("usuario_id, monto, motivo").eq("id", data.multa_id).single();
    if (!m) throw new Error("Multa no encontrada");
    const { error } = await context.supabase.rpc("marcar_recordatorio_multa", { _multa_id: data.multa_id });
    if (error) throw new Error(error.message);
    await notify({
      usuario_id: m.usuario_id,
      tipo: "transaccion",
      titulo: "📢 Recordatorio de multa pendiente",
      descripcion: `Tienes una multa de **${formatMoney(Number(m.monto))}** sin pagar.\nMotivo: ${m.motivo}`,
      color: 0xea580c,
    });
    return { ok: true };
  });

export const buscarUsuariosMdt = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .inputValidator((d: { q?: string } | undefined) =>
    z.object({ q: z.string().max(80).optional() }).parse(d ?? {}),
  )
  .handler(async ({ data, context }) => {
    await assertPoliciaOrAdmin(context.userId);
    const q = (data.q ?? "").trim();
    let query = supabaseAdmin
      .from("usuarios")
      .select("id, nombre, numero_cliente, discord_id, discord_username")
      .order("nombre", { ascending: true })
      .limit(40);
    if (q.length > 0) {
      query = query.or(
        `nombre.ilike.%${q}%,numero_cliente.ilike.%${q}%,discord_username.ilike.%${q}%,discord_id.eq.${q}`,
      );
    }
    const { data: rows, error } = await query;
    if (error) throw new Error(error.message);
    return rows ?? [];
  });
