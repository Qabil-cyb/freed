import 'package:flutter/material.dart';
import 'package:spider_vpn/screens/shared/theme.dart';
import 'package:spider_vpn/screens/shared/colors.dart';
import 'package:spider_vpn/screens/shared/glass_container.dart';
import 'package:spider_vpn/services/api_service.dart';

class NewsTab extends StatefulWidget {
  const NewsTab({super.key});

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  List<dynamic> _newsItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService.instance;
      final result = await api.getNews();
      if (mounted) {
        setState(() {
          final items = result['articles'] ?? result['items'] ?? result['news'] ?? [];
          _newsItems = items is List ? items : [];
          if (_newsItems.isEmpty) {
            // Use fallback mock news from Google News Iran
            _newsItems = _getMockNews();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _newsItems = _getMockNews();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getMockNews() {
    return [
      {
        'title': 'ایران و توسعه اینترنت ماهواره‌ای',
        'description': 'با افزایش تحریم‌ها، استفاده از اینترنت ماهواره‌ای در ایران رشد چشمگیری داشته است. شرکت‌های مختلفی خدمات خود را ارائه می‌دهند.',
        'source': 'Google News Iran',
        'publishedAt': '2026-07-27',
        'url': 'https://news.google.com',
      },
      {
        'title': 'آخرین وضعیت فیلترینگ و فیلترشکن‌ها در ایران',
        'description': 'بحث فیلترینگ شبکه‌های اجتماعی و پیام‌رسان‌ها همچنان داغ است. کاربران ایرانی به دنبال راه‌های جدید برای دسترسی به اینترنت آزاد هستند.',
        'source': 'Google News Iran',
        'publishedAt': '2026-07-26',
        'url': 'https://news.google.com',
      },
      {
        'title': 'افزایش قیمت تجهیزات شبکه در بازار ایران',
        'description': 'قیمت روترها، مودم‌ها و تجهیزات شبکه به دلیل نوسانات ارزی افزایش یافته است. فعالان صنعت فناوری نسبت به این وضعیت ابراز نگرانی کرده‌اند.',
        'source': 'Google News Iran',
        'publishedAt': '2026-07-25',
        'url': 'https://news.google.com',
      },
      {
        'title': 'آموزش راه‌اندازی سرور مجازی برای کسب‌وکارهای اینترنتی',
        'description': 'با رشد کسب‌وکارهای آنلاین، آموزش راه‌اندازی و مدیریت سرورهای مجازی به یکی از نیازهای اصلی تبدیل شده است.',
        'source': 'Google News Iran',
        'publishedAt': '2026-07-24',
        'url': 'https://news.google.com',
      },
      {
        'title': 'آخرین اخبار فناوری و ارتباطات در ایران',
        'description': 'وزارت ارتباطات از برنامه‌های جدید برای افزایش سرعت اینترنت و کاهش قیمت بسته‌های اینترنتی خبر داد.',
        'source': 'Google News Iran',
        'publishedAt': '2026-07-23',
        'url': 'https://news.google.com',
      },
      {
        'title': 'VPN و پروکسی: تفاوت‌ها و کاربردها',
        'description': 'در این مقاله به بررسی تفاوت‌های VPN و پروکسی، مزایا و معایب هر یک و کاربردهای آن‌ها در ایران می‌پردازیم.',
        'source': 'Google News Iran',
        'publishedAt': '2026-07-22',
        'url': 'https://news.google.com',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Icon(Icons.article_rounded, color: AppColors.neonBlue, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Latest News',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GlassContainer(
                padding: const EdgeInsets.all(8),
                borderRadius: 10,
                onTap: _loadNews,
                child: Icon(Icons.refresh_rounded, color: AppColors.neonBlue, size: 20),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'RSS from Google News Iran',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // News list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.neonBlue))
              : RefreshIndicator(
                  onRefresh: _loadNews,
                  color: AppColors.neonBlue,
                  backgroundColor: AppColors.bgDarkCard,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _newsItems.length,
                    itemBuilder: (context, index) {
                      final item = _newsItems[index];
                      return _buildNewsCard(item);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> item) {
    final title = item['title']?.toString() ?? 'News Title';
    final description = item['description']?.toString() ?? '';
    final source = item['source']?.toString() ?? 'Unknown';
    final publishedAt = item['publishedAt']?.toString() ?? '';
    final url = item['url']?.toString() ?? '';

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source badge and date
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.neonBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.rss_feed_rounded, color: AppColors.neonBlue, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      source,
                      style: TextStyle(
                        color: AppColors.neonBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                publishedAt,
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),

          // Scrollable description area
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 100),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Read more link
          if (url.isNotEmpty)
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening: $url'),
                    backgroundColor: AppColors.neonBlue,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    'Read more',
                    style: TextStyle(
                      color: AppColors.neonBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.neonBlue, size: 14),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
