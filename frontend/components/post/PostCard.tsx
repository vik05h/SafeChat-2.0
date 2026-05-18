// frontend/components/post/PostCard.tsx
/**
 * Reusable post card.
 *
 * Displays author avatar + uid, relative timestamp, post body, optional image,
 * and a like button with optimistic count. The parent is responsible for
 * tracking is_liked state (supplied via the post object after optimistic updates).
 */

import {
  View,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
} from "react-native";
import { Avatar } from "@/components/ui/Avatar";
import { COLORS, BORDER_RADIUS } from "@/constants/theme";
import type { Post } from "@/lib/api";

// ── Helpers ────────────────────────────────────────────────────────────────

function timeAgo(dateStr: string): string {
  const diff = Math.floor((Date.now() - new Date(dateStr).getTime()) / 1000);
  if (diff < 60) return `${diff}s ago`;
  if (diff < 3_600) return `${Math.floor(diff / 60)}m ago`;
  if (diff < 86_400) return `${Math.floor(diff / 3_600)}h ago`;
  if (diff < 2_592_000) return `${Math.floor(diff / 86_400)}d ago`;
  return `${Math.floor(diff / 2_592_000)}mo ago`;
}

// ── Component ──────────────────────────────────────────────────────────────

interface PostCardProps {
  post: Post;
  onLike: (postId: string, isLiked: boolean) => void;
  currentUserUid: string;
}

export function PostCard({ post, onLike }: PostCardProps) {
  const isLiked = post.is_liked ?? false;

  return (
    <View style={styles.card}>
      {/* ── Header ── */}
      <View style={styles.header}>
        <Avatar uid={post.author_uid} size={36} />
        <View style={styles.headerMeta}>
          <Text style={styles.authorUid} numberOfLines={1}>
            {post.author_uid}
          </Text>
          <Text style={styles.timeAgo}>{timeAgo(post.created_at)}</Text>
        </View>
      </View>

      {/* ── Body ── */}
      <Text style={styles.text}>{post.text}</Text>

      {post.image_url ? (
        <Image
          source={{ uri: post.image_url }}
          style={styles.image}
          resizeMode="cover"
        />
      ) : null}

      {/* ── Footer ── */}
      <View style={styles.footer}>
        <TouchableOpacity
          style={styles.likeButton}
          onPress={() => onLike(post.id, isLiked)}
          activeOpacity={0.7}
        >
          <Text style={styles.likeIcon}>{isLiked ? "❤️" : "🤍"}</Text>
          <Text style={[styles.likeCount, isLiked && styles.likeCountActive]}>
            {post.likes_count}
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

// ── Styles ─────────────────────────────────────────────────────────────────

const styles = StyleSheet.create({
  card: {
    backgroundColor: COLORS.surface,
    marginHorizontal: 16,
    marginBottom: 12,
    borderRadius: BORDER_RADIUS.lg,
    padding: 16,
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 12,
  },
  headerMeta: {
    marginLeft: 10,
    flex: 1,
  },
  authorUid: {
    color: COLORS.textPrimary,
    fontWeight: "600",
    fontSize: 14,
  },
  timeAgo: {
    color: COLORS.textSecondary,
    fontSize: 12,
    marginTop: 1,
  },
  text: {
    color: COLORS.textPrimary,
    fontSize: 16,
    lineHeight: 24,
  },
  image: {
    width: "100%",
    height: 220,
    borderRadius: BORDER_RADIUS.md,
    marginTop: 12,
    backgroundColor: COLORS.surface2,
  },
  footer: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 12,
  },
  likeButton: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
  },
  likeIcon: {
    fontSize: 18,
  },
  likeCount: {
    color: COLORS.textSecondary,
    fontSize: 14,
  },
  likeCountActive: {
    color: COLORS.error,
  },
});
