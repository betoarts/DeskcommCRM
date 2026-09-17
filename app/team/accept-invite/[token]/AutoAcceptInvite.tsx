"use client";

import { useEffect, useState, useTransition } from "react";

import { acceptInviteAction } from "@/app/actions/team/acceptInvite";
import { AcceptInviteForm } from "./AcceptInviteForm";

export function AutoAcceptInvite({
  token,
  failureLabel,
  pendingLabel,
  retryLabel,
}: {
  token: string;
  failureLabel: string;
  pendingLabel: string;
  retryLabel: string;
}) {
  const [failure, setFailure] = useState(false);
  const [, startTransition] = useTransition();

  useEffect(() => {
    startTransition(async () => {
      const result = await acceptInviteAction(token);
      if (!result.ok) setFailure(true);
    });
  }, [token]);

  if (failure) {
    return (
      <>
        <p role="alert" className="mt-4 text-sm text-destructive">
          {failureLabel}
        </p>
        <AcceptInviteForm
          token={token}
          label={retryLabel}
          pendingLabel={pendingLabel}
          failureLabel={failureLabel}
        />
      </>
    );
  }

  return (
    <p role="status" className="mt-4 text-sm text-muted-foreground">
      {pendingLabel}
    </p>
  );
}
