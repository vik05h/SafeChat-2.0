# backend/moderation/vision.py
"""Google Cloud Vision SafeSearch image moderation.

Calls the Vision API's safe_search_detection endpoint to screen images for
adult, violent, and racy content before they are surfaced to other users.

Thresholds (Likelihood scale: 1=VERY_UNLIKELY … 5=VERY_LIKELY):
  - adult    : LIKELY (4) or above → blocked
  - violence : LIKELY (4) or above → blocked
  - racy     : VERY_LIKELY (5) only → blocked

The check is guarded by SAFECHAT_VISION_ENABLED (default on). Setting it to
"0" or "false" skips the API call and returns a skipped=True verdict — useful
for local development without a Vision-enabled service account.
"""

from __future__ import annotations

import asyncio
import logging
import os
from typing import Any

from google.cloud import vision
from google.cloud.vision import Likelihood

from models.moderation import VisionVerdict

logger = logging.getLogger(__name__)

_VISION_ENABLED: bool = (
    os.getenv("SAFECHAT_VISION_ENABLED", "1") not in ("0", "false", "False")
)

# Map annotation attribute → minimum Likelihood int value that triggers a block.
_BLOCK_IF_GTE: dict[str, int] = {
    "adult": int(Likelihood.LIKELY),        # 4
    "violence": int(Likelihood.LIKELY),     # 4
    "racy": int(Likelihood.VERY_LIKELY),    # 5
}


def _annotate(image_url: str) -> Any:
    """Call the Vision API — thin wrapper kept as a monkeypatch seam in tests."""
    client = vision.ImageAnnotatorClient()
    image = vision.Image(source=vision.ImageSource(image_uri=image_url))
    return client.safe_search_detection(image=image)


async def check_image_with_vision(image_url: str) -> VisionVerdict:
    """Run SafeSearch detection on image_url and return a VisionVerdict.

    Fail-open: any exception from the Vision API returns
    ``VisionVerdict(blocked=False, error=True)`` so a transient API failure
    never prevents a post from being stored.

    Args:
        image_url: Publicly reachable URL of the image to screen.

    Returns:
        VisionVerdict with ``blocked=True`` if any attribute meets its
        threshold, ``skipped=True`` if Vision is disabled, or ``error=True``
        if the API call raised an exception.
    """
    if not _VISION_ENABLED:
        return VisionVerdict(blocked=False, skipped=True)

    try:
        response = await asyncio.to_thread(_annotate, image_url)
    except Exception as exc:
        logger.warning("Vision SafeSearch call failed: %s", exc)
        return VisionVerdict(blocked=False, error=True)

    ann = response.safe_search_annotation
    for attr, threshold in _BLOCK_IF_GTE.items():
        likelihood = int(getattr(ann, attr, Likelihood.UNKNOWN))
        if likelihood >= threshold:
            logger.info(
                "Vision blocked image (attr=%s, likelihood=%d, threshold=%d)",
                attr,
                likelihood,
                threshold,
            )
            return VisionVerdict(blocked=True, category=attr)

    return VisionVerdict(blocked=False)
