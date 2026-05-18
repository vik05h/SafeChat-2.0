// frontend/hooks/useFeed.ts
/**
 * Feed data hook — wraps TanStack Query with optimistic like/unlike support.
 *
 * Optimistic update flow:
 *   1. onMutate  — snapshot cache, apply toggle immediately.
 *   2. onError   — restore snapshot if the server rejects.
 *   3. onSettled — invalidate so a background refetch reconciles truth.
 *
 * This means the UI never waits for the network on a like tap.
 */

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  getFeed,
  likePost,
  unlikePost,
  type Post,
  type PostsResponse,
} from "@/lib/api";

export const FEED_QUERY_KEY = ["feed"] as const;

export function useFeed() {
  const queryClient = useQueryClient();

  // ── Query ────────────────────────────────────────────────────────────────

  const query = useQuery<PostsResponse, Error>({
    queryKey: FEED_QUERY_KEY,
    queryFn: () => getFeed(20),
  });

  // ── Like / unlike mutation ───────────────────────────────────────────────

  const likeMutation = useMutation<
    void,
    Error,
    { postId: string; isLiked: boolean },
    { snapshot: PostsResponse | undefined }
  >({
    mutationFn: ({ postId, isLiked }) =>
      isLiked ? unlikePost(postId) : likePost(postId),

    onMutate: async ({ postId, isLiked }) => {
      // Cancel any in-flight refetches so they don't overwrite the optimistic update.
      await queryClient.cancelQueries({ queryKey: FEED_QUERY_KEY });

      const snapshot = queryClient.getQueryData<PostsResponse>(FEED_QUERY_KEY);

      queryClient.setQueryData<PostsResponse>(FEED_QUERY_KEY, (old) => {
        if (!old) return old;
        return {
          ...old,
          data: {
            posts: old.data.posts.map((p: Post) =>
              p.id === postId
                ? {
                    ...p,
                    is_liked: !isLiked,
                    likes_count: Math.max(
                      0,
                      p.likes_count + (isLiked ? -1 : 1)
                    ),
                  }
                : p
            ),
          },
        };
      });

      return { snapshot };
    },

    onError: (_err, _vars, context) => {
      if (context?.snapshot !== undefined) {
        queryClient.setQueryData(FEED_QUERY_KEY, context.snapshot);
      }
    },

    onSettled: () => {
      void queryClient.invalidateQueries({ queryKey: FEED_QUERY_KEY });
    },
  });

  // ── Public API ───────────────────────────────────────────────────────────

  return {
    posts: query.data?.data.posts ?? [],
    isLoading: query.isLoading,
    isError: query.isError,
    isRefetching: query.isRefetching,
    refetch: query.refetch,
    toggleLike: (postId: string, isLiked: boolean) =>
      likeMutation.mutate({ postId, isLiked }),
  };
}
