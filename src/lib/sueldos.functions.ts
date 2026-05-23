import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";
import { supabaseAdmin } from "@/integrations/supabase/client.server";
import { notify, formatMoney } from "./notifications.server";

export interface SueldoInfo {
  role: string | null;
  monto: number;
  dias_periodo: number;
  ultimo: string | null;
  disponible: boolean;
  proximo: string | null;
}

export const getProximoSueldo = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }): Promise<SueldoInfo | null> => {
    const { data, error } = await context.supabase.rpc("proximo_sueldo");
    if (error) throw new Error(error.message);
    if (!data) return null;
    const j = data as any;
    return {
      role: j.role ?? null,
      monto: Number(j.monto ?? 0),
      dias_periodo: Number(j.dias_periodo ?? 7),
      ultimo: j.ultimo ?? null,
      disponible: Boolean(j.disponible),
      proximo: j.proximo ?? null,
    };
  });

export const reclamarSueldo = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }) => {
    const { data, error } = await context.supabase.rpc("reclamar_sueldo");
    if (error) throw new Error(error.message);
    const j = data as any;

    const { data: u } = await supabaseAdmin
      .from("usuarios").select("id").eq("auth_user_id", context.userId).single();
    if (u) {
      await notify({
        usuario_id: u.id,
        tipo: "transaccion",
        titulo: "💵 Sueldo cobrado",
        descripcion: `Recibiste **${formatMoney(Number(j?.monto ?? 0))}** por tu rol **${j?.role}**.`,
        color: 0x16a34a,
      });
    }
    return { monto: Number(j?.monto ?? 0), role: j?.role as string, proximo: j?.proximo as string };
  });

export interface SueldoConfigRow {
  role: string;
  monto: number;
  dias_periodo: number;
  activo: boolean;
}

export const listarConfigSueldos = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }): Promise<SueldoConfigRow[]> => {
    const { data: u } = await supabaseAdmin
      .from("usuarios").select("id").eq("auth_user_id", context.userId).single();
    if (!u) throw new Error("No autorizado");
    const { data: roles } = await supabaseAdmin
      .from("roles_usuario").select("role").eq("usuario_id", u.id);
    if (!(roles ?? []).some((r) => r.role === "admin")) throw new Error("Solo admin");
    const { data } = await supabaseAdmin.from("config_sueldos").select("*").order("role");
    return (data ?? []).map((r: any) => ({
      role: r.role, monto: Number(r.monto), dias_periodo: r.dias_periodo, activo: r.activo,
    }));
  });

export const upsertConfigSueldo = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((d: { role: string; monto: number; dias_periodo: number; activo: boolean }) =>
    z.object({
      role: z.string().min(2).max(40),
      monto: z.number().min(0).max(10_000_000),
      dias_periodo: z.number().int().min(1).max(60),
      activo: z.boolean(),
    }).parse(d),
  )
  .handler(async ({ data, context }) => {
    const { data: u } = await supabaseAdmin
      .from("usuarios").select("id").eq("auth_user_id", context.userId).single();
    if (!u) throw new Error("No autorizado");
    const { data: roles } = await supabaseAdmin
      .from("roles_usuario").select("role").eq("usuario_id", u.id);
    if (!(roles ?? []).some((r) => r.role === "admin")) throw new Error("Solo admin");
    const { error } = await supabaseAdmin
      .from("config_sueldos")
      .upsert({ role: data.role as any, monto: data.monto, dias_periodo: data.dias_periodo, activo: data.activo },
        { onConflict: "role" });
    if (error) throw new Error(error.message);
    return { ok: true };
  });
