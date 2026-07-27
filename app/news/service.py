import feedparser
from datetime import datetime
from typing import List, Dict, Any


GOOGLE_RSS_URL = "https://news.google.com/rss?hl=en-US&gl=US&ceid=US:en"


async def fetch_news() -> List[Dict[str, Any]]:
    """Fetch news from Google RSS feed."""
    try:
        feed = feedparser.parse(GOOGLE_RSS_URL)
        items = []
        for entry in feed.entries[:20]:
            # Try to extract image from media content
            image_url = None
            if hasattr(entry, "media_content") and entry.media_content:
                for media in entry.media_content:
                    if "url" in media:
                        image_url = media["url"]
                        break

            # Parse published date
            pub_date = None
            if hasattr(entry, "published_parsed") and entry.published_parsed:
                pub_date = datetime(*entry.published_parsed[:6])

            items.append({
                "title": entry.get("title", ""),
                "image": image_url,
                "description": entry.get("summary", ""),
                "url": entry.get("link", ""),
                "pub_date": pub_date,
            })

        return items
    except Exception as e:
        raise Exception(f"Failed to fetch news: {str(e)}")


async def fetch_iran_news() -> List[Dict[str, Any]]:
    """Fetch Iran-related news from Google RSS."""
    try:
        url = "https://news.google.com/rss/search?q=Iran&hl=en-US&gl=US&ceid=US:en"
        feed = feedparser.parse(url)
        items = []
        for entry in feed.entries[:20]:
            image_url = None
            if hasattr(entry, "media_content") and entry.media_content:
                for media in entry.media_content:
                    if "url" in media:
                        image_url = media["url"]
                        break

            pub_date = None
            if hasattr(entry, "published_parsed") and entry.published_parsed:
                pub_date = datetime(*entry.published_parsed[:6])

            items.append({
                "title": entry.get("title", ""),
                "image": image_url,
                "description": entry.get("summary", ""),
                "url": entry.get("link", ""),
                "pub_date": pub_date,
            })

        return items
    except Exception as e:
        raise Exception(f"Failed to fetch Iran news: {str(e)}")
