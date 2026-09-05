import 'dart:async';
import 'package:elms/common/widgets/custom_image.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class CustomCarouselSliderWidget extends StatefulWidget {
  final List<CustomSliderItem> items;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Duration animationDuration;
  final Curve animationCurve;
  final double height;

  const CustomCarouselSliderWidget({
    super.key,
    required this.items,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOut,
    this.height = 200.0,
  });

  @override
  State<CustomCarouselSliderWidget> createState() =>
      _CustomCarouselSliderWidgetState();
}

class _CustomCarouselSliderWidgetState
    extends State<CustomCarouselSliderWidget> {
  late final PageController _pageController;
  late Timer? _timer = Timer(Duration.zero, () {});
  final ValueNotifier<int> currentPage = ValueNotifier<int>(0);

  List<int> get _loopedIndexes => [
    widget.items.length - 1,
    ...List.generate(widget.items.length, (i) => i),
    0,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    if (widget.items.length > 1) {
      _timer = Timer.periodic(widget.autoPlayInterval, (_) {
        _pageController.nextPage(
          duration: widget.animationDuration,
          curve: widget.animationCurve,
        );
      });
    }
  }

  void _resetAutoPlay() {
    if (widget.autoPlay && widget.items.length != 1) {
      _timer?.cancel();
      _startAutoPlay();
    }
  }

  void _handlePageChanged(int index) {
    final actualIndex = (index - 1) % widget.items.length;
    currentPage.value = actualIndex;

    // Infinite scroll jump
    if (index == 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _pageController.jumpToPage(widget.items.length);
      });
    } else if (index == widget.items.length + 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _pageController.jumpToPage(1);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onPanDown: (_) => _resetAutoPlay(),
      child: Column(
        children: [
          SizedBox(
            height: widget.height,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _loopedIndexes.length,
              onPageChanged: _handlePageChanged,
              physics: widget.items.length <= 1
                  ? const NeverScrollableScrollPhysics()
                  : null,
              itemBuilder: (context, index) {
                final realIndex = _loopedIndexes[index % _loopedIndexes.length];
                return Padding(
                  padding: const .symmetric(horizontal: 16),
                  child: widget.items[realIndex],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          if (widget.items.length > 1)
            ValueListenableBuilder<int>(
              valueListenable: currentPage,
              builder: (context, value, _) {
                const int maxDots = 5;
                final int total = widget.items.length;
                final int visibleCount = total.clamp(0, maxDots);

                int start;
                if (total <= maxDots) {
                  start = 0;
                } else {
                  start = (value - maxDots ~/ 2).clamp(0, total - maxDots);
                }

                return Row(
                  mainAxisAlignment: .center,
                  children: List.generate(visibleCount, (i) {
                    final index = start + i;
                    final isActive = index == value;
                    final isEdge =
                        total > maxDots && (i == 0 || i == visibleCount - 1);
                    return GestureDetector(
                      onTap: () {
                        _resetAutoPlay();
                        _pageController.animateToPage(
                          index + 1,
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
                        );
                      },
                      child: AnimatedContainer(
                        duration: Durations.medium1,
                        margin: const .all(2),
                        width: isActive ? 25 : (isEdge ? 5 : 8),
                        height: isEdge ? 5 : 8,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.black : null,
                          border: !isActive
                              ? .all(color: context.color.textSecondary)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
        ],
      ),
    );
  }
}

class CustomSliderItem extends StatefulWidget {
  final String url;
  final VoidCallback? onTap;

  const CustomSliderItem({super.key, required this.url, this.onTap});

  @override
  State<CustomSliderItem> createState() => _CustomSliderItemState();
}

class _CustomSliderItemState extends State<CustomSliderItem>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CustomImage(
              widget.url,
              width: double.infinity,
              height: 190,
              fit: .cover,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
