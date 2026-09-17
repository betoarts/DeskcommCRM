import { requireSupportWrite } from "@/lib/impersonate/support";
import { randomUUID } from "node:crypto";
import type { NextRequest } from "next/server";
import { ok, fail } from "@/lib/api/wrappers";
import { audit } from "@/lib/audit";
import { requireRole } from "@/lib/auth/require-role";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export async function POST(_req: NextRequest, ctx: { params: Promise<{ user_id: string }> }): Promise<Response> {
  const supportDenied = await requireSupportWrite();
  if (supportDenied) return supportDenied;
  const requestId = randomUUID();
  const { user_id: targetUserId } = await ctx.params;
  const authz = await requireRole("admin", { requestId, resource: "team" });
  if (!authz.ok) return authz.response;
  const { user: authUser, org } = authz;
  const supabase = await createClient();
  const { data: target, error: fetchErr } = await supabase
    .from("user_organizations")
    .select("id, revoked_at")
    .eq("organization_id", org.orgId)
    .eq("user_id", targetUserId)
    .maybeSingle();
  if (fetchErr) return fail("internal_error", fetchErr.message, 500, { requestId });
  if (!target) return fail("not_found", "Membro não encontrado.", 404, { requestId });
  if (!target.revoked_at) return ok({ user_id: targetUserId, already_active: true }, { requestId });
  const now = new Date().toISOString();
  const { error } = await supabase.from("user_organizations").update({ revoked_at: null, updated_at: now }).eq("id", target.id);
  if (error) return fail("internal_error", error.message, 500, { requestId });
  await audit({ action: "member.activated", actorUserId: authUser.id, organizationId: org.orgId, resourceType: "membership", resourceId: target.id, requestId, metadata: { target_user_id: targetUserId } });
  return ok({ user_id: targetUserId, activated_at: now }, { requestId });
}

