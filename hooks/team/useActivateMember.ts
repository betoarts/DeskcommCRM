"use client";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api/client";
import { showApiError } from "@/components/feedback/ApiErrorToast";

export function useActivateMember() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (userId: string) => apiClient.post(`/api/v1/team/${userId}/activate`, {}),
    onError: showApiError,
    onSuccess: () => qc.invalidateQueries({ queryKey: ["team"] }),
  });
}

