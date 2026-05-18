// frontend/hooks/useApi.ts
/**
 * Thin wrappers around TanStack Query that wire in the Axios api client.
 *
 * useGet   — data-fetching queries (GET).
 * useApiMutation — CUD operations (POST / PATCH / PUT / DELETE).
 *
 * Both are generic so callers get full type inference without extra boilerplate.
 */

import {
  useQuery,
  useMutation,
  type UseQueryOptions,
  type UseMutationOptions,
} from "@tanstack/react-query";
import type { AxiosResponse } from "axios";
import api from "@/lib/api";

export function useGet<TData>(
  queryKey: unknown[],
  url: string,
  options?: Omit<UseQueryOptions<TData, Error>, "queryKey" | "queryFn">
) {
  return useQuery<TData, Error>({
    queryKey,
    queryFn: async () => {
      const res: AxiosResponse<TData> = await api.get(url);
      return res.data;
    },
    ...options,
  });
}

export function useApiMutation<TData, TVariables = void>(
  method: "post" | "patch" | "put" | "delete",
  url: string | ((vars: TVariables) => string),
  options?: UseMutationOptions<TData, Error, TVariables>
) {
  return useMutation<TData, Error, TVariables>({
    mutationFn: async (variables) => {
      const resolvedUrl =
        typeof url === "function" ? url(variables) : url;
      const res: AxiosResponse<TData> =
        method === "delete"
          ? await api.delete(resolvedUrl)
          : await api[method](resolvedUrl, variables);
      return res.data;
    },
    ...options,
  });
}
