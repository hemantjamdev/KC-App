import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_full_screen_image_dialog.dart';

/// Modular Image Carousel PageView with full-screen gallery viewer.
class DesignImageCarousel extends StatefulWidget {
  const DesignImageCarousel({super.key, required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<DesignImageCarousel> createState() => _DesignImageCarouselState();
}

class _DesignImageCarouselState extends State<DesignImageCarousel> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;

    return SizedBox(
      height: 380,
      child: Stack(
        children: [
          Positioned.fill(
            child: urls.isNotEmpty
                ? PageView.builder(
                    itemCount: urls.length,
                    onPageChanged: (idx) {
                      setState(() => _currentImageIndex = idx);
                    },
                    itemBuilder: (ctx, idx) {
                      return GestureDetector(
                        onTap: () => AppFullScreenImageDialog.show(
                          context,
                          imageUrls: urls,
                          initialIndex: idx,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: urls[idx],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.softCream,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.brandGreen800,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.softCream,
                            child: const Center(
                              child: Icon(
                                Icons.checkroom_rounded,
                                size: 48,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppColors.softCream,
                    child: const Center(
                      child: Icon(
                        Icons.checkroom_rounded,
                        size: 48,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ),
          ),

          // Image Page Indicator
          if (urls.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (idx) {
                  final isActive = idx == _currentImageIndex;
                  return Container(
                    width: isActive ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.surfaceWhite
                          : AppColors.surfaceWhite.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
