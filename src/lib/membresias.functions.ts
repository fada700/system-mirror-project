import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";
import { supabaseAdmin } from "@/integrations/supabase/client.server";
import { addGuildRole } from "./discord.server";
import { DISCORD_GUILD_ID } from "./discord-config";
import { notify } from "./notifications.server";

export type TipoMembresia = "basica" | "gold" | "zafiro" | "esmeralda" | "diamond" | "ruby" | "ruby_plus";

export interface MembresiaCfg {
  tipo: TipoMembresia;
  costo: number;
  impuesto_pct: number;
  tx_diarias: number;
  tx_grandes_diarias: number;
  monto_grande: number;
  debito_max: number;
  cartera_max: number;
  credito_max: number;
  nivel_soporte: string;
  role_id_discord: string | null;
  orden: number;
  seguridad_antihackeo_pct: number;
  seguro_dinero_pct: number;
}

export const listarMembresias = createServerFn({ method: "GET" })
  .handler(async (): Promise<MembresiaCfg[]> => {
    const { data, error } = await supabaseAdmin
      .from("config_membresias")
      .select("*")
      .order("orden", { ascending: true });
    if (error) throw new Error(error.message);
    return (data ?? []).map((r: any) => ({
      tipo: r.tipo,
      costo: Number(r.costo),
      impuesto_pct: Number(r.impuesto_pct),
      tx_diarias: r.tx_diarias,
      tx_grandes_diarias: r.tx_grandes_diarias,
      monto_grande: Number(r.monto_grande),
      debito_max: Number(r.debito_max),
      cartera_max: Number(r.cartera_max),
      credito_max: Number(r.credito_max),
      nivel_soporte: r.nivel_soporte,
      role_id_discord: r.role_id_discord,
      orden: r.orden,
      seguridad_antihackeo_pct: r.seguridad_antihackeo_pct,
      seguro_dinero_pct: r.seguro_dinero_pct,
    }));
  });

export const comprarMembresia = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((d: { tipo: TipoMembresia }) =>
    z.object({
      tipo: z.enum(["basica", "gold", "zafiro", "esmeralda", "diamond", "ruby", "ruby_plus"]),
    }).parse(d),
  )
  .handler(async ({ data, context }) => {
    const { data: res, error } = await context.supabase.rpc("comprar_membresia", { _tipo: data.tipo });
    if (error) throw new Error(error.message);
    const roleId = (res as any)?.role_id_discord as string | null | undefined;

    const { data: u } = await supabaseAdmin
      .from("usuarios").select("id, discord_id").eq("auth_user_id", context.userId).single();

    if (u && roleId) {
      try {
        await addGuildRole(u.discord_id, DISCORD_GUILD_ID, roleId);
      } catch (e) {
        console.error("[comprarMembresia] addGuildRole:", (e as Error).message);
      }
    }
    if (u) {
      await notify({
        usuario_id: u.id,
        tipo: "transaccion",
        titulo: "🎖️ Membresía activada",
        descripcion: `Tu membresía **${data.tipo}** está activa.`,
        color: 0xd4af37,
      });
    }
    return { ok: true, tipo: data.tipo };
  });

export const setRoleIdMembresia = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((d: { tipo: TipoMembresia; role_id: string | null }) =>
    z.object({
      tipo: z.enum(["basica", "gold", "zafiro", "esmeralda", "diamond", "ruby", "ruby_plus"]),
      role_id: z.string().min(5).max(40).nullable(),
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
      .from("config_membresias")
      .update({ role_id_discord: data.role_id })
      .eq("tipo", data.tipo);
    if (error) throw new Error(error.message);
    return { ok: true };
  });
