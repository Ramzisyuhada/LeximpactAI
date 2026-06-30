import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:leximpactai/core/color/app_colors.dart';

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  late final VideoPlayerController _videoController;
  late final PageController _pageController;

  int _currentPage = 0;
  bool _hasVideoError = false;
  bool _videoFinished = false;
  bool _isVideoInitializing = true;

  static const List<String> _slides = [
    'assets/ppt/1.jpg',
    'assets/ppt/2.jpg',
    'assets/ppt/3.jpg',
    'assets/ppt/4.jpg',
    'assets/ppt/5.jpg',
    'assets/ppt/6.jpg',
    'assets/ppt/7.jpg',
    'assets/ppt/8.jpg',
    'assets/ppt/9.jpg',
    'assets/ppt/10.jpg',
    'assets/ppt/11.jpg',
    'assets/ppt/12.jpg',
    'assets/ppt/13.jpg',
    'assets/ppt/14.jpg',
    'assets/ppt/15.jpg',
    'assets/ppt/16.jpg',
    'assets/ppt/17.jpg',
    'assets/ppt/19.jpg',
    'assets/ppt/20.jpg',
    'assets/ppt/21.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset('assets/video/Video.mp4');

    try {
      await _videoController.initialize();
      _videoController.addListener(_onVideoTick);
      if (mounted) {
        setState(() => _isVideoInitializing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasVideoError = true;
          _isVideoInitializing = false;
        });
      }
    }
  }

  void _onVideoTick() {
    final value = _videoController.value;
    if (!value.isInitialized) return;

    final isFinished =
        value.position >= value.duration && value.duration > Duration.zero;

    if (isFinished && !_videoFinished) {
      setState(() => _videoFinished = true);
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_onVideoTick);
    _videoController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Materi Pembelajaran'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildVideo(),
            ),
            if (_videoController.value.isInitialized) _buildVideoProgress(),
            const SizedBox(height: 16),
            _buildSectionLabel(),
            const SizedBox(height: 10),
            _buildSlideViewer(),
            const SizedBox(height: 10),
            _buildIndicator(),
            const SizedBox(height: 10),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  /// 🎥 VIDEO PLAYER
  Widget _buildVideo() {
    if (_isVideoInitializing) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.border.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_hasVideoError) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.border.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 36),
                const SizedBox(height: 8),
                Text(
                  'Video gagal dimuat',
                  style: GoogleFonts.poppins(color: AppColors.text),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_videoController.value.isPlaying) {
            _videoController.pause();
          } else {
            _videoController.play();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: VideoPlayer(_videoController),
            ),
          ),

          // Overlay gelap halus saat pause / selesai, supaya ikon kontras
          if (!_videoController.value.isPlaying)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ),

          // Ikon play/replay
          if (!_videoController.value.isPlaying)
            Icon(
              _videoFinished ? Icons.replay_circle_filled : Icons.play_circle,
              size: 64,
              color: Colors.white,
            ).animate().fadeIn().scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                ),

          // Badge "Selesai" di pojok
          if (_videoFinished)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Selesai',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn().scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
        );
  }

  /// 📊 PROGRESS BAR VIDEO + DURASI
  Widget _buildVideoProgress() {
    final position = _videoController.value.position;
    final duration = _videoController.value.duration;

    String fmt(Duration d) {
      final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$m:$s';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          VideoProgressIndicator(
            _videoController,
            allowScrubbing: true,
            padding: EdgeInsets.zero,
            colors: const VideoProgressColors(
              playedColor: Colors.green,
              bufferedColor: AppColors.border,
              backgroundColor: AppColors.border,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fmt(position),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.text.withOpacity(0.6),
                ),
              ),
              Text(
                fmt(duration),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.text.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📚 LABEL SECTION
  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '📚 Pre Employment',
            style: GoogleFonts.poppins(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Text(
            'Slide ${_currentPage + 1} / ${_slides.length}',
            style: GoogleFonts.poppins(
              color: AppColors.text.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  /// 🖼️ SLIDE VIEWER (SWIPE) + TOMBOL PREV/NEXT
  Widget _buildSlideViewer() {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      _slides[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.border.withOpacity(0.2),
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 40),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // Tombol slide sebelumnya
          if (_currentPage > 0)
            Positioned(
              left: 4,
              child: _SlideNavButton(
                icon: Icons.chevron_left,
                onTap: () => _pageController.previousPage(
                  duration: 250.ms,
                  curve: Curves.easeOut,
                ),
              ),
            ),

          // Tombol slide berikutnya
          if (_currentPage < _slides.length - 1)
            Positioned(
              right: 4,
              child: _SlideNavButton(
                icon: Icons.chevron_right,
                onTap: () => _pageController.nextPage(
                  duration: 250.ms,
                  curve: Curves.easeOut,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 🔘 DOT INDICATOR (scrollable agar tetap rapi walau slide banyak)
  Widget _buildIndicator() {
    return SizedBox(
      height: 16,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _slides.length,
        itemBuilder: (context, index) {
          final isActive = _currentPage == index;
          return AnimatedContainer(
            duration: 250.ms,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 16 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }

  /// 🚀 NEXT BUTTON
  /// Tombol baru aktif setelah video selesai ditonton ATAU semua slide
  /// sudah pernah dilihat, supaya proses belajar lebih terjamin.
  Widget _buildNextButton() {
    final isLastSlide = _currentPage == _slides.length - 1;
    final canProceed = _videoFinished || _hasVideoError || isLastSlide;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!canProceed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Tonton video sampai selesai atau buka semua slide untuk lanjut',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.text.withOpacity(0.6),
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canProceed
                  ? () {
                      // Ganti dengan context.push('/simulasi') bila menggunakan go_router
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.green.withOpacity(0.4),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Lanjut ke Simulasi',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

/// Tombol bulat kecil untuk navigasi slide prev/next.
class _SlideNavButton extends StatelessWidget {
  const _SlideNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}