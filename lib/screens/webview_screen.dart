import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _configureAudioSession();
    _initializeWebView();
  }

  void _configureAudioSession() async {
    if (Platform.isIOS) {
      try {
        // Configure iOS audio session for webview audio playback
        const platform = MethodChannel('com.andy.ezlearning/audio');
        await platform.invokeMethod('configureAudioSession');
        debugPrint('🔊 iOS audio session configured for physical device');
      } catch (e) {
        debugPrint('🚨 Failed to configure iOS audio session: $e');
      }
    }
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('🌐 WebView loading progress: $progress%');
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            debugPrint('🌐 WebView started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            debugPrint('🌐 WebView finished loading: $url');

            // Enable audio playback after page loads with multiple attempts
            Future.delayed(const Duration(milliseconds: 500), () {
              _enableAudioPlayback();
            });

            // Additional attempts to unlock audio
            Future.delayed(const Duration(milliseconds: 1500), () {
              _enableAudioPlayback();
            });

            Future.delayed(const Duration(milliseconds: 3000), () {
              _enableAudioPlayback();
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('🌐 WebView error: ${error.description}');
          },
        ),
      );

    // Configure platform-specific settings for audio
    _configurePlatformSettings();

    _controller.loadRequest(Uri.parse(widget.url));
  }

  void _configurePlatformSettings() {
    debugPrint('🔊 Configuring platform settings for audio playback');

    // Configure iOS-specific webview settings for media playback
    if (Platform.isIOS) {
      // Add iOS-specific webview configuration
      _controller.setUserAgent(
          'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1');
      debugPrint('🔊 iOS webview configured for media playback');
    }
  }

  void _enableAudioPlayback() {
    // Inject comprehensive JavaScript to enable audio context and autoplay
    _controller.runJavaScript('''
      console.log('🔊 Starting AGGRESSIVE audio playback configuration...');

      // Global audio unlock flag
      window.audioUnlocked = false;

      // Function to unlock audio context
      function unlockAudioContext() {
        console.log('🔊 Attempting to unlock audio context...');

        if (typeof AudioContext !== 'undefined' || typeof webkitAudioContext !== 'undefined') {
          try {
            var audioContext = new (window.AudioContext || window.webkitAudioContext)();
            console.log('🔊 Audio context created, state:', audioContext.state);

            if (audioContext.state === 'suspended') {
              audioContext.resume().then(() => {
                console.log('🔊 Audio context resumed successfully');
                window.audioUnlocked = true;
              }).catch((error) => {
                console.log('🚨 Failed to resume audio context:', error);
              });
            } else {
              console.log('🔊 Audio context already running');
              window.audioUnlocked = true;
            }

            // Store audio context globally for games to use
            window.audioContext = audioContext;

            // Create a silent audio buffer to unlock audio
            var buffer = audioContext.createBuffer(1, 1, 22050);
            var source = audioContext.createBufferSource();
            source.buffer = buffer;
            source.connect(audioContext.destination);
            source.start(0);
            console.log('🔊 Silent audio buffer played to unlock audio');

          } catch (error) {
            console.log('🚨 Error creating audio context:', error);
          }
        } else {
          console.log('🚨 AudioContext not supported');
        }
      }

      // Function to configure audio elements
      function configureAudioElements() {
        // Find all audio elements
        var audioElements = document.querySelectorAll('audio');
        console.log('🔊 Found', audioElements.length, 'audio elements');

        audioElements.forEach(function(audio, index) {
          console.log('🔊 Configuring audio element', index);

          // Set all audio properties for iOS compatibility
          audio.muted = false;
          audio.volume = 1.0;
          audio.preload = 'auto';
          audio.autoplay = false; // Don't autoplay, wait for user interaction
          audio.controls = false;
          audio.loop = false;

          // iOS-specific attributes
          audio.setAttribute('playsinline', 'true');
          audio.setAttribute('webkit-playsinline', 'true');
          audio.setAttribute('x-webkit-airplay', 'allow');

          // Add comprehensive event listeners
          audio.addEventListener('canplay', function() {
            console.log('🔊 Audio element', index, 'can play');
          });

          audio.addEventListener('canplaythrough', function() {
            console.log('🔊 Audio element', index, 'can play through');
          });

          audio.addEventListener('loadeddata', function() {
            console.log('🔊 Audio element', index, 'loaded data');
          });

          audio.addEventListener('loadedmetadata', function() {
            console.log('🔊 Audio element', index, 'loaded metadata');
          });

          audio.addEventListener('play', function() {
            console.log('🔊 Audio element', index, 'started playing');
          });

          audio.addEventListener('pause', function() {
            console.log('🔊 Audio element', index, 'paused');
          });

          audio.addEventListener('ended', function() {
            console.log('🔊 Audio element', index, 'ended');
          });

          audio.addEventListener('error', function(e) {
            console.log('🚨 Audio element', index, 'error:', e.target.error);
          });

          audio.addEventListener('loadstart', function() {
            console.log('🔊 Audio element', index, 'started loading');
          });

          // Force load the audio
          try {
            audio.load();
            console.log('🔊 Audio element', index, 'load() called');
          } catch (error) {
            console.log('🚨 Error loading audio element', index, ':', error);
          }
        });

        // Also look for any dynamically created audio elements
        var observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            mutation.addedNodes.forEach(function(node) {
              if (node.tagName === 'AUDIO') {
                console.log('🔊 New audio element detected, configuring...');
                configureAudioElements();
              }
            });
          });
        });

        observer.observe(document.body, { childList: true, subtree: true });
      }

      // Unlock audio on first user interaction
      function handleFirstInteraction(event) {
        console.log('🔊 AGGRESSIVE user interaction detected:', event.type);

        // Unlock audio context first
        unlockAudioContext();

        // Configure all audio elements
        configureAudioElements();

        // Wait a bit then try to unlock all audio elements
        setTimeout(function() {
          var audioElements = document.querySelectorAll('audio');
          console.log('🔊 Attempting to unlock', audioElements.length, 'audio elements');

          audioElements.forEach(function(audio, index) {
            console.log('🔊 Unlocking audio element', index);

            // Set all iOS-compatible properties
            audio.setAttribute('playsinline', 'true');
            audio.setAttribute('webkit-playsinline', 'true');
            audio.setAttribute('x-webkit-airplay', 'allow');
            audio.muted = false;
            audio.volume = 1.0;
            audio.preload = 'auto';

            // Try to play and immediately pause to unlock
            var playPromise = audio.play();
            if (playPromise !== undefined) {
              playPromise.then(() => {
                console.log('🔊 Audio element', index, 'SUCCESSFULLY UNLOCKED');
                setTimeout(() => {
                  audio.pause();
                  audio.currentTime = 0;
                  console.log('🔊 Audio element', index, 'paused and reset');
                }, 100);
              }).catch((error) => {
                console.log('🚨 Failed to unlock audio element', index, ':', error.name, error.message);
              });
            } else {
              console.log('🚨 Audio element', index, 'play() returned undefined');
            }
          });
        }, 100);

        // Also try to unlock Web Audio API
        if (window.audioContext) {
          if (window.audioContext.state === 'suspended') {
            window.audioContext.resume().then(() => {
              console.log('🔊 Web Audio API SUCCESSFULLY UNLOCKED on user interaction');
              window.audioUnlocked = true;
            }).catch((error) => {
              console.log('🚨 Failed to unlock Web Audio API:', error);
            });
          } else {
            console.log('🔊 Web Audio API already unlocked, state:', window.audioContext.state);
            window.audioUnlocked = true;
          }
        }

        // Try to trigger any game-specific audio initialization
        setTimeout(function() {
          // Look for common game audio initialization patterns
          if (typeof window.initAudio === 'function') {
            console.log('🔊 Calling window.initAudio()');
            window.initAudio();
          }

          if (typeof window.enableSound === 'function') {
            console.log('🔊 Calling window.enableSound()');
            window.enableSound();
          }

          if (typeof window.startAudio === 'function') {
            console.log('🔊 Calling window.startAudio()');
            window.startAudio();
          }

          // Dispatch custom events that games might listen for
          document.dispatchEvent(new Event('audioUnlocked'));
          document.dispatchEvent(new Event('userInteraction'));
          window.dispatchEvent(new Event('audioEnabled'));

          console.log('🔊 Custom audio events dispatched');
        }, 200);

        console.log('🔊 Audio unlock sequence completed');
      }

      // Add PERSISTENT event listeners for user interaction (not just once)
      document.addEventListener('touchstart', handleFirstInteraction, { passive: true });
      document.addEventListener('touchend', handleFirstInteraction, { passive: true });
      document.addEventListener('touchmove', handleFirstInteraction, { passive: true });
      document.addEventListener('click', handleFirstInteraction, { passive: true });
      document.addEventListener('mousedown', handleFirstInteraction, { passive: true });
      document.addEventListener('mouseup', handleFirstInteraction, { passive: true });
      document.addEventListener('keydown', handleFirstInteraction, { passive: true });
      document.addEventListener('keyup', handleFirstInteraction, { passive: true });
      document.addEventListener('pointerdown', handleFirstInteraction, { passive: true });
      document.addEventListener('pointerup', handleFirstInteraction, { passive: true });

      // Also listen on window
      window.addEventListener('touchstart', handleFirstInteraction, { passive: true });
      window.addEventListener('click', handleFirstInteraction, { passive: true });
      window.addEventListener('keydown', handleFirstInteraction, { passive: true });

      console.log('🔊 ALL interaction event listeners added');

      // Aggressive approach - try to unlock on page load and periodically
      window.addEventListener('load', function() {
        console.log('🔊 Page loaded, starting aggressive audio unlock...');

        setTimeout(function() {
          console.log('🔊 First unlock attempt (1s after load)');
          unlockAudioContext();
          configureAudioElements();
        }, 1000);

        setTimeout(function() {
          console.log('🔊 Second unlock attempt (3s after load)');
          unlockAudioContext();
          configureAudioElements();
        }, 3000);

        setTimeout(function() {
          console.log('🔊 Third unlock attempt (5s after load)');
          unlockAudioContext();
          configureAudioElements();
        }, 5000);
      });

      // Try to unlock immediately if DOM is already loaded
      if (document.readyState === 'complete' || document.readyState === 'interactive') {
        console.log('🔊 DOM already loaded, immediate unlock attempt');
        setTimeout(function() {
          unlockAudioContext();
          configureAudioElements();
        }, 500);
      }

      // Configure audio when DOM is ready
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
          console.log('🔊 DOM loaded, configuring audio elements');
          configureAudioElements();
        });
      } else {
        console.log('🔊 DOM already loaded, configuring audio elements');
        configureAudioElements();
      }

      // Also try to unlock audio context immediately if possible
      unlockAudioContext();

      // AGGRESSIVE iOS-specific audio unlock for PHYSICAL DEVICES
      if (navigator.userAgent.includes('iPhone') || navigator.userAgent.includes('iPad')) {
        console.log('🔊 PHYSICAL iOS device detected, applying AGGRESSIVE audio fixes');

        // Override ALL audio-related methods
        var originalPlay = HTMLAudioElement.prototype.play;
        var originalPause = HTMLAudioElement.prototype.pause;
        var originalLoad = HTMLAudioElement.prototype.load;

        HTMLAudioElement.prototype.play = function() {
          console.log('🔊 OVERRIDDEN Audio play() called on physical device');
          this.muted = false;
          this.volume = 1.0;
          this.setAttribute('playsinline', 'true');
          this.setAttribute('webkit-playsinline', 'true');
          this.setAttribute('x-webkit-airplay', 'allow');
          this.preload = 'auto';
          this.autoplay = false;

          // Force audio session activation
          if (window.audioContext && window.audioContext.state === 'suspended') {
            window.audioContext.resume();
          }

          return originalPlay.call(this);
        };

        HTMLAudioElement.prototype.pause = function() {
          console.log('🔊 OVERRIDDEN Audio pause() called on physical device');
          return originalPause.call(this);
        };

        HTMLAudioElement.prototype.load = function() {
          console.log('🔊 OVERRIDDEN Audio load() called on physical device');
          this.setAttribute('playsinline', 'true');
          this.setAttribute('webkit-playsinline', 'true');
          this.setAttribute('x-webkit-airplay', 'allow');
          return originalLoad.call(this);
        };

        // AGGRESSIVE audio enabling for physical devices
        setTimeout(function() {
          console.log('🔊 PHYSICAL DEVICE: Aggressive audio reload');
          var audioElements = document.querySelectorAll('audio');
          audioElements.forEach(function(audio, index) {
            console.log('🔊 PHYSICAL DEVICE: Reloading audio element', index);
            audio.load();
            audio.muted = false;
            audio.volume = 1.0;

            // Try to play immediately on physical device
            setTimeout(function() {
              var playPromise = audio.play();
              if (playPromise) {
                playPromise.then(() => {
                  console.log('🔊 PHYSICAL DEVICE: Audio', index, 'unlocked successfully');
                  audio.pause();
                  audio.currentTime = 0;
                }).catch((error) => {
                  console.log('🚨 PHYSICAL DEVICE: Audio', index, 'unlock failed:', error);
                });
              }
            }, 100 * index); // Stagger attempts
          });
        }, 1000);

        // Additional physical device audio session activation
        setTimeout(function() {
          if (window.audioContext) {
            console.log('🔊 PHYSICAL DEVICE: Force audio context resume');
            window.audioContext.resume().then(() => {
              console.log('🔊 PHYSICAL DEVICE: Audio context resumed successfully');
            });
          }
        }, 2000);
      }

      console.log('🔊 Audio playback configuration completed');
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: const Color(0xFFF8F9FA),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
